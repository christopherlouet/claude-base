#!/usr/bin/env bats

# =============================================================================
# Tests for check-refs.sh — verifies translated files preserve internal refs
# (slash commands, file paths, anchors)
# =============================================================================

load '../test_helper'

CHECK_REFS_REAL="$BATS_TEST_DIRNAME/../../scripts/migration/check-refs.sh"
BLACKLIST_REAL="$BATS_TEST_DIRNAME/../../specs/migration-fr-en/blacklist.txt"

setup() {
    setup_test_dir
    SRC_FILE="$TEST_DIR/source.md"
    DST_FILE="$TEST_DIR/translated.md"
    export SRC_FILE DST_FILE
}

teardown() {
    teardown_test_dir
}

# -----------------------------------------------------------------------------
# Script existence
# -----------------------------------------------------------------------------

@test "check-refs.sh exists and is executable" {
    [[ -x "$CHECK_REFS_REAL" ]]
}

@test "blacklist.txt exists" {
    [[ -f "$BLACKLIST_REAL" ]]
}

# -----------------------------------------------------------------------------
# Slash commands preserved
# -----------------------------------------------------------------------------

@test "check-refs passes when slash commands are intact" {
    cat > "$SRC_FILE" <<'EOF'
Use /work:work-explore to start.
Then /dev:dev-tdd for tests.
EOF
    cat > "$DST_FILE" <<'EOF'
Use /work:work-explore to start.
Then /dev:dev-tdd for tests.
EOF
    run "$CHECK_REFS_REAL" --src "$SRC_FILE" --dst "$DST_FILE" --blacklist "$BLACKLIST_REAL"
    [ "$status" -eq 0 ]
}

@test "check-refs fails when slash command is translated/altered" {
    cat > "$SRC_FILE" <<'EOF'
Use /work:work-explore to start.
EOF
    cat > "$DST_FILE" <<'EOF'
Use /work:work-explorer to start.
EOF
    run "$CHECK_REFS_REAL" --src "$SRC_FILE" --dst "$DST_FILE" --blacklist "$BLACKLIST_REAL"
    [ "$status" -ne 0 ]
}

@test "check-refs fails when slash command is dropped from translation" {
    cat > "$SRC_FILE" <<'EOF'
Run /qa:qa-loop "score 90" to audit.
EOF
    cat > "$DST_FILE" <<'EOF'
Run quality loop with score 90 to audit.
EOF
    run "$CHECK_REFS_REAL" --src "$SRC_FILE" --dst "$DST_FILE" --blacklist "$BLACKLIST_REAL"
    [ "$status" -ne 0 ]
}

# -----------------------------------------------------------------------------
# File paths preserved
# -----------------------------------------------------------------------------

@test "check-refs passes when file paths are intact" {
    cat > "$SRC_FILE" <<'EOF'
Voir docs/guides/PROMPTING-GUIDE.md pour plus de details.
La regle .claude/rules/typescript.md s'applique aux fichiers .ts.
EOF
    cat > "$DST_FILE" <<'EOF'
See docs/guides/PROMPTING-GUIDE.md for more details.
The rule .claude/rules/typescript.md applies to .ts files.
EOF
    run "$CHECK_REFS_REAL" --src "$SRC_FILE" --dst "$DST_FILE" --blacklist "$BLACKLIST_REAL"
    [ "$status" -eq 0 ]
}

@test "check-refs fails when file path is mistranslated" {
    cat > "$SRC_FILE" <<'EOF'
Voir docs/guides/PROMPTING-GUIDE.md pour plus de details.
EOF
    cat > "$DST_FILE" <<'EOF'
See docs/guides/PROMPTING-GUIDE-EN.md for more details.
EOF
    run "$CHECK_REFS_REAL" --src "$SRC_FILE" --dst "$DST_FILE" --blacklist "$BLACKLIST_REAL"
    [ "$status" -ne 0 ]
}

# -----------------------------------------------------------------------------
# Markdown anchors
# -----------------------------------------------------------------------------

@test "check-refs passes when anchor in same doc points to existing heading" {
    cat > "$DST_FILE" <<'EOF'
See [the workflow](#workflow).

## Workflow

Content here.
EOF
    run "$CHECK_REFS_REAL" --src "$DST_FILE" --dst "$DST_FILE" --blacklist "$BLACKLIST_REAL" --check-anchors
    [ "$status" -eq 0 ]
}

@test "check-refs fails when anchor points to non-existing section" {
    cat > "$DST_FILE" <<'EOF'
See [the workflow obligatoire](#workflow-obligatoire).

## Workflow

Content here (heading was renamed but anchor not updated).
EOF
    run "$CHECK_REFS_REAL" --src "$DST_FILE" --dst "$DST_FILE" --blacklist "$BLACKLIST_REAL" --check-anchors
    [ "$status" -ne 0 ]
}

# -----------------------------------------------------------------------------
# Blacklist enforcement
# -----------------------------------------------------------------------------

@test "check-refs passes when frontmatter keys are preserved" {
    cat > "$SRC_FILE" <<'EOF'
---
name: test
type: project
description: ma description
---
Contenu.
EOF
    cat > "$DST_FILE" <<'EOF'
---
name: test
type: project
description: my description
---
Content.
EOF
    run "$CHECK_REFS_REAL" --src "$SRC_FILE" --dst "$DST_FILE" --blacklist "$BLACKLIST_REAL"
    [ "$status" -eq 0 ]
}

@test "check-refs fails when frontmatter key itself is translated" {
    cat > "$SRC_FILE" <<'EOF'
---
name: test
description: ma description
---
EOF
    cat > "$DST_FILE" <<'EOF'
---
name: test
description_en: my description
---
EOF
    run "$CHECK_REFS_REAL" --src "$SRC_FILE" --dst "$DST_FILE" --blacklist "$BLACKLIST_REAL"
    [ "$status" -ne 0 ]
}
