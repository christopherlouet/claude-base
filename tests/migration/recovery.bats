#!/usr/bin/env bats

# =============================================================================
# Tests for recovery.sh — verifies that a batch killed mid-process can resume
# without re-translating already-completed files
# =============================================================================

load '../test_helper'

RECOVERY_REAL="$BATS_TEST_DIRNAME/../../scripts/migration/recovery.sh"

setup() {
    setup_test_dir
    STATE_FILE="$TEST_DIR/state.json"
    export STATE_FILE
}

teardown() {
    teardown_test_dir
}

# -----------------------------------------------------------------------------
# Script existence
# -----------------------------------------------------------------------------

@test "recovery.sh exists and is executable" {
    [[ -x "$RECOVERY_REAL" ]]
}

# -----------------------------------------------------------------------------
# State file format
# -----------------------------------------------------------------------------

@test "recovery init creates a valid state.json" {
    cat > "$TEST_DIR/inventory.json" <<'EOF'
{
  "tiers": {
    "1": {
      "files": ["a.md", "b.md", "c.md"]
    }
  }
}
EOF
    run "$RECOVERY_REAL" init --tier 1 --inventory "$TEST_DIR/inventory.json" --state "$STATE_FILE"
    [ "$status" -eq 0 ]
    [[ -f "$STATE_FILE" ]]
    if command -v jq >/dev/null 2>&1; then
        run jq '.files | length' "$STATE_FILE"
        [ "$output" -eq 3 ]
    fi
}

@test "recovery init marks all files as todo initially" {
    cat > "$TEST_DIR/inventory.json" <<'EOF'
{ "tiers": { "1": { "files": ["a.md", "b.md"] } } }
EOF
    "$RECOVERY_REAL" init --tier 1 --inventory "$TEST_DIR/inventory.json" --state "$STATE_FILE"
    if command -v jq >/dev/null 2>&1; then
        run jq -r '.files[].status' "$STATE_FILE"
        [[ "$output" == *"todo"* ]]
        [ "$(echo "$output" | grep -c todo)" -eq 2 ]
    else
        skip "jq required for detailed assertion"
    fi
}

# -----------------------------------------------------------------------------
# Resume after interruption
# -----------------------------------------------------------------------------

@test "recovery list-pending excludes files marked done" {
    cat > "$STATE_FILE" <<'EOF'
{
  "files": [
    { "path": "a.md", "status": "draft" },
    { "path": "b.md", "status": "todo" },
    { "path": "c.md", "status": "draft" },
    { "path": "d.md", "status": "todo" }
  ]
}
EOF
    run "$RECOVERY_REAL" list-pending --state "$STATE_FILE"
    [ "$status" -eq 0 ]
    [[ "$output" == *"b.md"* ]]
    [[ "$output" == *"d.md"* ]]
    [[ "$output" != *"a.md"* ]]
    [[ "$output" != *"c.md"* ]]
}

@test "recovery mark-done updates a file status to draft" {
    cat > "$STATE_FILE" <<'EOF'
{
  "files": [
    { "path": "a.md", "status": "todo" }
  ]
}
EOF
    run "$RECOVERY_REAL" mark-done --state "$STATE_FILE" --file "a.md"
    [ "$status" -eq 0 ]
    if command -v jq >/dev/null 2>&1; then
        run jq -r '.files[0].status' "$STATE_FILE"
        [ "$output" = "draft" ]
    fi
}

# -----------------------------------------------------------------------------
# Idempotence (key safety property)
# -----------------------------------------------------------------------------

@test "recovery list-pending is idempotent (multiple calls return same result)" {
    cat > "$STATE_FILE" <<'EOF'
{
  "files": [
    { "path": "a.md", "status": "todo" },
    { "path": "b.md", "status": "draft" },
    { "path": "c.md", "status": "todo" }
  ]
}
EOF
    out1=$("$RECOVERY_REAL" list-pending --state "$STATE_FILE")
    out2=$("$RECOVERY_REAL" list-pending --state "$STATE_FILE")
    [ "$out1" = "$out2" ]
}

@test "recovery resume scenario: kill mid-batch, files already done are not re-translated" {
    cat > "$TEST_DIR/inventory.json" <<'EOF'
{ "tiers": { "1": { "files": ["a.md", "b.md", "c.md", "d.md"] } } }
EOF
    "$RECOVERY_REAL" init --tier 1 --inventory "$TEST_DIR/inventory.json" --state "$STATE_FILE"

    # Simulate that 2 files were translated before kill
    "$RECOVERY_REAL" mark-done --state "$STATE_FILE" --file "a.md"
    "$RECOVERY_REAL" mark-done --state "$STATE_FILE" --file "b.md"

    # On resume, only c.md and d.md should remain pending
    run "$RECOVERY_REAL" list-pending --state "$STATE_FILE"
    [ "$status" -eq 0 ]
    pending_count=$(echo "$output" | grep -c "\.md")
    [ "$pending_count" -eq 2 ]
    [[ "$output" == *"c.md"* ]]
    [[ "$output" == *"d.md"* ]]
}

# -----------------------------------------------------------------------------
# Checksum-based detection of source change
# -----------------------------------------------------------------------------

@test "recovery init computes checksums for source detection" {
    cat > "$TEST_DIR/inventory.json" <<'EOF'
{ "tiers": { "1": { "files": ["a.md"] } } }
EOF
    cd "$TEST_DIR" && echo "source content" > a.md
    "$RECOVERY_REAL" init --tier 1 --inventory "$TEST_DIR/inventory.json" --state "$STATE_FILE" --root "$TEST_DIR"
    if command -v jq >/dev/null 2>&1; then
        run jq -r '.files[0].checksum_source' "$STATE_FILE"
        [ -n "$output" ]
        [ "$output" != "null" ]
    else
        skip "jq required for assertion"
    fi
}

# -----------------------------------------------------------------------------
# mark-todo (revert a file's status for re-translation)
# -----------------------------------------------------------------------------

@test "recovery mark-todo reverts a draft file back to todo" {
    cat > "$STATE_FILE" <<'EOF'
{
  "files": [
    { "path": "a.md", "status": "draft" }
  ]
}
EOF
    run "$RECOVERY_REAL" mark-todo --state "$STATE_FILE" --file "a.md"
    [ "$status" -eq 0 ]
    if command -v jq >/dev/null 2>&1; then
        run jq -r '.files[0].status' "$STATE_FILE"
        [ "$output" = "todo" ]
    fi
}

@test "recovery mark-todo on nonexistent file is a no-op (no error)" {
    cat > "$STATE_FILE" <<'EOF'
{
  "files": [
    { "path": "a.md", "status": "draft" }
  ]
}
EOF
    run "$RECOVERY_REAL" mark-todo --state "$STATE_FILE" --file "doesnotexist.md"
    [ "$status" -eq 0 ]
}

# -----------------------------------------------------------------------------
# stats (quick counts per status)
# -----------------------------------------------------------------------------

@test "recovery stats prints counts per status" {
    cat > "$STATE_FILE" <<'EOF'
{
  "files": [
    { "path": "a.md", "status": "draft" },
    { "path": "b.md", "status": "draft" },
    { "path": "c.md", "status": "todo" },
    { "path": "d.md", "status": "reviewed" }
  ]
}
EOF
    run "$RECOVERY_REAL" stats --state "$STATE_FILE"
    [ "$status" -eq 0 ]
    [[ "$output" == *"draft=2"* || "$output" == *"draft: 2"* ]]
    [[ "$output" == *"todo=1"* || "$output" == *"todo: 1"* ]]
    [[ "$output" == *"reviewed=1"* || "$output" == *"reviewed: 1"* ]]
}

# -----------------------------------------------------------------------------
# mark-reviewed (after human Friday morning review)
# -----------------------------------------------------------------------------

@test "recovery mark-reviewed bumps a draft file to reviewed" {
    cat > "$STATE_FILE" <<'EOF'
{
  "files": [
    { "path": "a.md", "status": "draft" }
  ]
}
EOF
    run "$RECOVERY_REAL" mark-reviewed --state "$STATE_FILE" --file "a.md"
    [ "$status" -eq 0 ]
    if command -v jq >/dev/null 2>&1; then
        run jq -r '.files[0].status' "$STATE_FILE"
        [ "$output" = "reviewed" ]
    fi
}

@test "recovery mark-reviewed refuses to bump from todo (must be draft first)" {
    cat > "$STATE_FILE" <<'EOF'
{
  "files": [
    { "path": "a.md", "status": "todo" }
  ]
}
EOF
    run "$RECOVERY_REAL" mark-reviewed --state "$STATE_FILE" --file "a.md"
    [ "$status" -ne 0 ]
}

@test "recovery mark-reviewed --all bumps all draft files to reviewed" {
    cat > "$STATE_FILE" <<'EOF'
{
  "files": [
    { "path": "a.md", "status": "draft" },
    { "path": "b.md", "status": "draft" },
    { "path": "c.md", "status": "todo" }
  ]
}
EOF
    run "$RECOVERY_REAL" mark-reviewed --state "$STATE_FILE" --all
    [ "$status" -eq 0 ]
    if command -v jq >/dev/null 2>&1; then
        run jq '[.files[] | select(.status == "reviewed")] | length' "$STATE_FILE"
        [ "$output" -eq 2 ]
        run jq '[.files[] | select(.status == "todo")] | length' "$STATE_FILE"
        [ "$output" -eq 1 ]
    fi
}

# -----------------------------------------------------------------------------
# mark-merged (after PR is finally merged on main)
# -----------------------------------------------------------------------------

@test "recovery mark-merged bumps a reviewed file to merged" {
    cat > "$STATE_FILE" <<'EOF'
{
  "files": [
    { "path": "a.md", "status": "reviewed" }
  ]
}
EOF
    run "$RECOVERY_REAL" mark-merged --state "$STATE_FILE" --file "a.md"
    [ "$status" -eq 0 ]
    if command -v jq >/dev/null 2>&1; then
        run jq -r '.files[0].status' "$STATE_FILE"
        [ "$output" = "merged" ]
    fi
}

@test "recovery mark-merged refuses to bump from draft (must be reviewed first)" {
    cat > "$STATE_FILE" <<'EOF'
{
  "files": [
    { "path": "a.md", "status": "draft" }
  ]
}
EOF
    run "$RECOVERY_REAL" mark-merged --state "$STATE_FILE" --file "a.md"
    [ "$status" -ne 0 ]
}

@test "recovery mark-merged --all bumps all reviewed files to merged" {
    cat > "$STATE_FILE" <<'EOF'
{
  "files": [
    { "path": "a.md", "status": "reviewed" },
    { "path": "b.md", "status": "reviewed" },
    { "path": "c.md", "status": "draft" }
  ]
}
EOF
    run "$RECOVERY_REAL" mark-merged --state "$STATE_FILE" --all
    [ "$status" -eq 0 ]
    if command -v jq >/dev/null 2>&1; then
        run jq '[.files[] | select(.status == "merged")] | length' "$STATE_FILE"
        [ "$output" -eq 2 ]
        run jq '[.files[] | select(.status == "draft")] | length' "$STATE_FILE"
        [ "$output" -eq 1 ]
    fi
}

# -----------------------------------------------------------------------------
# stats --all-tiers (cross-tier aggregation)
# -----------------------------------------------------------------------------

@test "recovery stats --all-tiers aggregates multiple state files" {
    cat > "$TEST_DIR/state-tier-1.json" <<'EOF'
{ "files": [
    { "path": "a.md", "status": "draft" },
    { "path": "b.md", "status": "reviewed" }
] }
EOF
    cat > "$TEST_DIR/state-tier-2.json" <<'EOF'
{ "files": [
    { "path": "c.md", "status": "draft" },
    { "path": "d.md", "status": "todo" },
    { "path": "e.md", "status": "todo" }
] }
EOF
    run "$RECOVERY_REAL" stats --all-tiers --dir "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"total=5"* ]]
    [[ "$output" == *"draft=2"* ]]
    [[ "$output" == *"reviewed=1"* ]]
    [[ "$output" == *"todo=2"* ]]
}

@test "recovery stats --all-tiers handles missing state files gracefully" {
    run "$RECOVERY_REAL" stats --all-tiers --dir "$TEST_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *"total=0"* || "$output" == *"no state"* ]]
}
