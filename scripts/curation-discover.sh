#!/usr/bin/env bash
# =============================================================================
# curation-discover.sh — MONTHLY discovery sweep for the marketplace curation
# engine (Slice 5, specs/marketplace-curation-engine). US-5.
#
# Surfaces NEWLY-published community skills in covered domains and runs them
# through three gates before PROPOSING them (proposal only — never auto-added,
# observe-never-install):
#   1. trust   — public popularity/maintenance signals (trust-score.sh)  [LLM-FREE]
#   2. safety  — pin-time integrity content scan (curation-safety.sh)     [LLM-FREE]
#   3. judge   — advice-neutrality + fit, via an LLM (claude -p), Haiku triage with
#                escalation of borderline cases.                          [LLM]
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
_LIST_RESERVED='topics|sponsors|features|about|marketplace|apps|settings|orgs|users|collections|login|join|pricing|search|explore|notifications|readme|new|site|security|enterprise|contact|customer-stories|blog'

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

# collect_candidates — run every source (search query OR curated list), flatten to
# owner/repo, dedupe, drop known repos, cap. A per-source FETCH FAILURE is still
# non-fatal (the other sources run), but the source's identifier is appended to
# $SOURCE_FAIL_LOG (a file the caller reads) so the run SURFACES it in the digest
# rather than presenting a shrunken candidate set as if it were complete.
collect_candidates() {
    # Exclude both already-tracked repos AND reviewed-and-declined ones.
    local known; known=$(printf '%s\n%s\n' "$(known_set)" "$(declined_set)" | awk 'NF' | sort -u)
    local per src kind query repo lpath path items rc
    per=$(jq -r '(.perPage | numbers) // 15' "$SOURCES")
    {
        while IFS= read -r src; do
            [ -n "$src" ] || continue
            kind=$(printf '%s' "$src" | jq -r '.kind // "search"')
            if [ "$kind" = "list" ]; then
                repo=$(printf '%s' "$src" | jq -r '.repo // empty')
                [ -n "$repo" ] || continue
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
                [ -n "$query" ] || continue
                path="search/repositories?q=${query// /+}&per_page=${per}&sort=stars"
                if items=$(curation_gh_api "$path" 2>/dev/null); then
                    printf '%s' "$items" | jq -r '.items[]?.full_name // empty' 2>/dev/null
                else
                    [ -n "${SOURCE_FAIL_LOG:-}" ] && printf 'search %s (unreachable)\n' "$(printf '%s' "$src" | jq -r '.domain // .query // "?"')" >> "$SOURCE_FAIL_LOG"
                fi
            fi
        done < <(jq -c '.sources[]?' "$SOURCES")
    } | awk 'NF' | sort -u | grep -vxF -f <(printf '%s\n' "$known") 2>/dev/null | head -n "$MAX_CANDIDATES"
}

# resolve_ref <repo> — a pinnable current ref: latest release tag, else HEAD sha.
resolve_ref() {
    local repo="$1" tag sha
    tag=$(curation_gh_api "repos/$repo/releases/latest" 2>/dev/null | jq -r '.tag_name // empty')
    if [ -n "$tag" ]; then printf '%s\n' "$tag"; return; fi
    sha=$(curation_gh_api "repos/$repo/commits/HEAD" 2>/dev/null | jq -r '.sha // empty')
    [ -n "$sha" ] && printf '%s\n' "$sha"
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
- fit: 0-5, how well it covers a domain the foundation points at (web/app/api/db/infra/testing/self-hosted homelab and home automation).
- borderline: true if you are unsure and a stronger model should re-judge.
- encroachesMoat: true if the skill covers a DURABLE WORKFLOW-ORCHESTRATION pattern the
  foundation itself owns — TDD enforcement, the audit/review loop, the
  Explore→Specify→Plan→Commit workflow, anti-drift/verification discipline (NOT mere
  tool-specific API depth). This is a STRATEGIC signal, not a recommendation.

Repo: $repo @ $ref
--- SKILL CONTENT (truncated) ---
$content
PROMPT
)
    out=$(printf '%s' "$prompt" | "${_LLM[@]}" --model "$model" 2>/dev/null)
    # Models routinely wrap the JSON in ```json fences (or add stray blank lines)
    # despite the "raw JSON only" instruction. Strip fence lines defensively so a
    # well-formed-but-fenced verdict is NOT discarded as unparseable.
    out=$(printf '%s' "$out" | sed -e '/^[[:space:]]*```/d')
    if printf '%s' "$out" | jq -e '.neutrality and (.fit != null)' >/dev/null 2>&1; then
        printf '%s' "$out"
    else
        curation_warn "llm judge failed/unparseable for $repo"
        # `unavailable` is what stops the caller reporting this as a VERDICT. The
        # rejecting shape is kept so any reader of the object still fails safe.
        jq -cn '{neutrality:"flag", fit:0, rationale:"llm-unavailable", borderline:false, tokensUsed:0, unavailable:true}'
    fi
}

# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------
NOW=$(curation_now)
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
unjudged_arr=()
moat_arr=()

if [ "$n_candidates" -gt 0 ]; then
  while IFS= read -r repo; do
    [ -n "$repo" ] || continue

    # Gate 1 — trust (LLM-free). Discovery is the community track (third-party).
    score=$(trust_score "$repo" community 2>/dev/null) || true
    if [ "$(printf '%s' "$score" | jq -r '.verdict // "error"')" != "pass" ]; then
        rejected=$((rejected + 1)); continue
    fi

    ref=$(resolve_ref "$repo")
    [ -n "$ref" ] || { rejected=$((rejected + 1)); continue; }

    # Gate 2 — safety (LLM-free).
    screen=$(curation_safety_screen "$repo" "$ref")
    if [ "$(printf '%s' "$screen" | jq -r '.verdict')" != "pass" ]; then
        rejected=$((rejected + 1)); continue
    fi

    # Budget gate — BEFORE any model call. Exhausted → defer this and the rest.
    if [ "$spent" -ge "$BUDGET" ]; then
        deferred=$((deferred + 1)); continue
    fi

    # Gate 3 — judge (LLM). Haiku triage; escalate a borderline verdict once.
    content=$(_curation_fetch_content "$repo" "$ref" 2>/dev/null | head -c 4000)
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
        rejected=$((rejected + 1))
    fi
  done < <(printf '%s\n' "$candidates" | awk 'NF')
fi

if [ "${#proposals_arr[@]}" -gt 0 ]; then
    proposals=$(printf '%s\n' "${proposals_arr[@]}" | jq -s '.')
else
    proposals='[]'
fi
if [ "${#moat_arr[@]}" -gt 0 ]; then
    moat_signals=$(printf '%s\n' "${moat_arr[@]}" | jq -s '.')
else
    moat_signals='[]'
fi

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
    '{generatedAt:$now, scope:{candidates:$cand},
      sourcesFailed:$srcFailed, sourceFailures:$srcFailures,
      counts:{proposed:$proposed, rejected:$rejected, deferred:$deferred, unjudged:$unjudged, moat:$moat, graduation:$graduation},
      unjudgedRepos:$unjudgedRepos,
      budget:{limit:$limit, spent:$spent, exhausted:$exhausted},
      proposals:$proposals, moatSignals:$moatSignals}')

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
        printf '%s' "$proposals" | jq -r 'def esc: tostring | gsub("\\|"; "\\|"); def link: "[\(.)](https://github.com/\(.))";
            .[] | "| \(.repo|link) | \(.provenance|esc) | \(.pinnedRef|esc) | \(.fit|esc) | \(.rationale|esc) |"'
        printf '\n'
    fi
    if [ "$graduation" -gt 0 ]; then
        printf '## 🎓 Graduation candidates (fill a foundation awaiting-vendor slot)\n\n'
        printf 'Cleared trust+safety+judge AND match a graduatable watch-list skill. Review for command-side graduation (specs/dev-command-vendor-graduation).\n\n'
        printf '| Repo | Graduates | Pin | Fit | Rationale |\n|---|---|---|---|---|\n'
        printf '%s' "$proposals" | jq -r 'def esc: tostring | gsub("\\|"; "\\|"); def link: "[\(.)](https://github.com/\(.))";
            .[] | select(.graduationFor != null) |
            "| \(.repo|link) | \(.graduationFor|esc) | \(.pinnedRef|esc) | \(.fit|esc) | \(.rationale|esc) |"'
        printf '\n'
    fi
    if [ "$moat" -gt 0 ]; then
        printf '## ⚠️ Moat-encroachment signals (strategic — NOT graduation candidates)\n\n'
        printf 'High-trust skills covering durable workflow patterns the foundation owns. Review strategically; do not auto-adopt.\n\n'
        printf '| Repo | Provenance | Fit | Why it encroaches |\n|---|---|---|---|\n'
        printf '%s' "$moat_signals" | jq -r 'def esc: tostring | gsub("\\|"; "\\|"); def link: "[\(.)](https://github.com/\(.))";
            .[] | "| \(.repo|link) | \(.provenance|esc) | \(.fit|esc) | \(.rationale|esc) |"'
        printf '\n'
    fi
    if [ "$proposed" -eq 0 ] && [ "$moat" -eq 0 ]; then
        printf 'No new candidates proposed.\n'
    fi
}

if [ -n "$DIGEST_DIR" ] && [ "$DRY_RUN" = false ]; then
    mkdir -p "$DIGEST_DIR"
    printf '%s\n' "$digest" > "$DIGEST_DIR/proposals.json"
    render_markdown > "$DIGEST_DIR/proposals.md"
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
