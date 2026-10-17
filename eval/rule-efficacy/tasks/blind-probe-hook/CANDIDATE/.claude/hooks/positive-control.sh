#!/usr/bin/env bash
# positive-control.sh — PostToolUse(Bash), ADVISORY: when a query-like command
# answers "nothing" (empty output, a bare 0, or a short "OK / no ... found" line),
# remind the agent that a blind check looks exactly like a true negative.
# Never blocks (exit 0 always). Disable: SKIP_POSITIVE_CONTROL=1.
[ "${SKIP_POSITIVE_CONTROL:-0}" = "1" ] && exit 0
command -v jq >/dev/null 2>&1 || exit 0
INPUT=$(cat) || exit 0
[ -n "$INPUT" ] || exit 0
[ "$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)" = "Bash" ] || exit 0
# A background command's output goes to a file: its empty result means nothing.
[ "$(printf '%s' "$INPUT" | jq -r '.tool_input.run_in_background // false' 2>/dev/null)" = "true" ] && exit 0
cmd=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
out=$(printf '%s' "$INPUT" | jq -r '(.tool_response.stdout // "") + (.tool_response.stderr // "")' 2>/dev/null | tr -d '\000')
[ -n "$cmd" ] || exit 0

# Structural exclusions — shapes whose empty answer is not a finding:
# wait loops, followed streams, file writes (heredoc / redirect-only).
printf '%s' "$cmd" | grep -Eq '(^|[;&|(][[:space:]]*)(until|while)[[:space:]]|sleep[[:space:]]+[0-9]|--watch|[[:space:]]-f([[:space:]]|$)' && exit 0
printf '%s' "$cmd" | grep -Eq '<<-?[[:space:]]*'"['\"]?"'[A-Za-z_]+|(^|[^0-9&])>[[:space:]]*[^&[:space:]][^[:space:]]*[[:space:]]+2>&1[[:space:]]*$' && exit 0

# Query-like: a search / count / listing command at the head of a segment, or a
# check-named script or target anywhere (npm run check:x, make lint, ./verify.sh).
printf '%s' "$cmd" | grep -Eq '(^|[|;&(]|\$\()[[:space:]]*(sudo[[:space:]]+)?(grep|egrep|rg|find|jq|wc|git[[:space:]]+(log|grep|ls-files|diff))([[:space:]]|$)' \
    || printf '%s' "$cmd" | grep -Eq '(^|[[:space:]/|;&(])[^[:space:]]*(check|scan|lint|verify|audit|validate)[^[:space:]]*([[:space:]]|$)' \
    || exit 0

# Drop blank lines and the "> script" banner npm/pnpm/yarn print before running it.
trimmed=$(printf '%s\n' "$out" | grep -Ev '^[[:space:]]*(>[[:space:]].*)?$' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
kind=""
if [ -z "$trimmed" ]; then
    kind="returned no output"
elif [ "$(printf '%s\n' "$trimmed" | wc -l)" -le 2 ] && [ "${#trimmed}" -le 160 ]; then
    last=$(printf '%s\n' "$trimmed" | tail -n 1)
    if printf '%s' "$last" | grep -Eiq '^[^[:alnum:]]*(0|ok|clean|passed?|none|nothing)([^[:alnum:]]|$)|no (match(es)?|results?|findings?|issues?|remaining|differences)|nothing (found|to)|[^[:alnum:]]0 (match(es)?|results?|findings?|errors?|issues?|files?)|not found'; then
        kind="answered \"$last\""
    fi
fi
[ -n "$kind" ] || exit 0
# Eval delivery canary: record each firing outside the project when asked to.
[ -n "${POSITIVE_CONTROL_TRACE:-}" ] && printf '%s\t%s\n' "$kind" "$cmd" >> "$POSITIVE_CONTROL_TRACE"

{
    echo "Positive control: this check $kind."
    echo "An empty or \"OK\" answer from a blind check (a glob or filter that skips the files that matter, a wrong path, a swallowed error) looks exactly like a true negative."
    echo "Before relying on it, make the same check find a known positive, or confirm with an independent method."
} | jq -Rs '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: .}}' 2>/dev/null || true
exit 0
