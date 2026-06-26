# Plan — Anti-tamper guardrails (config-protection + block-no-verify)

Spec: `specs/anti-tamper-guardrails/spec.md` · Branch: `feat/anti-tamper-guardrails`
Complexity: **Medium** (two small shell guardrails; risk concentrated in regex precision + settings.json wiring, not volume).

## Summary

Two PreToolUse guardrails that stop the agent from defeating claude-base's own
quality gates:
1. **config-protection** — a NEW hook blocking edits to *existing* linter/formatter
   config files (Edit|Write|MultiEdit).
2. **block-no-verify** — a NEW category in the EXISTING `command-validator.sh`
   blocking `git commit/push --no-verify` (and `-n`).

## Technical context (verified)

- PreToolUse hooks register in `.claude/settings.json` as
  `{ "matcher": "...", "hooks": [{ "type":"command", "command":"bash \"$CLAUDE_PROJECT_DIR/scripts/hooks/X.sh\"", "timeout":5000, "onFailure":"block" }] }`.
  Existing precedent: the `command-validator.sh` block (matcher `Bash`).
- Hooks read the payload on **stdin as JSON**; `.tool_input.file_path` is the
  target for Edit, Write **and** MultiEdit (single field covers all three).
  `.tool_input.command` for Bash. (Lesson `hooks-read-stdin-not-toolenv`.)
- Block = `exit 2` with a `>&2` message (the model sees it). `onFailure:"block"`.
- `command-validator.sh`: `set -euo pipefail`, parses `.tool_input.command` →
  `CMD_LOWER` (lowercased, whitespace-collapsed), 8 `# === CATEGORY N ===` blocks,
  ends `# All checks passed / exit 0`. New category inserts before that exit.
- Counts: a NEW hook file does not change a counted total, but the NEW
  `tests/config-protection.bats` (and added cases in `command-validator.bats`)
  bump the test count. The #408 pre-commit self-heal now stages the regenerated
  markers automatically — but `validate-counts.sh` must still end green.
- shellcheck runs in CI on `scripts/` → new hook must be clean.

## Architecture

### config-protection.sh (new)
```
read stdin → file_path = .tool_input.file_path  (jq; fail-safe if jq absent)
SKIP_CONFIG_PROTECTION=1 → exit 0
empty file_path → exit 0
base = basename(file_path)
path under an excluded dir (tests/, fixtures, __fixtures__, examples/, node_modules/) → exit 0   # EC-2
base matches recognized config set? no → exit 0
target file does NOT exist on disk → exit 0   # first-time creation allowed (EF-002)
else → exit 2 with "fix the source, don't relax the config" message
```
Recognized set (EF-003): `.eslintrc`, `.eslintrc.{js,cjs,mjs,json,yml,yaml}`,
`eslint.config.{js,cjs,mjs,ts,mts,cts}`, `.prettierrc`,
`.prettierrc.{js,cjs,mjs,json,yml,yaml,toml}`, `biome.json`, `biome.jsonc`,
`ruff.toml`, `.ruff.toml`, `.markdownlint.{json,jsonc,yml,yaml}`.
EXCLUDED (EF-004 + clarifications): `pyproject.toml`, `tsconfig.json` — never matched.

### block-no-verify (new CATEGORY 9 in command-validator.sh)
```
git (commit|push) … --no-verify    → exit 2
git commit … -n  (standalone short flag, no-verify sense)  → exit 2
must NOT match: grep -n, git log -n 5, echo -n, a -m message containing "--no-verify"
```
Match in command position, not anywhere in the payload (EC-6).

## Files

### Create
- `scripts/hooks/config-protection.sh` — the new guardrail (US-1).
- `tests/config-protection.bats` — bats for US-1 / US-4 (TDD first).

### Modify
- `scripts/hooks/command-validator.sh` — add CATEGORY 9 (US-2).
- `tests/command-validator.bats` — add block-no-verify cases (US-2) (TDD first).
- `.claude/settings.json` — register config-protection PreToolUse (Edit|Write|MultiEdit).
- `docs/reference/hooks-reference.md` — Configured Hooks table row + env-var rows
  (`SKIP_CONFIG_PROTECTION`); block-no-verify folds into the existing Command
  validator row (note `--no-verify`).
- (auto via #408 pre-commit) `counts.json`, `README.md`, `website/docs/` — regenerated.

### Do NOT touch
- `pyproject.toml`, `tsconfig.json` handling (out of scope v1).

## Phases

1. **US-2 block-no-verify** (P1, smallest, isolated regex in an existing tested hook) — TDD.
2. **US-1 config-protection** (P1, new hook + wiring) — TDD.
3. **US-3 docs/disable** (P2) — hooks-reference rows; verify both SKIP_* toggles by test.
4. **US-4 false-positive resistance** (P3) — folded into US-1 tests (basename + excluded dirs).
5. **Audit** — shellcheck, full bats, validate-counts, settings.json sanity, `/qa:qa-loop "score 90"`.

## Risks & mitigations

| Risk | Mitigation |
|------|-----------|
| **`-n` false positives** (grep -n, git log -n 5, echo -n, bundled `-nm`) | Anchor `-n` to `git commit` context only; test all four negatives. Bundled `-nm` = documented v1 gap (rare); `--no-verify` always caught. |
| **`--no-verify` inside a commit -m message** blocks legitimately | Match the flag in command position, not a quoted message; add an EC-6 negative test. |
| **MultiEdit payload shape** — assumes `.tool_input.file_path` | Verify against a real MultiEdit payload before relying; if it differs, read the right field. Add a MultiEdit test. |
| **Test fixtures named like configs** (e.g. a `.eslintrc.json` fixture) get blocked | Exclude `tests/`, `**/fixtures/`, `**/__fixtures__/`, `examples/`, `node_modules/` by path (EC-2). |
| **jq absent** → silent bypass | Mirror command-validator's fail-safe (no jq → do not crash; for config-protection, no parse → allow, since blocking-all would break editing). Test the jq-absent path. |
| **settings.json mis-wiring** breaks the session | Validate JSON after edit; start a session / run the hook manually with a crafted stdin payload; keep `timeout` + `onFailure:"block"` like the precedent. |
| **Relative vs absolute file_path / cwd** for existence check | Resolve against `$CLAUDE_PROJECT_DIR` then cwd; test both a relative and absolute path. |
| Count drift | #408 pre-commit self-heals; still run `validate-counts.sh` in audit. |

## Verification (Boris Cherny loop)

- `bats tests/config-protection.bats tests/command-validator.bats` (TDD red→green).
- `shellcheck scripts/hooks/config-protection.sh scripts/hooks/command-validator.sh`.
- Manual: pipe a crafted JSON payload into each hook, assert exit code.
- `jq . .claude/settings.json` + full `./scripts/test.sh`.
- `/qa:qa-loop "score 90"` before PR.
