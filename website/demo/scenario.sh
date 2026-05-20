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

# Visible prompt for the recording — keep it short.
export PS1='\[\e[36m\]demo\[\e[0m\]:\[\e[33m\]\w\[\e[0m\] $ '

pause() { sleep "${1:-0.6}"; }

clear
pause 0.5
echo "# Step 1 — install the foundation"
pause 0.8

set -x
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-base/main/install.sh | bash
{ set +x; } 2>/dev/null
pause 1.2

clear
echo "# Step 2 — drop the foundation into a new Next.js project"
pause 0.8

set -x
claude-base init --preset nextjs --yes ${HOME}/work/my-app
{ set +x; } 2>/dev/null
pause 1.2

clear
echo "# Step 3 — what we got on disk"
pause 0.6
set -x
tree -L 2 ${HOME}/work/my-app/.claude
{ set +x; } 2>/dev/null
pause 1.5

clear
echo "# Now drop into Claude Code and let the workflow drive your feature :"
echo ""
echo "    cd ./my-app && claude"
echo "    > /work:work-flow-feature \"add a /counter route\""
echo ""
echo "# Explore → Specify → Plan → TDD → Audit → Commit"
echo "# All wired up. github.com/christopherlouet/claude-base"
pause 2.5
