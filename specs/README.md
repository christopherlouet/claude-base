# Specs Index

Feature specs consumed by the workflow agents (`/work:work-specify`, `/work:work-plan`).

**Convention**:
- A spec cited by **live code, tests or docs** stays in place even when
  shipped — it serves as architecture documentation (e.g.
  `scripts/lib/modules.sh` → `specs/foundation-modules/spec.md`).
- A shipped spec with **no live references** (CHANGELOG history aside) moves
  to [`archive/`](archive/), with any remaining links updated.
- Each `spec.md` carries a status banner under its title; this index is the
  overview. When a spec ships, add the banner, update this table, and check
  `grep -rl "specs/<name>"` to decide in-place vs archive.

## Status

| Spec | Status | Delivered |
|------|--------|-----------|
| [presets](presets/spec.md) | ✅ Shipped | spec #118, system live since v1.32.0 |
| [presets-detection-and-e2e](presets-detection-and-e2e/spec.md) | ✅ Shipped | #160 (2026-05-09) |
| [presets-update-aware](presets-update-aware/spec.md) | ✅ Shipped | #162 (2026-05-09) |
| [presets-vendor-pointer-tier](presets-vendor-pointer-tier/spec.md) | ✅ Shipped | #185 (2026-05-18) |
| [preset-category-prompt](preset-category-prompt/spec.md) | ✅ Shipped | #192 (2026-05-19) |
| [audit-docs](audit-docs/spec.md) | ✅ Shipped | #201 (2026-05-19) |
| [foundation-modules](foundation-modules/spec.md) | ✅ Shipped | #265–#269 (2026-06-07) |
| [presets-commands-agents-filter](presets-commands-agents-filter/spec.md) | 🟢 Planned | — (plan + tasks 2026-06-08, S1 next) |
| [marketplace-audit](marketplace-audit/spec.md) | ♻️ Living document | continuous (vendor-curation gatekeeper) |
| [foundation-positioning-review](foundation-positioning-review/spec.md) | 📌 Reference | strategic baseline |
| [command-vendor-graduation](command-vendor-graduation/spec.md) | 🔵 Ready for planning | — (audit 2026-06-15: 2 REDUCE · 11 POINT · 4 KEEP) |
| [dogfood-v2-findings](dogfood-v2-findings/spec.md) | 📌 Closed | findings folded into rules/specs |

## Archived (shipped, no live references)

| Spec | Delivered |
|------|-----------|
| [archive/update-lifecycle-visibility](archive/update-lifecycle-visibility/spec.md) | #166 (2026-05-10), v1.38.0 |
| [archive/preset-react-vite-spa](archive/preset-react-vite-spa/spec.md) | #178 (2026-05-13) |
| [archive/vendor-skills-game-dev](archive/vendor-skills-game-dev/spec.md) | #183 (2026-05-18) |

## Legend

- ✅ **Shipped** — every story delivered and merged; kept as architecture reference.
- 🔵 **Ready for planning** — clarified, awaiting an implementation session.
- ♻️ **Living document** — continuously updated, no terminal state.
- 📌 **Reference / Closed** — context document; no implementation tracked.
