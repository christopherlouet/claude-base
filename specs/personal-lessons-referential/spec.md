# Spec — Personal cross-project "lessons learned" referential

> Design: `docs/designs/2026-06-21-personal-lessons-referential-design.md` (Approach A, approved).
> Phase: SPECIFY. Next: `/work:work-plan`.

## 1. Summary

Give each user a **personal, private memory of lessons** that carries across **all their projects** (and machines), so a mistake made — or a hard-won fix found — in one project is **never repeated from scratch** in another. The assistant proposes a generalized, sanitized lesson after a hard problem; the user approves; the lesson then quietly applies everywhere. The foundation ships only the *discipline* — the lessons stay the user's own and never enter the shared project.

## 2. User Stories

### P1 — MVP (the "never repeat a mistake" loop)

**US-1 — Capture a lesson by reflex (human-gated)**
As a developer, I want the assistant to offer to remember a lesson right after we solve a hard, reusable problem, so that I capture it without having to remember to.
- Given the assistant just resolved a non-trivial problem that generalizes beyond this project, When the work concludes, Then it proposes **one** short, generalized, sanitized lesson and asks me to keep / edit / discard it.
- Given I accept (or edit), Then the lesson is added to my personal lessons store.
- Given I discard, Then nothing is stored and I am not asked again about the same thing.
- Given the change was routine (a typo, a rename, an obvious fix), Then **no** proposal is made (no spam).

**US-2 — Recall a lesson automatically in every project**
As a developer, I want my stored lessons to be present in every project automatically, so that the same mistake is avoided everywhere without any per-project setup.
- Given a lesson is in my personal store, When I start work in any other project, Then the assistant already has that lesson in mind (no import, no command).
- Given a stored lesson is relevant to the current task, Then the assistant applies it (avoids the past mistake / reuses the past fix).

**US-3 — Personal and sanitized (privacy)**
As a developer, I want lessons kept private to me and stripped of project specifics, so that nothing sensitive leaks and nothing pollutes the shared foundation.
- Given a lesson is proposed, When it is written, Then it contains **no** project names, file paths, URLs, identifiers, or secrets — only a reusable principle.
- Given the foundation/shared project, Then **no** lesson is ever written into it; lessons live only in my personal space.
- Given a candidate lesson cannot be safely generalized (it only makes sense with project specifics), Then it is **not** promoted (kept local or discarded).

### P2 — Important

**US-4 — Promote a lesson explicitly (fallback)**
As a developer, I want to say "remember this as a lesson" on demand, so that I can capture something even when the reflex didn't fire.
- Given I explicitly ask to remember a lesson, Then it goes through the same generalize + sanitize + confirm path and is added on confirmation.

**US-5 — Keep the store bounded (pruning)**
As a developer, I want my lessons store kept small and high-value, so that it never becomes a burden carried into every session.
- Given the store would exceed its budget, When a new lesson is added, Then I am alerted and offered to consolidate/prune (merge duplicates, drop superseded lessons) — nothing is deleted without my confirmation.
- Given two lessons say nearly the same thing, Then I am offered to merge them rather than keep both.

**US-6 — Bootstrap from what I already learned (backfill)**
As a returning Claude Code user, I want to seed the store from lessons I already accumulated, so that I don't start from scratch.
- Given I have used Claude Code before (existing per-project notes), When I run the one-time bootstrap, Then the assistant scans my existing per-project lessons and **proposes** the general/recurring ones for promotion (generalize + sanitize + confirm each).
- Given I am a brand-new user with nothing to import, Then the bootstrap reports "nothing to import" and I simply continue on the reflex.
- Given the bootstrap runs, Then it is a **one-off** action I trigger — not a background process.

**US-7 — Carry lessons across machines (bring-your-own sync)**
As a developer with more than one machine, I want my lessons available on each, so that the referential follows me — without depending on the shared project.
- Given documented sync recipes, When I follow one (private repo / Syncthing / cloud-drive), Then my lessons appear on my other machine.
- Given the foundation, Then it does **not** provide or require any sync service of its own (the store is a single relocatable location; I choose the transport).

### P3 — Nice-to-have

**US-8 — Organize lessons as they grow**
As a developer with many lessons, I want them grouped (e.g. by topic), so that the store stays readable as it scales.

**US-9 — Recurrence signal**
As a developer, I want a lesson to note when the same mistake recurred, so that the most-repeated lessons are easy to spot and prioritize.

## 3. Functional Requirements

- **EF-001** — A stored lesson is a short, single-idea, generalized statement (a reusable principle), free of project names, paths, URLs, identifiers, and secrets.
- **EF-002** — No lesson is ever stored without explicit user confirmation (human-gate). This holds for the reflex, the explicit promote, and the bootstrap.
- **EF-003** — A confirmed lesson is present in the assistant's context in **every** project, with no per-project import or command by the user.
- **EF-004** — Lessons are written only to the user's personal space; nothing is written into the shared foundation/public project.
- **EF-005** — The store has a defined maximum budget; exceeding it triggers an alert and a guided, confirmation-based consolidation (never silent deletion).
- **EF-006** — The capture reflex fires only after a qualifying "hard problem" (e.g. multiple failed attempts, an explicit user correction, or a non-obvious root cause) and stays silent for routine changes.
- **EF-007** — The bootstrap proposes candidates drawn from the user's existing per-project lessons; nothing is imported without per-item confirmation.
- **EF-008** — No background or automated process consumes paid model usage to capture lessons; capture happens in-session, and prune/bootstrap are user-invoked. (billing-safe)
- **EF-009** — Sync is documented for at least three transports; the store is a single relocatable location with no foundation-owned sync component.
- **EF-010** — A lesson that duplicates (or near-duplicates) an existing one is not added twice; the user is offered a merge instead.
- **EF-011** — A lesson that cannot be generalized/sanitized is rejected for the personal store (it may remain a local, project-only note).

## 4. Edge Cases

- **New user, empty history** → bootstrap reports nothing to import; reflex still works.
- **Store at/over budget** → a new capture still proposes, but the user is required to prune/merge before it is kept.
- **User edits a proposed lesson** → the edited text is what gets stored (not the original proposal).
- **Project-specific "lesson"** → declined for the personal store; not silently promoted.
- **Sensitive content detected** (secret, token, private path) → blocked from being written; user is told why.
- **Duplicate already present** → offer merge / skip, never a silent second copy.
- **Two machines edit the store** → handled by the user's chosen sync transport; store format is append-friendly to minimize conflicts.
- **Reflex over-eager** → the user can decline, and repeated declines on a class of changes should reduce future proposals of that class.

## 5. Entities

- **Lesson** — a generalized, sanitized principle; optional topic/tag; date added; optional recurrence count. The single unit of value.
- **Personal lessons store** — the bounded, user-owned, single-location collection of lessons, loaded into every project.
- **Candidate lesson** — a proposed-but-unconfirmed lesson (from the reflex, an explicit promote, or the bootstrap) awaiting the user's keep/edit/discard.

## 6. Success Criteria

- **CS-001** — A lesson captured in project A is demonstrably applied in project B without any manual setup in B. (the core promise)
- **CS-002** — 0 lessons stored without user confirmation. (human-gate)
- **CS-003** — 0 project-specific identifiers or secrets present in stored lessons. (privacy)
- **CS-004** — The store stays within its budget across normal use. (reduction)
- **CS-005** — For a returning user with prior general notes, the bootstrap surfaces ≥ 1 promotable candidate.
- **CS-006** — 0 paid model usage attributable to a background capture process. (billing-safe)
- **CS-007** — On a routine change, the reflex stays silent (≈ 0 false proposals on a sample of trivial edits). (no-spam)

## 7. Out of Scope

- A session-end automated review that spends model usage to extract lessons (billing/anti-pattern).
- Any foundation-provided sync service or sync command (bring-your-own only).
- A community / shared lessons referential (personal only).
- Searching past conversation history ("how did we do X last time") — different use-case.
- Re-implementing the platform's native memory or memory-consolidation features.
- Mining past conversation transcripts during bootstrap (only already-curated per-project lessons are used).

## 8. Resolved decisions (were clarification points — confirmed 2026-06-21)

1. **Context budget (US-5/EF-005).** A single-screenful bound: **~2,000 characters / ~15–20 lessons**; beyond it, consolidation is prompted.
   > **Amended 2026-08-25 — the two halves of this bound were never consistent.** ~15–20 lessons in
   > ~2,000 chars implies 100–133 chars per lesson. Measured on a real store after ~2 months of use,
   > lessons average 210 chars (median 186) — and Hermes, the source of the 2,000 figure, states
   > 2,200 chars for 8–15 entries, i.e. 147–275 per entry, which is self-consistent where ours was
   > not. **The character bound stands; the count is now stated as a consequence of it (~8–13
   > lessons), not as a co-equal target.** Only the count changed — whether ~2,000 is still the right
   > budget is a separate, open question (see #504).
2. **"Hard problem" signal (EF-006).** The reflex qualifies a moment when **any** of: (a) more than one failed attempt before success, (b) an explicit user correction of the assistant, (c) a non-obvious root cause. It stays silent otherwise.
3. **Capture-rule placement.** The capture behavior is **shipped into each project** (so it fires everywhere via the normal foundation install/update); the lessons themselves live in the user's personal store, never in the project/foundation.
