# Tasks: [FEATURE NAME]

**Input**: Design documents from `specs/[feature]/`
**Prerequisites**: plan.md (required), spec.md (required for user stories)

---

## Task format: `[ID] [P?] [US?] Description`

- **[P]**: Can be executed in parallel (different files, no dependencies)
- **[US1/US2/US3]**: Associated user story (for traceability)
- Include exact file paths in descriptions

---

## Path conventions

- **Simple project**: `src/`, `tests/` at the root
- **Web app**: `backend/src/`, `frontend/src/`
- **Mobile**: `api/src/`, `ios/src/` or `android/src/`

Adapt to the structure defined in plan.md.

---

## Phase 1: Setup (Shared infrastructure)

**Goal**: Project initialization and base structure

- [ ] T001 - Create the file structure according to the plan
- [ ] T002 - Initialize dependencies
- [ ] T003 - [P] Configure linting and formatting

---

## Phase 2: Foundation (Blocking prerequisites)

**Goal**: Base infrastructure that MUST be complete BEFORE any user story

**⚠️ CRITICAL**: No user story can start before this phase is finished

- [ ] T004 - Setup database and migrations (if applicable)
- [ ] T005 - [P] Configure authentication (if applicable)
- [ ] T006 - [P] Setup routing and middleware
- [ ] T007 - Create the shared base models/entities
- [ ] T008 - Configure error handling and logging

**Checkpoint**: Foundation ready - user stories can start.

---

## Phase 3: User Story 1 - [Title] (P1) 🎯 MVP

**Goal**: [Short description of what this story delivers]

**Independent test**: [How to verify that this story works on its own]

### Tests for US1 (optional - if TDD requested) ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T009 - [P] [US1] Unit test for [component] in `tests/unit/[name].test.ts`
- [ ] T010 - [P] [US1] Integration test for [flow] in `tests/integration/[name].test.ts`

### US1 implementation

- [ ] T011 - [P] [US1] Create [Entity1] in `src/models/[entity1].ts`
- [ ] T012 - [P] [US1] Create [Entity2] in `src/models/[entity2].ts`
- [ ] T013 - [US1] Implement [Service] in `src/services/[service].ts` (depends on T011, T012)
- [ ] T014 - [US1] Implement [endpoint/feature] in `src/[location]/[file].ts`
- [ ] T015 - [US1] Add validation and error handling
- [ ] T016 - [US1] Add logging for US1 operations

**Checkpoint**: US1 is functional and testable independently.

---

## Phase 4: User Story 2 - [Title] (P2)

**Goal**: [Short description]

**Independent test**: [How to verify that this story works on its own]

### Tests for US2 (optional)

- [ ] T017 - [P] [US2] Unit test in `tests/unit/[name].test.ts`
- [ ] T018 - [P] [US2] Integration test in `tests/integration/[name].test.ts`

### US2 implementation

- [ ] T019 - [P] [US2] Create [Entity] in `src/models/[entity].ts`
- [ ] T020 - [US2] Implement [Service] in `src/services/[service].ts`
- [ ] T021 - [US2] Implement [endpoint/feature] in `src/[location]/[file].ts`
- [ ] T022 - [US2] Integrate with US1 components (if needed)

**Checkpoint**: US1 AND US2 work independently.

---

## Phase 5: User Story 3 - [Title] (P3)

**Goal**: [Short description]

**Independent test**: [How to verify that this story works on its own]

### Tests for US3 (optional)

- [ ] T023 - [P] [US3] Unit test in `tests/unit/[name].test.ts`
- [ ] T024 - [P] [US3] Integration test in `tests/integration/[name].test.ts`

### US3 implementation

- [ ] T025 - [P] [US3] Create [Entity] in `src/models/[entity].ts`
- [ ] T026 - [US3] Implement [Service] in `src/services/[service].ts`
- [ ] T027 - [US3] Implement [endpoint/feature] in `src/[location]/[file].ts`

**Checkpoint**: All user stories work independently.

---

## Phase N: Polish & Cross-cutting concerns

**Goal**: Improvements that touch multiple user stories

- [ ] TXXX - [P] Update documentation in `docs/`
- [ ] TXXX - Code cleanup and refactoring
- [ ] TXXX - Performance optimization
- [ ] TXXX - [P] Additional unit tests
- [ ] TXXX - Security review
- [ ] TXXX - Final validation

---

## Dependencies and Execution Order

### Dependencies between phases

```
Phase 1 (Setup)
     │
     ▼
Phase 2 (Foundation)  ◄──── BLOCKS all user stories
     │
     ├──▶ Phase 3 (US1 - MVP)
     │
     ├──▶ Phase 4 (US2) [can start after Phase 2]
     │
     └──▶ Phase 5 (US3) [can start after Phase 2]

All phases ──▶ Phase N (Polish)
```

### Dependencies between user stories

| Story | Can start after | Dependencies |
|-------|-----------------|--------------|
| US1 (P1) | Phase 2 (Foundation) | No other story |
| US2 (P2) | Phase 2 (Foundation) | Can integrate with US1 but testable on its own |
| US3 (P3) | Phase 2 (Foundation) | Can integrate with US1/US2 but testable on its own |

### Within each User Story

1. Tests (if TDD) MUST be written and FAIL before implementation
2. Models before services
3. Services before endpoints
4. Core implementation before integration
5. Complete story before moving on to the next

### Parallelization opportunities

- All tasks marked [P] can be executed in parallel
- Once Phase 2 is finished, all user stories can start in parallel
- Tests of a story marked [P] can run in parallel
- Models marked [P] can be created in parallel

---

## Parallelization example: User Story 1

```bash
# Launch all US1 tests together (if TDD):
Task: "Unit test for [component] in tests/unit/[name].test.ts"
Task: "Integration test for [flow] in tests/integration/[name].test.ts"

# Launch all US1 models together:
Task: "Create [Entity1] in src/models/[entity1].ts"
Task: "Create [Entity2] in src/models/[entity2].ts"
```

---

## Implementation Strategy

### MVP First (US1 only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundation (CRITICAL - blocks everything)
3. Complete Phase 3: US1
4. **STOP and VALIDATE**: Test US1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Setup + Foundation → Base ready
2. Add US1 → Test → Deploy (MVP!)
3. Add US2 → Test → Deploy
4. Add US3 → Test → Deploy
5. Each story adds value without breaking the previous ones

### Team Strategy (parallelization)

With several developers:

1. The full team completes Setup + Foundation together
2. Once Foundation is finished:
   - Dev A: User Story 1
   - Dev B: User Story 2
   - Dev C: User Story 3
3. Stories complete and integrate independently

---

## Notes

- **[P]** tasks = different files, no dependencies
- **[US?]** label = traceability to the user story
- Each user story must be completable and testable independently
- Verify that tests fail before implementing (TDD)
- Commit after each task or logical group
- Stop at each checkpoint to validate the story independently

**To avoid**:
- Vague tasks without a file path
- Conflicts on the same file
- Cross-story dependencies that break independence

---

**Version**: 1.0 | **Created**: [DATE]
