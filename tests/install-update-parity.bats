#!/usr/bin/env bats

# =============================================================================
# install ≡ update: the selection must survive the first update.
#
# install.sh computes WHAT ships from the selection seam (compute_selected_set:
# preset filters, module ownership, the per-stack rules whitelist). update.sh
# re-derives the same decision on its own, file by file. Nothing kept the two
# in agreement — so an item install deliberately EXCLUDED could be deposited by
# the very next `update --all`, silently undoing the install-time selection.
#
# The guard: for representative configs, `install` then `update --all --force`
# must leave the set of manifest-driven files UNCHANGED — nothing added
# (selection respected) and nothing removed (EF-011: update is copy-only).
#
# A negative probe plants a divergence and asserts the comparison catches it.
# =============================================================================

load 'test_helper'

NEW_PROJECT_SCRIPT="$BATS_TEST_DIRNAME/../scripts/new-project.sh"
UPDATE_SCRIPT="$BATS_TEST_DIRNAME/../scripts/update.sh"
MODULE_SCRIPT="$BATS_TEST_DIRNAME/../scripts/module.sh"

setup() {
    skip_if_no_jq
    setup_test_dir
}
teardown() { teardown_test_dir; }

# _snapshot <project_dir> <out_file> — the project's installed file set,
# repo-relative and sorted. Backup trees are update's own bookkeeping
# (.claude/commands.backup.<ts>/, .claude.backup.<ts>/), never selection.
_snapshot() {
    (cd "$1" && find .claude scripts -type f 2>/dev/null \
        | grep -v 'backup\.' \
        | LC_ALL=C sort) > "$2"
}

# _assert_parity <install flags...> — install, snapshot, update --all --force,
# snapshot, compare both directions. Leaves the two snapshots in $TEST_DIR.
_assert_parity() {
    local proj="$TEST_DIR/proj"
    mkdir -p "$proj"

    run "$NEW_PROJECT_SCRIPT" -y "$@" "$proj"
    [ "$status" -eq 0 ]

    _snapshot "$proj" "$TEST_DIR/after-install"
    # Non-empty first: a broken find would make both directions vacuously green.
    [ -s "$TEST_DIR/after-install" ]

    # PARITY_UPDATE_FLAGS: extra flags the update side needs to see the same
    # world as the install (e.g. --presets-dir for a fixture preset).
    run "$UPDATE_SCRIPT" -y --all --force \
        ${PARITY_UPDATE_FLAGS[@]+"${PARITY_UPDATE_FLAGS[@]}"} "$proj"
    [ "$status" -eq 0 ]

    _snapshot "$proj" "$TEST_DIR/after-update"
    [ -s "$TEST_DIR/after-update" ]

    local added removed
    added=$(comm -13 "$TEST_DIR/after-install" "$TEST_DIR/after-update")
    removed=$(comm -23 "$TEST_DIR/after-install" "$TEST_DIR/after-update")

    if [ -n "$added" ]; then
        echo "update deposited files the install excluded:" >&2
        printf '%s\n' "$added" >&2
        return 1
    fi
    if [ -n "$removed" ]; then
        echo "update removed installed files (EF-011 says copy-only):" >&2
        printf '%s\n' "$removed" >&2
        return 1
    fi
    return 0
}

@test "parity: update --all adds nothing to a simple (generic) install" {
    _assert_parity --simple
}

@test "parity: update --all does not deposit foreign stack rules on a python install" {
    _assert_parity --simple --type python
    # The stack is recorded — that field is what makes the selection durable.
    run bash -c "jq -r '.projectType' '$TEST_DIR/proj/.claude/foundation.json'"
    [ "$output" = "python" ]
    # The whitelist really bit: a python project has python.md and none of the
    # web/mobile framework rules — before AND after the update.
    [ -f "$TEST_DIR/proj/.claude/rules/python.md" ]
    [ ! -f "$TEST_DIR/proj/.claude/rules/react.md" ]
    [ ! -f "$TEST_DIR/proj/.claude/rules/flutter.md" ]
}

@test "parity: base-maintenance.md (foundation-internal) never reaches a project" {
    _assert_parity --simple
    [ ! -f "$TEST_DIR/proj/.claude/rules/base-maintenance.md" ]
}

@test "parity: a preset's catalog and skill filters survive the update" {
    # No SHIPPED preset declares foundation filters, so without this fixture the
    # filtered selection path — the one where install and update each re-derive
    # the decision from their own predicates — is never exercised end-to-end.
    mkdir -p "$TEST_DIR/presets"
    cat > "$TEST_DIR/presets/paritytest.json" <<'EOF'
{
  "name": "paritytest",
  "displayName": "Parity fixture",
  "detect": {},
  "foundation": {
    "commands": { "drop": ["domain:growth", "domain:legal"] },
    "agents":   { "drop": ["biz-competitor"] },
    "skills":   { "drop": ["growth-cro", "web-scraping"] }
  },
  "defaults": {}
}
EOF
    # --presets-dir, not the env var: the scripts initialize PRESETS_DIR_OVERRIDE
    # at load time, clobbering any inherited value.
    PARITY_UPDATE_FLAGS=(--presets-dir "$TEST_DIR/presets")
    _assert_parity --simple --presets-dir "$TEST_DIR/presets" --preset paritytest

    # The filter really bit at install time AND was still respected afterwards.
    [ ! -d "$TEST_DIR/proj/.claude/skills/growth-cro" ]
    [ ! -d "$TEST_DIR/proj/.claude/skills/web-scraping" ]
    [ ! -e "$TEST_DIR/proj/.claude/agents/biz-competitor.md" ]
    [ ! -d "$TEST_DIR/proj/.claude/commands/growth" ]
    # ...and non-dropped content is present (the filter was not a blanket skip).
    [ -d "$TEST_DIR/proj/.claude/skills/dev-tdd" ]
}

@test "parity: a preset's KEEP whitelist survives the update" {
    # keep-mode is the asymmetric case: update excludes module-owned items from
    # the filter's jurisdiction (CF_EXCLUDE_DOMAINS/ITEMS) so a whitelist cannot
    # drop them; the install-side selection has no such exclusion. If the two
    # disagree, it shows up here and nowhere else.
    mkdir -p "$TEST_DIR/presets"
    cat > "$TEST_DIR/presets/keeptest.json" <<'EOF'
{
  "name": "keeptest",
  "displayName": "Keep-mode fixture",
  "detect": {},
  "foundation": {
    "commands": { "keep": ["domain:work", "domain:qa"] },
    "agents":   { "keep": ["dev-tdd", "qa-loop"] },
    "skills":   { "keep": ["dev-tdd", "qa-review"] }
  },
  "defaults": {}
}
EOF
    PARITY_UPDATE_FLAGS=(--presets-dir "$TEST_DIR/presets")
    _assert_parity --simple --presets-dir "$TEST_DIR/presets" --preset keeptest

    # The whitelist bit on both sides.
    [ -d "$TEST_DIR/proj/.claude/skills/dev-tdd" ]
    [ ! -d "$TEST_DIR/proj/.claude/skills/growth-cro" ]
    [ -d "$TEST_DIR/proj/.claude/commands/work" ]
    [ ! -d "$TEST_DIR/proj/.claude/commands/doc" ]
}

@test "parity: an installed module survives a preset KEEP whitelist that excludes it" {
    # THE asymmetric case. update excludes module-owned items from the preset
    # filter's jurisdiction (CF_EXCLUDE_DOMAINS/ITEMS) precisely so a narrow keep
    # whitelist cannot strip an installed module; the install-side selection
    # instead re-adds module bundles after filtering. Two different mechanisms
    # for one rule — this is where they would disagree. Needs a module actually
    # installed, otherwise the branch is never reached.
    mkdir -p "$TEST_DIR/presets"
    cat > "$TEST_DIR/presets/modkeep.json" <<'EOF'
{
  "name": "modkeep",
  "displayName": "Keep-mode + module fixture",
  "detect": {},
  "foundation": {
    "commands": { "keep": ["domain:work"] },
    "agents":   { "keep": ["dev-tdd"] },
    "skills":   { "keep": ["dev-tdd"] }
  },
  "defaults": {}
}
EOF
    local proj="$TEST_DIR/proj"
    mkdir -p "$proj"
    run "$NEW_PROJECT_SCRIPT" -y --simple \
        --presets-dir "$TEST_DIR/presets" --preset modkeep "$proj"
    [ "$status" -eq 0 ]

    # Install the legal module: its items are NOT in any keep list.
    run "$MODULE_SCRIPT" add legal -y --target "$proj"
    [ "$status" -eq 0 ]
    [ -e "$proj/.claude/commands/legal/legal-rgpd.md" ]

    _snapshot "$proj" "$TEST_DIR/after-install"
    [ -s "$TEST_DIR/after-install" ]

    run "$UPDATE_SCRIPT" -y --all --force \
        --presets-dir "$TEST_DIR/presets" "$proj"
    [ "$status" -eq 0 ]

    _snapshot "$proj" "$TEST_DIR/after-update"
    local added removed
    added=$(comm -13 "$TEST_DIR/after-install" "$TEST_DIR/after-update")
    removed=$(comm -23 "$TEST_DIR/after-install" "$TEST_DIR/after-update")
    [ -z "$added" ] || { echo "update deposited:" >&2; printf '%s\n' "$added" >&2; false; }
    [ -z "$removed" ] || { echo "update removed:" >&2; printf '%s\n' "$removed" >&2; false; }

    # The module's own items are still there — the keep whitelist has no
    # jurisdiction over them.
    [ -e "$proj/.claude/commands/legal/legal-rgpd.md" ]
    [ -e "$proj/.claude/agents/legal-rgpd.md" ]
}

@test "update reports the rules it left out, naming the recorded stack" {
    local proj="$TEST_DIR/proj"
    mkdir -p "$proj"
    run "$NEW_PROJECT_SCRIPT" -y --simple --type go "$proj"
    [ "$status" -eq 0 ]
    # Wipe the rules so the update has real work to do (and real skips).
    rm -f "$proj/.claude/rules/"*.md

    run "$UPDATE_SCRIPT" -y --rules "$proj"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Outside the project stack (skipped)"* ]]
    [[ "$output" == *"'go' whitelist"* ]]
    # And the whitelist was applied, not just announced.
    [ -f "$proj/.claude/rules/go.md" ]
    [ ! -f "$proj/.claude/rules/react.md" ]
}

@test "legacy project (no projectType recorded): update still ships every rule" {
    # A project installed before the field existed has no recorded stack. The
    # whitelist must NOT be guessed there — update keeps refreshing the whole
    # rules dir, exactly as it did before. No silent change under users' feet.
    local proj="$TEST_DIR/proj"
    mkdir -p "$proj"
    run "$NEW_PROJECT_SCRIPT" -y --simple --type python "$proj"
    [ "$status" -eq 0 ]

    # Age the manifest back to a pre-projectType install.
    local mf="$proj/.claude/foundation.json"
    jq 'del(.projectType)' "$mf" > "$mf.tmp" && mv "$mf.tmp" "$mf"
    run bash -c "jq -r 'has(\"projectType\")' '$mf'"
    [ "$output" = "false" ]

    run "$UPDATE_SCRIPT" -y --all --force "$proj"
    [ "$status" -eq 0 ]

    # Old behaviour preserved: foreign rules land again...
    [ -f "$proj/.claude/rules/react.md" ]
    [ -f "$proj/.claude/rules/flutter.md" ]
    # ...but the foundation-internal one never does, legacy included.
    [ ! -f "$proj/.claude/rules/base-maintenance.md" ]
    # And the summary must not invent a whitelist this project has no stack
    # for: withholding base-maintenance is not "outside the generic whitelist".
    [[ "$output" != *"whitelist"* ]]
}

@test "parity negative probe: a planted extra file IS flagged" {
    local proj="$TEST_DIR/proj"
    mkdir -p "$proj"
    run "$NEW_PROJECT_SCRIPT" -y --simple "$proj"
    [ "$status" -eq 0 ]

    _snapshot "$proj" "$TEST_DIR/a"
    # Stand in for "update deposited something the install excluded".
    touch "$proj/.claude/rules/planted-divergence.md"
    _snapshot "$proj" "$TEST_DIR/b"

    local added
    added=$(comm -13 "$TEST_DIR/a" "$TEST_DIR/b")
    [[ "$added" == *"planted-divergence.md"* ]]
}
