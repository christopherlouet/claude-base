#!/usr/bin/env bash
# =============================================================================
# curation-safety.sh — pin-time integrity screen for the marketplace curation
# engine (Slice 3b, specs/marketplace-curation-engine). EF-006 / US-4.
#
# A DETERMINISTIC, LLM-free scan of a candidate's OWN content for obviously-
# dangerous instructions — kept STRICTLY SEPARATE from the trust criterion
# (popularity ≠ safety). It gates the engine's automated actions: in discover it
# is Gate 2 (a non-pass rejects the candidate); in watch a pass lets a drift
# auto-draft a re-pin, a flag demotes it to propose-only (human re-screens via
# the digest). It never auto-installs and never copies third-party content
# (EF-010) — it only reads.
#
# Scan surface (#3): NOT just the SKILL.md/README.md doc — also the candidate's
# REAL executable surface, where a benign-looking doc could otherwise hide
# hostile code: script files (*.sh/.bash/.zsh/.py/.js/.mjs/.cjs/.rb/.pl/.php),
# anything with the git executable bit (mode 100755, e.g. an extensionless
# `bin/install`), Claude settings hook command blocks (settings*.json), MCP
# server configs (.mcp.json / mcp.json) and the plugin format's own declarations
# (hooks/hooks.json, .claude-plugin/plugin.json, marketplace.json). The same
# high-signal danger patterns apply to every file; a JSON file is also scanned
# one line per declared command, "command" joined with its "args". (Limitations,
# all fail toward human review: a download executed in a separate statement, a
# hook command referencing a script outside the scanned surface, and a plugin
# manifest pointing its hooks at a custom-named file are not caught — see
# _SAFETY_PATTERNS. A flag only ever routes to review.)
#
# Fail-safe (EF-012): anything that cannot be confirmed safe is FLAGGED, never
# silently passed. Reasons: content-unfetchable (no doc), exec-surface-unfetchable
# (tree unlistable), exec-file-unfetchable (a listed exec file unreadable),
# exec-surface-truncated (GitHub itself truncated the tree, so files we never
# saw the names of went unscanned), exec-surface-over-cap (the tree listed more
# exec files than the cap, so the tail went unscanned).
#
# Subpath scoping: when a skill lives in a subpath of a monorepo (registry
# vendorId / preset id like phaserjs/phaser/skills or coreyhaines31/.../cro),
# pass the '+'-joined subpath(s) as the 3rd arg — the doc fetch AND the exec-
# surface scan then cover ONLY those subpaths, never the whole repo. Without
# this, a big unrelated tree elsewhere false-trips exec-surface-over-cap. In
# subpath mode a missing <subpath>/SKILL.md is NOT a flag (the doc is often
# nested); the scoped exec-surface scan is the load-bearing signal.
#
# Fail-safe (EF-012): anything that cannot be confirmed safe is FLAGGED, never
# silently passed. Reasons: content-unfetchable (no doc — root mode only),
# exec-surface-unfetchable (tree unlistable), exec-file-unfetchable (a listed
# exec file unreadable), exec-surface-truncated (GitHub truncated the tree),
# exec-surface-over-cap (more exec files than the cap).
#
# Reviewed exemptions: a maintainer who has read a flagged line and judged it
# harmless (an installer that ECHOES a curl|bash instruction, a comment) records
# it in .claude/curation/safety-exemptions.json. An entry lifts exactly one
# finding: same repo, same path, same category, same line bytes (sha256). Keyed
# by line, not by file blob, because a vendor's installer changes at every
# release while its flagged lines rarely do. Fail-safe reasons are not findings
# and can never be lifted. Known limit: an unchanged line whose CONTEXT changes
# (an echo moved into a heredoc fed to a shell) keeps its exemption.
#
# The verdict never depends on the finding detail: categories are decided by the
# pattern scan alone, and a category is lifted only when its detail exists and is
# entirely exempt. Whatever breaks the detail (a huge line, an odd byte, no temp
# directory) loses the detail, never the flag.
#
# API:  curation_safety_screen <owner/repo> <ref> [<subpaths>]
#   stdout: one JSON object {repo, ref, verdict:"pass"|"flag", reasons[],
#           findings[], findingsTotal, exempted[], exemptedTotal}; a finding is
#           {path, category, lineSha256, line[, lineTruncated]}. reasons is "clean" on a pass
#           with nothing lifted, "exempted" on a pass that holds only because
#           exemptions lifted every finding.
#   exit:   0 always (a verdict is always produced; failures become a flag).
#   env:    CURATION_SAFETY_MAX_FILES — exec-surface file cap (default 250).
#           CURATION_SAFETY_EXEMPTIONS — reviewed-exemptions file (default
#           .claude/curation/safety-exemptions.json; missing = none).
#           CURATION_SAFETY_DETAIL_MAX / CURATION_SAFETY_LINE_MAX — how many
#           findings, and how much of each line, the output shows (25 / 240).
# =============================================================================

_SAFETY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/curation-common.sh
source "$_SAFETY_DIR/curation-common.sh"
CURATION_SAFETY_EXEMPTIONS="${CURATION_SAFETY_EXEMPTIONS:-$_SAFETY_DIR/../../.claude/curation/safety-exemptions.json}"

# _curation_b64decode — thin alias kept for this file's internal callers; the
# portable decoder now lives once in curation-common.sh (curation_b64decode),
# shared with the trust-score README license probe.
_curation_b64decode() { curation_b64decode; }

# _curation_fetch_one <repo> <ref> <path> — echo the decoded text of one file at
# <ref> via the contents API (base64 body, mockable offline); return non-zero if
# the file is absent, unfetchable, or undecodable. A present-but-undecodable /
# empty-after-decode body is treated as NOT fetched — never as clean text — so
# corrupt base64 or a wrong-decoder pick fails SAFE instead of false-passing.
_curation_fetch_one() {
    local repo="$1" ref="$2" file="$3" body content decoded
    body=$(curation_gh_api "repos/$repo/contents/$file?ref=$ref" 2>/dev/null) || return 1
    content=$(printf '%s' "$body" | jq -r '.content // empty' 2>/dev/null)
    [ -n "$content" ] || return 1
    decoded=$(printf '%s' "$content" | _curation_b64decode) || return 1
    [ -n "$decoded" ] || return 1
    printf '%s' "$decoded"
}

# _curation_fetch_content <repo> <ref> [<subpaths>] — echo the decoded text of
# the skill's primary doc(s). With no subpaths: the repo-root SKILL.md (else
# README.md). With subpaths ('+'-joined, the registry's multi-skill notation):
# each subpath's own SKILL.md/README.md, concatenated — a subpath skill's doc
# lives under the subpath, NOT at the repo root. Non-zero if nothing is fetched.
_curation_fetch_content() {
    local repo="$1" ref="$2" subpaths="${3:-}" file
    if [ -z "$subpaths" ]; then
        for file in SKILL.md README.md; do
            _curation_fetch_one "$repo" "$ref" "$file" && return 0
        done
        return 1
    fi
    local sp out="" got=1 d sps=()
    IFS='+' read -ra sps <<< "$subpaths" || true
    for sp in "${sps[@]}"; do
        [ -n "$sp" ] || continue
        for file in SKILL.md README.md; do
            if d=$(_curation_fetch_one "$repo" "$ref" "$sp/$file"); then
                out+="$d"$'\n'; got=0; break
            fi
        done
    done
    [ "$got" -eq 0 ] && printf '%s' "$out"
    return "$got"
}

# The danger patterns — ONE table, read by both the category scan that decides the
# verdict and the per-line extraction that reports findings, so the two always
# test the same expressions. Shared by the doc scan AND the exec-surface scan;
# high-signal, deterministic, case-insensitive, line-based:
#   remote-exec      — a downloaded payload reaching an interpreter (curl|sh,
#                      curl|node, bash <(curl), eval "$(curl …)")
#   obfuscated-exec  — decode (base64/xxd) then execute / eval "$(base64 …)"
#   destructive-rm   — recursive+force delete of a root/home path (either flag order)
#   prompt-injection — overriding the operator's / system instructions
# The exec sink is NOT just POSIX shells: a hostile script in the exec surface
# commonly pipes a payload into node/deno/bun/python/perl/ruby/php/env, so those
# are recognized too.
#
# KNOWN line-based blind spot (#3 follow-up): a download SAVED to a file and then
# executed in a SEPARATE statement (`curl -o p …` then `sh p`) is not correlated
# across lines, nor is a hook command that references a script file outside the
# scanned surface. These need filename correlation; until then they evade the
# grep. The screen fails toward human review (a clean verdict only enables an
# auto-DRAFT, still human-merged), so this is a coverage gap, never a silent risk.
_INTERP='sh|bash|zsh|node|deno|bun|python[0-9.]*|perl|ruby|php|env'
_SAFETY_CATEGORIES=(
    remote-exec
    remote-exec
    remote-exec
    obfuscated-exec
    obfuscated-exec
    destructive-rm
    prompt-injection
)
_SAFETY_PATTERNS=(
    "(curl|wget).*\|[[:space:]]*(sudo[[:space:]]+)?($_INTERP)\b"
    "($_INTERP)[[:space:]]+(-[a-z]+[[:space:]]+)*(-c[[:space:]]+)?[\"']?[[:space:]]*[\$<]\(?(curl|wget)"
    'eval[^=]*\$\([^)]*(curl|wget)'
    "(base64|xxd)[^|]*(--decode|-d|-D|-r)?[^|]*\|.*\b(sudo[[:space:]]+)?($_INTERP|eval)\b"
    'eval[^=]*\$\([^)]*(base64|xxd)'
    'rm[[:space:]]+(-[a-z]*(rf|fr)[a-z]*|-[rf][[:space:]]+-[rf]|--recursive[[:space:]]+--force|--force[[:space:]]+--recursive)[[:space:]]+(/|~|\$\{?HOME)'
    'ignore[[:space:]]+(all|the|any|your)?[[:space:]]*(previous|prior|above)[[:space:]]+(system[[:space:]]+)?instructions?|ignore[[:space:]]+(the|your)?[[:space:]]*system[[:space:]]+prompt|disregard[[:space:]]+(the|your)?[[:space:]]*(system[[:space:]]+)?(prompt|instructions?)'
)

# _curation_sha256 <text> — hex sha256 of <text> exactly (no trailing newline).
# Linux ships sha256sum, macOS shasum. Echoes nothing when neither exists: an
# empty key never matches an exemption, so the finding keeps its flag.
_curation_sha256() {
    if command -v sha256sum >/dev/null 2>&1; then
        printf '%s' "$1" | sha256sum | cut -d' ' -f1
    elif command -v shasum >/dev/null 2>&1; then
        printf '%s' "$1" | shasum -a 256 | cut -d' ' -f1
    fi
}

# _curation_scan_findings <path> — read <path>'s text on stdin, echo one compact
# JSON finding per (pattern, matching line): {path, category, lineSha256, line}.
# The sha256 covers the line verbatim (leading whitespace included) — it is the
# key a reviewed exemption matches. Lines never travel as a command-line
# argument (a minified line can exceed the 128 KiB per-argument limit): they go
# to jq on stdin. `grep -a` because a single invalid byte otherwise makes GNU
# grep call the text binary and print nothing. May repeat a (category, line)
# pair when two patterns of one category hit the same line; the caller dedups.
# This is DETAIL only: the verdict never depends on it (see _curation_screen_scan).
_curation_scan_findings() {
    local path="$1" text i line
    text=$(cat)
    for ((i = 0; i < ${#_SAFETY_PATTERNS[@]}; i++)); do
        { LC_ALL=C grep -aEi -e "${_SAFETY_PATTERNS[$i]}" <<<"$text" || true; } \
            | while IFS= read -r line; do
                printf '%s\t%s\n' "$(_curation_sha256 "$line")" "$line"
            done \
            | jq -Rc --arg p "$path" --arg c "${_SAFETY_CATEGORIES[$i]}" \
                'index("\t") as $t | {path:$p, category:$c, lineSha256:.[0:$t], line:.[$t + 1:]}'
    done
}

# _curation_load_exemptions <owner/repo> — echo the JSON array of reviewed
# exemptions recorded for <owner/repo> in CURATION_SAFETY_EXEMPTIONS. A missing
# file is simply no exemption. A file jq cannot read is ALSO no exemption — the
# flags stand — but it is reported, since it means a review is being ignored.
_curation_load_exemptions() {
    local repo="$1" f="${CURATION_SAFETY_EXEMPTIONS:-}" out
    if [ -z "$f" ] || [ ! -f "$f" ]; then
        printf '[]'
        return 0
    fi
    if ! out=$(jq -c --arg r "$repo" '[.exemptions[]? | select(.repo == $r)]' "$f" 2>/dev/null); then
        curation_warn "safety exemptions file is malformed ($f); no finding is lifted"
        printf '[]'
        return 0
    fi
    printf '%s' "$out"
}

# _curation_screen_scan <path> — scan <path>'s text (stdin) for the running
# screen. Reads the caller's `scratch` directory (ex.json = this repo's
# exemptions; findings.jsonl / exempted.jsonl accumulate the detail) and appends
# to the caller's `reasons`.
#
# Two layers, and only the first decides: (1) which categories the text matches,
# by `grep -aq` exactly as before exemptions existed; (2) the per-line findings,
# partitioned against the exemptions. A matched category is dropped from
# `reasons` ONLY when layer 2 produced at least one finding for it and every one
# of them is exempt. If layer 2 fails in any way — a jq error, a missing scratch
# directory, a line it could not key — the category simply stays flagged.
# A finding is lifted only by an exemption matching path, category and the
# line's sha256 (repo is filtered on load); an empty key never matches.
_curation_screen_scan() {
    local path="$1" text i c part hit=()
    text=$(cat)
    # LC_ALL=C: byte semantics. In a UTF-8 locale `.` cannot cross an invalid
    # byte, so one stray byte inside `curl … | bash` hid the line from every
    # pattern (measured on the pre-exemptions screen too). The patterns are
    # ASCII, so -i loses nothing.
    for ((i = 0; i < ${#_SAFETY_PATTERNS[@]}; i++)); do
        LC_ALL=C grep -aEiq -e "${_SAFETY_PATTERNS[$i]}" <<<"$text" && hit+=("${_SAFETY_CATEGORIES[$i]}")
    done
    [ "${#hit[@]}" -gt 0 ] || return 0

    part=""
    if [ -n "$scratch" ] && [ -f "$scratch/ex.json" ]; then
        part=$(_curation_scan_findings "$path" <<<"$text" | jq -cs --slurpfile ex "$scratch/ex.json" '
            ($ex[0] // []) as $ex
            | unique_by([.category, .lineSha256])
            | map(. as $x | . + {exempt: ($x.lineSha256 != "" and any($ex[];
                  .path == $x.path and .category == $x.category and .lineSha256 == $x.lineSha256))})
            | . as $all
            | {kept: map(select(.exempt | not) | del(.exempt)),
               exempted: map(select(.exempt) | del(.exempt)),
               lifted: [$all | map(.category) | unique | .[] as $c
                        | select([$all[] | select(.category == $c) | .exempt] | all) | $c]}' 2>/dev/null) \
            || part=""
    fi

    for c in "${hit[@]}"; do
        if [ -n "$part" ] && printf '%s' "$part" | jq -e --arg c "$c" 'any(.lifted[]; . == $c)' >/dev/null 2>&1; then
            continue
        fi
        reasons+=("$c")
    done
    if [ -n "$part" ]; then
        printf '%s' "$part" | jq -c '.kept[]' >> "$scratch/findings.jsonl" 2>/dev/null || true
        printf '%s' "$part" | jq -c '.exempted[]' >> "$scratch/exempted.jsonl" 2>/dev/null || true
    fi
    return 0
}

# _curation_json_commands — read a JSON config on stdin, echo each command it
# declares as the ONE line it becomes when run: "command" joined with its "args".
# Hook and MCP entries split the sink — interpreter in "command", payload in
# "args" — and pretty-printing puts them on different lines, where the line-based
# scan never sees them together. Line breaks inside a piece are flattened too:
# jq -r decodes an escaped "\n", which would cut the joined line apart again.
# Emits nothing for JSON jq rejects: the caller still scans the raw text, so a
# malformed file is never treated as clean.
_curation_json_commands() {
    jq -r '.. | objects | select(has("command"))
        | [.command] + (if (.args | type) == "array" then .args else [] end)
        | map(tostring | gsub("[\r\n]+"; " ")) | join(" ")' 2>/dev/null || true
}

# _curation_list_exec_surface <repo> <ref> — echo the candidate's executable-
# surface paths (one per line) from the recursive git tree at <ref>: scripts,
# exec-bit files, Claude settings hook blocks (settings*.json), MCP server
# configs (.mcp.json / mcp.json) and plugin declarations (hooks.json,
# plugin.json, marketplace.json) — the files that can actually run code in a
# user's session, which the SKILL.md/README.md doc cannot reveal. Capped at
# CURATION_SAFETY_MAX_FILES (default 250) to bound API calls on large repos.
#
# The cap is a COST bound, not a safety judgement, so it must clear the real
# surfaces we watch: the biggest carry 36-158 exec files, and the old cap of 25
# flagged all four at every pin — demoting their nightly re-pin to propose-only
# for good (the freshness cliff). Whatever the cap, exceeding it stays a flag:
# the tail really did go unscanned.
# Exit: 0 = listed OK (paths on stdout, possibly none);
#       1 = the tree could not be listed/parsed (caller fails safe);
#       3 = GitHub truncated the tree itself — the path LIST is incomplete;
#       4 = fully listed but over the cap (caller flags + scans the kept slice).
# 3 and 4 are distinct unknowns: 3 hides files we never even named, 4 hides
# files we named and chose not to fetch. Both flag; only 3 is unbounded.
_curation_list_exec_surface() {
    local repo="$1" ref="$2" subpaths="${3:-}" body
    local cap="${CURATION_SAFETY_MAX_FILES:-250}"
    body=$(curation_gh_api "repos/$repo/git/trees/$ref?recursive=1" 2>/dev/null) || return 1
    # A response without a .tree array (e.g. an error object) is unusable.
    printf '%s' "$body" | jq -e '.tree | type == "array"' >/dev/null 2>&1 || return 1
    local truncated all count
    truncated=$(printf '%s' "$body" | jq -r '.truncated // false')
    all=$(printf '%s' "$body" | jq -r '
        .tree[] | select(.type == "blob")
        | select(
            (.path | test("\\.(sh|bash|zsh|py|js|mjs|cjs|rb|pl|php)$"))
            or (.mode == "100755")
            or (.path | split("/")[-1] | (test("^settings.*\\.json$") or test("^\\.?mcp\\.json$")
                or test("^(hooks|plugin|marketplace)\\.json$")))
          )
        | .path')
    # Subpath scoping (#384 fix): when the skill lives in subpath(s), keep ONLY
    # files under them — BEFORE the cap — so an unrelated big monorepo elsewhere
    # never false-trips exec-surface-over-cap. Literal prefix match (no regex).
    if [ -n "$subpaths" ]; then
        local sp sps=() scoped=""
        IFS='+' read -ra sps <<< "$subpaths" || true
        for sp in "${sps[@]}"; do
            [ -n "$sp" ] || continue
            scoped+=$(printf '%s\n' "$all" | awk -v p="$sp/" 'index($0,p)==1')$'\n'
        done
        all=$(printf '%s' "$scoped" | grep . | sort -u || true)
    fi
    count=$(printf '%s' "$all" | grep -c . || true)
    if [ "$truncated" = "true" ] || [ "$count" -gt "$cap" ]; then
        printf '%s\n' "$all" | grep . | head -n "$cap" || true
        [ "$truncated" = "true" ] && return 3
        return 4
    fi
    printf '%s' "$all" | grep . || true
    return 0
}

# _curation_subpaths_resolve <repo> <ref> <subpaths> — for a subpath-scoped
# skill, verify each '+'-split subpath actually matches at least one path in the
# repo tree at <ref>. A subpath that matches NOTHING (e.g. a registry vendorId
# that dropped the `skills/` prefix) would make the doc + exec-surface scans
# cover an EMPTY set, so the screen would vacuously report "clean" — the skill is
# never inspected. Return: 0 = every subpath resolves; 2 = at least one resolves
# to nothing; 1 = tree unfetchable (the exec-surface scan already fails safe, so
# the caller does not double-flag). A valid collection root (e.g. phaser's
# `skills`) matches many child paths and resolves cleanly.
_curation_subpaths_resolve() {
    local repo="$1" ref="$2" subpaths="$3" body paths sp sps=() missing=0
    body=$(curation_gh_api "repos/$repo/git/trees/$ref?recursive=1" 2>/dev/null) || return 1
    printf '%s' "$body" | jq -e '.tree | type == "array"' >/dev/null 2>&1 || return 1
    paths=$(printf '%s' "$body" | jq -r '.tree[]? | .path')
    IFS='+' read -ra sps <<< "$subpaths" || true
    for sp in "${sps[@]}"; do
        [ -n "$sp" ] || continue
        printf '%s\n' "$paths" | awk -v p="$sp/" 'index($0,p)==1{found=1} END{exit !found}' \
            || missing=1
    done
    [ "$missing" -eq 1 ] && return 2
    return 0
}

# curation_safety_screen <owner/repo> <ref> [<subpaths>]
# <subpaths>: optional '+'-joined subpath(s) the skill occupies in the repo
# (e.g. "skills" or "cro+analytics"). When given, the doc fetch AND the exec-
# surface scan are scoped to those subpaths — never the whole monorepo.
curation_safety_screen() {
    local repo="$1" ref="$2" subpaths="${3:-}"
    local reasons=() text r doc
    # Per-run scratch for the finding detail (files, never argv: a large repo's
    # detail outgrows a command-line argument). Without it the screen still
    # decides — only the detail and the exemptions are lost, so flags stand.
    local scratch
    if scratch=$(mktemp -d 2>/dev/null); then
        _curation_load_exemptions "$repo" > "$scratch/ex.json"
    else
        curation_warn "safety screen has no scratch directory; findings detail and exemptions unavailable"
        scratch=""
    fi

    # 1. Scan the primary doc(s), each under its own path so a finding names the
    # file it came from. Root mode: a repo-root SKILL.md/README.md MUST be
    # fetchable — fail safe otherwise (unchanged EF-012). Subpath mode: the doc
    # often lives nested under the subpath (e.g. skills/<name>/SKILL.md), so a
    # missing <subpath>/SKILL.md is NOT a failure — the scoped exec-surface scan
    # below is the load-bearing signal; the doc is scanned best-effort if present.
    if [ -z "$subpaths" ]; then
        local got=1
        for doc in SKILL.md README.md; do
            if text=$(_curation_fetch_one "$repo" "$ref" "$doc"); then
                _curation_screen_scan "$doc" <<<"$text"
                got=0
                break
            fi
        done
        if [ "$got" -ne 0 ]; then
            _curation_safety_emit "$repo" "$ref" "flag" "" "content-unfetchable"
            [ -n "$scratch" ] && rm -rf "$scratch"
            return 0
        fi
    else
        local sp sps=()
        IFS='+' read -ra sps <<< "$subpaths" || true
        for sp in "${sps[@]}"; do
            [ -n "$sp" ] || continue
            for doc in "$sp/SKILL.md" "$sp/README.md"; do
                if text=$(_curation_fetch_one "$repo" "$ref" "$doc"); then
                    _curation_screen_scan "$doc" <<<"$text"
                    break
                fi
            done
        done
    fi

    # 1b. Subpath-resolution guard: a stale/wrong subpath that matches NO path in
    # the tree would make both scans cover an EMPTY set and the screen vacuously
    # report "clean" — i.e. the skill is never actually inspected. Flag it so a
    # bad pin surfaces instead of silently passing. A tree-unfetchable result is
    # already covered by exec-surface-unfetchable below (no double-flag).
    if [ -n "$subpaths" ]; then
        local rrc
        _curation_subpaths_resolve "$repo" "$ref" "$subpaths"; rrc=$?
        [ "$rrc" -eq 2 ] && reasons+=("subpath-unresolved")
    fi

    # 2. Scan the REAL executable surface (scripts, settings/plugin hooks, MCP).
    # A benign doc must not let a hostile hook/script/MCP command through.
    local surface rc
    surface=$(_curation_list_exec_surface "$repo" "$ref" "$subpaths"); rc=$?
    if [ "$rc" -eq 1 ]; then
        # Can't confirm the surface is safe → fail safe (never silently pass).
        reasons+=("exec-surface-unfetchable")
    else
        [ "$rc" -eq 3 ] && reasons+=("exec-surface-truncated")
        [ "$rc" -eq 4 ] && reasons+=("exec-surface-over-cap")
        local path ftext
        while IFS= read -r path; do
            [ -n "$path" ] || continue
            if ftext=$(_curation_fetch_one "$repo" "$ref" "$path"); then
                case "$path" in
                    *.json) ftext+=$'\n'$(printf '%s' "$ftext" | _curation_json_commands) ;;
                esac
                _curation_screen_scan "$path" <<<"$ftext"
            else
                # A listed exec file we cannot read → fail safe.
                reasons+=("exec-file-unfetchable")
            fi
        done <<< "$surface"
    fi

    # 3. Dedup reason categories (order-preserving) and decide the verdict.
    local verdict="pass" seen=" " out=()
    for r in ${reasons[@]+"${reasons[@]}"}; do
        [ -n "$r" ] || continue
        [[ "$seen" == *" $r "* ]] && continue
        seen+="$r "; out+=("$r")
    done
    if [ "${#out[@]}" -gt 0 ]; then
        verdict="flag"
    elif [ -n "$scratch" ] && [ -s "$scratch/exempted.jsonl" ]; then
        # Passing only because reviewed exemptions lifted every finding: say so,
        # a reader must never mistake this for content that matched nothing.
        out+=("exempted")
    else
        out+=("clean")
    fi
    _curation_safety_emit "$repo" "$ref" "$verdict" "$scratch" "${out[@]}"
    [ -n "$scratch" ] && rm -rf "$scratch"
    return 0
}

# Detail caps: the verdict JSON rides downstream as a command-line argument, so
# its detail is bounded — the first CURATION_SAFETY_DETAIL_MAX findings, each
# line shown to CURATION_SAFETY_LINE_MAX characters. The *Total counts and every
# lineSha256 (computed on the whole line) are never truncated. A cut line carries
# lineTruncated:true — an exemption for it needs the whole line, read from the file.
CURATION_SAFETY_DETAIL_MAX="${CURATION_SAFETY_DETAIL_MAX:-25}"
CURATION_SAFETY_LINE_MAX="${CURATION_SAFETY_LINE_MAX:-240}"

# _curation_safety_emit <repo> <ref> <verdict> <scratch-dir|""> <reason...>
_curation_safety_emit() {
    local repo="$1" ref="$2" verdict="$3" scratch="$4"; shift 4
    local fl=/dev/null el=/dev/null
    if [ -n "$scratch" ]; then
        [ -f "$scratch/findings.jsonl" ] && fl="$scratch/findings.jsonl"
        [ -f "$scratch/exempted.jsonl" ] && el="$scratch/exempted.jsonl"
    fi
    jq -cn --arg repo "$repo" --arg ref "$ref" --arg verdict "$verdict" \
        --slurpfile f "$fl" --slurpfile e "$el" \
        --argjson n "$CURATION_SAFETY_DETAIL_MAX" --argjson w "$CURATION_SAFETY_LINE_MAX" \
        'def shown: .[0:$n] | map(if (.line | length) > $w
                                  then .line |= .[0:$w] | .lineTruncated = true else . end);
         {repo:$repo, ref:$ref, verdict:$verdict, reasons:$ARGS.positional,
          findings:($f | shown), findingsTotal:($f | length),
          exempted:($e | shown), exemptedTotal:($e | length)}' \
        --args "$@" 2>/dev/null \
    || jq -cn --arg repo "$repo" --arg ref "$ref" \
        '{repo:$repo, ref:$ref, verdict:"flag", reasons:["screen-emit-failed"],
          findings:[], findingsTotal:0, exempted:[], exemptedTotal:0}'
}

# CLI: curation-safety.sh <owner/repo> <ref> [<subpaths>]
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    set -u
    { [ $# -eq 2 ] || [ $# -eq 3 ]; } || { echo "Usage: $(basename "$0") <owner/repo> <ref> [<subpaths>]" >&2; exit 2; }
    curation_safety_screen "$1" "$2" "${3:-}"
    exit $?
fi
