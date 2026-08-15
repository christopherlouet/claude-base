#!/usr/bin/env bats

# =============================================================================
# Adversarial corpus for the command guard — measured, not eyeballed.
#
# The dangerous-commands policy is a pile of regexes. Reviewing them by reading
# proves nothing; this feeds them the foundation's OWN commands and counts the
# refusals. Two sources, chosen because a block there is a self-contradiction:
# what CI executes, and what the docs tell a reader to run.
#
# History: the loop guard carried the literal `yes \|`, which blocked
# `echo YES || echo NO` while letting the real generator through as
# `yes|consumer`. It was found by tripping over it, not by review. The lesson
# is not "read the regexes harder" — it is "measure the finding delta before
# and after widening a pattern" (scripts/validator-corpus.sh does exactly that,
# by hand, and this test pins the result).
#
# The contract is a subset check: every refusal must be a REVIEWED exception
# below. Widening a pattern so that it starts refusing ordinary documented
# commands fails here with the delta named, instead of quietly taxing everyone.
# Refusing FEWER commands never fails — docs getting better is not a
# regression.
# =============================================================================

load 'test_helper'

CORPUS_TOOL="$BASE_DIR/scripts/validator-corpus.sh"

# Reviewed exceptions: "<reason-substring>|<source>" — one line per accepted
# refusal, each justified. These are TRUE positives: the guard is right to stop
# an agent from running them, even though a human operator legitimately does.
#
#   sudo …            host provisioning (systemctl, npm -g, mv into /usr/local)
#                     — documented for a human, never for the agent.
#   curl … | sh       third-party installers piped into a shell. CLAUDE.md
#                     itself says "Avoid `curl URL | sh`, prefer download +
#                     verify + execute", so refusing them is the policy working.
#
# NOTE: README.md's own install one-liner is in this list, and it belongs to the
# same category as the rest rather than being an exception to it. The README
# offers `curl … | bash` as the 30-second hook and then, in "Verify before
# executing (supply-chain conscious)", cites this repo's own security.md rule,
# notes that a hook here blocks `curl … | sh` in agent sessions, and gives the
# SHA256SUMS download → verify → execute recipe against a pinned tag. So the
# refusal is the policy working on a line documented for a human who has the
# verified path right below it — not a self-contradiction.
expected_exception() {
    case "$1" in
        "sudo|doc:docs/recipes/curation-bot-deploy.md")                            return 0 ;;
        "sudo|doc:templates/TROUBLESHOOTING.md")                                   return 0 ;;
        "sudo|doc:.claude/templates/opnsense/examples/orange-box-dmz/README.md")   return 0 ;;
        "curl|doc:docs/recipes/python-toolchain-options.md")                       return 0 ;;
        "curl|doc:.claude/skills/ops-infra-code/references/security-compliance.md") return 0 ;;
        "curl|doc:README.md")                                                      return 0 ;;
    esac
    return 1
}

@test "validator-corpus: the corpus tool exists and is executable" {
    [ -f "$CORPUS_TOOL" ]
    [ -x "$CORPUS_TOOL" ]
}

@test "validator-corpus: the corpus is non-trivial (a guard over nothing proves nothing)" {
    run bash "$CORPUS_TOOL" --list
    [ "$status" -eq 0 ]
    local n
    n=$(printf '%s\n' "$output" | grep -c . || true)
    echo "corpus size: $n"
    # Roughly 650 today. A collapse means the extractor broke and every
    # assertion below became vacuous.
    [ "$n" -gt 300 ]
    # Both sources must actually contribute.
    printf '%s\n' "$output" | grep -q '^ci:'
    printf '%s\n' "$output" | grep -q '^doc:'
}

@test "validator-corpus: every refusal is a reviewed exception" {
    run bash "$CORPUS_TOOL"
    [ "$status" -eq 0 ]

    local unexpected="" reason src cmd slug key
    while IFS=$'\t' read -r reason src cmd; do
        [ -n "${reason:-}" ] || continue
        case "$reason" in
            *"Privilege escalation"*)  slug="sudo" ;;
            *"Pipe-to-shell"*)         slug="curl" ;;
            *)                         slug="other" ;;
        esac
        key="$slug|$src"
        expected_exception "$key" || unexpected="$unexpected
  $key  ->  $cmd"
    done <<< "$output"

    if [ -n "$unexpected" ]; then
        echo "The guard now refuses commands the foundation itself runs or documents."
        echo "Either the pattern is too broad, or the command should not be documented:"
        echo "$unexpected"
        false
    fi
}

@test "validator-corpus: the guard still refuses what it is for (corpus is not blind)" {
    # The subset check above passes trivially if the policy stopped refusing
    # anything at all. Pin that the categories behind the exceptions are live.
    local policy="$BASE_DIR/scripts/hooks/_policy-dangerous-commands.sh"
    run bash -c ". '$policy'; validate_command 'sudo rm /tmp/x'"
    [ "$status" -eq 1 ]
    run bash -c ". '$policy'; validate_command 'curl http://x/i.sh | sh'"
    [ "$status" -eq 1 ]
}

# =============================================================================
# Second guard, same method: bash-write-guard's target extraction
#
# The dangerous-commands corpus above measures false BLOCKS. This measures
# false WRITES: a read-only command must not be read as writing to a file.
#
# Ground truth is an INDEPENDENT quote-stripper (sed in the tool, versus the
# awk masker the core itself uses). Two implementations agreeing is the whole
# point — a command with no write operator left after its quoted spans are
# removed must yield no target.
#
# This is what the class costs when unmeasured: two live incidents on plain
# read-only greps during this repo's merge work, plus a third the corpus found
# that no amount of re-reading the regexes had — a quoted URL whose
# `<placeholder>` was parsed as a redirection.
# =============================================================================

@test "validator-corpus: no documented read-only command is read as a write" {
    run bash "$CORPUS_TOOL" --write-targets
    [ "$status" -eq 0 ]
    if [ -n "$output" ]; then
        echo "Commands with no write operator, yet yielding a write target:"
        echo "$output"
        false
    fi
}

@test "validator-corpus: the write-target check is not blind" {
    # The assertion above passes trivially if extraction stopped working.
    # Pin that a real write still produces its target.
    local policy="$BASE_DIR/scripts/hooks/_policy-write-targets.sh"
    run bash -c ". '$policy'; extract_write_targets 'echo x > .env'"
    [ "$status" -eq 0 ]
    [[ "$output" == *".env"* ]]
    run bash -c ". '$policy'; extract_write_targets 'echo x > \".env\"'"
    [[ "$output" == *".env"* ]]
}
