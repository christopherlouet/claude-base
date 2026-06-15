# Plan — Command-side vendor graduation

> Companion to `spec.md` (2026-06-15). Verdict: **2 REDUCE · 11 POINT · 4 KEEP.**
> Proven loop: [[session-workflow-modules-feature]] — edit `.claude/` → counts/doc gate
> (`npm --prefix website run generate` + `validate-counts.sh`) → adversarial review → 1 PR/slice.

## 1. Approach

Two edit shapes, one per verdict (see spec §1 command-vs-agent policy):

**A. Pointer-command (REDUCE)** — replace the body, keep the workflow cross-links. Template =
`biz-pricing.md` verbatim structure:
```markdown
# <NAME> Agent (pointer)
<one-line purpose>
## Context
$ARGUMENTS
## Delegate to the vendor toolkit
`claude-base`'s prior `<cmd>` content (<N>-line checklist) is **superseded** by
[<vendorId>](<url>) — <one-line depth rationale>.
Install:
```bash
git clone --depth 1 <repo> ~/dev/vendor-skills/<name>
ln -s ~/dev/vendor-skills/<name>/skills/<sub> ./.claude/skills/<sub>
```
Recipe entry: [...](../../../docs/recipes/recommended-vendor-skills.md) §"<section>".
Reduction rationale: [...](../../../specs/command-vendor-graduation/spec.md).
For <related> delegate to `/<ns>:<related>`; ...
---
<keep the single strongest IMPORTANT/guardrail line>
```

**B. `## See also` block (POINT, + every touched agent)** — append, delete nothing:
```markdown
## See also

For deeper <domain> methodology, pair this with [<vendorId>](<url>) — install per
[`docs/recipes/recommended-vendor-skills.md`](<rel>) §"<section>". Use the vendor for the
deep execution layer; keep this <command|agent> for the foundation workflow orchestration.
```
Agents keep all frontmatter + functional instructions; the block goes after the body, before
any trailing guardrail lines.

**Generated docs**: every `.claude/commands/**` and `.claude/agents/**` edit regenerates a
per-resource page under `website/docs/` via `npm --prefix website run generate`. No count
*number* changes (no add/remove) → README/CLAUDE.md badges untouched; only page bodies +
possibly `counts.json` mtime. The Counts gate diff must be committed.

## 2. Coverage facts (verified 2026-06-15) — drives the task list

| Vendor target | In recipe? | In registry? | Verified? |
|---|---|---|---|
| vercel-labs/agent-skills (REDUCE) | ✅ §Vercel | ✅ | ✅ authority |
| grafana/skills (REDUCE + observ.) | ✅ §Grafana | ✅ | ✅ authority |
| corey/* (5 growth POINT) | ✅ §Corey (enumerates ab-testing/cro/churn/copywriting/onboarding) | ✅ | ✅ community 29.8k★ |
| AgriciDaniel/claude-seo (growth-seo agent backfill) | ✅ §AgriciDaniel | ✅ | ✅ |
| **biz vendors** (orchestkit/okr, memstack|majiayu/roadmap, gsd|slavingia/mvp, kai-slide/pitch, UX-personas) | ❌ none | ❌ none | ❌ **provisional** |

**Consequence:** REDUCE + all growth/observability POINT are mechanical (vendors already
curated). The **biz POINT packs are gated** — pointing them at an unverified repo violates the
foundation's own curation safety gate (`.claude/rules/vendor-precedence.md` T1). They get a
verification step first; any biz vendor that fails the bar → that pack **falls back to KEEP**
(no pointer), recorded in §spec US-6.

## 3. PR slicing (revised from spec §7 to isolate the biz risk)

| PR | Scope | Risk | Vendors |
|----|-------|------|---------|
| **PR-A** | P1 REDUCE: `ops-vercel` + `ops-grafana-dashboard` commands → pointer; `ops-vercel` agent → See also | behaviour-visible, low | already curated |
| **PR-B** | P2 safe POINT: 5 growth commands + `ops-observability-stack` + agents (`growth-landing`, `growth-funnel`) + `growth-seo` agent backfill | additive, very low | already curated |
| **PR-C** | P2 biz POINT (gated): verify 5 biz vendors → point the passers, KEEP the failers; new recipe entries + registry records for passers | research + uncertain | **needs verification** |
| **PR-D** | P3 close-out: positioning-spec reconciliation note + KEEP reasons + final registry/README index status | docs/data | — |

Each PR is atomic; PR-C may shrink the POINT set if biz vendors don't verify.

## 4. Tasks

### PR-A — REDUCE (US-1, US-2)
- **T1** `ops-vercel.md` command → pointer-command (template A). Vendor `vercel-labs/agent-skills`,
  recipe §Vercel. Keep `## Related agents` (ops-ci/monitoring/env). Keep the cron-secret guardrail.
- **T2** `ops-grafana-dashboard.md` command → pointer-command. Vendor `grafana/skills`, recipe
  §Grafana. Keep related (ops-monitoring/observability-stack/k8s).
- **T3** `ops-vercel` agent → append `## See also` (template B), keep frontmatter + body.
- **T4** Regen: `npm --prefix website run generate`; `./scripts/validate-counts.sh`;
  `./scripts/audit-base.sh`. Commit regenerated mirror.
- **T5** CHANGELOG `[Unreleased]` entry (Changed: 2 commands reduced to vendor pointers).

### PR-B — safe POINT (US-3 growth/observ. + US-4 backfill)
- **T6** Append `## See also` to commands: `growth-ab-test`, `growth-funnel`, `growth-landing`,
  `growth-onboarding`, `growth-retention` → corey sub-skill (recipe §Corey, name the matching sub).
- **T7** Append `## See also` to `ops-observability-stack` command → grafana (recipe §Grafana),
  with the caveat "vendor covers Grafana; this command wires the full Prom+Loki+Alertmanager stack".
- **T8** Append `## See also` to agents `growth-landing`, `growth-funnel` (same vendor as their command).
- **T9** Backfill: `growth-seo` agent → `## See also` → `AgriciDaniel/claude-seo` (recipe §AgriciDaniel),
  consistent with the already-graduated `growth-seo` command.
- **T10** Regen + validate-counts + audit-base; commit mirror.
- **T11** CHANGELOG `[Unreleased]` entry (Added: vendor See-also pointers on growth/observability packs).

### PR-C — biz POINT, verification-gated (US-3 biz + US-5 + US-7)
- **T12** For each biz vendor candidate, run the curation gate offline-where-possible:
  `gh` existence + `scripts/lib/trust-score.sh <repo> <community>` + `scripts/lib/curation-safety.sh`
  (read SKILL.md) + advice-neutrality eyeball. Record pass/fail per pack.
- **T13** For **passers**: append `## See also` to the biz command (+ agent for `biz-mvp`,
  `biz-personas`); add a recipe entry (new "Business strategy — community" subsection or per-vendor);
  add a `registry.json` record (vendorId/pinnedRef/trustTrack=community/provenance/adviceNeutrality/
  lastVerified/status=candidate).
- **T14** For **failers**: leave the pack as-is (KEEP); note the reason for §spec US-6 (PR-D).
- **T15** `scripts/validate-presets.sh --registry` (no floating refs) + regen + validate-counts.
- **T16** CHANGELOG `[Unreleased]` entry; list which biz packs pointed vs kept.

### PR-D — close-out (US-6, US-7 finalize)
- **T17** `specs/foundation-positioning-review/spec.md`: dated note → reconciled table (2/11/4),
  the one-line REDUCE rule, and that opt-in status downgraded community-vendor REDUCEs to POINT.
- **T18** Record the KEEP reasons for `ops-k8s`, `doc-api-spec`, `doc-changelog`, `legal-privacy-policy`
  (+ any biz failers from T14) in the spec.
- **T19** Flip `specs/README.md` + `spec.md` status banner to ✅ Shipped on merge of the wave.
- **T20** Update memory (`catalog-reduction-roadmap` / a graduation note) with the wave outcome.

## 5. Risks & mitigations

- **Biz vendors unverifiable** → gated in PR-C; fallback KEEP, never point at an unvetted repo
  (honors `vendor-precedence` T1). Realistic outcome: some/all biz packs stay KEEP.
- **Broken-pointer window** → REDUCE/growth/observability vendors are already in the recipe, so
  PR-A/PR-B have no dangling-pointer risk; PR-C adds the recipe entry in the **same** PR as the pointer.
- **Counts gate** → no add/remove ⇒ no badge change; still regen + commit `website/docs` per PR
  ([[website-docs-is-generated]]).
- **Over-trimming an agent** → only `## See also` is added to agents; bodies/frontmatter untouched.
- **`ops-vercel`/`ops-grafana-dashboard` lose a useful checklist** → acceptable: authority vendor
  documents it better; the pointer + recipe carry the install path. Reversible from git if regretted.

## 6. Verification (every PR)
```bash
npm --prefix website run generate    # regenerate mirror
./scripts/validate-counts.sh         # blocking doc gate
./scripts/validate-presets.sh        # + --registry on PR-C
./scripts/audit-base.sh              # structural
git diff --stat                      # confirm only intended files
```
Then `/qa:qa-review` (light, docs-heavy diffs) or `/code-review high` on PR-A (behaviour change).

## 7. Out of scope (carried from spec §5)
KEEP packs get no content change; no removals; skill-side + module/preset structure untouched;
no version bump/release (separate post-merge decision).
