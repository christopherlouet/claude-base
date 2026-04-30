#!/usr/bin/env bash
# =============================================================================
# lock-glossary.sh — locks the glossary after Friday morning review (T025).
#
# Effects:
#   - Sets `locked_at: <today>` at top of glossary.yaml
#   - Sets `locked: true` on every term that doesn't have it
#   - Refuses to run if already locked, unless --force is passed
#
# Inputs:
#   GLOSSARY_PATH (env var) overrides the default glossary path.
#   --force allows re-locking after an explicit override.
#
# Usage:
#   lock-glossary.sh
#   lock-glossary.sh --force
#   GLOSSARY_PATH=/tmp/glossary.yaml lock-glossary.sh
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_GLOSSARY="$SCRIPT_DIR/../../specs/migration-fr-en/glossary.yaml"
GLOSSARY="${GLOSSARY_PATH:-$DEFAULT_GLOSSARY}"

FORCE=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --force) FORCE=true; shift ;;
        -h|--help) head -19 "$0" | tail -18; exit 0 ;;
        *) echo "Unknown arg: $1" >&2; exit 2 ;;
    esac
done

[[ -f "$GLOSSARY" ]] || { echo "Glossary not found: $GLOSSARY" >&2; exit 2; }

# ---------------------------------------------------------------------------
# Detect existing lock state via python (yaml is reliable)
# ---------------------------------------------------------------------------
already_locked=$(python3 <<EOF
import yaml
with open("$GLOSSARY") as f:
    d = yaml.safe_load(f) or {}
locked_at = d.get('locked_at')
print('true' if locked_at else 'false')
EOF
)

if [[ "$already_locked" == "true" && "$FORCE" != "true" ]]; then
    echo "[lock-glossary] FAIL: glossary is already locked. Use --force to re-lock." >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Apply lock via python (in-place, preserves comments best-effort)
# ---------------------------------------------------------------------------
today=$(date +"%Y-%m-%d")

python3 <<EOF
import yaml, re, sys

path = "$GLOSSARY"
today = "$today"

with open(path) as f:
    raw = f.read()

# Update locked_at field at top level. We rewrite using a structured approach.
data = yaml.safe_load(raw) or {}
data['locked_at'] = today
for t in data.get('terms', []):
    t['locked'] = True

# Write back. We use a header preserved from the original file (if any).
header_lines = []
for line in raw.splitlines():
    stripped = line.strip()
    if stripped.startswith('#') or stripped == '':
        header_lines.append(line)
    else:
        break

with open(path, 'w') as f:
    if header_lines:
        f.write('\n'.join(header_lines) + '\n\n')
    yaml.safe_dump(data, f, default_flow_style=False, sort_keys=False, allow_unicode=True)

print(f"[lock-glossary] Locked at {today}, {len(data.get('terms', []))} terms marked locked: true")
EOF

# ---------------------------------------------------------------------------
# Optional: create a git tag (only if running in a git repo and not in test)
# ---------------------------------------------------------------------------
if [[ -z "${GLOSSARY_PATH:-}" ]] && git -C "$SCRIPT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    tag="glossary-locked-$today"
    if ! git -C "$SCRIPT_DIR" rev-parse "$tag" >/dev/null 2>&1; then
        git -C "$SCRIPT_DIR" tag -a "$tag" -m "Glossary locked after T025 (Friday morning review)" 2>/dev/null \
            && echo "[lock-glossary] Created git tag: $tag" \
            || echo "[lock-glossary] Note: could not create git tag (may need manual stage/commit)"
    fi
fi

exit 0
