#!/usr/bin/env bats

# =============================================================================
# Every husky hook the foundation ships chains to the user's GLOBAL hook of the
# same name.
#
# A repository wired to .husky has a LOCAL core.hooksPath, and git reads one
# hooks directory only: the local value shadows a global one. A personal guard
# installed with `git config --global core.hooksPath <dir>` therefore never ran
# in a husky repository. Each shipped hook now runs the global hook first and
# stops when it fails.
#
# The global config is isolated per test (GIT_CONFIG_GLOBAL), so the result
# never depends on the machine running the suite.
# =============================================================================

load 'test_helper'

setup() {
    setup_test_dir
    export GIT_CONFIG_GLOBAL="$TEST_DIR/gitconfig-global"
    : > "$GIT_CONFIG_GLOBAL"
    GLOBAL="$TEST_DIR/global-hooks"
    LOG="$TEST_DIR/global.log"
    mkdir -p "$GLOBAL"
    for name in pre-commit commit-msg pre-push; do
        cat > "$GLOBAL/$name" <<EOF
#!/bin/sh
echo "$name args=\$#" >> "$LOG"
if [ "$name" = pre-push ]; then echo "$name stdin=\$(wc -l | tr -d ' ')" >> "$LOG"; fi
[ "\${GLOBAL_FAIL:-}" = "$name" ] && exit 1
exit 0
EOF
        chmod +x "$GLOBAL/$name"
    done

    REPO="$TEST_DIR/repo"
    git init -q "$REPO"
    git -C "$REPO" config user.email t@t
    git -C "$REPO" config user.name t
    mkdir -p "$REPO/.husky"
    git -C "$REPO" config core.hooksPath .husky
}

teardown() {
    teardown_test_dir
}

use_global() { git config --global core.hooksPath "$GLOBAL"; }

install_hook() { # <source under BASE_DIR> <hook name>
    cp "$BASE_DIR/$1" "$REPO/.husky/$2"
    chmod +x "$REPO/.husky/$2"
}

stage_file() { echo "$1" > "$REPO/f"; git -C "$REPO" add f; }

# =============================================================================
# Every shipped hook carries the chain for its OWN name (real files, no fixture)
# =============================================================================

@test "self-application: every shipped husky hook chains to the global hook of its own name" {
    local f name n=0
    for f in "$BASE_DIR"/templates/husky/* "$BASE_DIR"/.husky/*; do
        [ -f "$f" ] || continue
        name=${f##*/}
        grep -qF "git config --global --path core.hooksPath" "$f" \
            || { echo "no global chain in $f"; return 1; }
        grep -qF "\"\$_global_hooks/$name\" \"\$@\"" "$f" \
            || { echo "$f does not call the global $name"; return 1; }
        n=$((n + 1))
    done
    # Not trivially empty: 2 templates + the foundation's own 3 hooks.
    [ "$n" -ge 5 ]
}

# =============================================================================
# Downstream template: pre-commit
# =============================================================================

@test "template pre-commit: a commit runs the global pre-commit" {
    install_hook templates/husky/pre-commit pre-commit
    use_global
    stage_file one
    run git -C "$REPO" commit -qm one
    [ "$status" -eq 0 ]
    grep -q '^pre-commit ' "$LOG"
}

@test "template pre-commit: a failing global pre-commit refuses the commit" {
    install_hook templates/husky/pre-commit pre-commit
    use_global
    stage_file one
    GLOBAL_FAIL=pre-commit run git -C "$REPO" commit -qm one
    [ "$status" -ne 0 ]
    run git -C "$REPO" rev-parse --verify -q HEAD
    [ "$status" -ne 0 ]
}

@test "template pre-commit: no global hooks path is a no-op" {
    install_hook templates/husky/pre-commit pre-commit
    stage_file one
    run git -C "$REPO" commit -qm one
    [ "$status" -eq 0 ]
    [ ! -e "$LOG" ]
}

@test "template pre-commit: a global path pointing at this .husky does not recurse" {
    install_hook templates/husky/pre-commit pre-commit
    git config --global core.hooksPath "$REPO/.husky"
    stage_file one
    run timeout 20 git -C "$REPO" commit -qm one
    [ "$status" -eq 0 ]
}

# =============================================================================
# Downstream template: commit-msg
# =============================================================================

@test "template commit-msg: the global commit-msg gets the message file" {
    install_hook templates/husky/commit-msg commit-msg
    use_global
    stage_file one
    run git -C "$REPO" commit -qm one
    [ "$status" -eq 0 ]
    grep -q '^commit-msg args=1$' "$LOG"
}

@test "template commit-msg: a failing global commit-msg refuses the commit" {
    install_hook templates/husky/commit-msg commit-msg
    use_global
    stage_file one
    GLOBAL_FAIL=commit-msg run git -C "$REPO" commit -qm one
    [ "$status" -ne 0 ]
    run git -C "$REPO" rev-parse --verify -q HEAD
    [ "$status" -ne 0 ]
}

# =============================================================================
# The foundation's own pre-push: the global hook gets the refs on stdin
# =============================================================================

@test "foundation pre-push: the global pre-push gets the pushed refs and can refuse the push" {
    install_hook .husky/pre-push pre-push
    use_global
    git init -q --bare "$TEST_DIR/remote.git"
    git -C "$REPO" remote add origin "$TEST_DIR/remote.git"
    stage_file one
    git -C "$REPO" commit -qm one

    GLOBAL_FAIL=pre-push SKIP_PREFLIGHT=1 run git -C "$REPO" push -q origin HEAD:main
    [ "$status" -ne 0 ]
    run git -C "$TEST_DIR/remote.git" rev-parse --verify -q main
    [ "$status" -ne 0 ]
    grep -q '^pre-push args=2$' "$LOG"
    grep -q '^pre-push stdin=1$' "$LOG"

    SKIP_PREFLIGHT=1 run git -C "$REPO" push -q origin HEAD:main
    [ "$status" -eq 0 ]
    git -C "$TEST_DIR/remote.git" rev-parse --verify -q main
}
