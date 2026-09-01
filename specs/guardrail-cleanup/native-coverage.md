# Phase 3 — native coverage, demonstrated

**What this file is.** EF-015 forbids removing a guardrail because "the platform now does it".
The overlap has to be *shown on this repository*: disable the guardrail, trigger the real case,
observe what actually happens. EF-016 adds the other half — a demonstration that cannot be staged is
recorded **unproven**, and unproven items are **kept**.

**Why the rule is written that way.** On the day it was decided, two of this repository's own
comments asserted the opposite of what the tool actually did. Every row below therefore says which
of its claims was *measured* and which was *derived*, and derived claims name the measurement they
lean on.

Dated **2026-09-01**. Phase 3 had never been run; the record said so, which is why it is being run
now rather than concluded from the outside.

---

## T201 — the candidates, and where the suspicion comes from

| # | Guardrail | Suspected of being covered by | Source of the suspicion |
|---|---|---|---|
| 1 | `command-validator.sh` | the **29 native `permissions.deny` rules** in `.claude/settings.json` | the file itself: the deny list names `rm -rf /`, `sudo`, `dd if=`, `mkfs`, `chmod 777` — the guardrail's own subject matter. Never enumerated by Phase 1, which counted four sources and not this one |
| 2 | `destructive-ops.sh` | same deny list (`git reset --hard`, `git clean -fd`, `rm -rf …`) | same |
| 3 | `config-protection.sh` | the platform refusing config-weakening edits | `inventory.md` names it "a strong Phase 3 candidate" |
| 4 | `bash-write-guard.sh` | native permission prompts on Bash | its own entry: the harm it prevents is a write the permission layer also sees |
| 5 | `main-branch-guard.sh` | the harness's own instruction to the model | this session's system prompt: *"Commit or push only when the user asks. If on the default branch, branch first."* |
| 6 | `secret-scan.sh` | the CI secret scanning | `.github/workflows/ci.yml` runs gitleaks; a downstream `--ci` install ships secret scanning in two workflows |
| 7 | `pre-commit-tests.sh`, `pre-push-ci.sh`, `pre-deploy-build.sh` | the git hooks and CI | `pre-commit-tests.sh`'s own header: *"The git pre-commit hook and CI remain the backstops."* |
| 8 | `.husky` chain + `preflight` (~9 gates) | the CI workflows it mirrors | `.husky/pre-push`'s own header: *"Mirrors .github/workflows/ci.yml"* |

Candidate 1 is the one that mattered: it was the only plausible route by which the pass could have
removed anything, and it was invisible to Phase 1's enumeration.

---

## T202 — candidate 1: the native deny layer

### The instrument, proven capable of a positive first

A negative from a layer that never refuses anything proves nothing. Two harmless commands were run
as real tool calls before any conclusion was drawn:

| Command | Deny rule | Observed |
|---|---|---|
| `chmod 777 <probe dir>` | `Bash(chmod 777:*)` | **refused** by the platform |
| `eval echo hi` | `Bash(eval:*)` | **refused** by the platform |

The layer refuses. Negatives below are therefore real negatives.

### The arms

Every command is harmless: paths are throwaway probe directories or nonexistent, and `dd` writes to
`/dev/null`.

| Arm | Command | Rule that reads as covering it | Observed |
|---|---|---|---|
| 1 | `rm -rf <probe>/a` (an absolute path under `/`) | `Bash(rm -rf /:*)` | **allowed**, directory removed |
| 2 | `dd if=/dev/null of=/dev/null count=0` | `Bash(dd if=:*)` | **allowed** |
| 3 | `eval echo hi` | `Bash(eval:*)` | **refused** |
| 4 | `rm -rf node_modules` | `Bash(rm -rf node_modules:*)` | **refused** |
| 5 | `rm -rf /home/probe-nonexistent-xyz-9f2` | `Bash(rm -rf /:*)` | **allowed** |
| 6 | `dd if=/dev/zero of=/dev/null count=1` | `Bash(dd if=:*)` | **allowed** |

### What the arms establish

Arms 1 and 4 are the pair that decides it: **same binary, same flags**, opposite outcomes. The only
difference is where the deny rule's text stops. `rm -rf node_modules` ends at the end of a token;
`rm -rf /` ends *inside* one, because the real command continues the `/…` path.

> **Measured law: the native Bash deny matcher is token-boundary aware.** A rule whose prefix ends
> mid-token matches only its exact literal string, and never a longer command that continues that
> token.

Two independent rules on each side of the law (`chmod 777`/`eval` fire; `rm -rf /`/`dd if=` do not),
and one controlled pair on the same command word. That is the strongest form the evidence can take
without running something dangerous.

### The side finding: nine rules cover less than they read as

Applying the measured law to the 29 rules — **derived, not each separately staged**, because staging
the rest means running `mkfs` or writing to a disk device:

| Class | Rules | What they actually cover |
|---|---|---|
| Covers nothing | `dd if=`, `> /dev/sda`, `> /dev/nvme` | `dd if=` was **measured** never to match. The two redirections would need a command whose first token is `>` |
| Covers only the bare literal | `rm -rf /`, `rm -rf /*`, `rm -rf ~`, `rm -rf .`, `rm -rf ..` | exactly those five strings. `rm -rf /home/<user>` — a whole home directory — matches none of them (**measured**, arm 5) |
| Misses its own tool's normal form | `mkfs` | `mkfs.ext4` / `mkfs.xfs` are different tokens |

Nine of twenty-nine. This is the pass's dominant failure mode — a guard that *reports* more than it
has established — found this time in the **native** layer rather than in a foundation hook. And
`.claude/settings.json` ships to every installed project.

### Does the guardrail cover what the native layer misses?

Measured by feeding `command-validator.sh` a PreToolUse payload on stdin. Nothing was executed: the
payload is JSON, the observation is the hook's exit status (2 = refuse).

| Command | native deny | `command-validator.sh` |
|---|---|---|
| `rm -rf /` | matches (bare form) | **refuses** |
| `rm -rf /usr /etc` | no | **refuses** |
| `dd if=/dev/zero of=/dev/sda` | no | **refuses** |
| `mkfs.ext4 /dev/sda1` | no | **refuses** |
| `chmod 777 /etc/passwd` | **refuses** | **refuses** |
| `sudo rm -rf /var` | **refuses** | **refuses** |
| `git reset --hard HEAD~5` | **refuses** | allows |
| `git clean -fdx` | **refuses** | allows |
| `rm -rf /home/someuser` | no | allows |
| `ls -la`, `rm -rf ./build` (controls) | no | allows |

### T203 verdict — candidates 1 and 2

**NOT COVERED. Keep, and the keep is now demonstrated rather than pending.**

The two layers are **complementary, not redundant**: four destructive forms are refused only by the
hook, two only by the native rules. Removing `command-validator.sh` because "the deny list does it"
would have opened `dd if=…of=/dev/sda`, `mkfs.ext4`, and any multi-directory `rm -rf` — the exact
class Phase 2 had just widened it to catch.

One gap belongs to neither layer and is recorded rather than fixed here: **`rm -rf /home/<user>`
passes both**. Measured on a nonexistent path.

`destructive-ops.sh` (candidate 2) was probed with the same commands and refused none of them — but
that is **out of its regime**, not a negative: it guards destructive DDL and media/upload trees. In
regime it refuses `psql -c "DROP TABLE users"` and `rm -rf public/uploads`, and allows `ls -la`. The
native deny list contains **no SQL rule at all**, so there is nothing to be covered by.

---

## T202 — candidate 3 and 4: blocked, and the block is itself an observation

The protocol needs the hook disabled so the platform's own behaviour can be seen. Two attempts, two
different tools:

| Attempt | Target | Observed |
|---|---|---|
| Bash: write `SKIP_COMMAND_VALIDATOR=1` | `.claude/settings.local.json` (untracked) | refused by the auto-mode classifier |
| Edit tool: same change | `.claude/settings.local.json` | refused by the auto-mode classifier |
| Edit tool: remove three deny rules | `.claude/settings.json` (tracked) | refused by the auto-mode classifier |

> **Measured: the platform refuses to let an agent edit the settings that configure its own
> guardrails.** Three attempts, two tools, both settings files — the refusal is not specific to one
> file or one route.

This is a native capability the foundation does **not** have. Its nearest thing,
`base-integrity-check.sh`, is PostToolUse and explicitly non-blocking — it warns after the write
lands. So the direction of coverage is the reverse of the suspicion: the platform covers something
here that the foundation only reports on.

Two limits, both stated rather than smoothed over:

1. **It is regime-dependent.** The refusal came from the *auto-mode* classifier. A session running
   with ordinary permission prompts would prompt, and a maintainer would approve. Coverage that
   exists in one regime and not another cannot retire a guardrail that runs in both.
2. **It blocks the demonstration.** Candidates 3 and 4 (`config-protection.sh`,
   `bash-write-guard.sh`) cannot be staged without that write.

**T203 verdict — candidates 3 and 4: UNPROVEN → kept** (EF-016). What would settle it: the
maintainer setting `SKIP_CONFIG_PROTECTION=1` / `SKIP_BASH_WRITE_GUARD=1` themselves, then a staged
edit to a lint config and a Bash write to a tracked file, observing whether anything refuses.

---

## T202 — candidate 5: `main-branch-guard.sh`

The harness's own system prompt instructs the model: *"Commit or push only when the user asks. If on
the default branch, branch first."* That is a real overlap in intent.

It cannot be demonstrated by **this** reader. An instruction in a prompt is documentation of intent;
whether the model follows it under load is a behavioural question, and the only valid observer is
one that does not already know the guardrail exists. That is the same disqualification T602 ran
into, and it was resolved there by a fresh agent with no context.

**T203 verdict: UNPROVEN → kept.** What would settle it: an agent with no knowledge of the guard,
asked to make a commit on `main` with the hook disabled, observed for whether it branches first.

---

## T202 — candidate 6: `secret-scan.sh` vs CI secret scanning

Measured: the foundation's CI runs a dedicated gitleaks job, and a downstream `--ci` install ships
secret scanning in two of its six workflows (`ci.yml`, `security.yml`).

The overlap is real, and it does not matter. CI fires **after the push**. On a public repository the
secret is published by the time the job starts, and `git rm` fixes the tree, not the history. The
hook refuses the *write*; CI reports the *publication*. Under EF-013 — friction is spent against the
permanent — a post-publication detector cannot retire a pre-write refusal.

**T203 verdict: NOT COVERED for the harm that decides it → keep.**

---

## T202 — candidate 7: the three "keep — pending" test/build gates

`pre-commit-tests.sh`'s header states the backstops: *"The git pre-commit hook and CI remain the
backstops."* Measured against the actual files:

| Claimed backstop | What it actually runs |
|---|---|
| this repository's `.husky/pre-commit` | private-names check, derived-counts self-heal, `lint-staged` — **no test run** |
| a downstream project's `.husky/pre-commit` | `lint-staged` only, and only when `npx` **and** `package.json` are present |
| CI | the full suite — but after the push |

So the first named backstop does not exist: no git hook runs the test suite, here or downstream.
Only CI does, and only post-push.

**T203 verdict: NOT COVERED → keep**, for all three. The pending is resolved on the coverage
question.

⚠️ It is **not** resolved on the other question `inventory.md` raises about the same three: they are
*not exercisable on this repository* (bats rather than `npm test`, no build, no lint config to
weaken). That is a separate open item about where their value can be observed at all, and Phase 3
does not close it.

---

## T202 — candidate 8: `preflight` and the `.husky` chain vs CI

`preflight --fast` runs five gates. Each was matched against the CI workflows:

| preflight gate | Command | CI equivalent |
|---|---|---|
| shellcheck | `shellcheck -S warning …` | `ci.yml` → "Run ShellCheck" |
| counts | `scripts/validate-counts.sh` | `ci.yml` → "Validate documentation counts" |
| conflicts | `scripts/check-conflict-markers.sh` | `ci.yml` → "Conflict markers (tracked files)" |
| manifest | `bats tests/manifest-hooks-coverage.bats` | `ci.yml` → the sharded bats suite includes it |
| structure | `bats tests/policy-structure.bats` | same |

**Five of five are duplicated.** This is the first entry in the whole pass whose removal would lose
no coverage — only the local feedback before a push, which is the stated reason it exists.

Two facts that bear on the decision and are recorded here rather than argued:

- preflight **exits 1** when a gate fails, so `.husky/pre-push` does refuse a red push. It exits **0**
  when a gate could not run (tool absent), by an explicit design choice — CI is authoritative — and
  it withholds the success line in that case (#515).
- The harm it prevents is a red CI and a wasted merge slot: **recoverable**. Under EF-012 that is
  the class the spec says friction should not be spent on.

**T203 verdict: COVERED (by CI, demonstrated).** The removal decision is the maintainer's, and it is
a decision about local feedback, not about coverage. Recorded as a candidate; not executed here,
because Phase 4 closed and executing a removal from Phase 3 would skip the deciding step.

---

## Summary

| # | Guardrail | Verdict | Consequence |
|---|---|---|---|
| 1 | `command-validator.sh` | **not covered** (measured) | keep — was "pending", now demonstrated |
| 2 | `destructive-ops.sh` | **not covered** — no SQL rule exists natively | keep |
| 3 | `config-protection.sh` | **unproven** — platform blocks the demonstration | keep (EF-016) |
| 4 | `bash-write-guard.sh` | **unproven** — same block | keep (EF-016) |
| 5 | `main-branch-guard.sh` | **unproven** — needs an observer without this context | keep (EF-016) |
| 6 | `secret-scan.sh` | **not covered** for the irreversible harm | keep |
| 7 | the three test/build gates | **not covered** — the named git-hook backstop does not run tests | keep; the *exercisability* question stays open |
| 8 | `.husky` + `preflight` | **covered** — 5/5 gates duplicated in CI | first genuine removal candidate; maintainer's call |

**What Phase 3 changes about the pass's headline.** "Zero removals" was previously an untested
result. It is now tested: seven of eight candidates are demonstrably not covered or unprovable, and
**one is covered**. The pass's finding is no longer "nothing was a candidate" — it is "one candidate
survives the demonstration, and it is about duplicated local feedback rather than about a guard that
does not earn its place".

**What Phase 3 found that it was not looking for.** Nine of the 29 native deny rules cover less than
they read as, and a defect in `init --hooks` that refused every commit in a freshly installed
project — recorded in `inventory.md` and fixed under its own commit, since Phase 4's EF-011 freeze
ended with the pass.
