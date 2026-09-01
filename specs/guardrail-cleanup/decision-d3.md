# D3 — should the `.husky`/`preflight` chain be retired as CI duplication? **No.**

**Raised by Phase 3, 2026-09-01.** Measuring native coverage produced exactly one entry that came
back **covered**: `preflight --fast` runs five gates, and every one of them has an equivalent in
`.github/workflows/ci.yml`.

| preflight gate | CI equivalent |
|---|---|
| shellcheck | "Run ShellCheck" |
| counts (`validate-counts.sh`) | "Validate documentation counts" |
| conflicts (`check-conflict-markers.sh`) | "Conflict markers (tracked files)" |
| manifest (`bats tests/manifest-hooks-coverage.bats`) | the sharded bats suite |
| structure (`bats tests/policy-structure.bats`) | the sharded bats suite |

This is the **only removal candidate the pass produced across seven phases** — the only entry whose
removal would lose no coverage. It is therefore the one that most deserves to be argued rather than
felt.

## The criteria, applied

**1. What harm does it prevent, and is it irreversible?** A red push: a CI round-trip burnt, and
with required status checks, a merge slot. **Recoverable**, plainly — you fix it and push again.
EF-012 says friction is spent only against the permanent, so this criterion argues **for removal**.
It is the strongest argument on that side and it is stated first on purpose.

**2. Does it survive abandonment?** **Yes**, and this is what decides it. The spec's whole thesis is
that an unmaintained guardrail fails in one of two ways: it blocks all work, or it stops running
while the belief of protection survives. `preflight` does neither.

- A gate whose tool is absent is **skipped, and the skip is announced on stderr, unconditionally** —
  `--quiet` may hide a pass, never a non-run.
- In that case the success line is **withheld**: "the gates that ran passed — this is NOT a complete
  run". That was repaired in #515, by this same pass, for this exact reason.
- On a real failure it **exits 1**, so `.husky/pre-push` refuses the push.

Measured on this machine 2026-09-01: all five gates ran, zero skips. The local feedback is real
here, not hypothetical.

**3. What would removal actually save?** Not coverage — CI keeps every gate. It would save
maintaining a script that is already written, already tested, and whose "harm caused" column is
**empty after being genuinely exercised** — it runs on every push, so that emptiness is not the
"never tested" kind the pass learned to distrust in Phase 2.

**4. What would removal cost?** The local loop: finding a shellcheck warning or a stale count in
seconds instead of minutes. Partial, and worth stating as such — it depends on `shellcheck` and
`bats` being installed, and on a bare machine the chain announces its skips rather than gating.

## The bias this decision has to survive

After seven phases and zero removals, finding a candidate creates pressure to take it — a pass
called "cleanup" that removes nothing looks like a pass that failed. **That is precisely the shape
of reasoning EF-014 was written to block**: a harm avoided leaves no trace, a harm caused always
does, so the ledger is structurally biased against the guards that matter most.

"Duplicated" is not "useless". The measurement establishes overlap; it does not establish waste.

## Verdict

**Keep.** Recorded with its date and its argument so it can be re-judged, not so it can be settled
forever.

**What would change the answer:**

- The two copies drifting apart — a gate in `preflight` that CI no longer runs, or the reverse.
  That would make it two places to feed rather than one place mirrored, which is a different
  decision.
- A measured skip rate high enough that the local run stops being feedback. On a machine without
  `shellcheck` and `bats`, four of five gates are announcements rather than checks.

See [`native-coverage.md`](./native-coverage.md) for the measurements, and
[`decision-d1.md`](./decision-d1.md) for the pass's other recorded decision.
