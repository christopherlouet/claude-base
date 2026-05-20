#!/usr/bin/env bash
# =============================================================================
# Recorded scenario for the claude-base 60-second tour.
#
# Runs inside the claude-base-demo Docker image. Real steps :
#   1. curl|bash install of the foundation
#   2. claude-base init --preset nextjs into a fresh project dir
#   3. show what's on disk (`tree`)
#   4. open Claude Code and run /work:work-flow-feature against a real
#      Claude Max session (auth mounted from host into /root/.claude)
#
# Pacing : explicit `sleep` between visible steps so the recording reads
# naturally. agg --speed 1.5 will speed up the final GIF anyway.
# =============================================================================

set -euo pipefail

# Source the PATH so $HOME/.local/bin (where claude-base symlinks the
# dispatcher) is picked up after the installer runs.
export PATH="${HOME}/.local/bin:${PATH}"

pause() { sleep "${1:-1}"; }

# Colorize [INFO]/[OK]/[WARN]/[ERROR] tags emitted by scripts that strip
# colors when stdout isn't a TTY (install.sh has no native color logic ;
# common.sh's color is gated on `[[ -t 1 ]]` which fails behind a pipe).
# sed-injects ANSI escapes around the tags so the recording stays colorized
# regardless of how the underlying tool detects its environment.
colorize() {
    sed -E $'s/\\[OK\\]/\\\033[0;32m[OK]\\\033[0m/g;
            s/\\[INFO\\]/\\\033[0;34m[INFO]\\\033[0m/g;
            s/\\[WARN\\]/\\\033[0;33m[WARN]\\\033[0m/g;
            s/\\[ERROR\\]/\\\033[0;31m[ERROR]\\\033[0m/g'
}

# Visual prompt for the "$" line — bold + dim to match terminal palette
PROMPT_GREY=$'\033[1;30m$\033[0m'

# Step 1 — install
clear
echo
echo $'  \033[1;36m❯\033[0m Install the foundation'
echo
pause 1
printf "  %s curl -fsSL \033[4;36mhttps://raw.githubusercontent.com/christopherlouet/claude-base/main/install.sh\033[0m | bash\n" "$PROMPT_GREY"
pause 0.8
# Run the installer ; suppress git-clone noise but keep [OK]/[INFO] lines.
# Colorize the tags (install.sh doesn't emit them with color natively).
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-base/main/install.sh 2>/dev/null | bash 2>&1 \
    | grep -E '^\[(OK|INFO|WARN|ERROR)\]' | head -4 | colorize
# Read-time : 4 lines of output, give the eye time to land before next clear
pause 3

# Step 2 — init
clear
echo
echo $'  \033[1;36m❯\033[0m Drop the foundation into a new Next.js project'
echo
pause 1
printf "  %s claude-base init --preset nextjs ./my-app\n" "$PROMPT_GREY"
pause 0.8
# script -qec wraps the command in a PTY so common.sh's `[[ -t 1 ]]` check
# passes — colors are emitted natively. fallback to colorize() if any tag
# slipped through uncolored.
script -qec "claude-base init --preset nextjs --yes \"${HOME}/work/my-app\"" /dev/null 2>&1 \
    | tr -d '\r' \
    | grep -aE '\[(OK|INFO|WARN|ERROR)\]' | head -6
# Read-time : 6 lines of output, the densest frame
pause 4

# Step 3 — what we got
clear
echo
echo $'  \033[1;36m❯\033[0m What landed on disk'
echo
pause 1
printf "  %s ls .claude/\n" "$PROMPT_GREY"
pause 0.8
# Colorize directories blue (like default ls --color=auto)
ls -1 "${HOME}/work/my-app/.claude/" \
    | sed -E $'s/^([a-z-]+)$/\\\033[1;34m\\1\\\033[0m/' \
    | sed 's|^|    |'
# Read-time : 8 short dir names, scan-friendly
pause 4

# Step 4 — ask Claude how to use a specific foundation command
clear
echo
echo $'  \033[1;36m❯\033[0m Ask Claude — the foundation is now in context'
echo
pause 1
printf "  %s claude --print '/assistant How to use /dev:dev-tdd?'\n" "$PROMPT_GREY"
pause 0.8
cd "${HOME}/work/my-app"
# /assistant is the foundation's orchestrator. With a focused question it
# returns a short tailored answer — perfect for a demo frame.
claude --print --output-format text "/assistant How to use /dev:dev-tdd?" < /dev/null 2>&1 | head -10
# Read-time : Claude's reply is the payoff, give the eye time to land
pause 9

# Step 5 — closing CTA (all visible at once, no late URL)
clear
echo
echo $'  \033[1;36m❯\033[0m Next : \033[1;32mcd ./my-app && claude\033[0m'
echo
echo "  Then drive the 6-phase workflow with one command :"
echo $'  \033[1;33m/work:work-flow-feature "add a /counter route"\033[0m'
echo
echo $'  \033[4;36mhttps://github.com/christopherlouet/claude-base\033[0m'
echo
# Emit per-second events so asciinema captures the read-time (idle silence
# at the END of a session is not recorded — invisible events must occur).
# `printf ' \b'` writes a space + backspace = visually no-op but generates
# an event asciinema can record.
for _ in 1 2 3 4 5; do sleep 1; printf ' \b'; done
