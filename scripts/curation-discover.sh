#!/usr/bin/env bash
# =============================================================================
# curation-discover.sh — MONTHLY discovery sweep for the marketplace curation
# engine (Slice 5, specs/marketplace-curation-engine). US-5.
#
# Surfaces NEWLY-published community skills in covered domains and runs them
# through three gates before PROPOSING them (proposal only — never auto-added,
# observe-never-install):
#   1. trust   — public popularity/maintenance signals (trust-score.sh)  [LLM-FREE]
#   2. skill   — the repo must ship a SKILL.md (a link list or a product repo has
#                nothing to install: rejected `no-skill`)                 [LLM-FREE]
#   3. safety  — pin-time integrity content scan (curation-safety.sh), at the
#                root AND over the skill directories the judge reads      [LLM-FREE]
#   4. judge   — advice-neutrality + fit, via an LLM (claude -p), Haiku triage with
#                escalation of borderline cases. It reads the SHIPPED skills
#                (path, name, description, then bodies, up to
#                CURATION_SKILL_DOSSIER_CAP chars, 6000; at most
#                CURATION_SKILL_DOSSIER_MAX skills read, 12), never the README:
#                the README describes the product, the skill is what a user
#                installs.                                                [LLM]
# The two cheap deterministic gates run FIRST so the costly LLM is consulted only
# for candidates already worth judging.
#
# EF-012 / billing-safety: the LLM portion runs under a HARD token budget and is
# FAIL-SAFE — budget exhaustion DEFERS the remaining candidates and is reported,
# never a silent stop or runaway spend. From 2026-06-15 Anthropic meters
# `claude -p` on a separate credit, so this job belongs on a DEDICATED CAPPED API
# key (see docs/recipes/curation-bot-deploy.md), separate from the $0 nightly watch.
#
# The model call is indirected through CURATION_LLM_CMD (default "claude -p") so it
# is mockable offline; the command receives the prompt on stdin and must print one
# JSON object: {neutrality:"pass"|"flag", fit:0-5, rationale, borderline:bool,
# tokensUsed:int}.
#
# Usage:
#   curation-discover.sh [--dry-run] [--emit-issue] [--digest-dir DIR] [--budget N]
#                        [--sources FILE] [--registry FILE] [--presets-dir DIR]
#                        [--awaiting FILE] [--declined FILE] [--max-candidates N]
#                        [--fit-threshold N]
#                        [--model NAME] [--escalate-model NAME] [--thresholds FILE]
#
# With --digest-dir, rejections are also recorded in DIR/judged.json (judgements
# only, never an outage): a rejected repo is skipped until CURATION_REJUDGE_DAYS
# (180) pass. CURATION_DIGEST_REJECTIONS (50) bounds the rejections the markdown
# lists; proposals.json keeps them all.
#
# --emit-issue opens ONE propose-only GitHub issue with the proposals (mirrors the
# nightly watch; no-noise — only when there is something to review). Reuses
# emit_issue (CWD-independent -R, fail-safe). Proposal only — never auto-adds.
#
# Graduation veille: a cleared proposal whose repo matches an entry in the
# awaiting-vendors list (--awaiting) is tagged graduationFor:"dev-X" — a high-
# confidence "ready for graduation review" signal (specs/curation-graduation-veille).
#
# Exit: 0 = run completed (incl. budget-exhausted / no candidates); 2 = setup error.
# =============================================================================

set -u

_DISCO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/curation-common.sh
source "$_DISCO_DIR/lib/curation-common.sh"
# shellcheck source=scripts/lib/trust-score.sh
source "$_DISCO_DIR/lib/trust-score.sh"
# shellcheck source=scripts/lib/curation-safety.sh
source "$_DISCO_DIR/lib/curation-safety.sh"
# shellcheck source=scripts/lib/curation-emit.sh
source "$_DISCO_DIR/lib/curation-emit.sh"

REGISTRY="${CURATION_REGISTRY:-$_DISCO_DIR/../.claude/curation/registry.json}"
PRESETS_DIR="${CURATION_PRESETS_DIR:-$_DISCO_DIR/../.claude/presets}"
SOURCES="${CURATION_SOURCES:-$_DISCO_DIR/../.claude/curation/discovery-sources.json}"
AWAITING="${CURATION_AWAITING:-$_DISCO_DIR/../.claude/curation/awaiting-vendors.json}"
DECLINED="${CURATION_DECLINED:-$_DISCO_DIR/../.claude/curation/declined-candidates.json}"
DIGEST_DIR=""
DRY_RUN=false
EMIT_ISSUE=false
BUDGET="${CURATION_BUDGET:-200000}"
MAX_CANDIDATES="${CURATION_MAX_CANDIDATES:-40}"
# Rejections listed in the digest markdown (all of them stay in proposals.json):
# the markdown becomes the issue body, which GitHub caps at 65,536 characters.
DIGEST_REJECTIONS="${CURATION_DIGEST_REJECTIONS:-50}"
# Days a rejection stands before the repo is judged again (judged ledger).
REJUDGE_DAYS="${CURATION_REJUDGE_DAYS:-180}"
FIT_THRESHOLD="${CURATION_FIT_THRESHOLD:-4}"
MODEL="${CURATION_MODEL:-claude-haiku-4-5}"
ESCALATE_MODEL="${CURATION_ESCALATE_MODEL:-claude-sonnet-4-6}"
LLM_CMD="${CURATION_LLM_CMD:-claude -p}"

while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run) DRY_RUN=true; shift ;;
        --emit-issue) EMIT_ISSUE=true; shift ;;
        --digest-dir) DIGEST_DIR="${2:-}"; [ -n "$DIGEST_DIR" ] || { echo "--digest-dir requires a path" >&2; exit 2; }; shift 2 ;;
        --budget) BUDGET="${2:-}"; [ -n "$BUDGET" ] || { echo "--budget requires a number" >&2; exit 2; }; shift 2 ;;
        --sources) SOURCES="${2:-}"; [ -n "$SOURCES" ] || { echo "--sources requires a path" >&2; exit 2; }; shift 2 ;;
        --awaiting) AWAITING="${2:-}"; [ -n "$AWAITING" ] || { echo "--awaiting requires a path" >&2; exit 2; }; shift 2 ;;
        --declined) DECLINED="${2:-}"; [ -n "$DECLINED" ] || { echo "--declined requires a path" >&2; exit 2; }; shift 2 ;;
        --registry) REGISTRY="${2:-}"; [ -n "$REGISTRY" ] || { echo "--registry requires a path" >&2; exit 2; }; shift 2 ;;
        --presets-dir) PRESETS_DIR="${2:-}"; [ -n "$PRESETS_DIR" ] || { echo "--presets-dir requires a path" >&2; exit 2; }; shift 2 ;;
        --max-candidates) MAX_CANDIDATES="${2:-}"; [ -n "$MAX_CANDIDATES" ] || { echo "--max-candidates requires a number" >&2; exit 2; }; shift 2 ;;
        --fit-threshold) FIT_THRESHOLD="${2:-}"; [ -n "$FIT_THRESHOLD" ] || { echo "--fit-threshold requires a number" >&2; exit 2; }; shift 2 ;;
        --model) MODEL="${2:-}"; [ -n "$MODEL" ] || { echo "--model requires a name" >&2; exit 2; }; shift 2 ;;
        --escalate-model) ESCALATE_MODEL="${2:-}"; [ -n "$ESCALATE_MODEL" ] || { echo "--escalate-model requires a name" >&2; exit 2; }; shift 2 ;;
        --thresholds) CURATION_THRESHOLDS="${2:-}"; [ -n "$CURATION_THRESHOLDS" ] || { echo "--thresholds requires a path" >&2; exit 2; }; export CURATION_THRESHOLDS; shift 2 ;;
        -h|--help) sed -nE 's/^# ?//p' "$0" | sed -nE '/^curation-discover/,/^Exit/p'; exit 0 ;;
        *) echo "Unknown option: $1" >&2; exit 2 ;;
    esac
done

command -v jq >/dev/null 2>&1 || { echo "[ERROR] jq is required" >&2; exit 2; }
[ -f "$SOURCES" ] || { echo "[ERROR] sources not found: $SOURCES" >&2; exit 2; }
case "$REJUDGE_DAYS" in ''|*[!0-9]*) echo "[ERROR] CURATION_REJUDGE_DAYS must be a whole number of days" >&2; exit 2 ;; esac
case "$DIGEST_REJECTIONS" in ''|*[!0-9]*) echo "[ERROR] CURATION_DIGEST_REJECTIONS must be a whole number" >&2; exit 2 ;; esac
# Base 10 explicitly: "0180" must not reach jq's --argjson as a leading-zero number.
REJUDGE_DAYS=$((10#$REJUDGE_DAYS)); DIGEST_REJECTIONS=$((10#$DIGEST_REJECTIONS))

# The judged ledger lives beside the digest: rejections with their gate and
# reason, so a rejected repo is not judged again until REJUDGE_DAYS pass. No
# digest dir ⟹ no ledger (every run judges from scratch, as before).
LEDGER=""
[ -n "$DIGEST_DIR" ] && LEDGER="$DIGEST_DIR/judged.json"

read -ra _LLM <<< "$LLM_CMD"

# _repo_root <owner/repo[/...]> — first two path segments.
_repo_root() {
    local s="${1#https://github.com/}"; s="${s#http://github.com/}"; s="${s%%[?#]*}"
    local owner="${s%%/*}" rest="${s#*/}" repo
    repo="${rest%%/*}"
    [ -n "$owner" ] && [ -n "$repo" ] && [ "$owner" != "$rest" ] && printf '%s/%s\n' "$owner" "$repo"
}

# _graduation_for <repo> — graduation veille (specs/curation-graduation-veille).
# Echo the first foundationSkill in AWAITING whose matchKeywords appear (substring,
# case-insensitive) in the repo path, else empty. LLM-free + deterministic; missing
# AWAITING file ⟹ empty (fail-safe). Never lowers a gate — only annotates a proposal
# that already cleared trust+safety+judge.
_graduation_for() {
    [ -f "$AWAITING" ] || return 0
    local repo_lc; repo_lc=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
    local fskill kws kw
    while IFS=$'\t' read -r fskill kws; do
        [ -n "$fskill" ] || continue
        for kw in $kws; do
            [ -n "$kw" ] || continue
            case "$repo_lc" in *"$kw"*) printf '%s' "$fskill"; return 0 ;; esac
        done
    done < <(jq -r '.entries[]? | "\(.foundationSkill)\t\(.matchKeywords | join(" "))"' "$AWAITING" 2>/dev/null)
}

# known_set — repo-roots already tracked (registry records + preset recs); these
# are never re-proposed.
known_set() {
    {
        [ -f "$REGISTRY" ] && jq -r '.records[]?.vendorId' "$REGISTRY" 2>/dev/null
        local f
        for f in "$PRESETS_DIR"/*.json; do
            [ -f "$f" ] || continue
            jq -r '.recommendedVendorSkills[]? | (.url // .id)' "$f" 2>/dev/null
        done
    } | while IFS= read -r v; do [ -n "$v" ] && _repo_root "$v"; done | sort -u
}

# declined_set — repo-roots a human REVIEWED and chose NOT to adopt (DECLINED
# ledger): e.g. a moat-encroachment whose idea was absorbed into the foundation,
# or an off-stack skill. Excluded from candidates exactly like known_set so a
# standing decision is never re-surfaced (as a proposal OR a moat signal) every
# run. Missing/empty file ⟹ nothing excluded (fail-safe, like _graduation_for).
declined_set() {
    [ -f "$DECLINED" ] || return 0
    jq -r '.entries[]?.repo // empty' "$DECLINED" 2>/dev/null \
        | while IFS= read -r v; do [ -n "$v" ] && _repo_root "$v"; done | sort -u
}

# _LIST_RESERVED — github.com path roots that are NOT user/org repos (so a link
# to one must never become a candidate). Pipe-joined for a single egrep.
_LIST_RESERVED='user-attachments|topics|sponsors|features|about|marketplace|apps|settings|orgs|users|collections|login|join|pricing|search|explore|notifications|readme|new|site|security|enterprise|contact|customer-stories|blog'

# _list_candidates <list-repo> [<path>] — fetch a curated awesome-LIST's doc
# (default branch README.md, or <path>) and echo the owner/repo of every
# github.com repo it links to. Reserved github paths and a self-link are
# filtered; the extracted repos are deduped/gated downstream exactly like search
# hits — a list SEEDS candidates, it never bypasses a gate.
#
# Return code distinguishes a genuine FETCH FAILURE from a legitimately empty
# list, so a source that goes dark is SURFACED in the digest instead of silently
# yielding nothing:
#   0 — fetched OK (candidates on stdout; an empty list is still success)
#   3 — fetch failure / unreadable (404, decode error)
#   4 — over the contents-API 1MB cap (content:"" encoding:"none"): the list is
#       there but unreadable via this endpoint — a distinct, actionable reason.
_list_candidates() {
    local repo="$1" path="${2:-README.md}" body decoded enc size
    body=$(curation_gh_api "repos/$repo/contents/$path" 2>/dev/null) || return 3
    enc=$(printf '%s' "$body" | jq -r '.encoding // empty' 2>/dev/null)
    size=$(printf '%s' "$body" | jq -r '(.size | numbers) // 0' 2>/dev/null)
    if [ "$enc" = "none" ] && [ "${size:-0}" -gt 0 ] 2>/dev/null; then
        return 4
    fi
    decoded=$(printf '%s' "$body" | jq -r '.content // empty' 2>/dev/null | _curation_b64decode) || return 3
    # A genuinely empty (size 0) file is a valid empty list, not a failure.
    [ -n "$decoded" ] || return 0
    printf '%s' "$decoded" \
        | grep -oiE 'https?://github\.com/[A-Za-z0-9._-]+/[A-Za-z0-9._-]+' \
        | while IFS= read -r url; do _repo_root "$url"; done \
        | grep -viE "^($_LIST_RESERVED)/" \
        | grep -vixF "$repo"
}

# _source_hits <source-json> <per-page> — one source's hits (owner/repo), in the
# source's own ranking: a search by stars, a list in document order. A fetch
# failure is appended to $SOURCE_FAIL_LOG and yields nothing.
_source_hits() {
    local src="$1" per="$2" kind repo lpath rc query path items
    kind=$(printf '%s' "$src" | jq -r '.kind // "search"')
    if [ "$kind" = "list" ]; then
        repo=$(printf '%s' "$src" | jq -r '.repo // empty')
        [ -n "$repo" ] || return 0
        lpath=$(printf '%s' "$src" | jq -r '.path // "README.md"')
        _list_candidates "$repo" "$lpath"; rc=$?
        # rc 3 = unreachable/404, rc 4 = over the 1MB contents-API cap
        # (empty content). No stderr warn — the digest field below is the
        # surfacing channel, and a stderr line would corrupt the JSON on
        # stdout under `run`'s merged capture. Reason string is kept
        # human-actionable and greppable by the digest tests.
        if [ "$rc" = 4 ]; then
            [ -n "${SOURCE_FAIL_LOG:-}" ] && printf 'list %s/%s (empty content — over the 1MB API cap)\n' "$repo" "$lpath" >> "$SOURCE_FAIL_LOG"
        elif [ "$rc" != 0 ]; then
            [ -n "${SOURCE_FAIL_LOG:-}" ] && printf 'list %s/%s (unreachable)\n' "$repo" "$lpath" >> "$SOURCE_FAIL_LOG"
        fi
    else
        query=$(printf '%s' "$src" | jq -r '.query // empty')
        [ -n "$query" ] || return 0
        path="search/repositories?q=${query// /+}&per_page=${per}&sort=stars"
        if items=$(curation_gh_api "$path" 2>/dev/null); then
            printf '%s' "$items" | jq -r '.items[]?.full_name // empty' 2>/dev/null
        else
            [ -n "${SOURCE_FAIL_LOG:-}" ] && printf 'search %s (unreachable)\n' "$(printf '%s' "$src" | jq -r '.domain // .query // "?"')" >> "$SOURCE_FAIL_LOG"
        fi
    fi
}

# collect_candidates — run every source (search query OR curated list), flatten to
# owner/repo, dedupe, drop known repos, cap. The cap takes the sources' hits IN
# TURN, each in its own ranking (a search by stars, a list in document order):
# every source's best hits first, then every source's second, and so on. It
# used to sort the whole pool alphabetically and cut at the cap, so each month
# judged the same 0-9/a/b prefix of ~300 candidates and never reached the rest.
# A repo rejected within the re-judge window (judged_recent_set) is dropped too,
# so the cap moves on to candidates not yet examined. A per-source FETCH FAILURE is still
# non-fatal (the other sources run), but the source's identifier is appended to
# $SOURCE_FAIL_LOG (a file the caller reads) so the run SURFACES it in the digest
# rather than presenting a shrunken candidate set as if it were complete.
collect_candidates() {
    # Exclude both already-tracked repos AND reviewed-and-declined ones.
    local known; known=$(printf '%s\n%s\n%s\n' "$(known_set)" "$(declined_set)" "$(judged_recent_set)" | awk 'NF' | sort -u)
    local per src src_n=0
    per=$(jq -r '(.perPage | numbers) // 15' "$SOURCES")
    {
        while IFS= read -r src; do
            [ -n "$src" ] || continue
            src_n=$((src_n + 1))
            _source_hits "$src" "$per" | awk -v s="$src_n" 'NF { print NR "\t" s "\t" $0 }'
        done < <(jq -c '.sources[]?' "$SOURCES")
    } | LC_ALL=C sort -t "$(printf '\t')" -k1,1n -k2,2n \
      | awk -F '\t' 'NR == FNR { skip[tolower($0)] = 1; next }
            { k = tolower($3) } !(k in skip) && !seen[k]++ { print $3 }' \
            <(printf '#known\n%s\n' "$known") - \
      | head -n "$MAX_CANDIDATES"
}

# _LEDGER_DEFS — jq helpers shared by the ledger read and write. fresh/2 is true
# for a well-formed entry judged within the window; an entry whose date (or
# shape) cannot be read is never fresh, so it is skipped on read and dropped on
# write instead of failing the whole ledger.
_LEDGER_DEFS='def epoch: try (strptime("%Y-%m-%d") | mktime) catch null;
  def fresh($now; $days): type == "object" and (.repo | type) == "string"
    and ((.judgedAt | epoch) as $j | ($now | epoch) as $n
         | $j != null and $n != null and ($n - $j) < ($days * 86400));'

# judged_recent_set — repos REJECTED within the re-judge window, from the judged
# ledger ($DIGEST_DIR/judged.json). Skipping them is what lets the cap reach new
# candidates month after month; past the window a repo is judged again (it may
# have grown). No digest dir, missing or corrupted ledger ⟹ nothing skipped.
judged_recent_set() {
    [ -n "$LEDGER" ] && [ -f "$LEDGER" ] || return 0
    jq -r --arg now "$NOW" --argjson days "$REJUDGE_DAYS" "$_LEDGER_DEFS"'
        .entries[]? | select(fresh($now; $days)) | .repo | ascii_downcase' "$LEDGER" 2>/dev/null || true
}

# resolve_ref <repo> — a pinnable current ref: the most recently published
# stable release (not the "Latest" badge — curation_stable_release), else HEAD.
resolve_ref() {
    local repo="$1" tag sha
    tag=$(curation_stable_release "$repo")
    if [ -n "$tag" ]; then printf '%s\n' "$tag"; return; fi
    sha=$(curation_gh_api "repos/$repo/commits/HEAD" 2>/dev/null | jq -r '.sha // empty')
    [ -n "$sha" ] && printf '%s\n' "$sha"
}

# shipped_skills <repo> <ref> — the SKILL.md paths the repo holds at <ref>, one
# per skill: identical copies (one blob sha, e.g. .claude/skills/x beside
# skills/x) are kept once, at the shortest path; paths under a hidden directory
# come last (often the repo's own tooling). Exit 1 when the tree cannot be read,
# or is truncated with no SKILL.md in view: an outage, never "no skill".
shipped_skills() {
    local body paths
    body=$(curation_gh_api "repos/$1/git/trees/$2?recursive=1" 2>/dev/null) || return 1
    printf '%s' "$body" | jq -e '.tree | type == "array"' >/dev/null 2>&1 || return 1
    paths=$(printf '%s' "$body" | jq -r '
        [.tree[] | select(.type == "blob") | select(.path | test("(^|/)SKILL\\.md$"))]
        | group_by(.sha // .path) | map(min_by(.path | length))
        | sort_by([(.path | test("(^|/)\\.")), .path]) | .[].path')
    if [ -z "$paths" ] && printf '%s' "$body" | jq -e '.truncated == true' >/dev/null 2>&1; then
        return 1
    fi
    printf '%s\n' "$paths" | awk 'NF'
}

# The skills actually read (dossier AND safety scan): the first SKILL_DOSSIER_MAX
# of shipped_skills. The rest are listed by path only, so a repo of 200 skills
# costs a bounded number of API calls.
SKILL_DOSSIER_MAX="${CURATION_SKILL_DOSSIER_MAX:-12}"
SKILL_DOSSIER_CAP="${CURATION_SKILL_DOSSIER_CAP:-6000}"

# _frontmatter_field <field> — read <field> from the YAML frontmatter on stdin:
# CRLF tolerated, a folded/literal block (`>-`, `|`) joined into one line.
_frontmatter_field() {
    tr -d '\r' | awk -v k="$1" '
        /^---$/ { fm++; if (fm > 1) exit; next }
        fm != 1 { next }
        blk && /^[ \t]+/ { sub(/^[ \t]+/, ""); out = out (out == "" ? "" : " ") $0; next }
        blk { exit }
        index($0, k ":") == 1 {
            v = substr($0, length(k) + 2); sub(/^[ \t]+/, "", v)
            if (v ~ /^[>|][-+]?$/) { blk = 1; next }
            out = v; exit
        }
        END { print out }'
}

# skill_dossier <repo> <ref> <paths> — what the judge reads: the list of shipped
# skills (path, name, description), then their bodies until the size cap. Never
# the README: the repo's README describes its product, and the skill is what a
# user installs. Only the first SKILL_DOSSIER_MAX are read — the same set the
# safety screen scans.
skill_dossier() {
    local repo="$1" ref="$2" paths="$3" p doc name desc list="" bodies="" n=0 read=0 share i unlisted=0
    local -a docs=() read_paths=()
    while IFS= read -r p; do
        [ -n "$p" ] || continue
        n=$((n + 1))
        if [ "$n" -gt "$SKILL_DOSSIER_MAX" ]; then
            if [ "$n" -le $((SKILL_DOSSIER_MAX + 20)) ]; then
                list+="- $p (not read)"$'\n'
            else
                unlisted=$((unlisted + 1))
            fi
            continue
        fi
        doc=$(_curation_fetch_one "$repo" "$ref" "$p" 2>/dev/null) || doc=""
        name=$(printf '%s\n' "$doc" | _frontmatter_field name)
        desc=$(printf '%s\n' "$doc" | _frontmatter_field description | cut -c1-200)
        list+="- $p — name: ${name:-?} — description: ${desc:-?}"$'\n'
        [ -n "$doc" ] && { docs+=("$doc"); read_paths+=("$p"); read=$((read + 1)); }
    done <<< "$paths"
    [ "$unlisted" -gt 0 ] && list+="- … and $unlisted more, not listed"$'\n'
    # Every skill read gets an equal share of what is left after the list: the
    # first ones by path are not the important ones (skills-contrib/ sorts
    # before skills/), so none may crowd the others out.
    if [ "$read" -gt 0 ]; then
        share=$(( (SKILL_DOSSIER_CAP - ${#list} - 64) / read ))
        [ "$share" -lt 300 ] && share=300
        for ((i = 0; i < read; i++)); do
            bodies+="=== ${read_paths[$i]} ==="$'\n'"$(printf '%s' "${docs[$i]}" | head -c "$share")"$'\n'
        done
    fi
    printf 'Skills shipped (%s):\n%s\n%s' "$n" "$list" "$bodies" | head -c "$SKILL_DOSSIER_CAP"
}

# skill_subpaths <paths> — the '+'-joined directories of the skills the dossier
# reads, for the safety screen (a root SKILL.md is the root screen's job).
skill_subpaths() {
    printf '%s\n' "$1" | awk 'NF' | head -n "$SKILL_DOSSIER_MAX" \
        | awk '{ d = $0; sub(/\/?SKILL\.md$/, "", d); if (d != "") print d }' | paste -sd+ -
}

# llm_judge <repo> <ref> <content> <model> — one model call; echoes the verdict
# JSON (or a fail-safe rejecting verdict if the call/parse fails).
llm_judge() {
    local repo="$1" ref="$2" content="$3" model="$4" prompt out
    prompt=$(cat <<PROMPT
You are curating community Claude Code skills for a workflow foundation.
Judge the skill below and reply with ONLY a JSON object:
{"neutrality":"pass"|"flag","fit":0-5,"rationale":"<short>","borderline":true|false,"encroachesMoat":true|false,"tokensUsed":<int>}

- advice-neutrality: "flag" if it pushes the user toward proprietary lock-in or away
  from their chosen stack / Claude; "pass" otherwise. Publisher identity is NOT a
  criterion — judge the advice, not who wrote it.
- fit: 0-5, how well its skills serve ONE domain the foundation points at
  (web/app/api/db/infra/testing/self-hosted homelab and home automation). One domain
  covered in depth is enough for 4-5: NEVER lower fit because a skill does not
  cover other domains. Lower it when the skills are shallow, a list of links, meant
  for the repo's own contributors rather than its users, or apply only to a
  pre-release or narrow version of their tool — and say which.
- borderline: true if you are unsure and a stronger model should re-judge.
- encroachesMoat: true if the skill covers a DURABLE WORKFLOW-ORCHESTRATION pattern the
  foundation itself owns — TDD enforcement, the audit/review loop, the
  Explore→Specify→Plan→Commit workflow, anti-drift/verification discipline (NOT mere
  tool-specific API depth). This is a STRATEGIC signal, not a recommendation.

Judge the SKILLS the repo ships (listed below, what a user installs), not the
project the repository is about.

Repo: $repo @ $ref
--- SHIPPED SKILLS (truncated) ---
$content
PROMPT
)
    out=$(printf '%s' "$prompt" | "${_LLM[@]}" --model "$model" 2>/dev/null)
    local raw="$out"
    # Models routinely wrap the JSON in ```json fences (or add stray blank lines)
    # despite the "raw JSON only" instruction. Strip fence lines defensively so a
    # well-formed-but-fenced verdict is NOT discarded as unparseable.
    out=$(printf '%s' "$out" | sed -e '/^[[:space:]]*```/d')
    # Prose around the object ("Here is my verdict: {...} Hope this helps", on
    # one line or several) would discard a well-formed verdict: keep the span
    # from the first "{" to the last "}". The answer must then be EXACTLY ONE
    # object: two objects parse as a jq stream, the last one passed the check,
    # and two tokensUsed broke the budget arithmetic, ending the run in silence.
    if ! printf '%s' "$out" | jq -s -e 'length == 1 and (.[0] | type == "object")' >/dev/null 2>&1; then
        out=$(printf '%s' "$out" | tr '\n' '\036' | sed -E 's/^[^{]*//; s/[^}]*$//' | tr '\036' '\n')
    fi
    # The contract, not merely "parses": a fit sent as a string would floor to 0
    # and read as a verdict (recorded, hidden 180 days). Outside it = unanswered.
    if printf '%s' "$out" | jq -s -e 'length == 1 and (.[0] | (.neutrality == "pass" or .neutrality == "flag") and (.fit | type == "number"))' >/dev/null 2>&1; then
        printf '%s' "$out" | jq -c '.'
    else
        curation_warn "llm judge failed/unparseable for $repo: $(printf '%s' "$raw" | tr '\r\n\t' '   ' | tr -d '\000-\037\177' | cut -c1-160)"
        # `unavailable` is what stops the caller reporting this as a VERDICT. The
        # rejecting shape is kept so any reader of the object still fails safe.
        jq -cn '{neutrality:"flag", fit:0, rationale:"llm-unavailable", borderline:false, tokensUsed:0, unavailable:true}'
    fi
}

# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------
NOW=$(curation_now)
case "$NOW" in
    [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]) ;;
    *) echo "[ERROR] run date must be YYYY-MM-DD (CURATION_NOW): $NOW" >&2; exit 2 ;;
esac
# Failed-source log: collect_candidates appends one line per unreachable source
# (fail-safe — the run continues), read back afterwards so the digest reports
# how much of the intended coverage was actually fetched.
SOURCE_FAIL_LOG=$(mktemp 2>/dev/null || printf '')
candidates=$(collect_candidates)
n_candidates=$(printf '%s\n' "$candidates" | awk 'NF' | wc -l | tr -d ' ')
sources_failed=0; sources_failed_list='[]'
if [ -n "$SOURCE_FAIL_LOG" ] && [ -s "$SOURCE_FAIL_LOG" ]; then
    sources_failed=$(awk 'NF' "$SOURCE_FAIL_LOG" | sort -u | wc -l | tr -d ' ')
    sources_failed_list=$(awk 'NF' "$SOURCE_FAIL_LOG" | sort -u | jq -R . | jq -cs .)
fi
[ -n "$SOURCE_FAIL_LOG" ] && rm -f "$SOURCE_FAIL_LOG"

spent=0
proposed=0 rejected=0 deferred=0 moat=0 graduation=0 unjudged=0
proposals_arr=()
rejections_arr=()
unjudged_arr=()

# _reject <repo> <gate> <reason> <recorded:true|false> — count a rejection and
# keep WHY: the digest names it. Only a JUDGEMENT is recorded in the ledger (and
# skips the repo until REJUDGE_DAYS pass). An outage — a fetch that failed, a
# scan that could not run — says nothing about the repo: it is named but not
# recorded, so the next run examines the repo again (as an unanswered judge
# call is UNJUDGED, not rejected).
_reject() {
    rejected=$((rejected + 1))
    rejections_arr+=("$(jq -cn --arg repo "$1" --arg gate "$2" --arg reason "$3" --argjson rec "$4" \
        '{repo:$repo, gate:$gate, reason:$reason, recorded:$rec}')")
}

# Safety reasons that mean the screen could not run, not that it found something.
# exec-surface-truncated / -over-cap are NOT in it on purpose: the repo is too
# large to scan whole, a property of the repo that a re-run would meet again, so
# it is recorded like a finding.
_SAFETY_OUTAGE='unfetchable|unreadable|unresolved|scan-error|scan-blind|failed'

moat_arr=()

if [ "$n_candidates" -gt 0 ]; then
  while IFS= read -r repo; do
    [ -n "$repo" ] || continue

    # Gate 1 — trust (LLM-free). Discovery is the community track (third-party).
    score=$(trust_score "$repo" community 2>/dev/null) || true
    tverdict=$(printf '%s' "$score" | jq -r '.verdict // "error"' 2>/dev/null || echo error)
    if [ "$tverdict" != "pass" ]; then
        treasons=$(printf '%s' "$score" | jq -r '(.reasons // []) | join(", ")' 2>/dev/null || true)
        # fail / flag with reasons = a verdict on the repo; error or no score = an outage.
        case "$tverdict" in
            fail|flag)
                if [ -n "$treasons" ]; then _reject "$repo" trust "$treasons" true
                else _reject "$repo" trust "no trust score (operational)" false; fi ;;
            *) _reject "$repo" trust "${treasons:-no trust score} (operational)" false ;;
        esac
        continue
    fi

    ref=$(resolve_ref "$repo")
    [ -n "$ref" ] || { _reject "$repo" ref "could not resolve a release tag or HEAD (operational)" false; continue; }

    # Gate 2 — the repo must ship a skill (LLM-free). A link list or a product
    # repo has no SKILL.md: nothing to install, so nothing to judge.
    if ! skills=$(shipped_skills "$repo" "$ref"); then
        _reject "$repo" no-skill "repository tree unreadable or truncated (operational)" false
        continue
    fi
    if [ -z "$skills" ]; then
        _reject "$repo" no-skill "ships no SKILL.md" true
        continue
    fi

    # Gate 3 — safety (LLM-free): the root screen, then the skill directories the
    # judge will read. The root screen scans the root SKILL.md / README; without
    # the second pass a skill under skills/<x>/ reached the judge unscanned.
    subs=$(skill_subpaths "$skills")
    screen_failed=0
    for scope in "" ${subs:+"$subs"}; do
        screen=$(curation_safety_screen "$repo" "$ref" "$scope")
        [ "$(printf '%s' "$screen" | jq -r '.verdict')" = "pass" ] && continue
        sreasons=$(printf '%s' "$screen" | jq -r '(.reasons // []) | join(", ")' 2>/dev/null || true)
        if [ -z "$sreasons" ] || printf '%s' "$sreasons" | grep -qE "$_SAFETY_OUTAGE"; then
            _reject "$repo" safety "${sreasons:-no screen verdict} (operational)" false
        else
            _reject "$repo" safety "$sreasons" true
        fi
        screen_failed=1
        break
    done
    [ "$screen_failed" -eq 0 ] || continue

    # Budget gate — BEFORE any model call. Exhausted → defer this and the rest.
    if [ "$spent" -ge "$BUDGET" ]; then
        deferred=$((deferred + 1)); continue
    fi

    # Gate 4 — judge (LLM). Haiku triage; escalate a borderline verdict once.
    content=$(skill_dossier "$repo" "$ref" "$skills")
    verdict=$(llm_judge "$repo" "$ref" "$content" "$MODEL")
    spent=$((spent + $(printf '%s' "$verdict" | jq -r '(.tokensUsed | numbers | floor) // 1000')))

    if [ "$(printf '%s' "$verdict" | jq -r '.borderline // false')" = "true" ] && [ "$spent" -lt "$BUDGET" ]; then
        verdict=$(llm_judge "$repo" "$ref" "$content" "$ESCALATE_MODEL")
        spent=$((spent + $(printf '%s' "$verdict" | jq -r '(.tokensUsed | numbers | floor) // 1000')))
    fi

    # No verdict came back. That is an outage, not a judgement: counting it as a
    # rejection makes a broken model look like a month of unfit candidates, and
    # the count is the only thing the digest carries. Reported separately, and
    # NOT as `deferred` — that word already means the budget stopped the run.
    if [ "$(printf '%s' "$verdict" | jq -r '.unavailable // false')" = "true" ]; then
        unjudged=$((unjudged + 1))
        unjudged_arr+=("$repo")
        continue
    fi

    neutrality=$(printf '%s' "$verdict" | jq -r '.neutrality')
    fit=$(printf '%s' "$verdict" | jq -r '(.fit | numbers | floor) // 0')
    encroaches=$(printf '%s' "$verdict" | jq -r '.encroachesMoat // false')
    if [ "$encroaches" = "true" ]; then
        # US-8: a credible skill covering a durable workflow pattern is a STRATEGIC
        # signal for the maintainer — never a graduation candidate. It bypasses the
        # proposal path entirely (regardless of fit/neutrality).
        moat=$((moat + 1))
        moat_arr+=("$(jq -cn \
            --arg repo "$repo" --arg prov "${repo%%/*}" --arg ref "$ref" \
            --argjson trust "$score" --argjson judge "$verdict" \
            '{repo:$repo, provenance:$prov, pinnedRef:$ref, trustVerdict:$trust.verdict,
              fit:$judge.fit, rationale:$judge.rationale}')")
    elif [ "$neutrality" = "pass" ] && [ "$fit" -ge "$FIT_THRESHOLD" ]; then
        proposed=$((proposed + 1))
        # Graduation veille: tag if this cleared candidate fills an awaiting slot.
        grad_for=$(_graduation_for "$repo")
        [ -n "$grad_for" ] && graduation=$((graduation + 1))
        proposals_arr+=("$(jq -cn \
            --arg repo "$repo" --arg prov "${repo%%/*}" --arg ref "$ref" \
            --arg gradFor "$grad_for" \
            --argjson trust "$score" --argjson safety "$screen" --argjson judge "$verdict" \
            '{repo:$repo, provenance:$prov, pinnedRef:$ref, trustTrack:"community",
              trustVerdict:$trust.verdict, safetyVerdict:$safety.verdict,
              adviceNeutrality:$judge.neutrality, fit:$judge.fit,
              rationale:$judge.rationale,
              graduationFor:(if $gradFor == "" then null else $gradFor end)}')")
    else
        _reject "$repo" "$([ "$neutrality" = "pass" ] && echo fit || echo neutrality)" \
            "$(printf '%s' "$verdict" | jq -r '.rationale // ""')" true
    fi
  done < <(printf '%s\n' "$candidates" | awk 'NF')
fi

if [ "${#proposals_arr[@]}" -gt 0 ]; then
    proposals=$(printf '%s\n' "${proposals_arr[@]}" | jq -s '.')
else
    proposals='[]'
fi
if [ "${#rejections_arr[@]}" -gt 0 ]; then
    rejections=$(printf '%s\n' "${rejections_arr[@]}" | jq -s '.')
else
    rejections='[]'
fi
if [ "${#moat_arr[@]}" -gt 0 ]; then
    moat_signals=$(printf '%s\n' "${moat_arr[@]}" | jq -s '.')
else
    moat_signals='[]'
fi

# pending_proposals — proposals from EARLIER runs still in the ledger window and
# not yet decided (not in the registry/presets, not declined). They are not
# judged again (judged_recent_set skips them), so the digest keeps naming them
# instead of letting them vanish or re-proposing them every month.
pending_proposals() {
    [ -n "$LEDGER" ] && [ -f "$LEDGER" ] || { echo '[]'; return 0; }
    local decided
    decided=$(printf '%s\n%s\n' "$(known_set)" "$(declined_set)" | awk 'NF' | jq -R 'ascii_downcase' | jq -s '.')
    jq -c --arg now "$NOW" --argjson days "$REJUDGE_DAYS" --argjson decided "$decided" "$_LEDGER_DEFS"'
        [.entries[]? | select(type == "object" and .gate == "proposed" and fresh($now; $days))
         | select(.judgedAt < $now)
         | select((.repo | ascii_downcase) as $r | $decided | index($r) | not)
         | {repo, proposedAt:.judgedAt, pinnedRef, fit, reason}]' "$LEDGER" 2>/dev/null || echo '[]'
}
pending=$(pending_proposals)
printf '%s' "$pending" | jq -e 'type == "array"' >/dev/null 2>&1 || pending='[]'

exhausted=$([ "$deferred" -gt 0 ] && echo true || echo false)
if [ "${#unjudged_arr[@]}" -gt 0 ]; then
    unjudged_repos=$(printf '%s\n' "${unjudged_arr[@]}" | jq -R . | jq -s '.')
else
    unjudged_repos='[]'
fi
digest=$(jq -cn \
    --arg now "$NOW" --argjson cand "$n_candidates" \
    --argjson srcFailed "$sources_failed" --argjson srcFailures "$sources_failed_list" \
    --argjson proposed "$proposed" --argjson rejected "$rejected" --argjson deferred "$deferred" \
    --argjson unjudged "$unjudged" --argjson unjudgedRepos "$unjudged_repos" \
    --argjson moat "$moat" --argjson graduation "$graduation" \
    --argjson limit "$BUDGET" --argjson spent "$spent" --argjson exhausted "$exhausted" \
    --argjson proposals "$proposals" --argjson moatSignals "$moat_signals" \
    --argjson rejections "$rejections" --argjson pending "$pending" \
    '{generatedAt:$now, scope:{candidates:$cand},
      sourcesFailed:$srcFailed, sourceFailures:$srcFailures,
      counts:{proposed:$proposed, rejected:$rejected, deferred:$deferred, unjudged:$unjudged, moat:$moat, graduation:$graduation},
      unjudgedRepos:$unjudgedRepos,
      budget:{limit:$limit, spent:$spent, exhausted:$exhausted},
      proposals:$proposals, pendingProposals:$pending, moatSignals:$moatSignals, rejections:$rejections}')

# _MD_DEFS — jq helpers for the digest tables. Reasons and rationales are written
# by a model reading third-party SKILL.md content and end up in a GitHub issue
# body: esc keeps them inert text (no HTML, no markdown link or autolinked URL,
# no @mention, no line break that ends the table row; a backslash is doubled
# first so it cannot undo the escapes after it) and bounds their length.
_MD_DEFS='def esc: tostring | gsub("[\r\n]+"; " ") | gsub("\\\\"; "\\\\") | gsub("://"; ":/\u200b/") | gsub("&"; "&amp;") | gsub("<"; "&lt;") | gsub(">"; "&gt;")
    | gsub("\\|"; "\\|") | gsub("\\["; "\\[") | gsub("\\]"; "\\]") | gsub("`"; "\\`") | gsub("@"; "@\u200b")
    | if length > 300 then .[0:300] + "…" else . end;
  def link: "[\(.)](https://github.com/\(.))";'

render_markdown() {
    printf '# Curation discovery — %s\n\n' "$NOW"
    printf -- '- Candidates: **%s** · proposed **%s** · rejected **%s** · deferred **%s**\n' \
        "$n_candidates" "$proposed" "$rejected" "$deferred"
    if [ "$unjudged" -gt 0 ]; then
        printf -- '- ⚠️ **never judged** (the model call failed — these are NOT rejections): %s — %s\n' \
            "$unjudged" "$(printf '%s' "$unjudged_repos" | jq -r 'join("; ")')"
    fi
    if [ "$sources_failed" -gt 0 ]; then
        printf -- '- ⚠️ Discovery **sources failed** to fetch (%s — coverage incomplete): %s\n' \
            "$sources_failed" "$(printf '%s' "$sources_failed_list" | jq -r 'join("; ")')"
    fi
    printf -- '- Budget: %s / %s tokens%s\n\n' "$spent" "$BUDGET" \
        "$([ "$exhausted" = true ] && echo ' — **exhausted (rest deferred)**' || echo '')"
    if [ "$proposed" -gt 0 ]; then
        printf '## Proposed candidates\n\n'
        printf '| Repo | Provenance | Pin | Fit | Rationale |\n|---|---|---|---|---|\n'
        printf '%s' "$proposals" | jq -r "$_MD_DEFS"'
            .[] | "| \(.repo|link) | \(.provenance|esc) | \(.pinnedRef|esc) | \(.fit|esc) | \(.rationale|esc) |"'
        printf '\n'
    fi
    if [ "$(printf '%s' "$pending" | jq 'length')" -gt 0 ]; then
        printf '## ⏳ Pending proposals (earlier runs, not yet added or declined)\n\n'
        printf 'Not judged again while pending. Add to the registry, or record a decline, to clear one.\n\n'
        printf '| Repo | Proposed | Pin | Fit | Rationale |\n|---|---|---|---|---|\n'
        printf '%s' "$pending" | jq -r "$_MD_DEFS"'
            .[] | "| \(.repo|link) | \(.proposedAt|esc) | \(.pinnedRef|esc) | \(.fit|esc) | \(.reason|esc) |"'
        printf '\n'
    fi
    if [ "$graduation" -gt 0 ]; then
        printf '## 🎓 Graduation candidates (fill a foundation awaiting-vendor slot)\n\n'
        printf 'Cleared trust+safety+judge AND match a graduatable watch-list skill. Review for command-side graduation (specs/dev-command-vendor-graduation).\n\n'
        printf '| Repo | Graduates | Pin | Fit | Rationale |\n|---|---|---|---|---|\n'
        printf '%s' "$proposals" | jq -r "$_MD_DEFS"'
            .[] | select(.graduationFor != null) |
            "| \(.repo|link) | \(.graduationFor|esc) | \(.pinnedRef|esc) | \(.fit|esc) | \(.rationale|esc) |"'
        printf '\n'
    fi
    if [ "$moat" -gt 0 ]; then
        printf '## ⚠️ Moat-encroachment signals (strategic — NOT graduation candidates)\n\n'
        printf 'High-trust skills covering durable workflow patterns the foundation owns. Review strategically; do not auto-adopt.\n\n'
        printf '| Repo | Provenance | Fit | Why it encroaches |\n|---|---|---|---|\n'
        printf '%s' "$moat_signals" | jq -r "$_MD_DEFS"'
            .[] | "| \(.repo|link) | \(.provenance|esc) | \(.fit|esc) | \(.rationale|esc) |"'
        printf '\n'
    fi
    if [ "$proposed" -eq 0 ] && [ "$moat" -eq 0 ]; then
        printf 'No new candidates proposed.\n'
    fi
    if [ "$rejected" -gt 0 ]; then
        printf '\n<details><summary>Rejected (%s): the gate that stopped each one</summary>\n\n' "$rejected"
        printf '| Repo | Gate | Reason |\n|---|---|---|\n'
        printf '%s' "$rejections" | jq -r --argjson max "$DIGEST_REJECTIONS" "$_MD_DEFS"'
            (.[:$max][] | "| \(.repo|link) | \(.gate|esc) | \(.reason|esc) |"),
            (if length > $max then "\n… and \(length - $max) more: see `rejections` in proposals.json" else empty end)'
        printf '\n</details>\n'
    fi
}

if [ -n "$DIGEST_DIR" ] && [ "$DRY_RUN" = false ]; then
    mkdir -p "$DIGEST_DIR"
    printf '%s\n' "$digest" > "$DIGEST_DIR/proposals.json"
    render_markdown > "$DIGEST_DIR/proposals.md"
    # Judged ledger: this run's rejections AND proposals replace any older entry for the same
    # repo; entries past the re-judge window are dropped (they are eligible
    # again anyway). A corrupted ledger is started afresh, never fatal.
    _prev='{"entries":[]}'
    if [ -f "$LEDGER" ] && jq -e '.entries | arrays' "$LEDGER" >/dev/null 2>&1; then _prev=$(cat "$LEDGER"); fi
    if printf '%s' "$_prev" | jq --arg now "$NOW" --argjson days "$REJUDGE_DAYS" --argjson new "$rejections" --argjson props "$proposals" "$_LEDGER_DEFS"'
        (($new | map(select(.recorded) | {repo, gate, reason, judgedAt:$now}))
         + ($props | map({repo, gate:"proposed", reason:.rationale, judgedAt:$now, pinnedRef, fit}))) as $add
        | ($add | map(.repo | ascii_downcase)) as $renewed
        | {version:"1.0.0",
           entries: ([.entries[] | select(fresh($now; $days))
                      | select((.repo | ascii_downcase) as $r | $renewed | index($r) | not)]
                     + $add)}' > "$LEDGER.tmp" 2>/dev/null; then
        mv "$LEDGER.tmp" "$LEDGER"
    else
        rm -f "$LEDGER.tmp"
        echo "[WARN] could not update the judged ledger $LEDGER: this run's rejections are not recorded" >&2
    fi
    echo "[OK] discovery digest: $DIGEST_DIR/proposals.json (+ .md) — $proposed proposal(s)" >&2
fi

# --emit-issue: surface the proposals as ONE propose-only GitHub issue (mirrors
# the watch). No-noise: only when there is something to review (proposed / moat /
# graduation > 0). Reuses emit_issue (CWD-independent -R, fail-safe). Never auto-adds.
if [ "$EMIT_ISSUE" = true ] && [ "$DRY_RUN" = false ] && [ $((proposed + moat + graduation)) -gt 0 ]; then
    _disco_body=$(mktemp 2>/dev/null)
    if [ -n "$DIGEST_DIR" ] && [ -f "$DIGEST_DIR/proposals.md" ]; then
        cp "$DIGEST_DIR/proposals.md" "$_disco_body"
    else
        render_markdown > "$_disco_body"
    fi
    emit_issue "Curation discovery — $NOW" "$_disco_body" "discovery"
    rm -f "$_disco_body"
fi
printf '%s\n' "$digest"
exit 0
