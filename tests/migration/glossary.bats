#!/usr/bin/env bats

# =============================================================================
# Tests for the migration glossary.yaml format and lock-glossary.sh script
#
# Strategy: build a fake glossary in TEST_DIR, run the validators against it.
# =============================================================================

load '../test_helper'

LOCK_SCRIPT_REAL="$BATS_TEST_DIRNAME/../../scripts/migration/lock-glossary.sh"

setup() {
    setup_test_dir
    mkdir -p "$TEST_DIR/specs/migration-fr-en"
    GLOSSARY="$TEST_DIR/specs/migration-fr-en/glossary.yaml"
    export GLOSSARY
}

teardown() {
    teardown_test_dir
}

# -----------------------------------------------------------------------------
# Format validation
# -----------------------------------------------------------------------------

@test "glossary.yaml file exists at the expected path in real repo" {
    real_glossary="$BATS_TEST_DIRNAME/../../specs/migration-fr-en/glossary.yaml"
    [[ -f "$real_glossary" ]]
}

@test "glossary.yaml is valid YAML (parseable)" {
    real_glossary="$BATS_TEST_DIRNAME/../../specs/migration-fr-en/glossary.yaml"
    if command -v yq >/dev/null 2>&1; then
        run yq eval '.' "$real_glossary"
        [ "$status" -eq 0 ]
    else
        run python3 -c "import yaml, sys; yaml.safe_load(open('$real_glossary'))"
        [ "$status" -eq 0 ]
    fi
}

@test "glossary.yaml contains at least 50 terms" {
    real_glossary="$BATS_TEST_DIRNAME/../../specs/migration-fr-en/glossary.yaml"
    if command -v yq >/dev/null 2>&1; then
        count=$(yq eval '.terms | length' "$real_glossary")
    else
        count=$(python3 -c "import yaml; d = yaml.safe_load(open('$real_glossary')); print(len(d.get('terms', [])))")
    fi
    [ "$count" -ge 50 ]
}

# -----------------------------------------------------------------------------
# Unicity
# -----------------------------------------------------------------------------

@test "glossary FR terms are unique (no duplicates)" {
    real_glossary="$BATS_TEST_DIRNAME/../../specs/migration-fr-en/glossary.yaml"
    if command -v yq >/dev/null 2>&1; then
        unique=$(yq eval '.terms[].fr' "$real_glossary" | sort -u | wc -l)
        total=$(yq eval '.terms[].fr' "$real_glossary" | wc -l)
    else
        unique=$(python3 -c "import yaml; d = yaml.safe_load(open('$real_glossary')); fr=[t['fr'] for t in d['terms']]; print(len(set(fr)))")
        total=$(python3 -c "import yaml; d = yaml.safe_load(open('$real_glossary')); print(len(d['terms']))")
    fi
    [ "$unique" -eq "$total" ]
}

@test "every glossary entry has both fr and en fields" {
    real_glossary="$BATS_TEST_DIRNAME/../../specs/migration-fr-en/glossary.yaml"
    run python3 -c "
import yaml, sys
d = yaml.safe_load(open('$real_glossary'))
for t in d.get('terms', []):
    assert 'fr' in t and 'en' in t, f'missing fr or en in: {t}'
    assert t['fr'] and t['en'], f'empty fr or en in: {t}'
print('OK')
"
    [ "$status" -eq 0 ]
}

# -----------------------------------------------------------------------------
# Lock mechanism
# -----------------------------------------------------------------------------

@test "lock-glossary.sh exists and is executable" {
    [[ -x "$LOCK_SCRIPT_REAL" ]]
}

@test "lock-glossary.sh adds locked: true to all terms" {
    cat > "$GLOSSARY" <<'EOF'
terms:
  - fr: boucle
    en: loop
  - fr: agent
    en: agent
EOF
    GLOSSARY_PATH="$GLOSSARY" run "$LOCK_SCRIPT_REAL"
    [ "$status" -eq 0 ]
    grep -q "locked: true" "$GLOSSARY"
}

@test "lock-glossary.sh refuses to lock twice without --force" {
    cat > "$GLOSSARY" <<'EOF'
locked_at: "2026-04-30"
terms:
  - fr: boucle
    en: loop
    locked: true
EOF
    GLOSSARY_PATH="$GLOSSARY" run "$LOCK_SCRIPT_REAL"
    [ "$status" -ne 0 ]
}

@test "lock-glossary.sh allows re-lock with --force flag" {
    cat > "$GLOSSARY" <<'EOF'
locked_at: "2026-04-30"
terms:
  - fr: boucle
    en: loop
    locked: true
EOF
    GLOSSARY_PATH="$GLOSSARY" run "$LOCK_SCRIPT_REAL" --force
    [ "$status" -eq 0 ]
}
