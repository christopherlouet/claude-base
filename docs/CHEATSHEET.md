# Cheatsheet - Claude Code Agents

> Référence visuelle de tous les agents disponibles.

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                         CLAUDE CODE AGENTS - CHEATSHEET                       ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║  Total: 131 commands | 63 agents | 54 skills | 9 catégories                  ║
╚═══════════════════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────────────────┐
│                              ASSISTANT                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│   ┌────────────────┐  ┌────────────────────┐                                │
│   │   /assistant   │  │  /assistant-auto   │                                │
│   │  Mode guide    │  │  Mode automatique  │                                │
│   └────────────────┘  └────────────────────┘                                │
│   Orchestrateurs : analysent l'intention et routent vers le bon workflow.   │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                           WORK- : WORKFLOW PRINCIPAL                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   EXPLORE → (BRAINSTORM) → SPECIFY → PLAN → TDD → AUDIT → COMMIT            │
│                                                                             │
│   ┌─────────┐  ┌──────────┐  ┌─────────┐  ┌──────┐  ┌─────┐  ┌───────┐  ┌────────┐ │
│   │ EXPLORE │→│BRAINSTORM│→│ SPECIFY │→│ PLAN │→│ TDD │→│ AUDIT │→│ COMMIT │ │
│   │ Lit     │  │ (option) │  │ Stories │  │ Plan │  │ R-G-R│  │ Score │  │ +PR    │ │
│   │ existant│  │ Idéation │  │ Critères│  │ Files│  │ Tests│  │ ≥ 90  │  │        │ │
│   └─────────┘  └──────────┘  └─────────┘  └──────┘  └─────┘  └───────┘  └────────┘ │
│                                                                             │
│   Commandes : /work:work-explore, /work:work-brainstorm,                    │
│   /work:work-specify, /work:work-plan, /dev:dev-tdd,                        │
│   /qa:qa-loop "score 90", /work:work-commit, /work:work-pr                  │
│                                                                             │
│   Workflows chaînés (tout-en-un):                                           │
│   ┌────────────────┐ ┌────────────────┐ ┌────────────────┐ ┌─────────────┐  │
│   │ flow-feature   │ │ flow-bugfix    │ │ flow-release   │ │ flow-launch │  │
│   │ Feature A→Z    │ │ Bug A→Z        │ │ Release A→Z    │ │ Produit A→Z │  │
│   └────────────────┘ └────────────────┘ └────────────────┘ └─────────────┘  │
│                                                                             │
│   Variantes :                                                               │
│   ┌──────────┐  ┌──────────┐  ┌──────────┐                                  │
│   │  quick   │  │  batch   │  │   team   │                                  │
│   │ <50 LOC  │  │ Multi-US │  │ Agents   │                                  │
│   └──────────┘  └──────────┘  └──────────┘                                  │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                       DEV- : DÉVELOPPEMENT (23 commandes)                   │
├─────────────────────────────────────────────────────────────────────────────┤
│  Cycle TDD     : tdd, test, testing-setup, debug, refactor                  │
│  API & types   : api, api-versioning, graphql, trpc, prisma                 │
│  UI & front    : component, hook, design-system, react-perf, error-handling │
│  Mobile/Edit   : flutter, neovim                                            │
│  IA / Document : ai-integration, prompt-engineering, rag, mcp, document     │
│  Backend BaaS  : supabase                                                   │
│  → Détail complet : tableau "DEV- : Développement (23)" plus bas            │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          QA- : QUALITÉ (16 commandes)                       │
├─────────────────────────────────────────────────────────────────────────────┤
│  Audit principal : qa-loop (audit + fix en boucle, score ≥ 90)              │
│  Audits ciblés   : security, perf, design, responsive, coverage, tech-debt  │
│                    review, audit, automation, e2e, kaizen                   │
│  Spécifiques     : wcag-audit (a11y), mobile, neovim, chrome (visuels)      │
│  → Détail complet : tableau "QA- : Qualité (16)" plus bas                   │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                       OPS- : OPÉRATIONS (34 commandes)                      │
├─────────────────────────────────────────────────────────────────────────────┤
│  Release & deploy : release, deploy, rollback, hotfix, mobile-release       │
│  GitFlow          : gitflow-{init, feature, release, hotfix}                │
│  CI/CD            : ci, ci-fix, deps                                        │
│  Infra            : docker, k8s, vps, vercel, serverless,                   │
│                     proxmox, opnsense, infra-code                           │
│  Observabilité    : monitoring, observability-stack, grafana-dashboard,     │
│                     load-testing, health                                    │
│  Data/Sec         : database, backup, disaster-recovery, secrets-management │
│  Méta-ops         : env, migrate, cost, cost-optimization, standup          │
│  → Détail complet : tableau "OPS- : Opérations (34)" plus bas               │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          DOC- : DOCUMENTATION                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌──────────┐  ┌───────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐     │
│   │ GENERATE │  │ CHANGELOG │  │ EXPLAIN │  │ ONBOARD │  │  I18N   │     │
│   │ Auto doc │  │ History   │  │ Pédago  │  │ Découvre│  │ Traduc  │     │
│   └──────────┘  └───────────┘  └─────────┘  └─────────┘  └─────────┘     │
│                                                                             │
│   ┌───────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────┐            │
│   │ FIX-ISSUE │  │ API-SPEC │  │  README  │  │ ARCHITECTURE │            │
│   │ GitHub    │  │ OpenAPI  │  │ Readme   │  │ Doc archi    │            │
│   └───────────┘  └──────────┘  └──────────┘  └──────────────┘            │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                             BIZ- : BUSINESS                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐        │
│   │  MODEL  │  │ MARKET  │  │   MVP   │  │ PRICING │  │  PITCH  │        │
│   │ Canvas  │  │ TAM/SAM │  │ Minimum │  │ Stratég │  │ Deck    │        │
│   └─────────┘  └─────────┘  └─────────┘  └─────────┘  └─────────┘        │
│                                                                             │
│   ┌─────────┐  ┌─────────┐  ┌────────────┐  ┌─────────┐  ┌──────────┐    │
│   │ ROADMAP │  │ LAUNCH  │  │ COMPETITOR │  │   OKR   │  │ RESEARCH │    │
│   │ Planning│  │ Go-to   │  │ Analyse    │  │ Object  │  │ User res │    │
│   └─────────┘  └─────────┘  └────────────┘  └─────────┘  └──────────┘    │
│                                                                             │
│   ┌──────────┐                                                             │
│   │ PERSONAS │                                                             │
│   │ Profils  │                                                             │
│   └──────────┘                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                       GROWTH- : CROISSANCE (11 commandes)                   │
├─────────────────────────────────────────────────────────────────────────────┤
│  Acquisition     : landing, seo, ab-test, cro                               │
│  Mesure          : analytics, app-store-analytics, funnel                   │
│  Engagement      : email, onboarding, retention                             │
│  International   : localization                                             │
│  → Détail complet : tableau "GROWTH- : Croissance (11)" plus bas            │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                             DATA- : DONNÉES                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌──────────┐  ┌───────────┐  ┌──────────┐                               │
│   │ PIPELINE │  │ ANALYTICS │  │ MODELING │                               │
│   │ ETL/ELT  │  │ Rapports  │  │ DWH      │                               │
│   └──────────┘  └───────────┘  └──────────┘                               │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                             LEGAL- : LÉGAL                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌──────────────────┐             │
│   │  DOCS   │  │  RGPD   │  │ PAYMENT │  │ TERMS-OF-SERVICE │             │
│   │ CGU/CGV │  │ GDPR    │  │ Stripe  │  │ CGU détaillées   │             │
│   └─────────┘  └─────────┘  └─────────┘  └──────────────────┘             │
│                                                                             │
│   ┌────────────────┐                                                       │
│   │ PRIVACY-POLICY │                                                       │
│   │ Confidentialité│                                                       │
│   └────────────────┘                                                       │
└─────────────────────────────────────────────────────────────────────────────┘

╔═══════════════════════════════════════════════════════════════════════════════╗
║                              QUICK REFERENCE                                  ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║  WORKFLOW OBLIGATOIRE:                                                        ║
║  ┌────────────────────────────────────────────────────────────────────────┐  ║
║  │ EXPLORE → (BRAINSTORM) → SPECIFY → PLAN → TDD → AUDIT → COMMIT        │  ║
║  │ explore   brainstorm     specify   plan   dev-tdd   qa-loop   commit  │  ║
║  └────────────────────────────────────────────────────────────────────────┘  ║
║                                                                               ║
║  NOUVELLE FEATURE:        /work:work-flow-feature "description"            ║
║  CORRECTION BUG:          /work:work-flow-bugfix "issue #123"              ║
║  NOUVELLE RELEASE:        /work:work-flow-release "v2.0"                   ║
║  LANCEMENT PRODUIT:       /work:work-flow-launch "mon SaaS"                ║
║                                                                               ║
║  AUDIT COMPLET:           /qa:qa-audit                                   ║
║  HEALTH CHECK RAPIDE:     /ops:ops-health                                 ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

---

## Commandes par Catégorie (131)

### Orchestrateur (1)

| Commande | Usage |
|----------|-------|
| `/assistant` | Guide de choix des agents et workflows |

### WORK- : Workflow Principal (15)

| Commande | Usage |
|----------|-------|
| `/work:work-explore` | Explorer et comprendre le code |
| `/work:work-brainstorm` | Idéation structurée avant spec |
| `/work:work-specify` | Créer une spécification fonctionnelle |
| `/work:work-clarify` | Clarifier les ambiguïtés |
| `/work:work-plan` | Planifier une implémentation |
| `/work:work-commit` | Créer un commit propre |
| `/work:work-pr` | Créer une Pull Request |
| `/work:work-commit-push-pr` | Commit + push + PR en une commande |
| `/work:work-quick` | Workflow rapide (changements triviaux, skip cycle complet) |
| `/work:work-batch` | Exécution séquentielle de user stories depuis un PRD |
| `/work:work-team` | Lancer une équipe d'agents coordonnés (Agent Teams) |
| `/work:work-flow-feature` | Workflow feature complet |
| `/work:work-flow-bugfix` | Workflow bugfix complet |
| `/work:work-flow-release` | Workflow release complet |
| `/work:work-flow-launch` | Workflow lancement complet |

### DEV- : Développement (23)

| Commande | Usage |
|----------|-------|
| `/dev:dev-tdd` | Développement TDD |
| `/dev:dev-test` | Générer des tests |
| `/dev:dev-testing-setup` | Configurer infrastructure tests |
| `/dev:dev-debug` | Déboguer un problème |
| `/dev:dev-refactor` | Refactoring guidé |
| `/dev:dev-document` | Génération documents (PDF, DOCX, XLSX, PPTX) |
| `/dev:dev-api` | Créer/documenter API REST |
| `/dev:dev-api-versioning` | Versioning d'API |
| `/dev:dev-component` | Créer un composant UI complet |
| `/dev:dev-hook` | Créer un hook React/Vue |
| `/dev:dev-error-handling` | Stratégie de gestion d'erreurs |
| `/dev:dev-react-perf` | Optimisation React/Next.js |
| `/dev:dev-mcp` | Créer des serveurs MCP |
| `/dev:dev-flutter` | Widgets et screens Flutter |
| `/dev:dev-supabase` | Backend Supabase (Auth, DB, Storage) |
| `/dev:dev-graphql` | API GraphQL client/serveur |
| `/dev:dev-neovim` | Plugins et config Neovim |
| `/dev:dev-design-system` | Design tokens et composants |
| `/dev:dev-prisma` | ORM Prisma |
| `/dev:dev-prompt-engineering` | Optimisation prompts LLM |
| `/dev:dev-rag` | Systèmes RAG |
| `/dev:dev-trpc` | APIs type-safe tRPC |
| `/dev:dev-ai-integration` | Intégration LLMs (OpenAI, Claude) |

### QA- : Qualité (16)

| Commande | Usage |
|----------|-------|
| `/qa:qa-review` | Code review + analyse nommage |
| `/qa:qa-security` | Audit sécurité OWASP |
| `/qa:qa-perf` | Analyse performance |
| `/qa:wcag-audit` | Audit accessibilité WCAG |
| `/qa:qa-audit` | Audit complet (tout en un) |
| `/qa:qa-design` | Audit UI/UX (100+ règles) |
| `/qa:qa-responsive` | Audit responsive/mobile |
| `/qa:qa-automation` | Automatisation des tests |
| `/qa:qa-coverage` | Analyse couverture tests |
| `/qa:qa-e2e` | Tests E2E (Playwright, Cypress) |
| `/qa:qa-kaizen` | Amélioration continue |
| `/qa:qa-mobile` | Audit qualité apps mobiles |
| `/qa:qa-neovim` | Audit config Neovim |
| `/qa:qa-tech-debt` | Dette technique |
| `/qa:qa-chrome` | Tests visuels Chrome |
| `/qa:qa-loop` | Audit + fix en boucle jusqu'au score cible (90 par défaut) |

### OPS- : Opérations (34)

| Commande | Usage |
|----------|-------|
| `/ops:ops-hotfix` | Correction urgente production |
| `/ops:ops-release` | Créer une release |
| `/ops:ops-rollback` | Rollback sécurisé |
| `/ops:ops-gitflow-init` | Initialiser GitFlow |
| `/ops:ops-gitflow-feature` | Branches feature |
| `/ops:ops-gitflow-release` | Branches release |
| `/ops:ops-gitflow-hotfix` | Hotfixes GitFlow |
| `/ops:ops-deps` | Audit et MAJ dépendances |
| `/ops:ops-docker` | Dockeriser |
| `/ops:ops-k8s` | Déploiement Kubernetes |
| `/ops:ops-vps` | Déploiement VPS |
| `/ops:ops-migrate` | Migration code/deps |
| `/ops:ops-ci` | Pipelines CI/CD |
| `/ops:ops-monitoring` | Logs, métriques, alertes |
| `/ops:ops-observability-stack` | Prometheus, Grafana, Loki |
| `/ops:ops-grafana-dashboard` | Dashboards Grafana |
| `/ops:ops-database` | Schema, migrations DB |
| `/ops:ops-health` | Health check rapide |
| `/ops:ops-env` | Gestion environnements |
| `/ops:ops-backup` | Stratégie backup/restore |
| `/ops:ops-load-testing` | Tests de charge |
| `/ops:ops-cost-optimization` | Optimisation coûts cloud |
| `/ops:ops-disaster-recovery` | Plan reprise sinistre |
| `/ops:ops-infra-code` | Infrastructure as Code |
| `/ops:ops-proxmox` | Infrastructure Proxmox VE |
| `/ops:ops-opnsense` | Configuration OPNsense |
| `/ops:ops-secrets-management` | Gestion secrets |
| `/ops:ops-serverless` | Déploiement serverless |
| `/ops:ops-vercel` | Configuration Vercel |
| `/ops:ops-mobile-release` | Publication App/Play Store |
| `/ops:ops-deploy` | Déploiement sécurisé avec checklist pre-deploy |
| `/ops:ops-cost` | Suivi des tokens Claude Code et coûts |
| `/ops:ops-standup` | Briefing matinal cross-repo |
| `/ops:ops-ci-fix` | Diagnostic et réparation autonome de la CI |

### DOC- : Documentation (9)

| Commande | Usage |
|----------|-------|
| `/doc:doc-generate` | Générer documentation |
| `/doc:doc-changelog` | Changelog |
| `/doc:doc-explain` | Expliquer code complexe |
| `/doc:doc-onboard` | Découvrir un codebase |
| `/doc:doc-i18n` | Internationalisation |
| `/doc:doc-fix-issue` | Corriger issue GitHub |
| `/doc:doc-api-spec` | Spec OpenAPI/Swagger |
| `/doc:doc-readme` | Créer/améliorer README |
| `/doc:doc-architecture` | Documenter l'architecture |

### BIZ- : Business (11)

| Commande | Usage |
|----------|-------|
| `/biz:biz-model` | Business model, Lean Canvas |
| `/biz:biz-market` | Étude de marché |
| `/biz:biz-mvp` | Définir le MVP |
| `/biz:biz-pricing` | Stratégie tarifaire |
| `/biz:biz-pitch` | Pitch deck |
| `/biz:biz-roadmap` | Roadmap produit |
| `/biz:biz-launch` | Workflow lancement |
| `/biz:biz-competitor` | Analyse concurrentielle |
| `/biz:biz-okr` | OKRs |
| `/biz:biz-personas` | Personas utilisateur |
| `/biz:biz-research` | Recherche utilisateur |

### GROWTH- : Croissance (11)

| Commande | Usage |
|----------|-------|
| `/growth:growth-landing` | Landing page |
| `/growth:growth-seo` | Audit SEO |
| `/growth:growth-analytics` | Tracking et KPIs |
| `/growth:growth-app-store-analytics` | Métriques App/Play Store |
| `/growth:growth-onboarding` | Parcours utilisateur |
| `/growth:growth-email` | Templates email |
| `/growth:growth-ab-test` | A/B testing |
| `/growth:growth-retention` | Stratégies rétention |
| `/growth:growth-funnel` | Analyse funnels |
| `/growth:growth-localization` | Localisation multi-marchés |
| `/growth:growth-cro` | Optimisation conversion (CRO) |

### DATA- : Données (3)

| Commande | Usage |
|----------|-------|
| `/data:data-pipeline` | Pipelines ETL/ELT |
| `/data:data-analytics` | Analyse de données |
| `/data:data-modeling` | Modélisation data warehouse |

### LEGAL- : Légal (5)

| Commande | Usage |
|----------|-------|
| `/legal:legal-docs` | CGU, CGV, mentions légales |
| `/legal:legal-rgpd` | Conformité RGPD/GDPR |
| `/legal:legal-payment` | Intégration paiement |
| `/legal:legal-terms-of-service` | Conditions Générales d'Utilisation |
| `/legal:legal-privacy-policy` | Politique de Confidentialité |

---

## Décision rapide par intention

> "Je veux faire X" → quelle commande utiliser ?

| Intention | Commande |
|-----------|----------|
| Comprendre du code existant | `/work:work-explore` |
| Brainstormer / explorer des idées | `/work:work-brainstorm` |
| Créer une spécification (User Stories) | `/work:work-specify` |
| Clarifier les ambiguïtés d'une spec | `/work:work-clarify` |
| Planifier une feature (architecture, tasks) | `/work:work-plan` |
| Implémenter en TDD | `/dev:dev-tdd` |
| Déboguer un problème | `/dev:dev-debug` |
| Refactorer du code | `/dev:dev-refactor` |
| Faire une code review | `/qa:qa-review` |
| Audit complet + fix en boucle | `/qa:qa-loop` |
| Vérifier la sécurité (OWASP) | `/qa:qa-security` |
| Auditer la performance | `/qa:qa-perf` |
| Vérifier l'accessibilité (WCAG) | `/qa:wcag-audit` |
| Audit complet (lecture seule) | `/qa:qa-audit` |
| Créer un commit propre | `/work:work-commit` |
| Créer une PR | `/work:work-pr` |
| Briefing matinal / standup | `/ops:ops-standup` |
| Réparer la CI cassée | `/ops:ops-ci-fix` |
| Déployer en production | `/ops:ops-deploy` |
| Health check rapide | `/ops:ops-health` |

> Si vous hésitez : `/assistant` (mode guide) ou `/assistant-auto "votre demande"` (exécution directe).

---

## Scénarios Courants

### Nouveau projet
```
/doc:doc-onboard     → Comprendre la structure
/work:work-explore    → Explorer le code
/work:work-plan       → Planifier le travail
```

### Nouvelle feature (workflow standard)
```
/work:work-explore         → Comprendre l'existant
/work:work-specify         → Spec User Stories + critères Given/When/Then
/work:work-plan            → Designer la solution + tasks par US
/dev:dev-tdd               → Implémenter avec tests (Red-Green-Refactor)
/qa:qa-loop "score 90"     → Audit + fix en boucle (obligatoire avant commit)
/work:work-commit          → Commiter proprement
/work:work-pr              → Créer la PR
```

### Changement trivial (skip cycle complet)
```
/work:work-quick "renommer X en Y"   # < 50 LOC, 1-3 fichiers
```

### Nouvelle feature (workflow complet)
```
/work:work-flow-feature "ajouter dark mode"
```

### Correction de bug
```
/work:work-flow-bugfix "#123 - utilisateur ne peut pas se connecter"
```

### Avant mise en prod
```
/qa:qa-audit        → Audit complet
/ops:ops-health      → Health check rapide
```

### Nouvelle release
```
/work:work-flow-release "v2.0.0"
```

### Lancer un nouveau business
```
/work:work-flow-launch "mon nouveau SaaS"
```

### Application mobile Flutter
```
/work:work-explore → /work:work-plan → /dev:dev-flutter + /dev:dev-supabase → /qa:qa-mobile → /work:work-pr
```

---

## Format des Commandes

```
/{category}-{action} "context"

Categories:
• assistant → Orchestrateur
• work-   → Workflow de base
• dev-    → Développement
• qa-     → Qualité
• ops-    → Opérations
• doc-    → Documentation
• biz-    → Business
• growth- → Croissance
• data-   → Données
• legal-  → Légal
```

---

## Commandes Intégrées Claude Code

| Commande | Usage |
|----------|-------|
| `/clear` | Réinitialiser le contexte |
| `/compact` | Compacter l'historique |
| `/resume` | Reprendre une session |
| `/help` | Aide |

---

## Raccourcis Clavier

| Raccourci | Action |
|-----------|--------|
| `Escape` | Interrompre Claude |
| `Escape` x2 | Revenir en arrière |
| `Tab` | Autocomplétion |
| `Ctrl+C` | Annuler |

---

## Mots-clés Raisonnement

| Mot-clé | Niveau |
|---------|--------|
| `think` | Basique |
| `think hard` | Approfondi |
| `think harder` | Très approfondi |
| `ultrathink` | Maximum |

---

## Format des Commits

```
type(scope): description

Types: feat, fix, refactor, test, docs, style, chore, perf, hotfix
```

**Exemples:**
```bash
feat(auth): add OAuth2 login
fix(api): handle null response
refactor(user): extract validation logic
```

---

## Fichiers de Configuration

| Fichier | Rôle |
|---------|------|
| `CLAUDE.md` | Instructions projet |
| `CLAUDE.local.md` | Config locale (gitignore) |
| `.claude/settings.json` | Permissions et hooks |
| `.claude/commands/**/*.md` | Commandes (organisées par catégorie) |
| `.claude/skills/` | Skills automatiques |
| `.claude/agents/` | Sub-agents isolés |
| `.claude/rules/` | Règles contextuelles par path |
| `.mcp.json` | Serveurs MCP |

---

## Règles d'Or

1. **Explore avant de coder** - Toujours comprendre le contexte
2. **Plan avant d'implémenter** - Évite les retours en arrière
3. **Tests AVANT le code (TDD)** - Cycle Red-Green-Refactor obligatoire
4. **Audit avant commit** - Score qa-loop ≥ 90 obligatoire avant push
5. **Commits atomiques** - Un commit = une préoccupation
6. **Conventional Commits** - `feat(scope): description`
7. **Pas de secrets dans le code** - Utiliser `.env` + gitleaks

---

## Ressources

- [Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Documentation officielle](https://code.claude.com/docs/en/overview)

---

*Claude-Socle v1.30.0 - 131 commands - 63 agents - 54 skills - 30 rules*
