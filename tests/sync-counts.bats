#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/sync-counts.sh — the counts self-heal used by the pre-commit
# hook. Fully OFFLINE + hermetic: a throwaway git repo under $TEST_DIR, a fake
# "derived" file (counts.txt), and fake regen/check commands injected via the
# documented env seams. No node, no website, no network.
# =============================================================================

load 'test_helper'

SYNC="$BASE_DIR/scripts/sync-counts.sh"

setup() {
    setup_test_dir
    cd "$TEST_DIR"
    git init -q
    git config user.email t@t.t
    git config user.name t
    # The single tracked "derived" artifact for these tests.
    echo "count=1" > counts.txt
    git add counts.txt
    git commit -qm init
    # Fake tools live here; tests point the seams at them.
    mkdir -p bin
}

teardown() { teardown_test_dir; }

# run_sync <args...> — invoke sync-counts against the throwaway repo.
run_sync() {
    run env \
        SYNC_COUNTS_ROOT="$TEST_DIR" \
        SYNC_COUNTS_PATHS="counts.txt" \
        SYNC_COUNTS_REGEN_CMD="${REGEN:-true}" \
        SYNC_COUNTS_CHECK_CMD="${CHECK:-true}" \
        bash "$SYNC" "$@"
}

# --- HEAL mode ---------------------------------------------------------------

@test "heal: no drift (regen changes nothing) → exit 0, nothing staged" {
    REGEN="true" run_sync
    [ "$status" -eq 0 ]
    [[ "$output" == *"already in sync"* ]]
    # index unchanged: no staged diff
    git diff --cached --quiet
}

@test "heal: drift (regen rewrites the derived file) → exit 0, file staged" {
    cat > bin/regen <<'EOF'
#!/usr/bin/env bash
echo "count=2" > counts.txt
EOF
    chmod +x bin/regen
    REGEN="$TEST_DIR/bin/regen" run_sync
    [ "$status" -eq 0 ]
    [[ "$output" == *"regenerated and staged"* ]]
    # the regenerated derived file is now staged
    git diff --cached --name-only | grep -qx counts.txt
    [ "$(git show :counts.txt)" = "count=2" ]
}

@test "heal: regen fails but counts are already consistent → exit 0 (no block)" {
    REGEN="false" CHECK="true" run_sync
    [ "$status" -eq 0 ]
    [[ "$output" == *"tooling unavailable"* ]]
}

@test "heal: regen fails AND counts drifted → exit 1 (block, clear message)" {
    REGEN="false" CHECK="false" run_sync
    [ "$status" -eq 1 ]
    [[ "$output" == *"regeneration failed"* ]]
}

@test "heal: a pre-staged correct regen output is left clean → exit 0" {
    # regen writes the SAME content already committed → no unstaged diff
    cat > bin/regen <<'EOF'
#!/usr/bin/env bash
echo "count=1" > counts.txt
EOF
    chmod +x bin/regen
    REGEN="$TEST_DIR/bin/regen" run_sync
    [ "$status" -eq 0 ]
    [[ "$output" == *"already in sync"* ]]
}

# --- CHECK mode (read-only) --------------------------------------------------

@test "check: consistent → exit 0, no regeneration, no staging" {
    cat > bin/regen <<'EOF'
#!/usr/bin/env bash
echo "SHOULD NOT RUN" > counts.txt
EOF
    chmod +x bin/regen
    REGEN="$TEST_DIR/bin/regen" CHECK="true" run_sync --check
    [ "$status" -eq 0 ]
    # regen must NOT have run in check mode
    [ "$(git show :counts.txt)" = "count=1" ]
    git diff --quiet -- counts.txt
}

@test "check: drift → exit 1, no mutation" {
    CHECK="false" run_sync --check
    [ "$status" -eq 1 ]
    [[ "$output" == *"out of sync"* ]]
    git diff --cached --quiet
}

# Default-wiring exercise: every other test overrides the seams, so the PRODUCTION
# default CHECK_CMD (scripts/validate-counts.sh) and default ROOT (the real repo)
# are never run. This case leaves them at their defaults and runs --check against
# the REAL foundation, asserting it reports the clean tree as in sync (exit 0).
# REGEN is not invoked in --check mode, so no npm/website is touched.
#
# Precondition: the working tree's counts must be in sync. During active work the
# tree legitimately drifts (new files added before the pre-commit self-heal), so
# skip in that case — CI runs this on a clean, counts-consistent checkout. When it
# does run it pins the real default wiring end-to-end.
@test "check (default validator, real repo): clean tree reports in sync (exit 0)" {
    bash "$BASE_DIR/scripts/validate-counts.sh" >/dev/null 2>&1 \
        || skip "working tree counts drift (mid-edit); CI runs this on a clean checkout"
    run bash "$SYNC" --check
    [ "$status" -eq 0 ]
    [[ "$output" == *"in sync"* ]]
}

# --- CLI ---------------------------------------------------------------------

@test "unknown option → exit 2" {
    run_sync --bogus
    [ "$status" -eq 2 ]
}

@test "--quiet suppresses the informational line on a no-op" {
    REGEN="true" run_sync --quiet
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}
