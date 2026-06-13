#!/usr/bin/env bash
# =============================================================================
# curation-safety.sh — pin-time integrity screen for the marketplace curation
# engine (Slice 3b, specs/marketplace-curation-engine). EF-006 / US-4.
#
# A DETERMINISTIC, LLM-free scan of a candidate skill's OWN content for
# obviously-dangerous instructions — kept STRICTLY SEPARATE from the trust
# criterion (popularity ≠ safety). It exists to gate the engine's only automated
# action: an auto-draft re-pin. A clean screen lets the re-pin auto-draft; a flag
# demotes it to propose-only (the human re-screens via the digest). It never
# auto-installs and never copies third-party content (EF-010) — it only reads.
#
# Fail-safe (EF-012): content that cannot be fetched is conservatively FLAGGED
# (reason "content-unfetchable"), never silently passed — "can't confirm safe"
# is treated as "not safe to auto-pin".
#
# API:  curation_safety_screen <owner/repo> <ref>
#   stdout: one JSON object {repo, ref, verdict:"pass"|"flag", reasons[]}
#   exit:   0 always (a verdict is always produced; failures become a flag).
# =============================================================================

_SAFETY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/curation-common.sh
source "$_SAFETY_DIR/curation-common.sh"

# _curation_b64decode — decode base64 from stdin, portable across GNU (`-d` /
# `--decode`) and BSD/macOS (`-D`). GitHub wraps contents in newlines, which all
# variants tolerate. The decoder's exit status is PROPAGATED (no blanket
# swallow): a decode that fails must be visible to the caller so it can fail safe
# rather than treat undecodable bytes as "empty = clean".
_curation_b64decode() {
    if printf '' | base64 --decode >/dev/null 2>&1; then
        base64 --decode 2>/dev/null
    else
        base64 -D 2>/dev/null
    fi
}

# _curation_fetch_content <repo> <ref> — echo the decoded text of the skill's
# primary doc (SKILL.md, else README.md) at <ref>; return non-zero if neither is
# fetchable OR decodable. Uses the contents API (base64 body), so it is mockable
# offline. A present-but-undecodable / empty-after-decode body is treated as NOT
# fetched (fall through, ultimately → content-unfetchable) — never as clean text,
# so corrupt base64 or a wrong-decoder pick fails SAFE instead of false-passing.
_curation_fetch_content() {
    local repo="$1" ref="$2" file body content decoded
    for file in SKILL.md README.md; do
        if body=$(curation_gh_api "repos/$repo/contents/$file?ref=$ref" 2>/dev/null); then
            content=$(printf '%s' "$body" | jq -r '.content // empty' 2>/dev/null)
            [ -n "$content" ] || continue
            decoded=$(printf '%s' "$content" | _curation_b64decode) || continue
            [ -n "$decoded" ] || continue
            printf '%s' "$decoded"
            return 0
        fi
    done
    return 1
}

# curation_safety_screen <owner/repo> <ref>
curation_safety_screen() {
    local repo="$1" ref="$2"
    local reasons=() verdict="pass"
    local text

    if ! text=$(_curation_fetch_content "$repo" "$ref"); then
        reasons+=("content-unfetchable")
        verdict="flag"
        _curation_safety_emit "$repo" "$ref" "$verdict" "${reasons[@]}"
        return 0
    fi

    # High-signal, deterministic danger patterns. Each is a category, not a guess
    # — they describe instructions that would run hostile code in a user's
    # session, not merely "suspicious" prose. Case-insensitive.
    #   remote-exec     — piping a downloaded payload straight into a shell
    #   obfuscated-exec — decoding base64 and executing the result
    #   destructive-rm  — recursive force-delete of a root/home path
    #   prompt-injection— overriding the operator's / system instructions
    # remote-exec — a downloaded payload reaching a shell. Match the fetcher and
    # the shell by CO-OCCURRENCE on a line (any intermediate pipe stage such as
    # `curl … | tar xz | sh` no longer breaks it), plus the common
    # process-substitution / command-substitution installer forms.
    grep -Eiq '(curl|wget).*\|[[:space:]]*(sudo[[:space:]]+)?(sh|bash|zsh)\b' <<<"$text" \
        && reasons+=("remote-exec")
    grep -Eiq '(sh|bash|zsh)[[:space:]]+(-[a-z]+[[:space:]]+)*(-c[[:space:]]+)?["'"'"']?[$<]\(?(curl|wget)' <<<"$text" \
        && [[ ! " ${reasons[*]-} " == *" remote-exec "* ]] && reasons+=("remote-exec")
    # obfuscated-exec — decode (base64/xxd) then execute.
    grep -Eiq '(base64|xxd)[^|]*(--decode|-d|-D|-r)?[^|]*\|.*\b(sudo[[:space:]]+)?(sh|bash|zsh)\b' <<<"$text" \
        && reasons+=("obfuscated-exec")
    # destructive-rm — recursive+force delete of a root/home path, EITHER flag
    # order (-rf / -fr / -r -f / --recursive --force).
    grep -Eiq 'rm[[:space:]]+(-[a-z]*(rf|fr)[a-z]*|-[rf][[:space:]]+-[rf]|--recursive[[:space:]]+--force|--force[[:space:]]+--recursive)[[:space:]]+(/|~|\$\{?HOME)' <<<"$text" \
        && reasons+=("destructive-rm")
    # prompt-injection — overriding the operator's / system instructions. Requires
    # a directional qualifier (previous/prior/above) for the instructions branch,
    # or an explicit "system prompt", so benign prose ("ignore the lint
    # instructions") does not trip it. Singular/plural + qualifier widened.
    grep -Eiq 'ignore[[:space:]]+(all|the|any|your)?[[:space:]]*(previous|prior|above)[[:space:]]+(system[[:space:]]+)?instructions?|ignore[[:space:]]+(the|your)?[[:space:]]*system[[:space:]]+prompt|disregard[[:space:]]+(the|your)?[[:space:]]*(system[[:space:]]+)?(prompt|instructions?)' <<<"$text" \
        && reasons+=("prompt-injection")

    if [ "${#reasons[@]}" -gt 0 ]; then
        verdict="flag"
    else
        reasons+=("clean")
    fi
    _curation_safety_emit "$repo" "$ref" "$verdict" "${reasons[@]}"
    return 0
}

# _curation_safety_emit <repo> <ref> <verdict> <reason...>
_curation_safety_emit() {
    local repo="$1" ref="$2" verdict="$3"; shift 3
    jq -cn --arg repo "$repo" --arg ref "$ref" --arg verdict "$verdict" \
        '{repo:$repo, ref:$ref, verdict:$verdict, reasons:$ARGS.positional}' \
        --args "$@"
}

# CLI: curation-safety.sh <owner/repo> <ref>
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    set -u
    [ $# -eq 2 ] || { echo "Usage: $(basename "$0") <owner/repo> <ref>" >&2; exit 2; }
    curation_safety_screen "$1" "$2"
    exit $?
fi
