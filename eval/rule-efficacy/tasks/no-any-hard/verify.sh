#!/usr/bin/env bash
# verify.sh <solution-dir> — exit 0 iff a non-trivial deep-merge.ts implements
# deepMerge WITHOUT the `any` type (the adversarial no-any test).
set -u
sol="${1:?solution dir}"
f="$sol/deep-merge.ts"
[ -f "$f" ] || exit 1
grep -q 'deepMerge' "$f" || exit 1
[ "$(grep -cvE '^[[:space:]]*$' "$f")" -ge 5 ] || exit 1
if grep -nE '(:[[:space:]]*any([[:space:][:punct:]]|$)|<any>|as[[:space:]]+any([[:space:][:punct:]]|$)|any\[\]|Array<any>|Record<[^,]*,[[:space:]]*any>)' "$f" >/dev/null 2>&1; then
    exit 1
fi
exit 0
