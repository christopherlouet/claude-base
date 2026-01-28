# Cheatsheet - Claude Code Agents

> Référence visuelle de tous les agents disponibles.

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                         CLAUDE CODE AGENTS - CHEATSHEET                       ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║  Total: 118 commands | 56 agents | 40 skills | 9 catégories                    ║
╚═══════════════════════════════════════════════════════════════════════════════╝

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
│   ┌───────────┐  ┌─────────┐                                               │
│   │ COMPONENT │  │  HOOK   │                                               │
│   │ UI+Tests  │  │ Custom  │                                               │
│   └───────────┘  └─────────┘                                               │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                              QA- : QUALITÉ                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌──────────┐  ┌──────────┐  ┌─────────┐  ┌─────────┐                    │
│   │  REVIEW  │  │ SECURITY │  │  PERF   │  │  A11Y   │                    │
│   │ Code Rev │  │ OWASP    │  │ Optim   │  │ WCAG    │                    │
│   └──────────┘  └──────────┘  └─────────┘  └─────────┘                    │
│                                                                             │
│   ┌─────────┐  ┌────────────┐                                              │
│   │  AUDIT  │  │ RESPONSIVE │                                              │
│   │ Complet │  │ Mobile     │                                              │
│   └─────────┘  └────────────┘                                              │
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
│   ┌─────────┐  ┌────────────┐  ┌──────────┐  ┌─────────┐                  │
│   │   CI    │  │ MONITORING │  │ DATABASE │  │ HEALTH  │                  │
│   │ CI/CD   │  │ Observ     │  │ Schema   │  │ Check   │                  │
│   └─────────┘  └────────────┘  └──────────┘  └─────────┘                  │
│                                                                             │
│   ┌─────────┐  ┌─────────┐                                                 │
│   │   ENV   │  │ BACKUP  │                                                 │
│   │ Config  │  │ Restore │                                                 │
│   └─────────┘  └─────────┘                                                 │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          DOC- : DOCUMENTATION                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌──────────┐  ┌───────────┐  ┌─────────┐  ┌─────────┐                   │
│   │ GENERATE │  │ CHANGELOG │  │ EXPLAIN │  │ ONBOARD │                   │
│   │ Auto doc │  │ History   │  │ Pédago  │  │ Découvre│                   │
│   └──────────┘  └───────────┘  └─────────┘  └─────────┘                   │
│                                                                             │
│   ┌─────────┐  ┌───────────┐  ┌──────────┐                                │
│   │  I18N   │  │ FIX-ISSUE │  │ API-SPEC │                                │
│   │ Traduc  │  │ GitHub    │  │ OpenAPI  │                                │
│   └─────────┘  └───────────┘  └──────────┘                                │
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
│   ┌─────────┐  ┌─────────┐  ┌────────────┐  ┌─────────┐                   │
│   │ ROADMAP │  │ LAUNCH  │  │ COMPETITOR │  │   OKR   │                   │
│   │ Planning│  │ Go-to   │  │ Analyse    │  │ Object  │                   │
│   └─────────┘  └─────────┘  └────────────┘  └─────────┘                   │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          GROWTH- : CROISSANCE                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────┐  ┌─────────┐  ┌───────────┐  ┌────────────┐                 │
│   │ LANDING │  │   SEO   │  │ ANALYTICS │  │ ONBOARDING │                 │
│   │ Page    │  │ Ranking │  │ Tracking  │  │ UX Flow    │                 │
│   └─────────┘  └─────────┘  └───────────┘  └────────────┘                 │
│                                                                             │
│   ┌─────────┐  ┌─────────┐                                                 │
│   │  EMAIL  │  │ AB-TEST │                                                 │
│   │ Templat │  │ Expérim │                                                 │
│   └─────────┘  └─────────┘                                                 │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                             LEGAL- : LÉGAL                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────┐  ┌─────────┐  ┌─────────┐                                   │
│   │  DOCS   │  │  RGPD   │  │ PAYMENT │                                   │
│   │ CGU/CGV │  │ GDPR    │  │ Stripe  │                                   │
│   └─────────┘  └─────────┘  └─────────┘                                   │
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

## Commandes par Categorie (118)

### WORK- : Workflow Principal (10)

| Commande | Usage |
|----------|-------|
| `/work-explore` | Explorer et comprendre le code |
| `/work-specify` | Creer une specification fonctionnelle |
| `/work-clarify` | Clarifier les ambiguites |
| `/work-plan` | Planifier une implementation |
| `/work-commit` | Creer un commit propre |
| `/work-pr` | Creer une Pull Request |
| `/work-flow-feature` | Workflow feature complet |
| `/work-flow-bugfix` | Workflow bugfix complet |
| `/work-flow-release` | Workflow release complet |
| `/work-flow-launch` | Workflow lancement complet |

### DEV- : Developpement (23)

| Commande | Usage |
|----------|-------|
| `/dev-tdd` | Developpement TDD |
| `/dev-test` | Generer des tests |
| `/dev-testing-setup` | Configurer infrastructure tests |
| `/dev-debug` | Deboguer un probleme |
| `/dev-refactor` | Refactoring guide |
| `/dev-document` | Generation documents (PDF, DOCX, XLSX, PPTX) |
| `/dev-api` | Creer/documenter API |
| `/dev-api-versioning` | Versioning d'API |
| `/dev-component` | Creer un composant UI complet |
| `/dev-hook` | Creer un hook React/Vue |
| `/dev-error-handling` | Strategie gestion d'erreurs |
| `/dev-react-perf` | Optimisation React/Next.js |
| `/dev-mcp` | Creer des serveurs MCP |
| `/dev-flutter` | Widgets et screens Flutter |
| `/dev-supabase` | Backend Supabase |
| `/dev-graphql` | API GraphQL |
| `/dev-neovim` | Plugins et config Neovim |
| `/dev-design-system` | Design tokens et composants |
| `/dev-prisma` | ORM Prisma |
| `/dev-prompt-engineering` | Optimisation prompts LLM |
| `/dev-rag` | Systemes RAG |
| `/dev-trpc` | APIs type-safe tRPC |
| `/dev-ai-integration` | Integration LLMs (OpenAI, Claude) |

### QA- : Qualite (14)

| Commande | Usage |
|----------|-------|
| `/qa-review` | Code review + analyse nommage |
| `/qa-security` | Audit securite OWASP |
| `/qa-perf` | Analyse performance |
| `/qa-a11y` | Audit accessibilite WCAG |
| `/qa-audit` | Audit complet (tout en un) |
| `/qa-design` | Audit UI/UX (100+ regles) |
| `/qa-responsive` | Audit responsive/mobile |
| `/qa-automation` | Automatisation des tests |
| `/qa-coverage` | Analyse couverture tests |
| `/qa-e2e` | Tests E2E (Playwright, Cypress) |
| `/qa-kaizen` | Amelioration continue |
| `/qa-mobile` | Audit qualite apps mobiles |
| `/qa-neovim` | Audit config Neovim |
| `/qa-tech-debt` | Dette technique |

### OPS- : Operations (30)

| Commande | Usage |
|----------|-------|
| `/ops-hotfix` | Correction urgente prod |
| `/ops-release` | Creer une release |
| `/ops-rollback` | Rollback securise |
| `/ops-gitflow-init` | Initialiser GitFlow |
| `/ops-gitflow-feature` | Branches feature |
| `/ops-gitflow-release` | Branches release |
| `/ops-gitflow-hotfix` | Hotfixes GitFlow |
| `/ops-deps` | Audit et MAJ dependances |
| `/ops-docker` | Dockeriser |
| `/ops-k8s` | Deploiement Kubernetes |
| `/ops-vps` | Deploiement VPS |
| `/ops-migrate` | Migration code/deps |
| `/ops-ci` | Pipelines CI/CD |
| `/ops-monitoring` | Logs, metriques, alertes |
| `/ops-observability-stack` | Prometheus, Grafana, Loki |
| `/ops-grafana-dashboard` | Dashboards Grafana |
| `/ops-database` | Schema, migrations DB |
| `/ops-health` | Health check rapide |
| `/ops-env` | Gestion environnements |
| `/ops-backup` | Strategie backup/restore |
| `/ops-load-testing` | Tests de charge |
| `/ops-cost-optimization` | Optimisation couts cloud |
| `/ops-disaster-recovery` | Plan reprise sinistre |
| `/ops-infra-code` | Infrastructure as Code |
| `/ops-proxmox` | Infrastructure Proxmox VE |
| `/ops-opnsense` | Configuration OPNsense |
| `/ops-secrets-management` | Gestion secrets |
| `/ops-serverless` | Deploiement serverless |
| `/ops-vercel` | Configuration Vercel |
| `/ops-mobile-release` | Publication App/Play Store |

### DOC- : Documentation (9)

| Commande | Usage |
|----------|-------|
| `/doc-generate` | Generer documentation |
| `/doc-changelog` | Changelog |
| `/doc-explain` | Expliquer code complexe |
| `/doc-onboard` | Decouvrir un codebase |
| `/doc-i18n` | Internationalisation |
| `/doc-fix-issue` | Corriger issue GitHub |
| `/doc-api-spec` | Spec OpenAPI/Swagger |
| `/doc-readme` | Creer/ameliorer README |
| `/doc-architecture` | Documenter l'architecture |

### BIZ- : Business (11)

| Commande | Usage |
|----------|-------|
| `/biz-model` | Business model, Lean Canvas |
| `/biz-market` | Etude de marche |
| `/biz-mvp` | Definir le MVP |
| `/biz-pricing` | Strategie tarifaire |
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
| `/growth-app-store-analytics` | Metriques App/Play Store |
| `/growth-onboarding` | Parcours utilisateur |
| `/growth-email` | Templates email |
| `/growth-ab-test` | A/B testing |
| `/growth-retention` | Strategies retention |
| `/growth-funnel` | Analyse funnels |
| `/growth-localization` | Localisation multi-marches |
| `/growth-cro` | Optimisation conversion (CRO) |

### DATA- : Donnees (3)

| Commande | Usage |
|----------|-------|
| `/data-pipeline` | Pipelines ETL/ELT |
| `/data-analytics` | Analyse de donnees |
| `/data-modeling` | Modelisation data warehouse |

### LEGAL- : Legal (5)

| Commande | Usage |
|----------|-------|
| `/legal-docs` | CGU, CGV, mentions legales |
| `/legal-rgpd` | Conformite RGPD/GDPR |
| `/legal-payment` | Integration paiement |
| `/legal-terms-of-service` | CGU |
| `/legal-privacy-policy` | Politique confidentialite |

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

---

## Format des Commandes

```
/{category}-{action} "context"

Categories:
• work-   → Workflow de base
• dev-    → Développement
• qa-     → Qualité
• ops-    → Opérations
• doc-    → Documentation
• biz-    → Business
• growth- → Croissance
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
| `.claude/settings.json` | Permissions |
| `.claude/hooks.json` | Hooks automatiques |
| `.claude/commands/**/*.md` | Commandes (organisées par catégorie) |
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
- [Documentation](https://docs.anthropic.com/en/docs/claude-code)

---

*Claude-Socle v2.0 - 118 commands - 56 agents - 40 skills - 20 rules*
