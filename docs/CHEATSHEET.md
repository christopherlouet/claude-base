# Cheatsheet - Claude Code Agents

> Référence visuelle de tous les agents disponibles.

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                         CLAUDE CODE AGENTS - CHEATSHEET                       ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║  Total: 119 commands | 57 agents | 41 skills | 9 catégories                  ║
╚═══════════════════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────────────────┐
│                              ASSISTANT                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│   ┌────────────┐                                                            │
│   │ ASSISTANT  │  Orchestrateur : guide le choix des agents et workflows    │
│   └────────────┘                                                            │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                           WORK- : WORKFLOW PRINCIPAL                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐            │
│   │ EXPLORE  │ →  │   PLAN   │ →  │  COMMIT  │ →  │    PR    │            │
│   │          │    │          │    │          │    │          │            │
│   │ Comprend │    │ Conçoit  │    │ Enregistre    │ Partage  │            │
│   └──────────┘    └──────────┘    └──────────┘    └──────────┘            │
│                                                                             │
│   Workflows chaînés:                                                        │
│   ┌────────────────┐ ┌────────────────┐ ┌────────────────┐ ┌─────────────┐ │
│   │ flow-feature   │ │ flow-bugfix    │ │ flow-release   │ │ flow-launch │ │
│   │ Feature A→Z    │ │ Bug A→Z        │ │ Release A→Z    │ │ Produit A→Z │ │
│   └────────────────┘ └────────────────┘ └────────────────┘ └─────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                           DEV- : DÉVELOPPEMENT                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌──────────┐  ┌─────────┐        │
│   │   TDD   │  │  TEST   │  │  DEBUG  │  │ REFACTOR │  │   API   │        │
│   │ 🔴→🟢→♻️ │  │ Génère  │  │ Diagnos │  │ Améliore │  │ REST    │        │
│   └─────────┘  └─────────┘  └─────────┘  └──────────┘  └─────────┘        │
│                                                                             │
│   ┌───────────┐  ┌─────────┐  ┌──────────────┐  ┌───────────────┐         │
│   │ COMPONENT │  │  HOOK   │  │ERROR-HANDLING│  │ API-VERSIONING│         │
│   │ UI+Tests  │  │ Custom  │  │ Gestion err  │  │ Versions API  │         │
│   └───────────┘  └─────────┘  └──────────────┘  └───────────────┘         │
│                                                                             │
│   ┌──────────────┐  ┌─────────┐  ┌──────────┐  ┌─────────┐                │
│   │ TESTING-SETUP│  │ FLUTTER │  │ SUPABASE │  │ GRAPHQL │                │
│   │ Config tests │  │ Mobile  │  │ Backend  │  │ API GQL │                │
│   └──────────────┘  └─────────┘  └──────────┘  └─────────┘                │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                              QA- : QUALITÉ                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌──────────┐  ┌──────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐       │
│   │  REVIEW  │  │ SECURITY │  │  PERF   │  │  A11Y   │  │  AUDIT  │       │
│   │ Code Rev │  │ OWASP    │  │ Optim   │  │ WCAG    │  │ Complet │       │
│   └──────────┘  └──────────┘  └─────────┘  └─────────┘  └─────────┘       │
│                                                                             │
│   ┌────────────┐  ┌────────────┐  ┌──────────┐  ┌──────────┐              │
│   │ RESPONSIVE │  │ AUTOMATION │  │ COVERAGE │  │  MOBILE  │              │
│   │ Mobile web │  │ Tests auto │  │ Couvert. │  │ Flutter  │              │
│   └────────────┘  └────────────┘  └──────────┘  └──────────┘              │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                            OPS- : OPÉRATIONS                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐        │
│   │ HOTFIX  │  │ RELEASE │  │  DEPS   │  │ DOCKER  │  │ MIGRATE │        │
│   │ Urgent  │  │ Version │  │ MAJ     │  │ Contain │  │ Code    │        │
│   └─────────┘  └─────────┘  └─────────┘  └─────────┘  └─────────┘        │
│                                                                             │
│   ┌─────────┐  ┌────────────┐  ┌──────────┐  ┌─────────┐  ┌─────────┐    │
│   │   CI    │  │ MONITORING │  │ DATABASE │  │ HEALTH  │  │   ENV   │    │
│   │ CI/CD   │  │ Observ     │  │ Schema   │  │ Check   │  │ Config  │    │
│   └─────────┘  └────────────┘  └──────────┘  └─────────┘  └─────────┘    │
│                                                                             │
│   ┌─────────┐  ┌──────────────┐  ┌─────────────────┐  ┌───────────────┐   │
│   │ BACKUP  │  │ LOAD-TESTING │  │ COST-OPTIMIZ.   │  │DISASTER-RECOV │   │
│   │ Restore │  │ Stress test  │  │ Réduire coûts   │  │ Plan reprise  │   │
│   └─────────┘  └──────────────┘  └─────────────────┘  └───────────────┘   │
│                                                                             │
│   ┌────────────┐  ┌───────────────────┐                                    │
│   │ INFRA-CODE │  │ SECRETS-MANAGEMENT│                                    │
│   │ Terraform  │  │ Gestion secrets   │                                    │
│   └────────────┘  └───────────────────┘                                    │
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
│                          GROWTH- : CROISSANCE                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────┐  ┌─────────┐  ┌───────────┐  ┌────────────┐  ┌─────────┐   │
│   │ LANDING │  │   SEO   │  │ ANALYTICS │  │ ONBOARDING │  │  EMAIL  │   │
│   │ Page    │  │ Ranking │  │ Tracking  │  │ UX Flow    │  │ Templat │   │
│   └─────────┘  └─────────┘  └───────────┘  └────────────┘  └─────────┘   │
│                                                                             │
│   ┌─────────┐  ┌───────────┐  ┌─────────┐                                 │
│   │ AB-TEST │  │ RETENTION │  │ FUNNEL  │                                 │
│   │ Expérim │  │ Fidélis.  │  │ Tunnel  │                                 │
│   └─────────┘  └───────────┘  └─────────┘                                 │
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
║  WORKFLOW QUOTIDIEN:                                                          ║
║  ┌────────────────────────────────────────────────────────────────────────┐  ║
║  │  /work-explore → /work-plan → CODE → /work-pr │  ║
║  └────────────────────────────────────────────────────────────────────────┘  ║
║                                                                               ║
║  NOUVELLE FEATURE:        /work-flow-feature "description"            ║
║  CORRECTION BUG:          /work-flow-bugfix "issue #123"              ║
║  NOUVELLE RELEASE:        /work-flow-release "v2.0"                   ║
║  LANCEMENT PRODUIT:       /work-flow-launch "mon SaaS"                ║
║                                                                               ║
║  AUDIT COMPLET:           /qa-audit                                   ║
║  HEALTH CHECK RAPIDE:     /ops-health                                 ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

---

## Commandes par Catégorie (119)

### Orchestrateur (1)

| Commande | Usage |
|----------|-------|
| `/assistant` | Guide de choix des agents et workflows |

### WORK- : Workflow Principal (10)

| Commande | Usage |
|----------|-------|
| `/work-explore` | Explorer et comprendre le code |
| `/work-specify` | Créer une spécification fonctionnelle |
| `/work-clarify` | Clarifier les ambiguïtés |
| `/work-plan` | Planifier une implémentation |
| `/work-commit` | Créer un commit propre |
| `/work-pr` | Créer une Pull Request |
| `/work-flow-feature` | Workflow feature complet |
| `/work-flow-bugfix` | Workflow bugfix complet |
| `/work-flow-release` | Workflow release complet |
| `/work-flow-launch` | Workflow lancement complet |

### DEV- : Développement (23)

| Commande | Usage |
|----------|-------|
| `/dev-tdd` | Développement TDD |
| `/dev-test` | Générer des tests |
| `/dev-testing-setup` | Configurer infrastructure tests |
| `/dev-debug` | Déboguer un problème |
| `/dev-refactor` | Refactoring guidé |
| `/dev-document` | Génération documents (PDF, DOCX, XLSX, PPTX) |
| `/dev-api` | Créer/documenter API REST |
| `/dev-api-versioning` | Versioning d'API |
| `/dev-component` | Créer un composant UI complet |
| `/dev-hook` | Créer un hook React/Vue |
| `/dev-error-handling` | Stratégie de gestion d'erreurs |
| `/dev-react-perf` | Optimisation React/Next.js |
| `/dev-mcp` | Créer des serveurs MCP |
| `/dev-flutter` | Widgets et screens Flutter |
| `/dev-supabase` | Backend Supabase (Auth, DB, Storage) |
| `/dev-graphql` | API GraphQL client/serveur |
| `/dev-neovim` | Plugins et config Neovim |
| `/dev-design-system` | Design tokens et composants |
| `/dev-prisma` | ORM Prisma |
| `/dev-prompt-engineering` | Optimisation prompts LLM |
| `/dev-rag` | Systèmes RAG |
| `/dev-trpc` | APIs type-safe tRPC |
| `/dev-ai-integration` | Intégration LLMs (OpenAI, Claude) |

### QA- : Qualité (15)

| Commande | Usage |
|----------|-------|
| `/qa-review` | Code review + analyse nommage |
| `/qa-security` | Audit sécurité OWASP |
| `/qa-perf` | Analyse performance |
| `/qa-a11y` | Audit accessibilité WCAG |
| `/qa-audit` | Audit complet (tout en un) |
| `/qa-design` | Audit UI/UX (100+ règles) |
| `/qa-responsive` | Audit responsive/mobile |
| `/qa-automation` | Automatisation des tests |
| `/qa-coverage` | Analyse couverture tests |
| `/qa-e2e` | Tests E2E (Playwright, Cypress) |
| `/qa-kaizen` | Amélioration continue |
| `/qa-mobile` | Audit qualité apps mobiles |
| `/qa-neovim` | Audit config Neovim |
| `/qa-tech-debt` | Dette technique |
| `/qa-chrome` | Tests visuels Chrome |

### OPS- : Opérations (30)

| Commande | Usage |
|----------|-------|
| `/ops-hotfix` | Correction urgente production |
| `/ops-release` | Créer une release |
| `/ops-rollback` | Rollback sécurisé |
| `/ops-gitflow-init` | Initialiser GitFlow |
| `/ops-gitflow-feature` | Branches feature |
| `/ops-gitflow-release` | Branches release |
| `/ops-gitflow-hotfix` | Hotfixes GitFlow |
| `/ops-deps` | Audit et MAJ dépendances |
| `/ops-docker` | Dockeriser |
| `/ops-k8s` | Déploiement Kubernetes |
| `/ops-vps` | Déploiement VPS |
| `/ops-migrate` | Migration code/deps |
| `/ops-ci` | Pipelines CI/CD |
| `/ops-monitoring` | Logs, métriques, alertes |
| `/ops-observability-stack` | Prometheus, Grafana, Loki |
| `/ops-grafana-dashboard` | Dashboards Grafana |
| `/ops-database` | Schema, migrations DB |
| `/ops-health` | Health check rapide |
| `/ops-env` | Gestion environnements |
| `/ops-backup` | Stratégie backup/restore |
| `/ops-load-testing` | Tests de charge |
| `/ops-cost-optimization` | Optimisation coûts cloud |
| `/ops-disaster-recovery` | Plan reprise sinistre |
| `/ops-infra-code` | Infrastructure as Code |
| `/ops-proxmox` | Infrastructure Proxmox VE |
| `/ops-opnsense` | Configuration OPNsense |
| `/ops-secrets-management` | Gestion secrets |
| `/ops-serverless` | Déploiement serverless |
| `/ops-vercel` | Configuration Vercel |
| `/ops-mobile-release` | Publication App/Play Store |

### DOC- : Documentation (9)

| Commande | Usage |
|----------|-------|
| `/doc-generate` | Générer documentation |
| `/doc-changelog` | Changelog |
| `/doc-explain` | Expliquer code complexe |
| `/doc-onboard` | Découvrir un codebase |
| `/doc-i18n` | Internationalisation |
| `/doc-fix-issue` | Corriger issue GitHub |
| `/doc-api-spec` | Spec OpenAPI/Swagger |
| `/doc-readme` | Créer/améliorer README |
| `/doc-architecture` | Documenter l'architecture |

### BIZ- : Business (11)

| Commande | Usage |
|----------|-------|
| `/biz-model` | Business model, Lean Canvas |
| `/biz-market` | Étude de marché |
| `/biz-mvp` | Définir le MVP |
| `/biz-pricing` | Stratégie tarifaire |
| `/biz-pitch` | Pitch deck |
| `/biz-roadmap` | Roadmap produit |
| `/biz-launch` | Workflow lancement |
| `/biz-competitor` | Analyse concurrentielle |
| `/biz-okr` | OKRs |
| `/biz-personas` | Personas utilisateur |
| `/biz-research` | Recherche utilisateur |

### GROWTH- : Croissance (11)

| Commande | Usage |
|----------|-------|
| `/growth-landing` | Landing page |
| `/growth-seo` | Audit SEO |
| `/growth-analytics` | Tracking et KPIs |
| `/growth-app-store-analytics` | Métriques App/Play Store |
| `/growth-onboarding` | Parcours utilisateur |
| `/growth-email` | Templates email |
| `/growth-ab-test` | A/B testing |
| `/growth-retention` | Stratégies rétention |
| `/growth-funnel` | Analyse funnels |
| `/growth-localization` | Localisation multi-marchés |
| `/growth-cro` | Optimisation conversion (CRO) |

### DATA- : Données (3)

| Commande | Usage |
|----------|-------|
| `/data-pipeline` | Pipelines ETL/ELT |
| `/data-analytics` | Analyse de données |
| `/data-modeling` | Modélisation data warehouse |

### LEGAL- : Légal (5)

| Commande | Usage |
|----------|-------|
| `/legal-docs` | CGU, CGV, mentions légales |
| `/legal-rgpd` | Conformité RGPD/GDPR |
| `/legal-payment` | Intégration paiement |
| `/legal-terms-of-service` | Conditions Générales d'Utilisation |
| `/legal-privacy-policy` | Politique de Confidentialité |

---

## Scénarios Courants

### Nouveau projet
```
/doc-onboard     → Comprendre la structure
/work-explore    → Explorer le code
/work-plan       → Planifier le travail
```

### Nouvelle feature (rapide)
```
/work-explore    → Comprendre l'existant
/work-plan       → Designer la solution
/dev-tdd         → Implémenter avec tests
/work-commit     → Commiter proprement
/work-pr         → Créer la PR
```

### Nouvelle feature (workflow complet)
```
/work-flow-feature "ajouter dark mode"
```

### Correction de bug
```
/work-flow-bugfix "#123 - utilisateur ne peut pas se connecter"
```

### Avant mise en prod
```
/qa-audit        → Audit complet
/ops-health      → Health check rapide
```

### Nouvelle release
```
/work-flow-release "v2.0.0"
```

### Lancer un nouveau business
```
/work-flow-launch "mon nouveau SaaS"
```

### Application mobile Flutter
```
/work-explore → /work-plan → /dev-flutter + /dev-supabase → /qa-mobile → /work-pr
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
3. **Commits atomiques** - Un commit = une préoccupation
4. **Tests first (TDD)** - Code plus robuste
5. **Review régulière** - Qualité constante
6. **Pas de secrets dans le code** - Utiliser `.env`

---

## Ressources

- [Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Documentation officielle](https://code.claude.com/docs/en/overview)

---

*Claude-Socle v1.19.0 - 119 commands - 57 agents - 41 skills - 21 rules*
