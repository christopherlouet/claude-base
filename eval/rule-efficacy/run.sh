#!/usr/bin/env bash
# =============================================================================
# eval/rule-efficacy/run.sh — the GENERATION half of the rule-efficacy eval.
# For a task, builds a CONTROL arm (the task's target rule REMOVED) and a
# TREATMENT arm (rule present), runs the coding agent N times per arm, collects
# the produced files, and prints the 4-way verdict via eval.sh.
#
# *** THIS SPENDS METERED LLM CREDIT *** — each sample is one `claude -p` call
# (2 arms x N samples = 2N calls). It is therefore DRY-RUN by default: it prints
# exactly what it would do and spends nothing. Pass --execute to actually run.
#
#   run.sh <task-name> [--samples N] [--execute]
#
# Override the agent invocation with CLAUDE_CMD (default below). The agent must
# be able to write files non-interactively in its CWD.
# =============================================================================

set -euo pipefail

SELF_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SELF_DIR/../.." && pwd)"
EVAL="$SELF_DIR/eval.sh"
CLAUDE_CMD="${CLAUDE_CMD:-claude -p --permission-mode acceptEdits}"

TASK_NAME=""
SAMPLES=3
EXECUTE=0
while [ $# -gt 0 ]; do
    case "$1" in
        --samples) SAMPLES="$2"; shift 2 ;;
        --execute) EXECUTE=1; shift ;;
        -h|--help) sed -nE 's/^# ?//p' "$0" | sed -n '2,16p'; exit 0 ;;
        -*) echo "run.sh: unknown option: $1" >&2; exit 2 ;;
        *)  TASK_NAME="$1"; shift ;;
    esac
done
[ -n "$TASK_NAME" ] || { echo "run.sh: missing <task-name>" >&2; exit 2; }

TASK_DIR="$SELF_DIR/tasks/$TASK_NAME"
[ -d "$TASK_DIR" ] || { echo "run.sh: no such task: $TASK_NAME" >&2; exit 2; }
[ -f "$TASK_DIR/PROMPT.md" ] || { echo "run.sh: task has no PROMPT.md" >&2; exit 2; }

# shellcheck disable=SC2034  # used at runtime inside the eval'd agent command
PROMPT="$(cat "$TASK_DIR/PROMPT.md")"
# Rule files to remove for the control arm (RULE file; ignore blanks/comments).
RULES=()
if [ -f "$TASK_DIR/RULE" ]; then
    while IFS= read -r line; do
        case "$line" in ''|'#'*) continue ;; esac
        RULES+=("$line")
    done < "$TASK_DIR/RULE"
fi
# Output files to collect (OUTPUTS file).
OUTPUTS=()
if [ -f "$TASK_DIR/OUTPUTS" ]; then
    while IFS= read -r line; do
        case "$line" in ''|'#'*) continue ;; esac
        OUTPUTS+=("$line")
    done < "$TASK_DIR/OUTPUTS"
fi
[ "${#OUTPUTS[@]}" -gt 0 ] || { echo "run.sh: task has no OUTPUTS to collect" >&2; exit 2; }

WORK="$SELF_DIR/runs/${TASK_NAME}"
echo "Task:       $TASK_NAME"
echo "Samples:    $SAMPLES per arm (control + treatment = $((2 * SAMPLES)) agent calls)"
echo "Control removes rule(s): ${RULES[*]:-<none>}"
echo "Collect outputs:         ${OUTPUTS[*]}"
echo "Work dir:   $WORK"
echo "Agent:      $CLAUDE_CMD"
echo

if [ "$EXECUTE" -ne 1 ]; then
    echo "DRY RUN (no credit spent). For each arm it would, per sample:"
    echo "  1. build a project = CLAUDE.md + .claude/rules/ copied from the repo"
    echo "     (control: with the target rule file(s) removed)"
    echo "  2. cd into it and run: $CLAUDE_CMD \"\$(cat $TASK_NAME/PROMPT.md)\""
    echo "  3. collect ${OUTPUTS[*]} into runs/$TASK_NAME/<arm>/sample-N/"
    echo "  4. score with: eval.sh compare runs/$TASK_NAME/control runs/$TASK_NAME/treatment $TASK_NAME"
    echo
    echo "Re-run with --execute to spend the credit and produce the verdict."
    exit 0
fi

# --- real generation (spends credit) ----------------------------------------
command -v claude >/dev/null 2>&1 || { echo "run.sh: claude CLI not found" >&2; exit 2; }
rm -rf "$WORK"; mkdir -p "$WORK"

# build_project <dir> <arm> — a minimal foundation project (CLAUDE.md + rules).
build_project() {
    local dir="$1" arm="$2" r
    mkdir -p "$dir/.claude"
    cp "$REPO_ROOT/CLAUDE.md" "$dir/CLAUDE.md" 2>/dev/null || true
    cp -R "$REPO_ROOT/.claude/rules" "$dir/.claude/rules"
    if [ "$arm" = "control" ] && [ "${#RULES[@]}" -gt 0 ]; then
        for r in "${RULES[@]}"; do rm -f "$dir/$r"; done
    fi
}

for arm in control treatment; do
    i=1
    while [ "$i" -le "$SAMPLES" ]; do
        proj="$WORK/$arm/.proj-$i"
        sample="$WORK/$arm/sample-$i"
        mkdir -p "$sample"
        build_project "$proj" "$arm"
        echo "[$arm] sample $i/$SAMPLES — generating..."
        ( cd "$proj" && eval "$CLAUDE_CMD \"\$PROMPT\"" ) >/dev/null 2>&1 || true
        for out in "${OUTPUTS[@]}"; do
            [ -f "$proj/$out" ] && cp "$proj/$out" "$sample/$out"
        done
        i=$((i + 1))
    done
done

echo
echo "=== verdict ==="
bash "$EVAL" compare "$WORK/control" "$WORK/treatment" "$TASK_DIR"
