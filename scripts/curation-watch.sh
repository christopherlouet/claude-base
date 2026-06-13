#!/usr/bin/env bash
# =============================================================================
# curation-watch.sh — nightly rot-watch for the marketplace curation engine
# (Slice 3a, specs/marketplace-curation-engine). LLM-FREE → $0 tokens, immune to
# the 2026-06-15 agentic-billing change (EF-012). It re-verifies every recommended
# / pointed vendor skill and emits ONE reviewable digest per run.
#
# This 3a slice PRODUCES the digest only — it performs NO outbound gh mutation.
# The mix-output emission (re-pin draft-PR vs propose-only issue) and the
# sustained-collapse state live in Slice 3b + the deploy recipe (Slice 4).
#
# Per target it flags: archived / abandoned(stale) / below-popularity-bar /
# license change (all via trust-score.sh) and content-DRIFT (the repo's current
# good ref has moved beyond our pinnedRef → a newer version exists). gh failures
# are fail-safe: the target becomes an "error" finding, the run still completes.
#
# Usage:
#   curation-watch.sh [--dry-run] [--digest-dir DIR]
#                     [--registry FILE] [--presets-dir DIR] [--thresholds FILE]
#   --dry-run      do not write lastVerified back to the registry
#   --digest-dir   write digest.json + digest.md here (default: stdout JSON only)
#
# Exit: 0 = run completed (with or without findings); 2 = usage/setup error.
# =============================================================================

set -u

_WATCH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/curation-common.sh
source "$_WATCH_DIR/lib/curation-common.sh"
# shellcheck source=scripts/lib/trust-score.sh
source "$_WATCH_DIR/lib/trust-score.sh"

REGISTRY="${CURATION_REGISTRY:-$_WATCH_DIR/../.claude/curation/registry.json}"
PRESETS_DIR="${CURATION_PRESETS_DIR:-$_WATCH_DIR/../.claude/presets}"
DIGEST_DIR=""
DRY_RUN=false

while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run) DRY_RUN=true; shift ;;
        --digest-dir) DIGEST_DIR="${2:-}"; [ -n "$DIGEST_DIR" ] || { echo "--digest-dir requires a path" >&2; exit 2; }; shift 2 ;;
        --registry) REGISTRY="${2:-}"; [ -n "$REGISTRY" ] || { echo "--registry requires a path" >&2; exit 2; }; shift 2 ;;
        --presets-dir) PRESETS_DIR="${2:-}"; [ -n "$PRESETS_DIR" ] || { echo "--presets-dir requires a path" >&2; exit 2; }; shift 2 ;;
        --thresholds) export CURATION_THRESHOLDS="${2:-}"; shift 2 ;;
        -h|--help) sed -nE 's/^# ?//p' "$0" | sed -nE '/^curation-watch/,/^Exit/p'; exit 0 ;;
        *) echo "Unknown option: $1" >&2; exit 2 ;;
    esac
done

command -v jq >/dev/null 2>&1 || { echo "[ERROR] jq is required" >&2; exit 2; }
[ -f "$REGISTRY" ] || { echo "[ERROR] registry not found: $REGISTRY" >&2; exit 2; }

# _repo_root <vendorId-or-url> — the scoreable owner/repo (first two path
# segments), derived from a registry vendorId (owner/repo[/subpath…]) or a
# github.com URL. Echoes nothing for a non-github / non-repo identifier.
_repo_root() {
    local s="$1"
    case "$s" in
        https://github.com/*) s="${s#https://github.com/}" ;;
        http://github.com/*)  s="${s#http://github.com/}" ;;
        *://*) return 0 ;;  # some other URL (e.g. claude.com marketplace) → skip
    esac
    # take the first two slash-separated segments
    local owner="${s%%/*}"; local rest="${s#*/}"; local repo="${rest%%/*}"
    [ -n "$owner" ] && [ -n "$repo" ] && [ "$owner" != "$rest" ] && printf '%s/%s\n' "$owner" "$repo"
}

# collect_targets — emit unique {repoRoot,track,pinnedRef} JSON objects gathered
# from the registry records and every preset recommendation, deduped by
# (repoRoot,pinnedRef). gh is NOT called here.
collect_targets() {
    {
        jq -c '.records[] | {repoRoot:.vendorId, track:.trustTrack, pinnedRef:.pinnedRef}' "$REGISTRY"
        local f
        for f in "$PRESETS_DIR"/*.json; do
            [ -f "$f" ] || continue
            jq -c '.recommendedVendorSkills[]? | {repoRoot:(.url // .id), track:.trustTrack, pinnedRef:.pinnedRef}' "$f"
        done
    } | while IFS= read -r line; do
            local root track pin
            root=$(printf '%s' "$line" | jq -r '.repoRoot')
            root=$(_repo_root "$root")
            [ -n "$root" ] || continue
            track=$(printf '%s' "$line" | jq -r '.track')
            pin=$(printf '%s' "$line" | jq -r '.pinnedRef')
            jq -cn --arg r "$root" --arg t "$track" --arg p "$pin" '{repoRoot:$r, track:$t, pinnedRef:$p}'
        done | jq -s 'unique_by(.repoRoot + "@" + .pinnedRef)'
}

# resolve_current_ref <repo> <pinnedRef> — the repo's current good ref: a 40-hex
# pin compares against HEAD sha; a tag pin compares against the latest release
# tag (falling back to HEAD sha when the repo publishes no releases). Echoes the
# current ref, or nothing on gh failure.
resolve_current_ref() {
    local repo="$1" pinned="$2"
    if [[ "$pinned" =~ ^[0-9a-f]{40}$ ]]; then
        curation_gh_api "repos/$repo/commits/HEAD" | jq -r '.sha // empty'
        return
    fi
    local tag
    tag=$(curation_gh_api "repos/$repo/releases/latest" 2>/dev/null | jq -r '.tag_name // empty')
    if [ -n "$tag" ]; then
        printf '%s\n' "$tag"
    else
        curation_gh_api "repos/$repo/commits/HEAD" | jq -r '.sha // empty'
    fi
}

# watch_one <repoRoot> <track> <pinnedRef> — emit one finding JSON object.
watch_one() {
    local repo="$1" track="$2" pinned="$3"

    local score verdict
    if ! score=$(trust_score "$repo" "$track" 2>/dev/null); then
        # gh unavailable → fail-safe error finding; never abort the run.
        jq -cn --arg repo "$repo" --arg track "$track" --arg pinned "$pinned" \
            '{subject:$repo, track:$track, pinnedRef:$pinned, type:"error",
              verdict:"error", reasons:["gh-unavailable"], currentRef:null,
              proposedAction:"propose"}'
        return
    fi
    verdict=$(printf '%s' "$score" | jq -r '.verdict')

    local current drift="false"
    current=$(resolve_current_ref "$repo" "$pinned")
    if [ -n "$current" ] && [ "$current" != "$pinned" ]; then
        drift="true"
    fi

    # Classify. Only things that need a NEW action are surfaced (see the digest
    # filter): a hard-failing verdict is "rot"; an outdated pin is "drift". A soft
    # "flag" with no drift (e.g. a repo that simply has no license) is a STANDING,
    # already-recorded condition — it is typed "flag" and NOT re-surfaced every
    # run (that would be perpetual noise). Detecting a CHANGE to a soft signal
    # (license removed, popularity collapse) is state-based → Slice 3b.
    #   rot/error → propose-only (digest); drift+pass → re-pin (auto-draftable in 3b).
    local type action
    if [ "$verdict" = "fail" ]; then
        type="rot"; action="propose"
    elif [ "$drift" = "true" ]; then
        type="drift"; action=$([ "$verdict" = "pass" ] && echo "re-pin" || echo "propose")
    elif [ "$verdict" = "flag" ]; then
        type="flag"; action="none"
    else
        type="clean"; action="none"
    fi

    printf '%s' "$score" | jq -c \
        --arg pinned "$pinned" --arg current "${current:-}" \
        --arg type "$type" --arg drift "$drift" --arg action "$action" \
        '{subject:.repo, track:.track, pinnedRef:$pinned,
          currentRef:(if $current=="" then null else $current end),
          drift:($drift=="true"), type:$type, verdict:.verdict, reasons:.reasons,
          stars:.stars, license:.license, ageDays:.ageDays, proposedAction:$action}'
}

# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------
NOW=$(curation_now)
targets=$(collect_targets)
n_targets=$(printf '%s' "$targets" | jq 'length')

findings='[]'
i=0
while [ "$i" -lt "$n_targets" ]; do
    repo=$(printf '%s' "$targets" | jq -r ".[$i].repoRoot")
    track=$(printf '%s' "$targets" | jq -r ".[$i].track")
    pin=$(printf '%s' "$targets" | jq -r ".[$i].pinnedRef")
    finding=$(watch_one "$repo" "$track" "$pin")
    findings=$(printf '%s' "$findings" | jq -c --argjson f "$finding" '. + [$f]')
    i=$((i + 1))
done

# Counts by type. Only actionable findings (rot / drift / error) are SURFACED to
# the operator; "clean" and standing "flag" conditions are counted but not
# re-alarmed each run (no-noise contract).
counts=$(printf '%s' "$findings" | jq -c 'group_by(.type) | map({(.[0].type): length}) | add // {}')
surfaced=$(printf '%s' "$findings" | jq -c '[.[] | select(.type == "rot" or .type == "drift" or .type == "error")]')
n_surfaced=$(printf '%s' "$surfaced" | jq 'length')

digest=$(jq -cn \
    --arg generatedAt "$NOW" --argjson targets "$n_targets" \
    --argjson counts "$counts" --argjson findings "$surfaced" \
    '{generatedAt:$generatedAt, scope:{targets:$targets}, counts:$counts,
      findingCount:($findings|length), findings:$findings}')

# Idempotent lastVerified update: stamp every scored registry record with NOW
# (the run happened, regardless of verdict). Skipped under --dry-run.
if [ "$DRY_RUN" = false ]; then
    tmp=$(mktemp)
    if jq --arg now "$NOW" '.records |= map(.lastVerified = $now)' "$REGISTRY" > "$tmp" 2>/dev/null; then
        mv "$tmp" "$REGISTRY"
    else
        rm -f "$tmp"; curation_warn "could not update lastVerified in $REGISTRY"
    fi
fi

# Emit the digest. Markdown form when a digest dir is given; JSON always.
render_markdown() {
    printf '# Curation digest — %s\n\n' "$NOW"
    printf -- '- Targets scored: **%s**\n- Findings: **%s**\n\n' "$n_targets" "$n_surfaced"
    if [ "$n_surfaced" -eq 0 ]; then
        printf 'No rot or drift detected. lastVerified refreshed.\n'
        return
    fi
    printf '| Subject | Type | Verdict | Pinned | Current | Action |\n'
    printf '|---|---|---|---|---|---|\n'
    printf '%s' "$surfaced" | jq -r '.[] |
        "| \(.subject) | \(.type) | \(.verdict) | \(.pinnedRef) | \(.currentRef // "?") | \(.proposedAction) |"'
}

if [ -n "$DIGEST_DIR" ]; then
    mkdir -p "$DIGEST_DIR"
    printf '%s\n' "$digest" > "$DIGEST_DIR/digest.json"
    render_markdown > "$DIGEST_DIR/digest.md"
    echo "[OK] digest written: $DIGEST_DIR/digest.json (+ digest.md) — $n_surfaced finding(s)"
else
    printf '%s\n' "$digest"
fi

exit 0
