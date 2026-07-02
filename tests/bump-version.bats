#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/bump-version.sh — release-flow dry-run smoke
#
# The script propagates a new version across VERSION + README badge +
# README versioning-policy section. It is invoked once per release and a
# silent regression (e.g. a sed pattern that no longer matches a renamed
# badge) would drift the foundation across releases.
#
# All tests use --dry-run mode and assert against the REAL foundation
# repository, so they're safe to run in CI on every PR. The assertions
# focus on :
#   - argument validation (missing / malformed)
#   - --dry-run idempotency (zero filesystem changes)
#   - bump pattern correctness (the README badge sed pattern still matches)
#
# Together this gives the release flow a CI-runnable smoke test without
# needing a fixture repo or destructive operations.
# =============================================================================

load 'test_helper'

BUMP_VERSION="$BATS_TEST_DIRNAME/../scripts/bump-version.sh"
VERSION_FILE="$BATS_TEST_DIRNAME/../VERSION"

setup() {
    setup_test_dir
    # Snapshot the real VERSION + README state — assert it's unchanged at teardown
    VERSION_BEFORE=$(cat "$VERSION_FILE")
    README_HASH_BEFORE=$(md5sum "$BATS_TEST_DIRNAME/../README.md" | awk '{print $1}')
}

teardown() {
    # Hard safety net : any dry-run test that mutated the real repo is a bug
    local version_after
    version_after=$(cat "$VERSION_FILE")
    if [ "$VERSION_BEFORE" != "$version_after" ]; then
        echo "ERROR: VERSION file mutated by a --dry-run test (was $VERSION_BEFORE, now $version_after)" >&2
        # Restore for the rest of the suite
        echo "$VERSION_BEFORE" > "$VERSION_FILE"
    fi
    local readme_hash_after
    readme_hash_after=$(md5sum "$BATS_TEST_DIRNAME/../README.md" | awk '{print $1}')
    if [ "$README_HASH_BEFORE" != "$readme_hash_after" ]; then
        echo "ERROR: README.md mutated by a --dry-run test" >&2
    fi
    teardown_test_dir
}

# =============================================================================
# Argument validation
# =============================================================================

@test "bump-version.sh --help displays usage and the --dry-run flag" {
    run "$BUMP_VERSION" --help
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"USAGE"* ]]
    [[ "$output" == *"--dry-run"* ]]
    [[ "$output" == *"new-version"* ]]
}

@test "bump-version.sh without arguments exits non-zero with a clear error" {
    run "$BUMP_VERSION"
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"Missing version"* ]] || [[ "$output" == *"missing"* ]]
}

@test "bump-version.sh rejects non-semver format" {
    run "$BUMP_VERSION" "not-a-version" --dry-run
    [[ "$status" -ne 0 ]]
    [[ "$output" == *"Invalid version format"* ]] || [[ "$output" == *"X.Y.Z"* ]]
}

@test "bump-version.sh rejects two-component version (1.41)" {
    run "$BUMP_VERSION" "1.41" --dry-run
    [[ "$status" -ne 0 ]]
}

@test "bump-version.sh rejects pre-release suffix in semver" {
    run "$BUMP_VERSION" "1.42.0-beta" --dry-run
    [[ "$status" -ne 0 ]]
}

# =============================================================================
# Dry-run safety — must not mutate the real repo
# =============================================================================

@test "bump-version.sh 99.99.99 --dry-run exits 0 and prints DRY-RUN traces" {
    run "$BUMP_VERSION" 99.99.99 --dry-run
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"DRY-RUN"* ]]
    [[ "$output" == *"99.99.99"* ]]
}

@test "bump-version.sh 99.99.99 --dry-run leaves VERSION file unchanged" {
    local before
    before=$(cat "$VERSION_FILE")
    run "$BUMP_VERSION" 99.99.99 --dry-run
    [[ "$status" -eq 0 ]]
    [ "$(cat "$VERSION_FILE")" = "$before" ]
}

@test "bump-version.sh 99.99.99 --dry-run leaves README.md unchanged" {
    local before
    before=$(md5sum "$BATS_TEST_DIRNAME/../README.md" | awk '{print $1}')
    run "$BUMP_VERSION" 99.99.99 --dry-run
    [[ "$status" -eq 0 ]]
    local after
    after=$(md5sum "$BATS_TEST_DIRNAME/../README.md" | awk '{print $1}')
    [ "$before" = "$after" ]
}

# =============================================================================
# Release-flow regression — the sed patterns still match the real repo
# Catches the "silent killer" mentioned in bump-version.sh:126 : if a future
# README rewrite renames the badge or moves the versioning-policy table, the
# bump becomes a no-op and the foundation drifts across releases.
# =============================================================================

@test "bump-version.sh dry-run finds the README badge pattern (no drift warning)" {
    run "$BUMP_VERSION" 99.99.99 --dry-run
    [[ "$status" -eq 0 ]]
    # The script emits a [!] warning when a pattern is not found ; absence of
    # that warning for README.md confirms the badge sed pattern still matches.
    [[ "$output" != *"README.md: Version badge — pattern not found"* ]]
}

@test "bump-version.sh dry-run finds the README release-pin examples (no drift warning)" {
    run "$BUMP_VERSION" 99.99.99 --dry-run
    [[ "$status" -eq 0 ]]
    # The self-heal for the ```bash --ref / TAG= pin snippets must keep matching
    # the CURRENT_VERSION, else the reproducible-install examples silently rot at
    # every release (they live inside code fences the version markers can't reach).
    [[ "$output" != *"install --ref pin — pattern not found"* ]]
    [[ "$output" != *"SHA256SUMS TAG pin — pattern not found"* ]]
}

@test "bump-version.sh dry-run reports a non-zero change count" {
    run "$BUMP_VERSION" 99.99.99 --dry-run
    [[ "$status" -eq 0 ]]
    # Output contains "[DRY-RUN] N files would be modified" — assert N >= 1
    [[ "$output" =~ \[DRY-RUN\][[:space:]]+[1-9][0-9]*[[:space:]]+files\ would\ be\ modified ]]
}
