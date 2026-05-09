#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/lib/menu.sh
# Covers the dynamic type menu when matched presets prepend the standard 11
# type options. See specs/presets-detection-and-e2e/spec.md US-4.
# =============================================================================

load 'test_helper'

MENU_LIB="$BASE_DIR/scripts/lib/menu.sh"

setup() {
    setup_test_dir
    [ -f "$MENU_LIB" ]
}

teardown() {
    teardown_test_dir
}

# Helper: invoke a function from the lib in a clean subshell with controlled
# state. Strips ANSI color codes from stdout so assertions stay simple.
menu_run() {
    local fn="$1"
    shift
    bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$MENU_LIB'
        MATCHED_PRESETS=($MATCHED_PRESETS_LITERAL)
        $fn $*
    " 2>&1 | sed -E 's/\x1B\[[0-9;]*[A-Za-z]//g'
}

# =============================================================================
# Library wiring
# =============================================================================

@test "menu: library file exists and is sourceable" {
    run bash -c "source '$BASE_DIR/scripts/lib/common.sh' && source '$MENU_LIB'"
    [ "$status" -eq 0 ]
}

@test "menu: print_type_menu and apply_type_choice are defined after sourcing" {
    run bash -c "source '$BASE_DIR/scripts/lib/common.sh' && source '$MENU_LIB' && declare -f print_type_menu apply_type_choice >/dev/null"
    [ "$status" -eq 0 ]
}

# =============================================================================
# print_type_menu — empty MATCHED_PRESETS (regression: today's behavior)
# =============================================================================

@test "menu: print_type_menu with no matched presets prints the 11 standard options as 1..11" {
    MATCHED_PRESETS_LITERAL=""
    run menu_run print_type_menu
    [ "$status" -eq 0 ]
    [[ "$output" == *"1) React / Next.js"* ]]
    [[ "$output" == *"2) Vue.js"* ]]
    [[ "$output" == *"11) Other / Generic"* ]]
    [[ "$output" != *"Use preset"* ]]
}

@test "menu: print_type_menu with no matched presets honors default_choice marker" {
    MATCHED_PRESETS_LITERAL=""
    run menu_run print_type_menu 4
    [ "$status" -eq 0 ]
    [[ "$output" == *"4) Python"*"detected"* ]]
}

# =============================================================================
# print_type_menu — matched presets prepend
# =============================================================================

@test "menu: print_type_menu with one matched preset places it as option 1" {
    MATCHED_PRESETS_LITERAL='"nextjs"'
    run menu_run print_type_menu
    [ "$status" -eq 0 ]
    # Option 1 = preset entry
    [[ "$output" == *"1) Use preset: nextjs"* ]]
    # Standard types now start at 2
    [[ "$output" == *"2) React / Next.js"* ]]
    [[ "$output" == *"12) Other / Generic"* ]]
}

@test "menu: print_type_menu with two matched presets places both at the top" {
    MATCHED_PRESETS_LITERAL='"nextjs" "fastapi"'
    run menu_run print_type_menu
    [ "$status" -eq 0 ]
    [[ "$output" == *"1) Use preset: nextjs"* ]]
    [[ "$output" == *"2) Use preset: fastapi"* ]]
    # Standard types renumbered to 3..13
    [[ "$output" == *"3) React / Next.js"* ]]
    [[ "$output" == *"13) Other / Generic"* ]]
}

@test "menu: print_type_menu with default_choice on a preset entry marks it" {
    MATCHED_PRESETS_LITERAL='"nextjs"'
    run menu_run print_type_menu 1
    [ "$status" -eq 0 ]
    [[ "$output" == *"1) Use preset: nextjs"*"detected"* ]]
}

# =============================================================================
# apply_type_choice — preset range
# =============================================================================

@test "menu: apply_type_choice with choice in preset range sets PRESET_NAME" {
    run bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$MENU_LIB'
        MATCHED_PRESETS=(\"nextjs\" \"fastapi\")
        PRESET_NAME=\"\"
        PROJECT_TYPE=\"\"
        apply_type_choice 1 && echo \"PRESET=\$PRESET_NAME TYPE=\$PROJECT_TYPE\"
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"PRESET=nextjs"* ]]
    [[ "$output" == *"TYPE="* ]]  # PROJECT_TYPE remains empty
}

@test "menu: apply_type_choice 2 with two presets selects the second one" {
    run bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$MENU_LIB'
        MATCHED_PRESETS=(\"nextjs\" \"fastapi\")
        PRESET_NAME=\"\"
        apply_type_choice 2 && echo \"PRESET=\$PRESET_NAME\"
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"PRESET=fastapi"* ]]
}

# =============================================================================
# apply_type_choice — standard type range
# =============================================================================

@test "menu: apply_type_choice with no presets and choice 1 sets PROJECT_TYPE=react" {
    run bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$MENU_LIB'
        MATCHED_PRESETS=()
        PROJECT_TYPE=\"\"
        apply_type_choice 1 && echo \"TYPE=\$PROJECT_TYPE\"
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"TYPE=react"* ]]
}

@test "menu: apply_type_choice with one preset and choice 2 maps to react (renumbered)" {
    run bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$MENU_LIB'
        MATCHED_PRESETS=(\"nextjs\")
        PROJECT_TYPE=\"\"
        apply_type_choice 2 && echo \"TYPE=\$PROJECT_TYPE\"
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"TYPE=react"* ]]
}

@test "menu: apply_type_choice with two presets and choice 6 maps to python (renumbered)" {
    # 2 presets occupy options 1 and 2; standard types start at 3.
    # python is the 4th standard type → option 6 with 2 presets ahead.
    run bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$MENU_LIB'
        MATCHED_PRESETS=(\"nextjs\" \"fastapi\")
        PROJECT_TYPE=\"\"
        apply_type_choice 6 && echo \"TYPE=\$PROJECT_TYPE\"
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"TYPE=python"* ]]
}

@test "menu: apply_type_choice with last standard option maps to generic" {
    run bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$MENU_LIB'
        MATCHED_PRESETS=()
        PROJECT_TYPE=\"\"
        apply_type_choice 11 && echo \"TYPE=\$PROJECT_TYPE\"
    "
    [ "$status" -eq 0 ]
    [[ "$output" == *"TYPE=generic"* ]]
}

# =============================================================================
# apply_type_choice — invalid input
# =============================================================================

@test "menu: apply_type_choice rejects non-numeric input with exit 1" {
    run bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$MENU_LIB'
        MATCHED_PRESETS=()
        apply_type_choice abc
    "
    [ "$status" -eq 1 ]
}

@test "menu: apply_type_choice rejects 0 with exit 1" {
    run bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$MENU_LIB'
        MATCHED_PRESETS=()
        apply_type_choice 0
    "
    [ "$status" -eq 1 ]
}

@test "menu: apply_type_choice rejects out-of-range choice with exit 1" {
    run bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$MENU_LIB'
        MATCHED_PRESETS=()
        apply_type_choice 99
    "
    [ "$status" -eq 1 ]
}

@test "menu: apply_type_choice with empty input rejects with exit 1" {
    run bash -c "
        source '$BASE_DIR/scripts/lib/common.sh'
        source '$MENU_LIB'
        MATCHED_PRESETS=()
        apply_type_choice ''
    "
    [ "$status" -eq 1 ]
}
