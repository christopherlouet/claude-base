#!/usr/bin/env bash
# verify.sh <solution-dir> — exit 0 iff the agent-chosen .ts filename(s) follow the
# typescript rule's kebab-case convention for service/util files. The agent CHOOSES
# the name (the task does not pin it), so this measures whether the rule steers an
# arbitrary convention the model would otherwise pick freely (PascalCase/camelCase).
set -u
sol="${1:?solution dir}"
found=0
shopt -s nullglob
for f in "$sol"/*.ts; do
    found=1
    base="$(basename "$f")"
    # kebab-case: lowercase alnum words joined by single hyphens, then .ts
    printf '%s' "$base" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*\.ts$' || exit 1
done
[ "$found" -eq 1 ] || exit 1
exit 0
