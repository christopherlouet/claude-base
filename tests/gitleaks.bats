#!/usr/bin/env bats

# =============================================================================
# Tests pour la configuration gitleaks
# =============================================================================

load 'test_helper'

GITLEAKS_CONFIG="$BATS_TEST_DIRNAME/../.gitleaks.toml"

setup() {
    setup_test_dir
    skip_if_no_gitleaks
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Tests de configuration
# =============================================================================

@test ".gitleaks.toml existe" {
    [ -f "$GITLEAKS_CONFIG" ]
}

@test "gitleaks valide la configuration" {
    run gitleaks detect --config "$GITLEAKS_CONFIG" --no-git --source /dev/null 2>&1
    # Code 0 = pas de secrets trouvés (succès)
    # La config doit être valide pour que gitleaks s'exécute
    [[ "$status" -eq 0 ]] || [[ "$output" != *"error"* ]]
}

# =============================================================================
# Tests de détection
# =============================================================================

@test "gitleaks détecte un AWS Access Key" {
    echo 'aws_key = "AKIAIOSFODNN7EXAMPLE"' > "$TEST_DIR/test.env"
    run gitleaks detect --config "$GITLEAKS_CONFIG" --no-git --source "$TEST_DIR"
    [ "$status" -eq 1 ]
}

@test "gitleaks détecte un GitHub token" {
    echo 'token = "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"' > "$TEST_DIR/config.js"
    run gitleaks detect --config "$GITLEAKS_CONFIG" --no-git --source "$TEST_DIR"
    [ "$status" -eq 1 ]
}

@test "gitleaks détecte une clé privée" {
    cat > "$TEST_DIR/key.pem" << 'KEY'
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA0Z3VS5JJcds3xfn/ygWyF8PbnGy...
-----END RSA PRIVATE KEY-----
KEY
    run gitleaks detect --config "$GITLEAKS_CONFIG" --no-git --source "$TEST_DIR"
    [ "$status" -eq 1 ]
}

@test "gitleaks détecte un Stripe secret key" {
    echo 'STRIPE_KEY=sk_live_abcdefghijklmnopqrstuvwx' > "$TEST_DIR/.env"
    run gitleaks detect --config "$GITLEAKS_CONFIG" --no-git --source "$TEST_DIR"
    [ "$status" -eq 1 ]
}

@test "gitleaks ignore les placeholders" {
    echo 'API_KEY=your-api-key-here' > "$TEST_DIR/config.example"
    run gitleaks detect --config "$GITLEAKS_CONFIG" --no-git --source "$TEST_DIR"
    [ "$status" -eq 0 ]
}

@test "gitleaks ignore les variables d'environnement" {
    echo 'const key = process.env.API_KEY;' > "$TEST_DIR/config.js"
    run gitleaks detect --config "$GITLEAKS_CONFIG" --no-git --source "$TEST_DIR"
    [ "$status" -eq 0 ]
}

@test "gitleaks ignore les fichiers .md" {
    # Les .md sont dans l'allowlist
    echo 'secret_key = "sk_live_abcdefghijklmnopqrstuvwx"' > "$TEST_DIR/README.md"
    run gitleaks detect --config "$GITLEAKS_CONFIG" --no-git --source "$TEST_DIR"
    [ "$status" -eq 0 ]
}
