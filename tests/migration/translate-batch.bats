#!/usr/bin/env bats

# =============================================================================
# Tests for translate-batch.sh — orchestrator runner.
#
# Strategy: use --dry-run mode to test orchestration logic without calling
# claude (which would consume tokens and require setup). Build a fake repo
# in TEST_DIR with a mini inventory + a few fake files.
# =============================================================================

load '../test_helper'

BATCH_REAL="$BATS_TEST_DIRNAME/../../scripts/migration/translate-batch.sh"
RECOVERY_REAL="$BATS_TEST_DIRNAME/../../scripts/migration/recovery.sh"

setup() {
    setup_test_dir

    # Build a minimal fake project root in TEST_DIR
    cd "$TEST_DIR"
    mkdir -p docs/guides .claude/rules

    cat > a.md <<'EOF'
# Titre A

Contenu en francais.
EOF

    cat > b.md <<'EOF'
# Titre B

Autre contenu.
EOF

    cat > c.md <<'EOF'
# Titre C

Encore.
EOF

    cat > inventory.json <<EOF
{
  "tiers": {
    "1": {
      "files": ["a.md", "b.md", "c.md"]
    }
  }
}
EOF

    STATE_FILE="$TEST_DIR/state.json"
    INVENTORY="$TEST_DIR/inventory.json"
    export STATE_FILE INVENTORY
}

teardown() {
    teardown_test_dir
}

# -----------------------------------------------------------------------------
# Script existence
# -----------------------------------------------------------------------------

@test "translate-batch.sh exists and is executable" {
    [[ -x "$BATCH_REAL" ]]
}

# -----------------------------------------------------------------------------
# Pre-flight: invalid tier
# -----------------------------------------------------------------------------

@test "translate-batch fails on invalid tier number" {
    run "$BATCH_REAL" --tier 99 --inventory "$INVENTORY" --state "$STATE_FILE" --dry-run --root "$TEST_DIR"
    [ "$status" -ne 0 ]
}

@test "translate-batch fails when --tier missing" {
    run "$BATCH_REAL" --inventory "$INVENTORY" --state "$STATE_FILE" --dry-run --root "$TEST_DIR"
    [ "$status" -ne 0 ]
}

# -----------------------------------------------------------------------------
# Dry-run basic behavior
# -----------------------------------------------------------------------------

@test "translate-batch --dry-run initializes state.json on first run" {
    run "$BATCH_REAL" --tier 1 --inventory "$INVENTORY" --state "$STATE_FILE" --dry-run --root "$TEST_DIR" --no-commit
    [ "$status" -eq 0 ]
    [[ -f "$STATE_FILE" ]]
    if command -v jq >/dev/null 2>&1; then
        run jq '.files | length' "$STATE_FILE"
        [ "$output" -eq 3 ]
    fi
}

@test "translate-batch --dry-run marks all files as draft after a full pass" {
    "$BATCH_REAL" --tier 1 --inventory "$INVENTORY" --state "$STATE_FILE" --dry-run --root "$TEST_DIR" --no-commit
    if command -v jq >/dev/null 2>&1; then
        run jq -r '[.files[].status] | unique | .[]' "$STATE_FILE"
        [[ "$output" == "draft" ]]
    fi
}

@test "translate-batch --dry-run prepends a marker to translated files" {
    "$BATCH_REAL" --tier 1 --inventory "$INVENTORY" --state "$STATE_FILE" --dry-run --root "$TEST_DIR" --no-commit
    grep -q "DRY-RUN" "$TEST_DIR/a.md"
    grep -q "DRY-RUN" "$TEST_DIR/b.md"
    grep -q "DRY-RUN" "$TEST_DIR/c.md"
}

# -----------------------------------------------------------------------------
# --limit
# -----------------------------------------------------------------------------

@test "translate-batch --limit 1 processes only one file" {
    "$BATCH_REAL" --tier 1 --inventory "$INVENTORY" --state "$STATE_FILE" --dry-run --limit 1 --root "$TEST_DIR" --no-commit
    if command -v jq >/dev/null 2>&1; then
        run jq -r '[.files[] | select(.status == "draft")] | length' "$STATE_FILE"
        [ "$output" -eq 1 ]
    fi
}

# -----------------------------------------------------------------------------
# Resume / skip already-done files
# -----------------------------------------------------------------------------

@test "translate-batch resumes and skips already-done files" {
    # First pass: process 1 file
    "$BATCH_REAL" --tier 1 --inventory "$INVENTORY" --state "$STATE_FILE" --dry-run --limit 1 --root "$TEST_DIR" --no-commit

    # Capture which file was processed (the only "draft")
    if command -v jq >/dev/null 2>&1; then
        first_done=$(jq -r '[.files[] | select(.status == "draft") | .path][0]' "$STATE_FILE")
        [ -n "$first_done" ]

        # Capture mtime of the already-translated file
        mtime_before=$(stat -c %Y "$TEST_DIR/$first_done" 2>/dev/null || stat -f %m "$TEST_DIR/$first_done")

        # Sleep 1s so mtime would differ if re-translated
        sleep 1

        # Second pass: process all (should skip the first)
        "$BATCH_REAL" --tier 1 --inventory "$INVENTORY" --state "$STATE_FILE" --dry-run --root "$TEST_DIR" --no-commit

        mtime_after=$(stat -c %Y "$TEST_DIR/$first_done" 2>/dev/null || stat -f %m "$TEST_DIR/$first_done")

        [ "$mtime_before" = "$mtime_after" ]
    else
        skip "jq required"
    fi
}

# -----------------------------------------------------------------------------
# Idempotency
# -----------------------------------------------------------------------------

@test "translate-batch is idempotent (multiple full passes don't re-translate)" {
    "$BATCH_REAL" --tier 1 --inventory "$INVENTORY" --state "$STATE_FILE" --dry-run --root "$TEST_DIR" --no-commit
    sleep 1
    mtime1=$(stat -c %Y "$TEST_DIR/a.md" 2>/dev/null || stat -f %m "$TEST_DIR/a.md")
    "$BATCH_REAL" --tier 1 --inventory "$INVENTORY" --state "$STATE_FILE" --dry-run --root "$TEST_DIR" --no-commit
    mtime2=$(stat -c %Y "$TEST_DIR/a.md" 2>/dev/null || stat -f %m "$TEST_DIR/a.md")
    [ "$mtime1" = "$mtime2" ]
}

# -----------------------------------------------------------------------------
# Output reporting
# -----------------------------------------------------------------------------

@test "translate-batch reports progress (current/total)" {
    run "$BATCH_REAL" --tier 1 --inventory "$INVENTORY" --state "$STATE_FILE" --dry-run --root "$TEST_DIR" --no-commit
    [ "$status" -eq 0 ]
    [[ "$output" == *"1/3"* || "$output" == *"[1/"* ]]
    [[ "$output" == *"3/3"* || "$output" == *"/3]"* ]]
}

# -----------------------------------------------------------------------------
# --verify mode: re-runs validators on already-draft files (no translation).
# -----------------------------------------------------------------------------

@test "translate-batch --verify on a tier with no draft files exits 0" {
    "$BATCH_REAL" --tier 1 --inventory "$INVENTORY" --state "$STATE_FILE" --dry-run --root "$TEST_DIR" --no-commit
    # Reset all to todo
    if command -v jq >/dev/null 2>&1; then
        tmpf=$(mktemp)
        jq '.files |= map(.status = "todo")' "$STATE_FILE" > "$tmpf"
        mv "$tmpf" "$STATE_FILE"
    fi
    run "$BATCH_REAL" --tier 1 --state "$STATE_FILE" --root "$TEST_DIR" --verify
    [ "$status" -eq 0 ]
    [[ "$output" == *"no draft files"* || "$output" == *"nothing to verify"* ]]
}

@test "translate-batch --verify reports a count of draft files checked" {
    # Process all 3 in dry-run mode (with --no-validate to make them all draft regardless)
    "$BATCH_REAL" --tier 1 --inventory "$INVENTORY" --state "$STATE_FILE" --dry-run --root "$TEST_DIR" --no-commit --no-validate
    run "$BATCH_REAL" --tier 1 --state "$STATE_FILE" --root "$TEST_DIR" --verify
    # 3 draft files; verify might fail validation (these are FR with prepended marker, EN structure issues),
    # but the runner should still exit and report a count.
    [[ "$output" == *"3"* ]]
}

# -----------------------------------------------------------------------------
# Integration: --verify catches glossary drift across draft files
# -----------------------------------------------------------------------------

@test "translate-batch --verify detects forbidden translation in a draft file" {
    # Build state with one file marked draft
    cat > "$STATE_FILE" <<'EOF'
{
  "files": [
    { "path": "a.md", "status": "draft" }
  ]
}
EOF
    # Replace a.md with content that uses a FORBIDDEN translation per the
    # real glossary: "boucle" -> "loop" canonical, "cycle" forbidden in
    # this context.
    cat > "$TEST_DIR/a.md" <<'EOF'
# Title

The audit cycle ensures quality.
EOF
    run "$BATCH_REAL" --tier 1 --state "$STATE_FILE" --root "$TEST_DIR" --verify
    # The forbidden term "cycle" (forbidden alternative for "boucle"->"loop")
    # should be flagged by check-glossary, causing --verify to exit non-zero.
    [ "$status" -ne 0 ]
}

@test "translate-batch --verify passes when all drafts use canonical translations" {
    cat > "$STATE_FILE" <<'EOF'
{
  "files": [
    { "path": "a.md", "status": "draft" },
    { "path": "b.md", "status": "draft" }
  ]
}
EOF
    cat > "$TEST_DIR/a.md" <<'EOF'
# Title A

The audit loop ensures quality.
EOF
    cat > "$TEST_DIR/b.md" <<'EOF'
# Title B

The audit loop ensures consistency.
EOF
    run "$BATCH_REAL" --tier 1 --state "$STATE_FILE" --root "$TEST_DIR" --verify
    [ "$status" -eq 0 ]
}
