#!/usr/bin/env bash
# =============================================================================
# trust-score.sh — deterministic community-trust scorer (Slice 2,
# specs/marketplace-curation-engine). NO LLM. Public signals only (EF-002):
# stars / forks / pushed_at / archived / license. Two-track (EF-003): authority
# applies no popularity bar; community applies the global bar from
# .claude/curation/trust-thresholds.json.
#
# API:  trust_score <owner/repo> <authority|community>
#   stdout: one JSON object {repo,track,stars,forks,pushedAt,ageDays,archived,
#           license,verdict,reasons[]}
#   exit:   0 = a verdict was computed (pass|flag|fail)
#           2 = usage error (bad track)
#           3 = operational error (gh unavailable) — emits {verdict:"error"};
#               callers FAIL SAFE (report, never silently pass/fail) per EF-012.
# =============================================================================

_TS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/curation-common.sh
source "$_TS_DIR/curation-common.sh"

CURATION_THRESHOLDS="${CURATION_THRESHOLDS:-$_TS_DIR/../../.claude/curation/trust-thresholds.json}"

# _ts_rank <verdict> — severity rank so a verdict can only ever be RAISED:
# pass(0) < flag(1) < fail(2).
_ts_rank() {
    case "$1" in
        fail) echo 2 ;;
        flag) echo 1 ;;
        *)    echo 0 ;;
    esac
}

# trust_score <owner/repo> <track>
trust_score() {
    local repo="$1" track="$2"

    case "$track" in
        authority|community) ;;
        *) curation_warn "trust_score: track must be 'authority' or 'community' (got '$track')"; return 2 ;;
    esac

    if [ ! -f "$CURATION_THRESHOLDS" ]; then
        curation_warn "trust_score: thresholds file not found: $CURATION_THRESHOLDS"
        return 3
    fi

    local json
    if ! json=$(curation_gh_api "repos/$repo"); then
        # Fail safe: report an operational error, never a silent pass/fail.
        jq -cn --arg repo "$repo" --arg track "$track" \
            '{repo:$repo, track:$track, verdict:"error", reasons:["gh-unavailable"]}'
        return 3
    fi

    # Numeric fields are coerced through jq `numbers` so a malformed/garbled gh
    # payload (non-int where an int is expected) becomes 0 rather than crashing
    # the `[ -lt ]` tests or the final --argjson emit — i.e. we fail CLOSED
    # (a 0-star community repo fails the bar), never fail OPEN with empty output.
    local stars forks pushed archived license
    stars=$(printf '%s' "$json" | jq -r '(.stargazers_count | numbers) // 0')
    forks=$(printf '%s' "$json" | jq -r '(.forks_count | numbers) // 0')
    pushed=$(printf '%s' "$json" | jq -r '.pushed_at // ""')
    archived=$(printf '%s' "$json" | jq -r 'if .archived == true then "true" else "false" end')
    license=$(printf '%s' "$json" | jq -r '.license.spdx_id // "NONE"')

    # Thresholds (numeric ones coerced too: a config typo must not silently drop
    # a bar — it falls back to the documented default).
    local reject_archived max_stale missing_lic_verdict applies_bar min_stars
    reject_archived=$(jq -r '.global.rejectArchived // true' "$CURATION_THRESHOLDS")
    max_stale=$(jq -r '(.global.maxStaleDays | numbers) // 365' "$CURATION_THRESHOLDS")
    missing_lic_verdict=$(jq -r '.global.missingLicenseVerdict // "flag"' "$CURATION_THRESHOLDS")
    applies_bar=$(jq -r ".tracks.${track}.appliesPopularityBar // false" "$CURATION_THRESHOLDS")
    min_stars=$(jq -r "(.tracks.${track}.minStars | numbers) // 0" "$CURATION_THRESHOLDS")

    # Recency: distinguish a real parse failure / missing date (a soft
    # "unknown-recency"/"bad-date" flag) from a future push (clock skew / fresh
    # mirror) — the latter is known-very-recent, so clamp it to 0, never flag it.
    local age_days recency_flag=""
    if [ -z "$pushed" ]; then
        age_days=-1; recency_flag="unknown-recency"
    elif ! age_days=$(curation_days_since "$pushed"); then
        age_days=-1; recency_flag="bad-date"
    elif [ "$age_days" -lt 0 ]; then
        age_days=0
    fi

    # Verdict: collect ALL applicable reasons; severity only ever rises
    # (pass < flag < fail), never drops.
    local verdict="pass"
    local reasons=()

    if [ "$archived" = "true" ] && [ "$reject_archived" = "true" ]; then
        verdict="fail"; reasons+=("archived")
    fi
    if [ -n "$recency_flag" ]; then
        [ "$verdict" = "pass" ] && verdict="flag"
        reasons+=("$recency_flag")
    elif [ "$age_days" -gt "$max_stale" ]; then
        verdict="fail"; reasons+=("stale:${age_days}d>${max_stale}d")
    fi
    if [ "$applies_bar" = "true" ] && [ "$stars" -lt "$min_stars" ]; then
        verdict="fail"; reasons+=("below-popularity-bar:${stars}<${min_stars}")
    fi

    # License is a soft signal (we point, never copy — EF-010). NOASSERTION means
    # a license file exists but GitHub couldn't classify it → treated as present
    # (it is simply not in the missing-license set below). Missing license RAISES
    # severity to missingLicenseVerdict but never lowers an existing fail/flag.
    case "$license" in
        ""|NONE|null)
            reasons+=("missing-license")
            if [ "$(_ts_rank "$missing_lic_verdict")" -gt "$(_ts_rank "$verdict")" ]; then
                verdict="$missing_lic_verdict"
            fi
            ;;
    esac

    [ "${#reasons[@]}" -eq 0 ] && reasons+=("clean")

    # NOTE: the jq filter must come BEFORE --args; everything after --args is
    # consumed as $ARGS.positional (the reasons list).
    jq -cn \
        --arg repo "$repo" --arg track "$track" \
        --argjson stars "$stars" --argjson forks "$forks" \
        --arg pushedAt "$pushed" --argjson ageDays "$age_days" \
        --argjson archived "$archived" --arg license "$license" \
        --arg verdict "$verdict" \
        '{repo:$repo, track:$track, stars:$stars, forks:$forks, pushedAt:$pushedAt,
          ageDays:$ageDays, archived:$archived, license:$license,
          verdict:$verdict, reasons:$ARGS.positional}' \
        --args "${reasons[@]}"

    return 0
}

# Allow running as a CLI: trust-score.sh <repo> <track>
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    set -u
    [ $# -eq 2 ] || { echo "Usage: $(basename "$0") <owner/repo> <authority|community>" >&2; exit 2; }
    trust_score "$1" "$2"
    exit $?
fi
