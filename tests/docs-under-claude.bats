#!/usr/bin/env bats

# =============================================================================
# US1 — Install simple places foundation docs under .claude/docs/
# Spec: specs/docs-under-claude/spec.md (US1, P1, MVP)
# =============================================================================

load 'test_helper'

NEW_PROJECT_SCRIPT="$BATS_TEST_DIRNAME/../scripts/new-project.sh"
UPDATE_SCRIPT="$BATS_TEST_DIRNAME/../scripts/update.sh"

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# -----------------------------------------------------------------------------
# T004 — Reference docs land under .claude/docs/reference/
# -----------------------------------------------------------------------------

@test "[US1] --simple creates .claude/docs/reference/ with multiple files" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.claude/docs/reference" ]

    local count
    count=$(find "$TEST_DIR/.claude/docs/reference" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -ge 7 ]
}

@test "[US1] --simple creates .claude/docs/guides/ with multiple files" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -d "$TEST_DIR/.claude/docs/guides" ]

    # After consolidating stack guides into STACK-RECIPES.md, 4 specific
    # guides remain (EXTENDING, TEAM, PROMPTING, TROUBLESHOOTING).
    local count
    count=$(find "$TEST_DIR/.claude/docs/guides" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -ge 4 ]
}

# -----------------------------------------------------------------------------
# T005 — No foundation pollution under user's docs/
# -----------------------------------------------------------------------------

@test "[US1] --simple does NOT create docs/reference/ in target" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ ! -d "$TEST_DIR/docs/reference" ]
}

@test "[US1] --simple does NOT create docs/guides/ in target" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ ! -d "$TEST_DIR/docs/guides" ]
}

@test "[US1] --simple does NOT install docs/ARCHITECTURE.md from foundation" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ ! -f "$TEST_DIR/docs/ARCHITECTURE.md" ]
    [ ! -f "$TEST_DIR/.claude/docs/ARCHITECTURE.md" ]
}

@test "[US1] --simple does NOT install docs/WORKFLOWS.md from foundation" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ ! -f "$TEST_DIR/docs/WORKFLOWS.md" ]
    [ ! -f "$TEST_DIR/.claude/docs/WORKFLOWS.md" ]
}

# -----------------------------------------------------------------------------
# T006 — CLAUDE.md @imports rewritten to .claude/docs/
# -----------------------------------------------------------------------------

@test "[US1] --simple CLAUDE.md @imports point to .claude/docs/" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/CLAUDE.md" ]

    grep -q '@\.claude/docs/reference/best-practices\.md' "$TEST_DIR/CLAUDE.md"
    grep -q '@\.claude/docs/reference/project-structures\.md' "$TEST_DIR/CLAUDE.md"
}

@test "[US1] --simple CLAUDE.md does NOT contain legacy @docs/reference/ imports" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/CLAUDE.md" ]

    run grep -E '^@docs/reference/' "$TEST_DIR/CLAUDE.md"
    [ "$status" -ne 0 ]
}

@test "[US1] --simple CLAUDE.md table refs use .claude/docs/ paths" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/CLAUDE.md" ]

    grep -q '\.claude/docs/reference/commands\.md' "$TEST_DIR/CLAUDE.md"
    grep -q '\.claude/docs/STACK-RECIPES\.md' "$TEST_DIR/CLAUDE.md"
    grep -q '\.claude/docs/guides/EXTENDING-GUIDE\.md' "$TEST_DIR/CLAUDE.md"
}

@test "[US1] --simple copies STACK-RECIPES.md to .claude/docs/" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/.claude/docs/STACK-RECIPES.md" ]
}

@test "[US1] --simple CLAUDE.md does NOT mention removed ARCHITECTURE/WORKFLOWS rows" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/CLAUDE.md" ]

    run grep -F 'docs/ARCHITECTURE.md' "$TEST_DIR/CLAUDE.md"
    [ "$status" -ne 0 ]

    run grep -F 'docs/WORKFLOWS.md' "$TEST_DIR/CLAUDE.md"
    [ "$status" -ne 0 ]
}

# -----------------------------------------------------------------------------
# T007 — Pre-existing user docs/ARCHITECTURE.md preserved (user-owned docs scenario)
# -----------------------------------------------------------------------------

@test "[US1] --simple preserves pre-existing user docs/ARCHITECTURE.md byte-identical" {
    mkdir -p "$TEST_DIR/docs"
    cat > "$TEST_DIR/docs/ARCHITECTURE.md" <<'EOF'
# My Project Architecture

User-owned doc that documents the user's project, NOT the foundation.
The foundation install must not touch this file.

```mermaid
graph TB
    A[User VM] --> B[Proxmox]
```
EOF
    local checksum_before
    checksum_before=$(sha256sum "$TEST_DIR/docs/ARCHITECTURE.md" | cut -d' ' -f1)

    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    [ -f "$TEST_DIR/docs/ARCHITECTURE.md" ]

    local checksum_after
    checksum_after=$(sha256sum "$TEST_DIR/docs/ARCHITECTURE.md" | cut -d' ' -f1)
    [ "$checksum_before" = "$checksum_after" ]
}

@test "[US1] --simple preserves pre-existing user docs/WORKFLOWS.md byte-identical" {
    mkdir -p "$TEST_DIR/docs"
    echo "# User's own workflows doc" > "$TEST_DIR/docs/WORKFLOWS.md"

    local checksum_before
    checksum_before=$(sha256sum "$TEST_DIR/docs/WORKFLOWS.md" | cut -d' ' -f1)

    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    local checksum_after
    checksum_after=$(sha256sum "$TEST_DIR/docs/WORKFLOWS.md" | cut -d' ' -f1)
    [ "$checksum_before" = "$checksum_after" ]
}

# =============================================================================
# US2 — update.sh migrates legacy docs/reference/ → .claude/docs/reference/
# Spec: specs/docs-under-claude/spec.md (US2, P2)
# =============================================================================

# Helper: simulate a legacy install (pre-US1: docs/reference/ + @docs/reference/)
# Used by US2 tests to verify migration behavior.
make_legacy_install() {
    local target="$1"

    # Bootstrap with current install (creates .claude/, CLAUDE.md, etc.)
    "$NEW_PROJECT_SCRIPT" -y --simple "$target" >/dev/null 2>&1

    # Rewind to legacy layout: .claude/docs/ → docs/, @.claude/docs/ → @docs/
    if [[ -d "$target/.claude/docs/reference" ]]; then
        mkdir -p "$target/docs/reference"
        cp -r "$target/.claude/docs/reference/"* "$target/docs/reference/"
        rm -rf "$target/.claude/docs"
    fi
    if [[ -f "$target/CLAUDE.md" ]]; then
        # `-i.bak` works on both GNU sed (Linux) and BSD sed (macOS).
        sed -i.bak \
            -e 's|@\.claude/docs/reference/|@docs/reference/|g' \
            -e 's|`\.claude/docs/reference/|`docs/reference/|g' \
            -e 's|`\.claude/docs/guides/|`docs/guides/|g' \
            "$target/CLAUDE.md" && rm -f "$target/CLAUDE.md.bak"
    fi
}

# -----------------------------------------------------------------------------
# T017 — Legacy install migration: docs/reference/ → .claude/docs/reference/
# -----------------------------------------------------------------------------

@test "[US2] update.sh migrates legacy docs/reference/ to .claude/docs/reference/" {
    make_legacy_install "$TEST_DIR"

    # Sanity: legacy state in place
    [ -d "$TEST_DIR/docs/reference" ]
    [ ! -d "$TEST_DIR/.claude/docs/reference" ]
    grep -qE '^@docs/reference/' "$TEST_DIR/CLAUDE.md"

    run "$UPDATE_SCRIPT" -y --upgrade-claude-md "$TEST_DIR"
    [ "$status" -eq 0 ]

    # New layout in place, old removed
    [ -d "$TEST_DIR/.claude/docs/reference" ]
    [ ! -d "$TEST_DIR/docs/reference" ]

    local count
    count=$(find "$TEST_DIR/.claude/docs/reference" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -ge 7 ]
}

# -----------------------------------------------------------------------------
# T018 — CLAUDE.md @imports rewritten from @docs/ to @.claude/docs/
# -----------------------------------------------------------------------------

@test "[US2] update.sh rewrites legacy @docs/reference/ imports in CLAUDE.md" {
    make_legacy_install "$TEST_DIR"

    run "$UPDATE_SCRIPT" -y --upgrade-claude-md "$TEST_DIR"
    [ "$status" -eq 0 ]

    grep -q '@\.claude/docs/reference/best-practices\.md' "$TEST_DIR/CLAUDE.md"

    run grep -E '^@docs/reference/' "$TEST_DIR/CLAUDE.md"
    [ "$status" -ne 0 ]
}

# -----------------------------------------------------------------------------
# T019 — Locally-modified guides preserved during migration
# -----------------------------------------------------------------------------

@test "[US2] update.sh preserves locally-modified guides during migration" {
    make_legacy_install "$TEST_DIR"

    # Simulate user customization on a guide
    mkdir -p "$TEST_DIR/docs/guides"
    cat > "$TEST_DIR/docs/guides/WEB-GUIDE.md" <<'EOF'
# WEB-GUIDE customized by the user
Do not overwrite this content during migration.
EOF
    local user_checksum
    user_checksum=$(sha256sum "$TEST_DIR/docs/guides/WEB-GUIDE.md" | cut -d' ' -f1)

    run "$UPDATE_SCRIPT" -y --upgrade-claude-md "$TEST_DIR"
    [ "$status" -eq 0 ]

    # User's content survived under new path
    [ -f "$TEST_DIR/.claude/docs/guides/WEB-GUIDE.md" ]
    local migrated_checksum
    migrated_checksum=$(sha256sum "$TEST_DIR/.claude/docs/guides/WEB-GUIDE.md" | cut -d' ' -f1)
    [ "$user_checksum" = "$migrated_checksum" ]

    # Old location cleaned up
    [ ! -f "$TEST_DIR/docs/guides/WEB-GUIDE.md" ]
}

# -----------------------------------------------------------------------------
# T020 — Fresh install (no legacy) → install directly under .claude/docs/
# -----------------------------------------------------------------------------

@test "[US2] update.sh on fresh install only touches .claude/docs/" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]
    [ ! -d "$TEST_DIR/docs/reference" ]

    run "$UPDATE_SCRIPT" -y --upgrade-claude-md "$TEST_DIR"
    [ "$status" -eq 0 ]

    [ -d "$TEST_DIR/.claude/docs/reference" ]
    [ ! -d "$TEST_DIR/docs/reference" ]
    [ ! -d "$TEST_DIR/docs/guides" ]
}

# -----------------------------------------------------------------------------
# T021 — Legacy ARCHITECTURE.md / WORKFLOWS.md not auto-deleted
# -----------------------------------------------------------------------------

@test "[US2] update.sh does NOT delete legacy docs/ARCHITECTURE.md automatically" {
    make_legacy_install "$TEST_DIR"
    echo "# Doc generated by old foundation install" > "$TEST_DIR/docs/ARCHITECTURE.md"
    local checksum_before
    checksum_before=$(sha256sum "$TEST_DIR/docs/ARCHITECTURE.md" | cut -d' ' -f1)

    run "$UPDATE_SCRIPT" -y --upgrade-claude-md "$TEST_DIR"
    [ "$status" -eq 0 ]

    [ -f "$TEST_DIR/docs/ARCHITECTURE.md" ]
    local checksum_after
    checksum_after=$(sha256sum "$TEST_DIR/docs/ARCHITECTURE.md" | cut -d' ' -f1)
    [ "$checksum_before" = "$checksum_after" ]
}

# -----------------------------------------------------------------------------
# T022 — Backup created before migration
# -----------------------------------------------------------------------------

@test "[US2] update.sh creates CLAUDE.md backup before migration" {
    make_legacy_install "$TEST_DIR"

    run "$UPDATE_SCRIPT" -y --upgrade-claude-md "$TEST_DIR"
    [ "$status" -eq 0 ]

    local backup_count
    backup_count=$(find "$TEST_DIR" -maxdepth 1 -name "CLAUDE.md.backup.*" -type f 2>/dev/null | wc -l | tr -d ' ')
    [ "$backup_count" -ge 1 ]
}

# -----------------------------------------------------------------------------
# T-extra — No incoherence: after update, no docs/reference/ pollution
# -----------------------------------------------------------------------------

@test "[US2] update.sh on fresh install does NOT recreate docs/reference/ legacy" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    run "$UPDATE_SCRIPT" -y --upgrade-claude-md "$TEST_DIR"
    [ "$status" -eq 0 ]

    [ ! -d "$TEST_DIR/docs/reference" ]
    [ ! -d "$TEST_DIR/docs/guides" ]
}

@test "[US2] update.sh CLAUDE.md never has dual @imports (legacy + new)" {
    run "$NEW_PROJECT_SCRIPT" -y --simple "$TEST_DIR"
    [ "$status" -eq 0 ]

    run "$UPDATE_SCRIPT" -y --upgrade-claude-md "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Either all @imports are legacy, or all are new — never mixed
    local legacy_count
    legacy_count=$(grep -cE '^@docs/reference/' "$TEST_DIR/CLAUDE.md" || true)
    [ "$legacy_count" -eq 0 ]
}

# =============================================================================
# US3 — Mode --minimal aligned with new layout
# Spec: specs/docs-under-claude/spec.md (US3, P3)
# =============================================================================

@test "[US3] --minimal installs docs under .claude/docs/" {
    run "$NEW_PROJECT_SCRIPT" -y --minimal "$TEST_DIR"
    [ "$status" -eq 0 ]

    [ -f "$TEST_DIR/.claude/docs/reference/best-practices.md" ]
    [ -f "$TEST_DIR/.claude/docs/reference/project-structures.md" ]
    [ -f "$TEST_DIR/.claude/docs/guides/learning-path.md" ]
}

@test "[US3] --minimal does NOT pollute target docs/" {
    run "$NEW_PROJECT_SCRIPT" -y --minimal "$TEST_DIR"
    [ "$status" -eq 0 ]

    [ ! -d "$TEST_DIR/docs/reference" ]
    [ ! -d "$TEST_DIR/docs/guides" ]
}

@test "[US3] --minimal CLAUDE.md @imports point to .claude/docs/" {
    run "$NEW_PROJECT_SCRIPT" -y --minimal "$TEST_DIR"
    [ "$status" -eq 0 ]

    grep -q '@\.claude/docs/reference/best-practices\.md' "$TEST_DIR/CLAUDE.md"
    grep -q '@\.claude/docs/reference/project-structures\.md' "$TEST_DIR/CLAUDE.md"

    run grep -E '^@docs/reference/' "$TEST_DIR/CLAUDE.md"
    [ "$status" -ne 0 ]
}

# =============================================================================
# US2b — the migration must not take the project's own documentation with it
#
# A legacy docs/guides/ is routinely a mix: the foundation's four guides beside
# documentation the project authored itself. Moving the directory wholesale put
# project-authored files into a config directory the updater rewrites.
# =============================================================================

@test "[US2b] migration leaves project-authored guides in docs/guides/" {
    make_legacy_install "$TEST_DIR"
    mkdir -p "$TEST_DIR/docs/guides"
    cp "$BATS_TEST_DIRNAME/../docs/guides/TEAM-GUIDE.md" "$TEST_DIR/docs/guides/TEAM-GUIDE.md"
    printf '# Trading Guide\n\nMine, not the foundation.\n' > "$TEST_DIR/docs/guides/TRADING-GUIDE.md"

    run "$UPDATE_SCRIPT" -y --upgrade-claude-md "$TEST_DIR"
    [ "$status" -eq 0 ]

    # The foundation's guide moves under .claude/docs/...
    [ -f "$TEST_DIR/.claude/docs/guides/TEAM-GUIDE.md" ]
    [ ! -f "$TEST_DIR/docs/guides/TEAM-GUIDE.md" ]
    # ...and the project's own stays put, with its content intact.
    [ -f "$TEST_DIR/docs/guides/TRADING-GUIDE.md" ]
    grep -q "Mine, not the foundation" "$TEST_DIR/docs/guides/TRADING-GUIDE.md"
    [ ! -f "$TEST_DIR/.claude/docs/guides/TRADING-GUIDE.md" ]
}

@test "[US2b] migration leaves a project-authored file in docs/reference/" {
    make_legacy_install "$TEST_DIR"
    printf '# Our API contract\n\nProject-owned.\n' > "$TEST_DIR/docs/reference/api-contract.md"

    run "$UPDATE_SCRIPT" -y --upgrade-claude-md "$TEST_DIR"
    [ "$status" -eq 0 ]

    [ -f "$TEST_DIR/docs/reference/api-contract.md" ]
    grep -q "Project-owned" "$TEST_DIR/docs/reference/api-contract.md"
    [ -f "$TEST_DIR/.claude/docs/reference/best-practices.md" ]
    [ ! -f "$TEST_DIR/docs/reference/best-practices.md" ]
}

@test "[US2b] a docs/ holding only foundation files is still cleaned up" {
    make_legacy_install "$TEST_DIR"

    run "$UPDATE_SCRIPT" -y --upgrade-claude-md "$TEST_DIR"
    [ "$status" -eq 0 ]

    # Nothing of the project's was there, so nothing is left behind.
    [ ! -d "$TEST_DIR/docs/reference" ]
}

# Drift guard: the retired-docs list is a hand-written copy of a fact that lives
# in git history. Retire another doc upstream without adding it here and the
# migration hands it back to the project as if the project had authored it --
# which is exactly the defect this list exists to prevent.
@test "[US2b] FOUNDATION_RETIRED_DOCS still covers every doc the foundation ever shipped" {
    cd "$BATS_TEST_DIRNAME/.." || return 1

    local ever current listed missing=""
    ever=$( { git log --all --diff-filter=A --name-only --format='' -- 'docs/guides/*' 'docs/reference/*'; \
              git ls-files docs/guides docs/reference; } \
            | sed 's#^docs/\(guides\|reference\)/##' | grep -v '^$' | LC_ALL=C sort -u )
    current=$(ls docs/guides docs/reference 2>/dev/null | grep -v ':' | grep -v '^$' | LC_ALL=C sort -u)
    listed=$(sed -n '/^FOUNDATION_RETIRED_DOCS="/,/"$/p' scripts/update.sh \
             | sed -e 's/^FOUNDATION_RETIRED_DOCS="//' -e 's/"$//' | grep -v '^$')

    # Anti-vacuity: the three extractions must actually have found something.
    [ -n "$ever" ] && [ -n "$current" ] && [ -n "$listed" ]
    [ "$(printf '%s\n' "$ever" | wc -l)" -gt 10 ]

    local name
    while read -r name; do
        printf '%s\n' "$current" | grep -Fqx -- "$name" && continue
        printf '%s\n' "$listed" | grep -Fqx -- "$name" && continue
        missing="$missing $name"
    done <<< "$ever"

    [ -z "$missing" ] || { echo "not current and not listed as retired:$missing"; return 1; }
}
