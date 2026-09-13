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
# exec-surface-over-cap (more exec files than the cap), scan-error (a pattern
# grep failed, so the text could not be confirmed clean).
#
# Reviewed exemptions: a maintainer who has read a flagged line and judged it
# harmless (an installer that ECHOES a curl|bash instruction, a comment) records
# it in .claude/curation/safety-exemptions.json. An entry lifts those exact line
# bytes, in that file of that repo, under that category — the recorded line must
# be one line and hash to its recorded sha256, or the entry is ignored. Keyed by
# line, not by file blob, because a vendor's installer changes at every release
# while its flagged lines rarely do. Fail-safe reasons are not findings and can
# never be lifted. Known limit: an identical COPY of a reviewed line is lifted
# with it, even if its context differs (an echo moved into a heredoc fed to a
# shell) — the detail counts and locates every copy so the reader sees it.
#
# The verdict never depends on the finding detail: a category is lifted only
# when the text, with its exempted lines removed, no longer matches any of its
# patterns. Whatever breaks the detail (a huge line, an odd byte, no temp
# directory) loses the detail, never the flag.
#
# API:  curation_safety_screen <owner/repo> <ref> [<subpaths>]
#   stdout: one JSON object {repo, ref, verdict:"pass"|"flag", reasons[],
#           findings[], findingsTotal, exempted[], exemptedTotal, detailComplete};
#           a finding is
#           {path, category, lineNumber, lineSha256, line[, lineTruncated]},
#           in file order, one per occurrence; a command rebuilt from a JSON
#           config has lineNumber null and joinedCommand true. detailComplete is
#           false when any matched file's detail could not be fully recorded.
#           reasons is "clean" on a pass
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

# _curation_category_of <pattern-index> — the pattern's category. A pattern
# added without one is still a danger, never an empty string a dedup would drop.
_curation_category_of() { printf '%s' "${_SAFETY_CATEGORIES[$1]:-uncategorized-pattern}"; }

# _curation_match <pattern> <text> — does <text> match <pattern>? 0 = match,
# 1 = no match, 2 = no match but a grep ERRORED (callers treat that as unknown,
# never as clean). The pattern runs twice, and one match in either is a match:
#   LC_ALL=C          byte semantics — in a UTF-8 locale `.` cannot cross an
#                     invalid byte, so one stray byte inside `curl … | bash`
#                     hid the line from every pattern;
#   the caller locale [[:space:]] also matches Unicode spaces there, which the
#                     C locale does not — `ignore<U+2003>all previous
#                     instructions` must still read as an injection.
# Neither locale alone covers both evasions. `-a`: never treat text as binary.
_curation_match() {
    local rc_c rc_l
    LC_ALL=C grep -aEiq -e "$1" <<<"$2"
    rc_c=$?
    [ "$rc_c" -eq 0 ] && return 0
    grep -aEiq -e "$1" <<<"$2"
    rc_l=$?
    [ "$rc_l" -eq 0 ] && return 0
    { [ "$rc_c" -gt 1 ] || [ "$rc_l" -gt 1 ]; } && return 2
    return 1
}

# _curation_scan_findings <path> <joined:0|1> <pattern-index...> — read <path>'s
# text on stdin, echo one compact JSON finding per (pattern, matching line):
# {path, category, lineNumber, lineSha256, line}, or for a command reconstructed
# from a JSON config (joined=1) {…, lineNumber:null, joinedCommand:true,
# joinedIndex} — such a line exists nowhere in the file, so it has no line number.
# The sha256 covers the line verbatim (leading whitespace included). Lines never
# travel as a command-line argument (a minified line can exceed the 128 KiB
# per-argument limit): they go to jq on stdin. Both locales are searched (see
# _curation_match) and may return a line twice; the caller dedups.
# DETAIL only: nothing the verdict decides reads it (see _curation_screen_scan).
_curation_scan_findings() {
    local path="$1" joined="$2" text i line n
    shift 2
    text=$(cat)
    for i in "$@"; do
        { LC_ALL=C grep -anEi -e "${_SAFETY_PATTERNS[$i]}" <<<"$text"
          grep -anEi -e "${_SAFETY_PATTERNS[$i]}" <<<"$text"; } 2>/dev/null \
            | while IFS= read -r line; do
                n=${line%%:*}
                line=${line#*:}
                printf '%s\t%s\t%s\n' "$n" "$(_curation_sha256 "$line")" "$line"
            done \
            | jq -Rc --arg p "$path" --arg c "$(_curation_category_of "$i")" --argjson j "$joined" '
                index("\t") as $a | .[$a + 1:] as $r | ($r | index("\t")) as $b
                | (.[0:$a] | tonumber) as $n
                | {path:$p, category:$c, lineSha256:$r[0:$b], line:$r[$b + 1:]}
                | if $j == 1 then . + {lineNumber:null, joinedCommand:true, joinedIndex:$n}
                  else . + {lineNumber:$n} end'
    done
}

# _curation_load_exemptions <owner/repo> — echo the JSON array of reviewed
# exemptions recorded for <owner/repo> in CURATION_SAFETY_EXEMPTIONS that can be
# trusted to mean what they say: a single, non-empty line that hashes to its own
# recorded sha256 (the reviewer reads `line`, the screen removes `line`, the
# detail matches `lineSha256` — all three must be the same bytes). A missing file
# is simply no exemption; a malformed file, or an entry failing those checks, is
# no exemption either — the flags stand — and is reported, since a review is
# being ignored.
_curation_load_exemptions() {
    local repo="$1" f="${CURATION_SAFETY_EXEMPTIONS:-}" all entry line sha got n_all n_ok out
    if [ -z "$f" ] || [ ! -f "$f" ]; then
        printf '[]'
        return 0
    fi
    if ! all=$(jq -c --arg r "$repo" '[.exemptions[]? | select(.repo == $r)]' "$f" 2>/dev/null); then
        curation_warn "safety exemptions file is malformed ($f); no finding is lifted"
        printf '[]'
        return 0
    fi
    out=$(printf '%s' "$all" | jq -c '.[]
            | select((.path | type) == "string" and (.category | type) == "string"
                     and (.lineSha256 | type) == "string"
                     and (.line | type) == "string" and (.line | length) > 0
                     and (.line | test("\n") | not))' 2>/dev/null \
        | while IFS= read -r entry; do
            line=$(printf '%s' "$entry" | jq -r '.line')
            sha=$(printf '%s' "$entry" | jq -r '.lineSha256')
            got=$(_curation_sha256 "$line")
            [ "${#got}" -eq 64 ] && [ "$got" = "$sha" ] && printf '%s\n' "$entry"
        done | jq -cs '.' 2>/dev/null) || out='[]'
    [ -n "$out" ] || out='[]'
    n_all=$(printf '%s' "$all" | jq 'length' 2>/dev/null || echo 0)
    n_ok=$(printf '%s' "$out" | jq 'length' 2>/dev/null || echo 0)
    [ "$n_all" = "$n_ok" ] \
        || curation_warn "$((n_all - n_ok)) safety exemption(s) for $repo ignored: not one line hashing to its lineSha256"
    printf '%s' "$out"
}

# _curation_category_lifted <path> <category> — read <path>'s text on stdin;
# succeed only when that text, with every line exempted for (path, category)
# removed, no longer matches ANY pattern of the category. This is the same scan
# that flagged it (_curation_match), run on what is left — it does not read the
# finding detail at all, so no failure to extract or record detail can lift a
# flag. Any failure here (no scratch, unreadable exemptions, a grep error in the
# removal OR the re-scan) returns "not lifted".
# An identical copy of an exempted line is removed with it: exemption means "these
# bytes were reviewed", and the detail counts every copy so the reader sees them.
_curation_category_lifted() {
    local path="$1" category="$2" text lines residual rc i
    text=$(cat)
    [ -n "$scratch" ] && [ -f "$scratch/ex.json" ] || return 1
    lines="$scratch/exempt-lines"
    jq -r --arg p "$path" --arg c "$category" \
        '.[] | select(.path == $p and .category == $c) | .line' "$scratch/ex.json" > "$lines" 2>/dev/null \
        || return 1
    [ -s "$lines" ] || return 1
    residual=$(LC_ALL=C grep -avxF -f "$lines" <<<"$text")
    rc=$?
    [ "$rc" -le 1 ] || return 1
    for ((i = 0; i < ${#_SAFETY_PATTERNS[@]}; i++)); do
        [ "$(_curation_category_of "$i")" = "$category" ] || continue
        _curation_match "${_SAFETY_PATTERNS[$i]}" "$residual"
        [ "$?" -eq 1 ] || return 1
    done
    return 0
}

# _curation_screen_scan <path> [joined] — scan <path>'s text (stdin) for the
# running screen; `joined` marks the commands reconstructed from a JSON config.
# Appends to the caller's `reasons`, sets the caller's `lifted_any` when a
# reviewed exemption lifted a category and `detail_lost` when the finding detail
# for a matched category could not be fully recorded, and writes the detail to
# the caller's `scratch` directory (findings.jsonl / exempted.jsonl).
#
# Deciding and reporting are separate. DECIDE: which categories the text matches
# (_curation_match; a grep error is `scan-error`, never silence), then for each,
# whether _curation_category_lifted lifts it. REPORT: the per-line findings,
# marked exempt when their sha256 is a reviewed one — display only, best effort,
# and checked: every matched category must come back with at least one line.
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

    for c in "${cats[@]}"; do
        if _curation_category_lifted "$path" "$c" <<<"$text"; then
            lifted_any=1
        else
            reasons+=("$c")
        fi
    done

    if [ -z "$scratch" ] || [ ! -f "$scratch/ex.json" ]; then
        detail_lost=1
        return 0
    fi
    part=$(_curation_scan_findings "$path" "$joined" "${idx[@]}" <<<"$text" \
        | jq -cs --slurpfile ex "$scratch/ex.json" --arg cats "${cats[*]}" '
        ($ex[0] // []) as $ex
        | reduce .[] as $x ({seen: {}, out: []};
              "\($x.category):\($x.lineNumber // "j\($x.joinedIndex)")" as $k
              | if .seen[$k] then . else .seen[$k] = true | .out += [$x] end)
        | .out | sort_by(.lineNumber // 0, .joinedIndex // 0)
        | map(. as $x | . + {exempt: ($x.lineSha256 != "" and any($ex[];
              .path == $x.path and .category == $x.category and .lineSha256 == $x.lineSha256))})
        | . as $all
        | {kept: map(select(.exempt | not) | del(.exempt)),
           exempted: map(select(.exempt) | del(.exempt)),
           complete: ($cats | split(" ") | map(select(length > 0)) | all(. as $c | any($all[]; .category == $c)))}' \
        2>/dev/null) || { detail_lost=1; return 0; }
    [ "$(printf '%s' "$part" | jq -r '.complete' 2>/dev/null)" = "true" ] || detail_lost=1
    printf '%s' "$part" | jq -c '.kept[]' >> "$scratch/findings.jsonl" 2>/dev/null || detail_lost=1
    printf '%s' "$part" | jq -c '.exempted[]' >> "$scratch/exempted.jsonl" 2>/dev/null || detail_lost=1
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
    local reasons=() text r doc lifted_any=0 detail_lost=0 scanned=" "
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
                scanned+="$doc "
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
                    scanned+="$doc "
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
            # A doc that is also exec surface (an executable README) was read above.
            case "$scanned" in *" $path "*) continue ;; esac
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
    elif [ "$lifted_any" -eq 1 ]; then
        # Passing only because reviewed exemptions lifted every finding: say so,
        # a reader must never mistake this for content that matched nothing.
        out+=("exempted")
    else
        out+=("clean")
    fi
    _curation_safety_emit "$repo" "$ref" "$verdict" "$scratch" "$detail_lost" "${out[@]}"
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

# _curation_safety_emit <repo> <ref> <verdict> <scratch-dir|""> <detail-lost:0|1> <reason...>
_curation_safety_emit() {
    local repo="$1" ref="$2" verdict="$3" scratch="$4" lost="$5"; shift 5
    local fl=/dev/null el=/dev/null
    if [ -n "$scratch" ]; then
        [ -f "$scratch/findings.jsonl" ] && fl="$scratch/findings.jsonl"
        [ -f "$scratch/exempted.jsonl" ] && el="$scratch/exempted.jsonl"
    fi
    jq -cn --arg repo "$repo" --arg ref "$ref" --arg verdict "$verdict" \
        --slurpfile f "$fl" --slurpfile e "$el" \
        --argjson n "$CURATION_SAFETY_DETAIL_MAX" --argjson w "$CURATION_SAFETY_LINE_MAX" \
        --argjson lost "$lost" \
        'def shown: .[0:$n] | map(if (.line | length) > $w
                                  then .line |= .[0:$w] | .lineTruncated = true else . end);
         {repo:$repo, ref:$ref, verdict:$verdict, reasons:$ARGS.positional,
          findings:($f | shown), findingsTotal:($f | length),
          exempted:($e | shown), exemptedTotal:($e | length),
          detailComplete:($lost == 0)}' \
        --args "$@" 2>/dev/null \
    || jq -cn --arg repo "$repo" --arg ref "$ref" \
        '{repo:$repo, ref:$ref, verdict:"flag", reasons:["screen-emit-failed"],
          findings:[], findingsTotal:0, exempted:[], exemptedTotal:0, detailComplete:false}'
}

# CLI: curation-safety.sh <owner/repo> <ref> [<subpaths>]
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    set -u
    { [ $# -eq 2 ] || [ $# -eq 3 ]; } || { echo "Usage: $(basename "$0") <owner/repo> <ref> [<subpaths>]" >&2; exit 2; }
    curation_safety_screen "$1" "$2" "${3:-}"
    exit $?
fi
