#!/usr/bin/env bats

# =============================================================================
# Tests for the GitHub Actions workflows an install puts into a DOWNSTREAM
# project (`--ci`, `--all`, a preset with defaults.ci, `--ci-existing`).
#
# The installer used to copy the foundation's OWN .github/workflows/: six files
# that lint ./scripts with ShellCheck, run the bats suite, validate.sh, the
# counts gate, a Docusaurus deploy, and Gitleaks against the foundation's
# .gitleaks.toml. None of that exists in a user's project, so its first push
# went red. Same failure as the husky hooks (tests/husky-downstream.bats), same
# cure: the source is templates/github-workflows/, never .github/workflows/.
# =============================================================================

load 'test_helper'

NEW_PROJECT_SCRIPT="$BATS_TEST_DIRNAME/../scripts/new-project.sh"
BASE_REPO="$BATS_TEST_DIRNAME/.."
TEMPLATES="$BASE_REPO/templates/github-workflows"

setup() {
    setup_test_dir
    PROJ="$TEST_DIR/proj"
    mkdir -p "$PROJ"
}

teardown() {
    teardown_test_dir
}

# References to surfaces only the foundation checkout has. Comments are
# stripped first: a template may NAME the foundation in prose.
foundation_refs() {
    sed 's/#.*//' "$@" 2>/dev/null \
        | grep -nE 'scripts/|bats|validate\.sh|\.gitleaks\.toml|website|counts\.json|shellcheck|install\.sh' \
        || true
}

# Lines where a github.event / head_ref expression is substituted into a
# `run:` body — a crafted PR title then executes as shell source. Such values
# must reach the shell through `env:`.
run_injections() {
    awk '
        function ind(s) { match(s, /^ */); return RLENGTH }
        function tainted(s) { return s ~ /\$\{\{.*github(\.event|\.head_ref|\[)/ }
        {
            if (inrun && $0 !~ /^[[:space:]]*$/ && ind($0) <= runind) inrun = 0
            if (inrun && tainted($0)) print FILENAME ":" FNR
            if ($0 ~ /^[[:space:]]*(- )?run:/) {
                # Block scalars and plain scalars alike continue on the more
                # indented lines that follow, so both open a run body.
                runind = ind($0)
                inrun = 1
                rest = $0
                sub(/^[[:space:]]*(- )?run:[[:space:]]*/, "", rest)
                if (tainted(rest)) print FILENAME ":" FNR
            }
        }
    ' "$@"
}

# Every installed workflow must be a byte-identical downstream template.
assert_only_templates_installed() {
    local wf name
    for wf in "$PROJ/.github/workflows/"*; do
        name=$(basename "$wf")
        [ -f "$TEMPLATES/$name" ] || {
            printf 'installed %s has no downstream template\n' "$name" >&2
            return 1
        }
        cmp -s "$wf" "$TEMPLATES/$name" || {
            printf 'installed %s differs from its template\n' "$name" >&2
            return 1
        }
    done
}

# =============================================================================
# Anti-vacuity controls — each scanner is shown capable of a positive first.
# =============================================================================

@test "ci scanner: sees foundation-only references in the foundation's own workflows" {
    run foundation_refs "$BASE_REPO/.github/workflows/ci.yml"
    [ -n "$output" ]
    [[ "$output" == *"bats"* ]]
}

@test "injection scanner: flags an event expression inside a run block" {
    cat > "$TEST_DIR/bad.yml" <<'YML'
jobs:
  x:
    steps:
      - name: Check for WIP
        run: |
          if [[ "${{ github.event.pull_request.title }}" == *"WIP"* ]]; then
            exit 1
          fi
      - run: echo "${{ github.head_ref }}"
YML
    run run_injections "$TEST_DIR/bad.yml"
    [ "$(printf '%s\n' "$output" | grep -c 'bad.yml')" -eq 2 ]
}

@test "injection scanner: flags the forms a first version missed" {
    # Found in review (actionlint flagged all of them): a `}` inside the
    # expression, bracket access, and a plain scalar continued on the next line.
    cat > "$TEST_DIR/bad2.yml" <<'YML'
jobs:
  x:
    steps:
      - run: echo "${{ format('{0}', github.event.pull_request.title) }}"
      - run: echo "${{ github['head_ref'] }}"
      - run: echo start
          "${{ github.event.pull_request.body }}"
YML
    run run_injections "$TEST_DIR/bad2.yml"
    [ "$(printf '%s\n' "$output" | grep -c 'bad2.yml')" -eq 3 ]
}

@test "injection scanner: an event expression passed through env is not flagged" {
    cat > "$TEST_DIR/good.yml" <<'YML'
jobs:
  x:
    steps:
      - name: Check for WIP
        env:
          PR_TITLE: ${{ github.event.pull_request.title }}
        run: |
          case "$PR_TITLE" in *WIP*) exit 1 ;; esac
      - run: echo done
YML
    run run_injections "$TEST_DIR/good.yml"
    [ -z "$output" ]
}

# =============================================================================
# The templates themselves.
# =============================================================================

@test "templates: the three downstream workflows exist" {
    [ -f "$TEMPLATES/ci.yml" ]
    [ -f "$TEMPLATES/pr-check.yml" ]
    [ -f "$TEMPLATES/security.yml" ]
}

@test "templates: no reference to a foundation-only surface" {
    [ -f "$TEMPLATES/ci.yml" ]  # an empty glob would pass vacuously
    run foundation_refs "$TEMPLATES/"*.yml
    [ -z "$output" ] || { printf '%s\n' "$output" >&2; return 1; }
}

@test "templates: no github.event expression substituted into a run body" {
    [ -f "$TEMPLATES/ci.yml" ]  # an empty glob would pass vacuously
    run run_injections "$TEMPLATES/"*.yml
    [ -z "$output" ] || { printf '%s\n' "$output" >&2; return 1; }
}

@test "self-application: the foundation's own workflows carry no run-body injection" {
    run run_injections "$BASE_REPO/.github/workflows/"*.yml
    [ -z "$output" ] || { printf '%s\n' "$output" >&2; return 1; }
}

@test "templates: every file parses as YAML" {
    local parser=""
    if command -v yq >/dev/null 2>&1; then
        parser=yq
    elif python3 -c 'import yaml' >/dev/null 2>&1; then
        parser=python
    else
        skip "no YAML parser (yq or python3-yaml)"
    fi
    local f
    for f in "$TEMPLATES/"*.yml; do
        if [ "$parser" = yq ]; then
            yq eval '.jobs | keys' "$f" >/dev/null || { echo "invalid: $f" >&2; return 1; }
        else
            python3 -c 'import sys, yaml; d = yaml.safe_load(open(sys.argv[1])); assert d["jobs"]' "$f" \
                || { echo "invalid: $f" >&2; return 1; }
        fi
    done
}

@test "templates: ci.yml skips npm's placeholder test script instead of failing on it" {
    # `npm init -y` writes a test script that always exits 1: a CI running it
    # is red before the project has a single test.
    grep -qF 'Error: no test specified' "$TEMPLATES/ci.yml"
}

# =============================================================================
# Every install path lands the templates, and only them.
# =============================================================================

@test "install --ci: lands the downstream templates, not the foundation's workflows" {
    run bash "$NEW_PROJECT_SCRIPT" -y --ci "$PROJ"
    [ "$status" -eq 0 ]
    [ -f "$PROJ/.github/workflows/ci.yml" ]
    [ -f "$PROJ/.github/workflows/pr-check.yml" ]
    [ -f "$PROJ/.github/workflows/security.yml" ]
    [ ! -e "$PROJ/.github/workflows/release.yml" ]
    [ ! -e "$PROJ/.github/workflows/docs.yml" ]
    [ ! -e "$PROJ/.github/workflows/dependabot-auto-merge.yml" ]
    assert_only_templates_installed
}

@test "install --preset (defaults.ci): lands the downstream templates" {
    run bash "$NEW_PROJECT_SCRIPT" -y --preset nextjs "$PROJ"
    [ "$status" -eq 0 ]
    [ -f "$PROJ/.github/workflows/ci.yml" ]
    assert_only_templates_installed
}

@test "install --ci-existing replace: the replacement is the downstream templates" {
    mkdir -p "$PROJ/.github/workflows"
    echo "name: Custom" > "$PROJ/.github/workflows/custom.yml"

    run bash "$NEW_PROJECT_SCRIPT" -y --ci-existing replace "$PROJ"
    [ "$status" -eq 0 ]
    [ ! -f "$PROJ/.github/workflows/custom.yml" ]
    [ -f "$PROJ/.github/workflows/ci.yml" ]
    assert_only_templates_installed
}

@test "install --ci-existing merge: added workflows are downstream templates, the project's own is kept" {
    mkdir -p "$PROJ/.github/workflows"
    printf 'name: Custom\non: [push]\njobs:\n  t:\n    runs-on: ubuntu-latest\n    steps:\n      - run: npm test\n' \
        > "$PROJ/.github/workflows/custom.yml"
    local before; before=$(cat "$PROJ/.github/workflows/custom.yml")

    run bash "$NEW_PROJECT_SCRIPT" -y --ci-existing merge "$PROJ"
    [ "$status" -eq 0 ]
    [ "$(cat "$PROJ/.github/workflows/custom.yml")" = "$before" ]
    [ -f "$PROJ/.github/workflows/ci.yml" ]
    [ -f "$PROJ/.github/workflows/security.yml" ]
    [ -f "$PROJ/.github/workflows/pr-check.yml" ]
    rm "$PROJ/.github/workflows/custom.yml"
    assert_only_templates_installed
}

@test "install --ci-existing merge: a project security.yml without a secret scan is REPORTED" {
    # Found in review: "Security audit" missing + a security.yml the project
    # already has (CodeQL only) added nothing and said nothing.
    mkdir -p "$PROJ/.github/workflows"
    printf 'name: Security\non: [push]\njobs:\n  c:\n    runs-on: ubuntu-latest\n    steps:\n      - uses: github/codeql-action/analyze@v3\n' \
        > "$PROJ/.github/workflows/security.yml"
    run bash "$NEW_PROJECT_SCRIPT" -y --ci-existing merge "$PROJ"
    [ "$status" -eq 0 ]
    [[ "$output" == *"security.yml"* ]]
    [[ "$output" == *"secret"* ]]
}

@test "templates: ci.yml installs corepack before enabling it (Node 25+ ships none)" {
    local enable install
    enable=$(grep -n 'corepack enable' "$TEMPLATES/ci.yml" | head -1 | cut -d: -f1)
    install=$(grep -n 'npm install -g --force corepack' "$TEMPLATES/ci.yml" | head -1 | cut -d: -f1)
    [ -n "$enable" ] && [ -n "$install" ] && [ "$install" -lt "$enable" ]
}

@test "templates: ci.yml does not fail a Go module that has no package yet" {
    grep -q 'go list ./...' "$TEMPLATES/ci.yml"
}

@test "install --ci-existing merge: a missing release automation is REPORTED, not silently skipped" {
    # There is deliberately no downstream release template: a release process
    # is the project's decision. Saying nothing would read as "added".
    mkdir -p "$PROJ/.github/workflows"
    printf 'name: Custom\non: [push]\njobs:\n  t:\n    runs-on: ubuntu-latest\n    steps:\n      - run: npm test\n' \
        > "$PROJ/.github/workflows/custom.yml"

    run bash "$NEW_PROJECT_SCRIPT" -y --ci-existing merge "$PROJ"
    [ "$status" -eq 0 ]
    [ ! -e "$PROJ/.github/workflows/release.yml" ]
    [[ "$output" == *"release"* ]]
}
