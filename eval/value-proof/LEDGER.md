# Deterministic-gates value ledger

The **deterministic** family of guardrails (those that block an *action* rather
than nudge the model) does not need — and cannot honestly use — an A/B. Their
value is provable two ways:

- **By construction** — once the gate exists, the failure mode it targets cannot
  recur for the same reason. This is a logical guarantee, not a measurement.
- **By recurrence history** — where the failure *actually happened* before the
  gate, git/CI history is the evidence. This is the strongest claim and the one to
  prefer; where it's absent, the gate is **preventive** and we say so.

Each row is graded by evidence strength. No row claims more than its evidence.

| Gate | Failure mode it removes | Evidence | Grade |
|------|-------------------------|----------|-------|
| **Counts self-heal** — `.husky/pre-commit` → `scripts/sync-counts.sh` (#408, `ea7d988c`) | Adding a test/command/agent/skill bumps the canonical count but the derived markers (`counts.json`, README/docs) are forgotten → the CI counts gate fails after push. | **Recurrence-proven.** The #408 commit body documents this as a *recurring* CI failure; root cause was three-fold (stale absolute `core.hooksPath` from the `claude-socle`→`claude-base` rename disabling all git hooks; CI-only validation = late feedback; a hand-maintained derived artifact). Self-heals at commit time now → cannot drift into CI for that reason. | **Strong** (real recurrence + construction) |
| **Pre-push preflight** — `.husky/pre-push` → `scripts/preflight.sh` (#412, `2f3aea6e`) | A push fails CI on a gate that *could* have been run locally (counts, lint, bats), costing a red CI round-trip. | **Construction + parity.** Runs the foundation's own CI gates locally before push (local↔CI parity). The class of "CI tells me something I could have known locally" is structurally removed; no per-incident count claimed. | **Medium** (construction; parity is the argument) |
| **Config-protection** — `scripts/hooks/config-protection.sh` (#410, `9189dd98`) | The agent "satisfies" a failing linter/formatter by **weakening its config** (disabling a rule, loosening `tsconfig`) instead of fixing the code — gaming the gate. | **Preventive, sourced.** Blocks edits that weaken an existing linter/formatter config. Sourced from `affaan-m/ecc` veille, verified and re-implemented. No recorded in-repo incident — value is by construction (closes a known gaming move). Advisory nudge, not a hard boundary. | **Medium** (construction; preventive) |
| **`--no-verify` / `-n` block** — command-validator CATEGORY 9 (#410, `9189dd98`) | The agent bypasses the whole pre-commit/pre-push gate stack with `git commit --no-verify`. | **Preventive, sourced.** Blocks the bypass (granular `SKIP_NO_VERIFY_CHECK` opt-out). Same provenance as config-protection. By construction the gate stack can't be silently skipped. | **Medium** (construction; preventive) |
| **Hook stdin-contract drift-guard** — `command-validator.bats` (#330/#331) | The 19 hooks had silently drifted to reading unset `TOOL_*` env vars instead of stdin JSON → every hook a silent no-op (caught downstream). | **Recurrence-proven.** The drift had already shipped and silently disabled the hooks; a regression test now fails if a hook reverts to the env-var contract. | **Strong** (real incident + regression test) |

## How to read this against "does claude-base lower P(change fails)?"

For this family the answer is an honest **yes, by construction** — each row
removes a *process/discipline* failure mode, model-independently. Two of the five
rows (counts self-heal, hook stdin-contract) are backed by a **real recurrence**,
not just a logical argument, which is the strongest evidence the project has on
the value question.

The honest caveat (carried from `foundation-value-question`): this is
**rigor-failure reduction, not reasoning-failure reduction**. These gates stop a
change from failing for *discipline* reasons (forgot to regen, gamed the linter,
skipped the hooks). They do **not** make the model reason better on a hard
problem. And the marginal gain over an *already-disciplined* native agent (one
that already runs tests + typecheck) is real but narrower than the gain over raw
vibe-coding — these gates close the gaps a disciplined human still forgets
(the rename that silently killed every hook is the canonical example).

The **content safety net** (substance gate) is the one family where a marginal
catch-over-native number is both cheap and meaningful — measured in `FINDINGS.md`.
The **advisory prose** family is REDUNDANT on Opus (`../rule-efficacy/`).
