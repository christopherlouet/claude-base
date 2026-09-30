#!/usr/bin/env bats

# =============================================================================
# A bare `! cmd` never fails a bats test unless it is the test's last line
# =============================================================================
# bats runs each test under `set -e`, and bash exempts a negated pipeline from
# errexit: `! grep -q x file` with x present returns 1 and the test goes on.
# 63 such lines had turned their assertions into no-ops (found 2026-09-28).
# `! cmd || false` fails as intended: `false` is not negated. `run ! cmd`
# (bats >= 1.5) works too.

_bare_negations() {
    grep -nE '^[[:space:]]*! ' "$@" | grep -vE '\|\|[[:space:]]*(false|return 1|exit 1)[[:space:]]*$'
}

@test "no test file carries a bare negation (set -e ignores it)" {
    run _bare_negations "$BATS_TEST_DIRNAME"/*.bats
    [ -z "$output" ] || { echo "bare negations, append '|| false':" >&2; echo "$output" >&2; return 1; }
}

@test "the negation guard is not vacuous — it flags the bare shape only" {
    local f="$BATS_TEST_TMPDIR/planted.bats"
    printf '%s\n' '@test "x" {' '    ! grep -q a b' '    ! grep -q c d || false' \
        '    ! grep -q e f || return 1' '    run ! grep -q g h' '}' > "$f"
    run _bare_negations "$f"
    [ "$output" = "2:    ! grep -q a b" ]
}
