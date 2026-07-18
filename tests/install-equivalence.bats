#!/usr/bin/env bats

# =============================================================================
# EF-007 (specs/agnostic-core/spec.md US-4): dry-run listing ≡ real install.
#
# For representative configs, the dry-run manifest ("[DRY-RUN] install …"
# lines) must describe EXACTLY the real installed tree, in both directions:
#   1. every file the real install writes is covered by a manifest entry
#      (exact file, under a dir/ entry, or under a SRC:DST remap) OR is one of
#      the documented transform artifacts (CLAUDE.md, .gitignore,
#      foundation.json, .mcp.*, git init, backups);
#   2. every manifest entry materializes in the real tree.
# A negative probe plants a divergence and asserts the comparison catches it.
# =============================================================================

load 'test_helper'

NEW_PROJECT_SCRIPT="$BATS_TEST_DIRNAME/../scripts/new-project.sh"

setup() {
    skip_if_no_jq
    setup_test_dir
}
teardown() { teardown_test_dir; }

# Transform artifacts and flag-driven installers: written by post-emit steps
# (CLAUDE.md rewrite, gitignore append, foundation manifest) or by the
# optional per-flag installers (ci/hooks/mcp/docker — out of the manifest
# scope per plan-p2.md). Never manifest entries.
_is_transform_artifact() {
    case "$1" in
        CLAUDE.md|CLAUDE.local.md.example|.gitignore) return 0 ;;
        .mcp.json|.mcp.json.example|.mcp.env.example) return 0 ;;
        .claude/foundation.json) return 0 ;;
        .git/*|.claude.backup.*/*) return 0 ;;
        .github/workflows/*|.husky/*) return 0 ;;
        .pre-commit-config.yaml|.lintstagedrc.json|.commitlintrc.json) return 0 ;;
        Dockerfile|.dockerignore|docker-compose*.yml) return 0 ;;
    esac
    return 1
}

# _manifest_covers <manifest-file> <relpath> — 0 if a manifest DST covers it.
_manifest_covers() {
    local manifest="$1" rel="$2" entry dst
    while IFS= read -r entry; do
        [ -z "$entry" ] && continue
        dst="$entry"
        case "$entry" in *:*) dst="${entry#*:}" ;; esac
        if [ "${dst%/}" = "$rel" ]; then return 0; fi
        case "$dst" in
            */) case "$rel" in "${dst%/}"/*) return 0 ;; esac ;;
        esac
    done < "$manifest"
    return 1
}

# _assert_equivalence <flags...> — run dry-run + real install with the same
# flags, compare both directions. Populates $TEST_DIR/{dry,real,manifest}.
_assert_equivalence() {
    mkdir -p "$TEST_DIR/real"
    # 1. Dry-run → manifest
    run "$NEW_PROJECT_SCRIPT" -y --dry-run "$@" "$TEST_DIR/real"
    [ "$status" -eq 0 ]
    printf '%s\n' "$output" | sed -n 's/^\[DRY-RUN\] install //p' > "$TEST_DIR/manifest"
    [ -s "$TEST_DIR/manifest" ]
    # Dry-run must have written nothing.
    [ ! -d "$TEST_DIR/real/.claude" ]

    # 2. Real install
    run "$NEW_PROJECT_SCRIPT" -y "$@" "$TEST_DIR/real"
    [ "$status" -eq 0 ]

    # 3a. Real tree ⊆ manifest ∪ transforms
    local uncovered="" rel
    while IFS= read -r rel; do
        rel="${rel#./}"
        _is_transform_artifact "$rel" && continue
        _manifest_covers "$TEST_DIR/manifest" "$rel" || uncovered="$uncovered $rel"
    done < <(cd "$TEST_DIR/real" && find . -type f | sed 's|^\./||')
    if [ -n "$uncovered" ]; then
        echo "installed but not in the dry-run manifest:$uncovered" >&2
        return 1
    fi

    # 3b. Every manifest entry materializes in the tree.
    local missing="" entry dst
    while IFS= read -r entry; do
        [ -z "$entry" ] && continue
        dst="$entry"
        case "$entry" in *:*) dst="${entry#*:}" ;; esac
        [ -e "$TEST_DIR/real/${dst%/}" ] || missing="$missing $dst"
    done < "$TEST_DIR/manifest"
    if [ -n "$missing" ]; then
        echo "in the dry-run manifest but not installed:$missing" >&2
        return 1
    fi
    return 0
}

@test "EF-007: dry-run ≡ real install (simple, generic)" {
    _assert_equivalence --simple
}

@test "EF-007: dry-run ≡ real install (preset with catalog+skill filters)" {
    _assert_equivalence --simple --preset nextjs
}

@test "EF-007: dry-run ≡ real install (second preset, different stack)" {
    _assert_equivalence --simple --preset fastapi
}

@test "EF-007 negative probe: a planted extra file IS flagged" {
    mkdir -p "$TEST_DIR/real"
    run "$NEW_PROJECT_SCRIPT" -y --dry-run --simple "$TEST_DIR/real"
    [ "$status" -eq 0 ]
    printf '%s\n' "$output" | sed -n 's/^\[DRY-RUN\] install //p' > "$TEST_DIR/manifest"
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR/real"
    [ "$status" -eq 0 ]
    # Plant a file the manifest does not know.
    touch "$TEST_DIR/real/.claude/commands/planted-divergence.md"
    run _manifest_covers "$TEST_DIR/manifest" ".claude/commands/planted-divergence.md"
    [ "$status" -ne 0 ]
}
