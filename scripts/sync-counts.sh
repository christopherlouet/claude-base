#!/usr/bin/env bash
# =============================================================================
# sync-counts.sh — keep derived count artifacts in sync and stage them, so a
# stale count can NEVER be committed. Kills the recurring CI "counts gate"
# failure (add a test / command / agent → forget to regenerate → CI red).
#
# It MIRRORS the CI "Counts gate" exactly: regenerate, then look at the SAME
# derived path set the CI diffs. The CI list is the single source of truth; keep
# the two in lock-step.
#
# Modes:
#   (default)  HEAL — regenerate; if that produced derived changes, `git add`
#              them so the in-flight commit carries fresh counts.
#   --check    READ-ONLY — delegate to validate-counts.sh; never regenerate or
#              stage. Exit reflects whether counts are consistent (CI / test use).
#   --quiet    suppress the informational line.
#
# Exit 0 : counts consistent (already, or regenerated + staged).
# Exit 1 : drift remains and could not be auto-resolved (inspect manually).
# Exit 2 : usage error.
#
# Test seams (env overrides; production defaults are the real repo values):
#   SYNC_COUNTS_ROOT       repo root (default: this script's parent dir)
#   SYNC_COUNTS_PATHS      space-separated derived paths (default: the CI set)
#   SYNC_COUNTS_REGEN_CMD  regenerate command (default: npm --prefix website run generate)
#   SYNC_COUNTS_CHECK_CMD  read-only validator (default: scripts/validate-counts.sh)
# =============================================================================

set -euo pipefail

ROOT="${SYNC_COUNTS_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Derived paths the CI "Counts gate" diffs — KEEP IN SYNC with .github/workflows/ci.yml.
if [ -n "${SYNC_COUNTS_PATHS:-}" ]; then
    # shellcheck disable=SC2206  # intentional word-split of the override
    DERIVED_PATHS=( ${SYNC_COUNTS_PATHS} )
else
    DERIVED_PATHS=( counts.json README.md CLAUDE.md docs/ website/docs/ \
        website/sidebars.ts website/docusaurus.config.ts website/src/ )
fi

REGEN_CMD="${SYNC_COUNTS_REGEN_CMD:-npm --prefix website run generate}"
CHECK_CMD="${SYNC_COUNTS_CHECK_CMD:-$ROOT/scripts/validate-counts.sh}"

MODE=heal
QUIET=0
while [ $# -gt 0 ]; do
    case "$1" in
        --check) MODE=check; shift ;;
        --quiet) QUIET=1; shift ;;
        -h|--help) sed -nE 's/^# ?//p' "$0" | sed -nE '/^sync-counts/,/^Exit 2/p'; exit 0 ;;
        *) echo "sync-counts: unknown option: $1" >&2; exit 2 ;;
    esac
done

cd "$ROOT"
say() { [ "$QUIET" = 1 ] || echo "$@"; }

# READ-ONLY check: no regeneration, no staging — just the canonical validator.
if [ "$MODE" = check ]; then
    "$CHECK_CMD" >/dev/null 2>&1 && { say "counts: in sync"; exit 0; }
    echo "sync-counts: counts are out of sync (run: $REGEN_CMD)" >&2
    exit 1
fi

# HEAL: regenerate, then stage whatever derived files moved.
if ! bash -c "$REGEN_CMD" >/dev/null 2>&1; then
    # Cannot regenerate (e.g. website deps / node absent). Do not silently let
    # drift through, but do not block a clean commit either: fall back to the
    # read-only validator.
    if "$CHECK_CMD" >/dev/null 2>&1; then
        say "counts: in sync (regen skipped — tooling unavailable)"
        exit 0
    fi
    echo "sync-counts: counts drifted but regeneration failed." >&2
    echo "  Install website deps and run: $REGEN_CMD" >&2
    exit 1
fi

# Regen succeeded. If it left no unstaged derived changes, counts were already
# correct (or the user had already staged the fresh output) → nothing to do.
if git diff --quiet -- "${DERIVED_PATHS[@]}" 2>/dev/null; then
    say "counts: already in sync"
    exit 0
fi

git add -- "${DERIVED_PATHS[@]}" 2>/dev/null || true
# Always reported (even under --quiet): this MUTATED the in-flight commit.
echo "counts: regenerated and staged (derived artifacts were stale)"
exit 0
