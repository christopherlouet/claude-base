#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/audit-docs.sh — doc drift firewall
# Spec: specs/audit-docs/spec.md
# Plan: specs/audit-docs/plan.md
#
# Each test creates a minimal fixture .md in $TEST_DIR and runs the script
# with `--target $TEST_DIR/<file>.md` to scope detection to that fixture.
# Categories: paths / verbs / flags / scripts / npm
# Plus: env-var hatch, remote-URL tolerance, regression PR #199, zero-FP gate.
# =============================================================================

load 'test_helper'

AUDIT_DOCS="$BASE_DIR/scripts/audit-docs.sh"

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Category: paths (EF-001)
# =============================================================================

@test "audit-docs: rejects unknown ~/X path prefix (T005, EF-001)" {
    cat > "$TEST_DIR/bad-path.md" <<'EOF'
# Bad path

Run `~/nonexistent-prefix/foo` to break things.
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/bad-path.md" --category paths
    [ "$status" -eq 1 ]
    [[ "$output" == *"paths"* ]]
    [[ "$output" == *"nonexistent-prefix"* ]]
}

@test "audit-docs: accepts known ~/.local/share/claude-base/ path (T006, EF-001)" {
    cat > "$TEST_DIR/good-path.md" <<'EOF'
# Good path

The foundation lives at `~/.local/share/claude-base/` per install.sh.
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/good-path.md" --category paths
    [ "$status" -eq 0 ]
}

# =============================================================================
# Category: verbs (EF-002)
# =============================================================================

@test "audit-docs: rejects claude-base nonexistentverb (T007, EF-002)" {
    cat > "$TEST_DIR/bad-verb.md" <<'EOF'
# Bad verb

Run `claude-base bogusverb` to install.
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/bad-verb.md" --category verbs
    [ "$status" -eq 1 ]
    [[ "$output" == *"verbs"* ]]
    [[ "$output" == *"bogusverb"* ]]
}

@test "audit-docs: ignores claude-base is a foundation (English prose) (T008, EF-002)" {
    cat > "$TEST_DIR/prose.md" <<'EOF'
# Prose

claude-base is a foundation for Claude Code workflows.
You can use claude-base in production with confidence.
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/prose.md" --category verbs
    [ "$status" -eq 0 ]
}

# =============================================================================
# Category: flags (EF-003)
# =============================================================================

@test "audit-docs: rejects claude-base init --foo (T009, EF-003)" {
    cat > "$TEST_DIR/bad-flag.md" <<'EOF'
# Bad flag

```bash
claude-base init --foo ./my-project
```
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/bad-flag.md" --category flags
    [ "$status" -eq 1 ]
    [[ "$output" == *"flags"* ]]
    [[ "$output" == *"--foo"* ]]
}

@test "audit-docs: accepts claude-base init --preset nextjs (T010, EF-003)" {
    cat > "$TEST_DIR/good-flag.md" <<'EOF'
# Good flag

```bash
claude-base init --preset nextjs ./my-web-app
```
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/good-flag.md" --category flags
    [ "$status" -eq 0 ]
}

# =============================================================================
# Category: scripts (EF-004, EF-013)
# =============================================================================

@test "audit-docs: rejects ./scripts/nuclear.sh (T011, EF-004)" {
    cat > "$TEST_DIR/bad-script.md" <<'EOF'
# Bad script

Run `./scripts/nuclear.sh` to destroy your project.
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/bad-script.md" --category scripts
    [ "$status" -eq 1 ]
    [[ "$output" == *"scripts"* ]]
    [[ "$output" == *"nuclear.sh"* ]]
}

@test "audit-docs: accepts ./scripts/test.sh (T012, EF-004)" {
    cat > "$TEST_DIR/good-script.md" <<'EOF'
# Good script

Run `./scripts/test.sh` to run the bats tests in parallel.
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/good-script.md" --category scripts
    [ "$status" -eq 0 ]
}

@test "audit-docs: https URL with scripts/X.sh substring is NOT flagged (T018, EF-013)" {
    cat > "$TEST_DIR/remote-url.md" <<'EOF'
# Remote URL

The install script is at https://github.com/christopherlouet/claude-base/blob/main/scripts/deploy.sh — not a local script.
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/remote-url.md" --category scripts
    [ "$status" -eq 0 ]
}

# =============================================================================
# Category: npm (EF-005)
# =============================================================================

@test "audit-docs: rejects npm --prefix website run nonsense (T013, EF-005)" {
    cat > "$TEST_DIR/bad-npm.md" <<'EOF'
# Bad npm

Run `npm --prefix website run nonsense` to break things.
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/bad-npm.md" --category npm
    [ "$status" -eq 1 ]
    [[ "$output" == *"npm"* ]]
    [[ "$output" == *"nonsense"* ]]
}

@test "audit-docs: accepts npm --prefix website run generate (T014, EF-005)" {
    cat > "$TEST_DIR/good-npm.md" <<'EOF'
# Good npm

Run `npm --prefix website run generate` to regenerate counters.
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/good-npm.md" --category npm
    [ "$status" -eq 0 ]
}

# =============================================================================
# Regression: PR #199 (T015)
# =============================================================================

@test "audit-docs: regression PR #199 — ~/.claude-base/ triggers paths drift (T015, US-6)" {
    cat > "$TEST_DIR/pr199-drift.md" <<'EOF'
# PR #199 historical drift

```bash
git clone https://github.com/christopherlouet/claude-base.git ~/.claude-base
~/.claude-base/scripts/new-project.sh --simple /path/to/your-project
```
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/pr199-drift.md" --category paths
    [ "$status" -eq 1 ]
    [[ "$output" == *"paths"* ]]
    [[ "$output" == *".claude-base"* ]]
}

# =============================================================================
# Env-var hatch (T016, EF-011)
# =============================================================================

@test "audit-docs: AUDIT_DOCS_SKIP_PATHS=1 ignores path drifts but still catches verbs (T016, EF-011)" {
    cat > "$TEST_DIR/mixed-drift.md" <<'EOF'
# Mixed drift

Run `claude-base bogusverb` against `~/nonexistent/foo`.
EOF
    run env AUDIT_DOCS_SKIP_PATHS=1 "$AUDIT_DOCS" --target "$TEST_DIR/mixed-drift.md"
    [ "$status" -eq 1 ]
    [[ "$output" == *"verbs"* ]]
    [[ "$output" == *"bogusverb"* ]]
    # The path drift should NOT be reported
    [[ "$output" != *"nonexistent"* ]]
}

# =============================================================================
# Zero-FP gate (T017, EF-012) — CRITICAL
# =============================================================================

@test "audit-docs: real foundation repo exits 0 with no drift (T017, EF-012)" {
    [ -x "$AUDIT_DOCS" ]
    run "$AUDIT_DOCS"
    [ "$status" -eq 0 ]
}
