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

# --- Shell: the last-resort type (#656) ----------------------------------------

@test "detection: a repo of shell scripts is type shell" {
    mkdir -p "$TEST_DIR/p/bin"
    printf '#!/usr/bin/env bash\necho hi\n' > "$TEST_DIR/p/bin/tool.sh"
    run detect_in "$TEST_DIR/p"
    [[ "$output" == shell\|* ]]
}

@test "detection: bats tests alone also make a repo shell" {
    mkdir -p "$TEST_DIR/p/tests"
    printf '@test "x" { true; }\n' > "$TEST_DIR/p/tests/x.bats"
    run detect_in "$TEST_DIR/p"
    [[ "$output" == shell\|* ]]
}

@test "detection: shell is a last resort - a Node project with scripts stays Node" {
    _pkg "$TEST_DIR/p" '    "express": "^4.18.0"'
    mkdir -p "$TEST_DIR/p/scripts"
    printf 'echo hi\n' > "$TEST_DIR/p/scripts/setup.sh"
    run detect_in "$TEST_DIR/p"
    [[ "$output" == node-api\|* ]]
}

@test "detection: shell is a last resort - a Python project with scripts stays Python" {
    mkdir -p "$TEST_DIR/p"
    printf '[project]\nname = "x"\n' > "$TEST_DIR/p/pyproject.toml"
    printf 'echo hi\n' > "$TEST_DIR/p/run.sh"
    run detect_in "$TEST_DIR/p"
    [[ "$output" == python\|* ]]
}

@test "detection: the scripts the foundation installs do not make a project shell" {
    # Control first: the same layout with a script of the user's own is shell.
    mkdir -p "$TEST_DIR/p/scripts/hooks" "$TEST_DIR/p/.claude/hooks"
    printf 'echo hi\n' > "$TEST_DIR/p/scripts/hooks/guard.sh"
    printf 'echo hi\n' > "$TEST_DIR/p/scripts/substance-check.sh"
    printf 'echo hi\n' > "$TEST_DIR/p/.claude/hooks/x.sh"
    run detect_in "$TEST_DIR/p"
    [ "$output" = "|" ]
    printf 'echo hi\n' > "$TEST_DIR/p/scripts/deploy.sh"
    run detect_in "$TEST_DIR/p"
    [[ "$output" == shell\|* ]]
}

@test "detection: shell files under .git or node_modules do not count" {
    mkdir -p "$TEST_DIR/p/.git/hooks" "$TEST_DIR/p/node_modules/x"
    printf 'echo hi\n' > "$TEST_DIR/p/.git/hooks/pre-commit.sh"
    printf 'echo hi\n' > "$TEST_DIR/p/node_modules/x/install.sh"
    run detect_in "$TEST_DIR/p"
    [ "$output" = "|" ]
}

# --- Databases: named only when a config file mentions them (#665) -----------

# deps_in <dir> — run detect_stack and echo DETECTED_DEPENDENCIES, one per line.
# Fails when the detection run itself fails, so an absence check cannot pass on
# an empty output; callers assert $status.
deps_in() {
    local out
    out=$(bash -c "
        set -uo pipefail
        source '$REPO_ROOT/scripts/lib/common.sh' >/dev/null 2>&1 || exit 3
        source '$REPO_ROOT/scripts/lib/detection.sh' >/dev/null 2>&1 || exit 3
        detect_stack '$1' >/dev/null 2>&1 || exit 3
        printf 'DEP|%s\n' \${DETECTED_DEPENDENCIES[@]+\"\${DETECTED_DEPENDENCIES[@]}\"}
    ") || return 1
    printf '%s\n' "$out" | sed -n 's/^DEP|//p'
}

_no_db() { [[ "$1" != *PostgreSQL* && "$1" != *MongoDB* && "$1" != *Redis* ]]; }

@test "detection: a repo with no config file reports no database" {
    mkdir -p "$TEST_DIR/p"
    printf 'echo hi\n' > "$TEST_DIR/p/run.sh"
    run deps_in "$TEST_DIR/p"
    [ "$status" -eq 0 ]
    [[ "$output" == *Shell* ]] || false
    _no_db "$output"
}

@test "detection: a config that names no database reports none" {
    # Control: the same file naming redis is detected, so the run reads it.
    mkdir -p "$TEST_DIR/p"
    printf '{"cache": "redis"}\n' > "$TEST_DIR/p/config.json"
    run deps_in "$TEST_DIR/p"
    [ "$status" -eq 0 ]
    [[ "$output" == *Redis* ]] || false
    printf '{"name": "x"}\n' > "$TEST_DIR/p/config.json"
    run deps_in "$TEST_DIR/p"
    [ "$status" -eq 0 ]
    _no_db "$output"
}

@test "detection: a compose file naming postgres reports PostgreSQL only" {
    mkdir -p "$TEST_DIR/p"
    printf 'services:\n  db:\n    image: postgres:16\n' > "$TEST_DIR/p/docker-compose.yml"
    run deps_in "$TEST_DIR/p"
    [ "$status" -eq 0 ]
    [[ "$output" == *PostgreSQL* ]] || false
    [[ "$output" != *MongoDB* && "$output" != *Redis* ]]
}

@test "detection: mongo in a .env and redis in a spaced file name are both reported" {
    mkdir -p "$TEST_DIR/p/config"
    printf 'DB_URL=mongodb://localhost\n' > "$TEST_DIR/p/.env"
    printf 'cache: redis\n' > "$TEST_DIR/p/config/my cache.yml"
    run deps_in "$TEST_DIR/p"
    [ "$status" -eq 0 ]
    [[ "$output" == *MongoDB* ]] || false
    [[ "$output" == *Redis* ]] || false
    [[ "$output" != *PostgreSQL* ]]
}

@test "detection: upper-case environment variables name their database" {
    mkdir -p "$TEST_DIR/p"
    printf 'POSTGRES_DB=app\nREDIS_HOST=cache\nMONGO_INITDB_ROOT_USERNAME=x\n' > "$TEST_DIR/p/.env.example"
    run deps_in "$TEST_DIR/p"
    [ "$status" -eq 0 ]
    [[ "$output" == *PostgreSQL* ]] || false
    [[ "$output" == *Redis* ]] || false
    [[ "$output" == *MongoDB* ]]
}

@test "detection: lock files, node_modules and .claude do not name a database" {
    # Control: the same mention in a project config is detected.
    mkdir -p "$TEST_DIR/p/node_modules" "$TEST_DIR/p/.claude"
    printf '{"dependencies": {"ioredis": "5"}}\n' > "$TEST_DIR/p/app.json"
    run deps_in "$TEST_DIR/p"
    [ "$status" -eq 0 ]
    [[ "$output" == *Redis* ]] || false
    rm "$TEST_DIR/p/app.json"
    printf '{"packages": {"node_modules/ioredis": {}, "pg": "postgres", "mongo": 1}}\n' > "$TEST_DIR/p/package-lock.json"
    printf 'packages:\n  ioredis: 5\n  mongodb: 6\n' > "$TEST_DIR/p/pnpm-lock.yaml"
    printf '{"packages": {"node_modules/ioredis": {}}}\n' > "$TEST_DIR/p/node_modules/.package-lock.json"
    printf '{"note": "postgres mongo redis"}\n' > "$TEST_DIR/p/.claude/settings.json"
    run deps_in "$TEST_DIR/p"
    [ "$status" -eq 0 ]
    _no_db "$output"
}

@test "detection: a word that merely contains redis does not report Redis" {
    mkdir -p "$TEST_DIR/p"
    printf 'license: free to redistribute\n' > "$TEST_DIR/p/meta.yml"
    run deps_in "$TEST_DIR/p"
    [ "$status" -eq 0 ]
    [[ "$output" != *Redis* ]] || false
    printf 'cache: redis://localhost\n' >> "$TEST_DIR/p/meta.yml"
    run deps_in "$TEST_DIR/p"
    [ "$status" -eq 0 ]
    [[ "$output" == *Redis* ]]
}

# --- Every detectable type can select its rules -------------------------------

@test "detection: each detectable type resolves a rules whitelist containing its own rule" {
    # The link this whole change exists for: detection names a stack, and the
    # whitelist can then ship that stack's rule.
    local lib="$REPO_ROOT/scripts/lib/selected-set.sh"
    local t rule
    for pair in "astro:astro.md" "svelte:svelte.md" "php:php.md" \
                "ruby:ruby.md" "csharp:csharp.md" "vue:vue.md" "shell:shell.md"; do
        t="${pair%%:*}"; rule="${pair#*:}"
        run bash -c ". '$lib'; get_rules_for_type '$t'"
        [ "$status" -eq 0 ]
        [[ "$output" == *"$rule"* ]] || { echo "type '$t' does not select $rule" >&2; false; }
    done
}
