#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/lib/trust-score.sh + scripts/lib/curation-common.sh
# (Slice 2, specs/marketplace-curation-engine).
#
# Fully OFFLINE and DETERMINISTIC: `gh` is replaced by a fake binary on PATH that
# emits a canned repo JSON (no network), and `CURATION_NOW` pins "today" so the
# recency math is stable. No LLM, no real gh, no clock dependence.
# =============================================================================

load 'test_helper'

TRUST_LIB="$BATS_TEST_DIRNAME/../scripts/lib/trust-score.sh"
COMMON_LIB="$BATS_TEST_DIRNAME/../scripts/lib/curation-common.sh"

setup() {
    setup_test_dir
    mkdir -p "$TEST_DIR/fakebin"
}

teardown() {
    teardown_test_dir
}

# fake_gh_returns <json> — install a fake `gh` that prints <json> for any
# `gh api ...` call (one repo per test, so the path is irrelevant).
fake_gh_returns() {
    printf '%s' "$1" > "$TEST_DIR/repo.json"
    cat > "$TEST_DIR/fakebin/gh" <<EOF
#!/usr/bin/env bash
cat "$TEST_DIR/repo.json"
EOF
    chmod +x "$TEST_DIR/fakebin/gh"
}

# fake_gh_errors — install a fake `gh` that always fails (simulates API/network
# error or rate-limit exhaustion).
fake_gh_errors() {
    cat > "$TEST_DIR/fakebin/gh" <<'EOF'
#!/usr/bin/env bash
echo "gh: HTTP 503" >&2
exit 1
EOF
    chmod +x "$TEST_DIR/fakebin/gh"
}

# repo_json — build a GitHub repo JSON with overridable fields.
# Args: stars forks pushed_at archived spdx_id
repo_json() {
    jq -cn \
        --argjson stars "$1" --argjson forks "$2" \
        --arg pushed "$3" --argjson archived "$4" --arg lic "$5" \
        '{stargazers_count:$stars, forks_count:$forks, pushed_at:$pushed,
          archived:$archived, license:{spdx_id:$lic}}'
}

# score <repo> <track> — run trust_score with the fake gh on PATH, "now" pinned,
# and gh retries collapsed so the test never sleeps. Operational logging goes to
# stderr (not under test here); discard it so $output is the pure JSON verdict.
score() {
    run env PATH="$TEST_DIR/fakebin:$PATH" CURATION_NOW=2026-06-13 \
        CURATION_GH_RETRIES=1 CURATION_GH_BACKOFF=0 \
        bash -c "source '$TRUST_LIB'; trust_score '$1' '$2' 2>/dev/null"
}

verdict_of() { printf '%s' "$1" | jq -r '.verdict'; }

# =============================================================================
# curation-common — pure-bash date math (portable, no `date` dependency)
# =============================================================================

@test "curation_days_since computes whole days between two dates" {
    run env CURATION_NOW=2026-06-13 bash -c "source '$COMMON_LIB'; curation_days_since '2026-04-28T07:24:36Z'"
    [[ "$status" -eq 0 ]]
    [[ "$output" -eq 46 ]]
}

@test "curation_days_since handles a leap day correctly" {
    run env CURATION_NOW=2024-03-01 bash -c "source '$COMMON_LIB'; curation_days_since '2024-02-28'"
    [[ "$status" -eq 0 ]]
    [[ "$output" -eq 2 ]]   # 2024 is a leap year: 28 -> 29 -> 01 = 2 days
}

@test "curation_days_since returns same-day as 0" {
    run env CURATION_NOW=2026-06-13 bash -c "source '$COMMON_LIB'; curation_days_since '2026-06-13T23:59:59Z'"
    [[ "$status" -eq 0 ]]
    [[ "$output" -eq 0 ]]
}

@test "curation_days_since rejects an unparseable date" {
    run bash -c "source '$COMMON_LIB'; curation_days_since 'not-a-date'"
    [[ "$status" -ne 0 ]]
}

@test "curation_days_since does not read leading-zero months as octal" {
    # 08/09 would be invalid octal — must be parsed base-10.
    run env CURATION_NOW=2026-09-10 bash -c "source '$COMMON_LIB'; curation_days_since '2026-08-31'"
    [[ "$status" -eq 0 ]]
    [[ "$output" -eq 10 ]]
}

# =============================================================================
# trust_score — authority track (no popularity bar, EF-003)
# =============================================================================

@test "trust_score: authority track passes a low-star but maintained repo" {
    fake_gh_returns "$(repo_json 7 1 '2026-06-10T00:00:00Z' false MIT)"
    score "vendor/own-skill" authority
    [[ "$status" -eq 0 ]]
    [[ "$(verdict_of "$output")" == "pass" ]]
}

@test "trust_score: authority track does NOT apply the popularity bar" {
    fake_gh_returns "$(repo_json 3 0 '2026-06-01T00:00:00Z' false Apache-2.0)"
    score "vendor/tiny" authority
    [[ "$(verdict_of "$output")" == "pass" ]]
}

# =============================================================================
# trust_score — community track (high popularity bar)
# =============================================================================

@test "trust_score: community track passes above the popularity bar" {
    fake_gh_returns "$(repo_json 2012 100 '2026-06-03T00:00:00Z' false MIT)"
    score "person/skill" community
    [[ "$(verdict_of "$output")" == "pass" ]]
}

@test "trust_score: community track FAILS below the popularity bar" {
    fake_gh_returns "$(repo_json 100 5 '2026-06-03T00:00:00Z' false MIT)"
    score "person/small" community
    [[ "$status" -eq 0 ]]
    [[ "$(verdict_of "$output")" == "fail" ]]
    [[ "$output" == *"below-popularity-bar"* ]]
}

# =============================================================================
# trust_score — archive / recency / license
# =============================================================================

@test "trust_score: an archived repo fails regardless of track" {
    fake_gh_returns "$(repo_json 5000 200 '2026-06-10T00:00:00Z' true MIT)"
    score "vendor/dead" authority
    [[ "$(verdict_of "$output")" == "fail" ]]
    [[ "$output" == *"archived"* ]]
}

@test "trust_score: an abandoned (stale) repo fails" {
    fake_gh_returns "$(repo_json 5000 200 '2024-01-01T00:00:00Z' false MIT)"
    score "vendor/stale" authority
    [[ "$(verdict_of "$output")" == "fail" ]]
    [[ "$output" == *"stale:"* ]]
}

@test "trust_score: a repo pushed exactly at the staleness boundary still passes" {
    # maxStaleDays = 365; 2025-06-13 is exactly 365 days before 2026-06-13.
    fake_gh_returns "$(repo_json 5000 200 '2025-06-13T00:00:00Z' false MIT)"
    score "vendor/edge" authority
    [[ "$(verdict_of "$output")" == "pass" ]]
}

@test "trust_score: a missing license flags (soft), never fails" {
    fake_gh_returns "$(repo_json 5000 200 '2026-06-10T00:00:00Z' false NONE)"
    score "vendor/nolicense" authority
    [[ "$(verdict_of "$output")" == "flag" ]]
    [[ "$output" == *"missing-license"* ]]
}

@test "trust_score: NOASSERTION license is treated as present (passes)" {
    fake_gh_returns "$(repo_json 2012 100 '2026-06-03T00:00:00Z' false NOASSERTION)"
    score "person/skill" community
    [[ "$(verdict_of "$output")" == "pass" ]]
}

@test "trust_score: reports ALL failing reasons, not just the first" {
    fake_gh_returns "$(repo_json 100 5 '2024-01-01T00:00:00Z' true MIT)"
    score "person/multi" community
    [[ "$(verdict_of "$output")" == "fail" ]]
    [[ "$output" == *"archived"* ]]
    [[ "$output" == *"stale:"* ]]
    [[ "$output" == *"below-popularity-bar"* ]]
}

# =============================================================================
# trust_score — emitted signals + fail-safe + usage
# =============================================================================

@test "trust_score: emits the captured public signals" {
    fake_gh_returns "$(repo_json 82 3 '2026-06-12T17:14:23Z' false MIT)"
    score "apollographql/skills" authority
    [[ "$(printf '%s' "$output" | jq -r '.stars')" -eq 82 ]]
    [[ "$(printf '%s' "$output" | jq -r '.license')" == "MIT" ]]
    [[ "$(printf '%s' "$output" | jq -r '.ageDays')" -eq 1 ]]
}

@test "trust_score: FAILS SAFE on gh error (verdict=error, exit 3)" {
    fake_gh_errors
    score "vendor/x" authority
    [[ "$status" -eq 3 ]]
    [[ "$(verdict_of "$output")" == "error" ]]
    [[ "$output" == *"gh-unavailable"* ]]
}

@test "trust_score: rejects an unknown track (exit 2)" {
    fake_gh_returns "$(repo_json 100 5 '2026-06-10T00:00:00Z' false MIT)"
    score "vendor/x" vendor
    [[ "$status" -eq 2 ]]
}
