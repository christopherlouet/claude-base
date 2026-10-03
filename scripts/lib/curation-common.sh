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

# curation_stable_release <owner/repo> [<like-tag>] — a stable release tag (no
# draft, no prerelease), never the repo's "Latest" badge, which is its
# maintainer's choice (prisma/orm set it on another product line: v0.17.0 beside
# 7.10.0). Read only when the release list is unavailable.
#   no <like-tag> (discovery): the most recently PUBLISHED stable release.
#   with <like-tag> (watch): releases of the same SHAPE compete. The shape of a
#     package tag (`pkg@1.0.0`, `@scope/pkg@0.2.0`) is everything before its last
#     "@" (a digit in the name, vue2-lib@ vs vue3-lib@, never merges families);
#     of any other tag, the prefix before the first digit ("", "v"...).
#     - <like-tag> in the list: those published since it compete on VERSION
#       (ties: the more recently published) — a later backport (6.19.3 after
#       7.10.0) is not newer, an old mis-numbered v0.180.0 is out of the race.
#     - <like-tag> not in the list (older than the first page, or a bare git
#       tag): the most recently published of the shape — never "highest
#       version", which an old mis-numbered release would win.
#     - no release of the shape since the pin, but a newer one of another shape:
#       the repo changed its tag style (v1.0.0, then 2.0.0); that newer release
#       is returned so the change surfaces as drift. A repo still publishing in
#       the pin's shape (two product lines) never crosses, and package tags
#       (`pkg@`) never do: another family is another package, not a new style.
# Echoes the tag, or nothing.
curation_stable_release() {
    local repo="$1" like="${2:-}" shape="" list tag
    if [ -n "$like" ]; then
        if [[ "$like" == *@* ]]; then shape="${like%@*}@"; else shape="${like%%[0-9]*}"; fi
    fi
    if list=$(curation_gh_api "repos/$repo/releases?per_page=100" 2>/dev/null) \
        && printf '%s' "$list" | jq -e 'type == "array"' >/dev/null 2>&1; then
        printf '%s' "$list" | jq -r --arg like "$like" --arg s "$shape" '
            def shape: if test("@") then sub("@[^@]*$"; "") + "@" else sub("[0-9].*$"; "") end;
            def ver: (if test("@") then sub("^.*@"; "") else . end)
                     | sub("^[^0-9]*"; "") | [scan("[0-9]+") | tonumber];
            [ .[] | select(.draft == false and .prerelease == false and (.tag_name | type == "string"))
                  | .published_at |= (. // "") ] as $st
            | if $like == "" then
                ($st | max_by(.published_at) | .tag_name) // empty
              else
                [ $st[] | select(.tag_name | shape == $s) ] as $same
                | (first($same[] | select(.tag_name == $like) | .published_at) // null) as $since
                | if $since == null then
                    ($same | max_by(.published_at) | .tag_name) // empty
                  else
                    [ $same[] | select(.published_at >= $since) ] as $cand
                    | [ $st[] | select(($s | test("@") | not) and (.tag_name | test("@") | not)
                                       and (.tag_name | shape) != $s and .published_at > $since) ] as $other
                    | if ($cand | map(select(.tag_name != $like)) | length) == 0 and ($other | length) > 0
                      then ($other | max_by(.published_at) | .tag_name)
                      else ($cand | max_by([(.tag_name | ver), .published_at]) | .tag_name) // empty
                      end
                  end
              end'
        return 0
    fi
    tag=$(curation_gh_api "repos/$repo/releases/latest" 2>/dev/null | jq -r '.tag_name // empty' 2>/dev/null)
    [ -n "$tag" ] || return 0
    if [ -n "$like" ]; then
        local tshape
        if [[ "$tag" == *@* ]]; then tshape="${tag%@*}@"; else tshape="${tag%%[0-9]*}"; fi
        [ "$tshape" = "$shape" ] || return 0
    fi
    printf '%s\n' "$tag"
}

# curation_finding_json — emit one normalized finding object for a digest
# (Slice 3 consumes these). Args: subject type evidence action.
curation_finding_json() {
    jq -cn \
        --arg subject "$1" --arg type "$2" --arg evidence "$3" --arg action "$4" \
        '{subject:$subject, type:$type, evidence:$evidence, action:$action}'
}
