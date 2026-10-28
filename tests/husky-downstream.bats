#!/usr/bin/env bats

# =============================================================================
# Tests for the .husky hooks an install puts into a DOWNSTREAM project.
#
# The foundation's own .husky/* invoke foundation-only scripts: the private
# names check, the derived-counts self-heal, and preflight. None of the three
# is in scripts/lib/minimal-manifest.txt, so an install never puts them in the
# target. Copying .husky verbatim therefore ships hooks that call files which
# are not there — and because git-hooks-wire.sh sets core.hooksPath on the
# first Claude session, those hooks go live and refuse EVERY commit and push.
#
# Measured on a real install before the fix: the commit was refused with
# "bash: scripts/private-names-check.sh: No such file or directory", and the
# same commit with core.hooksPath unset succeeded. Both failure modes the
# guardrail-cleanup spec names appear here in sequence — a gate reported as
# installed while inert, then a gate that blocks all work.
# =============================================================================

load 'test_helper'

NEW_PROJECT_SCRIPT="$BATS_TEST_DIRNAME/../scripts/new-project.sh"
BASE_REPO="$BATS_TEST_DIRNAME/.."

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# Every script path a hook actually INVOKES. Comments are stripped first: the
# foundation's pre-commit names its scripts in prose as well as in code, and a
# scanner that cannot tell the two apart would report the fixed file as broken.
invoked_scripts() {
    sed 's/#.*//' "$@" 2>/dev/null \
        | grep -oE '[A-Za-z0-9_.][A-Za-z0-9_./-]*\.sh' \
        | sort -u
}

# Installs a project with hooks into $TEST_DIR/proj and echoes its path.
install_with_hooks() {
    local proj="$TEST_DIR/proj"
    mkdir -p "$proj"
    git -C "$proj" init -q
    bash "$NEW_PROJECT_SCRIPT" --simple --hooks -y "$proj" >/dev/null 2>&1
    printf '%s' "$proj"
}

# =============================================================================
# Anti-vacuity control — the scanner must be shown capable of a positive first.
# A grep that matches nothing looks exactly like a file with nothing to find.
# =============================================================================

@test "husky scanner: sees the invocations in the foundation's own pre-commit" {
    run invoked_scripts "$BASE_REPO/.husky/pre-commit"
    [ "$status" -eq 0 ]
    [[ "$output" == *"private-names-check.sh"* ]]
    [[ "$output" == *"sync-counts.sh"* ]]
}

@test "husky scanner: ignores a script named only in a comment" {
    printf '#!/usr/bin/env sh\n# see scripts/mentioned-only.sh for details\necho ok\n' \
        > "$TEST_DIR/hook-fixture"
    run invoked_scripts "$TEST_DIR/hook-fixture"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

# =============================================================================
# The structural claim: an installed hook may only call what the install ships.
# =============================================================================

@test "install --hooks: every script an installed husky hook calls exists" {
    local proj; proj=$(install_with_hooks)
    [ -d "$proj/.husky" ]

    local missing=""
    local hook script
    for hook in "$proj"/.husky/*; do
        [ -f "$hook" ] || continue
        while IFS= read -r script; do
            [ -n "$script" ] || continue
            [ -e "$proj/$script" ] || missing="$missing $(basename "$hook"):$script"
        done < <(invoked_scripts "$hook")
    done

    # Collected, then asserted once: `! cmd` is exempt from set -e, so a negated
    # assertion inside the loop could not fail the case.
    [ -z "$missing" ] || {
        echo "hooks call scripts the install does not ship:$missing" >&2
        false
    }
}

@test "install --hooks: no installed hook calls a foundation-only script" {
    local proj; proj=$(install_with_hooks)
    run invoked_scripts "$proj"/.husky/*
    [ "$status" -eq 0 ]
    [[ "$output" != *"private-names-check.sh"* ]]
    [[ "$output" != *"sync-counts.sh"* ]]
    [[ "$output" != *"preflight.sh"* ]]
}

# =============================================================================
# The behavioural claim: the thing the defect actually broke.
# =============================================================================

@test "install --hooks: a commit still passes once the hooks are wired" {
    local proj; proj=$(install_with_hooks)
    git -C "$proj" config core.hooksPath .husky

    echo "hello" > "$proj/readme.txt"
    git -C "$proj" add -A
    git -C "$proj" -c user.email=probe@example.invalid -c user.name=probe \
        commit -m "test: probe commit" >/dev/null 2>&1 || true

    # Asserted by EFFECT, not by exit status: the commit either exists or it
    # does not, and a status read through a pipe reports the wrong stage.
    run git -C "$proj" log --oneline
    [ "$status" -eq 0 ]
    [[ "$output" == *"probe commit"* ]]
}

@test "install --hooks: commit-msg is still shipped" {
    local proj; proj=$(install_with_hooks)
    [ -f "$proj/.husky/commit-msg" ]
    [ -x "$proj/.husky/commit-msg" ]
}

# =============================================================================
# A Node project that has not installed the hook tools yet.
#
# Measured on a fresh project before the fix: package.json present, npx on the
# PATH, commitlint not installed — `npx --no -- commitlint` refused to download
# it, exited non-zero, and every commit was refused. The guard tested that npx
# and package.json exist, which says nothing about the TOOL being there.
# =============================================================================

# Commits in $1 with message $2, the hooks' stderr kept in $1/commit.err;
# asserted by effect in the log, not by exit status.
probe_commit() {
    local proj="$1" msg="$2"
    echo "$msg" >> "$proj/readme.txt"
    git -C "$proj" add -A
    # Offline: an npx that falls back to a download must fail here, not reach
    # the network and turn the test slow and flaky.
    # $PROBE_PATH_PREFIX, when set, is put ahead of the PATH the hooks see.
    PATH="${PROBE_PATH_PREFIX:+$PROBE_PATH_PREFIX:}$PATH" npm_config_offline=true \
        git -C "$proj" -c user.email=probe@example.invalid \
        -c user.name=probe commit -m "$msg" >/dev/null 2>"$proj/commit.err" || true
}

# Writes a stub $3 into directory $1 that logs its name and args to
# $2/tool-calls.log and exits with $4 — the log is how a test sees it ran.
write_stub() {
    local dir="$1" proj="$2" name="$3" code="$4"
    mkdir -p "$dir"
    printf '#!/bin/sh\necho "%s $*" >> "%s/tool-calls.log"\nexit %s\n' \
        "$name" "$proj" "$code" > "$dir/$name"
    chmod +x "$dir/$name"
}

# Puts a stub tool in node_modules/.bin that logs its args and exits with $3.
stub_tool() {
    write_stub "$1/node_modules/.bin" "$1" "$2" "$3"
}

# Puts a stub $2 exiting with $3 in $TEST_DIR/pathbin, outside the project,
# and echoes that directory for PROBE_PATH_PREFIX.
stub_on_path() {
    write_stub "$TEST_DIR/pathbin" "$1" "$2" "$3"
    printf '%s' "$TEST_DIR/pathbin"
}

# Installs a Node project with hooks wired, and echoes its path.
install_node_project() {
    local proj; proj=$(install_with_hooks)
    echo '{"name":"probe","version":"0.0.0","private":true}' > "$proj/package.json"
    git -C "$proj" config core.hooksPath .husky
    printf '%s' "$proj"
}

# A `[[ ]]` that is not a test's last line does not fail it on bash < 4.1
# (macOS system bash), hence `|| false` on every earlier one.

# No skip without npx: the fixed hooks never call it, and a runner without
# Node is exactly where a regression that needs node_modules would show.
@test "install --hooks: a Node project without the tools installed still commits" {
    local proj; proj=$(install_node_project)
    probe_commit "$proj" "test: no tools installed"
    run git -C "$proj" log --oneline
    [[ "$output" == *"no tools installed"* ]]
}

# Pins the original defect on any runner: the npx the old hooks called is
# present and refuses, as `npx --no` did for a tool that was not installed.
# Without it, a runner lacking npx made the old hooks no-op and this passed.
# Not called at all: a hook that ran npx and ignored its status would still
# reach for a download.
@test "install --hooks: an npx that refuses does not block the commit" {
    local proj; proj=$(install_node_project)
    PROBE_PATH_PREFIX=$(stub_on_path "$proj" npx 1)
    probe_commit "$proj" "test: npx refuses"
    run git -C "$proj" log --oneline
    [[ "$output" == *"npx refuses"* ]] || false
    [ ! -e "$proj/tool-calls.log" ]
}

# Only the project's OWN install is a gate. A global tool (npm -g, volta, nix,
# asdf) was tried as a fallback and reverted: it fires in repos that never set
# the tooling up, and it runs whatever version happens to be global against the
# project's configs (an install from before the self-contained
# .commitlintrc.json still extends @commitlint/config-conventional, which a
# global commitlint cannot resolve: every commit refused). The stubs fail, so running them would show.
@test "install --hooks: a tool only on the PATH is not run in a Node project" {
    local proj; proj=$(install_node_project)
    stub_on_path "$proj" commitlint 1 >/dev/null
    PROBE_PATH_PREFIX=$(stub_on_path "$proj" lint-staged 1)
    probe_commit "$proj" "test: global tools ignored"
    run git -C "$proj" log --oneline
    [[ "$output" == *"global tools ignored"* ]] || false
    [ ! -e "$proj/tool-calls.log" ]
}

# Outside a Node project the hooks have nothing to say and nothing to run: a
# warning would fire on every commit of every non-Node repo, and a global tool
# would gate a project that never set one up.
@test "install --hooks: a project without package.json skips silently" {
    local proj; proj=$(install_with_hooks)
    git -C "$proj" config core.hooksPath .husky
    stub_on_path "$proj" commitlint 0 >/dev/null
    PROBE_PATH_PREFIX=$(stub_on_path "$proj" lint-staged 0)
    probe_commit "$proj" "test: no package.json"
    run git -C "$proj" log --oneline
    [[ "$output" == *"no package.json"* ]] || false
    [ ! -e "$proj/tool-calls.log" ]
    [ ! -s "$proj/commit.err" ]
}

@test "install --hooks: a skipped check says so on stderr" {
    local proj; proj=$(install_node_project)
    probe_commit "$proj" "test: skipped checks"
    run cat "$proj/commit.err"
    [[ "$output" == *"commitlint not installed"* ]] || false
    [[ "$output" == *"lint-staged not installed"* ]]
}

@test "install --hooks: installed tools are run, with the commit message file" {
    local proj; proj=$(install_node_project)
    stub_tool "$proj" commitlint 0
    stub_tool "$proj" lint-staged 0
    probe_commit "$proj" "test: tools installed"
    run git -C "$proj" log --oneline
    [[ "$output" == *"tools installed"* ]] || false
    run cat "$proj/tool-calls.log"
    [[ "$output" == *"lint-staged"* ]] || false
    [[ "$output" == *"commitlint --edit "*"COMMIT_EDITMSG"* ]]
}

# Positive control: tolerating an ABSENT tool must not mean ignoring a PRESENT
# one. A hook that no-ops whatever happens would pass the two cases above.
@test "install --hooks: a failing commitlint still refuses the commit" {
    local proj; proj=$(install_node_project)
    stub_tool "$proj" commitlint 1
    probe_commit "$proj" "test: rejected by commitlint"
    run git -C "$proj" log --oneline
    [[ "$output" != *"rejected by commitlint"* ]] || false
    # Refused BY commitlint, not by some other breakage in the hook.
    run cat "$proj/tool-calls.log"
    [[ "$output" == *"commitlint --edit"* ]]
}

@test "install --hooks: a failing lint-staged still refuses the commit" {
    local proj; proj=$(install_node_project)
    stub_tool "$proj" lint-staged 1
    probe_commit "$proj" "test: rejected by lint-staged"
    run git -C "$proj" log --oneline
    [[ "$output" != *"rejected by lint-staged"* ]] || false
    run cat "$proj/tool-calls.log"
    [[ "$output" == *"lint-staged"* ]]
}

# =============================================================================
# #657: a commitlint without the preset its config extends, a package.json
# below the root, and an explicit opt-out.
# =============================================================================

# Measured with @commitlint/cli 20.5.3 alone: a config that `extends`
# @commitlint/config-conventional throws ("Cannot find module") and refuses
# EVERY commit; the same rules written out pass a valid message and refuse a bad
# one. The shipped config is therefore self-contained: it needs no preset.
@test "install --hooks: the shipped commitlint config extends no preset" {
    local proj; proj=$(install_node_project)
    [ -f "$proj/.commitlintrc.json" ]
    [ "$(jq -r 'has("extends")' "$proj/.commitlintrc.json")" = false ]
    [ "$(jq -r '.rules["type-enum"][2] | index("feat") != null' "$proj/.commitlintrc.json")" = true ]
}

# The header parser replaces the preset's: run its patterns as commitlint does
# (JavaScript RegExp), on a plain, a scoped and a breaking-change header.
@test "install --hooks: the shipped header parser reads type, scope and subject, with '!'" {
    command -v node >/dev/null 2>&1 || skip "node not installed"
    local proj; proj=$(install_node_project)
    run node -e '
        const o = require(process.argv[1]).parserPreset.parserOpts;
        const h = new RegExp(o.headerPattern), b = new RegExp(o.breakingHeaderPattern);
        const p = s => { const m = h.exec(s); return m ? m.slice(1).map(x => x || "").join("|") : "none"; };
        console.log([p("feat: add x"), p("fix(api): y"), p("feat(api)!: drop v1"),
                     p("no colon here"), b.test("feat!: z"), b.test("feat: z")].join(" ; "));
    ' "$proj/.commitlintrc.json"
    [ "$status" -eq 0 ]
    [ "$output" = "feat||add x ; fix|api|y ; feat|api|drop v1 ; none ; true ; false" ]
}

# A Node part below the root (web/, apps/web/) that set the tooling up: the
# hooks run at the root and find nothing to run, so both checks were skipped
# without a word. Only a package.json that declares the tooling is named: a
# docs site (website/) with no hooks of its own must not warn on every commit.
_tooling_pkg() {
    mkdir -p "$(dirname "$1")"
    echo '{"name":"part","devDependencies":{"husky":"^9","lint-staged":"^15","@commitlint/cli":"^20"}}' > "$1"
}

@test "install --hooks: a package.json below the root that sets up the tooling is named" {
    local proj; proj=$(install_with_hooks)
    git -C "$proj" config core.hooksPath .husky
    _tooling_pkg "$proj/web/package.json"
    _tooling_pkg "$proj/apps/api/package.json"
    probe_commit "$proj" "test: nested package"
    run git -C "$proj" log --oneline
    [[ "$output" == *"nested package"* ]] || false
    run cat "$proj/commit.err"
    [[ "$output" == *"pre-commit: lint-staged is set up in apps/api web, not at the repository root"* ]] || false
    [[ "$output" == *"commit-msg: commitlint is set up in apps/api web, not at the repository root"* ]]
}

@test "install --hooks: an untracked package.json that sets up the tooling stays silent" {
    # Only what the repo tracks: an ignored scratch clone is not the project.
    local proj; proj=$(install_with_hooks)
    git -C "$proj" config core.hooksPath .husky
    echo 'sandbox/' >> "$proj/.gitignore"
    _tooling_pkg "$proj/sandbox/other/package.json"
    probe_commit "$proj" "test: ignored clone"
    run git -C "$proj" log --oneline
    [[ "$output" == *"ignored clone"* ]] || false
    [ ! -s "$proj/commit.err" ]
}

@test "install --hooks: a package.json below the root without the tooling stays silent" {
    local proj; proj=$(install_with_hooks)
    git -C "$proj" config core.hooksPath .husky
    mkdir -p "$proj/website" "$proj/node_modules/x"
    echo '{"name":"site","dependencies":{"@docusaurus/core":"^3"}}' > "$proj/website/package.json"
    _tooling_pkg "$proj/node_modules/x/package.json"
    # Tracked on purpose (vendored dependencies): a dependency's manifest is
    # still not the project's.
    git -C "$proj" add -f node_modules/x/package.json
    probe_commit "$proj" "test: docs site only"
    run git -C "$proj" log --oneline
    [[ "$output" == *"docs site only"* ]] || false
    [ ! -s "$proj/commit.err" ]
}

@test "install --hooks: SKIP_COMMITLINT and SKIP_LINT_STAGED turn a check off, silently" {
    local proj; proj=$(install_node_project)
    stub_tool "$proj" commitlint 1
    stub_tool "$proj" lint-staged 1
    SKIP_COMMITLINT=1 SKIP_LINT_STAGED=1 probe_commit "$proj" "test: opted out"
    run git -C "$proj" log --oneline
    [[ "$output" == *"opted out"* ]] || false
    [ ! -e "$proj/tool-calls.log" ]
    [ ! -s "$proj/commit.err" ]
}

@test "install --hooks: control - SKIP_LINT_STAGED leaves commitlint running" {
    local proj; proj=$(install_node_project)
    stub_tool "$proj" commitlint 1
    SKIP_LINT_STAGED=1 probe_commit "$proj" "test: only lint-staged off"
    run git -C "$proj" log --oneline
    [[ "$output" != *"only lint-staged off"* ]] || false
    run cat "$proj/tool-calls.log"
    [[ "$output" == *"commitlint --edit"* ]]
}

@test "install --hooks: control - SKIP_COMMITLINT leaves lint-staged running" {
    local proj; proj=$(install_node_project)
    stub_tool "$proj" lint-staged 1
    SKIP_COMMITLINT=1 probe_commit "$proj" "test: only commitlint off"
    run git -C "$proj" log --oneline
    [[ "$output" != *"only commitlint off"* ]] || false
    run cat "$proj/tool-calls.log"
    [[ "$output" == *"lint-staged"* ]]
}
