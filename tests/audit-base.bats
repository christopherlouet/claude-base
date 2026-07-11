#!/usr/bin/env bats

# =============================================================================
# Tests for audit-base.sh — specifically its drift issue-counting.
# =============================================================================
# audit-base.sh delegates doc-drift detection to audit-docs.sh and counts each
# reported drift line as one issue. The count list must include EVERY category
# audit-docs.sh can emit — including [cmdrefs] (dead /domain:name references) —
# or a cmdrefs-only drift exits 0 (false green).
#
# The real audit-base.sh audits the whole foundation, so to isolate the counting
# logic we run a COPY of the real script against a minimal fixture root with the
# delegated scripts (audit-docs.sh / validate-counts.sh) stubbed.
# =============================================================================

load 'test_helper'

REAL_AUDIT="$BASE_DIR/scripts/audit-base.sh"
REAL_COMMON="$BASE_DIR/scripts/lib/common.sh"

setup() {
    skip_if_no_jq
    setup_test_dir
    # Fixture foundation root: $TEST_DIR, with a scripts/ dir holding the REAL
    # audit-base.sh + common.sh so our edits are exercised, plus stubbed
    # delegated scripts.
    mkdir -p "$TEST_DIR/scripts"
    cp "$REAL_AUDIT" "$TEST_DIR/scripts/audit-base.sh"
    # common.sh sources sibling lib/*.sh helpers, so copy the whole lib dir.
    cp -r "$BASE_DIR/scripts/lib" "$TEST_DIR/scripts/lib"
    chmod +x "$TEST_DIR/scripts/audit-base.sh"
    # validate-counts is not under test here: stub it clean.
    printf '#!/usr/bin/env bash\nexit 0\n' > "$TEST_DIR/scripts/validate-counts.sh"
    chmod +x "$TEST_DIR/scripts/validate-counts.sh"
}

teardown() {
    teardown_test_dir
}

# Write a fake audit-docs.sh that emits the given drift line(s) and exits 1.
# With no args, emits nothing and exits 0 (clean).
fake_audit_docs() {
    {
        echo '#!/usr/bin/env bash'
        if [ "$#" -gt 0 ]; then
            echo 'echo "[X] audit-docs: drift(s) detected:"'
            local line
            for line in "$@"; do
                printf 'echo "  %s"\n' "$line"
            done
            echo 'exit 1'
        else
            echo 'exit 0'
        fi
    } > "$TEST_DIR/scripts/audit-docs.sh"
    chmod +x "$TEST_DIR/scripts/audit-docs.sh"
}

# BUG 9: a cmdrefs-only drift must be counted (exit nonzero), not a false green.
@test "audit-base: a cmdrefs-only doc drift makes the audit fail (exit nonzero)" {
    fake_audit_docs "docs/foo.md:42: [cmdrefs] dead reference /work:ghost"
    run bash "$TEST_DIR/scripts/audit-base.sh"
    [ "$status" -ne 0 ]
    [[ "$output" == *"[cmdrefs]"* ]]
    [[ "$output" == *"issue(s) detected"* ]]
}

# Control: with no drift emitted, the same harness exits 0 — proving the test
# above is not trivially always-nonzero.
@test "audit-base: no doc drift on the clean fixture exits 0" {
    fake_audit_docs
    run bash "$TEST_DIR/scripts/audit-base.sh"
    [ "$status" -eq 0 ]
    [[ "$output" == *"No issue detected"* ]]
}
