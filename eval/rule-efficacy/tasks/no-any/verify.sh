#!/usr/bin/env bash
# verify.sh <solution-dir> — exit 0 iff the solution COMPLIES with the typescript
# "no any" rule: a non-trivial config.ts that implements parseConfig WITHOUT using
# the `any` type. A missing/empty/stub solution is NOT compliant (it must actually
# do the task — otherwise "no any" is trivially satisfied by writing nothing).
set -u
sol="${1:?solution dir}"
f="$sol/config.ts"

[ -f "$f" ] || exit 1
# Must actually implement the task (non-trivial) — guard against an empty/stub win.
grep -q 'parseConfig' "$f" || exit 1
[ "$(grep -cvE '^[[:space:]]*$' "$f")" -ge 5 ] || exit 1

# Violation = the `any` type used in any of its common spellings.
if grep -nE '(:[[:space:]]*any([[:space:][:punct:]]|$)|<any>|as[[:space:]]+any([[:space:][:punct:]]|$)|any\[\]|Array<any>)' "$f" >/dev/null 2>&1; then
    exit 1
fi
exit 0
