# Specs Index

Feature specs consumed by the workflow agents (`/work:work-specify`, `/work:work-plan`).

**Convention**: completed specs stay in place — foundation code cites them as
architecture documentation (e.g. `scripts/lib/modules.sh` →
`specs/foundation-modules/spec.md`), so they are never moved or deleted.
Each `spec.md` carries a status banner under its title; this index is the
overview. When a spec ships, add the banner and update this table.

## Status

| Spec | Status | Delivered |
|------|--------|-----------|
| [presets](presets/spec.md) | ✅ Shipped | spec #118, system live since v1.32.0 |
| [presets-detection-and-e2e](presets-detection-and-e2e/spec.md) | ✅ Shipped | #160 (2026-05-09) |
| [presets-update-aware](presets-update-aware/spec.md) | ✅ Shipped | #162 (2026-05-09) |
| [update-lifecycle-visibility](update-lifecycle-visibility/spec.md) | ✅ Shipped | #166 (2026-05-10), v1.38.0 |
| [preset-react-vite-spa](preset-react-vite-spa/spec.md) | ✅ Shipped | #178 (2026-05-13) |
| [presets-vendor-pointer-tier](presets-vendor-pointer-tier/spec.md) | ✅ Shipped | #185 (2026-05-18) |
| [vendor-skills-game-dev](vendor-skills-game-dev/spec.md) | ✅ Shipped | #183 (2026-05-18) |
| [preset-category-prompt](preset-category-prompt/spec.md) | ✅ Shipped | #192 (2026-05-19) |
| [audit-docs](audit-docs/spec.md) | ✅ Shipped | #201 (2026-05-19) |
| [foundation-modules](foundation-modules/spec.md) | ✅ Shipped | #265–#269 (2026-06-07) |
| [presets-commands-agents-filter](presets-commands-agents-filter/spec.md) | 🔵 Ready for planning | — (design review #264) |
| [marketplace-audit](marketplace-audit/spec.md) | ♻️ Living document | continuous (vendor-curation gatekeeper) |
| [foundation-positioning-review](foundation-positioning-review/spec.md) | 📌 Reference | strategic baseline |
| [dogfood-v2-findings](dogfood-v2-findings/spec.md) | 📌 Closed | findings folded into rules/specs |

## Legend

- ✅ **Shipped** — every story delivered and merged; kept as architecture reference.
- 🔵 **Ready for planning** — clarified, awaiting an implementation session.
- ♻️ **Living document** — continuously updated, no terminal state.
- 📌 **Reference / Closed** — context document; no implementation tracked.
