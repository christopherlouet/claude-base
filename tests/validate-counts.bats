#!/usr/bin/env bats

# =============================================================================
# Tests for validate-counts.sh (Layer 1 + Layer 2 anti-drift scan)
#
# Isolation strategy: we build a fake foundation in TEST_DIR, copy the script
# + its common library into it, and execute it. The script uses
# `dirname(BASH_SOURCE)` so it scans TEST_DIR instead of the real repo.
# No risk of polluting the real repo.
# =============================================================================

load 'test_helper'

VALIDATE_COUNTS_SCRIPT_REAL="$BATS_TEST_DIRNAME/../scripts/validate-counts.sh"

setup() {
    setup_test_dir

    # Build a minimal fake foundation in TEST_DIR with known counts:
    # 3 commands, 2 agents, 1 skill, 4 rules, 5 tests, 1 test file
    mkdir -p "$TEST_DIR/.claude/commands/work"
    mkdir -p "$TEST_DIR/.claude/agents"
    mkdir -p "$TEST_DIR/.claude/skills/sample-skill"
    mkdir -p "$TEST_DIR/.claude/rules"
    mkdir -p "$TEST_DIR/scripts/lib"
    mkdir -p "$TEST_DIR/tests"
    mkdir -p "$TEST_DIR/docs"
    mkdir -p "$TEST_DIR/website/src/pages"
    mkdir -p "$TEST_DIR/website/src/components"
    mkdir -p "$TEST_DIR/website/docs/intro"
    mkdir -p "$TEST_DIR/website/docs/reference"

    touch "$TEST_DIR/.claude/commands/work/cmd1.md" \
          "$TEST_DIR/.claude/commands/work/cmd2.md" \
          "$TEST_DIR/.claude/commands/work/cmd3.md"
    touch "$TEST_DIR/.claude/agents/agent1.md" \
          "$TEST_DIR/.claude/agents/agent2.md"
    touch "$TEST_DIR/.claude/skills/sample-skill/SKILL.md"
    touch "$TEST_DIR/.claude/rules/rule1.md" \
          "$TEST_DIR/.claude/rules/rule2.md" \
          "$TEST_DIR/.claude/rules/rule3.md" \
          "$TEST_DIR/.claude/rules/rule4.md"

    # 1 test file with 5 @test → ACTUAL_TESTS=5, ACTUAL_TEST_FILES=1
    # NB: do NOT use a heredoc with literal @test, because bats preprocesses
    # @test lines in .bats files even inside heredocs and breaks them.
    # printf avoids the collision with the bats preprocessor.
    {
        echo "#!/usr/bin/env bats"
        printf '@test "test%s" { :; }\n' 1 2 3 4 5
    } > "$TEST_DIR/tests/sample.bats"

    # Copy the script and its library (the script will resolve BASE_DIR=TEST_DIR)
    cp "$VALIDATE_COUNTS_SCRIPT_REAL" "$TEST_DIR/scripts/validate-counts.sh"
    cp -r "$BATS_TEST_DIRNAME/../scripts/lib/"* "$TEST_DIR/scripts/lib/"
    chmod +x "$TEST_DIR/scripts/validate-counts.sh"

    # Path of the copied script for the tests
    VALIDATE_SCRIPT="$TEST_DIR/scripts/validate-counts.sh"
    export VALIDATE_SCRIPT
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Basic tests (smoke)
# =============================================================================

@test "validate-counts.sh exists and is executable" {
    [ -f "$VALIDATE_COUNTS_SCRIPT_REAL" ]
    [ -x "$VALIDATE_COUNTS_SCRIPT_REAL" ]
}

@test "validate-counts.sh shows help with --help" {
    run "$VALIDATE_SCRIPT" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"USAGE"* ]]
    [[ "$output" == *"compteurs"* ]] || [[ "$output" == *"Validate"* ]]
}

@test "validate-counts.sh on a coherent fake foundation: exit 0" {
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"consistent"* ]] || [[ "$output" == *"No drift"* ]] || [[ "$output" == *"coherents"* ]] || [[ "$output" == *"Aucun drift"* ]]
}

@test "validate-counts.sh shows the actual counts in its output" {
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 0 ]
    # The fake foundation has 3 commands / 2 agents / 1 skill / 4 rules
    # Loose assertions (regex) because bats may normalize whitespace.
    [[ "$output" =~ Commands[[:space:]]*:[[:space:]]*3 ]]
    [[ "$output" =~ Agents[[:space:]]*:[[:space:]]*2 ]]
    [[ "$output" =~ Skills[[:space:]]*:[[:space:]]*1 ]]
    [[ "$output" =~ Rules[[:space:]]*:[[:space:]]*4 ]]
    # No "Tests :" line any more — the test counters are not tracked (US4).
}

# =============================================================================
# Layer 1 tests — Source-of-truth files
# =============================================================================

@test "validate-counts.sh detects a drift in CLAUDE.md (commands)" {
    # Create a CLAUDE.md with a wrong counter: "999 commandes" instead of 3
    cat > "$TEST_DIR/CLAUDE.md" <<'EOF'
# Test
The foundation has 999 commandes.
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"999"* ]] || [[ "$output" == *"incohérence"* ]]
}

# =============================================================================
# Layer 2 tests — Global anti-drift scan (scan_drift)
# =============================================================================

@test "scan_drift Layer 2: detects the 'Skills (N)' markdown header pattern" {
    # We have 1 actual skill but declare 99 in a markdown heading
    cat > "$TEST_DIR/website/docs/intro/architecture.md" <<'EOF'
# Architecture

## Skills (99)
Les skills auto-declenches.
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"99 skills"* ]]
    [[ "$output" == *"canonical: 1"* ]]
}

@test "scan_drift Layer 2: detects the 'N Sub-Agents' TS string literal pattern" {
    # We have 2 actual agents but declare 88 in a TSX literal
    cat > "$TEST_DIR/website/src/pages/index.tsx" <<'EOF'
const stats = ['88 Sub-Agents', '3 Commands'];
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"88 agents"* ]] || [[ "$output" == *"88 sub-agents"* ]]
}

@test "scan_drift Layer 2: detects the '| **Rules** | N |' bold table cell pattern" {
    # We have 4 actual rules but declare 77 in a markdown table
    cat > "$TEST_DIR/website/docs/intro/index.md" <<'EOF'
# Stats

| Composant | Nombre |
|-----------|--------|
| **Rules** | 77 |
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"77 rules"* ]]
}

@test "scan_drift Layer 2: detects the 'Skills disponibles (N)' pattern" {
    cat > "$TEST_DIR/.claude/skills/README.md" <<'EOF'
# Skills

## Skills disponibles (66)
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"66 skills"* ]]
}

@test "scan_drift Layer 2: detects 'Commands (N available)' (text after digit)" {
    # Heading with extra text after the digit: '## Commands (55 available)'
    # The plain '## Label (N)' pattern would miss this because of the trailing
    # ' available'. The extended pattern accepts [^)]* after the digit.
    cat > "$TEST_DIR/docs/ARCHITECTURE.md" <<'EOF'
# Foundation

## Commands (55 available)
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"55 commands"* ]]
}

@test "scan_drift Layer 2: detects multi-column table '| **Agents** | ... | ... | N |'" {
    # 4-column table with the bold label cell and the number cell separated
    # by intermediate cells. The plain adjacent pattern would miss this.
    cat > "$TEST_DIR/website/docs/intro/what-is-claude-code.md" <<'EOF'
# What

| Component | Trigger | Example | Count |
|-----------|---------|---------|-------|
| **Agents** | Via commands | Isolated autonomous sub-agents | 88 |
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"88 agents"* ]] || [[ "$output" == *"88 sub-agents"* ]]
}

# =============================================================================
# Layer 2 tests — scan_tests_drift (badges + Test layout)
# =============================================================================

# =============================================================================
# Anti-false-positive tests
# =============================================================================

@test "scan_drift: does NOT flag numbers <= 5 (subset/example)" {
    # 1 actual skill, but we mention "3 skills" in a heading
    # The scan must ignore numbers <= 5 to avoid flagging examples
    cat > "$TEST_DIR/website/docs/intro/index.md" <<'EOF'
# Test

## Skills (3)
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "scan_drift: does NOT flag per-domain subtotals (WORK 15)" {
    # We declare "WORK (15)" which is a domain subtotal, not a canonical total
    # The scan must NOT flag because the label pattern is WORK, not Skills/Agents/Rules/Commands
    cat > "$TEST_DIR/website/sidebars.ts" <<'EOF'
const sidebars = {
  commands: [
    { label: 'WORK (15)' },
    { label: 'OPS (34)' }
  ]
};
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "scan_drift: does NOT flag the CHANGELOG (history)" {
    # The CHANGELOG contains historical references to old counters
    # The scan must explicitly exclude it
    cat > "$TEST_DIR/CHANGELOG.md" <<'EOF'
# Changelog

## v0.1.0
- 41 skills released
- 21 rules added
EOF
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 0 ]
}

# =============================================================================
# Integration tests: the real repo must always pass
# =============================================================================

@test "validate-counts.sh on the REAL repo: exit 0 (regression test)" {
    run "$VALIDATE_COUNTS_SCRIPT_REAL"
    [ "$status" -eq 0 ]
    [[ "$output" == *"consistent"* ]] || [[ "$output" == *"No drift"* ]] || [[ "$output" == *"consistent"* ]] || [[ "$output" == *"No drift"* ]] || [[ "$output" == *"coherents"* ]] || [[ "$output" == *"Aucun drift"* ]]
}

# =============================================================================
# Layer 2 tests — injected markers (count + version) — added for the doc-gate
# hardening (catches markers an injector forgot to cover, e.g. AGENTS.md)
# =============================================================================

@test "marker drift: a wrong <!-- count:rules --> marker is flagged (canonical 4)" {
    printf 'rules: <!-- count:rules -->99<!-- /count --> here\n' > "$TEST_DIR/AGENTS.md"
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"count:rules marker = 99"* ]]
    [[ "$output" == *"canonical: 4"* ]]
}

@test "marker drift: a correct <!-- count:rules --> marker passes" {
    printf 'rules: <!-- count:rules -->4<!-- /count --> here\n' > "$TEST_DIR/AGENTS.md"
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "marker drift: a wrong <!-- count:commands --> marker is flagged (canonical 3)" {
    printf 'cmds: <!-- count:commands -->77<!-- /count -->\n' > "$TEST_DIR/AGENTS.md"
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"count:commands marker = 77"* ]]
}

@test "version marker drift: a marker not matching VERSION is flagged" {
    printf '1.0.0' > "$TEST_DIR/VERSION"
    printf 'current: <!-- version -->9.9.9<!-- /version -->\n' > "$TEST_DIR/AGENTS.md"
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"version marker = 9.9.9"* ]]
    [[ "$output" == *"canonical: 1.0.0"* ]]
}

@test "version marker drift: a marker matching VERSION passes" {
    printf '1.0.0' > "$TEST_DIR/VERSION"
    printf 'current: <!-- version -->1.0.0<!-- /version -->\n' > "$TEST_DIR/AGENTS.md"
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "version marker drift: no VERSION file → version check is a no-op (no crash)" {
    printf 'current: <!-- version -->9.9.9<!-- /version -->\n' > "$TEST_DIR/AGENTS.md"
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 0 ]
}

# =============================================================================
# CONTRIBUTING.md inline-comment counts (gate-hole fix #5)
# Counts live in a code fence (e.g. "commands/  # 128 commands"), so they can't
# carry <!-- count --> markers and the # is not line-anchored — they escaped the
# global scan. A targeted prose scan of CONTRIBUTING.md closes that hole.
# =============================================================================

@test "validate-counts.sh detects a drift in CONTRIBUTING.md inline comment (commands)" {
    # Fake foundation has 3 commands; declare 99 in a fenced tree comment.
    printf '# Contributing\n\n```\n.claude/\n  commands/    # 99 commands (source of truth)\n```\n' \
        > "$TEST_DIR/CONTRIBUTING.md"
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"99 commands"* ]]
    [[ "$output" == *"canonical: 3"* ]]
}

@test "validate-counts.sh detects a drift in CONTRIBUTING.md inline comment (sub-agents)" {
    # Fake foundation has 2 agents; declare 88 sub-agents.
    printf '# Contributing\n\n```\n  agents/      # 88 sub-agents\n```\n' \
        > "$TEST_DIR/CONTRIBUTING.md"
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"88 agents"* ]]
    [[ "$output" == *"canonical: 2"* ]]
}

@test "validate-counts.sh accepts a CONTRIBUTING.md with correct inline counts" {
    # The -le 5 guard skips small subset numbers, so push commands above it (6)
    # and declare the matching count — this actually exercises the accept path.
    touch "$TEST_DIR/.claude/commands/work/cmd4.md" \
          "$TEST_DIR/.claude/commands/work/cmd5.md" \
          "$TEST_DIR/.claude/commands/work/cmd6.md"
    printf '# Contributing\n\n```\n  commands/    # 6 commands\n```\n' \
        > "$TEST_DIR/CONTRIBUTING.md"
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "validate-counts.sh catches a drifted count even with an adjective (contextual rules)" {
    # Fake foundation has 4 rules; "# 99 contextual rules" must still be caught
    # despite the adjective between the number and the label.
    printf '# Contributing\n\n```\n  rules/       # 99 contextual rules\n```\n' \
        > "$TEST_DIR/CONTRIBUTING.md"
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"99 rules"* ]]
    [[ "$output" == *"canonical: 4"* ]]
}

# =============================================================================
# The test counters are no longer tracked (US4 / EF-009 / EF-010)
#
# Measured over 95 commits: `tests` moved 112 count-lines and `testFiles` 48,
# while commands, skills, rules and presets moved ZERO. counts.json and
# README.md were touched by 63% and 69% of commits -- yet no commit touched
# only those two, so the cost was never clutter: it was SERIALISATION. Two
# changes prepared in parallel each bumped the same line, so accepting one
# invalidated the other.
#
# The principled line is not "it churns" but WHAT VERIFIES WHAT. The test count
# is the only counter that verifies itself -- CI runs the suite on every PR, so
# a stored figure tells a reader nothing they do not already have. The
# structural counters do NOT verify themselves: a doc claiming 106 commands
# while 107 exist is caught by this gate and by nothing else. So the
# self-verifying counters go and the rest stay.
#
# Accepted loss, stated rather than hidden (EF-006): a stale test count written
# into prose later is no longer detected. Its harm is recoverable (a wrong
# number in a README), and no replacement guard is added here -- adding one
# during this pass is what EF-011 forbids.
# =============================================================================

@test "counts.json no longer carries the self-verifying test counters" {
    # `-eq 1` (no match), never `-ne 0`: grep exits 2 when the FILE IS MISSING,
    # so `-ne 0` would keep this green if counts.json were deleted or renamed —
    # it could not tell "the counter is gone" from "the file is gone".
    [ -f "$BATS_TEST_DIRNAME/../counts.json" ]
    run grep -E '"(tests|testFiles)"[[:space:]]*:' "$BATS_TEST_DIRNAME/../counts.json"
    [ "$status" -eq 1 ]
}

@test "README carries no hardcoded test count (badge or count marker)" {
    [ -f "$BATS_TEST_DIRNAME/../README.md" ]
    run grep -nE 'tests-[0-9]+|count:tests|count:testFiles' "$BATS_TEST_DIRNAME/../README.md"
    [ "$status" -eq 1 ]
}

@test "EF-010: adding a test file produces no counts drift" {
    # A change that adds nothing COUNTED must carry no counting update.
    #
    # The fake foundation ships 5 tests; this plants a badge stating so, then
    # adds two more tests. BEFORE the removal the badge drifted (5 vs 7) and the
    # gate refused -- a change that added nothing counted still had to carry a
    # counting update, which is precisely what serialised parallel work. AFTER,
    # there is no test figure to drift.
    echo '[![Tests](https://img.shields.io/badge/tests-5%20passing-brightgreen)](./tests)' \
        >> "$TEST_DIR/README.md"
    printf '@test "a" {\n  true\n}\n@test "b" {\n  true\n}\n' \
        > "$TEST_DIR/tests/newly-added.bats"
    run bash "$TEST_DIR/scripts/validate-counts.sh"
    [ "$status" -eq 0 ]
}

@test "control: scan_marker_drift can still fail (a count: marker drift is caught)" {
    # The anti-drift property must SURVIVE the removal. A gate that can no
    # longer fail is worse than the friction it removed, because the belief
    # that it protects the docs survives with it.
    #
    # There are TWO live scanners and one control per scanner, because a single
    # control does not span them. An earlier version planted a marker drift AND
    # a prose drift in one test — but the marker drift alone satisfied every
    # assertion, so the test still passed against a mutant with scan_drift
    # disabled. Each control now asserts its own scanner's message signature.
    echo '<!-- count:commands -->999<!-- /count -->' >> "$TEST_DIR/README.md"
    run bash "$TEST_DIR/scripts/validate-counts.sh"
    [ "$status" -ne 0 ]
    [[ "$output" == *"count:commands"* ]]
}

@test "control: scan_drift can still fail (a prose/heading drift is caught)" {
    # scan_drift covers markdown headings, table cells and TS literals — most of
    # the live patterns. Its own signature is "N <resource>", distinct from the
    # marker scanner's "count:<key> marker = N".
    echo '## Skills (999)' >> "$TEST_DIR/README.md"
    run bash "$TEST_DIR/scripts/validate-counts.sh"
    [ "$status" -ne 0 ]
    [[ "$output" == *"999 skills"* ]]
}

# =============================================================================
# The marker gate's blind spots — Phase 4 of specs/guardrail-cleanup/
# =============================================================================
# Three defects recorded on 2026-08-29 and repaired here: a document that QUOTES
# a marker was indistinguishable from one that violates it (it blocked real work
# that day); the scan had no anti-vacuity floor, so stripping every marker left
# the gate green; and it validated four of the six live keys, silently skipping
# the rest through `*) continue ;;` while `byDomain.*` never matched at all.

# fake_counts_json — give the fake foundation a counts.json consistent with it
# (3 commands, 2 agents, 1 skill, 4 rules, no modules) plus the extra keys.
fake_counts_json() {
    # The fake foundation carries the REAL module bundles (the lib is copied
    # wholesale), so point the registry at an empty dir: this fake has no
    # module-owned commands, and core == full here.
    mkdir -p "$TEST_DIR/nomodules"
    export MODULES_BUNDLES_DIR="$TEST_DIR/nomodules"
    cat > "$TEST_DIR/counts.json" <<JSON
{
  "commands": 3, "agents": 2, "skills": 1, "rules": 4,
  "core": { "commands": 3, "agents": 2, "skills": 1 },
  "byDomain": { "work": 3 },
  "presets": 7,
  "marketplaceAuditPilots": 2
}
JSON
}

# floor_markers — the four structural markers the anti-vacuity floor requires,
# all correct, so a test can be about something else.
floor_markers() {
    printf 'c <!-- count:commands -->3<!-- /count --> a <!-- count:agents -->2<!-- /count --> s <!-- count:skills -->1<!-- /count --> r <!-- count:rules -->4<!-- /count -->\n' \
        > "$TEST_DIR/docs/floor.md"
}

# --- a document that quotes a marker is not a document that violates one -----

@test "marker drift: a marker inside a fenced code block is documentation, not drift" {
    { echo 'How the gate works:'; echo '```markdown'
      echo '<!-- count:rules -->99<!-- /count -->'; echo '```'; } > "$TEST_DIR/docs/explainer.md"
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "marker drift: a marker inside inline backticks is documentation, not drift" {
    printf 'Write `<!-- count:rules -->99<!-- /count -->` to pin a number.\n' > "$TEST_DIR/docs/explainer.md"
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "marker drift: CONTROL - the same marker unquoted is still flagged" {
    # Without this arm the two above would pass on a scanner that had simply
    # stopped looking at markers altogether.
    printf 'Live: <!-- count:rules -->99<!-- /count -->\n' > "$TEST_DIR/docs/explainer.md"
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"count:rules marker = 99"* ]]
}

@test "marker drift: a quoted marker does not hide a live one in the same file" {
    { printf 'Example: `<!-- count:rules -->99<!-- /count -->`\n'
      printf 'Live: <!-- count:commands -->77<!-- /count -->\n'; } > "$TEST_DIR/docs/explainer.md"
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"count:commands marker = 77"* ]]
    [[ "$output" != *"count:rules marker = 99"* ]]
}

# --- an empty gate is a green gate ------------------------------------------

@test "marker floor: a foundation with counts.json and no markers at all fails" {
    fake_counts_json
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"count:commands"* ]]
    [[ "$output" == *"no"*"marker"* ]]
}

@test "marker floor: CONTROL - the four structural markers satisfy the floor" {
    fake_counts_json
    floor_markers
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "marker floor: removing markers for ONE structural key still fails" {
    fake_counts_json
    printf 'c <!-- count:commands -->3<!-- /count --> a <!-- count:agents -->2<!-- /count --> s <!-- count:skills -->1<!-- /count -->\n' \
        > "$TEST_DIR/docs/floor.md"
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"count:rules"* ]]
}

# --- every live key is validated, and an unknown one is never skipped --------

@test "marker keys: a wrong count:presets marker is flagged against counts.json" {
    fake_counts_json; floor_markers
    printf 'presets: <!-- count:presets -->99<!-- /count -->\n' > "$TEST_DIR/docs/presets.md"
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"count:presets marker = 99"* ]]
    [[ "$output" == *"canonical: 7"* ]]
}

@test "marker keys: a wrong count:marketplaceAuditPilots marker is flagged" {
    fake_counts_json; floor_markers
    printf 'pilots: <!-- count:marketplaceAuditPilots -->99<!-- /count -->\n' > "$TEST_DIR/docs/pilots.md"
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"count:marketplaceAuditPilots marker = 99"* ]]
}

@test "marker keys: a dotted count:byDomain.work marker is matched and checked" {
    # The old pattern excluded the dot, so these markers were never seen at all.
    fake_counts_json; floor_markers
    printf 'work: <!-- count:byDomain.work -->99<!-- /count -->\n' > "$TEST_DIR/docs/domains.md"
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"count:byDomain.work marker = 99"* ]]
    [[ "$output" == *"canonical: 3"* ]]
}

@test "marker keys: CONTROL - correct presets and byDomain markers pass" {
    fake_counts_json; floor_markers
    printf 'p <!-- count:presets -->7<!-- /count --> w <!-- count:byDomain.work -->3<!-- /count -->\n' \
        > "$TEST_DIR/docs/extra.md"
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 0 ]
}

@test "marker keys: a key with no canonical source is reported, never skipped" {
    fake_counts_json; floor_markers
    printf 'bogus: <!-- count:bogus -->12<!-- /count -->\n' > "$TEST_DIR/docs/bogus.md"
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"bogus"* ]]
}

# --- _check_core is exercised through the script, not only through its data --

@test "core split: a wrong core.commands in counts.json is flagged" {
    # Recorded gap: a mutant disabling _check_core survived the whole suite,
    # because the only coverage re-implemented the invariant against counts.json
    # instead of running the script that enforces it.
    fake_counts_json; floor_markers
    sed -i.bak 's/"core": { "commands": 3/"core": { "commands": 99/' "$TEST_DIR/counts.json"
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"core.commands"* ]]
}

@test "core split: CONTROL - a consistent core object passes" {
    fake_counts_json; floor_markers
    run "$VALIDATE_SCRIPT"
    [ "$status" -eq 0 ]
}
