# Adapter Contract — what a new harness shell must implement

> Status: specification only (CS-004). The only shipped shell today is the
> Claude Code one. This contract is written in neutral core/shell vocabulary;
> it deliberately names no third-party product.

A **shell** adapts one harness to the policy **cores** in `scripts/hooks/_core-helpers.sh` and `scripts/hooks/_policy-*.sh`. A shell owns exactly three responsibilities; everything else is core.

## 1. Input acquisition

The shell obtains the guard's plain input from its harness and passes it to the core as a string:

| Guard family | Core entry point | Plain input |
|--------------|------------------|-------------|
| Command guard | `validate_command <cmd>` | the shell command about to run |
| Destructive ops | `check_destructive_command <cmd>` | same |
| Write-target guard | `extract_write_targets <cmd>` → classify via `_sensitive-paths.sh` | same |
| Build gates | `is_git_commit_command` / `is_git_push_command` / `is_deploy_command <cmd>` | same |
| Secret gate | `scan_content_for_secrets <content>` (+ `scan_content_with_gitleaks`) | the content about to be written |
| Migration gate | `is_migration_file <path>` + `check_migration_content <content> <basename>` | target path + content |

How the harness delivers that input (stdin JSON, env, argv) is the shell's business and must never leak into a core.

## 2. Verdict translation

Every core verdict is data: **return 0 = allow (no output)**, **return 1 = deny, human-readable reason on stdout**. The shell translates:

- **Exit-code harnesses** (block = specific exit code, reason on stderr): print the reason to stderr and exit with the harness's block code. This is the shipped Claude Code behavior (`exit 2`).
- **JSON-verdict harnesses** (block = structured decision on stdout; a non-zero exit means *hook failure*, not deny): wrap the reason in the harness's deny JSON and exit 0. The core's reason string is the message field; nothing else changes.

A shell must never re-implement, extend, or filter a core's decision — if a verdict is wrong, fix the core (one representation).

## 3. Failure philosophy (missing core file)

Preserve each guard's documented lineage — a shell for a new harness must match it:

| Guard | Missing core behavior | Rationale |
|-------|----------------------|-----------|
| command guard, destructive ops | **fail closed** (block with recovery hint) | security guards: a missing file must never become a silent bypass |
| secret gate, migration gate | fail open (no-op) | edit-path gates must not wedge every edit on a broken install |
| build gates | fail open (no-op) | advisory; real CI is the backstop |

## Environment opt-outs (portable, part of the policy surface)

`SKIP_COMMAND_VALIDATOR`, `SKIP_NO_VERIFY_CHECK`, `SKIP_DESTRUCTIVE_CHECK`, `SKIP_SECRET_SCAN`, `SKIP_BASH_WRITE_GUARD`, `ALLOW_MAIN_EDIT`, `SKIP_PRE_COMMIT_TESTS`, `SKIP_PRE_PUSH_CI`, `SKIP_PRE_DEPLOY_BUILD`. Top-level SKIP checks live in shells; category-level ones (e.g. `SKIP_NO_VERIFY_CHECK`) live in cores.

## Install wiring

- Cores are flat `_`-prefixed files in `scripts/hooks/` (the installer copies `scripts/hooks/*.sh` with a flat glob — do not introduce subdirectories).
- Every new file must be listed in `scripts/lib/minimal-manifest.txt` (drift guards: `tests/manifest-hooks-coverage.bats`, `tests/policy-structure.bats`).
- A new shell must ship WITH its cores; `tests/policy-install.bats` shows the expected fresh-install self-application test to replicate.

## Reference tests

A new shell must keep two suites green:
1. the direct core suites (`tests/policy-*.bats`) — untouched, they define the policy;
2. a harness-contract suite for the new shell, mirroring what `tests/command-validator.bats` etc. do for Claude Code (envelope in, block-convention out), including the degraded modes (missing JSON tool, missing core file).

## Known limits (inherit, do not silently fix)

- Guards are best-effort anti-accident screens, not anti-evasion boundaries (obfuscation is out of scope by design).
- Shells that receive pre-parsed argv (token-based harnesses) may skip `strip_msg_values` — the payload-in-message false-positive class does not exist there. The cores still accept the raw string form.
