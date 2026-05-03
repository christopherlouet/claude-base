---
sidebar_position: 21
title: "Visual Workflows"
description: " Diagrams of the recommended workflows"
tags:
  - "concept"
---

<!-- Auto-generated from docs/ - DO NOT EDIT -->

# Visual Workflows

> Diagrams of the recommended workflows

## Main Workflow: Explore → Specify → Plan → TDD → Audit → Commit

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                     │
│   ┌─────────┐   ┌─────────┐   ┌───────┐   ┌───────┐   ┌───────┐   ┌─────────┐      │
│   │ EXPLORE │──▶│ SPECIFY │──▶│ PLAN  │──▶│  TDD  │──▶│ AUDIT │──▶│ COMMIT  │      │
│   └─────────┘   └─────────┘   └───────┘   └───────┘   └───────┘   └─────────┘      │
│        │             │             │           │           │           │            │
│        ▼             ▼             ▼           ▼           ▼           ▼            │
│   /work:work-explore  /work:work-specify  /work:work-plan  /dev:dev-tdd  /qa:qa-loop  /work:work-commit │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

### Mermaid
```mermaid
flowchart LR
    A[EXPLORE] --> B[SPECIFY]
    B --> C[PLAN]
    C --> D[TDD]
    D --> E[AUDIT]
    E --> F[COMMIT]

    A --> A1[/work:work-explore]
    B --> B1[/work:work-specify]
    C --> C1[/work:work-plan]
    D --> D1[/dev:dev-tdd]
    E --> E1[/qa:qa-loop]
    F --> F1[/work:work-commit]
```

## Full Feature Workflow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           /work:work-flow-feature                                 │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                                                                       │  │
│  │   START                                                               │  │
│  │     │                                                                 │  │
│  │     ▼                                                                 │  │
│  │   ┌─────────────┐                                                     │  │
│  │   │ work-explore│ ─────────────────────────────────┐                  │  │
│  │   └──────┬──────┘                                  │                  │  │
│  │          │                                         │                  │  │
│  │          ▼                                         ▼                  │  │
│  │   ┌─────────────┐                          ┌─────────────┐            │  │
│  │   │work-specify │                          │   RULES     │            │  │
│  │   │ User Stories│                          │ (typescript,│            │  │
│  │   │ + criteria  │                          │  react,     │            │  │
│  │   └──────┬──────┘                          │  security)  │            │  │
│  │          │                                 └─────────────┘            │  │
│  │          ▼                                                            │  │
│  │   ┌─────────────┐                                                     │  │
│  │   │  work-plan  │ Plan approved?                                      │  │
│  │   └──────┬──────┘                                                     │  │
│  │     ┌────┴────┐                                                       │  │
│  │     No       Yes                                                      │  │
│  │     │         │                                                       │  │
│  │     ▼         ▼                                                       │  │
│  │   Revise   ┌──────────────┐                                           │  │
│  │   the plan │   dev-tdd    │ Tests BEFORE the code (Red-Green-Refactor)│  │
│  │            └──────┬───────┘                                           │  │
│  │                   │                                                   │  │
│  │                   ▼                                                   │  │
│  │            ┌──────────────┐                                           │  │
│  │            │   qa-loop    │ Audit + fix loop (score ≥ 90)             │  │
│  │            └──────┬───────┘                                           │  │
│  │                   │                                                   │  │
│  │                   │ Score reached?                                    │  │
│  │              ┌────┴────┐                                              │  │
│  │             No        Yes                                             │  │
│  │              │         │                                              │  │
│  │              ▼         ▼                                              │  │
│  │           Iterate   ┌──────────────┐                                  │  │
│  │           qa-loop   │   work-pr    │                                  │  │
│  │                     └──────┬───────┘                                  │  │
│  │                            │                                          │  │
│  │                            ▼                                          │  │
│  │                          DONE                                         │  │
│  │                                                                       │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Mermaid
```mermaid
flowchart TD
    START([Start]) --> EXPLORE[work-explore]
    EXPLORE --> SPECIFY[work-specify]
    SPECIFY --> PLAN[work-plan]
    PLAN --> APPROVED{Plan approved?}
    APPROVED -->|No| REVISE[Revise the plan]
    REVISE --> PLAN
    APPROVED -->|Yes| CODE[dev-tdd]
    CODE --> AUDIT[qa-loop]
    AUDIT --> SCORE{Score ≥ 90?}
    SCORE -->|No| AUDIT
    SCORE -->|Yes| PR[work-pr]
    PR --> DONE([Done])
```

## Bugfix Workflow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           /work:work-flow-bugfix                                  │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                                                                       │  │
│  │   BUG REPORTED                                                        │  │
│  │        │                                                              │  │
│  │        ▼                                                              │  │
│  │   ┌─────────────┐                                                     │  │
│  │   │  dev-debug  │────────┐                                            │  │
│  │   └──────┬──────┘        │                                            │  │
│  │          │               ▼                                            │  │
│  │          │        ┌─────────────┐                                     │  │
│  │          │        │   AGENT     │                                     │  │
│  │          │        │  dev-debug  │                                     │  │
│  │          │        │  (isolated) │                                     │  │
│  │          │        └──────┬──────┘                                     │  │
│  │          │               │                                            │  │
│  │          │◀──────────────┘                                            │  │
│  │          │                                                            │  │
│  │          │ Cause identified?                                          │  │
│  │     ┌────┴────┐                                                       │  │
│  │     │         │                                                       │  │
│  │    No        Yes                                                      │  │
│  │     │         │                                                       │  │
│  │     ▼         ▼                                                       │  │
│  │   More     ┌──────────────┐                                           │  │
│  │   context  │ dev-tdd      │ (failing test)                            │  │
│  │            └──────┬───────┘                                           │  │
│  │                   │                                                   │  │
│  │                   ▼                                                   │  │
│  │            ┌──────────────┐                                           │  │
│  │            │    FIX       │                                           │  │
│  │            └──────┬───────┘                                           │  │
│  │                   │                                                   │  │
│  │                   ▼                                                   │  │
│  │            ┌──────────────┐                                           │  │
│  │            │  Tests pass? │                                           │  │
│  │            └──────┬───────┘                                           │  │
│  │              ┌────┴────┐                                              │  │
│  │             No        Yes                                             │  │
│  │              │         │                                              │  │
│  │              ▼         ▼                                              │  │
│  │           Iterate  ┌──────────────┐                                   │  │
│  │                    │ work-commit  │                                   │  │
│  │                    └──────────────┘                                   │  │
│  │                                                                       │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Mermaid
```mermaid
flowchart TD
    BUG([Bug reported]) --> DEBUG[dev-debug]
    DEBUG --> AGENT{{Agent dev-debug}}
    AGENT --> FOUND{Cause found?}
    FOUND -->|No| CONTEXT[More context]
    CONTEXT --> DEBUG
    FOUND -->|Yes| TEST[dev-tdd - Failing test]
    TEST --> FIX[Apply the fix]
    FIX --> PASS{Tests pass?}
    PASS -->|No| ITERATE[Iterate]
    ITERATE --> FIX
    PASS -->|Yes| COMMIT[work-commit]
    COMMIT --> DONE([Done])
```

## Release Workflow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           /work:work-flow-release                                 │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                                                                       │  │
│  │   PREPARE RELEASE                                                     │  │
│  │        │                                                              │  │
│  │        ▼                                                              │  │
│  │   ┌──────────────────────────────────────────────┐                    │  │
│  │   │              PARALLEL AUDITS                  │                   │  │
│  │   │                                               │                   │  │
│  │   │  ┌─────────┐  ┌─────────┐  ┌─────────┐       │                   │  │
│  │   │  │qa-security│  qa-perf │  wcag-audit │        │                   │  │
│  │   │  │  AGENT  │  │ AGENT   │  │ AGENT  │        │                   │  │
│  │   │  └────┬────┘  └────┬────┘  └───┬────┘        │                   │  │
│  │   │       │            │           │              │                   │  │
│  │   │       └────────────┼───────────┘              │                   │  │
│  │   │                    │                          │                   │  │
│  │   └────────────────────┼──────────────────────────┘                   │  │
│  │                        │                                              │  │
│  │                        ▼                                              │  │
│  │                 ┌─────────────┐                                       │  │
│  │                 │   Issues?   │                                       │  │
│  │                 └──────┬──────┘                                       │  │
│  │                   ┌────┴────┐                                         │  │
│  │                  Yes       No                                         │  │
│  │                   │         │                                         │  │
│  │                   ▼         ▼                                         │  │
│  │                Fix      ┌─────────────┐                               │  │
│  │                first    │doc-changelog│                               │  │
│  │                         └──────┬──────┘                               │  │
│  │                                │                                      │  │
│  │                                ▼                                      │  │
│  │                         ┌─────────────┐                               │  │
│  │                         │ ops-release │                               │  │
│  │                         └──────┬──────┘                               │  │
│  │                                │                                      │  │
│  │                                ▼                                      │  │
│  │                         ┌─────────────┐                               │  │
│  │                         │    TAG      │                               │  │
│  │                         │  vX.Y.Z     │                               │  │
│  │                         └─────────────┘                               │  │
│  │                                                                       │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Mermaid
```mermaid
flowchart TD
    START([Prepare Release]) --> AUDITS

    subgraph AUDITS[Parallel Audits]
        SEC[qa-security]
        PERF[qa-perf]
        A11Y[wcag-audit]
    end

    AUDITS --> ISSUES{Issues?}
    ISSUES -->|Yes| FIX[Fix first]
    FIX --> AUDITS
    ISSUES -->|No| CHANGELOG[doc-changelog]
    CHANGELOG --> RELEASE[ops-release]
    RELEASE --> TAG[Tag vX.Y.Z]
    TAG --> DONE([Done])
```

## Full Audit Workflow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              /qa:qa-audit                                       │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                                                                       │  │
│  │                    MAIN ORCHESTRATOR                                  │  │
│  │                           │                                           │  │
│  │       ┌───────────────────┼───────────────────┐                       │  │
│  │       │                   │                   │                       │  │
│  │       ▼                   ▼                   ▼                       │  │
│  │  ┌─────────┐        ┌─────────┐         ┌─────────┐                   │  │
│  │  │ AGENT   │        │ AGENT   │         │ AGENT   │                   │  │
│  │  │qa-security│       qa-perf │         │wcag-audit  │                   │  │
│  │  │(sonnet) │        │(sonnet) │         │(haiku)  │                   │  │
│  │  └────┬────┘        └────┬────┘         └────┬────┘                   │  │
│  │       │                  │                   │                        │  │
│  │       │                  │                   │                        │  │
│  │       ▼                  ▼                   ▼                        │  │
│  │  ┌─────────┐        ┌─────────┐         ┌─────────┐                   │  │
│  │  │ Report  │        │ Report  │         │ Report  │                   │  │
│  │  │Security │        │  Perf   │         │  A11y   │                   │  │
│  │  └────┬────┘        └────┬────┘         └────┬────┘                   │  │
│  │       │                  │                   │                        │  │
│  │       └──────────────────┼───────────────────┘                        │  │
│  │                          │                                            │  │
│  │                          ▼                                            │  │
│  │                   ┌─────────────┐                                     │  │
│  │                   │   GLOBAL    │                                     │  │
│  │                   │   REPORT    │                                     │  │
│  │                   │             │                                     │  │
│  │                   │ - Critical  │                                     │  │
│  │                   │ - Important │                                     │  │
│  │                   │ - Minor     │                                     │  │
│  │                   │ - Score     │                                     │  │
│  │                   └─────────────┘                                     │  │
│  │                                                                       │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Mermaid
```mermaid
flowchart TD
    AUDIT([/qa:qa-audit]) --> ORCHESTRATOR[Orchestrator]

    ORCHESTRATOR --> SEC{{Agent qa-security<br/>sonnet}}
    ORCHESTRATOR --> PERF{{Agent qa-perf<br/>sonnet}}
    ORCHESTRATOR --> A11Y{{Agent wcag-audit<br/>haiku}}

    SEC --> RSEC[Security Report]
    PERF --> RPERF[Perf Report]
    A11Y --> RA11Y[A11y Report]

    RSEC --> MERGE[Global Report]
    RPERF --> MERGE
    RA11Y --> MERGE

    MERGE --> REPORT[/Critical\nImportant\nMinor\nScore/]
```

## Flutter Mobile Workflow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     Flutter Mobile App Workflow                              │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                                                                       │  │
│  │   NEW FEATURE                                                         │  │
│  │        │                                                              │  │
│  │        ▼                                                              │  │
│  │   ┌─────────────┐                                                     │  │
│  │   │work-explore │                                                     │  │
│  │   └──────┬──────┘                                                     │  │
│  │          │                                                            │  │
│  │          ▼                                                            │  │
│  │   ┌─────────────┐                                                     │  │
│  │   │ work-plan   │  Clean Architecture                                 │  │
│  │   │             │  - Domain (entities, usecases)                      │  │
│  │   │             │  - Data (models, repos impl)                        │  │
│  │   │             │  - Presentation (BLoC, pages)                       │  │
│  │   └──────┬──────┘                                                     │  │
│  │          │                                                            │  │
│  │    ┌─────┴─────┐                                                      │  │
│  │    │           │                                                      │  │
│  │    ▼           ▼                                                      │  │
│  │  ┌───────┐  ┌───────┐                                                 │  │
│  │  │dev-   │  │dev-   │                                                 │  │
│  │  │flutter│  │supabase│ (if backend)                                   │  │
│  │  └───┬───┘  └───┬───┘                                                 │  │
│  │      │          │                                                     │  │
│  │      └────┬─────┘                                                     │  │
│  │           │                                                           │  │
│  │           ▼                                                           │  │
│  │    ┌─────────────┐                                                    │  │
│  │    │   dev-tdd   │  Unit & widget tests                               │  │
│  │    └──────┬──────┘                                                    │  │
│  │           │                                                           │  │
│  │           ▼                                                           │  │
│  │    ┌─────────────┐                                                    │  │
│  │    │  qa-mobile  │  Mobile quality audit                              │  │
│  │    └──────┬──────┘                                                    │  │
│  │           │                                                           │  │
│  │           ▼                                                           │  │
│  │    ┌─────────────┐                                                    │  │
│  │    │   qa-loop   │  Audit + fix score ≥ 90                            │  │
│  │    └──────┬──────┘                                                    │  │
│  │           │                                                           │  │
│  │           ▼                                                           │  │
│  │    ┌─────────────┐                                                    │  │
│  │    │  work-pr    │                                                    │  │
│  │    └─────────────┘                                                    │  │
│  │                                                                       │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │   RELEASE                                                             │  │
│  │        │                                                              │  │
│  │        ▼                                                              │  │
│  │   ┌─────────────┐                                                     │  │
│  │   │  qa-mobile  │  Pre-release checks                                 │  │
│  │   └──────┬──────┘                                                     │  │
│  │          │                                                            │  │
│  │          ▼                                                            │  │
│  │   ┌─────────────┐                                                     │  │
│  │   │doc-changelog│                                                     │  │
│  │   └──────┬──────┘                                                     │  │
│  │          │                                                            │  │
│  │          ▼                                                            │  │
│  │   ┌─────────────┐                                                     │  │
│  │   │ops-mobile-  │  Fastlane iOS + Android                             │  │
│  │   │   release   │                                                     │  │
│  │   └──────┬──────┘                                                     │  │
│  │          │                                                            │  │
│  │    ┌─────┴─────┐                                                      │  │
│  │    │           │                                                      │  │
│  │    ▼           ▼                                                      │  │
│  │  ┌───────┐  ┌───────┐                                                 │  │
│  │  │  iOS  │  │Android│                                                 │  │
│  │  │ Store │  │ Play  │                                                 │  │
│  │  └───────┘  └───────┘                                                 │  │
│  │                                                                       │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Mermaid
```mermaid
flowchart TD
    subgraph FEATURE[New Feature]
        F1([Start]) --> F2[work-explore]
        F2 --> F3[work-plan]
        F3 --> F4[dev-flutter]
        F3 --> F5[dev-supabase]
        F4 --> F6[dev-tdd]
        F5 --> F6
        F6 --> F7[qa-mobile]
        F7 --> F8[work-pr]
    end

    subgraph RELEASE[Release]
        R1([Prepare]) --> R2[qa-mobile]
        R2 --> R3[doc-changelog]
        R3 --> R4[ops-mobile-release]
        R4 --> R5[iOS App Store]
        R4 --> R6[Android Play Store]
    end
```

## Backend API Workflow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        Backend API Workflow                                  │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                                                                       │  │
│  │   NEW ENDPOINT                                                        │  │
│  │        │                                                              │  │
│  │        ▼                                                              │  │
│  │   ┌─────────────┐                                                     │  │
│  │   │work-explore │ Understand the existing API                         │  │
│  │   └──────┬──────┘                                                     │  │
│  │          │                                                            │  │
│  │          ▼                                                            │  │
│  │   ┌─────────────┐                                                     │  │
│  │   │work-specify │ User Stories + Given/When/Then criteria             │  │
│  │   └──────┬──────┘                                                     │  │
│  │          │                                                            │  │
│  │          ▼                                                            │  │
│  │   ┌─────────────┐                                                     │  │
│  │   │   dev-api   │ Routes, Controllers, Services                       │  │
│  │   └──────┬──────┘                                                     │  │
│  │          │                                                            │  │
│  │          ▼                                                            │  │
│  │   ┌─────────────┐                                                     │  │
│  │   │   dev-tdd   │ API integration tests (before the code)             │  │
│  │   └──────┬──────┘                                                     │  │
│  │          │                                                            │  │
│  │    ┌─────┴─────┐                                                      │  │
│  │    ▼           ▼                                                      │  │
│  │  ┌────────┐  ┌────────────┐                                           │  │
│  │  │qa-loop │  │doc-api-spec│                                           │  │
│  │  │ ≥ 90   │  │ (OpenAPI)  │                                           │  │
│  │  └───┬────┘  └─────┬──────┘                                           │  │
│  │      │             │                                                  │  │
│  │      └─────┬───────┘                                                  │  │
│  │            ▼                                                          │  │
│  │     ┌─────────────┐                                                   │  │
│  │     │   work-pr   │                                                   │  │
│  │     └─────────────┘                                                   │  │
│  │                                                                       │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Mermaid
```mermaid
flowchart TD
    A([New Endpoint]) --> B[work-explore]
    B --> S[work-specify]
    S --> C[dev-api]
    C --> D[dev-tdd]
    D --> E[qa-loop]
    D --> F[doc-api-spec]
    E --> G[work-pr]
    F --> G
```

## Data Pipeline Workflow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       Data Pipeline Workflow                                 │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                                                                       │  │
│  │   NEW PIPELINE                                                        │  │
│  │        │                                                              │  │
│  │        ▼                                                              │  │
│  │   ┌─────────────┐                                                     │  │
│  │   │work-explore │ Existing sources, schemas                           │  │
│  │   └──────┬──────┘                                                     │  │
│  │          │                                                            │  │
│  │          ▼                                                            │  │
│  │   ┌─────────────┐                                                     │  │
│  │   │ work-plan   │ ETL/ELT architecture                                │  │
│  │   └──────┬──────┘                                                     │  │
│  │          │                                                            │  │
│  │    ┌─────┴─────┐                                                      │  │
│  │    │           │                                                      │  │
│  │    ▼           ▼                                                      │  │
│  │  ┌────────┐  ┌────────────┐                                           │  │
│  │  │ data-  │  │   data-    │                                           │  │
│  │  │pipeline│  │  modeling  │                                           │  │
│  │  │(Airflow)│  │   (dbt)   │                                           │  │
│  │  └────┬───┘  └─────┬──────┘                                           │  │
│  │       │            │                                                  │  │
│  │       └─────┬──────┘                                                  │  │
│  │             │                                                         │  │
│  │             ▼                                                         │  │
│  │      ┌─────────────┐                                                  │  │
│  │      │    Tests    │ Data quality checks                              │  │
│  │      │ (Great Exp) │                                                  │  │
│  │      └──────┬──────┘                                                  │  │
│  │             │                                                         │  │
│  │             ▼                                                         │  │
│  │      ┌─────────────┐                                                  │  │
│  │      │   data-     │ Dashboards, KPIs                                 │  │
│  │      │  analytics  │                                                  │  │
│  │      └──────┬──────┘                                                  │  │
│  │             │                                                         │  │
│  │             ▼                                                         │  │
│  │      ┌─────────────┐                                                  │  │
│  │      │    ops-     │ Monitoring pipelines                             │  │
│  │      │ monitoring  │                                                  │  │
│  │      └─────────────┘                                                  │  │
│  │                                                                       │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Mermaid
```mermaid
flowchart TD
    A([New Pipeline]) --> B[work-explore]
    B --> C[work-plan]
    C --> D[data-pipeline]
    C --> E[data-modeling]
    D --> F[Data Quality Tests]
    E --> F
    F --> G[data-analytics]
    G --> H[ops-monitoring]
```

## Diagram Legend

```
┌─────────────────────────────────────────────────────────────────┐
│                         LEGEND                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌──────────┐                                                  │
│   │          │    Command (manual)                              │
│   └──────────┘                                                  │
│                                                                 │
│   ┌──────────┐                                                  │
│   │  AGENT   │    Agent (isolated context)                      │
│   │ (model)  │                                                  │
│   └──────────┘                                                  │
│                                                                 │
│   ┌──────────┐                                                  │
│   │   ◇◇◇    │    Decision point                                │
│   └──────────┘                                                  │
│                                                                 │
│       │                                                         │
│       ▼           Sequential flow                               │
│                                                                 │
│       │                                                         │
│   ────┼────       Parallel flow                                 │
│       │                                                         │
│                                                                 │
│   ─ ─ ─ ─ ─       Optional                                      │
│                                                                 │
│   ═════════       Section separator                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```
