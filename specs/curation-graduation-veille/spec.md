# Spec — Graduation veille (discover tags watch-list candidates)

> Status: ▶ In progress · 2026-06-21 · Owner: Chris
> Follows: `specs/dev-command-vendor-graduation.md` §US-2 (the markdown watch-list)
> Rides: `specs/marketplace-curation-engine` Slice 5 (`curation-discover.sh`, monthly LLM)
> Constraint: keeps the **nightly** `curation-watch.sh` LLM-free/$0 untouched (EF-012).

## 1. Problem

The "graduatable watch-list" (`dev-flutter`, `dev-auth`, `dev-i18n` — foundation skills kept
full-impl because **no vendor cleared the curation bar**) is **prose-only** in the
dev-command-vendor-graduation spec. Two gaps:

1. It is **not machine-readable** — no automation knows which foundation skills await a vendor.
2. `discovery-sources.json` searches by stack (nextjs/react/fastapi…) but **never** flutter /
   auth / i18n — so even the monthly discovery sweep would never surface a candidate for them.

Result: the graduation strategy is passive — it relies on the maintainer manually noticing a
vendor emerged. The veille closes that loop.

## 2. Scope (decided 2026-06-21)

**Monthly, full-judge** path (chosen over a $0 nightly heads-up): ride the existing
`curation-discover.sh` pipeline (trust ★≥500 + safety + LLM neutrality/fit judge) and **tag**
any cleared proposal that matches a watch-list entry as a **graduation candidate for `dev-X`**.
This reuses all three gates — a tagged candidate already passed the full bar, so it is a
high-confidence "ready for graduation review" signal, not a coarse heads-up.

No new script, no nightly change, no auto-mutation (observe-never-install: still proposal-only).

## 3. Design

### 3.1 Machine-readable watch-list — `.claude/curation/awaiting-vendors.json` (new)

```json
{ "version": "1.0.0",
  "entries": [
    { "foundationSkill": "dev-flutter", "tech": "Flutter",
      "matchKeywords": ["flutter"], "graduationTrigger": "..." },
    { "foundationSkill": "dev-auth", "tech": "auth",
      "matchKeywords": ["better-auth","betterauth","lucia-auth","nextauth","authjs"], "graduationTrigger": "..." },
    { "foundationSkill": "dev-i18n", "tech": "i18n",
      "matchKeywords": ["lingui","i18next","next-intl"], "graduationTrigger": "..." } ] }
```

The prose table in the dev-command-vendor-graduation spec stays the **human source of truth**;
this file is its **machine mirror** for the veille. `matchKeywords` are deliberately specific
lib names (precision over recall — `auth` alone would match `oauth`/`author`); recall depends on
the candidate repo naming the lib, acceptable for a veille.

**Doctrine (2026-06-21, user-flagged) — classify by KIND, not popularity.** A resource that
wraps an **external tool** is graduatable; niche/fragmentation only lowers the *probability* a
vendor emerges, never the category. So the watch-list also covers the tool-wrappers earlier
mis-parked as "permanent niche": `ops-k8s` (k8s already scanned by the `infra` query; fragmentation
is a non-issue — graduates to a `+`-joined bundle the registry supports), `dev-neovim`/`qa-neovim`,
`ops-proxmox`, `ops-opnsense`. The **concept-level** wrappers `dev-mcp`/`dev-rag`/`dev-ai-integration`
are graduatable in doctrine but **omitted** here — repo-path keyword match has too-low recall for
them (`rag` matches `storage`); they await a content-based matcher. The **only** permanent
category is the foundation's own workflow/discipline (a vendor there = moat-WARNING, not a
graduation). `foundationSkill` may name a skill, **command**, or agent (most tool-wrappers ship
as commands).

### 3.2 Discovery queries — extend `discovery-sources.json`

Add three sources so the techs are actually scanned:
`flutter`, `auth` (better-auth/lucia/nextauth), `i18n` (lingui/next-intl).

### 3.3 Tagging in `curation-discover.sh`

- New `AWAITING` path (`CURATION_AWAITING` env / `--awaiting FILE`), default
  `.claude/curation/awaiting-vendors.json`. Missing file ⟹ no tagging (fail-safe).
- `_graduation_for <repo>` — **LLM-free, deterministic**: lowercase the repo path, return the
  first `foundationSkill` whose `matchKeywords` appear as a substring, else empty.
- A cleared proposal (neutrality=pass ∧ fit≥threshold) gains a `graduationFor` field
  (`"dev-flutter"` … or `null`). New `counts.graduation` total. A dedicated **"Graduation
  candidates"** section in `proposals.md` lists repo · graduationFor · fit · rationale.
- Modelled on the existing `encroachesMoat` strategic-signal precedent — additive, no behaviour
  change for non-matching proposals.

## 4. User Stories

**US-1 (P1) — Tag a cleared candidate that fills an awaiting slot**
- **Given** an awaiting entry `dev-flutter` (keyword `flutter`) and a repo `acme/flutter-skill`
  that clears trust+safety+neutrality+fit, **When** discover runs, **Then** its proposal carries
  `graduationFor: "dev-flutter"`, `counts.graduation ≥ 1`, and the digest's Graduation section
  names it.
- **Given** a cleared proposal matching **no** awaiting entry, **Then** `graduationFor` is `null`
  and it is a normal proposal (unchanged behaviour).
- **Given** a repo that matches a keyword but **fails** a gate (trust/safety/fit/neutrality),
  **Then** it is rejected and never tagged (the bar is not lowered for awaiting techs).

**US-2 (P1) — Fail-safe & machine mirror**
- **Given** `awaiting-vendors.json` is missing/unreadable, **When** discover runs, **Then** it
  completes normally with `graduationFor` absent/null (never errors).
- **Given** the awaiting file, **Then** it is valid JSON with `version` + `entries[]`, each
  entry having `foundationSkill` + non-empty `matchKeywords[]`, and every `foundationSkill`
  corresponds to a real foundation skill directory.

## 5. Acceptance criteria

- `tests/curation-discover.bats` gains: tag-on-match, null-on-no-match, no-tag-when-gate-fails,
  missing-awaiting-file fail-safe, `counts.graduation` correct.
- A schema sanity check for `awaiting-vendors.json` (valid JSON, required fields, foundation
  skills exist).
- `shellcheck` clean on the modified `curation-discover.sh`.
- `validate-counts.sh` / `audit-base.sh` green (no command/agent/skill/rule count change).
- Nightly `curation-watch.sh` untouched (still $0 / LLM-free).

## 6. Out of scope

- A $0 nightly veille variant (rejected in favour of the full-judge monthly path).
- Auto-graduation / registry mutation (a tagged candidate is reviewed by a human, who then runs
  the normal command-side graduation per `specs/dev-command-vendor-graduation`).
- Content-based matching (v1 matches the repo path only; documented recall limitation).
- `docs/recipes/curation-bot-deploy.md` cadence change (the monthly job already runs discover).
