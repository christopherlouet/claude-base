# Spec: acknowledge game-dev as a vendor-pointer gap

> **Status: ✅ Shipped** — PR #183 (2026-05-18).

**Status**: Validated — all P1+P2 stories shipped in PR #183 (2026-05-18). Phaser vendor pointer live in [`docs/recipes/recommended-vendor-skills.md`](../../docs/recipes/recommended-vendor-skills.md); [`specs/presets/roadmap.md`](../presets/roadmap.md) "Game / Interactive media" subsection live; counter `vendorSkillsValidated` 16 → 17.
**Date**: 2026-05-18
**Owner**: Chris

---

## Summary

Add a validated pointer to the canonical game-dev vendor skill source in `docs/recipes/recommended-vendor-skills.md` and acknowledge the game-dev category in `specs/presets/roadmap.md`. No new bundled skill, no new preset. The change makes a currently invisible foundation gap explicit and gives users one trusted source instead of a marketplace they have to evaluate themselves.

## Locked decisions (resolved during /work:work-clarify)

| Decision | Resolution | Resolved on |
|---|---|---|
| Canonical vendor source | **`phaserjs/phaser/skills/`** — official Phaser repo, 28 SKILL.md files including a `v3-to-v4-migration` skill, vendor-published, MIT, passes vendor-neutrality filter. | 2026-05-18 |
| Roadmap subsection label | **`Game / Interactive media`** — follows the existing roadmap pattern `X / Y` (`Mobile / Desktop`, `Other infra / data`). Broad enough to absorb future entries (Godot HTML5, Unity Web). | 2026-05-18 |
| Recipe placement | **Main section** "Recommended vendor skills (by domain)" — same tier as Supabase, Prisma, Vercel, shadcn/ui. Stack-narrowing language goes in **When to install**, not in a secondary section. | 2026-05-18 |
| Adjacent options | **Single bullet** "Adjacent options (not separately evaluated): PixiJS, Kaplay, Excalibur" at the end of the entry — no full evaluation. Defers a broader audit pilot to a separate spec if appetite emerges. | 2026-05-18 |
| Counter increment | **`counts.json#vendorSkillsValidated` goes from 16 → 17** — one vendor source = +1, same convention as Supabase/Prisma/shadcn entries. `validate-counts.sh` MUST stay green. | 2026-05-18 |

## User Stories

### P1 — MVP

**US-1 — Vendor pointer for 2D web game work**
- **As a** foundation user starting a 2D web game project
- **I want** the recipe of recommended community/vendor skills to name a single trusted source for game-dev guidance
- **So that** I do not have to audit the marketplace myself before installing a skill

Acceptance criteria (Given/When/Then):
- Given I open `docs/recipes/recommended-vendor-skills.md`
- When I scan the document for game-dev content
- Then I find one entry that names the canonical vendor source, names what it covers, names the install command, and names the vendor-neutrality assessment, in the same template as the existing entries

**US-2 — Roadmap explicitly acknowledges the gap**
- **As a** reader scanning the presets roadmap
- **I want** game-dev to appear in the "What is NOT covered" section with a one-line rationale
- **So that** the foundation does not appear to have an opinionated stance on game-dev by silent omission

Acceptance criteria:
- Given I open `specs/presets/roadmap.md`
- When I read the "What is NOT covered" section
- Then I find a new subsection naming at least one game-dev stack and stating why no preset ships yet

### P2 — Important

**US-3 — Contribution path is signposted**
- **As a** potential community contributor for a game-dev preset
- **I want** the roadmap rationale to point me to the existing contribution process
- **So that** I know the bar (≥3 months production use, quarterly review commitment, issue-first protocol) without rediscovering it from scratch

Acceptance criteria:
- Given the new roadmap subsection
- When I read it
- Then it references the existing "How to contribute a preset" section by relative anchor or by repeating the link to `roadmap.md` §"How to contribute"

**US-4 — Counter discipline upheld**
- **As a** maintainer running the anti-drift validation script
- **I want** the change to keep all counters consistent
- **So that** the next contributor does not inherit a broken `validate-counts.sh` run

Acceptance criteria:
- Given the change is applied locally
- When I run `./scripts/validate-counts.sh`
- Then the script exits 0

### P3 — Nice-to-have

**US-5 — Quick-reference table reflects the new category**
- **As a** reader looking at the roadmap's bottom-line count table
- **I want** the "Quick reference (count)" row set to include game-dev
- **So that** the "6 shipped / 22+ wanted" honest position number stays in sync with what the document above claims

Acceptance criteria:
- Given the roadmap is updated
- When I read the "Quick reference (count)" table
- Then a row for the game-dev category exists, with `0` shipped and `≥1` community-wanted

## Functional Requirements

| ID | Requirement |
|---|---|
| **EF-001** | The recipe MUST contain exactly one new entry for game-dev under the main "Recommended vendor skills (by domain)" list, OR under "Stack-specific" if scoped narrowly. Choice justified in a Clarification Point below. |
| **EF-002** | The new entry MUST follow the existing template: **Covers**, **When to install**, **Pair with**, **Install** (with shell snippet), **Vendor-neutrality** sections — same order, same level. |
| **EF-003** | The new entry MUST cite a source whose existence is verified the day the change is made: vendor identity, repository URL, last-commit date, and stars at verification time stated in the **Vendor-neutrality** paragraph. |
| **EF-004** | The new entry MUST pass the vendor-neutrality filter: source MUST NOT be a vendor acquired by an Anthropic competitor (notably OpenAI). Any such candidate MUST go into the recipe's "Vendors evaluated and NOT recommended" section instead. |
| **EF-005** | The recipe's "Last verified" timestamp at the top MUST be updated to the date of the change. |
| **EF-006** | The roadmap MUST gain a new subsection under "What is NOT covered" titled with the new category. The subsection MUST use the existing two-column table format (`Stack` / `Why we don't have it yet`). |
| **EF-007** | The roadmap's "Quick reference (count)" table MUST gain a row for the new category, with shipped count `0` and community-wanted count matching the number of stacks named in the new subsection. |
| **EF-008** | The change MUST NOT add any directory under `.claude/skills/`. The change MUST NOT add any file under `.claude/presets/`. The change MUST NOT touch `.claude/settings.json`. |
| **EF-009** | `counts.json#vendorSkillsValidated` MUST be incremented from `16` to `17`. `./scripts/validate-counts.sh` MUST exit `0` after the change. |
| **EF-010** | The change MUST add a CHANGELOG entry under the next minor version, naming both the recipe addition and the roadmap update in one bullet (single deliverable, single mention). |
| **EF-011** | The new entry and the new subsection MUST NOT name any specific end-user project (no game titles, no project codenames). Stack and vendor names only. |

## Edge Cases

| Case | Expected handling |
|---|---|
| The vendor source has not committed in >60 days at verification time | Entry still allowed, but **Vendor-neutrality** paragraph MUST state the staleness explicitly; a follow-up review trigger MUST be noted. |
| The vendor source is archived or marked deprecated between drafting and merge | Move directly to "Vendors evaluated and NOT recommended" with the deprecation as the rejection rationale. No bundled change. |
| Multiple credible alternatives exist (vendor + community competitors) | Lead with the highest-trust vendor source. Adjacent alternatives MAY be named in one short bullet under the entry without full evaluation. |
| The vendor source belongs to a tool acquired by an Anthropic competitor | Auto-reject per the vendor-neutrality filter. Document the rejection in "Vendors evaluated and NOT recommended" with explanation. |
| No vendor publishes officially, only community sources exist | The MVP is to add the most credible community source with a clear "community-authored" note in **Vendor-neutrality**. If no source clears the methodology bar, the change is reduced to the roadmap acknowledgment only and the recipe is left untouched. |
| `validate-counts.sh` fails after the change | The change MUST NOT be committed until counts are reconciled. |

## Entities

### Recipe entry

| Field | Purpose |
|---|---|
| Vendor name | Heading of the entry |
| Source URL | Canonical link, verified the day of the change |
| Covers | One paragraph naming what the source teaches |
| When to install | One paragraph naming the stack the source matches |
| Pair with | Name of the foundation skill the entry complements (or "none — gap" if no bundled counterpart exists) |
| Install | Shell snippet matching the install method on the vendor's README |
| Vendor-neutrality | One paragraph with funding/ownership status + last-verified date + stars |

### Roadmap subsection row

| Field | Purpose |
|---|---|
| Stack name | The framework / engine (e.g., 2D web game framework, generic) |
| Why not yet | One sentence; typically "no maintainer production use" or "no contributor with quarterly commitment yet" |

## Success Criteria

| ID | Metric | Target |
|---|---|---|
| **CS-001** | `./scripts/validate-counts.sh` exit code | `0` |
| **CS-002** | `./scripts/audit-base.sh` exit code | `0` (no structural regression) |
| **CS-003** | `./scripts/validate-presets.sh` exit code | `0` (preset format untouched, but smoke-checked) |
| **CS-004** | New bundled skill folder count delta | `0` (no `.claude/skills/<new>/` created) |
| **CS-005** | New preset file delta | `0` (no `.claude/presets/<new>.json` created) |
| **CS-006** | Recipe entry presence | Searchable by the keyword used to name the new category, found at the first match |
| **CS-007** | Roadmap "Quick reference (count)" rows | `n+1` after the change (`n` before) |
| **CS-008** | CHANGELOG entry | One bullet under the next minor version, naming both files touched |
| **CS-009** | End-user-project names in diff | `0` (verified by `grep -Ei "<protected-names>"` over the diff before commit) |
| **CS-010** | Time from intent to merged PR | `≤ 1 hour` of focused work (sanity check that the MVP stayed minimal) |

## Out of Scope

- Writing a bundled `dev-*` skill on the topic. That is a separate option (the C option in the exploration report) and gets its own spec if pursued.
- Creating a preset for any game-dev stack. That requires `≥3 months production use` per the existing roadmap contribution bar — none is claimed today.
- Bundling any third-party plugin via `marketplacePlugins[]` of any preset.
- A full audit of all game-dev community skills (PixiJS, Kaplay, Excalibur, melonJS, etc.). The MVP is one trusted pointer. A broader audit can land later as its own marketplace-audit pilot.
- Updating the website source files (`website/src/...`, `website/docs/...`) beyond what `validate-counts.sh` requires. The website is downstream and follows the foundation counters automatically once `npm --prefix website run generate` runs.
- Adding any test file. The recipe is prose; the existing audit scripts cover structural checks; the roadmap is a living document with no schema.
- Renaming any existing recipe entry or roadmap subsection.

## Clarification Points

_All clarifications resolved during `/work:work-clarify` on 2026-05-18. See "Locked decisions" at the top of this spec for the binding answers. Original questions kept below for traceability._

1. **Source identity** (added during clarify) — resolved: `phaserjs/phaser/skills/`.
2. **Roadmap subsection label** (added during clarify) — resolved: `Game / Interactive media`.
3. **Recipe placement** — resolved: main section "Recommended vendor skills (by domain)".
4. **Adjacent options** — resolved: single bullet "Adjacent options (not separately evaluated): PixiJS, Kaplay, Excalibur".
5. **Counter convention** — resolved: `vendorSkillsValidated` 16 → 17.

---

## Cross-references

- Exploration that produced the option set: previous session, `/work:work-explore` report on `dev-phaser` skill vs preset.
- Methodology this spec follows: `specs/marketplace-audit/spec.md` (vendor-neutrality filter, search protocol, decision rubric) and `specs/marketplace-audit/dev-skills-pilot-2026-05-05.md` (POINT-TO-VENDOR verdict pattern).
- Roadmap contribution bar reused in US-3: `specs/presets/roadmap.md` §"How to contribute a preset".
- Recipe template reused in EF-002: `docs/recipes/recommended-vendor-skills.md` (existing entries from Supabase through Pulumi all share the same shape).
- Counter discipline reused in EF-009 and CS-001: `.claude/rules/base-maintenance.md` and `scripts/validate-counts.sh`.
