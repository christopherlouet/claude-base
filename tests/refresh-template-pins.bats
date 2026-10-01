#!/usr/bin/env bats

# Tests for scripts/refresh-template-pins.sh — re-pins the workflow TEMPLATES a
# project receives (templates/github-workflows, .claude/templates/github-actions)
# to the latest release of each action's major line. Dependabot only reads
# /.github/workflows, so nothing else keeps these SHAs fresh in the foundation.
# Fully offline: a fake `gh` serves tag lists and tag->commit answers from files.

load 'test_helper'

SCRIPT="$BATS_TEST_DIRNAME/../scripts/refresh-template-pins.sh"
SHA_A=1111111111111111111111111111111111111111
SHA_B=2222222222222222222222222222222222222222
SHA_C=3333333333333333333333333333333333333333
SHA_D=4444444444444444444444444444444444444444

setup() {
    setup_test_dir
    ROOT="$TEST_DIR/root"
    mkdir -p "$ROOT/templates/github-workflows" "$ROOT/.claude/templates/github-actions" \
             "$TEST_DIR/fakebin" "$TEST_DIR/gh"
    # tags: one file per repo (owner_repo), one tag per line.
    # shas: one file per repo+tag (owner_repo@tag) holding the commit SHA.
    cat > "$TEST_DIR/fakebin/gh" <<EOF
#!/usr/bin/env bash
echo "gh \$*" >> "$TEST_DIR/gh.log"
[ "\$1" = api ] || exit 2
path="\$2"
repo=\$(printf '%s' "\$path" | cut -d/ -f2-3 | tr / _)
[ -f "$TEST_DIR/gh/fail-\$repo" ] && { echo "HTTP 502" >&2; exit 1; }
case "\$path" in
  */tags*)      cat "$TEST_DIR/gh/tags-\$repo" 2>/dev/null || exit 1 ;;
  */commits/*)  tag=\${path##*/commits/}; cat "$TEST_DIR/gh/sha-\$repo@\$tag" 2>/dev/null || exit 1 ;;
  *) exit 2 ;;
esac
EOF
    chmod +x "$TEST_DIR/fakebin/gh"
    export PATH="$TEST_DIR/fakebin:$PATH" PINS_ROOT="$ROOT"
}

teardown() { teardown_test_dir; }

_tags() { local r="$1"; shift; printf '%s\n' "$@" > "$TEST_DIR/gh/tags-$r"; }
_sha()  { printf '%s\n' "$3" > "$TEST_DIR/gh/sha-$1@$2"; }
_wf()   { printf '%s\n' "$@" > "$ROOT/templates/github-workflows/ci.yml"; }

@test "refresh-template-pins: a floating major tag becomes the latest release of that major" {
    _tags actions_checkout v6.0.0 v7.0.0 v7.0.1 v7.0.10 v8.0.0 v7
    _sha actions_checkout v7.0.10 "$SHA_A"
    _wf 'steps:' '      - uses: actions/checkout@v7'
    run "$SCRIPT"
    [ "$status" -eq 0 ]
    # v7.0.10 sorts above v7.0.1 (numeric, not lexical); v8 is another major line.
    [ "$(sed -n 2p "$ROOT/templates/github-workflows/ci.yml")" = "      - uses: actions/checkout@$SHA_A # v7.0.10" ]
}

@test "refresh-template-pins: an existing pin moves to the newest release of its major" {
    _tags amannn_action-semantic-pull-request v6.1.0 v6.1.1 v7.0.0
    _sha amannn_action-semantic-pull-request v6.1.1 "$SHA_B"
    _wf "        uses: amannn/action-semantic-pull-request@$SHA_C # v6.1.0"
    run "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$(cat "$ROOT/templates/github-workflows/ci.yml")" = "        uses: amannn/action-semantic-pull-request@$SHA_B # v6.1.1" ]
}

@test "refresh-template-pins: keeps a tag style without the v prefix" {
    _tags ludeeus_action-shellcheck 1.1.0 2.0.0 2.0.1
    _sha ludeeus_action-shellcheck 2.0.1 "$SHA_D"
    _wf "        uses: ludeeus/action-shellcheck@$SHA_C # 2.0.0"
    run "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$(cat "$ROOT/templates/github-workflows/ci.yml")" = "        uses: ludeeus/action-shellcheck@$SHA_D # 2.0.1" ]
}

@test "refresh-template-pins: covers .claude/templates/github-actions too" {
    _tags anthropics_claude-code-action v1.0.0 v1.2.0
    _sha anthropics_claude-code-action v1.2.0 "$SHA_A"
    printf '%s\n' '      - uses: anthropics/claude-code-action@v1' \
        > "$ROOT/.claude/templates/github-actions/claude-review.yml"
    run "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$(cat "$ROOT/.claude/templates/github-actions/claude-review.yml")" = "      - uses: anthropics/claude-code-action@$SHA_A # v1.2.0" ]
}

@test "refresh-template-pins: local and docker actions are left alone" {
    _wf '      - uses: ./.github/actions/setup' '      - uses: docker://alpine:3'
    run "$SCRIPT"
    [ "$status" -eq 0 ]
    [ "$(cat "$ROOT/templates/github-workflows/ci.yml")" = "$(printf '%s\n' '      - uses: ./.github/actions/setup' '      - uses: docker://alpine:3')" ]
    [ ! -f "$TEST_DIR/gh.log" ]
}

@test "refresh-template-pins: an unresolvable action keeps its line, the others still move, exit 1" {
    _tags actions_checkout v7.0.1
    _sha actions_checkout v7.0.1 "$SHA_A"
    touch "$TEST_DIR/gh/fail-actions_setup-node"
    _wf '      - uses: actions/checkout@v7' '      - uses: actions/setup-node@v7'
    run "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"actions/setup-node"* ]]
    [ "$(sed -n 1p "$ROOT/templates/github-workflows/ci.yml")" = "      - uses: actions/checkout@$SHA_A # v7.0.1" ]
    [ "$(sed -n 2p "$ROOT/templates/github-workflows/ci.yml")" = "      - uses: actions/setup-node@v7" ]
}

@test "refresh-template-pins: a major line with no release keeps its line and fails" {
    _tags actions_checkout v6.0.0 v8.0.0
    _wf '      - uses: actions/checkout@v7'
    run "$SCRIPT"
    [ "$status" -eq 1 ]
    [ "$(cat "$ROOT/templates/github-workflows/ci.yml")" = '      - uses: actions/checkout@v7' ]
}

@test "refresh-template-pins: a second run changes nothing (idempotent)" {
    _tags actions_checkout v7.0.1
    _sha actions_checkout v7.0.1 "$SHA_A"
    _wf '      - uses: actions/checkout@v7' '      - uses: actions/checkout@v7'
    run "$SCRIPT"
    [ "$status" -eq 0 ]
    cp "$ROOT/templates/github-workflows/ci.yml" "$TEST_DIR/first"
    run "$SCRIPT"
    [ "$status" -eq 0 ]
    cmp "$TEST_DIR/first" "$ROOT/templates/github-workflows/ci.yml"
    # The same action/major is resolved once per run, not once per line.
    [ "$(grep -c '/tags' "$TEST_DIR/gh.log")" -eq 2 ]
}

@test "refresh-template-pins: a bare SHA with no version comment is reported, not fatal" {
    _tags actions_checkout v7.0.1
    _sha actions_checkout v7.0.1 "$SHA_A"
    # A realistic hex SHA, and an all-digit one, which a version pattern
    # would otherwise read as a 40-digit major.
    _wf '      - uses: actions/setup-node@0a1b2c3d4e5f60718293a4b5c6d7e8f901234567' \
        "      - uses: actions/setup-go@$SHA_C" '      - uses: actions/checkout@v7'
    run "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"actions/setup-node"* ]]
    [[ "$output" == *"actions/setup-go"* ]]
    # Neither SHA was taken for a major: no tag lookup was made for them.
    if grep -qE 'setup-(node|go)' "$TEST_DIR/gh.log"; then echo "looked up a SHA as a major" >&2; return 1; fi
    # The run went on past them: the next line was still refreshed.
    [ "$(sed -n 1p "$ROOT/templates/github-workflows/ci.yml")" = '      - uses: actions/setup-node@0a1b2c3d4e5f60718293a4b5c6d7e8f901234567' ]
    [ "$(sed -n 2p "$ROOT/templates/github-workflows/ci.yml")" = "      - uses: actions/setup-go@$SHA_C" ]
    [ "$(sed -n 3p "$ROOT/templates/github-workflows/ci.yml")" = "      - uses: actions/checkout@$SHA_A # v7.0.1" ]
}
