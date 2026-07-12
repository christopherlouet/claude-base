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
    # An empty dir has no secrets → exit 0. A broken .gitleaks.toml makes gitleaks
    # error out non-zero, so a clean exit genuinely proves the config loads/runs.
    # (The prior form passed `2>&1` as a positional argument — bats' `run` does
    # not interpret redirections — and used an OR that could never fail: gitleaks
    # prints capitalised "Error"/"ERRO", so the lowercase "error" test never hit.)
    mkdir -p "$TEST_DIR/empty-src"
    run gitleaks detect --config "$GITLEAKS_CONFIG" --no-git --source "$TEST_DIR/empty-src"
    [ "$status" -eq 0 ]
}

@test "gitleaks: the real repo scans clean with the shipped config (self-application)" {
    # The true regression guard: fails the day a real secret lands OR a new
    # planted fixture is added without a path allowlist (this is the test that
    # would have caught the 30 pre-existing findings the enforcing CI job needs
    # gone). Working-tree scan (no history) for speed.
    run gitleaks detect --config "$GITLEAKS_CONFIG" --no-git --source "$BATS_TEST_DIRNAME/.." --no-banner
    [ "$status" -eq 0 ]
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
