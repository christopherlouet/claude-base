# Cheatsheet - Claude Code Agents

> Référence visuelle de tous les agents disponibles.

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                         CLAUDE CODE AGENTS - CHEATSHEET                       ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║  Total: 57 agents | 8 catégories | 4 workflows                                ║
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

## Agents par Catégorie (57)

### WORK- : Workflow Principal (8)

| Commande | Usage |
|----------|-------|
| `/work-explore` | Explorer et comprendre le code |
| `/work-plan` | Planifier une implémentation |
| `/work-commit` | Créer un commit propre |
| `/work-pr` | Créer une Pull Request |
| `/work-flow-feature` | Workflow feature complet |
| `/work-flow-bugfix` | Workflow bugfix complet |
| `/work-flow-release` | Workflow release complet |
| `/work-flow-launch` | Workflow lancement complet |

### DEV- : Développement (7)

| Commande | Usage |
|----------|-------|
| `/dev-tdd` | Développement TDD |
| `/dev-test` | Générer des tests |
| `/dev-debug` | Déboguer un problème |
| `/dev-refactor` | Refactoring guidé |
| `/dev-api` | Créer/documenter API |
| `/dev-component` | Créer un composant UI complet |
| `/dev-hook` | Créer un hook React/Vue |

### QA- : Qualité (6)

| Commande | Usage |
|----------|-------|
| `/qa-review` | Code review |
| `/qa-security` | Audit sécurité OWASP |
| `/qa-perf` | Analyse performance |
| `/qa-a11y` | Audit accessibilité WCAG |
| `/qa-audit` | Audit complet (tout en un) |
| `/qa-responsive` | Audit responsive/mobile |

### OPS- : Opérations (11)

| Commande | Usage |
|----------|-------|
| `/ops-hotfix` | Correction urgente prod |
| `/ops-release` | Créer une release |
| `/ops-deps` | Audit et MAJ dépendances |
| `/ops-docker` | Dockeriser |
| `/ops-migrate` | Migration code/deps |
| `/ops-ci` | Pipelines CI/CD |
| `/ops-monitoring` | Logs, métriques, alertes |
| `/ops-database` | Schéma, migrations DB |
| `/ops-health` | Health check rapide |
| `/ops-env` | Gestion environnements |
| `/ops-backup` | Stratégie backup/restore |

### DOC- : Documentation (7)

| Commande | Usage |
|----------|-------|
| `/doc-generate` | Générer documentation |
| `/doc-changelog` | Changelog |
| `/doc-explain` | Expliquer code complexe |
| `/doc-onboard` | Découvrir un codebase |
| `/doc-i18n` | Internationalisation |
| `/doc-fix-issue` | Corriger issue GitHub |
| `/doc-api-spec` | Spec OpenAPI/Swagger |

### BIZ- : Business (9)

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

### GROWTH- : Croissance (6)

| Commande | Usage |
|----------|-------|
| `/growth-landing` | Landing page |
| `/growth-seo` | Audit SEO |
| `/growth-analytics` | Tracking et KPIs |
| `/growth-onboarding` | Parcours utilisateur |
| `/growth-email` | Templates email |
| `/growth-ab-test` | A/B testing |

### LEGAL- : Légal (3)

| Commande | Usage |
|----------|-------|
| `/legal-docs` | CGU, CGV, mentions légales |
| `/legal-rgpd` | Conformité RGPD/GDPR |
| `/legal-payment` | Intégration paiement |

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

*Claude-Socle v2.0 - 57 agents - 8 catégories*
