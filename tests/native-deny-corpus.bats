#!/usr/bin/env bats

# =============================================================================
# Corpus instrument for the NATIVE permissions.deny layer.
#
# WHY IT EXISTS. #540 removed three deny rules that could never fire, and
# stopped there: replacing `dd if=` with `dd` would have WIDENED the layer, and
# `validator-corpus.sh` measures the hook, not the native list. There was no
# instrument for this layer, so the decision could not be taken on evidence and
# was recorded as deferred. This is that instrument.
#
# WHAT IT MEASURES, AND WHAT IT CANNOT. The native matcher belongs to the
# platform; a script cannot invoke it. This tool runs a MODEL of it, and the
# model is only worth its arms. Six properties were measured as live tool calls
# on 2026-09-02/04, each one an observed refusal or an observed execution:
#
#   prefix + space matches           `chmod 777 <dir>`            refused
#   the bare literal matches         `git checkout .`             refused
#   a mid-token continuation does not `git checkout ./<path>`     ran
#   `rm -rf /` does not cover a home `rm -rf /home/<probe>`       ran
#   an argument position does not    `echo chmod 777 <dir>`       ran
#   `&&` and `;` split the command   `true; chmod 777 <dir>`      refused
#
# DERIVED, NOT MEASURED: that `|`, `||` and a newline split the same way. The
# model treats them as separators, which makes it report MORE refusals than it
# can prove — the conservative direction for a tool whose job is to price a
# widening.
#
# THE ZERO THAT MEANS NOTHING. A delta of "0 new refusals" is only evidence if
# the corpus contains commands the candidate rule could have caught. Measured
# on 2026-09-04: the corpus holds 0 commands whose command word is `dd`, `mkfs`,
# `rm` or `chown`. For those families it is BLIND, and the tool must say so
# rather than return a zero that reads as a green light. That is the property
# these tests exist to keep.
# =============================================================================

load 'test_helper'

TOOL="$BATS_TEST_DIRNAME/../scripts/native-deny-corpus.sh"
INVENTORY="$BATS_TEST_DIRNAME/../scripts/guardrail-inventory.sh"

setup() {
    setup_test_dir
    mkdir -p "$TEST_DIR/.claude"
    cat > "$TEST_DIR/.claude/settings.json" <<'JSON'
{
  "permissions": {
    "deny": [
      "Bash(chmod 777:*)",
      "Bash(git checkout .:*)",
      "Bash(rm -rf /:*)",
      "Bash(sudo:*)",
      "Bash(eval)"
    ]
  }
}
JSON
}

teardown() { teardown_test_dir; }

# Feed the matcher a command directly: "source<TAB>command" on stdin.
#
# The command reaches the tool through a FILE, never through a pipe into `run`:
# a `run` at the end of a pipeline executes in a SUBSHELL, so the $output it
# captures never reaches the test body. Every case in this file was written
# that way first — the refusals came back empty and the absences passed for
# free, which is exactly the failure this file exists to keep out.
probe() {
    printf 'probe\t%s\n' "$1" > "$TEST_DIR/probe.tsv"
    run bash "$TOOL" --root "$TEST_DIR" --stdin < "$TEST_DIR/probe.tsv"
}

# `run` merges stderr into $output, so "not empty" is satisfied by a warning or
# a traceback that never modelled a refusal at all. A refusal is a TSV row whose
# first field is the rule.
refused() { [[ "$output" == Bash\(* ]]; }

# An absence of refusal proves nothing on its own: with no tool on disk, every
# such case passed. So `allowed` first shows the matcher answering on the same
# path, then asserts the case. Measured: without this, four tests here were
# green against a script that did not exist.
allowed() {
    local actual="$output"
    probe 'chmod 777 /tmp/probe-liveness'
    [ -n "$output" ] || { echo "matcher is not alive; the absence below proves nothing"; return 1; }
    [ -z "$actual" ]
}

# --- It reports, and never gates --------------------------------------------

@test "native-deny-corpus: it exits 0 on the real foundation" {
    run bash "$TOOL" --summary
    [ "$status" -eq 0 ]
}

@test "native-deny-corpus: a root with no settings file is empty, not an error" {
    printf 'probe\tchmod 777 /tmp/x\n' > "$TEST_DIR/probe.tsv"
    run bash "$TOOL" --root "$TEST_DIR" --stdin < "$TEST_DIR/probe.tsv"
    [ -n "$output" ]                      # the same input IS refused with a list…
    rm -f "$TEST_DIR/.claude/settings.json"
    run bash "$TOOL" --root "$TEST_DIR" --stdin < "$TEST_DIR/probe.tsv"
    [ "$status" -eq 0 ]
    [ -z "$output" ]                      # …so the empty result is the missing file
}

# --- The model, one case per measured arm -----------------------------------

@test "model: a prefix followed by a space matches" {
    probe 'chmod 777 /tmp/probe-dir'
    refused
    [[ "$output" == *"Bash(chmod 777:*)"* ]]
}

@test "model: the bare literal matches" {
    probe 'git checkout .'
    refused
}

@test "model: a continuation INSIDE the final token does not match" {
    # The pair that established the law: same subcommand, opposite outcomes.
    probe 'git checkout ./src'
    allowed
}

@test "model: a whole home directory escapes the bare-slash rule" {
    probe 'rm -rf /home/someone'
    allowed
}

@test "model: the rule text in an ARGUMENT position does not match" {
    # Measured: `echo chmod 777 <dir>` ran. A substring search would refuse it,
    # and would price every widening far too high.
    probe 'echo chmod 777 /tmp/probe-dir'
    allowed
}

@test "model: && splits the command into segments" {
    probe 'mkdir -p /tmp/probe-dir && chmod 777 /tmp/probe-dir'
    refused
}

@test "model: a semicolon splits the command into segments" {
    probe 'true; chmod 777 /tmp/probe-dir'
    refused
}

@test "model: a rule with no :* wildcard matches its literal alone" {
    probe 'eval'
    refused
    probe 'eval echo hi'
    allowed
}

@test "CONTROL: the liveness probe the allowed cases lean on really refuses" {
    # `allowed` is only as good as this. If the liveness command ever stops
    # being refused, every absence assertion in this file goes quiet instead
    # of failing, and that is the failure mode the file is about.
    probe 'chmod 777 /tmp/probe-liveness'
    refused
}

@test "CONTROL: an ordinary command is refused by nothing" {
    # Without this, every "allowed" case above would pass on a matcher that
    # matches nothing at all.
    probe 'npm run test'
    allowed
}

# --- The zero that means nothing --------------------------------------------

@test "support: a candidate rule the corpus cannot exercise is named blind" {
    printf 'probe\tnpm run build\n' > "$TEST_DIR/probe.tsv"
    run bash "$TOOL" --root "$TEST_DIR" --stdin --with-rule 'Bash(dd:*)' \
        < "$TEST_DIR/probe.tsv"
    [ "$status" -eq 0 ]
    [[ "$output" == *"support: 0"* ]]
    [[ "$output" == *"blind"* ]]
}

@test "support: a candidate rule the corpus CAN exercise reports its support" {
    printf 'probe\tdd if=/dev/zero of=out\nprobe\tnpm run build\n' > "$TEST_DIR/probe.tsv"
    run bash "$TOOL" --root "$TEST_DIR" --stdin --with-rule 'Bash(dd:*)' \
        < "$TEST_DIR/probe.tsv" 
    [[ "$output" == *"support: 1"* ]]
    [[ "$output" != *"blind"* ]]
    # …and the delta is the cost of the candidate, not a repeat of the support.
    [[ "$output" == *"delta +1"* ]]
}

@test "support: it is counted at the RULE's granularity, not its command word" {
    # The first version counted the command WORD, so a rule about `git clean`
    # reported the support of every `git` command in the corpus — measured, 82
    # against 0 real `git clean` commands. It therefore stayed silent exactly
    # where it was blind, which is the one thing the support figure exists to
    # prevent. Support is now the set of commands ONE TOKEN away from matching.
    printf 'probe\tgit status --short\n' > "$TEST_DIR/probe.tsv"
    run bash "$TOOL" --root "$TEST_DIR" --stdin --with-rule 'Bash(git clean -fdx:*)' \
        < "$TEST_DIR/probe.tsv"
    [[ "$output" == *"support: 0"* ]]
    [[ "$output" == *"blind"* ]]
}

@test "support: a rule one token from the corpus is NOT called blind" {
    # The boundary of the case above: without it, a support that always
    # answered zero would pass, and every candidate would read as blind.
    printf 'probe\tgit status --short\n' > "$TEST_DIR/probe.tsv"
    run bash "$TOOL" --root "$TEST_DIR" --stdin --with-rule 'Bash(git status:*)' \
        < "$TEST_DIR/probe.tsv"
    [[ "$output" == *"support: 1"* ]]
    [[ "$output" != *"blind"* ]]
}

@test "support: a candidate the model does not cover says so" {
    # A Read rule went through as "delta +0" with no support line at all — a
    # reader takes that for "this rule is free" when the model measured
    # nothing. The law was established on the Bash matcher only.
    printf 'probe\tgit status --short\n' > "$TEST_DIR/probe.tsv"
    run bash "$TOOL" --root "$TEST_DIR" --stdin --with-rule 'Read(./secrets/**)' \
        < "$TEST_DIR/probe.tsv"
    [ "$status" -eq 0 ]
    [[ "$output" == *"not covered"* ]]
}

@test "model: a separator INSIDE a quoted string does not split the command" {
    # Measured on this tool before the fix: `grep -E "foo|chmod 777 bar" file`
    # was reported as refused by the chmod rule. It contradicts the model's own
    # measured law — the rule text in an argument position does not match — and
    # it is not merely noise: these refusals feed the reviewed-exception gate,
    # so one such example added to a docs fence would fail CI on a command
    # nothing actually refuses.
    probe 'grep -E "foo|chmod 777 bar" file'
    allowed
}

@test "model: a separator inside SINGLE quotes does not split either" {
    probe "awk '{print \$1; chmod 777 x}' file"
    allowed
}

@test "CONTROL: a separator OUTSIDE quotes still splits" {
    # The boundary of the two cases above: a quote-aware splitter that stopped
    # splitting altogether would pass them both.
    probe 'echo "safe text" && chmod 777 /tmp/x'
    refused
}

@test "no corpus source: the zero is named, not left to speak" {
    # The one path with no blindness warning. A --root without the corpus
    # builder printed `corpus: 0 commands` and exit 0 — the reassuring zero
    # this whole tool exists to refuse.
    run bash "$TOOL" --root "$TEST_DIR" --summary
    [ "$status" -eq 0 ]
    [[ "$output" == *"no corpus source"* ]]
}

@test "flag order: --with-rule is not discarded by a later --summary" {
    # MODE was last-writer-wins, so `--with-rule X --summary` answered a
    # different question with no diagnostic: the reader prices a widening,
    # reads "5 refused", and has priced nothing.
    printf 'probe\tnpm run build\n' > "$TEST_DIR/probe.tsv"
    run bash "$TOOL" --root "$TEST_DIR" --stdin --with-rule 'Bash(dd:*)' --summary \
        < "$TEST_DIR/probe.tsv"
    [[ "$output" == *"support:"* ]]
}

@test "a flag missing its value exits 0 with a diagnostic, as documented" {
    # `shift 2` on a single remaining argument returns non-zero and `set -e`
    # aborted before any exit 0 — measured rc=1, no output, against a header
    # that promises "Exit: 0 always".
    run bash "$TOOL" --root
    [ "$status" -eq 0 ]
    [[ "$output" == *"needs a value"* ]]
}

# --- The two tools must not drift apart -------------------------------------

@test "consistency: every rule the inventory calls literal-only behaves as one" {
    # Two tools model the same measured law from different angles — the
    # inventory classifies RULES, this one matches COMMANDS. Nothing keeps them
    # honest but a law asserted across both, so: for every literal-only rule,
    # its bare form is refused and the same form extended INSIDE its final
    # token is not.
    local checked=0 rule prefix
    while IFS= read -r rule; do
        prefix="${rule#Bash(}"
        prefix="${prefix%:\*)}"
        prefix="${prefix%)}"
        printf 'probe\t%s\n' "$prefix" > "$TEST_DIR/probe.tsv"
        run bash "$TOOL" --stdin < "$TEST_DIR/probe.tsv"
        [ -n "$output" ] || { echo "literal not refused: $prefix"; return 1; }
        printf 'probe\t%sZZ\n' "$prefix" > "$TEST_DIR/probe.tsv"
        run bash "$TOOL" --stdin < "$TEST_DIR/probe.tsv"
        [ -z "$output" ] || { echo "token extension refused: ${prefix}ZZ"; return 1; }
        checked=$((checked + 1))
    done < <(bash "$INVENTORY" --source deny \
             | grep 'blocking-literal-only' \
             | sed -E 's/^deny \| ([^|]+) \|.*/\1/' | sed 's/[[:space:]]*$//')
    # Derived from the inventory, never pinned: a hard-coded count would pass
    # while the loop iterated over nothing.
    [ "$checked" -gt 0 ]
}

# --- The real repository ----------------------------------------------------

@test "self-application: every refusal names a rule the deny list really holds" {
    run bash "$TOOL"
    [ "$status" -eq 0 ]
    local rule
    while IFS=$'\t' read -r rule _; do
        [ -n "$rule" ] || continue
        grep -Fq "$rule" "$BATS_TEST_DIRNAME/../.claude/settings.json" \
            || { echo "reported a rule the settings file does not carry: $rule"; return 1; }
    done <<< "$output"
}

@test "self-application: every refusal is a reviewed exception" {
    # The contract mirrors tests/validator-corpus.bats: a SUBSET check, not a
    # count. Refusing fewer commands never fails — docs getting better is not a
    # regression — but a rule widened until it starts refusing ordinary
    # documented commands fails here, with the command named, instead of
    # quietly taxing everyone who follows the docs.
    #
    # Reviewed 2026-09-04. All five are `sudo` in operator procedures a human
    # runs, and the deny rule is deliberate: the agent is meant to stop there.
    run bash "$TOOL"
    local rule src cmd
    while IFS=$'\t' read -r rule src cmd; do
        [ -n "$cmd" ] || continue
        case "$rule|$cmd" in
            'Bash(sudo:*)|sudo '*) continue ;;
        esac
        echo "unreviewed refusal: $rule on $src -> $cmd"
        return 1
    done <<< "$output"
}

@test "self-application CONTROL: the reviewed-exception gate can actually fail" {
    # The gate above is a loop over refusals; with none, it passes having
    # checked nothing. Plant one the review set does not cover and watch it
    # fail, so the green above means the set was really consulted.
    printf 'planted\tchmod 777 /tmp/x\n' > "$TEST_DIR/probe.tsv"
    run bash "$TOOL" --root "$TEST_DIR" --stdin < "$TEST_DIR/probe.tsv"
    [ -n "$output" ]
    local rule cmd unreviewed=0
    while IFS=$'\t' read -r rule _ cmd; do
        [ -n "$cmd" ] || continue
        case "$rule|$cmd" in
            'Bash(sudo:*)|sudo '*) continue ;;
        esac
        unreviewed=$((unreviewed + 1))
    done <<< "$output"
    [ "$unreviewed" -gt 0 ]
}

@test "self-application CONTROL: the real corpus is not silently empty" {
    # The measurement that matters is a count of refusals; a broken corpus
    # builder would report zero and look reassuring.
    run bash "$TOOL" --summary
    [[ "$output" =~ corpus:\ ([0-9]+)\ commands ]]
    [ "${BASH_REMATCH[1]}" -gt 100 ]
}
