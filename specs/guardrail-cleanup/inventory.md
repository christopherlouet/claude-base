# The record — every guardrail, both harms, one view

**Date**: 2026-08-29
**Phase**: 2 (US1, US2) — grading. Enumeration is [`enumeration.md`](./enumeration.md).
**Status**: the blocking Claude Code hooks are graded. The other tiers are listed and **explicitly
ungraded** — see *Not yet graded*, which says so rather than leaving a blank.

---

## How to read this

**Both harms are in the same view, deliberately.** The project already had a one-sided record:
`eval/value-proof/LEDGER.md` grades five gates by the harm they remove and has **no column for the
harm they cause**. Under that arithmetic every guardrail is a net gain by construction, so every
review reaches the same conclusion. That is the defect US2 exists to correct, and it is why the
*caused* column comes first in each entry below.

**The counts here are not the criterion (EF-014).** Prevented harm leaves no trace and caused harm
always does, so tallying the two columns is structurally biased against the guardrails that matter
most — the one protecting the only irreversible outcome in the set has *zero* recorded preventions
and *two* recorded blocks. There is no score column and no totals row, on purpose.

**Grades claim no more than the evidence beside them (EF-002).**

| Grade | Meaning |
|---|---|
| **A** | Prevented a failure that really happened — a dated occasion, named |
| **B** | Has fired; whether what it blocked was harmful is not recorded |
| **C** | Preventive: nothing it has prevented is recorded. Stated explicitly, never left blank |
| **D** | Never observed to fire in either direction — an instrumentation question, *not* a removal candidate |

**"none recorded" is written out** wherever nothing is recorded (EF-004). An empty cell must never
be readable as "none happened".

---

## The blocking Claude Code hooks

Ten scripts under `scripts/hooks/` that can refuse an action (`exit 2`).

| Guardrail | Grade | Harm prevented | Irreversible? | Harm caused — dated | Decision |
|---|:--:|---|:--:|---|---|
| `secret-scan.sh` | **C** | preventive, nothing recorded | **yes** — a published secret cannot be unpublished | **2026-07-08** (#449), **08-15** (#499), **08-25** (#508) — three | **keep** |
| `command-validator.sh` | **C** | preventive, nothing recorded | mixed — see entry | **2026-07-08** (#453), **07-12** (#469), **07-13** (#477), **08-15** (`yes \|`), **08-29** (throwaway clone) | **keep**, narrowed |
| `main-branch-guard.sh` | **C** | preventive, nothing recorded | no — a commit on the wrong branch is movable | **2026-08-29** (#501) branched the repo for edits outside its worktree | **keep** — see entry |
| `destructive-ops.sh` | **C** | preventive, nothing recorded | **yes** — an erased database or disk | none recorded | **keep** |
| `destructive-migration.sh` | **C** | preventive, nothing recorded | **yes** — a dropped column | none recorded | **keep** |
| `config-protection.sh` | **C** | preventive, sourced from external review; no in-repo incident | no — a weakened lint config is revertible | none recorded | **keep** — unproven, see [native-coverage](./native-coverage.md) |
| `bash-write-guard.sh` | **C** | **2026-08-31** — refused a Bash write to a tracked test file while on `main` | no | **2026-07-12** (#469) over-blocks in the Bash guards | **keep** — see entry |
| `pre-commit-tests.sh` | **C** | preventive, nothing recorded | no — a failing test is visible | none recorded | **keep** — not covered, demonstrated |
| `pre-push-ci.sh` | **C** | preventive, nothing recorded | no — a red CI is recoverable | none recorded | **keep** — not covered, demonstrated |
| `pre-deploy-build.sh` | **C** | preventive, nothing recorded | no | none recorded | **keep** — not covered, demonstrated |

**Phase 3 ran on 2026-09-01** and these four are no longer pending — see
[`native-coverage.md`](./native-coverage.md). Three are kept because the backstop their own header
names does not exist: no git hook runs the test suite, here or downstream, so only CI does and only
after the push. `config-protection.sh` is kept as **unproven**, which EF-016 treats as a keep: the
platform refuses to let an agent disable its own guardrails through the settings file, which blocks
the very demonstration the rule demands. That refusal was measured twice, through two different
tools, and is itself recorded as native coverage the foundation does not have.

---

## Entries needing more than a row

### `secret-scan.sh` — the clearest case for EF-013, and the clearest illustration of EF-014

Grade **C**: nothing it has prevented is recorded. **Three** caused-harm episodes are — and the
first version of this record found only one, which is worth admitting because the correction makes
the entry harder, not easier, to defend:

| Date | Episode |
|---|---|
| 2026-07-08 (#449) | a false block on correct content |
| 2026-08-15 (#499) | it scanned the working directory instead of the staged change |
| 2026-08-25 (#508) | it read a *broken* scanner as a *found secret* — refusing on its own failure |

**By the counts alone this guardrail loses badly: zero preventions against three blocks.** That is precisely
the arithmetic EF-014 forbids, and this entry is why the prohibition exists. The harm it guards
against — a secret published to a public repository — **cannot be undone**: revocation is possible,
but the value is already out, mirrored and cached. EF-013 is unambiguous: irreversible keeps it.

Related, and instructive: the repository's own history contains a leak this guard could not have
caught — a homelab host and private address sat in a spec for two months (2026-06-12 → 08-23),
because a spec *documenting a deployment target* looks like doing the job well, and an RFC1918
address is not a secret to a secret scanner. That is not evidence against `secret-scan.sh`; it is
evidence that its coverage has a shape, which the record should carry.

### `command-validator.sh` — five recorded blocks, and still a keep

The most-corrected guardrail in the set: five dated episodes of blocking legitimate work.

| Date | Episode | Resolution |
|---|---|---|
| 2026-07-08 | CATEGORY 9 (`--no-verify`) matched too broadly (#453) | segment-scoped |
| 2026-07-12 | over-blocks in the Bash guards (#469) | common forms unblocked |
| 2026-07-13 | false positives on install commands (#477) | narrowed |
| 2026-08-15 | the loop guard shipped a literal that refused `echo YES \|\| echo NO` | pattern fixed |
| 2026-08-29 | refused `git commit --no-verify` inside a throwaway clone whose hooks were already removed | flag was unnecessary |

**Why it stays despite the worst caused-harm column in the set.** Its categories are not one
guardrail but many, and they do not share a harm class: `rm -rf` on a protected path and a sudo
escalation are **irreversible**; a `--no-verify` bypass is **recoverable**. EF-012 requires saying
which case the classification refers to, so this entry is explicitly *mixed*, and the irreversible
categories carry the keep. The 2026-08-15 episode is also the foundation's own documented precedent
for measuring a pattern change against the corpus before widening it.

The recurring shape of these five is worth stating: **every one was a pattern too broad, none was
the guardrail being wrong to exist.** That is a tuning history, not a value question.

### `main-branch-guard.sh` — recoverable harm, one recorded block, and still a keep

By EF-013's letter this is the entry that should go: the harm it prevents is **recoverable** (a
commit on the wrong branch can be moved), and it has a recorded block against it — this morning
(#501), where it branched the repository for edits made entirely outside its worktree.

**It is kept, and EF-013 requires the departure to be argued.** Two reasons:

1. **The block was a scoping defect, and it is fixed.** The guardrail was firing on the *tool*, not
   the *path*. After #501 it fires only on edits to the repository it guards. The recorded harm is
   not a standing property of the guardrail; it is a bug that has been removed and pinned by tests.
2. **"Recoverable" understates it in the agentic case.** A human notices a commit on `main`
   immediately. An agent working unattended can accumulate a series of them, and the recovery is a
   history rewrite on a **public** repository — which the project has already decided, on a separate
   occasion, not to do. Recoverable-in-principle is not recoverable-in-practice here.

This departure is recorded rather than silently taken, per EF-013.

### `bash-write-guard.sh` — a departure this record took without arguing it

**This entry exists because the pass failed to write it.** The row above reads recoverable harm, one
dated over-block (#469), decision *keep* — which is EF-013's letter pointing at removal, and EF-013
requires any departure to state its reason. No reason was stated anywhere. The independent
read-through (T602) found it as the one row where the pass applied its own rule without following
it: a single unflagged departure sitting in a table full of correctly flagged ones.

**The keep is argued now, from evidence dated after the pass.** On 2026-08-31 the guardrail refused
a Bash heredoc appending to `tests/doctor.bats` while the session was on `main` — a tracked file, an
interpreter write, the exact shape a `>` or `sed -i` matcher does not see. The work moved to a branch
and proceeded. That is one recorded prevention against one recorded over-block, and it is the class
of write that escapes every narrower matcher.

**What that does not settle.** One prevention is not a pattern, and the harm it prevents remains
recoverable in principle. The honest grade is the same departure `main-branch-guard.sh` takes and for
the same reason — recovery on a public repository is a history rewrite, and an unattended agent
accumulates the damage faster than a human notices it. Recorded rather than silently taken, per
EF-013, and dated so it can be re-judged.

### `config-protection.sh` — preventive and *sourced*, which is a grade of its own

`eval/value-proof/LEDGER.md` grades it **"Preventive, sourced"**: it blocks the move where an agent
satisfies a failing linter by weakening the linter's config rather than fixing the code. There is
**no recorded in-repo incident**, and the ledger says so plainly. Its provenance is an external
review, verified and re-implemented.

Kept for now. It is a strong Phase 3 candidate: if the platform now refuses config-weakening edits
natively, that must be **demonstrated on this repository** (EF-015), not read.

### `destructive-ops.sh` and `destructive-migration.sh` — grade C, zero blocks, irreversible

Neither has a recorded prevention **or** a recorded block. Both guard **irreversible** outcomes: an
erased store, a dropped column.

Grade C with an empty caused column is the profile that looks like waste under a counting review and
is exactly what EF-014 protects. Note also the spec's edge case: *absence of recurrence cannot
distinguish "the guardrail works" from "the failure was never likely"*. This record claims the
former for neither — it says the evidence does not separate them.

**They do need a grade-D probe** (T105): has either ever fired, in either direction? If neither has,
the honest question is whether they run at all, not whether they are useful.

---

## T105 complete — and it produced a grade the scale did not have

The probe asked whether the guardrails with an empty incident record ever fire. Running it properly
took three attempts, and each failure is more useful than the answer.

**Attempt one** was refused by the guardrail it was measuring: the probe's own command line carried
the payload it was testing for. **Attempt two** reported *five guardrails not firing*, which looked
like a devastating finding and was worth nothing — the instrument had never been shown capable of a
positive. Reading their tests explained it: those five are **conditional on project shape**.

**Attempt three** probes each one twice, with the condition absent and present:

| Guardrail | Condition absent — this repository | Condition present |
|---|---|---|
| `config-protection.sh` | passes | **refuses (2)** — the config file exists |
| `bash-write-guard.sh` | passes — an ordinary file | **refuses (2)** — an in-place rewrite of a real config |
| `pre-deploy-build.sh` | passes | **refuses (2)** — a deploy with a failing build |
| `pre-commit-tests.sh` | passes | **refuses (2)** — pinned by its own suite, green in CI |
| `pre-push-ci.sh` | passes | **refuses (2)** — same |

**All five are alive.** None is dormant, none is dead.

### The grade this produced: *not exercisable here*

The scale had A (prevented something real), B (fired, outcome unknown), C (preventive, nothing
recorded) and D (never observed to fire). These five fit none of them cleanly, and forcing them into
C would lose the reason.

They are **inert on this repository because it does not have the shape they guard**: claude-base
ships no eslint config to weaken, its test command is bats rather than `npm test`, and it has no
build to fail before a deploy. Their mechanism is demonstrated functional; their *value here* is
unmeasurable, because the failure mode they remove cannot occur here.

That matters for the decision, and it cuts the opposite way from how an empty column reads. These
five ship to the installed projects — which **do** have those shapes. Judging them by what happens in
this repository would be measuring them where they were never meant to fire, and the pass's own
criterion (does it earn its place?) has to be applied where the thing actually runs.

**Consequence for the record**: their rows keep the **keep — pending** decision, and the pending is
now specific. It does not depend on Phase 3's native-coverage demonstration alone; it depends on
whether their value can be assessed anywhere the maintainer can observe. That is an open question
this record states rather than resolves.

### The methodological point, which generalises past this pass

Three arms were needed before the measurement meant anything, and the first two were confidently
wrong in opposite directions — one refused to run, one produced a clean false alarm. *Five guardrails
do not fire* is exactly the kind of finding that reads as decisive and gets acted on. Had it been
believed, this pass would have removed five working guardrails on the strength of a badly-shaped
probe.

---

## The spec's worst case, measured — `preflight` skips silently

The spec's argument rests on a claim: an unmaintained guardrail *"silently stops running while the
belief that it protects you remains"*. That claim was an argument. It is now a measurement.

`scripts/preflight.sh` runs five gates before every push. Its own header says a missing tool skips
its gate, and it defines a fallback that echoes `shellcheck absent - gate skipped`. The question was
never whether it skips — it says so — but whether the operator can **tell**.

Probed with a PATH mirroring the real one exactly (4 459 binaries) and removing a single tool, so the
only difference between the arms is the tool under study:

| Arm | Output | Exit |
|---|---|---|
| `shellcheck` present | `[preflight] shellcheck...` … `OK all fast gates passed` | 0 |
| `shellcheck` absent | `[preflight] shellcheck...` … `OK all fast gates passed` | 0 |
| control: absent **and** a real drift planted | `FAILED: counts`, naming file, line and both numbers | 1 |

**The two are indistinguishable.** The line `[preflight] shellcheck...` is printed either way, which
positively suggests the gate ran; the skip notice never reaches the output; the run announces
*"OK all fast gates passed"* when one of them did not execute at all.

The control matters: the remaining gates still bite, so this is not a broken script. It is a gate
that removed itself and left the reassurance in place.

**Not hypothetical.** The foundation's own conventions record that the GitHub **macOS runner ships no
shellcheck** — the same absence this probe simulates. Any contributor on a machine without it pushes
with that gate silently inert, reading a success line.

**Harm class: recoverable** — CI runs shellcheck on Linux and would catch what the local gate missed.
By EF-013's letter that argues for removal rather than repair. But the finding is not really about
shellcheck: it is about a **reporting contract**. A gate that cannot run should say so in the line it
already prints, and the run should not claim all gates passed. That is a repair, not a removal, and
it is the cheapest correction of the exact failure mode this entire pass was built around.

**Deferred to Phase 4, deliberately.** Repairing a guardrail before the record is complete is what
EF-011 forbids, and that discipline has held for six pre-existing findings today. This one is
recorded with its reproduction so the decision is taken on evidence.

### ✅ Repaired in Phase 4 — the reporting contract, not the skip

Decision: **repair, keep the skip non-blocking.** The measurement indicted the *silence*, not the
skip; a machine lacking a tool is still not blocked on it, because CI's Linux job is the
authoritative run. What changed is that a gate which cannot run can no longer be read as one that
passed:

- a missing tool no longer substitutes an `echo` that *succeeds* — it sets a skip reason, and the
  gate prints `[preflight] <gate>... SKIPPED (<tool> not installed)`;
- the skip notice goes to stderr **unconditionally**: `--quiet` may hide a pass, never a non-run;
- the run withholds `OK all <mode> gates passed` and prints instead which gates did not run, plus
  *"this is NOT a complete run"*;
- a failing gate no longer hides a skipped one — both are reported.

**Proven by mutation, not by reading.** Four mutants, each killed by the arm that should kill it and
by no other: dropping the skip summary, printing the success line anyway (the original defect),
routing the skip notice through `say()` so `--quiet` swallows it, and dropping the gate name from
the notice. The control arm — every tool present — is the one that runs first: it shows the
instrument can produce a positive before any absence is believed.

One arm was **hollow on its first version** and passed against the unrepaired script, because
`preflight` prints a line per gate either way; it now asserts the gate name and the skip notice on
the *same* line. That is the third hollow test caught in this pass by looking for one.

**What the repair does NOT reach — the exit code (added 2026-08-31, found by T602).** The before-table
above makes **Exit** a column; the after-state had none, and that omission hid a residual. Re-measured
with the same two-arm method — a mirror of the real `PATH`, **4,466 binaries**, one tool removed so
only that varies:

| arm | exit | `OK all fast gates passed` | notice |
|---|---:|---|---|
| full mirror (control) | **0** | present | — |
| minus `shellcheck` | **0** | **absent** (0 occurrences) | stderr only |

The repair holds where it was aimed: the success line is withheld and the non-run is announced. But
**the exit code is 0 in both arms**. Every caller that reads only `$?` — `.husky/pre-push` among them
— is exactly as blind to an incomplete run as it was before. That is deliberate (the skip is
non-blocking by design, CI's Linux job being authoritative), but it was never stated, and a reader
who checked the before-table's Exit column would have looked for it. The repair changed what a
*human* reads, not what a *script* reads.

**One consequence for the record itself**: every "the gates were green" statement in this repository's
history carries this caveat. Green meant *"no gate objected"*, which is not the same as *"every gate
ran"*. Nothing here suggests a specific past failure slipped through; it means the evidence cannot
rule one out, and the record should say that rather than imply the stronger claim.

---

## What the existing ledger already said, and where it stops

`eval/value-proof/LEDGER.md` grades five gates, and its vocabulary maps cleanly onto this scale:

| Ledger row | Ledger's evidence | Grade here |
|---|---|---|
| Counts self-heal (`sync-counts.sh`) | **Recurrence-proven** — a documented recurring CI failure | **A** |
| Hook stdin-contract drift guard | **Recurrence-proven** — the drift had already shipped and silently disabled every hook | **A** |
| Pre-push preflight | Construction + local↔CI parity | **C** |
| Config-protection | Preventive, sourced | **C** |
| `--no-verify` block | Preventive, sourced | **C** |

Two grade **A**s in the whole project, and both were found the same way: **something had already
silently broken**. The stdin-contract case is the sharpest — nineteen hooks had drifted to reading
unset environment variables instead of stdin, so every one was a silent no-op, and nothing noticed
until it was looked for. That is the failure mode this entire pass is built around.

**Where the ledger stops**: it has no caused-harm column at all. Adding one changes the picture for
`command-validator` (five blocks) and `main-branch-guard` (one) without changing either decision —
which is itself worth recording, because it means the two columns are not in competition as often as
feared.

---

## The CI tier — 29 named steps, of which ~16 gate a pull request

Decision D2 put these in scope: a CI step refuses a merge, so by the spec's own criterion it
qualifies. They also grade faster than the hooks, because CI failures leave a trace by construction —
which is itself a finding: **this is the only tier where prevented harm is visible at all.**

| Gate | Grade | Evidence | Harm caused — dated |
|---|:--:|---|---|
| **Conflict markers** (`ci.yml`) | **A** | Conflict markers were **committed to `README.md`** on 2026-07-08 (#449); the gate was created 2026-07-11 (#464), three days later, because of it | none recorded |
| **Counts gate** (`ci.yml`) | **A** | `eval/value-proof/LEDGER.md` records this as a *recurring* CI failure — add a resource, forget to regenerate, CI red after push | the serialisation cost measured in US4; addressed in #510 |
| **Gitleaks behaviour** (`ci.yml`) | **B** | It fires — the enforcing scan runs on `main` — but no recorded occasion where it caught a *real* secret in this repository | via the `secret-scan` hook it feeds: three episodes above |
| **ShellCheck** (`ci.yml`, `security.yml`) | **C** | preventive, nothing recorded | none recorded |
| **Bats shards** (Linux ×4, macOS ×4) | **A** | The authoritative run. It caught what a local run missed **today**: `substance-check` failing on this pass's own test file while the local suite was green | slow feedback only |
| **Validate counts / portability** (`ci.yml`) | **C** | preventive, nothing recorded | none recorded |
| **CodeQL / Security Scan** | **C** | preventive, nothing recorded | none recorded |
| **PR title format** (`pr-check.yml`) | **C** | preventive, nothing recorded | **2026-08-29**: refused `fix(security): CATEGORY 7 …` because the subject began with a capital. The change was correct and every test was green |
| **Commit messages / WIP / PR size** (`pr-check.yml`) | **C** | preventive, nothing recorded | none recorded |
| **Release, docs, dependabot steps** (13) | — | **not PR gates** — they run after a merge or on a schedule. Listed for completeness, outside the "refuses an action" criterion | — |

### What grading this tier actually showed

**Two grade As here, against two in the entire hooks tier** — and for the same structural reason. A
CI gate that fires leaves a run record; a hook that fires leaves nothing but an interrupted session.
The asymmetry is not evidence that CI gates are more valuable. It is evidence that **the hooks are
harder to credit**, which is exactly the bias EF-014 warns about, appearing here as a tier-level
effect rather than a per-entry one.

**The bats shards earned their A today**, in this very pass: the local suite was green and CI was
not. That is the single strongest argument in the record for keeping a slow, duplicated,
run-everything gate — the thing a "what earns its place?" review would be most tempted to trim.

**The PR-title gate is the tier's clearest cost.** It refused a correct, fully-green security fix
over a capital letter, and the repository's own memory records it rejecting a valid conventional type
on a previous occasion. Harm class: recoverable, trivially. It stays for now, but it is the one entry
in this tier where the caused column has something and the prevented column has nothing.

---

## Not yet graded

Listed so the record can say it examined everything, and stated rather than left blank (EF-004).

| Tier | Count | Why not yet |
|---|---:|---|
| Advisory `scripts/hooks/` scripts | 8 | graded by a different question — do they change what the assistant does? — which is Phase 6's criterion, not this one |
| Inline `settings.json` declarations | 31 | none can refuse (verified). They belong to the carried-cost question, Phase 6 |
| ~~`.husky` chain + `preflight` gates~~ | ~~~9~~ | ✅ **graded and decided 2026-09-01** — Phase 3 measured 5 of 5 fast gates duplicated in CI, the pass's only *covered* entry; kept, see [`decision-d3.md`](./decision-d3.md) |

**Every tier that can refuse an action is now graded.** The `.husky`/`preflight` chain was the last
one outstanding — measured but ungraded — and Phase 3 supplied the demonstration it was waiting for.
An earlier version of this sentence made the same claim while excepting a tier in the same breath, a
claim and its own counter-example one comma apart; it is stated without the exception now because
there is no longer one. The two tiers still listed above are graded by Phase 6's criterion — *does
this change what the assistant does?* — not by this phase's.

---

## The probe found a gap, not just an answer — bare-root deletion

T105 asked whether the guardrails with an empty record ever fire. Two answers came back, and the
second was not the question being asked.

**`destructive-ops.sh` and `destructive-migration.sh` are alive.** Both refuse inside their real
scope and pass their controls — dormant, not dead. `destructive-ops.sh` proved it the hard way: the
*first* attempt at this probe was blocked by the guardrail it was measuring, because the probe's own
command line carried the literal SQL it was testing for. Payloads now live in a file. That is a
sixth dated caused-harm episode, and the guard was right to fire.

**`command-validator.sh` does not cover deletion of the bare root.** Verified with the instrument
first shown capable of a positive — named system directories are all refused — and with controls
that must pass, which do (`./build`, `node_modules`, a real subpath under a system tree).

| Form | Guard | `rm` itself |
|---|---|---|
| bare root, recursive+force | **passes** | refuses — `--preserve-root` is the default |
| the same with `--no-preserve-root` | **passes** | protection explicitly disabled |
| bare root with a glob | **passes** | never applies — the shell expands it to the top-level dirs |
| several system directories in one command | **passes** | — |
| the glob form under `sudo` | refuses | — |

The pattern at `scripts/hooks/_policy-dangerous-commands.sh:167` requires a **named** directory after
the slash, so the bare root falls through. And a single system directory is refused while the same
directory listed *after another one* is not: only the first path following the flag group is
examined. Without `sudo`, the three most destructive forms are uncovered.

Reproduce with the two-arm probe kept in the session scratchpad (positives, negatives, controls).

**Why this belongs in the record and not only in a fix.** The pass was built to ask whether
guardrails earn their place. Its first serious probe found an existing one with a hole in the single
most irreversible failure mode in the set. That is not an argument against the pass — it is the
strongest argument for it. An empty incident column had been reading as "quiet"; it was partly
reading as "never tested".

**Harm class: irreversible. Closed in #513** (`21c97b30`), with the corpus delta measured at 656/10 before and after — identical. EF-012/013 place this at the top of the keep ladder. Closing the gap was
a repair to an existing guardrail rather than a new one, but it is still a deliberate widening of a
detector pattern — which this repository requires to be measured against its own command corpus
before and after (`scripts/validator-corpus.sh`), since a refusal there is a self-contradiction.
**That measurement is the gating step, not the regex.**

**A seventh caused-harm episode, from writing this very section**: the guard refused the edit that
documents its gap, because the text carried the patterns it scans for. Recorded because it is the
same shape as the `validate-counts` false positive earlier today — a document *quoting* a guard is
indistinguishable, to that guard, from a document *violating* it.

---

## A verdict that was not deterministic — found by being wrong about it

Recorded because it nearly produced a false conclusion: a macOS CI job failed on
`audit-docs: real foundation repo exits 0 with no drift` for a pull request whose diff **cannot
reach that scanner** — it touches neither the directories `audit-docs.sh` scans nor anything it
reads. Re-running the identical commit passed. Two arms on the same code: **the verdict was
non-deterministic**, which is the same defect as a guardrail reporting what it has not established,
one level up.

**The mechanism, and exactly how far the evidence goes.** Two cases in `tests/audit-docs.bats`
planted their drift **in the shared checkout** — a file under `templates/`, an appended line in
`README.md` — and removed it afterwards, while a third case audits that same checkout, and the suite
runs `bats --jobs`.

| Arm | Result |
|---|---|
| plant window widened, run concurrently | the clean-repo case fails **deterministically** |
| real window, maximal concurrency, 32 runs here | **0 failures** — it did not reproduce |
| checkout sampled while the planting cases run (before) | modified in **71 of 268 samples** |
| same sampling (after the repair) | **0 of 281** |

So: the coupling is **demonstrated**, the non-determinism is **established**, and the claim that this
race caused that particular macOS red is **unproven** and written as such. The repair does not rest
on it — a test mutating shared state while the suite runs in parallel is a hazard whether or not it
has bitten yet, and the fix costs nothing the tests were relying on: they now plant in a
foundation-shaped copy with `audit-docs.sh` inside it, so the **default scope** is still what gets
exercised. Only the root moves.

⚠️ **The instrument was wrong first.** The initial sampler reported the repaired code as *worse*
(121 dirty of 121) because it read `git status` unscoped, and the working tree already carried the
repair itself. A measurement that indicts the fix is a reason to check the instrument before
believing it.

## Open, and carried forward

- **The grade-D probe (T105) is complete.** Every blocking guardrail is alive; none is dormant. It
  also surfaced the bare-root gap, now closed (#513), and produced a grade the scale did not have —
  *not exercisable here* — for the five that are conditional on project shape.
- **`preflight`'s silent skip is measured, not suspected** — see the section above. The remaining
  question is the reporting contract, and it is Phase 4's to decide.
- **Portability (T106, EF-007)**: recorded from evidence already in hand only. For every entry
  above: **not measured**. No work is opened to find out.

---

## How the pass ended — read this first if you were not here

A cleanup that removed nothing. That is the finding, not an apology for one.

**What it did.** Enumerated everything in this repository that can refuse an action, from all four
sources — 29 CI gates, 18 hooks (10 blocking, 8 advisory), 31 inline declarations that no inventory
had ever listed, 3 git hooks. Graded every tier that refuses. Repaired seven defects. Removed zero.

**What it found, and it is one thing wearing five costumes.** A guardrail can fail by reporting more
than it established, and every repair but two was that:

| | What it claimed | What was true |
|---|---|---|
| `preflight` | *"OK all fast gates passed"* | one gate had not run at all |
| the marker gate | no drift | 87 of 147 markers were being checked; stripping all of them left it green |
| `tests/ci-workflows.bats` | pins every input class | asserted a word in a prose comment; killed 1 of 5 mutations |
| a macOS CI job | a red on a specific PR | non-deterministic — the same commit passed on re-run |
| `substance-check` | *"empty test body"* | the test had four lines; a brace in a comment closed the block early |

**What it cost to be sure.** Five hollow assertions were caught in this pass by mutation, none by
reading — including two in the author's own new tests, one where a *mutation that did not mutate*
looked exactly like a guardrail that does not catch, and one where a test helper read a documented
example instead of the real thing. The technique kept paying because **a test that cannot fail looks
exactly like a test that passes**.

**What it deliberately did not do.** No removal without demonstrated native coverage. **Phase 3 was
finally performed on 2026-09-01** — see [`native-coverage.md`](./native-coverage.md) — after two
earlier versions of this line got it wrong in opposite directions: the first reported an unrun phase
as a finding ("Phase 3 never became necessary"), the second correctly called zero removals
*untested*. It is tested now. Eight candidates, of which **seven are demonstrably not covered or
unprovable and one is covered**: the `.husky`/`preflight` chain, whose five fast gates all have a CI
equivalent. So the pass does have a removal candidate after all, and it is about duplicated local
feedback rather than a guard that fails to earn its place. The decision is the maintainer's; Phase 3
records, it does not retire. No behavioural verdict on carried material, because
that eval's generation half is billing-gated and no run was authorised. No drift guard on this
record — see [`decision-d1.md`](./decision-d1.md); the harm is recoverable, an existing command
re-derives the truth, and the guard would have to be fed before any new guardrail could land.

**What is still open.** Three demonstrations Phase 3 could not stage, each kept per EF-016 and each
with the observation that would settle it named in `native-coverage.md`: `config-protection.sh` and
`bash-write-guard.sh` (the platform blocks the disable the protocol requires — only the maintainer
can set those variables), and `main-branch-guard.sh` (needs an observer who does not already know
the guard exists). Whether the three test/build gates can have their value observed *anywhere the
maintainer can see it*, since this repository does not have the shape they guard.

Closed since: the `.husky`/`preflight` decision (D3 — kept); the three native deny rules that could
never fire, removed with a test pinning their *shape* rather than the list; and the one gap Phase 3
found without looking for it — `rm -rf /home/<user>` passed both layers, and now the hook refuses it
(corpus measured identical before and after, 648/10).
The largest carried item, `docs/reference/best-practices.md` at 23 %, mixes instruction with
reference and needs a content split rather than a frontmatter line. And `workflow.md` duplicates 7 of
its 13 anti-pattern bullets from `CLAUDE.md`, the two copies already drifting apart.

**The claim this record does not make**: that the foundation is now correct. It says what was
measured, when, and by which route — twice, where a number mattered.
