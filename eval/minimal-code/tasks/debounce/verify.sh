#!/usr/bin/env bash
# verify.sh <solution-dir> — exit 0 iff the debounce solution is correct.
set -euo pipefail
sol="${1:?usage: verify.sh <solution-dir>}"
command -v node >/dev/null 2>&1 || { echo "node required to verify the debounce task" >&2; exit 2; }
exec node "$(dirname "$0")/verify.mjs" "$sol"
