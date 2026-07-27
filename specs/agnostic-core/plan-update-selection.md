# P2 follow-up — update.sh and the selection seam

Companion to `plan-p2.md`, which left `update.sh` explicitly out of scope
("duplicates the emit logic today; shares the selection libs already"). This
note records what the follow-up actually found and changed.

## The finding: the install's selection did not survive the first update

`new-project.sh` decides WHAT ships through the seam (`compute_selected_set`,
whose rules arm is `get_rules_for_type`). `update.sh` re-derived the same
decision on its own, file by file — and for rules it had no notion of stack at
all, so it refreshed the whole `.claude/rules/` directory.

Measured on a real install (`--simple --type python`, then `update --all
--force`): **19 rules the install had deliberately excluded were deposited**,
the entire web bundle among them. On a generic install: 14. Every install-time
rules decision was undone by the next update.

Root cause: `.claude/foundation.json` recorded `version`, `preset`, `tier` and
`modules` — never the stack the whitelist had been resolved for.

## Second finding: the whitelist itself had holes

Auditing the arms turned up rules no type could ever select:

| Rule | Before | After |
|------|--------|-------|
| `vue.md` | never shipped — the `react\|vue\|…` arm added `react.md` + `nextjs.md` but not `vue.md` | ships to `vue` only |
| `migration-safety.md` | in no arm | universal (its target paths span `package.json`/`tsconfig`, `pyproject.toml` AND `go.mod` — cross-cutting like `deploy-safety`) |
| `service-worker.md` | in no arm | web arm (paths: `sw.js`, `service-worker*`) |
| `base-maintenance.md` | in no arm | stays out, deliberately — foundation-internal (targets `.claude/skills/**`, `scripts/hooks/**`) |
| `astro/svelte/php/ruby/csharp.md` | in no arm | UNCHANGED — see the open item below |

Order mattered: aligning update on the whitelist BEFORE fixing it would have
removed the only channel through which a Vue project ever received `vue.md`.

## What changed

1. `get_rules_for_type` — the three coverage holes above. A `web_rules` array
   replaces the duplicated inline list so the web bundle has one definition.
2. `write_foundation_manifest` — new optional `projectType` field. Same
   non-positional mechanism as `tier`: `MANIFEST_PROJECT_TYPE` env wins, else an
   existing value is preserved, else **the key is omitted**. Reader:
   `manifest_project_type`.
3. `new-project.sh` records the EFFECTIVE type (`${PROJECT_TYPE:-generic}` —
   simple mode without `-t` leaves it empty, yet still selects the generic
   whitelist; recording nothing would have read as "legacy install").
4. `update.sh` sources `selected-set.sh` and applies `is_rule_excluded`:
   `base-maintenance.md` always, plus anything outside the recorded stack's
   whitelist. Skips are reported in the summary.

## Invariants held

- **Legacy = unchanged.** No `projectType` in the manifest → empty whitelist →
  update keeps shipping every rule, exactly as before. The stack is never
  re-detected at update time: guessing would silently change what an existing
  project receives. (`base-maintenance.md` is the one exception — it was never
  legitimate anywhere, so it is withheld from legacy projects too.)
- **EF-011 copy-only.** The filter only stops NEW deposits; a rule already on
  disk is never removed.
- **One SSOT.** `get_rules_for_type` now has a single caller-facing definition
  consumed by both install and update.

## Guard

`tests/install-update-parity.bats` — for representative configs, `install` then
`update --all --force` must leave the manifest-driven file set unchanged, in
both directions (nothing added: selection respected; nothing removed: EF-011).
Plus a negative probe. This is the standing guard against the two paths drifting
apart again.

`tests/selected-set.bats` also gained a coverage guard: every rule in
`.claude/rules/` must be selectable by at least one stack type, except an
enumerated list of documented exceptions — so a newly added rule cannot silently
join the unreachable set.

## Open items

- **5 unreachable rules** (`astro`, `svelte`, `php`, `ruby`, `csharp`): no arm
  can select them because `detection.sh` cannot yield those types
  (`react|vue|generic|node-api|fullstack|python|go|rust|java|flutter|neovim`).
  Fixing this means extending detection, not the whitelist — separate chantier.
  They are listed in the coverage guard's documented-exception set.
- **Selection predicates still duplicated**: `is_skill_kept`, `is_skill_dropped`,
  `is_catalog_item_filtered`, `_catalog_remove_set` in `update.sh` restate what
  `selected-set.sh` computes. Rules were the only surface where the duplication
  actually diverged (no shipped preset declares catalog/skill filters, so those
  paths are latent risk, not live drift). Folding them onto the seam is the next
  step; the parity guard above is what makes it safe to attempt.
