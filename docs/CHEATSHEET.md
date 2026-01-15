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
║  │  /project:work-explore → /project:work-plan → CODE → /project:work-pr │  ║
║  └────────────────────────────────────────────────────────────────────────┘  ║
║                                                                               ║
║  NOUVELLE FEATURE:        /project:work-flow-feature "description"            ║
║  CORRECTION BUG:          /project:work-flow-bugfix "issue #123"              ║
║  NOUVELLE RELEASE:        /project:work-flow-release "v2.0"                   ║
║  LANCEMENT PRODUIT:       /project:work-flow-launch "mon SaaS"                ║
║                                                                               ║
║  AUDIT COMPLET:           /project:qa-audit                                   ║
║  HEALTH CHECK RAPIDE:     /project:ops-health                                 ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

---

## Agents par Catégorie (57)

### WORK- : Workflow Principal (8)

| Commande | Usage |
|----------|-------|
| `/project:work-explore` | Explorer et comprendre le code |
| `/project:work-plan` | Planifier une implémentation |
| `/project:work-commit` | Créer un commit propre |
| `/project:work-pr` | Créer une Pull Request |
| `/project:work-flow-feature` | Workflow feature complet |
| `/project:work-flow-bugfix` | Workflow bugfix complet |
| `/project:work-flow-release` | Workflow release complet |
| `/project:work-flow-launch` | Workflow lancement complet |

### DEV- : Développement (7)

| Commande | Usage |
|----------|-------|
| `/project:dev-tdd` | Développement TDD |
| `/project:dev-test` | Générer des tests |
| `/project:dev-debug` | Déboguer un problème |
| `/project:dev-refactor` | Refactoring guidé |
| `/project:dev-api` | Créer/documenter API |
| `/project:dev-component` | Créer un composant UI complet |
| `/project:dev-hook` | Créer un hook React/Vue |

### QA- : Qualité (6)

| Commande | Usage |
|----------|-------|
| `/project:qa-review` | Code review |
| `/project:qa-security` | Audit sécurité OWASP |
| `/project:qa-perf` | Analyse performance |
| `/project:qa-a11y` | Audit accessibilité WCAG |
| `/project:qa-audit` | Audit complet (tout en un) |
| `/project:qa-responsive` | Audit responsive/mobile |

### OPS- : Opérations (11)

| Commande | Usage |
|----------|-------|
| `/project:ops-hotfix` | Correction urgente prod |
| `/project:ops-release` | Créer une release |
| `/project:ops-deps` | Audit et MAJ dépendances |
| `/project:ops-docker` | Dockeriser |
| `/project:ops-migrate` | Migration code/deps |
| `/project:ops-ci` | Pipelines CI/CD |
| `/project:ops-monitoring` | Logs, métriques, alertes |
| `/project:ops-database` | Schéma, migrations DB |
| `/project:ops-health` | Health check rapide |
| `/project:ops-env` | Gestion environnements |
| `/project:ops-backup` | Stratégie backup/restore |

### DOC- : Documentation (7)

| Commande | Usage |
|----------|-------|
| `/project:doc-generate` | Générer documentation |
| `/project:doc-changelog` | Changelog |
| `/project:doc-explain` | Expliquer code complexe |
| `/project:doc-onboard` | Découvrir un codebase |
| `/project:doc-i18n` | Internationalisation |
| `/project:doc-fix-issue` | Corriger issue GitHub |
| `/project:doc-api-spec` | Spec OpenAPI/Swagger |

### BIZ- : Business (9)

| Commande | Usage |
|----------|-------|
| `/project:biz-model` | Business model, Lean Canvas |
| `/project:biz-market` | Étude de marché |
| `/project:biz-mvp` | Définir le MVP |
| `/project:biz-pricing` | Stratégie tarifaire |
| `/project:biz-pitch` | Pitch deck |
| `/project:biz-roadmap` | Roadmap produit |
| `/project:biz-launch` | Workflow lancement |
| `/project:biz-competitor` | Analyse concurrentielle |
| `/project:biz-okr` | OKRs |

### GROWTH- : Croissance (6)

| Commande | Usage |
|----------|-------|
| `/project:growth-landing` | Landing page |
| `/project:growth-seo` | Audit SEO |
| `/project:growth-analytics` | Tracking et KPIs |
| `/project:growth-onboarding` | Parcours utilisateur |
| `/project:growth-email` | Templates email |
| `/project:growth-ab-test` | A/B testing |

### LEGAL- : Légal (3)

| Commande | Usage |
|----------|-------|
| `/project:legal-docs` | CGU, CGV, mentions légales |
| `/project:legal-rgpd` | Conformité RGPD/GDPR |
| `/project:legal-payment` | Intégration paiement |

---

## Scénarios Courants

### Nouveau projet
```
/project:doc-onboard     → Comprendre la structure
/project:work-explore    → Explorer le code
/project:work-plan       → Planifier le travail
```

### Nouvelle feature (rapide)
```
/project:work-explore    → Comprendre l'existant
/project:work-plan       → Designer la solution
/project:dev-tdd         → Implémenter avec tests
/project:work-commit     → Commiter proprement
/project:work-pr         → Créer la PR
```

### Nouvelle feature (workflow complet)
```
/project:work-flow-feature "ajouter dark mode"
```

### Correction de bug
```
/project:work-flow-bugfix "#123 - utilisateur ne peut pas se connecter"
```

### Avant mise en prod
```
/project:qa-audit        → Audit complet
/project:ops-health      → Health check rapide
```

### Nouvelle release
```
/project:work-flow-release "v2.0.0"
```

### Lancer un nouveau business
```
/project:work-flow-launch "mon nouveau SaaS"
```

---

## Format des Commandes

```
/project:{category}-{action} "context"

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
| `.claude/commands/*.md` | Commandes custom |
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
