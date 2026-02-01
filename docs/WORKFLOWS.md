# Workflows Visuels

> Diagrammes des flux de travail recommandes

## Workflow Principal: Explore → Plan → Code → Commit

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐     │
│   │          │    │          │    │          │    │          │     │
│   │ EXPLORE  │───▶│   PLAN   │───▶│   CODE   │───▶│  COMMIT  │     │
│   │          │    │          │    │          │    │          │     │
│   └──────────┘    └──────────┘    └──────────┘    └──────────┘     │
│        │               │               │               │            │
│        ▼               ▼               ▼               ▼            │
│   /work:work-explore   /work:work-plan      /dev:dev-tdd       /work:work-commit      │
│                                   /dev:dev-api       /work:work-pr          │
│                                   /dev:dev-component                   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Mermaid
```mermaid
flowchart LR
    A[EXPLORE] --> B[PLAN]
    B --> C[CODE]
    C --> D[COMMIT]

    A --> A1[/work:work-explore]
    B --> B1[/work:work-plan]
    C --> C1[/dev:dev-tdd]
    C --> C2[/dev:dev-api]
    C --> C3[/dev:dev-component]
    D --> D1[/work:work-commit]
    D --> D2[/work:work-pr]
```

## Workflow Feature Complete

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
│  │   │  work-plan  │                          │   RULES     │            │  │
│  │   └──────┬──────┘                          │ (typescript,│            │  │
│  │          │                                 │  react,     │            │  │
│  │          │ Plan approuve?                  │  security)  │            │  │
│  │          │                                 └─────────────┘            │  │
│  │     ┌────┴────┐                                                       │  │
│  │     │         │                                                       │  │
│  │    Non       Oui                                                      │  │
│  │     │         │                                                       │  │
│  │     ▼         ▼                                                       │  │
│  │   Reviser  ┌──────────────┐                                           │  │
│  │   le plan  │   dev-tdd    │                                           │  │
│  │            └──────┬───────┘                                           │  │
│  │                   │                                                   │  │
│  │                   ▼                                                   │  │
│  │            ┌──────────────┐                                           │  │
│  │            │  qa-review   │                                           │  │
│  │            └──────┬───────┘                                           │  │
│  │                   │                                                   │  │
│  │                   │ Review OK?                                        │  │
│  │              ┌────┴────┐                                              │  │
│  │              │         │                                              │  │
│  │             Non       Oui                                             │  │
│  │              │         │                                              │  │
│  │              ▼         ▼                                              │  │
│  │           Corriger  ┌──────────────┐                                  │  │
│  │                     │   work-pr    │                                  │  │
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
    EXPLORE --> PLAN[work-plan]
    PLAN --> APPROVED{Plan approuvé?}
    APPROVED -->|Non| REVISE[Réviser le plan]
    REVISE --> PLAN
    APPROVED -->|Oui| CODE[dev-tdd]
    CODE --> REVIEW[qa-review]
    REVIEW --> REVIEWOK{Review OK?}
    REVIEWOK -->|Non| FIX[Corriger]
    FIX --> REVIEW
    REVIEWOK -->|Oui| PR[work-pr]
    PR --> DONE([Done])
```

## Workflow Bugfix

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           /work:work-flow-bugfix                                  │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                                                                       │  │
│  │   BUG REPORTE                                                         │  │
│  │        │                                                              │  │
│  │        ▼                                                              │  │
│  │   ┌─────────────┐                                                     │  │
│  │   │  dev-debug  │────────┐                                            │  │
│  │   └──────┬──────┘        │                                            │  │
│  │          │               ▼                                            │  │
│  │          │        ┌─────────────┐                                     │  │
│  │          │        │   AGENT     │                                     │  │
│  │          │        │  dev-debug  │                                     │  │
│  │          │        │  (isolé)    │                                     │  │
│  │          │        └──────┬──────┘                                     │  │
│  │          │               │                                            │  │
│  │          │◀──────────────┘                                            │  │
│  │          │                                                            │  │
│  │          │ Cause identifiée?                                          │  │
│  │     ┌────┴────┐                                                       │  │
│  │     │         │                                                       │  │
│  │    Non       Oui                                                      │  │
│  │     │         │                                                       │  │
│  │     ▼         ▼                                                       │  │
│  │  Plus de   ┌──────────────┐                                           │  │
│  │  contexte  │ dev-tdd      │ (test qui échoue)                         │  │
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
│  │             Non       Oui                                             │  │
│  │              │         │                                              │  │
│  │              ▼         ▼                                              │  │
│  │           Itérer   ┌──────────────┐                                   │  │
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
    BUG([Bug reporté]) --> DEBUG[dev-debug]
    DEBUG --> AGENT{{Agent dev-debug}}
    AGENT --> FOUND{Cause trouvée?}
    FOUND -->|Non| CONTEXT[Plus de contexte]
    CONTEXT --> DEBUG
    FOUND -->|Oui| TEST[dev-tdd - Test qui échoue]
    TEST --> FIX[Appliquer le fix]
    FIX --> PASS{Tests passent?}
    PASS -->|Non| ITERATE[Itérer]
    ITERATE --> FIX
    PASS -->|Oui| COMMIT[work-commit]
    COMMIT --> DONE([Done])
```

## Workflow Release

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
│  │   │              AUDITS PARALLELES                │                   │  │
│  │   │                                               │                   │  │
│  │   │  ┌─────────┐  ┌─────────┐  ┌─────────┐       │                   │  │
│  │   │  │qa-security│  qa-perf │  qa-a11y │        │                   │  │
│  │   │  │  AGENT  │  │ AGENT   │  │ AGENT  │        │                   │  │
│  │   │  └────┬────┘  └────┬────┘  └───┬────┘        │                   │  │
│  │   │       │            │           │              │                   │  │
│  │   │       └────────────┼───────────┘              │                   │  │
│  │   │                    │                          │                   │  │
│  │   └────────────────────┼──────────────────────────┘                   │  │
│  │                        │                                              │  │
│  │                        ▼                                              │  │
│  │                 ┌─────────────┐                                       │  │
│  │                 │ Problèmes?  │                                       │  │
│  │                 └──────┬──────┘                                       │  │
│  │                   ┌────┴────┐                                         │  │
│  │                  Oui       Non                                        │  │
│  │                   │         │                                         │  │
│  │                   ▼         ▼                                         │  │
│  │               Corriger  ┌─────────────┐                               │  │
│  │               d'abord   │doc-changelog│                               │  │
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

    subgraph AUDITS[Audits Parallèles]
        SEC[qa-security]
        PERF[qa-perf]
        A11Y[qa-a11y]
    end

    AUDITS --> ISSUES{Problèmes?}
    ISSUES -->|Oui| FIX[Corriger d'abord]
    FIX --> AUDITS
    ISSUES -->|Non| CHANGELOG[doc-changelog]
    CHANGELOG --> RELEASE[ops-release]
    RELEASE --> TAG[Tag vX.Y.Z]
    TAG --> DONE([Done])
```

## Workflow Audit Complet

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              /qa:qa-audit                                       │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                                                                       │  │
│  │                    ORCHESTRATEUR PRINCIPAL                            │  │
│  │                           │                                           │  │
│  │       ┌───────────────────┼───────────────────┐                       │  │
│  │       │                   │                   │                       │  │
│  │       ▼                   ▼                   ▼                       │  │
│  │  ┌─────────┐        ┌─────────┐         ┌─────────┐                   │  │
│  │  │ AGENT   │        │ AGENT   │         │ AGENT   │                   │  │
│  │  │qa-security│       qa-perf │         │qa-a11y  │                   │  │
│  │  │(sonnet) │        │(sonnet) │         │(haiku)  │                   │  │
│  │  └────┬────┘        └────┬────┘         └────┬────┘                   │  │
│  │       │                  │                   │                        │  │
│  │       │                  │                   │                        │  │
│  │       ▼                  ▼                   ▼                        │  │
│  │  ┌─────────┐        ┌─────────┐         ┌─────────┐                   │  │
│  │  │ Rapport │        │ Rapport │         │ Rapport │                   │  │
│  │  │Sécurité │        │  Perf   │         │  A11y   │                   │  │
│  │  └────┬────┘        └────┬────┘         └────┬────┘                   │  │
│  │       │                  │                   │                        │  │
│  │       └──────────────────┼───────────────────┘                        │  │
│  │                          │                                            │  │
│  │                          ▼                                            │  │
│  │                   ┌─────────────┐                                     │  │
│  │                   │   RAPPORT   │                                     │  │
│  │                   │   GLOBAL    │                                     │  │
│  │                   │             │                                     │  │
│  │                   │ - Critiques │                                     │  │
│  │                   │ - Importants│                                     │  │
│  │                   │ - Mineurs   │                                     │  │
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
    AUDIT([/qa:qa-audit]) --> ORCHESTRATOR[Orchestrateur]

    ORCHESTRATOR --> SEC{{Agent qa-security<br/>sonnet}}
    ORCHESTRATOR --> PERF{{Agent qa-perf<br/>sonnet}}
    ORCHESTRATOR --> A11Y{{Agent qa-a11y<br/>haiku}}

    SEC --> RSEC[Rapport Sécurité]
    PERF --> RPERF[Rapport Perf]
    A11Y --> RA11Y[Rapport A11y]

    RSEC --> MERGE[Rapport Global]
    RPERF --> MERGE
    RA11Y --> MERGE

    MERGE --> REPORT[/Critiques\nImportants\nMineurs\nScore/]
```

## Workflow Mobile Flutter

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     Workflow App Mobile Flutter                              │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                                                                       │  │
│  │   NOUVELLE FEATURE                                                    │  │
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
│  │  │flutter│  │supabase│ (si backend)                                   │  │
│  │  └───┬───┘  └───┬───┘                                                 │  │
│  │      │          │                                                     │  │
│  │      └────┬─────┘                                                     │  │
│  │           │                                                           │  │
│  │           ▼                                                           │  │
│  │    ┌─────────────┐                                                    │  │
│  │    │   dev-tdd   │  Tests unitaires & widget                          │  │
│  │    └──────┬──────┘                                                    │  │
│  │           │                                                           │  │
│  │           ▼                                                           │  │
│  │    ┌─────────────┐                                                    │  │
│  │    │  qa-mobile  │  Audit complet mobile                              │  │
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
    subgraph FEATURE[Nouvelle Feature]
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

## Workflow API Backend

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        Workflow API Backend                                  │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                                                                       │  │
│  │   NOUVEL ENDPOINT                                                     │  │
│  │        │                                                              │  │
│  │        ▼                                                              │  │
│  │   ┌─────────────┐                                                     │  │
│  │   │work-explore │ Comprendre l'API existante                          │  │
│  │   └──────┬──────┘                                                     │  │
│  │          │                                                            │  │
│  │          ▼                                                            │  │
│  │   ┌─────────────┐                                                     │  │
│  │   │   dev-api   │ Routes, Controllers, Services                       │  │
│  │   └──────┬──────┘                                                     │  │
│  │          │                                                            │  │
│  │          ▼                                                            │  │
│  │   ┌─────────────┐                                                     │  │
│  │   │   dev-tdd   │ Tests d'intégration API                             │  │
│  │   └──────┬──────┘                                                     │  │
│  │          │                                                            │  │
│  │    ┌─────┴─────┐                                                      │  │
│  │    │           │                                                      │  │
│  │    ▼           ▼                                                      │  │
│  │  ┌───────┐  ┌────────────┐                                            │  │
│  │  │qa-    │  │doc-api-spec│                                            │  │
│  │  │security│  │ (OpenAPI)  │                                            │  │
│  │  └───┬───┘  └─────┬──────┘                                            │  │
│  │      │            │                                                   │  │
│  │      └─────┬──────┘                                                   │  │
│  │            │                                                          │  │
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
    A([Nouvel Endpoint]) --> B[work-explore]
    B --> C[dev-api]
    C --> D[dev-tdd]
    D --> E[qa-security]
    D --> F[doc-api-spec]
    E --> G[work-pr]
    F --> G
```

## Workflow Data Pipeline

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       Workflow Data Pipeline                                 │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                                                                       │  │
│  │   NOUVEAU PIPELINE                                                    │  │
│  │        │                                                              │  │
│  │        ▼                                                              │  │
│  │   ┌─────────────┐                                                     │  │
│  │   │work-explore │ Sources, schémas existants                          │  │
│  │   └──────┬──────┘                                                     │  │
│  │          │                                                            │  │
│  │          ▼                                                            │  │
│  │   ┌─────────────┐                                                     │  │
│  │   │ work-plan   │ Architecture ETL/ELT                                │  │
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
    A([Nouveau Pipeline]) --> B[work-explore]
    B --> C[work-plan]
    C --> D[data-pipeline]
    C --> E[data-modeling]
    D --> F[Tests Data Quality]
    E --> F
    F --> G[data-analytics]
    G --> H[ops-monitoring]
```

## Légende des Diagrammes

```
┌─────────────────────────────────────────────────────────────────┐
│                         LÉGENDE                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌──────────┐                                                  │
│   │          │    Commande (manuel)                             │
│   └──────────┘                                                  │
│                                                                 │
│   ┌──────────┐                                                  │
│   │  AGENT   │    Agent (contexte isolé)                        │
│   │ (model)  │                                                  │
│   └──────────┘                                                  │
│                                                                 │
│   ┌──────────┐                                                  │
│   │   ◇◇◇    │    Decision point                                │
│   └──────────┘                                                  │
│                                                                 │
│       │                                                         │
│       ▼           Flux séquentiel                               │
│                                                                 │
│       │                                                         │
│   ────┼────       Flux parallèle                                │
│       │                                                         │
│                                                                 │
│   ─ ─ ─ ─ ─       Optionnel                                     │
│                                                                 │
│   ═════════       Séparateur de section                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```
