#!/usr/bin/env bash
# =============================================================================
# scratchpad-check.sh — SessionStart warning about Claude Code temp dirs
# =============================================================================
# Claude Code gives every session a temp dir (<base>/claude-<uid>/<project>/
# <session>/, holding its scratchpad) and nothing removes it when the session
# ends. Where /tmp is a tmpfs that is RAM: on 2026-09-24 one session's 4 GB of
# node_modules stayed in memory until the OOM killer ended another session.
# That session was one day old, so the signal is SIZE, not age.
#
# REPORTS ONLY — this hook never deletes. When the whole temp tree passes the
# threshold it prints the total, the largest OTHER sessions and the rebuildable
# dirs inside them; it always reports files you do not own (a `docker run -v`
# without --user leaves root-owned files no user-level cleanup can remove).
#
# Input: the SessionStart payload on stdin; `scratchpad_dir` locates the tree.
# Env:   CLAUDE_BASE_SCRATCH_WARN_MB  threshold in MiB (default 1024)
#        CLAUDE_BASE_SCRATCH_UID      uid treated as "you" (test seam)
# Always exits 0 — never blocks a session. Silent when there is nothing to say.
# =============================================================================

set -u

command -v jq >/dev/null 2>&1 || exit 0

payload=$(cat 2>/dev/null) || exit 0
sp=$(printf '%s' "$payload" | jq -r 'if type == "object" then (.scratchpad_dir // "") else "" end' 2>/dev/null) || exit 0

me="${CLAUDE_BASE_SCRATCH_UID:-$(id -u)}"
cur=""
if [ -n "$sp" ]; then
    # Only a path with Claude Code's shape is trusted to locate the tree: the
    # base is derived from it, and a malformed one must not walk, say, /.
    case "$sp" in */scratchpad) ;; *) exit 0 ;; esac
    cur=$(dirname "$sp")
    base=$(dirname "$(dirname "$cur")")
    case "$(basename "$base")" in claude-[0-9]*) ;; *) exit 0 ;; esac
else
    base="${CLAUDE_CODE_TMPDIR:-${TMPDIR:-/tmp}}"
    base="${base%/}/claude-$(id -u)"
fi
[ -d "$base" ] || exit 0

warn_mb="${CLAUDE_BASE_SCRATCH_WARN_MB:-1024}"
case "$warn_mb" in ''|*[!0-9]*) warn_mb=1024 ;; esac

# du, bounded where `timeout` exists (not on stock macOS).
_du_k() {
    if command -v timeout >/dev/null 2>&1; then timeout 5 du -sk "$@" 2>/dev/null
    else du -sk "$@" 2>/dev/null; fi
}
# _human <KiB> — "4.1 GB" / "312 MB".
_human() { awk -v k="$1" 'BEGIN { if (k >= 1048576) printf "%.1f GB", k/1048576; else printf "%d MB", k/1024 }'; }

total_k=$(_du_k "$base" | awk '{print $1}')
case "$total_k" in ''|*[!0-9]*) total_k=0 ;; esac

if [ "$total_k" -gt $((warn_mb * 1024)) ]; then
    echo "[SCRATCH] Claude Code temp dirs use $(_human "$total_k") under $base (threshold $(_human $((warn_mb * 1024)))). Nothing removes them when a session ends."
    # The three largest session dirs, the current one excluded.
    _du_k "$base"/*/* | sort -rn | while read -r k dir; do
        [ "$dir" = "$cur" ] && continue
        echo "$k $dir"
    done | head -3 | while read -r k dir; do
        rebuild=$(find "$dir" -maxdepth 5 -type d \( -name node_modules -o -name .venv -o -name .next -o -name .turbo -o -name target \) -prune -print 2>/dev/null \
            | awk -F/ '{print $NF}' | sort -u | tr '\n' ' ' | sed 's/ $//')
        line="[SCRATCH]   $(_human "$k")  ${dir#"$base"/}"
        [ -n "$rebuild" ] && line="$line  (rebuildable: $rebuild)"
        echo "$line"
    done
    if command -v findmnt >/dev/null 2>&1 && [ "$(findmnt -no FSTYPE -T "$base" 2>/dev/null)" = "tmpfs" ]; then
        echo "[SCRATCH] $base is a tmpfs: this is RAM. CLAUDE_CODE_TMPDIR in ~/.claude/settings.json env moves it to disk."
    fi
fi

foreign=$(find "$base" -xdev ! -user "$me" -print 2>/dev/null | head -1)
if [ -n "$foreign" ]; then
    echo "[SCRATCH] Files not owned by you under $base (e.g. ${foreign#"$base"/}): a docker run -v without --user \"\$(id -u):\$(id -g)\"? Removing them needs sudo."
fi

exit 0
