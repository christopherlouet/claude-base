#!/usr/bin/env bats

# =============================================================================
# Tests for scripts/hooks/_policy-zsh-pipestatus.sh — the harness-neutral core
# of zsh-pipestatus-guard. has_pipestatus_expansion answers whether the OUTER
# shell would expand PIPESTATUS, which zsh silently expands to empty (zsh's
# array is the lower-case, 1-indexed `pipestatus`). Text zsh hands to bash
# untouched (single quotes, `\$`, a quoted-delimiter heredoc body), comments
# and the bare word must not count. Replayed under mawk and busybox awk by
# scripts/awk-portability.sh (it runs tests/policy-*.bats).
# =============================================================================

load 'test_helper'

POLICY="$BATS_TEST_DIRNAME/../scripts/hooks/_policy-zsh-pipestatus.sh"

# expands <command-string> — the pure core verdict (0 = zsh would expand it).
expands() {
    run bash -c '. "$1"; has_pipestatus_expansion "$2"' _ "$POLICY" "$1"
}

# --- Core: must FIRE ---------------------------------------------------------

@test "core: bare \${PIPESTATUS[0]} is an expansion" {
    expands 'false | true; echo ${PIPESTATUS[0]}'
    [ "$status" -eq 0 ]
}

@test "core: bare \$PIPESTATUS is an expansion" {
    expands 'cmd | tail -3; rc=$PIPESTATUS'
    [ "$status" -eq 0 ]
}

@test "core: \${#PIPESTATUS[@]} (length) is an expansion" {
    expands 'a | b; echo ${#PIPESTATUS[@]}'
    [ "$status" -eq 0 ]
}

@test "core: inside double quotes is an expansion" {
    expands 'a | b; echo "rc=${PIPESTATUS[0]}"'
    [ "$status" -eq 0 ]
}

@test "core: an unquoted-delimiter heredoc body is expanded by zsh" {
    expands $'cat <<EOF\nrc=${PIPESTATUS[0]}\nEOF'
    [ "$status" -eq 0 ]
}

@test "core: an expansion AFTER a quoted heredoc ends still fires" {
    expands $'cat > f.sh <<\'EOF\'\necho ${PIPESTATUS[0]}\nEOF\na | b; echo ${PIPESTATUS[0]}'
    [ "$status" -eq 0 ]
}

@test "core: an expansion after a closed single-quoted string fires" {
    expands "echo 'x' | cat; echo \${PIPESTATUS[0]}"
    [ "$status" -eq 0 ]
}

# --- Core: must NOT fire -----------------------------------------------------

@test "core: inside single quotes (bash -c) is not expanded by zsh" {
    expands "bash -c 'false | true; echo \${PIPESTATUS[0]}'"
    [ "$status" -eq 1 ]
}

@test "core: an escaped \\\$PIPESTATUS is not expanded" {
    expands 'bash -c "false | true; echo \${PIPESTATUS[0]}"'
    [ "$status" -eq 1 ]
}

@test "core: an unquoted escaped \\\${PIPESTATUS[0]} is not expanded" {
    expands 'printf "%s\n" \${PIPESTATUS[0]} > note.txt'
    [ "$status" -eq 1 ]
}

@test "core: the bare word (a search for it) is not an expansion" {
    expands 'grep -rn PIPESTATUS scripts/hooks'
    [ "$status" -eq 1 ]
}

@test "core: a quoted-delimiter heredoc body is not expanded ('EOF')" {
    expands $'cat > f.sh <<\'EOF\'\nrc=${PIPESTATUS[0]}\nEOF'
    [ "$status" -eq 1 ]
}

@test "core: a quoted-delimiter heredoc body is not expanded (\"EOF\")" {
    expands $'cat > f.sh <<"EOF"\nrc=${PIPESTATUS[0]}\nEOF'
    [ "$status" -eq 1 ]
}

@test "core: a quoted-delimiter heredoc body is not expanded (<<-'EOF')" {
    expands $'cat > f.sh <<-\'EOF\'\n\trc=${PIPESTATUS[0]}\n\tEOF'
    [ "$status" -eq 1 ]
}

@test "core: a longer identifier (\$PIPESTATUS_X) is not PIPESTATUS" {
    expands 'echo $PIPESTATUS_SAVED'
    [ "$status" -eq 1 ]
}

@test "core: zsh's own \${pipestatus[1]} is fine" {
    expands 'a | b; echo ${pipestatus[1]}'
    [ "$status" -eq 1 ]
}

@test "core: a comment mentioning it is not an expansion" {
    expands 'a | b  # ${PIPESTATUS[0]} would be empty here'
    [ "$status" -eq 1 ]
}

# --- Core: shell classification ---------------------------------------------

@test "core: shell_is_zsh recognises zsh paths and rejects bash" {
    run bash -c '. "$1"; shell_is_zsh /usr/bin/zsh && shell_is_zsh /bin/zsh-5.9 && ! shell_is_zsh /bin/bash && ! shell_is_zsh ""' _ "$POLICY"
    [ "$status" -eq 0 ]
}

# --- Self-application: the foundation's own bash hooks read PIPESTATUS -------
# They are bash scripts, so writing or running them must pass; the same text
# pasted for zsh to evaluate must not. Real files, not fixtures.

@test "self-application: writing or running the real PIPESTATUS hooks passes" {
    local f files=0
    for f in "$BASE_DIR"/scripts/hooks/*.sh; do
        grep -q 'PIPESTATUS' "$f" || continue
        files=$((files + 1))
        expands "$(printf "cat > %s <<'EOF'\n%s\nEOF" "$(basename "$f")" "$(cat "$f")")"
        [ "$status" -eq 1 ] || { echo "quoted-heredoc write flagged: $f" >&2; return 1; }
        expands "bash $f"
        [ "$status" -eq 1 ] || { echo "running flagged: $f" >&2; return 1; }
    done
    [ "$files" -ge 2 ]
}

@test "self-application CONTROL: the same real lines evaluated by zsh are flagged" {
    local line
    line=$(grep -h 'PIPESTATUS' "$BASE_DIR"/scripts/hooks/pre-push-ci.sh | grep -v '^[[:space:]]*#' | head -1)
    [ -n "$line" ]
    expands "$line"
    [ "$status" -eq 0 ]
}

# --- Premise control: the bug the guard exists for is real here --------------

@test "premise: zsh expands PIPESTATUS to empty while pipestatus holds the codes" {
    command -v zsh >/dev/null 2>&1 || skip "zsh not installed"
    run zsh -c 'false | true; print -r -- "[${PIPESTATUS[*]}][${pipestatus[*]}]"'
    [ "$output" = "[][1 0]" ]
}
