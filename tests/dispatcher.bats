#!/usr/bin/env bats

# =============================================================================
# Tests for bin/claude-base — unified CLI dispatcher
#
# The dispatcher is purely additive. The underlying scripts under scripts/
# remain callable directly. Tests verify dispatch correctness, help output,
# error handling on unknown verbs, and arg forwarding.
# =============================================================================

load 'test_helper'

DISPATCHER="$BATS_TEST_DIRNAME/../bin/claude-base"

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Basic invariants
# =============================================================================

@test "dispatcher: bin/claude-base exists and is executable" {
    [ -f "$DISPATCHER" ]
    [ -x "$DISPATCHER" ]
}

@test "dispatcher: no arg shows help" {
    run "$DISPATCHER"
    [ "$status" -eq 0 ]
    [[ "$output" == *"claude-base"* ]]
    [[ "$output" == *"COMMANDS"* ]]
    [[ "$output" == *"init"* ]]
    [[ "$output" == *"update"* ]]
    [[ "$output" == *"validate"* ]]
    [[ "$output" == *"preset"* ]]
    [[ "$output" == *"uninstall"* ]]
}

@test "dispatcher: help verb shows the same help" {
    run "$DISPATCHER" help
    [ "$status" -eq 0 ]
    [[ "$output" == *"COMMANDS"* ]]
}

@test "dispatcher: --help and -h short forms work" {
    run "$DISPATCHER" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"COMMANDS"* ]]

    run "$DISPATCHER" -h
    [ "$status" -eq 0 ]
    [[ "$output" == *"COMMANDS"* ]]
}

# =============================================================================
# version
# =============================================================================

@test "dispatcher: version prints VERSION content" {
    run "$DISPATCHER" version
    [ "$status" -eq 0 ]
    local expected
    expected=$(cat "$BATS_TEST_DIRNAME/../VERSION")
    [[ "$output" == *"$expected"* ]]
    [[ "$output" == *"claude-base"* ]]
}

@test "dispatcher: --version short form works" {
    run "$DISPATCHER" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"claude-base"* ]]
}

# =============================================================================
# preset
# =============================================================================

@test "dispatcher: preset list shows the 4 vouched presets" {
    run "$DISPATCHER" preset list
    [ "$status" -eq 0 ]
    [[ "$output" == *"nextjs"* ]]
    [[ "$output" == *"homelab-proxmox"* ]]
    [[ "$output" == *"cli-tools"* ]]
    [[ "$output" == *"fastapi"* ]]
}

@test "dispatcher: preset (no subcommand) is equivalent to preset list" {
    run "$DISPATCHER" preset
    [ "$status" -eq 0 ]
    [[ "$output" == *"nextjs"* ]]
}

@test "dispatcher: preset show <name> prints the JSON manifest" {
    run "$DISPATCHER" preset show fastapi
    [ "$status" -eq 0 ]
    [[ "$output" == *"\"name\""* ]]
    [[ "$output" == *"fastapi"* ]]
    [[ "$output" == *"\"appliesToTypes\""* ]]
}

@test "dispatcher: preset show without name fails clearly" {
    run "$DISPATCHER" preset show
    [ "$status" -ne 0 ]
    [[ "$output" == *"requires a preset name"* ]] || [[ "$output" == *"name"* ]]
}

@test "dispatcher: preset show on unknown name fails with helpful error" {
    run "$DISPATCHER" preset show this-preset-does-not-exist
    [ "$status" -ne 0 ]
    [[ "$output" == *"not found"* ]]
}

@test "dispatcher: preset unknown-subcommand fails" {
    run "$DISPATCHER" preset bogus
    [ "$status" -ne 0 ]
    [[ "$output" == *"unknown subcommand"* ]] || [[ "$output" == *"Available"* ]]
}

# =============================================================================
# Verb dispatch (arg forwarding)
# =============================================================================

@test "dispatcher: init --help forwards to new-project.sh help" {
    run "$DISPATCHER" init --help
    [ "$status" -eq 0 ]
    # new-project.sh --help shows USAGE
    [[ "$output" == *"USAGE"* ]] || [[ "$output" == *"new-project"* ]]
}

@test "dispatcher: update --help forwards to update.sh help" {
    run "$DISPATCHER" update --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]] || [[ "$output" == *"update"* ]]
}

@test "dispatcher: validate --help forwards to validate.sh help" {
    run "$DISPATCHER" validate --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]] || [[ "$output" == *"validate"* ]]
}

@test "dispatcher: uninstall --help forwards to uninstall.sh help" {
    run "$DISPATCHER" uninstall --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]] || [[ "$output" == *"uninstall"* ]]
}

# =============================================================================
# Unknown verb
# =============================================================================

@test "dispatcher: unknown verb fails with helpful error" {
    run "$DISPATCHER" not-a-real-verb
    [ "$status" -eq 2 ]
    [[ "$output" == *"unknown command"* ]]
    [[ "$output" == *"init"* ]]
}

# =============================================================================
# User-visible CLI naming — when invoked via the dispatcher, scripts emit
# `claude-base init` / `claude-base update` in their hints, not the raw
# `new-project.sh` / `update.sh`. Verifies the CLAUDE_BASE_DISPATCHER env var
# wiring + the cli_usage helper.
# =============================================================================

@test "dispatcher: preset list output references 'claude-base init', not new-project.sh" {
    run "$DISPATCHER" preset list
    [ "$status" -eq 0 ]
    [[ "$output" == *"claude-base init"* ]]
    [[ "$output" != *"Use: new-project.sh"* ]]
}

@test "dispatcher: --help text does not leak 'alias for new-project.sh'" {
    run "$DISPATCHER" --help
    [ "$status" -eq 0 ]
    [[ "$output" != *"alias for new-project.sh"* ]]
    [[ "$output" != *"alias for new-project.sh --list-presets"* ]]
}

@test "direct script: ./scripts/new-project.sh --list-presets keeps the raw script name in its hint" {
    # Foundation-contributor path : if you run the underlying script directly,
    # the hint should reference the script you actually invoked.
    local script="$BATS_TEST_DIRNAME/../scripts/new-project.sh"
    run "$script" --list-presets
    [ "$status" -eq 0 ]
    [[ "$output" == *"new-project.sh"* ]] || [[ "$output" == *"./scripts/new-project.sh"* ]]
}

# =============================================================================
# Symlink invocation — install.sh creates ~/.local/bin/claude-base as a
# symlink to ~/.local/share/claude-base/bin/claude-base. The dispatcher must
# resolve the symlink to compute BASE_ROOT correctly ; otherwise BASE_ROOT
# lands at ~/.local instead of ~/.local/share/claude-base, and every
# subsequent script exec fails with "No such file or directory".
#
# Regression caught while preparing the asciinema demo recording — the
# scripted curl|bash flow ended with broken `claude-base init`.
# =============================================================================

@test "dispatcher: invocation via symlink resolves BASE_ROOT correctly (version)" {
    # Create a symlink mirroring what install.sh does
    setup_test_dir
    local symlink="$TEST_DIR/claude-base"
    ln -s "$DISPATCHER" "$symlink"

    run "$symlink" version
    [ "$status" -eq 0 ]
    # If the resolution is wrong, VERSION file isn't found and output is
    # "claude-base vunknown" ; if correct, we get the real version
    [[ "$output" != *"vunknown"* ]]
    [[ "$output" =~ v[0-9]+\.[0-9]+\.[0-9]+ ]]
    teardown_test_dir
}

@test "dispatcher: invocation via symlink can run subcommands (preset list)" {
    setup_test_dir
    local symlink="$TEST_DIR/claude-base"
    ln -s "$DISPATCHER" "$symlink"

    run "$symlink" preset list
    [ "$status" -eq 0 ]
    # If BASE_ROOT was wrong, this would fail with "No such file or directory"
    [[ "$output" != *"No such file or directory"* ]]
    [[ "$output" == *"Available presets"* ]] || [[ "$output" == *"NAME"* ]]
    teardown_test_dir
}

# =============================================================================
# Module verbs — add, remove, modules (T018, US-2)
# These tests verify routing correctness; the underlying scripts/module.sh
# behaviour is covered by modules.bats.
# =============================================================================

@test "dispatcher: help text lists 'add' verb" {
    run "$DISPATCHER"
    [ "$status" -eq 0 ]
    [[ "$output" == *"add"* ]]
}

@test "dispatcher: help text lists 'modules' verb" {
    run "$DISPATCHER"
    [ "$status" -eq 0 ]
    [[ "$output" == *"modules"* ]]
}

@test "dispatcher: 'modules' verb is dispatched (shows available modules)" {
    run "$DISPATCHER" modules
    [ "$status" -eq 0 ]
    # Must list the three known modules.
    [[ "$output" == *"biz"* ]]
    [[ "$output" == *"legal"* ]]
    [[ "$output" == *"growth"* ]]
}

@test "dispatcher: 'add --help' forwards to module.sh (shows usage)" {
    run "$DISPATCHER" add --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]] || [[ "$output" == *"add"* ]]
}

@test "dispatcher: 'remove --help' forwards to module.sh (shows usage)" {
    run "$DISPATCHER" remove --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]] || [[ "$output" == *"remove"* ]]
}

@test "dispatcher: 'add' with unknown module fails with non-zero exit" {
    # module.sh must return non-zero for unknown modules; dispatcher must relay it.
    run "$DISPATCHER" add totally-unknown-module-xyz --target /tmp
    [ "$status" -ne 0 ]
}

@test "dispatcher: 'modules' verb routes to module.sh, not new-project.sh" {
    # Verify the output does NOT include raw script paths from other scripts.
    run "$DISPATCHER" modules
    [ "$status" -eq 0 ]
    [[ "$output" != *"new-project.sh"* ]]
}

@test "dispatcher: doctor verb forwards to doctor.sh" {
    run "$DISPATCHER" doctor --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]] || [[ "$output" == *"iagnos"* ]]
}

@test "dispatcher: help lists the doctor verb" {
    run "$DISPATCHER"
    [ "$status" -eq 0 ]
    [[ "$output" == *"doctor"* ]]
}

@test "dispatcher: lessons verb forwards to lessons.sh" {
    run "$DISPATCHER" lessons --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"bootstrap-scan"* ]] || [[ "$output" == *"Usage"* ]]
}

@test "dispatcher: help lists the lessons verb" {
    run "$DISPATCHER"
    [ "$status" -eq 0 ]
    [[ "$output" == *"lessons"* ]]
}
