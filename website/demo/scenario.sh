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

pause() { sleep "${1:-2}"; }

# Step 1 — install
clear
echo
echo "  ❯ Install the foundation"
echo
pause 2
echo '  $ curl -fsSL .../install.sh | bash'
pause 1.5
# Run the installer ; suppress git-clone noise but keep [OK]/[INFO] lines
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-base/main/install.sh 2>/dev/null | bash 2>&1 \
    | grep -E '^\[(OK|INFO|WARN|ERROR)\]' | head -4
pause 3

# Step 2 — init
clear
echo
echo "  ❯ Drop the foundation into a new Next.js project"
echo
pause 2
echo '  $ claude-base init --preset nextjs ./my-app'
pause 1.5
claude-base init --preset nextjs --yes "${HOME}/work/my-app" 2>&1 \
    | grep -E '^\[(OK|INFO|WARN|ERROR)\]' | head -6
pause 3

# Step 3 — what we got
clear
echo
echo "  ❯ What landed on disk"
echo
pause 2
echo '  $ ls .claude/'
pause 1.5
ls -1 "${HOME}/work/my-app/.claude/" | sed 's|^|    |'
pause 4

# Step 4 — closing CTA
clear
echo
echo "  ❯ Next : cd ./my-app && claude"
echo
echo "  Then drive the 6-phase workflow with one command :"
echo "  /work:work-flow-feature \"add a /counter route\""
echo
# Emit a trailing event after each second so asciinema captures the read-time
# (idle silence at the END of a session is not recorded — events must occur)
for _ in 1 2 3 4 5 6; do sleep 1; printf "" ; done
echo "  github.com/christopherlouet/claude-base"
sleep 2
