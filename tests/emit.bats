#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/lib/emit.sh — the manifest emitter, focused on the
# outgoing-symlink guard and its batched resolution cache.
#
# Why this file exists: emit.sh had no direct test of its own (it was covered
# only indirectly, through export-minimal and the install paths). The guard
# resolves every manifest entry, which used to mean one realpath fork per
# entry — the largest remaining cost of an install. Resolutions are now
# computed in ONE realpath call and looked up from a cache.
#
# A cache in front of a security check is exactly the kind of optimisation that
# can silently disable it, so the deny cases below run WITH the cache populated
# (several entries, so the batch really kicks in) and again with batching
# unavailable, asserting the verdict is identical either way.
# =============================================================================

load 'test_helper'

EMIT_LIB="$BASE_DIR/scripts/lib/emit.sh"

setup() {
    setup_test_dir
    SRC="$TEST_DIR/src"
    DST="$TEST_DIR/dst"
    mkdir -p "$SRC/dir" "$DST"
    printf 'a\n' > "$SRC/a.txt"
    printf 'b\n' > "$SRC/b.txt"
    printf 'c\n' > "$SRC/dir/c.txt"
}

teardown() {
    teardown_test_dir
}

# run_emit <manifest-file> [extra PATH-stripping]
run_emit() {
    run bash -c '. "$1"; emit_manifest "$2" "$3" "$4"' _ "$EMIT_LIB" "$1" "$SRC" "$DST"
}

# Same, with realpath made unreachable so the batch bails out and every entry
# falls through to the per-entry resolve.
run_emit_nobatch() {
    run bash -c '
        realpath() { return 127; }
        command() { if [ "$1" = "-v" ] && [ "$2" = "realpath" ]; then return 1; fi; builtin command "$@"; }
        . "$1"; emit_manifest "$2" "$3" "$4"
    ' _ "$EMIT_LIB" "$1" "$SRC" "$DST"
}

@test "emit: lib exists and defines emit_manifest" {
    [ -f "$EMIT_LIB" ]
    run bash -c "set -euo pipefail; . '$EMIT_LIB'; declare -F emit_manifest >/dev/null"
    [ "$status" -eq 0 ]
}

@test "emit: copies a plain multi-entry manifest" {
    printf 'a.txt\nb.txt\ndir/\n' > "$TEST_DIR/m.txt"
    run_emit "$TEST_DIR/m.txt"
    [ "$status" -eq 0 ]
    [ -f "$DST/a.txt" ]
    [ -f "$DST/b.txt" ]
    [ -f "$DST/dir/c.txt" ]
}

@test "emit: rejects an outgoing symlink WITH the batch cache populated" {
    # Several real entries first, so the batch path is the one in use — a cache
    # that answered for the wrong entry would let this through.
    ln -s /etc/passwd "$SRC/escape.txt"
    printf 'a.txt\nb.txt\ndir/\nescape.txt\n' > "$TEST_DIR/m.txt"
    run_emit "$TEST_DIR/m.txt"
    [ "$status" -ne 0 ]
    [[ "$output" == *"symlink"* ]]
}

@test "emit: rejects the same symlink with batching unavailable (fallback parity)" {
    ln -s /etc/passwd "$SRC/escape.txt"
    printf 'a.txt\nb.txt\ndir/\nescape.txt\n' > "$TEST_DIR/m.txt"
    run_emit_nobatch "$TEST_DIR/m.txt"
    [ "$status" -ne 0 ]
    [[ "$output" == *"symlink"* ]]
}

@test "emit: a symlink that stays inside the root is allowed" {
    ln -s "$SRC/a.txt" "$SRC/inside.txt"
    printf 'a.txt\ninside.txt\n' > "$TEST_DIR/m.txt"
    run_emit "$TEST_DIR/m.txt"
    [ "$status" -eq 0 ]
    [ -e "$DST/inside.txt" ]
}

@test "emit: aborts at the SAME entry as before the cache (error ordering)" {
    # The pre-pass must not turn a mid-manifest failure into an up-front one:
    # entries before the bad one are still emitted, the ones after are not.
    ln -s /etc/passwd "$SRC/escape.txt"
    printf 'a.txt\nescape.txt\nb.txt\n' > "$TEST_DIR/m.txt"
    run_emit "$TEST_DIR/m.txt"
    [ "$status" -ne 0 ]
    [ -f "$DST/a.txt" ]      # before the failure — copied
    [ ! -e "$DST/b.txt" ]    # after  the failure — not reached
}

@test "emit: a missing source is still reported, not silently skipped" {
    # The pre-pass skips non-existent paths when collecting resolve candidates;
    # the main loop must still fail on them.
    printf 'a.txt\nnope.txt\n' > "$TEST_DIR/m.txt"
    run_emit "$TEST_DIR/m.txt"
    [ "$status" -ne 0 ]
    [[ "$output" == *"nope.txt"* ]]
}

@test "emit: comments and blank lines are ignored by both passes" {
    printf '# a comment\n\na.txt\n\n#another\nb.txt\n' > "$TEST_DIR/m.txt"
    run_emit "$TEST_DIR/m.txt"
    [ "$status" -eq 0 ]
    [ -f "$DST/a.txt" ]
    [ -f "$DST/b.txt" ]
}

@test "emit: reads a manifest from stdin (buffered once)" {
    # The pre-pass needs a second look at the lines; stdin can only be read
    # once, so the buffer is what makes this work.
    run bash -c '. "$1"; printf "a.txt\nb.txt\n" | emit_manifest - "$2" "$3"' \
        _ "$EMIT_LIB" "$SRC" "$DST"
    [ "$status" -eq 0 ]
    [ -f "$DST/a.txt" ]
    [ -f "$DST/b.txt" ]
}

@test "emit: a src_root reached through a SYMLINK is not rejected wholesale" {
    # The macOS default: /tmp is a link to /private/tmp, so src_root resolves to
    # a different string than the caller passed. Comparing a resolved source
    # against a RAW root then refused every entry — an install from such a path
    # failed completely with "source outside the repo". Predates the batch
    # cache; these tests were simply the first to exercise a symlinked root.
    mkdir -p "$TEST_DIR/real/src" "$TEST_DIR/real/dst"
    printf 'a\n' > "$TEST_DIR/real/src/a.txt"
    ln -s "$TEST_DIR/real" "$TEST_DIR/link"
    printf 'a.txt\n' > "$TEST_DIR/m.txt"

    run bash -c '. "$1"; emit_manifest "$2" "$3" "$4"' _ \
        "$EMIT_LIB" "$TEST_DIR/m.txt" "$TEST_DIR/link/src" "$TEST_DIR/link/dst"
    [ "$status" -eq 0 ]
    [ -f "$TEST_DIR/real/dst/a.txt" ]
}

@test "emit: an outgoing symlink is still refused when the root is symlinked" {
    # The bypass check for the fix above: relaxing the comparison must not stop
    # refusing a source that genuinely resolves outside the (resolved) root.
    #
    # The escape target is a real file created HERE, outside the root, rather
    # than a system path. Two earlier attempts show why: /etc/passwd trips our
    # own command validator when written in a shell command (it reads the PATH
    # as the passwd COMMAND), and /etc/hostname — chosen to dodge that — does
    # not exist on macOS, so the link dangled and emit failed with "path not
    # found" instead of the symlink refusal, failing this test on CI's macOS
    # column for a reason that had nothing to do with the behaviour under test.
    # A self-contained target depends on no platform at all.
    mkdir -p "$TEST_DIR/real/src" "$TEST_DIR/real/dst" "$TEST_DIR/outside"
    printf 'a\n' > "$TEST_DIR/real/src/a.txt"
    printf 'secret\n' > "$TEST_DIR/outside/target.txt"
    ln -s "$TEST_DIR/outside/target.txt" "$TEST_DIR/real/src/escape.txt"
    ln -s "$TEST_DIR/real" "$TEST_DIR/link"
    printf 'a.txt\nescape.txt\n' > "$TEST_DIR/m.txt"

    run bash -c '. "$1"; emit_manifest "$2" "$3" "$4"' _ \
        "$EMIT_LIB" "$TEST_DIR/m.txt" "$TEST_DIR/link/src" "$TEST_DIR/link/dst"
    [ "$status" -ne 0 ]
    [[ "$output" == *"symlink"* ]]
}
