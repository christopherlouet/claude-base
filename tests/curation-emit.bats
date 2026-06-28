#!/usr/bin/env bats

# Tests for emit_issue (scripts/lib/curation-emit.sh) — the idempotent digest
# emission. With a dedupe-key it must UPDATE the one rolling issue (marker in the
# body) instead of opening a duplicate every run (the digest-dup bug). Without a
# key it stays legacy create-only. Fully offline: a fake `gh` logs calls and
# returns a configurable existing-issue number.

load 'test_helper'

EMIT="$BATS_TEST_DIRNAME/../scripts/lib/curation-emit.sh"

setup() {
    setup_test_dir
    mkdir -p "$TEST_DIR/fakebin"
    export CURATION_GH_REPO="owner/repo"   # skip git-remote resolution
    cat > "$TEST_DIR/fakebin/gh" <<EOF
#!/usr/bin/env bash
echo "gh \$*" >> "$TEST_DIR/gh.log"
prev=""
for a in "\$@"; do
  [ "\$prev" = "--body-file" ] && cat "\$a" >> "$TEST_DIR/body.cap" 2>/dev/null
  prev="\$a"
done
case "\$*" in
  *"issue list"*) printf '%s' "\${FAKE_EXISTING:-}" ;;
esac
exit 0
EOF
    chmod +x "$TEST_DIR/fakebin/gh"
    printf 'digest body\n' > "$TEST_DIR/body.md"
}
teardown() { teardown_test_dir; }

@test "emit_issue updates the existing rolling issue (no duplicate create)" {
    source "$EMIT"
    FAKE_EXISTING=42 PATH="$TEST_DIR/fakebin:$PATH" emit_issue "Curation digest — 2026-06-28" "$TEST_DIR/body.md" "watch-digest"
    grep -q "issue edit 42" "$TEST_DIR/gh.log"
    ! grep -q "issue create" "$TEST_DIR/gh.log"
}

@test "emit_issue creates when no rolling issue exists yet" {
    source "$EMIT"
    FAKE_EXISTING="" PATH="$TEST_DIR/fakebin:$PATH" emit_issue "Curation digest — 2026-06-28" "$TEST_DIR/body.md" "watch-digest"
    grep -q "issue create" "$TEST_DIR/gh.log"
    ! grep -q "issue edit" "$TEST_DIR/gh.log"
}

@test "emit_issue embeds the dedupe marker in the emitted body" {
    source "$EMIT"
    FAKE_EXISTING="" PATH="$TEST_DIR/fakebin:$PATH" emit_issue "t" "$TEST_DIR/body.md" "watch-digest"
    grep -q "curation-issue:watch-digest" "$TEST_DIR/body.cap"
}

@test "emit_issue without a key is create-only (legacy, no list lookup)" {
    source "$EMIT"
    PATH="$TEST_DIR/fakebin:$PATH" emit_issue "t" "$TEST_DIR/body.md"
    grep -q "issue create" "$TEST_DIR/gh.log"
    ! grep -q "issue list" "$TEST_DIR/gh.log"
}
