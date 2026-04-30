#!/usr/bin/env bash
# =============================================================================
# create-tier-pr.sh — open a PR for a translated tier.
#
# Wraps `gh pr create` with a pre-filled body (checklist + spec links).
# Assumes the current branch is `migration-en/tier-N` and has commits.
#
# Usage:
#   create-tier-pr.sh --tier <N> [--draft] [--title <override>]
#
# Options:
#   --tier <N>      REQUIRED — 1, 2, 3, or 4
#   --draft         Open as draft (default for tiers 2, 3, 4; tier 1 = ready)
#   --title <s>     Override the auto-generated title
#   -h, --help
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SPEC_DIR="$REPO_ROOT/specs/migration-fr-en"

TIER=""
DRAFT=""
TITLE_OVERRIDE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --tier) TIER="$2"; shift 2 ;;
        --draft) DRAFT="--draft"; shift ;;
        --title) TITLE_OVERRIDE="$2"; shift 2 ;;
        -h|--help) head -16 "$0" | tail -15; exit 0 ;;
        *) echo "Unknown arg: $1" >&2; exit 2 ;;
    esac
done

[[ -z "$TIER" ]] && { echo "--tier is required" >&2; exit 2; }
case "$TIER" in 1|2|3|4) ;; *) echo "--tier must be 1, 2, 3, or 4" >&2; exit 2 ;; esac

command -v gh >/dev/null 2>&1 || { echo "gh CLI is required" >&2; exit 2; }

cd "$REPO_ROOT"

# -----------------------------------------------------------------------------
# Pre-flight checks
# -----------------------------------------------------------------------------
current_branch=$(git rev-parse --abbrev-ref HEAD)
expected_branch="migration-en/tier-$TIER"

if [[ "$current_branch" != "$expected_branch" ]]; then
    echo "WARN: current branch is '$current_branch', expected '$expected_branch'." >&2
    read -rp "Continue anyway? [y/N] " confirm
    [[ "$confirm" != "y" && "$confirm" != "Y" ]] && exit 1
fi

# Ensure branch is pushed
if ! git ls-remote --exit-code origin "$current_branch" >/dev/null 2>&1; then
    echo "[create-tier-pr] Pushing branch to origin..."
    git push --set-upstream origin "$current_branch"
fi

# -----------------------------------------------------------------------------
# Default for --draft (tiers 2, 3, 4 default to draft)
# -----------------------------------------------------------------------------
if [[ -z "$DRAFT" && "$TIER" != "1" ]]; then
    DRAFT="--draft"
fi

# -----------------------------------------------------------------------------
# Tier-specific titles and descriptions
# -----------------------------------------------------------------------------
case "$TIER" in
    1) scope_label="showcase + rules (README, CLAUDE.md, docs/guides, docs/reference, .claude/rules)" ;;
    2) scope_label="agents + commands (.claude/agents, .claude/commands)" ;;
    3) scope_label="skills + hooks (.claude/skills, scripts/hooks)" ;;
    4) scope_label="website hand-maintained docs (intro, guides, reference, concepts, workflow, tutorials, examples)" ;;
esac

title="${TITLE_OVERRIDE:-feat(migration): translate tier $TIER to English ($scope_label)}"

# -----------------------------------------------------------------------------
# Body
# -----------------------------------------------------------------------------
state_file="$SPEC_DIR/state-tier-$TIER.json"
files_summary="see state file"
words_count="see inventory"
if [[ -f "$state_file" ]] && command -v jq >/dev/null 2>&1; then
    total=$(jq '.files | length' "$state_file")
    drafts=$(jq '[.files[] | select(.status == "draft")] | length' "$state_file")
    files_summary="$drafts of $total translated"
fi
if [[ -f "$SPEC_DIR/inventory.json" ]] && command -v jq >/dev/null 2>&1; then
    words_count=$(jq -r ".tiers[\"$TIER\"].words" "$SPEC_DIR/inventory.json")
fi

# Tier-specific body section
case "$TIER" in
    1)
        tier_section=$(cat <<'EOF'
This is the **showcase tier** — the most visible content (README, CLAUDE.md, top-level guides, rules). It MUST be reviewed before merge per the hybrid method D defined in `specs/migration-fr-en/spec.md` §8.5.

### Hybrid review checklist (T024)

- [ ] **Full read**: README.md (~30 min)
- [ ] **Full read**: CLAUDE.md (~20 min)
- [ ] **Full read**: 1 major guide (PROMPTING-GUIDE.md or equivalent)
- [ ] **Quick scan**: titles + intros + conclusions on remaining guides
- [ ] **Spot-checks**: 3-4 random rules out of 31

### After this PR merges (T025)

Run `scripts/migration/lock-glossary.sh` to lock the glossary before launching Tier 2.
EOF
        )
        ;;
    *)
        tier_section=$(cat <<'EOF'
This is a **draft PR** — opened during the headless overnight run, awaiting morning sampling.

### Sampling checklist

- [ ] 5-10 random files reviewed for quality
- [ ] Glossary stability verified (no drift since lock)
- [ ] No broken refs (validators green in CI)
EOF
        )
        ;;
esac

body=$(cat <<EOF
## Summary

Translates **tier $TIER** of the FR→EN migration to English.

**Scope**: $scope_label
**Volume**: $files_summary, ~$words_count words

This is part of the planned 4-tier migration described in \`specs/migration-fr-en/\`.

## Tier $TIER specifics

$tier_section

## Validation

- [ ] CI green (\`bats tests/migration/*.bats\` and \`scripts/validate-counts.sh --mixed\`)
- [ ] No broken references (\`scripts/migration/check-refs.sh\` per file)
- [ ] No structural drift (\`scripts/migration/check-structure.sh\`)
- [ ] No glossary drift (\`scripts/migration/check-glossary.sh --detect-drift\`)

## Recovery

If validation fails on some files, the migration harness keeps a backup of each file's source via git history. To roll back a single file: \`git checkout main -- <path>\`.

## Related

- Spec: \`specs/migration-fr-en/spec.md\`
- Plan: \`specs/migration-fr-en/plan.md\`
- Tasks: \`specs/migration-fr-en/tasks.md\`
- Journal: \`specs/migration-fr-en/journal.md\`
EOF
)

# -----------------------------------------------------------------------------
# Create PR
# -----------------------------------------------------------------------------
echo "[create-tier-pr] Creating PR for tier $TIER on branch $current_branch..."
echo "[create-tier-pr] Title: $title"
[[ -n "$DRAFT" ]] && echo "[create-tier-pr] Mode: draft"

# shellcheck disable=SC2086
gh pr create \
    --title "$title" \
    --body "$body" \
    --base main \
    --head "$current_branch" \
    $DRAFT
