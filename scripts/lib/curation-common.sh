#!/usr/bin/env bash
# =============================================================================
# curation-common.sh — shared helpers for the marketplace curation engine
# (specs/marketplace-curation-engine). Sourced by trust-score.sh (Slice 2) and
# curation-watch.sh (Slice 3).
#
# Design constraints:
#   - Deterministic & offline-testable: the "now" used for recency math is
#     overridable via CURATION_NOW (YYYY-MM-DD) so bats fixtures are stable.
#   - Portable date math: a pure-bash civil→days conversion avoids the GNU vs
#     BSD `date` incompatibility entirely (the repo runs on Linux + macOS).
#   - Fail-safe gh access: curation_gh_api retries with backoff and returns
#     non-zero (never hangs / never partial-succeeds silently) so callers can
#     report-and-stop.
# =============================================================================

# --- logging (stderr, non-fatal — a library must never exit its caller) ------
curation_warn() { printf 'curation: %s\n' "$1" >&2; }

# curation_now — reference date (YYYY-MM-DD). CURATION_NOW overrides it for
# deterministic tests; otherwise today's UTC date.
curation_now() {
    if [ -n "${CURATION_NOW:-}" ]; then
        printf '%s\n' "$CURATION_NOW"
    else
        date -u +%Y-%m-%d
    fi
}

# _civil_to_days <year> <month> <day> — days since 1970-01-01 (Howard Hinnant's
# days_from_civil). Pure integer arithmetic, no `date` dependency → identical on
# GNU and BSD. Handles leap years correctly.
_civil_to_days() {
    local y="$1" m="$2" d="$3"
    [ "$m" -le 2 ] && y=$((y - 1))
    local era yoe doy doe
    if [ "$y" -ge 0 ]; then era=$((y / 400)); else era=$(((y - 399) / 400)); fi
    yoe=$((y - era * 400))
    if [ "$m" -gt 2 ]; then doy=$(((153 * (m - 3) + 2) / 5 + d - 1)); else doy=$(((153 * (m + 9) + 2) / 5 + d - 1)); fi
    doe=$((yoe * 365 + yoe / 4 - yoe / 100 + doy))
    printf '%s\n' $((era * 146097 + doe - 719468))
}

# _date_to_days <date-or-timestamp> — accepts YYYY-MM-DD or an ISO-8601 stamp
# (e.g. 2026-04-28T07:24:36Z); echoes days-since-epoch, or returns 1 if the
# leading YYYY-MM-DD cannot be parsed.
_date_to_days() {
    local s="$1"
    [[ "$s" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2}) ]] || return 1
    # 10# forces base-10 so leading-zero months/days are not read as octal.
    _civil_to_days "$((10#${BASH_REMATCH[1]}))" "$((10#${BASH_REMATCH[2]}))" "$((10#${BASH_REMATCH[3]}))"
}

# curation_days_since <iso-timestamp> — whole days between the given date and
# curation_now (positive = in the past). Returns 1 on unparseable input.
curation_days_since() {
    local now_d then_days now_days
    then_days=$(_date_to_days "$1") || { curation_warn "unparseable date: $1"; return 1; }
    now_d=$(curation_now)
    now_days=$(_date_to_days "$now_d") || return 1
    printf '%s\n' $((now_days - then_days))
}

# curation_gh_api <api-path> — fail-safe `gh api` wrapper. Retries on transient
# failure with linear backoff. Echoes the JSON body on success (exit 0); on
# exhaustion echoes nothing and returns non-zero. Tunables (test-overridable):
#   CURATION_GH_RETRIES (default 3), CURATION_GH_BACKOFF seconds (default 2).
curation_gh_api() {
    local path="$1"
    local retries="${CURATION_GH_RETRIES:-3}"
    local backoff="${CURATION_GH_BACKOFF:-2}"
    command -v gh >/dev/null 2>&1 || { curation_warn "gh not found"; return 2; }
    local attempt=1 out
    while [ "$attempt" -le "$retries" ]; do
        if out=$(gh api "$path" 2>/dev/null); then
            printf '%s\n' "$out"
            return 0
        fi
        if [ "$attempt" -lt "$retries" ] && [ "$backoff" -gt 0 ]; then
            sleep "$((backoff * attempt))"
        fi
        attempt=$((attempt + 1))
    done
    curation_warn "gh api failed after ${retries} attempt(s): $path"
    return 1
}

# curation_b64decode — decode base64 from stdin, portable across GNU (`-d` /
# `--decode`) and BSD/macOS (`-D`). GitHub wraps contents/readme bodies in
# newlines, which all variants tolerate. The decoder's exit status is PROPAGATED
# (no blanket swallow): a decode that fails must be visible to the caller so it
# can fail safe rather than treat undecodable bytes as "empty = clean".
curation_b64decode() {
    if printf '' | base64 --decode >/dev/null 2>&1; then
        base64 --decode 2>/dev/null
    else
        base64 -D 2>/dev/null
    fi
}

# curation_finding_json — emit one normalized finding object for a digest
# (Slice 3 consumes these). Args: subject type evidence action.
curation_finding_json() {
    jq -cn \
        --arg subject "$1" --arg type "$2" --arg evidence "$3" --arg action "$4" \
        '{subject:$subject, type:$type, evidence:$evidence, action:$action}'
}
