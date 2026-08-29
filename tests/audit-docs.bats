#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/audit-docs.sh — doc drift firewall
# Spec: specs/audit-docs/spec.md
# Plan: specs/audit-docs/plan.md
#
# Each test creates a minimal fixture .md in $TEST_DIR and runs the script
# with `--target $TEST_DIR/<file>.md` to scope detection to that fixture.
# Categories: paths / verbs / flags / scripts / npm
# Plus: env-var hatch, remote-URL tolerance, regression PR #199, zero-FP gate.
# =============================================================================

load 'test_helper'

AUDIT_DOCS="$BASE_DIR/scripts/audit-docs.sh"

setup() {
    setup_test_dir
}

teardown() {
    teardown_test_dir
}

# =============================================================================
# Category: paths (EF-001)
# =============================================================================

@test "audit-docs: rejects unknown ~/X claude-related path prefix (T005, EF-001)" {
    # Threat model: typos of foundation paths. We narrow scope to paths
    # containing "claude" — generic ~/X paths (~/.ssh, ~/.zshrc) are
    # tutorial-legit and out of scope.
    cat > "$TEST_DIR/bad-path.md" <<'EOF'
# Bad path

Run `~/.claude-bogus-install/foo` to break things.
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/bad-path.md" --category paths
    [ "$status" -eq 1 ]
    [[ "$output" == *"paths"* ]]
    [[ "$output" == *"claude-bogus-install"* ]]
}

@test "audit-docs: accepts known ~/.local/share/claude-base/ path (T006, EF-001)" {
    cat > "$TEST_DIR/good-path.md" <<'EOF'
# Good path

The foundation lives at `~/.local/share/claude-base/` per install.sh.
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/good-path.md" --category paths
    [ "$status" -eq 0 ]
}

# =============================================================================
# Category: verbs (EF-002)
# =============================================================================

@test "audit-docs: rejects claude-base nonexistentverb (T007, EF-002)" {
    cat > "$TEST_DIR/bad-verb.md" <<'EOF'
# Bad verb

Run `claude-base bogusverb` to install.
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/bad-verb.md" --category verbs
    [ "$status" -eq 1 ]
    [[ "$output" == *"verbs"* ]]
    [[ "$output" == *"bogusverb"* ]]
}

@test "audit-docs: accepts the module verbs add/remove/modules (EF-002)" {
    # Verbs shipped by specs/foundation-modules S2 (claude-base add/remove/
    # modules). Pinned here so the T028 docs task (S4) cannot trip the
    # zero-FP gate: documenting the verbs must not read as drift.
    cat > "$TEST_DIR/module-verbs.md" <<'EOF'
# Module verbs

```bash
claude-base add legal ./my-project
claude-base remove growth ./my-project
claude-base modules ./my-project
```
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/module-verbs.md" --category verbs
    [ "$status" -eq 0 ]
}

@test "audit-docs: ignores claude-base is a foundation (English prose) (T008, EF-002)" {
    cat > "$TEST_DIR/prose.md" <<'EOF'
# Prose

claude-base is a foundation for Claude Code workflows.
You can use claude-base in production with confidence.
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/prose.md" --category verbs
    [ "$status" -eq 0 ]
}

# =============================================================================
# Category: flags (EF-003)
# =============================================================================

@test "audit-docs: rejects claude-base init --foo (T009, EF-003)" {
    cat > "$TEST_DIR/bad-flag.md" <<'EOF'
# Bad flag

```bash
claude-base init --foo ./my-project
```
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/bad-flag.md" --category flags
    [ "$status" -eq 1 ]
    [[ "$output" == *"flags"* ]]
    [[ "$output" == *"--foo"* ]]
}

@test "audit-docs: accepts claude-base init --preset nextjs (T010, EF-003)" {
    cat > "$TEST_DIR/good-flag.md" <<'EOF'
# Good flag

```bash
claude-base init --preset nextjs ./my-web-app
```
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/good-flag.md" --category flags
    [ "$status" -eq 0 ]
}

# =============================================================================
# Category: scripts (EF-004, EF-013)
# =============================================================================

@test "audit-docs: rejects ./scripts/nuclear.sh (T011, EF-004)" {
    cat > "$TEST_DIR/bad-script.md" <<'EOF'
# Bad script

Run `./scripts/nuclear.sh` to destroy your project.
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/bad-script.md" --category scripts
    [ "$status" -eq 1 ]
    [[ "$output" == *"scripts"* ]]
    [[ "$output" == *"nuclear.sh"* ]]
}

@test "audit-docs: accepts ./scripts/test.sh (T012, EF-004)" {
    cat > "$TEST_DIR/good-script.md" <<'EOF'
# Good script

Run `./scripts/test.sh` to run the bats tests in parallel.
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/good-script.md" --category scripts
    [ "$status" -eq 0 ]
}

@test "audit-docs: https URL with scripts/X.sh substring is NOT flagged (T018, EF-013)" {
    cat > "$TEST_DIR/remote-url.md" <<'EOF'
# Remote URL

The install script is at https://github.com/christopherlouet/claude-base/blob/main/scripts/deploy.sh — not a local script.
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/remote-url.md" --category scripts
    [ "$status" -eq 0 ]
}

# =============================================================================
# Category: npm (EF-005)
# =============================================================================

@test "audit-docs: rejects npm --prefix website run nonsense (T013, EF-005)" {
    cat > "$TEST_DIR/bad-npm.md" <<'EOF'
# Bad npm

Run `npm --prefix website run nonsense` to break things.
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/bad-npm.md" --category npm
    [ "$status" -eq 1 ]
    [[ "$output" == *"npm"* ]]
    [[ "$output" == *"nonsense"* ]]
}

@test "audit-docs: accepts npm --prefix website run generate (T014, EF-005)" {
    cat > "$TEST_DIR/good-npm.md" <<'EOF'
# Good npm

Run `npm --prefix website run generate` to regenerate counters.
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/good-npm.md" --category npm
    [ "$status" -eq 0 ]
}

# =============================================================================
# Regression: PR #199 (T015)
# =============================================================================

@test "audit-docs: regression PR #199 — ~/.claude-base/ triggers paths drift (T015, US-6)" {
    cat > "$TEST_DIR/pr199-drift.md" <<'EOF'
# PR #199 historical drift

```bash
git clone https://github.com/christopherlouet/claude-base.git ~/.claude-base
~/.claude-base/scripts/new-project.sh --simple /path/to/your-project
```
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/pr199-drift.md" --category paths
    [ "$status" -eq 1 ]
    [[ "$output" == *"paths"* ]]
    [[ "$output" == *".claude-base"* ]]
}

# =============================================================================
# Env-var hatch (T016, EF-011)
# =============================================================================

@test "audit-docs: AUDIT_DOCS_SKIP_PATHS=1 ignores path drifts but still catches verbs (T016, EF-011)" {
    cat > "$TEST_DIR/mixed-drift.md" <<'EOF'
# Mixed drift

Run `claude-base bogusverb` against `~/.claude-bogus/foo`.
EOF
    run env AUDIT_DOCS_SKIP_PATHS=1 "$AUDIT_DOCS" --target "$TEST_DIR/mixed-drift.md"
    [ "$status" -eq 1 ]
    [[ "$output" == *"verbs"* ]]
    [[ "$output" == *"bogusverb"* ]]
    # The path drift should NOT be reported (skipped via env var)
    [[ "$output" != *"claude-bogus"* ]]
}

# =============================================================================
# Category: cmdrefs — dead /domain:name command references
# =============================================================================

@test "audit-docs: rejects a removed /dev:dev-test command reference (cmdrefs)" {
    cat > "$TEST_DIR/dead-ref.md" <<'EOF'
# Dead ref

Run `/dev:dev-test` to scaffold tests.
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/dead-ref.md" --category cmdrefs
    [ "$status" -eq 1 ]
    [[ "$output" == *"cmdrefs"* ]]
    [[ "$output" == *"/dev:dev-test"* ]]
}

@test "audit-docs: accepts a live /work:work-pr command reference (cmdrefs)" {
    cat > "$TEST_DIR/live-ref.md" <<'EOF'
# Live ref

Use `/work:work-pr` then `/qa:qa-loop "score 90"`.
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/live-ref.md" --category cmdrefs
    [ "$status" -eq 0 ]
}

@test "audit-docs: detects a dead ref regardless of context — prose, table, backticks (cmdrefs)" {
    # Argument-ordering / embedding coverage: the same dead token must be caught
    # whether it sits in a sentence, a markdown table cell, or inline code.
    cat > "$TEST_DIR/dead-many.md" <<'EOF'
# Mixed contexts

Plain prose calls /qa:qa-coverage at the end.

| Step | Command |
|------|---------|
| 1 | `/growth:growth-funnel` |

Inline `/doc:doc-readme` reference.
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/dead-many.md" --category cmdrefs
    [ "$status" -eq 1 ]
    [[ "$output" == *"/qa:qa-coverage"* ]]
    [[ "$output" == *"/growth:growth-funnel"* ]]
    [[ "$output" == *"/doc:doc-readme"* ]]
}

@test "audit-docs: a subcommand-arg form /ops:ops-gitflow <action> is NOT flagged (cmdrefs)" {
    # /ops:ops-gitflow exists; "init"/"feature" are arguments, not part of the
    # command name. The space-separated form must resolve to the real command.
    cat > "$TEST_DIR/gitflow-ok.md" <<'EOF'
# Gitflow

Run `/ops:ops-gitflow init` then `/ops:ops-gitflow feature start "x"`.
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/gitflow-ok.md" --category cmdrefs
    [ "$status" -eq 0 ]
}

@test "audit-docs: a concatenated /ops:ops-gitflow-feature IS flagged (cmdrefs)" {
    cat > "$TEST_DIR/gitflow-bad.md" <<'EOF'
# Gitflow concatenated

Run `/ops:ops-gitflow-feature` to start.
EOF
    run "$AUDIT_DOCS" --target "$TEST_DIR/gitflow-bad.md" --category cmdrefs
    [ "$status" -eq 1 ]
    [[ "$output" == *"/ops:ops-gitflow-feature"* ]]
}

@test "audit-docs: AUDIT_DOCS_SKIP_CMDREFS=1 silences the cmdrefs category (cmdrefs)" {
    cat > "$TEST_DIR/dead-ref-skip.md" <<'EOF'
# Dead ref skipped

Run `/dev:dev-test` to scaffold tests.
EOF
    run env AUDIT_DOCS_SKIP_CMDREFS=1 "$AUDIT_DOCS" --target "$TEST_DIR/dead-ref-skip.md" --category cmdrefs
    [ "$status" -eq 0 ]
}

# =============================================================================
# Zero-FP gate (T017, EF-012) — CRITICAL
# =============================================================================

@test "audit-docs: real foundation repo exits 0 with no drift (T017, EF-012)" {
    [ -x "$AUDIT_DOCS" ]
    run "$AUDIT_DOCS"
    [ "$status" -eq 0 ]
}

@test "audit-docs: KNOWN_INIT_FLAGS covers every flag init actually parses" {
    # The allowlist is a hand-maintained copy of new-project.sh's parse_args, so
    # it drifts silently — and a gap here does not fail loudly, it falsely
    # reports a CORRECT doc as drift. That is how documenting `init --help`
    # broke the firewall. Derived from parse_args so the copy cannot rot again.
    #
    # [[:space:]] not \s: BSD grep on macOS does not know the shorthand.
    local parsed known flag missing=""
    parsed=$(sed -n '/^parse_args()/,/^}/p' "$BASE_DIR/scripts/new-project.sh" \
        | grep -oE '^[[:space:]]+(-[a-zA-Z]\|)?--?[a-z-]+(\|--?[a-z-]+)*\)' \
        | tr -d ' )' | tr '|' '\n' | sort -u)

    # An empty parse would make every assertion below vacuously true.
    [ -n "$parsed" ]
    printf '%s\n' "$parsed" | grep -qx -- '--type'

    known=$(sed -n '/^KNOWN_INIT_FLAGS=(/,/^)/p' "$AUDIT_DOCS" \
        | grep -oE '(^|[[:space:]])--?[a-zA-Z-]+' | tr -d ' ' | sort -u)
    [ -n "$known" ]

    for flag in $parsed; do
        printf '%s\n' "$known" | grep -qx -- "$flag" || missing="$missing $flag"
    done

    [ -z "$missing" ] || {
        printf 'init parses these flags but audit-docs would flag them as drift:%s\n' "$missing" >&2
        return 1
    }
}

# =============================================================================
# Scope coverage — the guard's own blind spot
# =============================================================================

# _fake_audit_root — a foundation-shaped tree with audit-docs.sh copied INSIDE
# it, so the script resolves BASE_DIR to the copy and a planted drift never
# touches the shared checkout.
#
# These two cases used to plant into the real repository — a file under
# `templates/` and an appended line in `README.md` — and clean up afterwards.
# The suite runs `bats --jobs`, so a sibling case auditing that same checkout can
# observe the plant while it exists. Demonstrated on 2026-08-29: with the plant
# window widened, "real foundation repo exits 0 with no drift" fails
# deterministically. It did not reproduce at the real window in 32 runs here, so
# whether this caused the macOS failure that day is unproven — but a test
# mutating shared state while the suite runs in parallel is a hazard on its own.
#
# What is exercised is unchanged: the DEFAULT scope, with no --target passed.
# Only the root moves.
_fake_audit_root() {
    local root="$TEST_DIR/fake-foundation"
    mkdir -p "$root/scripts/lib" "$root/templates" "$root/docs"
    cp "$BASE_DIR/scripts/audit-docs.sh" "$root/scripts/"
    cp -r "$BASE_DIR/scripts/lib/." "$root/scripts/lib/"
    printf '# Fake foundation\n' > "$root/README.md"
    printf '# Fake foundation\n' > "$root/CLAUDE.md"
    printf '%s' "$root"
}

@test "audit-docs: a drift planted in templates/ is caught by a default run" {
    # The default scope used to stop at docs/ and website/docs/*. That is how a
    # 2026-01-22 skill rename rotted the ten CLAUDE.md templates unnoticed for
    # six months: nothing scanned the surface every installed project inherits
    # its CLAUDE.md from. Asserting the behaviour — not the source text — is
    # what makes a future narrowing of the scope fail loudly.
    local root; root="$(_fake_audit_root)"
    cat > "$root/templates/scope-probe.md" <<'EOF'
# Scope probe

Run `./scripts/definitely-not-a-real-script.sh` to break things.
EOF

    run bash "$root/scripts/audit-docs.sh" --category scripts
    [ "$status" -ne 0 ]
    printf '%s\n' "$output" | grep -q 'definitely-not-a-real-script.sh'
}

@test "audit-docs: a drift planted in README.md is caught by a default run" {
    local root; root="$(_fake_audit_root)"
    printf '\nRun `./scripts/definitely-not-a-real-script.sh` to break things.\n' \
        >> "$root/README.md"

    run bash "$root/scripts/audit-docs.sh" --category scripts
    [ "$status" -ne 0 ]
    printf '%s\n' "$output" | grep -q 'definitely-not-a-real-script.sh'
}

@test "audit-docs: CONTROL - the fake root with nothing planted audits clean" {
    # Without this, the two cases above would also pass on a root that fails for
    # some unrelated reason — a non-zero exit is not evidence of the right cause.
    local root; root="$(_fake_audit_root)"
    printf '# A page with no script reference\n' > "$root/templates/plain.md"

    run bash "$root/scripts/audit-docs.sh" --category scripts
    [ "$status" -eq 0 ]
}
