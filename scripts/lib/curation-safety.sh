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
# server configs (.mcp.json / mcp.json), the plugin format's own declarations
# (hooks/hooks.json, .claude-plugin/plugin.json, marketplace.json), any other
# JSON, TOML or YAML file whose shape declares a server or a command whatever
# its name (MCP configs, a plugin's .lsp.json, a Gemini extension, Codex
# config.toml, Goose config.yaml: #679; keys in any case, `cmd` too; an
# unparseable one is scanned as text), and the
# members of any ARCHIVE in the tree (.zip, .skill, .tar.gz, …: #678 — a zip
# once carried two unscanned shell scripts past a clean verdict). The same
# high-signal danger patterns apply to every file; a JSON or TOML config is also
# scanned one line per declared command, "command" joined with its "args" (YAML
# is not: no parser in the standard library, so its text is scanned and a
# config-shaped YAML is flagged yaml-config-unparsed, for review). (Limitations,
# all fail toward human review: a download executed in a separate statement, a
# hook command referencing a script outside the scanned surface, and a plugin
# manifest pointing its hooks at a custom-named file are not caught — see
# _SAFETY_PATTERNS. A flag only ever routes to review. Archives, likewise not
# caught: a payload encoded as text (base64, uuencode) and decoded at run time;
# a stream in a format the standard library cannot open (zstd, lz4, lzip, .Z,
# raw lzma); an installer kept as a member of another archive; an archive in a
# non-exec file whose name is not an archive's, unpacked by a script.)
#
# Fail-safe (EF-012): anything that cannot be confirmed safe is FLAGGED, never
# silently passed. Reasons: content-unfetchable (no doc), doc-unreadable (the doc
# IS there and its body could not be read — no falling back to a neighbouring
# file, which would report a skill clean on a doc that was never its own),
# exec-surface-unfetchable (tree unlistable), exec-file-unfetchable (a listed
# exec file unreadable), exec-surface-truncated (GitHub itself truncated the
# tree, so files we never saw the names of went unscanned), exec-surface-over-cap
# (the tree listed more exec files than the cap, so the tail went unscanned),
# scan-error (a pattern grep failed), scan-blind (the pattern scan reported "no
# match" on a text bash itself can see characters in — the instrument, not the
# text, was empty), screen-emit-failed (the verdict itself could not be rendered).
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
# doc-unreadable (the doc is present and unreadable — both modes),
# exec-surface-unfetchable (tree unlistable), exec-file-unfetchable (a listed
# exec file unreadable), exec-surface-truncated (GitHub truncated the tree),
# exec-surface-over-cap (more exec files than the cap), json-surface-over-cap
# (more other JSON/TOML/YAML files than their own cap, #679), yaml-config-unparsed
# (a YAML that declares a command, whose commands cannot be rebuilt without a
# parser, #679), toml-unreadable (the TOML reader could not run: no python3 3.11+
# — an outage), scan-error (a pattern
# grep failed, so the text could not be confirmed clean), scan-blind (the scan
# answered "no match" about a text that demonstrably holds characters).
# Archives (see _curation_scan_archive): archive-unreadable (the reader could
# not run, e.g. no python3 — an outage), archive-corrupt (the archive does not
# parse, or is encrypted), archive-nested (an archive inside one, not unpacked),
# archive-over-cap (more members or bytes than the caps, or a body over the
# 1 MB GitHub serves), archive-unsupported (a format the screen cannot read,
# e.g. .7z, or a member that is a link or a device). All but the first are
# properties of the archive, recorded like a finding.
#
# Nothing on the verdict path travels through a here-string: bash serves one
# from a temp file in /tmp above the pipe buffer, and at EVERY size on the bash
# 3.2 that macOS still ships. A redirection that cannot create that file returns
# 1 without running the command — the exact answer grep gives for "clean" — so a
# full /tmp would have reported every candidate safe. Pipes and process
# substitutions replace them (process substitution where the loop or the array
# must stay in the current shell; `reasons` IS the verdict).
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
#           CURATION_SAFETY_ARCHIVE_MAX_MEMBERS — archive entries read in the
#           whole run before archive-over-cap (2000); _MAX_BYTES — the bytes one
#           archive may decompress to (16 MiB).
#           CURATION_SAFETY_PYTHON — the interpreter that reads archives (python3).
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

# _curation_contents_api <repo> <ref> <path> — echo the contents API path for one
# file, each path segment and the ref percent-encoded (`/` kept between
# segments). The path comes from the candidate's own tree: inserted raw, a name
# holding `?`, `&`, `#` or `%` rewrites the request (`run?ref=v0&x=.sh` asks for
# `run` at v0) and the screen scans a file that is not the one installed (#680).
_curation_contents_api() {
    local p r
    p=$(curation_path_uri "$3") || return 1
    r=$(curation_uri "$2") || return 1
    printf 'repos/%s/contents/%s?ref=%s' "$1" "$p" "$r"
}

# _curation_trees_api <repo> <ref> — the recursive git-trees API path, ref
# encoded: the ref is a tag the candidate chose (see curation_uri).
_curation_trees_api() {
    local r
    r=$(curation_uri "$2") || return 1
    printf 'repos/%s/git/trees/%s?recursive=1' "$1" "$r"
}

# _curation_fetch_one <repo> <ref> <path> — echo the decoded text of one file at
# <ref> via the contents API (base64 body, mockable offline); return non-zero if
# the file is absent, unfetchable, or undecodable. A present-but-undecodable /
# empty-after-decode body is treated as NOT fetched — never as clean text — so
# corrupt base64 or a wrong-decoder pick fails SAFE instead of false-passing.
#
# The two non-zero answers are NOT the same fact, and the caller acts on the
# difference: 2 = the API ANSWERED, so the file is there, and its body could not
# be read. GitHub serves an EMPTY body for a blob over 1 MB, so 2 is the ordinary
# answer for a big file — and reading it as "absent" would let a doc fall back to
# a neighbour that was never the subject.
#
# 1 is weaker than it looks and must not be read as "absent": curation_gh_api
# answers non-zero for a 404, a rate limit, a 5xx, a dead network and an expired
# token alike, so 1 means "could not ask, or nothing to ask about". The screen
# survives that only because the SAME outage takes the tree call down with it
# (exec-surface-unfetchable, a flag). Telling a real 404 from a transport failure
# needs a status the CLI does not give us here; until it does, nothing may treat
# 1 as proof that a file does not exist.
_curation_fetch_one() {
    local repo="$1" ref="$2" file="$3" api body content decoded
    api=$(_curation_contents_api "$repo" "$ref" "$file") || return 1
    body=$(curation_gh_api "$api" 2>/dev/null) || return 1
    # The API answered, so the path EXISTS; from here every failure is "present
    # but unreadable".
    content=$(printf '%s' "$body" | jq -r '.content // empty' 2>/dev/null)
    [ -n "$content" ] || return 2
    decoded=$(printf '%s' "$content" | _curation_b64decode) || return 2
    [ -n "$decoded" ] || return 2
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
    IFS='+' read -ra sps < <(printf '%s' "$subpaths") || true
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
#                      curl|node, bash <(curl), eval "$(curl …)"), or an
#                      unpinned git source: a git+ URL (any scheme) with no @ref,
#                      or with @main/master/HEAD/develop/trunk/refs/… (uvx --from,
#                      pip install, a script constant). A SHA or a tag is a pin.
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
# grep. Nor is a package runner at @latest (`npx x@latest`, an .mcp.json running
# `uvx server@latest`): measured 2026-10-04 on the 27 pinned repos, the pattern
# flagged only vendors running their OWN CLI in their docs (prisma/skills
# `npx create-db@latest`, shadcn `npx shadcn@latest`) — separating that from an
# auto-started server needs a per-file-type rule the table does not have.
# Also unseen, as of 2026-10-04: other fetch-and-run forms — `npx github:user/repo`,
# `npm i user/repo`, `go run …@latest`, `cargo install --git`, a branch archive
# (`…/archive/main.zip`, `…/refs/heads/main.tar.gz`) — and a moving branch with a
# name outside main/master/HEAD/develop/dev/trunk/latest/refs/.
# The screen fails toward human review (a clean verdict only enables an
# auto-DRAFT, still human-merged), so this is a coverage gap, never a silent risk.
_INTERP='sh|bash|zsh|node|deno|bun|python[0-9.]*|perl|ruby|php|env'
_SAFETY_CATEGORIES=(
    remote-exec
    remote-exec
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
    # an unpinned git source — no @ref after the path (login details before the
    # host, as in git+ssh://git@… or a token@, are not a ref): uvx --from / pip
    # install / a script constant
    "git\\+[a-z]+://([^/[:space:]\"'@]+@)?[^[:space:]\"'@#]+([#[:space:]\"']|$)"
    # a git source "pinned" to a moving branch
    "git\\+[a-z]+://([^/[:space:]\"'@]+@)?[^[:space:]\"'@#]+@(main|master|head|develop|dev|trunk|latest|refs/)"
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
#
# The text travels through a PIPE, never a here-string: above the pipe buffer
# (measured: between 65000 and 70000 bytes) bash serves a here-string from a
# temp file in /tmp, and on bash 3.2 — still the system bash on macOS — it does
# so at every size. A redirection that cannot create that file returns 1 WITHOUT
# running the command, which is byte-for-byte the "ran, found nothing" answer,
# so a full /tmp would report every candidate clean. A pipe needs no filesystem.
# grep -q stops at the first match and closes the pipe mid-write. Under systemd
# (IgnoreSIGPIPE=yes) printf survives that and prints "write error: Broken pipe"
# — expected noise, so only printf's stderr is silenced. The verdict is GREP's
# status (PIPESTATUS[1]), never the pipeline's: under a caller's pipefail,
# printf's EPIPE status would turn a match into "clean" (measured: rc=1).
_curation_match() {
    local rc_c rc_u
    printf '%s\n' "$2" 2>/dev/null | LC_ALL=C grep -aEiq -e "$1"
    rc_c=${PIPESTATUS[1]}
    [ "$rc_c" -eq 0 ] && return 0
    printf '%s\n' "$2" 2>/dev/null | _curation_grep_utf8 -aEiq -e "$1"
    rc_u=${PIPESTATUS[1]}
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
        { printf '%s\n' "$text" | LC_ALL=C grep -anEi -e "${_SAFETY_PATTERNS[$i]}"
          printf '%s\n' "$text" | _curation_grep_utf8 -anEi -e "${_SAFETY_PATTERNS[$i]}"; } 2>/dev/null \
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

    # Differential control: "no match" (1) is also what the scan reports when it
    # NEVER SAW the text — a failed redirection, a grep that cannot run, a
    # mangled locale. That silence is indistinguishable from a clean file, and
    # it decides the verdict, so it must not be taken on trust. Bash's own
    # matcher is an independent instrument: no process, no redirection, no
    # filesystem. When IT finds a non-space character that the scan's instrument
    # cannot find, the instrument is blind — flag, never "clean".
    if [[ "$text" =~ [^[:space:]] ]]; then
        _curation_match '[^[:space:]]' "$text"
        rc=$?
        if [ "$rc" -ne 0 ]; then
            # 2 is already the instrument SAYING it failed; 1 is the silent one.
            if [ "$rc" -eq 2 ]; then reasons+=("scan-error"); else reasons+=("scan-blind"); fi
            return 0
        fi
    fi

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
    part=$(printf '%s\n' "$text" | _curation_scan_findings "$path" "$joined" "${idx[@]}" \
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
# malformed file is never treated as clean. The jq definition is shared with the
# rendering, which must rebuild commands exactly the same way.
# Keys match whatever their case, and "cmd" counts as "command" (#679): Go's
# JSON decoder folds case, Goose names it `cmd`. A command given as an array
# (`["bash", "-c", …]`) is rebuilt word by word, not as its JSON text.
# shellcheck disable=SC2016  # jq variables, not shell ones
_CURATION_JQ_COMMANDS='def ckey($n): to_entries | map(select(.key | ascii_downcase | IN($n[])) | .value);
def commands: .. | objects | select(any(keys[]; ascii_downcase | IN("command", "cmd")))
    | (ckey(["command", "cmd"]) | flatten) + (ckey(["args"]) | map(select(type == "array")) | flatten)
    | map(tostring | gsub("[\r\n]+"; " ")) | join(" ");'
_curation_json_commands() {
    jq -r "$_CURATION_JQ_COMMANDS commands" 2>/dev/null || true
}

# _curation_fetch_blob <repo> <ref> <path> — echo a JSON file's text through
# the git blobs API, for the bodies the contents API withholds (over 1 MB; it
# still names the blob's sha and size). A big data file (a test fixture in
# vercel-labs/agent-skills) must not flag every pin of its repo; a SCRIPT over
# 1 MB stays a flag, never read this way. An empty file echoes nothing and
# succeeds (nothing in it runs); a blob over CURATION_SAFETY_BLOB_MAX bytes
# (default 10 MB) is not downloaded and fails, as does anything unreadable.
_curation_fetch_blob() {
    local api meta sha size out
    local max="${CURATION_SAFETY_BLOB_MAX:-10485760}"
    api=$(_curation_contents_api "$1" "$2" "$3") || return 1
    meta=$(curation_gh_api "$api" 2>/dev/null) || return 1
    size=$(printf '%s' "$meta" | jq -r '.size // empty' 2>/dev/null)
    case "$size" in '' | *[!0-9]*) return 1 ;; 0) return 0 ;; esac
    [ "$size" -le "$max" ] || return 1
    sha=$(printf '%s' "$meta" | jq -r '.sha // empty' 2>/dev/null)
    [[ "$sha" =~ ^[0-9a-f]+$ ]] || return 1
    out=$(curation_gh_api "repos/$1/git/blobs/$sha" 2>/dev/null \
        | jq -r '.content // empty' 2>/dev/null | _curation_b64decode) || return 1
    [ -n "$out" ] || return 1
    printf '%s' "$out"
}

# _curation_json_is_config — read a JSON file on stdin; return 1 only when it
# is NOT exec surface: empty, or a parsed body that declares no server or
# command. A config is recognised by its SHAPE (an `mcpServers` key, or any
# object with a "command"), never by a filename list: every client names its
# own (`.agy-plugin/mcp_config.json`, `gemini-extension.json`, a plugin's
# `.lsp.json`), and a list missed all three in pinned subjects (#679). A body jq
# rejects (JSONC, a broken file) cannot be ruled out, so it stays surface and
# its raw text is scanned. Keys match whatever their case, and `cmd` and
# `mcp_servers` count too (Go's decoder folds case; Goose, Codex), as in
# _CURATION_JQ_COMMANDS.
_curation_json_is_config() {
    local body shape
    body=$(cat)
    [ -n "$body" ] || return 1
    shape=$(printf '%s' "$body" | jq -r '[.. | objects
        | select(any(keys[]; ascii_downcase | IN("mcpservers", "mcp_servers", "command", "cmd")))] | length' 2>/dev/null) || return 0
    case "$shape" in '' | *[!0-9]*) return 0 ;; esac
    [ "$shape" -gt 0 ]
}

# _curation_toml_json — read a TOML file on stdin, echo it as JSON, so its shape
# and its commands are read by the JSON rules above (Codex `config.toml`
# declares `[mcp_servers.x]` with `command` and `args`). Python's standard
# library (3.11+) parses it. Exit: 0 = JSON on stdout; 1 = the file does not
# parse (no client reads it either: the caller scans its text); anything else =
# the reader could not run — no interpreter, or one without tomllib — and the
# file's commands cannot be rebuilt (the caller flags toml-unreadable, an outage).
_curation_toml_json() {
    "${CURATION_SAFETY_PYTHON:-python3}" -I -c 'import json, sys
try:
    import tomllib
except ImportError:
    sys.exit(3)
try:
    data = tomllib.loads(sys.stdin.read())
except Exception:
    sys.exit(1)
print(json.dumps(data, default=str))' 2>/dev/null
}

# _curation_yaml_is_config <text> — 0 when a YAML text may declare a server or
# a command: a key named command, cmd, mcpServers or mcp_servers (any case,
# block or flow style), or a key the text does not spell out on its line — an
# escaped quoted key ("\x63md"), an alias used as a key (*k :), a complex key
# (? command, in a block or a flow collection) — which a loader may read as one
# of those. A leading BOM is dropped, as loaders do; whole-line comments are
# skipped (an inline one is kept: cutting at `#` could cut a key off). Read by
# bash's own matcher: no process that could fail silently into "not a
# config". The standard library has no YAML parser, so the caller cannot
# rebuild the commands and sends a config-shaped YAML to review (#679). A
# phrase rule leaks both ways — prose in a block scalar still matches — so the
# review it causes is not recorded as a finding (see curation-discover.sh).
_curation_yaml_is_config() {
    local text="${1#$'\xef\xbb\xbf'}" line lower="" q='["'\'']'
    while IFS= read -r line || [ -n "$line" ]; do
        [[ "$line" =~ ^[[:space:]]*# ]] || lower+="${line,,}"$'\n'
    done < <(printf '%s\n' "$text")
    local key="(^|[[:space:]{,[-])${q}?(command|cmd|mcpservers|mcp_servers)${q}?[[:space:]]*:"
    local escaped="${q}[^\"'"$'\n'"]*\\\\[^\"'"$'\n'"]*${q}[[:space:]]*:"
    # An alias key opens its key: after the indent, a `- `, a flow `{`, `[` or
    # `,`, or an explicit `? `, and names an anchor. A shell glob (`*"$tag"*)`)
    # or bold Markdown (`**repository:`) inside a value is neither (both seen in
    # pinned repos).
    local alias='(^|'$'\n''|[{,[])[[:space:]]*(-[[:space:]]+)?(\?[[:space:]]+)?\*[a-z0-9_.-]+[[:space:]]*:([[:space:]]|$)'
    local complex='(^|'$'\n''|[{,[])[[:space:]]*(-[[:space:]]+)?\?([[:space:]]|$)'
    [[ "$lower" =~ $key ]] || [[ "$lower" =~ $escaped ]] \
        || [[ "$lower" =~ $alias ]] || [[ "$lower" =~ $complex ]]
}

# _curation_toml_text_is_config <text> — for a TOML file tomllib rejects: 0 when
# its text may still declare a server or a command (a `command`, `cmd`,
# `mcpServers` or `mcp_servers` key, any case, or such a table header). A
# real client may read what tomllib does not — Codex reads TOML 1.1 — so a
# rejected config cannot be confirmed safe and goes to review (#679).
_curation_toml_text_is_config() {
    local lower="${1,,}" q='["'\'']'
    local key="(^|[[:space:]{,.[])${q}?(command|cmd|mcpservers|mcp_servers)${q}?([[:space:]]*=|[[:space:]]*[].])"
    [[ "$lower" =~ $key ]]
}

# What counts as an archive, by name (jq/ERE, matched case-insensitively): zip
# containers under their many names (a .skill is a zip, so are .jar, .whl, .egg,
# .pyz, .nupkg, .apk, .crx…), tar and its compressions, single compressed files,
# and the formats the reader cannot open (.zst, .7z, .rar — flagged, not
# skipped). An archive under any other name is caught by its bytes when it is
# in the surface for another reason (a script, an exec-bit file: see the scan
# loop); a non-exec file of an unknown name is not in the surface at all.
_CURATION_ARCHIVE_RE='\.(zip|skill|jar|war|ear|aar|apk|ipa|egg|whl|pyz|pyzw|nupkg|vsix|xpi|crx|tar|tgz|tbz2?|txz|gz|bz2|xz|zst|7z|rar)$'

# The byte sequences that start an archive or compressed stream INSIDE a file
# the shell already read as text (NUL bytes dropped): a zip local header or end
# record, a deflated gzip header, a bzip2 block, an xz header. One found
# anywhere sends the file to the archive reader — a zipapp behind a shebang or
# a makeself installer is a script whose payload the text scan cannot see.
_CURATION_EMBEDDED_RE="PK$(printf '\003\004')|PK$(printf '\005\006')|$(printf '\037\213\010')|BZh[1-9]1AY&SY|$(printf '\375')7zXZ"

# _curation_fetch_raw <repo> <ref> <path> <dest> — write the file's BYTES to
# <dest> (an archive cannot ride a shell variable: it holds NUL bytes).
# 0 = written; 1 = could not ask (as _curation_fetch_one); 2 = present but its
# body could not be decoded; 3 = GitHub withheld the body of a non-empty file
# (what it does over 1 MB); 4 = the file is empty.
_curation_fetch_raw() {
    local api body size
    api=$(_curation_contents_api "$1" "$2" "$3") || return 1
    body=$(curation_gh_api "$api" 2>/dev/null) || return 1
    printf '%s' "$body" | jq -r '.content // empty' 2>/dev/null | _curation_b64decode > "$4" || return 2
    [ -s "$4" ] && return 0
    size=$(printf '%s' "$body" | jq -r '.size // 0' 2>/dev/null)
    case "$size" in '' | *[!0-9]*) return 2 ;; 0) return 4 ;; esac
    return 3
}

# The archive reader (python3, standard library only). It never extracts under
# a member's own name — no path is trusted: member N's bytes go to <dir>/m<N>,
# NUL bytes dropped so the shell can read them. It prints one line per member
# written ("M<TAB>m<N><TAB>name", control characters in the name replaced), one
# per finding about the archive itself ("R<TAB>reason") and the number of
# entries it counted ("N<TAB>n"). Exit 2 = the archive does not parse; exit 3 =
# no archive was found in the file at all.
#
# A blob may be several things at once, and each reading is taken: a tar whose
# last member is a zip also reads as a zip, and compressed streams may follow a
# shell stub (makeself) or be a tar (tar.gz). So: the tar members (reading past
# an invalid header, as GNU tar does), the zip members, and EVERY compressed
# stream signature found in the file — each decompressed and scanned whole (a
# tar's tail, a single .gz), and read as a tar when it holds one. A decoy
# stream before the real one, or a zip appended after it, hides nothing; more
# than 4096 signatures is archive-over-cap. A signature that yields no bytes is
# not a stream; one that yields bytes and then fails (a bad CRC) is kept, as
# gzip -dc keeps it, and is archive-corrupt — so is a zip member that fails its
# CRC (its bytes are kept, the next members still read) and a zip entry whose
# offset holds no local header (an entry can lie about where it starts).
# A nested archive is reported, not unpacked;
# the other members are still read. A link or device member is reported (unzip
# and tar recreate it, and a link can point out of the install directory).
# Every entry, a directory included, counts toward the member cap, and the
# count is printed even when the read fails. Members and streams have a byte
# cap each, so a tar.gz is not counted twice.
# Embedded mode (argv 7): the file is a script or binary that merely holds
# archive bytes; when NOTHING could be read from them it is "no archive found"
# (exit 3), never corrupt — a native binary or a signature written as text is
# not one. Once anything was read, damage is archive-corrupt there too.
# The raw bytes outside any member (a zip comment, a stub, a tar's tail) are the
# caller's to scan: it scans the whole file as text.
_CURATION_PY_ARCHIVE='
import bz2, io, lzma, os, re, stat, sys, tarfile, zipfile, zlib
blob, name, out = sys.argv[1], sys.argv[2], sys.argv[3]
max_members, max_bytes = int(sys.argv[4]), int(sys.argv[5])
ARCHIVE = re.compile(sys.argv[6], re.I)
embedded = sys.argv[7] == "embedded"
MAGIC = (b"PK\x03\x04", b"PK\x05\x06", b"\x1f\x8b", b"\x1f\x9d", b"BZh", b"\xfd7zXZ\x00",
         b"7z\xbc\xaf\x27\x1c", b"Rar!", b"\x28\xb5\x2f\xfd", b"\x04\x22\x4d\x18", b"LZIP")
def gzip_header(buf):
    # Length of a gzip member header, or None. The body is then inflated as raw
    # deflate: no CRC check, so a stream whose trailer lies still yields its
    # bytes (gzip -dc writes them before it complains).
    if len(buf) < 10: return None
    flags, h = buf[3], 10
    if flags & 4:
        if len(buf) < h + 2: return None
        h += 2 + buf[h] + 256 * buf[h + 1]
    for bit in (8, 16):
        if flags & bit:
            end = bytes(buf[h:h + 65536]).find(b"\x00")
            if end < 0: return None
            h += end + 1
    if flags & 2: h += 2
    return h if h <= len(buf) else None
STREAMS = ((re.compile(rb"\x1f\x8b\x08"), "gzip"),
           (re.compile(rb"BZh[1-9]1AY&SY"), bz2.BZ2Decompressor),
           (re.compile(rb"\xfd7zXZ\x00"), lzma.LZMADecompressor))
MAX_SIGNATURES, CHUNK = 4096, 65536
# got: something was really read (a member, a non-empty stream). damaged: a
# member or stream failed part-way. Damage is archive-corrupt — unless, in
# embedded mode, nothing at all was read: then the bytes were never an archive.
reasons = set()
state = {"n": 0, "bytes": 0, "raw": 0, "stop": False, "got": False, "damaged": False}

def over():
    reasons.add("archive-over-cap"); state["stop"] = True

def room(key="bytes"):
    return max_bytes - state[key] + 1

def count():
    state["n"] += 1
    if state["n"] > max_members:
        over()
    return not state["stop"]

def take(member, data, raw=False):
    key = "raw" if raw else "bytes"
    state[key] += len(data)
    if state[key] > max_bytes:
        over(); return
    state["got"] = True
    if data.startswith(MAGIC) or (not raw and (ARCHIVE.search(member) or data[257:262] == b"ustar")):
        reasons.add("archive-nested"); return
    idx = "m%05d" % state["n"]
    with open(os.path.join(out, idx), "wb") as f:
        f.write(data.replace(b"\x00", b""))
    print("M\t%s\t%s" % (idx, re.sub(r"[\x00-\x1f\x7f]", "?", member)))

def inflate(buf, mk, limit):
    # Fed in chunks, so what a stream yields before a CRC or format error is
    # kept: gzip -dc writes it out too, and tar extracts it.
    if mk == "gzip":
        h = gzip_header(buf)
        if h is None: return b"", False
        buf, d = buf[h:], zlib.decompressobj(-15)
    else:
        d = mk()
    parts, size = [], 0
    try:
        for k in range(0, len(buf), CHUNK):
            if getattr(d, "eof", False) or size > limit:
                break
            p = d.decompress(buf[k:k + CHUNK])
            parts.append(p); size += len(p)
        return b"".join(parts), True
    except Exception:
        return b"".join(parts), False

def read_tar(t):
    for i in t:
        if not count(): return
        if i.isdir(): continue
        if not i.isreg(): reasons.add("archive-unsupported"); continue
        if i.size >= room(): over(); return
        take(i.name, t.extractfile(i).read(room()))

def read_zip(z, data):
    for i in z.infolist():
        if not count(): return
        if data[i.header_offset:i.header_offset + 4] != b"PK\x03\x04":
            state["damaged"] = True; continue
        if i.is_dir(): continue
        kind = stat.S_IFMT(i.external_attr >> 16)
        if kind and kind != stat.S_IFREG: reasons.add("archive-unsupported"); continue
        if i.file_size >= room(): over(); return
        # A member that fails its CRC still yields its bytes, and one bad member
        # must not hide the next (zipimport never checks the others).
        part = b""
        try:
            with z.open(i) as s:
                part = s.read(max(i.file_size - 1, 0))
                part += s.read(room() - len(part))
        except Exception:
            state["damaged"] = True
        if part or i.file_size == 0:
            take(i.filename, part)

def read_streams(data, tar_read):
    view = memoryview(data)
    hits = sorted(((m.start(), mk) for rx, mk in STREAMS for m in rx.finditer(data)), key=lambda h: h[0])
    if len(hits) > MAX_SIGNATURES:
        over(); hits = hits[:MAX_SIGNATURES]
    found = False
    for off, mk in hits:
        if state["stop"]: break
        stream, ok = inflate(view[off:], mk, room("raw"))
        if not stream:
            # A signature that yields nothing is not a stream (a decoy, a
            # signature in text) — except where the file claims to be one.
            if not ok and off == 0 and not embedded: state["damaged"] = True
            continue
        if not ok: state["damaged"] = True
        if not count(): break
        found = True
        single = re.search(r"\.(gz|bz2|xz)$", name, re.I) if off == 0 else None
        label = os.path.basename(name)[:-len(single.group(0))] if single else "<stream@%d>" % off
        take(label, stream, raw=True)
        if stream[257:262] == b"ustar" and not (off == 0 and tar_read) and not state["stop"]:
            try:
                with tarfile.open(fileobj=io.BytesIO(stream), ignore_zeros=True) as t:
                    read_tar(t)
            except Exception:
                state["damaged"] = True
    return found

rc = 0
try:
    with open(blob, "rb") as f:
        data = f.read()
    # Each reading on its own: one that fails (a tar.gz with trailing bytes
    # breaks is_tarfile) must not skip the others.
    tar_read = zip_read = streams_read = False
    try:
        tar_read = tarfile.is_tarfile(blob)
        if tar_read:
            with tarfile.open(blob, ignore_zeros=True) as t:
                read_tar(t)
    except Exception:
        state["damaged"] = True
    try:
        if not state["stop"] and zipfile.is_zipfile(blob):
            zip_read = True
            with zipfile.ZipFile(blob) as z:
                read_zip(z, data)
    except Exception:
        state["damaged"] = True
    try:
        if not state["stop"]:
            streams_read = read_streams(data, tar_read)
    except Exception:
        state["damaged"] = True
    read = tar_read or zip_read or streams_read
    if state["damaged"]:
        if embedded and not state["got"]:
            rc = 3
        else:
            reasons.add("archive-corrupt")
    elif not read and not state["got"]:
        if re.search(r"\.(zst|7z|rar)$", name, re.I):
            reasons.add("archive-unsupported")
        else:
            rc = 3
except Exception:
    rc = 2
finally:
    for r in sorted(reasons):
        print("R\t" + r)
    print("N\t%d" % state["n"])
sys.exit(rc)
'

# _curation_scan_archive <path> [embedded] — read the archive at <path> member
# by member and scan each member like any exec file, as "<path>!<member>". The
# whole file is ALSO scanned as raw text: bytes no member holds (a zip comment,
# a stub before the first entry, data after a tar's end) are what an exec-bit
# archive runs first. "embedded" = the caller already text-scanned the file and
# found archive bytes inside it: no second raw scan, and finding no archive
# after all is not a flag.
#
# Runs inside curation_safety_screen: uses its repo, ref, scratch, reasons and
# archive_entries — the member cap bounds the whole run, not each archive, so a
# repo of many archives cannot multiply the scan cost. Two kinds of reason, as
# discovery and the nightly watch tell them apart: archive-unreadable is an
# OUTAGE (no scratch, no interpreter, a reader that crashed — a re-run may
# succeed); archive-corrupt, -over-cap (incl. a body GitHub withholds, over
# 1 MB), -nested and -unsupported are properties of the archive, which a re-run
# would meet again.
_curation_scan_archive() {
    local path="$1" embedded="${2:-}" dir out rc kind a b left
    local py="${CURATION_SAFETY_PYTHON:-python3}"
    local max_m max_b
    max_m=$(_curation_cap CURATION_SAFETY_ARCHIVE_MAX_MEMBERS 2000)
    max_b=$(_curation_cap CURATION_SAFETY_ARCHIVE_MAX_BYTES 16777216)
    left=$((max_m - ${archive_entries:-0}))
    if [ "$left" -le 0 ]; then
        reasons+=("archive-over-cap")
        return 0
    fi
    if [ -z "$scratch" ]; then
        reasons+=("archive-unreadable")
        return 0
    fi
    dir=$(mktemp -d "$scratch/archive.XXXXXX" 2>/dev/null) || { reasons+=("archive-unreadable"); return 0; }
    _curation_fetch_raw "$repo" "$ref" "$path" "$dir/blob"; rc=$?
    case "$rc" in
        0) ;;
        3) reasons+=("archive-over-cap") ;;
        4) ;;
        *) reasons+=("exec-file-unfetchable") ;;
    esac
    if [ "$rc" -eq 0 ]; then
        [ -n "$embedded" ] || _curation_screen_scan "$path" < <(LC_ALL=C tr -d '\000' < "$dir/blob")
        out=$("$py" -I -c "$_CURATION_PY_ARCHIVE" "$dir/blob" "$path" "$dir" "$left" "$max_b" \
            "$_CURATION_ARCHIVE_RE" "${embedded:-archive}" 2>/dev/null); rc=$?
        case "$rc" in
            0) ;;
            2) reasons+=("archive-corrupt") ;;
            3) [ -n "$embedded" ] || reasons+=("archive-corrupt") ;;
            *)
                reasons+=("archive-unreadable")
                curation_warn "archive reader '$py' did not run (exit $rc): $path was not read"
                ;;
        esac
        while IFS="$(printf '\t')" read -r kind a b; do
            case "$kind" in
                M) _curation_screen_scan "$path!$b" < "$dir/$a" ;;
                R) reasons+=("$a") ;;
                N) archive_entries=$(( ${archive_entries:-0} + a )) ;;
            esac
        done < <(printf '%s\n' "${out:-}")
    fi
    # Members may weigh up to the byte cap each archive: never let them pile up.
    rm -rf -- "${dir:?}"
    return 0
}

# _curation_list_exec_surface <repo> <ref> [<subpaths>] [exec|json] — echo the
# candidate's executable-surface paths (one per line) from the recursive git
# tree at <ref>: scripts, exec-bit files, Claude settings hook blocks
# (settings*.json), MCP server configs (.mcp.json / mcp.json) and plugin
# declarations (hooks.json, plugin.json, marketplace.json) — the files that can
# actually run code in a user's session, which the SKILL.md/README.md doc cannot
# reveal. Capped at CURATION_SAFETY_MAX_FILES (default 250) to bound API calls
# on large repos. With `json`: every OTHER *.json / .jsonc / .json5 / .toml /
# .yaml / .yml (any case) instead, whose shape the scan reads (#679), under
# its own cap CURATION_SAFETY_MAX_JSON (default 250; over it the caller flags
# json-surface-over-cap) — folders of locale or fixture JSON must not crowd
# scripts out of the exec cap.
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
    local repo="$1" ref="$2" subpaths="${3:-}" kind="${4:-exec}" api body
    local cap="${CURATION_SAFETY_MAX_FILES:-250}"
    [ "$kind" = "json" ] && cap="${CURATION_SAFETY_MAX_JSON:-250}"
    api=$(_curation_trees_api "$repo" "$ref") || return 1
    body=$(curation_gh_api "$api" 2>/dev/null) || return 1
    # A response without a .tree array (e.g. an error object) is unusable.
    printf '%s' "$body" | jq -e '.tree | type == "array"' >/dev/null 2>&1 || return 1
    local truncated all count
    truncated=$(printf '%s' "$body" | jq -r '.truncated // false')
    all=$(printf '%s' "$body" | jq -r --arg archive "$_CURATION_ARCHIVE_RE" --arg kind "$kind" '
        .tree[] | select(.type == "blob")
        | ((.path | test("\\.(sh|bash|zsh|py|js|mjs|cjs|rb|pl|php)$"))
            or (.path | test($archive; "i"))
            or (.mode == "100755")
            or (.path | split("/")[-1] | (test("^settings.*\\.json$") or test("^\\.?mcp\\.json$")
                or test("^(hooks|plugin|marketplace)\\.json$")))) as $exec
        | select(if $kind == "json" then ($exec | not) and (.path | test("\\.(json[c5]?|toml|ya?ml)$"; "i")) else $exec end)
        | .path')
    # Subpath scoping (#384 fix): when the skill lives in subpath(s), keep ONLY
    # files under them — BEFORE the cap — so an unrelated big monorepo elsewhere
    # never false-trips exec-surface-over-cap. Literal prefix match (no regex).
    if [ -n "$subpaths" ]; then
        local sp sps=() scoped=""
        IFS='+' read -ra sps < <(printf '%s' "$subpaths") || true
        for sp in "${sps[@]}"; do
            [ -n "$sp" ] || continue
            scoped+=$(printf '%s\n' "$all" | awk -v p="$sp/" 'index($0,p)==1')$'\n'
        done
        all=$(printf '%s' "$scoped" | grep . | sort -u || true)
    fi
    count=$(printf '%s' "$all" | grep -c . || true)
    # The count comes from the same instrument that filters the list, and "0" is
    # a legitimate answer (plenty of skills ship no exec file). A NON-NUMBER is
    # not: it means grep did not run, and the empty list that comes with it would
    # otherwise be reported as a surface listed and found empty — a clean pass
    # over files nobody looked at. Fail safe: unlistable, like a dead tree call.
    case "$count" in
        '' | *[!0-9]*)
            curation_warn "exec-surface listing could not be counted ('$count'); treating the surface as unlistable"
            return 1
            ;;
    esac
    if [ "$truncated" = "true" ] || [ "$count" -gt "$cap" ]; then
        # Display only: head closes the pipe once it has $cap lines; grep's
        # EPIPE complaint under systemd is noise, as in _curation_match.
        printf '%s\n' "$all" 2>/dev/null | grep . 2>/dev/null | head -n "$cap" || true
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
# _curation_tree_has <repo> <ref> <path> — 0 iff the recursive tree at <ref>
# lists <path> as a file. Any failure answers no (the caller only uses it to
# tell "not scanned" from "nothing there").
_curation_tree_has() {
    local api
    api=$(_curation_trees_api "$1" "$2") || return 1
    curation_gh_api "$api" 2>/dev/null \
        | jq -e --arg p "$3" '[.tree[]? | select(.type == "blob" and .path == $p)] | length > 0' >/dev/null 2>&1
}

_curation_subpaths_resolve() {
    local repo="$1" ref="$2" subpaths="$3" api body paths sp sps=() missing=0
    api=$(_curation_trees_api "$repo" "$ref") || return 1
    body=$(curation_gh_api "$api" 2>/dev/null) || return 1
    printf '%s' "$body" | jq -e '.tree | type == "array"' >/dev/null 2>&1 || return 1
    paths=$(printf '%s' "$body" | jq -r '.tree[]? | .path')
    IFS='+' read -ra sps < <(printf '%s' "$subpaths") || true
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
    local reasons=() text r doc detail_lost=0 archive_entries=0
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
    #
    # A doc that is THERE but unreadable (rc 2) never falls back: the fallback
    # exists for a repo that simply has no SKILL.md, and using it here would
    # scan a neighbouring file and report the skill clean while its own doc went
    # unread — and the doc big enough to be undeliverable is exactly the one
    # worth hiding something in. It records the reason and the screen CARRIES ON
    # to the exec surface: the flag is not the job, showing the reviewer what is
    # in the repo is, and returning here would hand them a verdict that claims
    # detailComplete over a run that scanned nothing.
    local frc
    if [ -z "$subpaths" ]; then
        local got=1
        for doc in SKILL.md README.md; do
            text=$(_curation_fetch_one "$repo" "$ref" "$doc"); frc=$?
            if [ "$frc" -eq 2 ]; then
                # A doc WAS located, so this is not content-unfetchable.
                reasons+=("doc-unreadable")
                got=0
                break
            fi
            if [ "$frc" -eq 0 ]; then
                _curation_screen_scan "$doc" < <(printf '%s\n' "$text")
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
        IFS='+' read -ra sps < <(printf '%s' "$subpaths") || true
        local sp_got
        for sp in "${sps[@]}"; do
            [ -n "$sp" ] || continue
            sp_got=1
            for doc in "$sp/SKILL.md" "$sp/README.md"; do
                text=$(_curation_fetch_one "$repo" "$ref" "$doc"); frc=$?
                if [ "$frc" -eq 2 ]; then
                    reasons+=("doc-unreadable")
                    sp_got=0
                    break
                fi
                if [ "$frc" -eq 0 ]; then
                    _curation_screen_scan "$doc" < <(printf '%s\n' "$text")
                    sp_got=0
                    break
                fi
            done
            # Neither doc could be fetched although the tree lists the skill's
            # SKILL.md: the skill was not scanned. Silence here let a later
            # successful fetch (discovery's dossier) hand the judge a skill body
            # no screen had read. An outage, not a finding. (A collection root
            # such as `skills`, with no SKILL.md of its own, is not this case.)
            if [ "$sp_got" -ne 0 ] && _curation_tree_has "$repo" "$ref" "$sp/SKILL.md"; then
                reasons+=("content-unfetchable")
            fi
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
            if printf '%s' "$path" | LC_ALL=C grep -qiE "$_CURATION_ARCHIVE_RE"; then
                _curation_scan_archive "$path"
            elif ftext=$(_curation_fetch_one "$repo" "$ref" "$path"); then
                _curation_screen_scan "$path" < <(printf '%s\n' "$ftext")
                # A file whose bytes hold an archive (an extensionless zip, a
                # zipapp behind a shebang, a makeself installer): its text scan
                # saw compressed bytes, so read the archive too.
                if printf '%s' "$ftext" | LC_ALL=C grep -qaE "$_CURATION_EMBEDDED_RE"; then
                    _curation_scan_archive "$path" embedded
                fi
                # The commands a JSON config declares, rebuilt one per line, are
                # scanned apart: they exist nowhere in the file, so no line number.
                case "$path" in
                    *.json) _curation_screen_scan "$path" joined < <(printf '%s' "$ftext" | _curation_json_commands) ;;
                esac
            else
                # A listed exec file we cannot read → fail safe.
                reasons+=("exec-file-unfetchable")
            fi
            # Process substitution, not a here-string (no temp file) and not a
            # pipe (the loop must stay in THIS shell — `reasons` is the verdict).
        done < <(printf '%s\n' "$surface")
    fi

    # 2b. Every other config-like file (*.json, .jsonc, .json5, .toml, .yaml,
    # .yml), read for its SHAPE (#679): a config declares a server or a command
    # whatever its client names it. One that declares nothing runnable is data
    # (a package.json, a pyproject.toml, a CI workflow) and is not scanned; one
    # that cannot be read is a flag, as above. Their cap keeps its first name,
    # json-surface-over-cap.
    local jsurface jrc jpath jtext tjson trc
    jsurface=$(_curation_list_exec_surface "$repo" "$ref" "$subpaths" json); jrc=$?
    if [ "$jrc" -eq 1 ]; then
        reasons+=("exec-surface-unfetchable")
    else
        [ "$jrc" -eq 3 ] && reasons+=("exec-surface-truncated")
        [ "$jrc" -eq 4 ] && reasons+=("json-surface-over-cap")
        while IFS= read -r jpath; do
            [ -n "$jpath" ] || continue
            if jtext=$(_curation_fetch_one "$repo" "$ref" "$jpath") \
                || jtext=$(_curation_fetch_blob "$repo" "$ref" "$jpath"); then
                case "${jpath,,}" in
                    *.yaml | *.yml)
                        _curation_yaml_is_config "$jtext" || continue
                        # Its text is scanned, but a command split from its
                        # args or folded over lines is not rebuilt: review.
                        reasons+=("yaml-config-unparsed")
                        _curation_screen_scan "$jpath" < <(printf '%s\n' "$jtext")
                        ;;
                    *.toml)
                        tjson=$(printf '%s' "$jtext" | _curation_toml_json); trc=$?
                        if [ "$trc" -eq 0 ]; then
                            printf '%s' "$tjson" | _curation_json_is_config || continue
                            _curation_screen_scan "$jpath" < <(printf '%s\n' "$jtext")
                            _curation_screen_scan "$jpath" joined < <(printf '%s' "$tjson" | _curation_json_commands)
                        else
                            # Unparsed: its shape cannot be ruled out, so scan the
                            # text. A reader that could not run is an outage; a
                            # rejected file that may declare a command, a review.
                            if [ "$trc" -ne 1 ]; then
                                reasons+=("toml-unreadable")
                            elif _curation_toml_text_is_config "$jtext"; then
                                reasons+=("toml-config-unparsed")
                            fi
                            _curation_screen_scan "$jpath" < <(printf '%s\n' "$jtext")
                        fi
                        ;;
                    *)
                        printf '%s' "$jtext" | _curation_json_is_config || continue
                        _curation_screen_scan "$jpath" < <(printf '%s\n' "$jtext")
                        _curation_screen_scan "$jpath" joined < <(printf '%s' "$jtext" | _curation_json_commands)
                        ;;
                esac
            else
                reasons+=("exec-file-unfetchable")
            fi
        done < <(printf '%s\n' "$jsurface")
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
# file text and as a rebuilt command. A rebuilt command is dropped only against a
# raw line that DECLARES it (parsed, the line yields that command), one per
# declaration: a line merely quoting the text — a planted note — never hides it.
# A cut line is never parsed: its prefix could declare a shorter command.
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
        "$_CURATION_JQ_COMMANDS"'
         def declared: sub("[[:space:],]+$"; "") as $l
            | [(try ($l | fromjson) catch null), (try ("{" + $l + "}" | fromjson) catch null)]
            | map(select(. != null) | [commands]) | first // [];
         def dedup: reduce .[] as $x ({seen: {}, out: []};
                  ([$x.path, $x.category, ($x.lineNumber // "j\($x.joinedIndex)")] | tojson) as $k
                  | if .seen[$k] then . else .seen[$k] = true | .out += [$x] end)
            | .out
            | (reduce (.[] | select(.joinedCommand != true and .lineTruncated != true)
                      | . as $r | .line | declared[] | [$r.path, $r.category, .] | tojson) as $k
                  ({}; .[$k] += 1)) as $covered
            | reduce .[] as $x ({left: $covered, out: []};
                  ([$x.path, $x.category, $x.line] | tojson) as $k
                  | if $x.joinedCommand == true and (.left[$k] // 0) > 0
                    then .left[$k] -= 1 else .out += [$x] end)
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
