# What every session carries — measured, and graded by a different criterion

**Phase 6 of [`spec.md`](./spec.md) — US5.** This half of the pass is not about guardrails, and the
guardrail criterion must not be applied to it. Carried material has **no harm to prevent**: it earns
its place only by changing what the assistant does. Judging it by "does it prevent something" would
pass everything.

---

## The measurement

Eight files reach the assistant before it reads a single line of the repository. Measured against a
live session on 2026-08-29, and **re-measured by a second route** the next step of the pass — the two
agree to the byte:

| Item | Bytes | Share | Why it is carried |
|---|---:|---:|---|
| `docs/reference/best-practices.md` | 8 240 | 23 % | `@`-imported by `CLAUDE.md` |
| `.claude/rules/workflow.md` | 5 646 | 16 % | rule with no `paths:` → global |
| `.claude/rules/README.md` | 5 441 | 15 % | **no `paths:` → global, though it is a catalogue** |
| `CLAUDE.md` | 5 360 | 15 % | the project's own instructions |
| `.claude/rules/self-improvement.md` | 3 758 | 11 % | rule with no `paths:` → global |
| `.claude/rules/vendor-precedence.md` | 3 393 | 10 % | rule with no `paths:` → global |
| `docs/reference/project-structures.md` | 1 927 | 5 % | `@`-imported by `CLAUDE.md` |
| `.claude/rules/git.md` | 1 397 | 4 % | rule with no `paths:` → global |
| **Total** | **35 162** | | ~8 k tokens, every session |

For scale, the guardrails this pass spent four phases on — `scripts/hooks/*.sh`, 119 KB — are
**never carried**. They cost disk, not context. The spec's "four fifths of the cost" is about
context, and there the guardrails weigh approximately nothing.

## The carrying mechanism, demonstrated rather than assumed

A rule with a `paths:` frontmatter is conditional; one without is global. That is documented, and
documentation is not evidence — so it was observed in two arms **inside a live session**:

| Arm | Observation |
|---|---|
| the five rules **without** `paths:` | present in context from the first turn |
| `.claude/rules/testing.md` (**has** `paths:`) | absent at start — and **arrived mid-session**, the moment a `tests/*.bats` file was edited |

The second arm is the one that matters: it shows the conditional path actually fires, so "add
`paths:` and it stops travelling" is a demonstrated mechanism rather than a reading of the docs.

## What could be measured today, and what could not

**T504 names the instrument**: `eval/rule-efficacy/eval.sh`, whose verdicts are
EFFECTIVE / REDUNDANT / INERT / HARMFUL. Its scoring half is offline and tested; its **generation
half is manual and billing-gated** — two LLM arms per item, control and treatment. No such run was
authorised here, so **no behavioural verdict is claimed for any item below**. Recording that is the
task; opening a paid run to avoid writing it is not.

The prior result stands over everything here: rule efficacy is **model-dependent** (measured: an
Opus-class model found rules largely redundant, a Haiku-class one did not). A verdict obtained on one
model does not transfer, which is why the rules are also portability insurance and why "inert here"
never means "inert".

What *was* measurable without a model:

- **Textual duplication between carried items — small, and drifting.** A line-level comparison
  (normalised, deduplicated, lines over 25 characters, with a control pair that correctly returns
  zero) finds overlap only in the anti-pattern list: **7 of `workflow.md`'s 13 bullets are verbatim
  in `CLAUDE.md`**. Worse than the repetition: the two copies have already **diverged** — over-
  engineering appears in both under different wordings, and three of `CLAUDE.md`'s bullets are absent
  from the rule. That is the "same fact in two places" failure the foundation's own lessons name.
  A *semantic* redundancy claim would need the billing-gated eval and is not made.
- **Composition of the largest rule-side item.** `.claude/rules/README.md` is **83 % table rows**
  (4 513 of 5 441 bytes): a catalogue of the 32 rules and their target paths. The only content that
  tells the assistant to *do* anything is the priority ladder, at 1 266 bytes including its own table.

---

## Item verdicts

Each states its evidence class: **structural** (readable from the file and the mechanism),
**judgement** (argued, not measured), or **unmeasured**.

### `.claude/rules/README.md` — 15 % of the load, and it is not a rule

**Structural.** It is the *catalogue describing* the rules, not a rule. The rules it lists are
activated by the harness on their own; a session does not need the index to receive them. It is
carried for one reason only: it lacks a `paths:` frontmatter, and it lacks one because it is not a
rule and nobody thought to give a catalogue a scope.

It is, however, **load-bearing on disk** — three consumers read the file, and none needs it in
context:

| Consumer | What it needs | Affected by scoping? |
|---|---|---|
| `scripts/audit-base.sh` | every rule must be registered here | no — it reads the file, and skips `README` itself |
| `website/scripts/generate-rule-docs.ts` | builds the site index | no — it **skips** `README` and generates from the rule files |
| `scripts/validate-counts.sh` | `ACTUAL_RULES` | no — `README.md` is explicitly excluded |
| `tests/export-minimal.bats`, `tests/new-project.bats` | the four global rules it names must ship | no — content unchanged |

**Decision: scope it, and keep what instructs.** The catalogue becomes conditional on
`.claude/rules/**` — carried exactly when someone is working on the rules, which is when an index of
them is worth having. The priority ladder is the one part that changes behaviour during ordinary
work, so it moves to `CLAUDE.md` in one compact line rather than being lost.

### `docs/reference/best-practices.md` — 23 %, the largest item of all

**Judgement, and left alone for now.** Much of it is reference about Claude Code itself — model
tiers and prices, effort levels, caching flags — the kind of material the `claude-api` skill serves
on demand, and the kind that goes stale fastest. But it is `@`-imported by `CLAUDE.md` deliberately,
and parts of it *are* instructions (the verification table, the effort ladder). Splitting instruction
from reference here is a real piece of work, not a frontmatter line, and it is the natural next step
rather than something to slip into this one.

### `.claude/rules/workflow.md` — 16 %

**Structural finding, no action yet.** Seven of its thirteen anti-pattern bullets are already in
`CLAUDE.md`, and the two copies have drifted. The duplication is measured; which copy should own the
list is a judgement that belongs with the `best-practices.md` split above.

### `CLAUDE.md` — 15 %

**Keep.** The project's own instructions; carrying them is the mechanism working as intended.

### `.claude/rules/git.md` — 4 %

**Keep, and it is the cheapest item on the list.** Conventional commits, branch naming, never
force-push `main` — all three were exercised in this very session.

### `.claude/rules/self-improvement.md` — 11 %

**Keep.** Behavioural by construction: it is a reflex, and a reflex that is not present does not
fire. Exercised this session.

### `.claude/rules/vendor-precedence.md` — 10 %

**Not exercisable here** — the grade Phase 2 had to invent. It governs conflicts between the
foundation and installed vendor skills; this repository has none, so it can do nothing here. That is
not evidence of being inert in the installed projects, where the collision it arbitrates is real.
**Keep**, and record that the reason is an absence of local evidence, not a presence of it.

### `docs/reference/project-structures.md` — 5 %

**Judgement.** Directory layouts for four stacks, relevant when scaffolding and inert otherwise —
the clearest case of "reference consulted on demand" after the rules catalogue. Small enough that it
is not worth a separate change; it belongs to the `best-practices.md` split.

---

## What this phase changes, and what it does not

**Acted on: one item.** `.claude/rules/README.md` — a 15 % share carried by an accident of
frontmatter, with no consumer needing it in context and no behavioural content beyond a ladder that
moves rather than disappears.

**Not acted on: everything else**, because the remaining candidates need either the billing-gated
eval or a content split that deserves its own evidence. Listing them as "next" and stopping is the
honest end of a phase whose instrument is half unavailable.

## Second action — the reference stops travelling, and every fact gets one home

`docs/reference/best-practices.md` was the **largest carried item of all** (8 240 B, 23 %), and
measuring it by section settled the argument that reading it could not:

| | Sections | Bytes |
|---|---|---:|
| **Reference / news** — model tiers and prices, memory, worktrees, `/rewind`, `/recap`, prompt caching, prompting tables, one slash command | 8 | ~5 600 |
| **Instruction** — verification, effort ladder | 2 | ~1 800 |

`## Recommended Model` alone is **2 721 bytes, a third of the file**: prices and dated
announcements, the fastest-staling content in the repository, and material the `claude-api` skill
serves authoritatively on demand. `docs/reference/project-structures.md` (1 927 B) is four directory
layouts — reference by construction.

**Both `@`-imports are removed.** The instruction they carried moves into `CLAUDE.md` in compact
form; the documents stay exactly where readers and the website expect them, and stay the canonical
wording reference the `fable-5-integration` spec's EF-007 depends on. Nothing is deleted; it stops
being *carried*.

**And the duplication measured earlier is resolved rather than noted.** The anti-pattern list now has
one home — `.claude/rules/workflow.md`, itself global, so it was already present — and the three
bullets that existed only in `CLAUDE.md` moved there instead of being lost. The second copy bought
nothing and had already drifted.

| | Carried bytes |
|---|---:|
| at the start of the pass | 35 162 |
| after scoping the catalogue | 30 046 |
| **after this** | **20 783 — −40.9 %** |

⚠️ **The same load rides into every installed project, and that is a separate decision.** The
`CLAUDE.md` that `init` generates carries the same two `@`-imports (as
`@.claude/docs/reference/…`), pinned by five tests in `tests/docs-under-claude.bats`,
`tests/claude-md-per-type.bats` and `tests/new-project.bats` — where they are a *feature* of the
docs-under-`.claude` layout, not an oversight. Making the same change downstream reaches ~20 projects
and rewrites those tests, so it is named here rather than slipped in: the argument is identical, the
blast radius is not.

## The one guardrail this phase adds, and why it earns its place

`tests/rules-frontmatter.bats` pins the carried set as an **explicit list**. Judged by the same
criteria as everything else in this pass:

- **Harm prevented**: a rule made global costs every session forever, and **nothing reports it** —
  no failure, no warning, only a heavier session. That is the silent-cost failure mode the whole
  pass is about, and the reason a reviewer cannot catch it by reading a diff.
- **Maintenance cost**: one line when a rule is *deliberately* made global. It needs no feeding
  otherwise, which is this pass's keep-criterion.
- **Harm caused**: none recorded; it fails only on a real change to what every session carries.
- **Class**: recoverable — but the recovery only happens if someone notices, and nobody did for the
  15 % this phase just removed.

Three mutations of the real rules directory, each killed by its own arm and no other: the catalogue
made global again, an intentionally-global rule silently scoped, and a new undeclared global rule.

### ⚠️ What writing it cost — two hollow assertions, both of which looked like passes

1. **The reader was reading the documentation.** The first `_has_paths` helper looked for the first
   two `---` lines *anywhere* in the file. `.claude/rules/README.md` ends with a fenced example **of**
   a frontmatter block — so the helper found `paths:` in the example and answered *yes* for a file
   with no frontmatter at all. It survived the exact mutation it exists to catch. The helper is now
   anchored to line 1. **A document showing a construct is not a document using it** — the third time
   that same confusion surfaced in a single day, after `substance-check` and the marker gate.
2. **`! cmd` is exempt from `set -e`.** The "every intended-global rule really is" case negated
   inside a loop, so it could not fail; the mutation was caught only by a control that happened to be
   the last command in its own body. Offenders are now collected and asserted at the end.

Both were found by mutation, neither by reading. That is the fourth and fifth hollow assertion caught
this way in this pass — the technique keeps paying because a test that cannot fail looks exactly like
a test that passes.

---

**Not claimed anywhere here**: that any carried item is useless. The measurements say what a file
*is* and how it travels, never what it does to a model's behaviour — that is the eval's question, and
the eval did not run.
