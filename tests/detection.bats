#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/lib/detection.sh — stack detection.
#
# DETECTED_TYPE is the value that drives the rules whitelist
# (get_rules_for_type), the CLAUDE.md template choice and the recorded
# .projectType. A stack that detection cannot name can never receive its own
# rule — which is exactly how astro/svelte/php/ruby/csharp rules sat in the
# repo unreachable by any install.
# =============================================================================

load 'test_helper'

REPO_ROOT="$BATS_TEST_DIRNAME/.."

setup() { setup_test_dir; }
teardown() { teardown_test_dir; }

# detect_in <fixture_subdir> — run the full detect_stack on a fixture and echo
# "TYPE|FRAMEWORK". detection.sh refuses to load without common.sh (guard), and
# detect_stack prints its report to stdout, so the values are emitted on a
# marker line and grepped back out.
detect_in() {
    local dir="$1"
    run bash -c "
        set -uo pipefail
        source '$REPO_ROOT/scripts/lib/common.sh' >/dev/null 2>&1
        source '$REPO_ROOT/scripts/lib/detection.sh' >/dev/null 2>&1
        detect_stack '$dir' >/dev/null 2>&1
        printf 'RESULT|%s|%s\n' \"\$DETECTED_TYPE\" \"\$DETECTED_FRAMEWORK\"
    "
    [ "$status" -eq 0 ]
    printf '%s\n' "$output" | sed -n 's/^RESULT|//p'
}

# _pkg <dir> <json-body> — write a package.json fixture.
_pkg() {
    mkdir -p "$1"
    printf '{\n  "name": "fixture",\n  "dependencies": {\n%s\n  }\n}\n' "$2" > "$1/package.json"
}

# --- Existing types must not regress ------------------------------------------

@test "detection: a React project is still type react" {
    _pkg "$TEST_DIR/p" '    "react": "^19.0.0"'
    run detect_in "$TEST_DIR/p"
    [[ "$output" == react\|* ]]
}

@test "detection: a Vue project is still type vue" {
    _pkg "$TEST_DIR/p" '    "vue": "^3.4.0"'
    run detect_in "$TEST_DIR/p"
    [[ "$output" == vue\|* ]]
}

@test "detection: a Python project is still type python" {
    mkdir -p "$TEST_DIR/p"
    printf 'flask\n' > "$TEST_DIR/p/requirements.txt"
    run detect_in "$TEST_DIR/p"
    [[ "$output" == python\|* ]]
}

# --- Astro --------------------------------------------------------------------

@test "detection: an Astro project is type astro" {
    _pkg "$TEST_DIR/p" '    "astro": "^5.0.0"'
    run detect_in "$TEST_DIR/p"
    [[ "$output" == "astro|Astro" ]]
}

@test "detection: Astro wins over a React island (integrations pull react in)" {
    # An Astro site using @astrojs/react has BOTH deps. Matching react first
    # would mislabel every Astro project that renders one React component.
    _pkg "$TEST_DIR/p" '    "astro": "^5.0.0",
    "react": "^19.0.0"'
    run detect_in "$TEST_DIR/p"
    [[ "$output" == astro\|* ]]
}

# --- Svelte -------------------------------------------------------------------

@test "detection: a Svelte project is type svelte (was silently generic)" {
    _pkg "$TEST_DIR/p" '    "svelte": "^5.0.0"'
    run detect_in "$TEST_DIR/p"
    [[ "$output" == "svelte|Svelte" ]]
}

@test "detection: SvelteKit is reported as the framework" {
    _pkg "$TEST_DIR/p" '    "svelte": "^5.0.0",
    "@sveltejs/kit": "^2.0.0"'
    run detect_in "$TEST_DIR/p"
    [[ "$output" == "svelte|SvelteKit" ]]
}

# --- PHP ----------------------------------------------------------------------

@test "detection: a composer.json project is type php" {
    mkdir -p "$TEST_DIR/p"
    printf '{"require": {"php": "^8.3"}}\n' > "$TEST_DIR/p/composer.json"
    run detect_in "$TEST_DIR/p"
    [[ "$output" == "php|PHP" ]]
}

@test "detection: Laravel and Symfony are reported as the framework" {
    mkdir -p "$TEST_DIR/a" "$TEST_DIR/b"
    printf '{"require": {"laravel/framework": "^11.0"}}\n' > "$TEST_DIR/a/composer.json"
    printf '{"require": {"symfony/framework-bundle": "^7.0"}}\n' > "$TEST_DIR/b/composer.json"
    run detect_in "$TEST_DIR/a"
    [[ "$output" == "php|Laravel" ]]
    run detect_in "$TEST_DIR/b"
    [[ "$output" == "php|Symfony" ]]
}

# --- Ruby ---------------------------------------------------------------------

@test "detection: a Gemfile project is type ruby" {
    mkdir -p "$TEST_DIR/p"
    printf "source 'https://rubygems.org'\ngem 'nokogiri'\n" > "$TEST_DIR/p/Gemfile"
    run detect_in "$TEST_DIR/p"
    [[ "$output" == "ruby|Ruby" ]]
}

@test "detection: Rails is reported as the framework" {
    mkdir -p "$TEST_DIR/p"
    printf "source 'https://rubygems.org'\ngem 'rails', '~> 8.0'\n" > "$TEST_DIR/p/Gemfile"
    run detect_in "$TEST_DIR/p"
    [[ "$output" == "ruby|Ruby on Rails" ]]
}

# --- C# / .NET ----------------------------------------------------------------

@test "detection: a .csproj project is type csharp" {
    mkdir -p "$TEST_DIR/p"
    printf '<Project Sdk="Microsoft.NET.Sdk"></Project>\n' > "$TEST_DIR/p/App.csproj"
    run detect_in "$TEST_DIR/p"
    [[ "$output" == "csharp|.NET" ]]
}

@test "detection: a .sln at the root also detects csharp" {
    mkdir -p "$TEST_DIR/p"
    printf 'Microsoft Visual Studio Solution File\n' > "$TEST_DIR/p/App.sln"
    run detect_in "$TEST_DIR/p"
    [[ "$output" == csharp\|* ]]
}

@test "detection: ASP.NET Core is reported as the framework" {
    mkdir -p "$TEST_DIR/p"
    printf '<Project Sdk="Microsoft.NET.Sdk.Web"></Project>\n' > "$TEST_DIR/p/Api.csproj"
    run detect_in "$TEST_DIR/p"
    [[ "$output" == "csharp|ASP.NET Core" ]]
}

# --- Precedence ---------------------------------------------------------------

@test "detection: Node wins when a JS project also carries a Gemfile" {
    # Mirrors how python/go/java already yield to an already-set type: the
    # sub-detectors only claim DETECTED_TYPE when nothing else did.
    _pkg "$TEST_DIR/p" '    "react": "^19.0.0"'
    printf "source 'https://rubygems.org'\n" > "$TEST_DIR/p/Gemfile"
    run detect_in "$TEST_DIR/p"
    [[ "$output" == react\|* ]]
}

# --- Every detectable type can select its rules -------------------------------

@test "detection: each detectable type resolves a rules whitelist containing its own rule" {
    # The link this whole change exists for: detection names a stack, and the
    # whitelist can then ship that stack's rule.
    local lib="$REPO_ROOT/scripts/lib/selected-set.sh"
    local t rule
    for pair in "astro:astro.md" "svelte:svelte.md" "php:php.md" \
                "ruby:ruby.md" "csharp:csharp.md" "vue:vue.md"; do
        t="${pair%%:*}"; rule="${pair#*:}"
        run bash -c ". '$lib'; get_rules_for_type '$t'"
        [ "$status" -eq 0 ]
        [[ "$output" == *"$rule"* ]] || { echo "type '$t' does not select $rule" >&2; false; }
    done
}
