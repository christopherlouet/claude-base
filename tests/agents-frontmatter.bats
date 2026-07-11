#!/usr/bin/env bats

# =============================================================================
# Structural coherence of .claude/agents/*.md frontmatter.
#
# Born from the 2026-07-11 full-project analysis: 6 WRITER agents (doc-generate,
# doc-changelog, biz-mvp, biz-personas, legal-privacy-policy,
# legal-terms-of-service) shipped with `permissionMode: plan` (read-only) while
# granting Edit/Write and instructing file creation — every downstream install
# got agents that silently cannot do their stated job. These guards make that
# contradiction class impossible to reintroduce.
# =============================================================================

load 'test_helper'

AGENTS_DIR="$BATS_TEST_DIRNAME/../.claude/agents"

@test "agents: plan-mode agents must not carry write tools (Edit/Write/NotebookEdit)" {
    local bad=""
    for f in "$AGENTS_DIR"/*.md; do
        grep -qE '^permissionMode:[[:space:]]*plan[[:space:]]*$' "$f" || continue
        local tools
        tools=$(grep -m1 '^tools:' "$f" || true)
        case "$tools" in
            *Edit*|*Write*|*NotebookEdit*) bad+="$(basename "$f"): $tools"$'\n' ;;
        esac
    done
    if [ -n "$bad" ]; then
        echo "plan-mode agents with write tools (read-only mode blocks their own job):"
        echo "$bad"
        return 1
    fi
}

@test "agents: every declared permissionMode is a known value" {
    local bad=""
    while IFS=: read -r f _ mode; do
        mode=$(printf '%s' "$mode" | tr -d '[:space:]')
        case "$mode" in
            default|plan|acceptEdits|bypassPermissions) : ;;
            *) bad+="$(basename "$f"): '$mode'"$'\n' ;;
        esac
    done < <(grep -H '^permissionMode:' "$AGENTS_DIR"/*.md)
    if [ -n "$bad" ]; then
        echo "unknown permissionMode values:"
        echo "$bad"
        return 1
    fi
}
