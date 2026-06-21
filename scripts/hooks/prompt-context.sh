#!/usr/bin/env bash
# =============================================================================
# prompt-context.sh — UserPromptSubmit Hook
# =============================================================================
# Invoked by Claude Code on every user prompt.
# Reads from stdin a JSON {"prompt": "..."} and, if the prompt is NOT a
# slash command, writes to stdout a JSON conforming to the hookSpecificOutput
# contract that injects context (branch, diff, modified files, routing hint).
#
# Goal: make the "happy path" the default — every free-form request benefits
# from the repo context so that Claude routes to the right workflow via /assistant-auto.
#
# Disable: SKIP_PROMPT_CONTEXT=1
# =============================================================================

set -u

# Quick bail-outs
[ "${SKIP_PROMPT_CONTEXT:-0}" = "1" ] && exit 0
command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat 2>/dev/null || true)
[ -z "$INPUT" ] && exit 0

# stdin must be parseable JSON
PROMPT=$(printf '%s' "$INPUT" | jq -r '.prompt // empty' 2>/dev/null) || exit 0
[ -z "$PROMPT" ] && exit 0

# Session id (for the once-per-session vendor-precedence marker); fallbacks keep
# the marker stable when the field is absent on older CLIs.
SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // .transcript_path // empty' 2>/dev/null || true)

# Trim leading whitespace then detect slash command
TRIMMED=$(printf '%s' "$PROMPT" | sed -e 's/^[[:space:]]*//')
case "$TRIMMED" in
    /*) exit 0 ;;
esac

# Project root (outside git repo: we still provide the routing hint)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$PROJECT_DIR" 2>/dev/null || exit 0

BRANCH=""
STATUS_SHORT=""
DIFF_STAT=""
LOC_CHANGED=0
IN_GIT=0
DRIFT_COUNT=0
DRIFT_WARN=""
PRS_AWAITING=""

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    IN_GIT=1
    BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
    STATUS_SHORT=$(git status --short 2>/dev/null | head -20)
    DIFF_STAT=$(git diff --stat HEAD 2>/dev/null | tail -1)
    LOC_CHANGED=$(git diff --shortstat HEAD 2>/dev/null | grep -oE '[0-9]+ insertion|[0-9]+ deletion' | awk '{s+=$1} END {print s+0}')

    # Drift vs origin/main (silent if no remote / no main)
    # Disable with SKIP_DRIFT_CHECK=1 to avoid network calls
    if [ "${SKIP_DRIFT_CHECK:-0}" != "1" ]; then
        DEFAULT_REMOTE_BRANCH=""
        for candidate in origin/main origin/master; do
            if git rev-parse --verify --quiet "$candidate" >/dev/null 2>&1; then
                DEFAULT_REMOTE_BRANCH="$candidate"
                break
            fi
        done
        if [ -n "$DEFAULT_REMOTE_BRANCH" ] && [ "$BRANCH" != "main" ] && [ "$BRANCH" != "master" ]; then
            DRIFT_COUNT=$(git rev-list --count "HEAD..$DEFAULT_REMOTE_BRANCH" 2>/dev/null || echo 0)
            if [ "${DRIFT_COUNT:-0}" -gt 10 ]; then
                DRIFT_WARN="WARN: $DEFAULT_REMOTE_BRANCH is $DRIFT_COUNT commits ahead. Consider a rebase before pushing to avoid conflicts."
            elif [ "${DRIFT_COUNT:-0}" -gt 0 ]; then
                DRIFT_WARN="$DEFAULT_REMOTE_BRANCH is $DRIFT_COUNT commits ahead."
            fi
        fi
    fi

    # PRs awaiting review (silent if gh absent / not authenticated)
    # Disable with SKIP_PR_CHECK=1
    if [ "${SKIP_PR_CHECK:-0}" != "1" ] && command -v gh >/dev/null 2>&1; then
        PRS_AWAITING=$(timeout 2 gh pr list --search "review-requested:@me is:open" --json number,title,repository --limit 3 2>/dev/null \
            | jq -r '.[] | "- #\(.number) \(.title) (\(.repository.nameWithOwner // "?"))"' 2>/dev/null || true)
    fi
fi

# Personal memory (top 5 lines of MEMORY.md if present)
MEMORY_SNIPPET=""
MEMORY_FILE="$HOME/.claude/projects/$(printf '%s' "$PROJECT_DIR" | sed 's|/|-|g')/memory/MEMORY.md"
if [ -f "$MEMORY_FILE" ]; then
    MEMORY_SNIPPET=$(head -5 "$MEMORY_FILE" 2>/dev/null | grep -E '^- ' || true)
fi

# Self-improvement loop: feedback pattern detection
# Disable with SKIP_FEEDBACK_DETECT=1
FEEDBACK_HINT=""
if [ "${SKIP_FEEDBACK_DETECT:-0}" != "1" ]; then
    PROMPT_LOWER=$(printf '%s' "$PROMPT" | tr '[:upper:]' '[:lower:]')
    case "$PROMPT_LOWER" in
        *"non, "*|*"non pas"*|*"pas comme"*|*"arrete"*|*"arrête"*|\
        *"stop "*|*"don't "*|*"do not "*|*"not like"*|\
        *"plutot"*|*"plutôt"*|*"prefere"*|*"préfère"*|*"prefer "*|\
        *"au lieu de"*|*"instead of"*|*"rather than"*|\
        *"a l'avenir"*|*"à l'avenir"*|*"from now on"*|*"next time"*|\
        *"souviens-toi"*|*"remember that"*|*"remember to"*|\
        *"toujours "*|*"jamais "*|*"always "*|*"never ")
            FEEDBACK_HINT="Feedback signal detected in the user prompt. If the correction is applicable to future sessions (preference, rule, counter-example), consider saving it via the auto-memory system as a \`feedback\` memory (with **Why:** and **How to apply:**). See memory types in the system prompt."
            ;;
    esac
fi

# Vendor-precedence hint (once per session): if a graduated vendor skill is
# installed, nudge toward it over the foundation pointer (vendor-precedence T3).
# Pure-shell helper, no network/jq. Opt out with SKIP_VENDOR_PRECEDENCE=1.
VENDOR_HINT=""
if [ "${SKIP_VENDOR_PRECEDENCE:-0}" != "1" ]; then
    VPREC_HELPER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_vendor-precedence-hint.sh"
    if [ -f "$VPREC_HELPER" ]; then
        # shellcheck source=/dev/null
        . "$VPREC_HELPER"
        _vprec_key=$(printf '%s' "${SESSION_ID:-$PROJECT_DIR}|$PROJECT_DIR" | cksum 2>/dev/null | cut -d' ' -f1)
        _vprec_marker="${TMPDIR:-/tmp}/claude-base-vprec.${_vprec_key:-default}"
        # Only suppress once we have actually shown the hint, so a vendor skill
        # installed mid-session still surfaces the first time it appears.
        if [ ! -e "$_vprec_marker" ]; then
            VENDOR_HINT=$(vendor_precedence_hints "$PROJECT_DIR" "${HOME:-}" 2>/dev/null || true)
            [ -n "$VENDOR_HINT" ] && { : > "$_vprec_marker" 2>/dev/null || true; }
        fi
    fi
fi

# Build context
{
    echo "## Repo context (auto-injected)"
    echo ""
    if [ "$IN_GIT" = "1" ]; then
        echo "- Branch: \`$BRANCH\`"
        case "$BRANCH" in
            feature/auto-*)
                echo "- TIP: auto-generated branch, rename with \`/git-rename <descriptive-name>\`"
                ;;
        esac
        if [ -n "$STATUS_SHORT" ]; then
            echo "- Modified files:"
            echo "\`\`\`"
            printf '%s\n' "$STATUS_SHORT"
            echo "\`\`\`"
        else
            echo "- Working tree clean"
        fi
        if [ -n "$DIFF_STAT" ]; then
            echo "- Diff: $DIFF_STAT (LOC changed: $LOC_CHANGED)"
        fi
        if [ -n "$DRIFT_WARN" ]; then
            echo "- $DRIFT_WARN"
        fi
    else
        echo "- Outside git repo"
    fi

    if [ -n "$PRS_AWAITING" ]; then
        echo ""
        echo "## PRs awaiting your review"
        printf '%s\n' "$PRS_AWAITING"
    fi

    if [ -n "$MEMORY_SNIPPET" ]; then
        echo ""
        echo "## Personal memory (excerpts)"
        printf '%s\n' "$MEMORY_SNIPPET"
    fi

    if [ -n "$FEEDBACK_HINT" ]; then
        echo ""
        echo "## Self-improvement"
        echo ""
        echo "$FEEDBACK_HINT"
    fi

    if [ -n "$VENDOR_HINT" ]; then
        echo ""
        echo "## Vendor skills (precedence)"
        echo ""
        printf '%s\n' "$VENDOR_HINT"
    fi

    echo ""
    echo "## Routing"
    echo ""
    echo "No explicit slash command. If the request is actionable (feature, bugfix, refactor, audit, deploy...), consider routing via \`/assistant-auto\` to choose the appropriate workflow. For a trivial change (< 50 LOC, 1-3 files), \`/work:work-quick\` is enough."
} | jq -Rs '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: .}}'
