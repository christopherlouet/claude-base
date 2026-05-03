#!/usr/bin/env bats

# =============================================================================
# Tests for the gitleaks configuration
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
# Configuration tests
# =============================================================================

@test ".gitleaks.toml exists" {
    [ -f "$GITLEAKS_CONFIG" ]
}

@test "gitleaks validates the configuration" {
    run gitleaks detect --config "$GITLEAKS_CONFIG" --no-git --source /dev/null 2>&1
    # Code 0 = no secrets found (success)
    # The config must be valid for gitleaks to run
    [[ "$status" -eq 0 ]] || [[ "$output" != *"error"* ]]
}

# =============================================================================
# Detection tests
# =============================================================================

@test "gitleaks detects an AWS Access Key" {
    echo 'aws_key = "AKIAIOSFODNN7EXAMPLE"' > "$TEST_DIR/test.env"
    run gitleaks detect --config "$GITLEAKS_CONFIG" --no-git --source "$TEST_DIR"
    [ "$status" -eq 1 ]
}

@test "gitleaks detects a GitHub token" {
    echo 'token = "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"' > "$TEST_DIR/config.js"
    run gitleaks detect --config "$GITLEAKS_CONFIG" --no-git --source "$TEST_DIR"
    [ "$status" -eq 1 ]
}

@test "gitleaks detects a private key" {
    cat > "$TEST_DIR/key.pem" << 'KEY'
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA0Z3VS5JJcds3xfn/ygWyF8PbnGy...
-----END RSA PRIVATE KEY-----
KEY
    run gitleaks detect --config "$GITLEAKS_CONFIG" --no-git --source "$TEST_DIR"
    [ "$status" -eq 1 ]
}

@test "gitleaks detects a Stripe secret key" {
    echo 'STRIPE_KEY=sk_live_abcdefghijklmnopqrstuvwx' > "$TEST_DIR/.env"
    run gitleaks detect --config "$GITLEAKS_CONFIG" --no-git --source "$TEST_DIR"
    [ "$status" -eq 1 ]
}

@test "gitleaks ignores placeholders" {
    echo 'API_KEY=your-api-key-here' > "$TEST_DIR/config.example"
    run gitleaks detect --config "$GITLEAKS_CONFIG" --no-git --source "$TEST_DIR"
    [ "$status" -eq 0 ]
}

@test "gitleaks ignores environment variables" {
    echo 'const key = process.env.API_KEY;' > "$TEST_DIR/config.js"
    run gitleaks detect --config "$GITLEAKS_CONFIG" --no-git --source "$TEST_DIR"
    [ "$status" -eq 0 ]
}

@test "gitleaks ignores .md files" {
    # .md files are in the allowlist
    echo 'secret_key = "sk_live_abcdefghijklmnopqrstuvwx"' > "$TEST_DIR/README.md"
    run gitleaks detect --config "$GITLEAKS_CONFIG" --no-git --source "$TEST_DIR"
    [ "$status" -eq 0 ]
}
