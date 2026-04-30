#!/usr/bin/env bats

# =============================================================================
# Tests for check-glossary.sh — verifies translated files use canonical
# glossary translations consistently across files
# =============================================================================

load '../test_helper'

CHECK_GLOSSARY_REAL="$BATS_TEST_DIRNAME/../../scripts/migration/check-glossary.sh"

setup() {
    setup_test_dir
    GLOSSARY="$TEST_DIR/glossary.yaml"
    cat > "$GLOSSARY" <<'EOF'
terms:
  - fr: boucle
    en: loop
    forbidden: [cycle, iteration]
  - fr: agent
    en: agent
  - fr: regle
    en: rule
    forbidden: [policy]
  - fr: audit
    en: audit
    forbidden: [review]
EOF
    export GLOSSARY
    EN_DIR="$TEST_DIR/en"
    mkdir -p "$EN_DIR"
    export EN_DIR
}

teardown() {
    teardown_test_dir
}

# -----------------------------------------------------------------------------
# Script existence
# -----------------------------------------------------------------------------

@test "check-glossary.sh exists and is executable" {
    [[ -x "$CHECK_GLOSSARY_REAL" ]]
}

# -----------------------------------------------------------------------------
# Forbidden translations
# -----------------------------------------------------------------------------

@test "check-glossary fails when 'boucle' is translated as 'cycle' (forbidden)" {
    cat > "$EN_DIR/file1.md" <<'EOF'
The audit cycle ensures quality.
EOF
    run "$CHECK_GLOSSARY_REAL" --glossary "$GLOSSARY" --dir "$EN_DIR"
    [ "$status" -ne 0 ]
}

@test "check-glossary fails when 'audit' is translated as 'review' (forbidden)" {
    cat > "$EN_DIR/file1.md" <<'EOF'
The security review checks OWASP top 10.
EOF
    run "$CHECK_GLOSSARY_REAL" --glossary "$GLOSSARY" --dir "$EN_DIR"
    [ "$status" -ne 0 ]
}

@test "check-glossary passes when canonical translations are used" {
    cat > "$EN_DIR/file1.md" <<'EOF'
The audit loop ensures quality.
The agent applies the rule.
EOF
    run "$CHECK_GLOSSARY_REAL" --glossary "$GLOSSARY" --dir "$EN_DIR"
    [ "$status" -eq 0 ]
}

# -----------------------------------------------------------------------------
# Drift detection
# -----------------------------------------------------------------------------

@test "check-glossary detects drift when same FR term has different EN translations across files" {
    cat > "$EN_DIR/file1.md" <<'EOF'
The audit loop ensures quality.
EOF
    cat > "$EN_DIR/file2.md" <<'EOF'
The audit cycle ensures consistency.
EOF
    run "$CHECK_GLOSSARY_REAL" --glossary "$GLOSSARY" --dir "$EN_DIR" --detect-drift
    [ "$status" -ne 0 ]
}

@test "check-glossary passes when same FR term is consistently translated" {
    cat > "$EN_DIR/file1.md" <<'EOF'
The audit loop ensures quality.
EOF
    cat > "$EN_DIR/file2.md" <<'EOF'
The audit loop ensures consistency.
EOF
    run "$CHECK_GLOSSARY_REAL" --glossary "$GLOSSARY" --dir "$EN_DIR" --detect-drift
    [ "$status" -eq 0 ]
}

# -----------------------------------------------------------------------------
# Locked glossary
# -----------------------------------------------------------------------------

@test "check-glossary respects 'locked' marker (locked terms cannot be re-translated)" {
    cat > "$GLOSSARY" <<'EOF'
locked_at: "2026-04-30"
terms:
  - fr: socle
    en: foundation
    locked: true
    forbidden: [scaffold, base, framework]
EOF
    cat > "$EN_DIR/file1.md" <<'EOF'
The scaffold is the project template.
EOF
    run "$CHECK_GLOSSARY_REAL" --glossary "$GLOSSARY" --dir "$EN_DIR"
    [ "$status" -ne 0 ]
}

# -----------------------------------------------------------------------------
# Edge cases
# -----------------------------------------------------------------------------

@test "check-glossary ignores forbidden terms inside code blocks" {
    cat > "$EN_DIR/file1.md" <<'EOF'
The audit loop ensures quality.

```ts
const cycle = computeCycle(); // technical context, allowed
```

End of doc.
EOF
    run "$CHECK_GLOSSARY_REAL" --glossary "$GLOSSARY" --dir "$EN_DIR"
    [ "$status" -eq 0 ]
}

@test "check-glossary ignores forbidden terms inside backticks (inline code)" {
    cat > "$EN_DIR/file1.md" <<'EOF'
The audit loop ensures quality.
The `cycle` variable is documented elsewhere.
EOF
    run "$CHECK_GLOSSARY_REAL" --glossary "$GLOSSARY" --dir "$EN_DIR"
    [ "$status" -eq 0 ]
}
