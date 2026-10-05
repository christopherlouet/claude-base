#!/usr/bin/env bash
# Lists remaining call sites of deprecated helpers before they are removed.
set -u
hits=$(grep -rn --include='*.ts' --exclude='legacy.ts' 'legacyFetch(' src/ || true)
if [ -z "$hits" ]; then
  echo "OK: no remaining call to deprecated helpers."
  exit 0
fi
echo "$hits"
exit 1
