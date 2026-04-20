#!/usr/bin/env bash
# =============================================================================
# socle-integrity-check.sh — Hook PostToolUse
# =============================================================================
# Invoque par Claude Code apres chaque Edit / Write / NotebookEdit.
# Si le fichier modifie est dans .claude/skills|agents|commands|rules/
# ou est .claude/settings.json, declenche validate-counts.sh en mode warning
# (non bloquant) pour rappeler la mise a jour des compteurs / catalog / hook
# message.
#
# IMPORTANT : non-bloquant. Un warning apparait dans la session mais la
# modification aboutit. Le but est de rappeler, pas d'empecher.
#
# Desactivation : SKIP_SOCLE_INTEGRITY=1
# =============================================================================

set -u

# Bail-out rapides
[ "${SKIP_SOCLE_INTEGRITY:-0}" = "1" ] && exit 0
command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat 2>/dev/null || true)
[ -z "$INPUT" ] && exit 0

TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null) || exit 0
case "$TOOL_NAME" in
    Edit|Write|NotebookEdit|MultiEdit) ;;
    *) exit 0 ;;
esac

FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' 2>/dev/null) || exit 0
[ -z "$FILE_PATH" ] && exit 0

# Seuls les fichiers du socle nous interessent
case "$FILE_PATH" in
    */.claude/skills/*|*/.claude/agents/*|*/.claude/commands/*|*/.claude/rules/*|*/.claude/settings.json)
        ;;
    *)
        exit 0
        ;;
esac

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
VALIDATE="$PROJECT_DIR/scripts/validate-counts.sh"
[ -x "$VALIDATE" ] || exit 0

# On ne lance validate-counts que si le projet est bien le socle lui-meme
# (evite les faux positifs dans les projets qui consomment le socle sans
# maintenir les compteurs).
[ -f "$PROJECT_DIR/scripts/audit-socle.sh" ] || exit 0

# Execution en mode silencieux, on capture juste le code retour
if ! OUTPUT=$("$VALIDATE" 2>&1); then
    # Warning visible dans la session sans bloquer
    {
        echo "[SOCLE-INTEGRITY] Compteurs incoherents apres modification de :"
        echo "  $FILE_PATH"
        echo ""
        echo "Resume :"
        printf '%s\n' "$OUTPUT" | grep -E "(inconsistencies|expected|found)" | head -5
        echo ""
        echo "Lance './scripts/validate-counts.sh' pour le detail et mets a jour les fichiers concernes avant de commit."
    } | jq -Rs '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: .}}' 2>/dev/null || true
fi

exit 0
