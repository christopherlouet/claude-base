#!/usr/bin/env bash
# =============================================================================
# prompt-context.sh — Hook UserPromptSubmit
# =============================================================================
# Invoque par Claude Code sur chaque prompt utilisateur.
# Lit sur stdin un JSON {"prompt": "..."} et, si le prompt n'est PAS une
# slash command, ecrit sur stdout un JSON conforme au contrat hookSpecificOutput
# qui injecte du contexte (branche, diff, fichiers modifies, hint routing).
#
# Objectif : rendre le "happy path" par defaut — toute demande libre beneficie
# du contexte repo pour que Claude route vers le bon workflow via /assistant-auto.
#
# Desactivation : SKIP_PROMPT_CONTEXT=1
# =============================================================================

set -u

# Bail-out rapides
[ "${SKIP_PROMPT_CONTEXT:-0}" = "1" ] && exit 0
command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat 2>/dev/null || true)
[ -z "$INPUT" ] && exit 0

# stdin doit etre du JSON parseable
PROMPT=$(printf '%s' "$INPUT" | jq -r '.prompt // empty' 2>/dev/null) || exit 0
[ -z "$PROMPT" ] && exit 0

# Trim leading whitespace puis detection slash command
TRIMMED=$(printf '%s' "$PROMPT" | sed -e 's/^[[:space:]]*//')
case "$TRIMMED" in
    /*) exit 0 ;;
esac

# Racine projet (hors repo git : on fournit quand meme le hint routing)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$PROJECT_DIR" 2>/dev/null || exit 0

BRANCH=""
STATUS_SHORT=""
DIFF_STAT=""
LOC_CHANGED=0
IN_GIT=0

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    IN_GIT=1
    BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
    STATUS_SHORT=$(git status --short 2>/dev/null | head -20)
    DIFF_STAT=$(git diff --stat HEAD 2>/dev/null | tail -1)
    LOC_CHANGED=$(git diff --shortstat HEAD 2>/dev/null | grep -oE '[0-9]+ insertion|[0-9]+ deletion' | awk '{s+=$1} END {print s+0}')
fi

# Memoire perso (top 5 lignes de MEMORY.md si presente)
MEMORY_SNIPPET=""
MEMORY_FILE="$HOME/.claude/projects/$(printf '%s' "$PROJECT_DIR" | sed 's|/|-|g')/memory/MEMORY.md"
if [ -f "$MEMORY_FILE" ]; then
    MEMORY_SNIPPET=$(head -5 "$MEMORY_FILE" 2>/dev/null | grep -E '^- ' || true)
fi

# Construction du contexte
{
    echo "## Contexte repo (injecte automatiquement)"
    echo ""
    if [ "$IN_GIT" = "1" ]; then
        echo "- Branche : \`$BRANCH\`"
        if [ -n "$STATUS_SHORT" ]; then
            echo "- Fichiers modifies :"
            echo "\`\`\`"
            printf '%s\n' "$STATUS_SHORT"
            echo "\`\`\`"
        else
            echo "- Working tree clean"
        fi
        if [ -n "$DIFF_STAT" ]; then
            echo "- Diff : $DIFF_STAT (LOC changees : $LOC_CHANGED)"
        fi
    else
        echo "- Hors repo git"
    fi

    if [ -n "$MEMORY_SNIPPET" ]; then
        echo ""
        echo "## Memoire perso (extraits)"
        printf '%s\n' "$MEMORY_SNIPPET"
    fi

    echo ""
    echo "## Routing"
    echo ""
    echo "Pas de slash command explicite. Si la demande est actionnable (feature, bugfix, refactor, audit, deploy...), envisage de router via \`/assistant-auto\` pour choisir le workflow adapte. Pour un changement trivial (< 50 LOC, 1-3 fichiers), \`/work:work-quick\` suffit."
} | jq -Rs '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: .}}'
