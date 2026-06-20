#!/usr/bin/env bats

# =============================================================================
# Tests for ide.sh (IDE integration)
# =============================================================================

load 'test_helper'

IDE_SCRIPT="$BATS_TEST_DIRNAME/../scripts/ide.sh"

setup() {
    setup_test_dir
    TEST_PROJECT="$TEST_DIR/test-project"
    mkdir -p "$TEST_PROJECT"
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Basic tests
# =============================================================================

@test "ide.sh exists and is executable" {
    [[ -x "$IDE_SCRIPT" ]]
}

@test "ide.sh --help displays help" {
    run "$IDE_SCRIPT" --help
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"USAGE"* ]]
    [[ "$output" == *"setup"* ]]
    [[ "$output" == *"vscode"* ]]
    [[ "$output" == *"idea"* ]]
}

@test "ide.sh --version displays the version" {
    run "$IDE_SCRIPT" --version
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"IDE Integration"* ]]
}

@test "ide.sh -h is equivalent to --help" {
    run "$IDE_SCRIPT" -h
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"USAGE"* ]]
}

@test "ide.sh -v is equivalent to --version" {
    run "$IDE_SCRIPT" -v
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"IDE"* ]]
}

# =============================================================================
# Error tests
# =============================================================================

@test "ide.sh without arguments displays help" {
    run "$IDE_SCRIPT"
    [[ "$status" -eq 1 ]] || [[ "$output" == *"USAGE"* ]]
}

@test "ide.sh with invalid command fails" {
    run "$IDE_SCRIPT" invalid-command vscode
    [[ "$status" -ne 0 ]]
}

@test "ide.sh with invalid IDE fails" {
    run "$IDE_SCRIPT" setup invalid-ide
    [[ "$status" -ne 0 ]]
}

# =============================================================================
# VSCode setup tests
# =============================================================================

@test "ide.sh setup vscode creates the .vscode directory" {
    run "$IDE_SCRIPT" setup vscode "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ -d "$TEST_PROJECT/.vscode" ]]
}

@test "ide.sh setup vscode creates settings.json" {
    run "$IDE_SCRIPT" setup vscode "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ -f "$TEST_PROJECT/.vscode/settings.json" ]]
}

@test "ide.sh setup vscode creates tasks.json" {
    run "$IDE_SCRIPT" setup vscode "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ -f "$TEST_PROJECT/.vscode/tasks.json" ]]
}

@test "ide.sh setup vscode creates extensions.json" {
    run "$IDE_SCRIPT" setup vscode "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ -f "$TEST_PROJECT/.vscode/extensions.json" ]]
}

@test "ide.sh setup vscode creates the snippets" {
    run "$IDE_SCRIPT" setup vscode "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ -f "$TEST_PROJECT/.vscode/claude-base.code-snippets" ]]
}

@test "settings.json contains the Claude configuration" {
    "$IDE_SCRIPT" setup vscode "$TEST_PROJECT"
    grep -q "formatOnSave" "$TEST_PROJECT/.vscode/settings.json"
    grep -q "eslint" "$TEST_PROJECT/.vscode/settings.json"
}

@test "tasks.json contains the Claude tasks" {
    "$IDE_SCRIPT" setup vscode "$TEST_PROJECT"
    grep -q "Claude" "$TEST_PROJECT/.vscode/tasks.json"
    grep -q "validate.sh" "$TEST_PROJECT/.vscode/tasks.json"
    grep -q "doctor.sh" "$TEST_PROJECT/.vscode/tasks.json"
}

@test "extensions.json contains the recommendations" {
    "$IDE_SCRIPT" setup vscode "$TEST_PROJECT"
    grep -q "recommendations" "$TEST_PROJECT/.vscode/extensions.json"
    grep -q "prettier" "$TEST_PROJECT/.vscode/extensions.json"
    grep -q "eslint" "$TEST_PROJECT/.vscode/extensions.json"
}

@test "snippets contain the Claude commands" {
    "$IDE_SCRIPT" setup vscode "$TEST_PROJECT"
    grep -q "work-explore" "$TEST_PROJECT/.vscode/claude-base.code-snippets"
    grep -q "work-plan" "$TEST_PROJECT/.vscode/claude-base.code-snippets"
    grep -q "dev-tdd" "$TEST_PROJECT/.vscode/claude-base.code-snippets"
}

# =============================================================================
# VSCode check tests
# =============================================================================

@test "ide.sh check vscode detects complete configuration" {
    "$IDE_SCRIPT" setup vscode "$TEST_PROJECT"
    run "$IDE_SCRIPT" check vscode "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"complète"* ]] || [[ "$output" == *"✓"* ]]
}

@test "ide.sh check vscode detects missing configuration" {
    run "$IDE_SCRIPT" check vscode "$TEST_PROJECT"
    [[ "$output" == *"manquant"* ]] || [[ "$output" == *"⚠"* ]] || [[ "$output" == *"✗"* ]]
}

# =============================================================================
# VSCode remove tests
# =============================================================================

@test "ide.sh remove vscode removes the configuration" {
    "$IDE_SCRIPT" setup vscode "$TEST_PROJECT"
    [[ -d "$TEST_PROJECT/.vscode" ]]

    run "$IDE_SCRIPT" remove vscode "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ ! -f "$TEST_PROJECT/.vscode/settings.json" ]]
}

# =============================================================================
# IntelliJ setup tests
# =============================================================================

@test "ide.sh setup idea creates the .idea directory" {
    run "$IDE_SCRIPT" setup idea "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ -d "$TEST_PROJECT/.idea" ]]
}

@test "ide.sh setup idea creates the run configurations" {
    run "$IDE_SCRIPT" setup idea "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ -d "$TEST_PROJECT/.idea/runConfigurations" ]]
}

@test "ide.sh setup idea creates the code style" {
    run "$IDE_SCRIPT" setup idea "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ -d "$TEST_PROJECT/.idea/codeStyles" ]]
}

@test "IntelliJ run configurations contain the Claude scripts" {
    "$IDE_SCRIPT" setup idea "$TEST_PROJECT"
    [[ -f "$TEST_PROJECT/.idea/runConfigurations/Claude_Validate.xml" ]]
    [[ -f "$TEST_PROJECT/.idea/runConfigurations/Claude_Doctor.xml" ]]
    [[ -f "$TEST_PROJECT/.idea/runConfigurations/Claude_Test.xml" ]]
}

# =============================================================================
# Vim setup tests
# =============================================================================

@test "ide.sh setup vim creates .vimrc.claude" {
    run "$IDE_SCRIPT" setup vim "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ -f "$TEST_PROJECT/.vimrc.claude" ]]
}

@test ".vimrc.claude contains the Claude abbreviations" {
    "$IDE_SCRIPT" setup vim "$TEST_PROJECT"
    grep -q "cexplore" "$TEST_PROJECT/.vimrc.claude"
    grep -q "cplan" "$TEST_PROJECT/.vimrc.claude"
    grep -q "ccommit" "$TEST_PROJECT/.vimrc.claude"
}

@test ".vimrc.claude contains the mappings" {
    "$IDE_SCRIPT" setup vim "$TEST_PROJECT"
    grep -q "nnoremap" "$TEST_PROJECT/.vimrc.claude"
    grep -q "validate.sh" "$TEST_PROJECT/.vimrc.claude"
}

# =============================================================================
# all tests
# =============================================================================

@test "ide.sh setup all configures every IDE" {
    run "$IDE_SCRIPT" setup all "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ -d "$TEST_PROJECT/.vscode" ]]
    [[ -d "$TEST_PROJECT/.idea" ]]
    [[ -f "$TEST_PROJECT/.vimrc.claude" ]]
}

@test "ide.sh check all checks every IDE" {
    "$IDE_SCRIPT" setup all "$TEST_PROJECT"
    run "$IDE_SCRIPT" check all "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
}

# =============================================================================
# --force tests
# =============================================================================

@test "ide.sh setup --force overwrites existing files" {
    "$IDE_SCRIPT" setup vscode "$TEST_PROJECT"
    echo "modified" >> "$TEST_PROJECT/.vscode/settings.json"

    run "$IDE_SCRIPT" setup vscode --force "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    ! grep -q "modified" "$TEST_PROJECT/.vscode/settings.json"
}

# =============================================================================
# cursor tests (vscode alias)
# =============================================================================

@test "ide.sh setup cursor is equivalent to vscode" {
    run "$IDE_SCRIPT" setup cursor "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ -d "$TEST_PROJECT/.vscode" ]]
}

# =============================================================================
# Dry-run tests — flag advertised in --help, must not touch the filesystem
# =============================================================================

@test "ide.sh setup vscode --dry-run writes nothing to disk" {
    run "$IDE_SCRIPT" setup vscode --dry-run "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ ! -d "$TEST_PROJECT/.vscode" ]]
    [[ ! -f "$TEST_PROJECT/.vscode/settings.json" ]]
    [[ ! -f "$TEST_PROJECT/.vscode/tasks.json" ]]
    [[ ! -f "$TEST_PROJECT/.vscode/extensions.json" ]]
}

@test "ide.sh setup idea --dry-run writes nothing to disk" {
    run "$IDE_SCRIPT" setup idea --dry-run "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ ! -d "$TEST_PROJECT/.idea" ]]
}

@test "ide.sh setup vim --dry-run writes nothing to disk" {
    run "$IDE_SCRIPT" setup vim --dry-run "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ ! -f "$TEST_PROJECT/.vimrc.claude" ]]
}

@test "ide.sh setup all --dry-run writes nothing to disk" {
    run "$IDE_SCRIPT" setup all --dry-run "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ ! -d "$TEST_PROJECT/.vscode" ]]
    [[ ! -d "$TEST_PROJECT/.idea" ]]
    [[ ! -f "$TEST_PROJECT/.vimrc.claude" ]]
}

# =============================================================================
# IntelliJ / Vim / all remove tests
#
# These exercise the destructive `rm -f`/`rm` branches (remove_idea,
# remove_vim, remove_all) that previously had no coverage — only the VSCode
# remove path was tested.
# =============================================================================

@test "ide.sh remove idea removes the claude-base run configurations and templates" {
    "$IDE_SCRIPT" setup idea "$TEST_PROJECT"
    # Precondition: setup created at least one claude-base run configuration
    ls "$TEST_PROJECT/.idea/runConfigurations/Claude_"*.xml >/dev/null 2>&1

    run "$IDE_SCRIPT" remove idea "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]

    # No claude-base run configuration survives the removal
    run bash -c "ls $TEST_PROJECT/.idea/runConfigurations/Claude_*.xml 2>/dev/null"
    [[ "$output" == "" ]]
}

@test "ide.sh remove idea is a no-op when no .idea exists" {
    run "$IDE_SCRIPT" remove idea "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"No IntelliJ"* ]] || [[ "$output" == *"configuration"* ]]
}

@test "ide.sh remove vim removes the vim configuration" {
    "$IDE_SCRIPT" setup vim "$TEST_PROJECT"
    [[ -f "$TEST_PROJECT/.vimrc.claude" ]]

    run "$IDE_SCRIPT" remove vim "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ ! -f "$TEST_PROJECT/.vimrc.claude" ]]
}

@test "ide.sh remove vim is a no-op when no vim config exists" {
    run "$IDE_SCRIPT" remove vim "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]
    [[ "$output" == *"No Vim"* ]] || [[ "$output" == *"configuration"* ]]
}

@test "ide.sh remove all removes vscode, idea and vim configurations" {
    "$IDE_SCRIPT" setup all "$TEST_PROJECT"
    [[ -d "$TEST_PROJECT/.vscode" ]]
    [[ -d "$TEST_PROJECT/.idea" ]]
    [[ -f "$TEST_PROJECT/.vimrc.claude" ]]

    run "$IDE_SCRIPT" remove all "$TEST_PROJECT"
    [[ "$status" -eq 0 ]]

    [[ ! -f "$TEST_PROJECT/.vscode/settings.json" ]]
    [[ ! -f "$TEST_PROJECT/.vimrc.claude" ]]
    run bash -c "ls $TEST_PROJECT/.idea/runConfigurations/Claude_*.xml 2>/dev/null"
    [[ "$output" == "" ]]
}

# =============================================================================
# Structure tests
# =============================================================================

@test "ide.sh sources the common library" {
    grep -q "source.*lib/common.sh" "$IDE_SCRIPT"
}

@test "ide.sh uses set -euo pipefail" {
    grep -q "set -euo pipefail" "$IDE_SCRIPT"
}
