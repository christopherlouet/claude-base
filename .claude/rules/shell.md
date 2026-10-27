---
paths:
  - "**/*.sh"
  - "**/*.bash"
  - "**/*.bats"
---

# Shell Rules

## Strict mode

- Start every executable script with `#!/usr/bin/env bash` and `set -euo pipefail`
- Do NOT set it in a library meant to be sourced: it would change the caller's shell
- Know its gaps — they fail silently:
  - `set -e` is ignored inside `if`, `while`, `&&`/`||` lists and functions called from them
  - `local x=$(cmd)` returns the status of `local`, not of `cmd`: declare first, assign on a second line
  - without `pipefail`, a pipe's status is its LAST stage's

```bash
# Correct: the failure of cmd is not masked
local out
out=$(cmd)
```

## Quoting and expansion

- IMPORTANT: quote every expansion: `"$var"`, `"$@"`, `"${arr[@]}"`
- Guard a variable used in a destructive path: `rm -rf -- "${dir:?}/build"`
- Put `--` before arguments that may start with a dash
- Use arrays, not strings, to build a command line
- Prefer `[[ ]]` over `[ ]` in bash; `(( ))` for arithmetic

## Portability (macOS ships bash 3.2)

A script that passes on Linux (bash 5, GNU tools) can fail only on macOS.

| Avoid on bash 3.2 | Use instead |
|-------------------|-------------|
| `declare -A` (associative arrays) | parallel arrays, or a `case` |
| `mapfile` / `readarray` | `while IFS= read -r line; do …; done` |
| `${x,,}` / `${x^^}` | `tr '[:upper:]' '[:lower:]'` |
| `"${arr[@]}"` on an empty array under `set -u` | `${arr[@]+"${arr[@]}"}` |
| `local -n` (nameref), `${x@Q}` | pass names explicitly, `printf %q` |

GNU and BSD tools differ too: `sed -i` (BSD needs `-i ''`), `readlink -f`, `date -d`, `grep -P`.
Prefer POSIX options, or detect the variant.

## Errors and cleanup

- Error messages go to stderr (`>&2`), with a non-zero exit code
- Temporary files: `mktemp`, removed by `trap 'rm -rf -- "$tmp"' EXIT`
- `cd dir || exit 1` — never a bare `cd`
- Guard an optional tool: `command -v tool >/dev/null 2>&1 || { echo "tool missing" >&2; exit 1; }`

## shellcheck

- IMPORTANT: run `shellcheck` on every script before committing
- Fix the finding; disable one only inline, with the reason: `# shellcheck disable=SC2034  # read by the caller`

## Tests (bats)

- `run cmd`, then assert `$status` and `$output`
- IMPORTANT: a `[[ ]]` or `! cmd` that is NOT the last line of a test does not fail it on every bash: end it with `|| false`
- Make a script testable by sourcing: `[[ "${BASH_SOURCE[0]}" == "$0" ]] && main "$@"`
- Stub external commands with a fake on `PATH`, never the real network or service
- Each test gets its own temp dir, created in `setup`, removed in `teardown`
- A test that asserts an ABSENCE needs a control that proves the presence is detectable

## Anti-patterns

- Parsing `ls` output (use globs or `find -print0`)
- `eval` on anything derived from input
- `curl … | sh` (download, verify, then run)
- Unquoted `$var` in `rm`, `cp`, `mv`, `[ ]`
- `cat file | grep` and other useless pipes in hot loops
