# Spec: pre-detection category prompt (Option C1)

**Status**: Validated — all P1+P2+P3 stories shipped in PR #192 (2026-05-19). Pre-detection category prompt live in `scripts/new-project.sh`; `categories[]` schema extension enforced by `scripts/validate-presets.sh`; all 11 shipped presets retrofitted; 8-entry taxonomy mirrored by [`specs/presets/roadmap.md`](../presets/roadmap.md) §"Category taxonomy" (drift-guard test).
**Date**: 2026-05-19
**Owner**: Chris

---

## Summary

Add an interactive "what are you building?" prompt to `scripts/new-project.sh` that fires BEFORE the existing 11-type menu, but ONLY when no preset has been auto-detected and no `--preset`/`--type` flag has been passed. The prompt presents a fixed 8-entry intent taxonomy (Web frontend / API-Backend / Mobile-Desktop / Game-Interactive media / Data-Database / Infra-DevOps / CLI-Automation / Other-Generic) and uses the user's choice to filter the type-and-preset menu down to relevant entries. Solves the "user starts an empty directory for a game project, doesn't know that the `phaser` preset exists" gap.

## Scope guardrails (locked from exploration)

| Decision | Resolution |
|---|---|
| Category model | **Intent-only** (C1). The taxonomy maps to "what kind of project" — cross-cutting tool-presets (e.g., `playwright`) stay OUT of the category prompt and remain accessible via `--preset` or `claude-base preset list`. |
| Category field | `categories: [string]` on the preset manifest, **optional**. Presets without it remain accessible via detect rule / flag / list — soft migration, no breaking change for community contributors. |
| Taxonomy source-of-truth | The 8 categories MUST mirror the existing `specs/presets/roadmap.md` "What is NOT covered" structure. Single source, single diff to audit drift. |
| `counts.json#presets` | Unchanged (still 11 after the change). |

## Locked decisions (resolved during /work:work-clarify)

| Decision | Resolution | Resolved on |
|---|---|---|
| Category prompt default | **`Other / Generic`** — pressing Enter without picking falls back to the full unfiltered menu (regression-safe, no editorial bias). | 2026-05-19 |
| Category-to-types mapping placement | **Static table in the prompt library** (bash constant in `scripts/lib/menu.sh` or a new `lib/category-map.sh`). Locked in the plan, modifiable in one PR if the type taxonomy evolves. No per-type manifest refactor. | 2026-05-19 |
| `categories[]` enum strictness | **Strict enum** — `validate-presets.sh` rejects any value outside the 8 locked slugs (EF-002). Adding a new category requires a coordinated PR updating spec + roadmap + prompt menu + validator together. Prevents menu-vs-manifest drift. | 2026-05-19 |
| `apollo` preset placement | **`["api-backend"]`** (single category). Vendor depth on Server/Federation/Connectors anchors the placement ; the `dev-graphql` pair-with framing is backend-anchored. Multi-category remains available for future cases per EF-014, but Apollo stays single for MVP to avoid menu duplication. | 2026-05-19 |

## User Stories

### P1 — MVP

**US-1 — New user discovers the right preset from an empty directory**
- **As a** developer starting a new project in an empty directory and not knowing which preset claude-base offers for my use case
- **I want** to be asked "what are you building?" with simple, plain-language categories
- **So that** I land on the relevant preset (e.g., `phaser` for a game project) without having to know its name or read documentation first

Acceptance criteria:
- Given I run the foundation install script against EITHER (a) an existing empty directory, OR (b) a directory that does not yet exist (and which the script offers to create at my prompt before continuing)
- And I am in interactive mode
- And I pass no `--preset` and no `--type` flag
- When the script reaches the project-type step (after the directory exists and the auto-detection step has produced no match)
- Then I see a prompt asking "What are you building?" with 8 numbered categories
- And after picking a category, the subsequent type-and-preset menu only shows entries relevant to that category

**US-2 — Experienced user with `--preset` is unaffected**
- **As a** user who already knows which preset they want and passes `--preset <name>`
- **I want** the new category prompt to be entirely skipped
- **So that** my command flow is identical to today's behavior

Acceptance criteria:
- Given I run the install script with `--preset phaser ./my-game`
- When the script starts
- Then no category prompt is shown
- And the install proceeds exactly as it did before the new prompt was added

**US-3 — Non-interactive caller (CI / scripts) is unaffected**
- **As a** non-interactive caller (CI pipeline, scripted install, piped stdin)
- **I want** the new category prompt to be skipped silently with no output and no hang
- **So that** my pipeline behavior is unchanged

Acceptance criteria:
- Given the standard input is not a terminal, OR the `--skip-prompts` / `--yes` / `-y` flag is passed
- When the install script starts
- Then no category prompt is shown
- And no prompt-related text appears in the output
- And the script does not block waiting for input

### P2 — Important

**US-4 — Filtered menu after category pick**
- **As a** user who has just picked a category
- **I want** the subsequent type-and-preset menu to show only entries relevant to my pick
- **So that** I am not distracted by 11 unrelated options when I am clearly building one specific kind of thing

Acceptance criteria:
- Given I pick "Game / Interactive media" at the category prompt
- When the next menu renders
- Then I see all presets whose `categories[]` declaration includes the "Game / Interactive media" category
- And I see only the subset of the 11 standard types that fit this category (e.g., "Other / Generic" but not "Java / Spring Boot")
- And a banner notes the roadmap path if zero presets match the category

**US-5 — Maintainer ships every preset with a category**
- **As the** foundation maintainer
- **I want** every shipped preset to declare its category in the same delivery as the new prompt
- **So that** the prompt is useful on day one (no preset is hidden from the new flow)

Acceptance criteria:
- Given the 11 currently-shipped presets
- When the new prompt feature ships
- Then all 11 presets have a `categories[]` declaration in their manifest
- And every category in the taxonomy has at least one entry, OR is explicitly documented as "no preset yet, see roadmap" in the prompt's empty-category banner

**US-6 — Community contributor can ship a preset without categorizing it (soft migration)**
- **As a** community contributor proposing a new preset
- **I want** the `categories[]` field to be optional in the manifest schema
- **So that** I can ship a useful preset without being forced to debate which taxonomy slot it fits

Acceptance criteria:
- Given a preset manifest that does NOT declare `categories[]`
- When the foundation validation script runs against it
- Then the manifest is accepted
- And the preset remains discoverable via auto-detection, `--preset` flag, and `claude-base preset list`
- And the preset does NOT appear in the post-category-prompt filtered menu

### P3 — Nice-to-have

**US-7 — User unsure of category picks "Other / Generic" and gets the full menu**
- **As a** user who reads the 8 categories and doesn't see one that fits
- **I want** to pick "Other / Generic" and see the full unfiltered type menu plus all presets
- **So that** I have an escape hatch without having to know the foundation's internals

Acceptance criteria:
- Given I pick "Other / Generic" at the category prompt
- When the next menu renders
- Then I see all 11 standard project types
- And I see all presets including those with no `categories[]` declaration

**US-8 — Empty-category UX names the roadmap**
- **As a** user who picks a category that has zero declared presets (e.g., "Mobile / Desktop" today)
- **I want** the menu to clearly indicate the absence of a preset and point me to the roadmap for community-wanted candidates
- **So that** I understand the foundation's honest position rather than thinking I missed something

Acceptance criteria:
- Given I pick a category with zero matching presets
- When the type menu renders
- Then a one-line banner is shown stating "No preset yet for this category — see `specs/presets/roadmap.md` for community-wanted candidates"
- And the relevant subset of the 11 standard types is still shown so I can proceed

## Functional Requirements

| ID | Requirement |
|---|---|
| **EF-001** | The pre-detection prompt MUST fire only when ALL of the following hold: (a) interactive mode is active, (b) standard input is a terminal, (c) no `--preset` flag was passed, (d) no `--type` flag was passed, (e) the auto-detection step did not produce any match (`MATCHED_PRESETS[]` is empty). |
| **EF-002** | The prompt MUST present a fixed 8-entry taxonomy in the following order (locked in this spec): `Web frontend`, `API / Backend`, `Mobile / Desktop`, `Game / Interactive media`, `Data / Database`, `Infra / DevOps`, `CLI / Automation`, `Other / Generic`. |
| **EF-003** | The taxonomy MUST mirror the categorization shape used in `specs/presets/roadmap.md` ("What is NOT covered" section). Single source of truth — any future addition or rename happens in both at once or the change is rejected by audit. |
| **EF-004** | When a category is picked, the subsequent type-and-preset menu MUST show: (a) all presets whose `categories[]` array includes the picked category, AND (b) the standard-type subset relevant to that category (subset definition lives in the plan, not in this spec). |
| **EF-005** | When the user picks "Other / Generic", the type menu MUST show the full unfiltered list of 11 standard types AND all presets (including those without a `categories[]` declaration). |
| **EF-006** | The preset manifest schema MUST gain an OPTIONAL `categories: [string]` field. When present, every entry MUST be a value from the locked enum of EF-002. The validation script MUST reject any value outside this enum. |
| **EF-007** | A preset without a `categories[]` field MUST remain fully accessible via (a) its `detect` rule if any, (b) `--preset <name>` flag, and (c) `claude-base preset list`. It only loses visibility in the post-category-prompt filtered menu (and in the "Other / Generic" fallback per EF-005, where it does appear). |
| **EF-008** | The same delivery that introduces the prompt MUST retrofit all 11 currently-shipped presets (`nextjs`, `astro`, `react-vite-spa`, `fastapi`, `cli-tools`, `homelab-proxmox`, `phaser`, `playwright`, `pulumi`, `apollo`, `mongodb`) with an explicit `categories[]` declaration. |
| **EF-009** | The non-interactive guard MUST skip the prompt silently when ANY of the following holds: (a) `SKIP_PROMPTS=true`, (b) `--yes` / `-y` was passed, (c) `--skip-prompts` was passed, (d) standard input is not a terminal. No prompt output, no error, no blocking read. |
| **EF-010** | The presence of `--preset <name>` or `--type <name>` MUST bypass the category prompt entirely, even in interactive TTY mode. Existing precedence rules for `--preset` vs `--type` are unchanged. |
| **EF-011** | When `--preset <name>` is passed for a preset whose `categories[]` is absent or does not include any known taxonomy value, the install MUST still proceed. `categories[]` is a discovery hint, NOT an install gate. |
| **EF-012** | A preset MAY declare multiple categories. When it does, it MUST appear in the filtered menu for every matching category. The validation script MUST accept arrays of length ≥1 (subject to enum validation per EF-006). |
| **EF-013** | The change MUST NOT modify `counts.json#presets` (still 11 after the change). The tests count MUST grow by the number of new bats tests added. |
| **EF-014** | The change MUST NOT rename `appliesToTypes` or any other existing field. `appliesToTypes` (language/runtime) and `categories` (intent) coexist as orthogonal axes. |
| **EF-015** | The CHANGELOG MUST receive one bullet under `[Unreleased]` describing both the new prompt and the schema extension. |
| **EF-016** | The change MUST NOT name any end-user project in spec, plan, manifests, prompts, banners, tests, or commits (per the foundation's durable rule on user-project confidentiality). |

## Edge Cases

| Case | Expected handling |
|---|---|
| User enters a non-numeric value at the category prompt | Display error message and re-prompt up to a maximum of 3 retries, then fall back to "Other / Generic" |
| User enters an out-of-range number (0, 9+) | Same re-prompt + fall-back behavior as above |
| User picks a category that has zero declared presets | Per US-8: show the relevant standard-type subset plus a one-line banner pointing to `specs/presets/roadmap.md` |
| A preset declares `categories: []` (empty array) | Treated as "field absent" (same effect as not declaring the field) |
| A preset declares a category outside the locked enum | Validation script rejects with a clear error message naming the offending entry |
| `MATCHED_PRESETS[]` is non-empty (detection fired on the target dir) | Category prompt is skipped entirely. Existing detect-first menu flow is preserved unchanged |
| Standard input is a pipe (`echo 5 \| script`) | Treated as non-TTY per EF-009 → prompt skipped → fallback to `--type generic` (or whatever default the existing fallback chooses) |
| User presses Ctrl-C at the category prompt | Standard SIGINT behavior, install aborts with exit code 130 (no special handling required) |
| Both `--type` AND `--preset` are passed | Existing precedence rules apply (out of scope of this spec). Category prompt is skipped either way per EF-010 |
| Terminal width is small (< 60 cols) | Category labels MUST still be readable. Use single-line entries; no multi-column layout assumption |
| `--preset` matches a preset whose `categories[]` is absent | Install proceeds normally per EF-011. No warning |
| Category enum changes in a future PR | The roadmap, the prompt labels, and the validation script's allowed-values list MUST be updated together. CI test asserts the three sources match |

## Entities

### Category

A category is one of 8 string values defined by EF-002. Each entry has:

| Attribute | Purpose |
|---|---|
| Display label (e.g., `Web frontend`) | Shown to the user in the prompt and in any banner |
| Slug (kebab-case, e.g., `web-frontend`) | The string stored in `categories[]` arrays in preset manifests |
| Roadmap row (e.g., `Web frameworks` in roadmap.md) | The drift anchor |

The 8 categories are locked in EF-002 and named in the spec body, not in code, so a future change is a spec amendment first.

### Preset manifest, extended

The existing preset JSON shape (defined in `specs/presets/spec.md`) gains:

| Field | Behavior |
|---|---|
| `categories` | Optional array of strings, each one a slug from the enum. Validation per EF-006. When absent, the preset is invisible to the category-filtered menu but remains accessible via every other path (EF-007). |

No other field is added, renamed, or removed.

### Category-to-types mapping

For each of the 8 categories, the spec defines which subset of the 11 standard types is "relevant" (used to render the filtered menu in EF-004). This mapping is shipped in the prompt library (the file is plan-level, not spec-level) but the mapping logic is:

- `Web frontend` → `react`, `vue`, `fullstack`, `generic`
- `API / Backend` → `node-api`, `python`, `go`, `rust`, `java`, `generic`
- `Mobile / Desktop` → `flutter`, `generic`
- `Game / Interactive media` → `generic`
- `Data / Database` → `python`, `generic`
- `Infra / DevOps` → `generic`
- `CLI / Automation` → `python`, `go`, `rust`, `generic`
- `Other / Generic` → all 11 types

This mapping is provisional and subject to refinement during clarification or plan.

## Success Criteria

| ID | Metric | Target |
|---|---|---|
| **CS-001** | `./scripts/validate-presets.sh` exit code on all 11 retrofitted presets | `0` |
| **CS-002** | Interactive run on empty directory (no flags) shows the category prompt within 2 seconds of script start | Confirmed manually + by bats |
| **CS-003** | Run with `--preset phaser` OR `--type python` does NOT show the category prompt | Asserted by bats |
| **CS-004** | Non-TTY caller (piped stdin or `--yes`) does NOT see the prompt and does NOT hang | Asserted by bats |
| **CS-005** | After picking "Game / Interactive media", the menu shows `phaser` as the matching preset | Asserted by bats |
| **CS-006** | After picking a zero-preset category (e.g. "Mobile / Desktop"), the menu shows the roadmap banner | Asserted by bats |
| **CS-007** | After picking "Other / Generic", the menu shows the full unfiltered list (11 types + all presets) | Asserted by bats |
| **CS-008** | `./scripts/validate-counts.sh` exit code | `0` |
| **CS-009** | `./scripts/audit-base.sh` exit code | `0` |
| **CS-010** | `counts.json#presets` value | `11` (unchanged) |
| **CS-011** | New bats tests added | `≥ 6` (covering EF-001, EF-005, EF-006, EF-007, EF-009, EF-010) |
| **CS-012** | All 11 existing fixture-pairing tests still pass (no regression on detect rules) | `0` regressions |
| **CS-013** | Category labels in the prompt match 1-to-1 with the roadmap.md taxonomy | Asserted by a drift-guard bats test |
| **CS-014** | Grep on protected end-user project names over the diff | `0` matches |

## Out of Scope

- Multi-step wizard (intent → tooling → language). Single-step intent prompt only.
- Cross-cutting tool-preset surfacing inside the category prompt (e.g., "After picking Web frontend, suggest playwright too"). Tool-presets stay accessible via `--preset` or `claude-base preset list` only.
- Renaming `appliesToTypes` to `categories` or otherwise restructuring the existing schema.
- Auto-inferring `categories[]` from `appliesToTypes` when the field is absent. Explicit declaration only.
- Telemetry / analytics on which category users pick.
- Localization of category labels. English-only for MVP.
- Adding new presets to fill empty categories. The retrofit covers the 11 existing presets only.
- Modifying the auto-detection mechanism. Detection-first remains the priority path; the category prompt is the fallback when detection has nothing to offer.
- Modifying the `claude-base preset list` command's output. Separate UX concern.
- Removing or deprecating the current 11-type menu. The new prompt is layered ON TOP, not a replacement.
- A "back" button at the category prompt to re-pick. Workaround is to abort (Ctrl-C) and re-run.
- Hardening the `categories[]` schema to mandatory. Soft migration only — community-curated presets without the field still ship.
- Adding `categories[]` to any preset under `.claude/presets/community/` (none shipped yet).
- Extending the taxonomy beyond the 8 categories named in EF-002. Any future addition is a spec amendment first.

## Clarification Points

_All clarifications resolved during `/work:work-clarify` on 2026-05-19. See "Locked decisions" at the top of this spec for the binding answers. Original questions kept below for traceability._

1. **Category prompt default** (emergent during clarify) — resolved: `Other / Generic` (regression-safe fallback to the full unfiltered menu).
2. **Standard-type subset mapping placement** — resolved: static table in the prompt library, locked in plan.
3. **`categories[]` enum strictness** — resolved: strict enum on the 8 locked slugs, validator rejects out-of-enum values.
4. **`apollo` preset placement** — resolved: `["api-backend"]` (single category).

---

## Cross-references

- Exploration that produced this spec: previous session, `/work:work-explore` readback covering `scripts/lib/menu.sh`, `scripts/lib/preset-detect.sh`, and `get_project_type()` in `scripts/new-project.sh`. Key finding: orthogonal axes (intent / language / tool) — C1 chooses to model intent only.
- Foundation gap that motivated the change: an empty-directory user who knows they want to build a game does not see any "Game" entry in the existing 11-type menu, and the `phaser` preset (live since PR #185) is invisible to them.
- Schema that this spec extends: `specs/presets/spec.md` "JSON schema" section.
- Taxonomy source-of-truth: `specs/presets/roadmap.md` "What is NOT covered" structure.
- Vendor-pointer tier that produced the 5 game/tooling presets: `specs/presets-vendor-pointer-tier/spec.md`.
- Memory anchors active at plan time: `feedback_verify_code_claims` (the standard-type subset mapping must be verified against `_MENU_STD_TYPES`), `feedback_counts_ci_gate` (auto-regen counts after fixture additions), `feedback_no_project_names` (EF-016 grep guard).
