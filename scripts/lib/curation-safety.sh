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
# exec files than the cap, so the tail went unscanned), scan-error (a pattern
# grep failed), screen-emit-failed (the verdict itself could not be rendered).
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
# exec-surface-over-cap (more exec files than the cap), scan-error (a pattern
# grep failed, so the text could not be confirmed clean).
#
# The verdict never depends on the finding detail: categories are decided by
# the pattern scan alone; the per-line detail is extracted afterwards for the
# reader. Whatever breaks the detail (a huge line, an odd byte, no temp
# directory) loses the detail and sets detailComplete false — never the flag.
#
# API:  curation_safety_screen <owner/repo> <ref> [<subpaths>]
#   stdout: one JSON object {repo, ref, verdict:"pass"|"flag", reasons[],
#           findings[], findingsTotal, detailComplete}; a finding is
#           {path, category, lineNumber, line[, lineTruncated]}, in file order,
#           one per occurrence; a command rebuilt from a JSON config has
#           lineNumber null, joinedCommand true and joinedIndex (its rank among
#           the rebuilt commands). detailComplete is false when
#           any matched file's detail could not be fully recorded. reasons is
#           "clean" on a pass.
#   exit:   0 always (a verdict is always produced; failures become a flag).
#   env:    CURATION_SAFETY_MAX_FILES — exec-surface file cap (default 250).
#           CURATION_SAFETY_DETAIL_MAX / CURATION_SAFETY_LINE_MAX — how many
#           findings, and how much of each line, the output shows (25 / 240).
# =============================================================================

_SAFETY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/curation-common.sh
source "$_SAFETY_DIR/curation-common.sh"

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

# _curation_category_of <pattern-index> — the pattern's category. A pattern
# added without one is still a danger, never an empty string a dedup would drop.
_curation_category_of() { printf '%s' "${_SAFETY_CATEGORIES[$1]:-uncategorized-pattern}"; }

# A UTF-8 locale for the second matching arm, resolved once. Pinned rather than
# inherited: under cron, `env -i` or a minimal container the caller's locale is C,
# and the Unicode-space arm would silently become a second C scan. Any installed
# UTF-8 locale serves (C.UTF-8 or en_US preferred): a host may only have fr_FR.
# Empty when the system has none — the second arm then runs in the caller's
# locale, and the screen says so once (_SAFETY_LOCALE_WARNED).
_SAFETY_UTF8_LOCALES=$(locale -a 2>/dev/null | grep -iE '\.utf-?8$')
_SAFETY_UTF8_LOCALE=$(printf '%s\n' "$_SAFETY_UTF8_LOCALES" | grep -iE '^c\.' | head -n 1)
[ -n "$_SAFETY_UTF8_LOCALE" ] || _SAFETY_UTF8_LOCALE=$(printf '%s\n' "$_SAFETY_UTF8_LOCALES" | grep -iE '^en_us\.' | head -n 1)
[ -n "$_SAFETY_UTF8_LOCALE" ] || _SAFETY_UTF8_LOCALE=$(printf '%s\n' "$_SAFETY_UTF8_LOCALES" | grep . | head -n 1)
_SAFETY_LOCALE_WARNED=0

# _curation_grep_utf8 <grep-args...> — grep in _SAFETY_UTF8_LOCALE (or the
# caller's locale when none exists).
_curation_grep_utf8() {
    if [ -n "$_SAFETY_UTF8_LOCALE" ]; then
        LC_ALL="$_SAFETY_UTF8_LOCALE" grep "$@"
    else
        grep "$@"
    fi
}

# _curation_match <pattern> <text> — does <text> match <pattern>? 0 = match,
# 1 = no match, 2 = no match but a grep ERRORED (callers treat that as unknown,
# never as clean). The pattern runs twice, and one match in either is a match:
#   LC_ALL=C      byte semantics — in a UTF-8 locale `.` cannot cross an invalid
#                 byte, so one stray byte inside `curl … | bash` hid the line
#                 from every pattern;
#   a UTF-8 locale [[:space:]] also matches Unicode spaces there, which the C
#                 locale does not — `ignore<U+2003>all previous instructions`
#                 must still read as an injection.
# Neither locale alone covers both evasions. `-a`: never treat text as binary.
_curation_match() {
    local rc_c rc_u
    LC_ALL=C grep -aEiq -e "$1" <<<"$2"
    rc_c=$?
    [ "$rc_c" -eq 0 ] && return 0
    _curation_grep_utf8 -aEiq -e "$1" <<<"$2"
    rc_u=$?
    [ "$rc_u" -eq 0 ] && return 0
    { [ "$rc_c" -gt 1 ] || [ "$rc_u" -gt 1 ]; } && return 2
    return 1
}

# _curation_cap <variable-name> <default> — echo the variable's value when it is a
# non-negative integer; otherwise warn and echo <default>. A bogus cap used to
# break the rendering and a negative one silently hid the last finding.
_curation_cap() {
    local name="$1" default="$2" value
    value="${!name:-$default}"
    case "$value" in
        '' | *[!0-9]*)
            curation_warn "$name='$value' is not a non-negative integer; using $default"
            value="$default"
            ;;
    esac
    printf '%s' "$value"
}

# _curation_scan_findings <path> <joined:0|1> <pattern-index...> — read <path>'s
# text on stdin, echo one compact JSON finding per (pattern, matching line):
# {path, category, lineNumber, line}, or for a command reconstructed from a JSON
# config (joined=1) {…, lineNumber:null, joinedCommand:true, joinedIndex} — such a
# line exists nowhere in the file, so it has no line number. Lines never travel as
# a command-line argument (a minified line can exceed the 128 KiB per-argument
# limit): they go to jq on stdin, and are cut to the display cap right here, so a
# 1 MB minified line never rides through every later jq pass (lineTruncated marks
# the cut). Both locales are searched (see _curation_match) and may return a line
# twice; the rendering dedups. `pattern` is the pattern index, for completeness.
# DETAIL only: nothing the verdict decides reads it (see _curation_screen_scan).
_curation_scan_findings() {
    local path="$1" joined="$2" text i w
    shift 2
    w="${cap_w:-$(_curation_cap CURATION_SAFETY_LINE_MAX 240)}"
    text=$(cat)
    for i in "$@"; do
        { LC_ALL=C grep -anEi -e "${_SAFETY_PATTERNS[$i]}" <<<"$text"
          _curation_grep_utf8 -anEi -e "${_SAFETY_PATTERNS[$i]}" <<<"$text"; } 2>/dev/null \
            | jq -Rc --arg p "$path" --arg c "$(_curation_category_of "$i")" \
                --argjson j "$joined" --argjson i "$i" --argjson w "$w" '
                index(":") as $a | (.[0:$a] | tonumber) as $n | .[$a + 1:] as $l
                | {path:$p, category:$c, pattern:$i, line:$l[0:$w]}
                | if ($l | length) > $w then . + {lineTruncated:true} else . end
                | if $j == 1 then . + {lineNumber:null, joinedCommand:true, joinedIndex:$n}
                  else . + {lineNumber:$n} end'
    done
}

# _curation_screen_scan <path> [joined] — scan <path>'s text (stdin) for the
# running screen; `joined` marks the commands reconstructed from a JSON config.
# Appends every matched category to the caller's `reasons`, sets the caller's
# `detail_lost` when the finding detail could not be fully recorded, and writes
# the detail to the caller's `scratch` directory (findings.jsonl).
#
# Deciding and reporting are separate. DECIDE: which categories the text matches
# (_curation_match; a grep error is `scan-error`, never silence). REPORT: the
# per-line findings — display only, best effort, and checked: every matched
# PATTERN must come back with at least one line (one line per category was not
# enough: a failed extraction for one pattern hid behind another of the same
# category).
_curation_screen_scan() {
    local path="$1" joined=0 text i c rc seen=" " cats=() idx=() part
    [ "${2:-}" = "joined" ] && joined=1
    text=$(cat)
    for ((i = 0; i < ${#_SAFETY_PATTERNS[@]}; i++)); do
        _curation_match "${_SAFETY_PATTERNS[$i]}" "$text"
        rc=$?
        if [ "$rc" -eq 2 ]; then
            reasons+=("scan-error")
            continue
        fi
        [ "$rc" -eq 0 ] || continue
        idx+=("$i")
        c=$(_curation_category_of "$i")
        case "$seen" in *" $c "*) ;; *) seen+="$c "; cats+=("$c") ;; esac
    done
    [ "${#idx[@]}" -gt 0 ] || return 0
    reasons+=("${cats[@]}")

    if [ -z "$scratch" ]; then
        detail_lost=1
        return 0
    fi
    part=$(_curation_scan_findings "$path" "$joined" "${idx[@]}" <<<"$text" \
        | jq -cs --arg idx "${idx[*]}" '
        . as $raw
        | ($idx | split(" ") | map(select(length > 0) | tonumber)
           | all(. as $p | any($raw[]; .pattern == $p))) as $complete
        | map(del(.pattern)) | sort_by(.lineNumber // 0, .joinedIndex // 0)
        | {findings: ., complete: $complete}' \
        2>/dev/null) || { detail_lost=1; return 0; }
    [ "$(printf '%s' "$part" | jq -r '.complete' 2>/dev/null)" = "true" ] || detail_lost=1
    printf '%s' "$part" | jq -c '.findings[]' >> "$scratch/findings.jsonl" 2>/dev/null || detail_lost=1
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
    local reasons=() text r doc detail_lost=0
    local cap_n cap_w
    cap_n=$(_curation_cap CURATION_SAFETY_DETAIL_MAX 25)
    cap_w=$(_curation_cap CURATION_SAFETY_LINE_MAX 240)
    if [ -z "$_SAFETY_UTF8_LOCALE" ] && [ "$_SAFETY_LOCALE_WARNED" -eq 0 ]; then
        curation_warn "no UTF-8 locale installed: Unicode-space evasions (e.g. U+2003) are not detected"
        _SAFETY_LOCALE_WARNED=1
    fi
    # Per-run scratch for the finding detail (files, never argv: a large repo's
    # detail outgrows a command-line argument). Without it the screen still
    # decides — only the detail is lost, so flags stand.
    local scratch
    if ! scratch=$(mktemp -d 2>/dev/null); then
        curation_warn "safety screen has no scratch directory; findings detail unavailable"
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
            _curation_safety_emit "$repo" "$ref" "flag" "" 0 "content-unfetchable"
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
            # A doc that is also exec surface (an executable README) is scanned
            # again here; the rendering dedups its findings. Skipping it instead
            # once let a crafted file name go unscanned.
            if ftext=$(_curation_fetch_one "$repo" "$ref" "$path"); then
                _curation_screen_scan "$path" <<<"$ftext"
                # The commands a JSON config declares, rebuilt one per line, are
                # scanned apart: they exist nowhere in the file, so no line number.
                case "$path" in
                    *.json) _curation_screen_scan "$path" joined < <(printf '%s' "$ftext" | _curation_json_commands) ;;
                esac
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
    else
        out+=("clean")
    fi
    _curation_safety_emit "$repo" "$ref" "$verdict" "$scratch" "$detail_lost" "${out[@]}"
    [ -n "$scratch" ] && rm -rf "$scratch"
    return 0
}

# Detail caps: the verdict JSON rides downstream as a command-line argument, so
# its detail is bounded — the first CURATION_SAFETY_DETAIL_MAX findings, each
# line already cut to CURATION_SAFETY_LINE_MAX characters at extraction (both
# validated by _curation_cap); findingsTotal is never truncated, and a cut line
# carries lineTruncated:true. Rendering also dedups what two scans of one text report: a
# doc that is also exec surface, and a one-line JSON command found both in the raw
# file text and as a rebuilt command.
CURATION_SAFETY_DETAIL_MAX="${CURATION_SAFETY_DETAIL_MAX:-25}"
CURATION_SAFETY_LINE_MAX="${CURATION_SAFETY_LINE_MAX:-240}"

# _curation_safety_emit <repo> <ref> <verdict> <scratch-dir|""> <detail-lost:0|1> <reason...>
_curation_safety_emit() {
    local repo="$1" ref="$2" verdict="$3" scratch="$4" lost="$5"; shift 5
    local fl=/dev/null n
    n="${cap_n:-$(_curation_cap CURATION_SAFETY_DETAIL_MAX 25)}"
    [ -n "$scratch" ] && [ -f "$scratch/findings.jsonl" ] && fl="$scratch/findings.jsonl"
    jq -cn --arg repo "$repo" --arg ref "$ref" --arg verdict "$verdict" \
        --slurpfile f "$fl" \
        --argjson n "$n" \
        --argjson lost "$lost" \
        'def dedup: (map(select(.joinedCommand != true))) as $raw
            | map(. as $x | select(($x.joinedCommand != true)
                  or (any($raw[]; .path == $x.path and .category == $x.category
                          and (.line | contains($x.line))) | not)))
            | reduce .[] as $x ({seen: {}, out: []};
                  ([$x.path, $x.category, ($x.lineNumber // "j\($x.joinedIndex)")] | tojson) as $k
                  | if .seen[$k] then . else .seen[$k] = true | .out += [$x] end)
            | .out;
         def shown: .[0:$n];
         ($f | dedup) as $all
         | {repo:$repo, ref:$ref, verdict:$verdict, reasons:$ARGS.positional,
            findings:($all | shown), findingsTotal:($all | length),
            detailComplete:($lost == 0)}' \
        --args "$@" 2>/dev/null && return 0
    # The verdict could not be rendered. Say so, and flag — keeping every reason
    # already found (a hostile repo must not lose its `remote-exec`).
    curation_warn "safety screen could not render its verdict for $repo@$ref; flagging it"
    jq -cn --arg repo "$repo" --arg ref "$ref" \
        '{repo:$repo, ref:$ref, verdict:"flag",
          reasons:([$ARGS.positional[] | select(. != "clean")] + ["screen-emit-failed"]),
          findings:[], findingsTotal:0, detailComplete:false}' \
        --args "$@"
}

# CLI: curation-safety.sh <owner/repo> <ref> [<subpaths>]
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    set -u
    { [ $# -eq 2 ] || [ $# -eq 3 ]; } || { echo "Usage: $(basename "$0") <owner/repo> <ref> [<subpaths>]" >&2; exit 2; }
    curation_safety_screen "$1" "$2" "${3:-}"
    exit $?
fi
