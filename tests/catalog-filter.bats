#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/lib/catalog-filter.sh — preset command/agent filtering SSOT
#
# Spec: specs/presets-commands-agents-filter/spec.md
# Plan: specs/presets-commands-agents-filter/plan.md (S1 — Phase 1, T001-T003)
#
# The lib is the single source of truth for resolving an item's domain,
# matching a filter entry (domain:<name> | exact item) against an item,
# computing the removal set (drop XOR keep, floor subtracted) and reporting
# floor (EF-111) violations + unknown names. NO consumer is wired this
# session — the lib is exercised in isolation against fixture catalogs and
# the real repo catalog (drift sanity).
#
# Decisions baked in (plan R1): keep-mode = whitelist, single polarity per
# list. Floor = work domain + assistant/assistant-auto command entry points,
# force-kept in BOTH modes. Horizontal domains (biz/legal/growth) are NOT
# special-cased here — that rejection lives in validate-presets (S3).
# =============================================================================

load 'test_helper'

REPO_ROOT="$BATS_TEST_DIRNAME/.."
CF_LIB="$REPO_ROOT/scripts/lib/catalog-filter.sh"

setup() {
    setup_test_dir
    _build_fixture_catalog
}

teardown() {
    teardown_test_dir
}

# Source the lib in a subshell, preserving argument boundaries (incl. empties).
# Usage: run_lib <function> [args...]
run_lib() {
    run bash -c 'source "$1"; shift; "$@"' _ "$CF_LIB" "$@"
}

# Build a small, controlled catalog under $TEST_DIR mirroring the real on-disk
# layout: commands in <domain>/ subdirs + 4 domainless top-level commands;
# agents flat with a <prefix>-<rest> name.
_build_fixture_catalog() {
    CMD_ROOT="$TEST_DIR/commands"
    AGT_ROOT="$TEST_DIR/agents"
    mkdir -p "$CMD_ROOT"/{work,ops,biz} "$AGT_ROOT"
    # commands — domain subdirs
    : > "$CMD_ROOT/work/work-plan.md"
    : > "$CMD_ROOT/work/work-explore.md"
    : > "$CMD_ROOT/ops/ops-proxmox.md"
    : > "$CMD_ROOT/ops/ops-deploy.md"
    : > "$CMD_ROOT/biz/biz-mvp.md"
    # commands — domainless top-level
    : > "$CMD_ROOT/assistant.md"
    : > "$CMD_ROOT/assistant-auto.md"
    : > "$CMD_ROOT/git-rename.md"
    : > "$CMD_ROOT/lessons.md"
    # agents — flat, prefix = domain
    : > "$AGT_ROOT/work-explore.md"
    : > "$AGT_ROOT/work-plan.md"
    : > "$AGT_ROOT/ops-proxmox.md"
    : > "$AGT_ROOT/ops-deploy.md"
    : > "$AGT_ROOT/biz-mvp.md"
    : > "$AGT_ROOT/wcag-audit.md"
    export CMD_ROOT AGT_ROOT
}

# =============================================================================
# Guard
# =============================================================================

@test "catalog-filter: lib file exists" {
    [ -f "$CF_LIB" ]
}

@test "catalog-filter: unknown catalog is rejected (defense)" {
    run_lib catalog_item_domain skills "x.md"
    [ "$status" -ne 0 ]
    run_lib catalog_list_items rules "$TEST_DIR"
    [ "$status" -ne 0 ]
}

# =============================================================================
# Domain resolution
# =============================================================================

@test "domain: commands subdir item resolves to its domain" {
    run_lib catalog_item_domain commands "work/work-plan.md"
    [ "$status" -eq 0 ]
    [ "$output" = "work" ]
    run_lib catalog_item_domain commands "ops/ops-proxmox.md"
    [ "$output" = "ops" ]
}

@test "domain: commands top-level item is domainless (empty)" {
    run_lib catalog_item_domain commands "assistant.md"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    run_lib catalog_item_domain commands "git-rename.md"
    [ -z "$output" ]
    run_lib catalog_item_domain commands "lessons.md"
    [ -z "$output" ]
}

@test "domain: agents prefix before first dash is the domain" {
    run_lib catalog_item_domain agents "work-explore.md"
    [ "$status" -eq 0 ]
    [ "$output" = "work" ]
    run_lib catalog_item_domain agents "ops-proxmox.md"
    [ "$output" = "ops" ]
}

@test "domain: agents non-domain prefix resolves mechanically (wcag-audit)" {
    run_lib catalog_item_domain agents "wcag-audit.md"
    [ "$status" -eq 0 ]
    [ "$output" = "wcag" ]
}

@test "name: item name is the basename without .md" {
    run_lib catalog_item_name commands "work/work-plan.md"
    [ "$output" = "work-plan" ]
    run_lib catalog_item_name agents "wcag-audit.md"
    [ "$output" = "wcag-audit" ]
    run_lib catalog_item_name commands "assistant.md"
    [ "$output" = "assistant" ]
}

# =============================================================================
# Enumeration
# =============================================================================

@test "enumerate: list_domains for commands excludes domainless top-level" {
    run_lib catalog_list_domains commands "$CMD_ROOT"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "biz" ]
    [ "${lines[1]}" = "ops" ]
    [ "${lines[2]}" = "work" ]
    [ "${#lines[@]}" -eq 3 ]
}

@test "enumerate: list_domains for agents includes every prefix" {
    run_lib catalog_list_domains agents "$AGT_ROOT"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "biz" ]
    [ "${lines[1]}" = "ops" ]
    [ "${lines[2]}" = "wcag" ]
    [ "${lines[3]}" = "work" ]
    [ "${#lines[@]}" -eq 4 ]
}

@test "enumerate: list_items for commands includes subdir + top-level paths" {
    run_lib catalog_list_items commands "$CMD_ROOT"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 9 ]
    [[ "$output" == *"work/work-plan.md"* ]]
    [[ "$output" == *"assistant.md"* ]]
    # relative to root — no absolute path leak
    [[ "$output" != *"$CMD_ROOT"* ]]
}

@test "enumerate: list_items for agents is flat" {
    run_lib catalog_list_items agents "$AGT_ROOT"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 6 ]
    [[ "$output" == *"wcag-audit.md"* ]]
}

@test "enumerate: missing root yields no items, exit 0" {
    run_lib catalog_list_items commands "$TEST_DIR/does-not-exist"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

# =============================================================================
# Entry matching (domain:<name> + exact item)
# =============================================================================

@test "match: domain entry matches every item of that domain" {
    run_lib catalog_entry_matches commands "domain:ops" "ops/ops-proxmox.md"
    [ "$status" -eq 0 ]
    run_lib catalog_entry_matches commands "domain:ops" "ops/ops-deploy.md"
    [ "$status" -eq 0 ]
}

@test "match: domain entry does not match other domains" {
    run_lib catalog_entry_matches commands "domain:ops" "work/work-plan.md"
    [ "$status" -ne 0 ]
}

@test "match: exact item entry matches only that item" {
    run_lib catalog_entry_matches commands "ops-proxmox" "ops/ops-proxmox.md"
    [ "$status" -eq 0 ]
    run_lib catalog_entry_matches commands "ops-proxmox" "ops/ops-deploy.md"
    [ "$status" -ne 0 ]
}

@test "match: agents domain + exact entries" {
    run_lib catalog_entry_matches agents "domain:wcag" "wcag-audit.md"
    [ "$status" -eq 0 ]
    run_lib catalog_entry_matches agents "ops-deploy" "ops-deploy.md"
    [ "$status" -eq 0 ]
}

# =============================================================================
# Removal set — DROP mode (R = matched \ floor)
# =============================================================================

@test "drop: domain entry removes the whole domain" {
    run_lib catalog_removal_set commands "$CMD_ROOT" drop "domain:ops"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 2 ]
    [[ "$output" == *"ops/ops-proxmox.md"* ]]
    [[ "$output" == *"ops/ops-deploy.md"* ]]
    [[ "$output" != *"work/"* ]]
}

@test "drop: domain + exact entries mix freely in one list" {
    run_lib catalog_removal_set commands "$CMD_ROOT" drop "domain:ops" "biz-mvp"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 3 ]
    [[ "$output" == *"biz/biz-mvp.md"* ]]
}

@test "drop: floor (work domain) is never removed even when explicitly targeted" {
    run_lib catalog_removal_set commands "$CMD_ROOT" drop "domain:work"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "drop: floor (assistant entry points) is never removed" {
    run_lib catalog_removal_set commands "$CMD_ROOT" drop "assistant" "assistant-auto"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "drop: agents work domain is floor-protected" {
    run_lib catalog_removal_set agents "$AGT_ROOT" drop "domain:work"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "drop: empty entry list removes nothing" {
    run_lib catalog_removal_set commands "$CMD_ROOT" drop
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

# =============================================================================
# Removal set — KEEP mode / whitelist (R = (all \ matched) \ floor)
# =============================================================================

@test "keep: whitelist removes everything outside the kept domain (floor stays)" {
    run_lib catalog_removal_set commands "$CMD_ROOT" keep "domain:ops"
    [ "$status" -eq 0 ]
    # kept: ops/* (matched) + work/* + assistant + assistant-auto (floor)
    # removed: biz-mvp, git-rename, lessons
    [ "${#lines[@]}" -eq 3 ]
    [[ "$output" == *"biz/biz-mvp.md"* ]]
    [[ "$output" == *"git-rename.md"* ]]
    [[ "$output" == *"lessons.md"* ]]
    [[ "$output" != *"ops/"* ]]
    [[ "$output" != *"work/"* ]]
    [[ "$output" != *"assistant"* ]]
}

@test "keep: exact item rescues one item of an otherwise-excluded domain (R1)" {
    # keep work domain + one ops item; ops-proxmox and the rest go.
    run_lib catalog_removal_set commands "$CMD_ROOT" keep "domain:work" "ops-deploy"
    [ "$status" -eq 0 ]
    [[ "$output" == *"ops/ops-proxmox.md"* ]]
    [[ "$output" == *"biz/biz-mvp.md"* ]]
    [[ "$output" != *"ops/ops-deploy.md"* ]]
    [[ "$output" != *"work/"* ]]
}

# =============================================================================
# Floor violations (EF-111) — validation helper, DROP mode only
# =============================================================================

@test "floor-violation: drop domain:work is flagged" {
    run_lib catalog_floor_violations commands "$CMD_ROOT" drop "domain:work"
    [ "$status" -eq 0 ]
    [[ "$output" == *"domain:work"* ]]
}

@test "floor-violation: drop assistant entry point is flagged" {
    run_lib catalog_floor_violations commands "$CMD_ROOT" drop "assistant"
    [ "$status" -eq 0 ]
    [[ "$output" == *"assistant"* ]]
}

@test "floor-violation: drop an exact work-domain item is flagged" {
    run_lib catalog_floor_violations commands "$CMD_ROOT" drop "work-plan"
    [ "$status" -eq 0 ]
    [[ "$output" == *"work-plan"* ]]
}

@test "floor-violation: dropping a non-floor domain is not flagged" {
    run_lib catalog_floor_violations commands "$CMD_ROOT" drop "domain:ops" "biz-mvp"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "floor-violation: agents domain:work is flagged" {
    run_lib catalog_floor_violations agents "$AGT_ROOT" drop "domain:work"
    [ "$status" -eq 0 ]
    [[ "$output" == *"domain:work"* ]]
}

@test "floor-violation: keep mode never violates (floor force-kept)" {
    run_lib catalog_floor_violations commands "$CMD_ROOT" keep "domain:ops"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

# =============================================================================
# Unknown-name detection (EF-105 warning source)
# =============================================================================

@test "unknown: known domain + item entries report nothing" {
    run_lib catalog_unknown_entries commands "$CMD_ROOT" "domain:ops" "biz-mvp"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "unknown: typo'd domain and missing item are reported" {
    run_lib catalog_unknown_entries commands "$CMD_ROOT" "domain:opss" "does-not-exist"
    [ "$status" -eq 0 ]
    [[ "$output" == *"domain:opss"* ]]
    [[ "$output" == *"does-not-exist"* ]]
}

@test "unknown: a domain valid in one catalog may be unknown in the other" {
    # wcag is an agents-only prefix; unknown as a commands domain.
    run_lib catalog_unknown_entries commands "$CMD_ROOT" "domain:wcag"
    [[ "$output" == *"domain:wcag"* ]]
    run_lib catalog_unknown_entries agents "$AGT_ROOT" "domain:wcag"
    [ -z "$output" ]
}

# =============================================================================
# Real repo catalog — drift sanity (the lib must resolve the live layout)
# =============================================================================

@test "repo: real command domains include work and ops" {
    run_lib catalog_list_domains commands "$REPO_ROOT/.claude/commands"
    [ "$status" -eq 0 ]
    [[ "$output" == *"work"* ]]
    [[ "$output" == *"ops"* ]]
    [[ "$output" == *"qa"* ]]
}

@test "repo: real catalog drop domain:work removes nothing (floor holds)" {
    run_lib catalog_removal_set commands "$REPO_ROOT/.claude/commands" drop "domain:work"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "repo: nextjs stack-mirror drop reduces commands and agents" {
    # The US-4 stack mirror (counterparts of nextjs' dropped skills).
    run_lib catalog_removal_set commands "$REPO_ROOT/.claude/commands" drop \
        "dev-flutter" "ops-mobile-release" "ops-opnsense" "ops-proxmox" \
        "ops-infra-code" "data-pipeline"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -ge 6 ]
    run_lib catalog_removal_set agents "$REPO_ROOT/.claude/agents" drop \
        "dev-flutter" "ops-mobile-release" "ops-opnsense" "ops-proxmox" \
        "ops-infra-code" "data-pipeline"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -ge 5 ]
}

# =============================================================================
# Preset-file parsing helpers (cf_filter_mode / cf_filter_entries) — the SSOT
# for "parse a preset file into (mode, entries)", previously hand-copied in
# new-project.sh, update.sh and validate-presets.sh. jq-backed.
# =============================================================================

# Write a foundation.<catalog> filter object into a preset file and echo its path.
# $1 = catalog (commands|agents), $2 = filter body (JSON object), file at $TEST_DIR.
_write_filter_preset() {
    local catalog="$1" body="$2" f="$TEST_DIR/preset.json"
    printf '{"name":"t","foundation":{"%s":%s}}\n' "$catalog" "$body" > "$f"
    echo "$f"
}

@test "cf_filter_mode: drop present → drop" {
    skip_if_no_jq
    local f; f=$(_write_filter_preset commands '{"drop":["dev-flutter"]}')
    run_lib cf_filter_mode "$f" commands
    [ "$status" -eq 0 ]
    [ "$output" = "drop" ]
}

@test "cf_filter_mode: keep present → keep" {
    skip_if_no_jq
    local f; f=$(_write_filter_preset commands '{"keep":["work-plan"]}')
    run_lib cf_filter_mode "$f" commands
    [ "$status" -eq 0 ]
    [ "$output" = "keep" ]
}

@test "cf_filter_mode: both present → drop wins (drop-first)" {
    skip_if_no_jq
    local f; f=$(_write_filter_preset commands '{"drop":["x"],"keep":["y"]}')
    run_lib cf_filter_mode "$f" commands
    [ "$output" = "drop" ]
}

@test "cf_filter_mode: neither present → empty" {
    skip_if_no_jq
    local f; f=$(_write_filter_preset commands '{}')
    run_lib cf_filter_mode "$f" commands
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "cf_filter_mode: empty array → empty (declared-but-empty ignored)" {
    skip_if_no_jq
    local f; f=$(_write_filter_preset commands '{"drop":[]}')
    run_lib cf_filter_mode "$f" commands
    [ -z "$output" ]
}

@test "cf_filter_mode: scalar (malformed) → empty, no crash" {
    skip_if_no_jq
    local f; f=$(_write_filter_preset commands '{"drop":"oops"}')
    run_lib cf_filter_mode "$f" commands
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "cf_filter_mode: missing catalog key → empty" {
    skip_if_no_jq
    local f; f=$(_write_filter_preset commands '{"drop":["x"]}')
    run_lib cf_filter_mode "$f" agents
    [ -z "$output" ]
}

@test "cf_filter_entries: lists the entries of the active mode, one per line" {
    skip_if_no_jq
    local f; f=$(_write_filter_preset commands '{"drop":["dev-flutter","domain:ops","data-pipeline"]}')
    run_lib cf_filter_entries "$f" commands drop
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 3 ]
    [ "${lines[0]}" = "dev-flutter" ]
    [ "${lines[1]}" = "domain:ops" ]
    [ "${lines[2]}" = "data-pipeline" ]
}

@test "cf_filter_entries: empty/missing mode → no output" {
    skip_if_no_jq
    local f; f=$(_write_filter_preset commands '{"drop":["x"]}')
    run_lib cf_filter_entries "$f" commands keep
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}
