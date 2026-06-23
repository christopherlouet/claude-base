#!/usr/bin/env bash
# verify.sh <solution-dir> — exit 0 iff the email-validate solution is correct.
set -euo pipefail
sol="${1:?usage: verify.sh <solution-dir>}"
command -v python3 >/dev/null 2>&1 || { echo "python3 required to verify the email-validate task" >&2; exit 2; }
exec python3 "$(dirname "$0")/verify.py" "$sol"
