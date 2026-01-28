---
sidebar_position: 4
title: Cheatsheet
description: Aide-memoire rapide claude-socle
---

# Cheatsheet

> Aide-memoire rapide - imprimable format A4

## Workflow principal

```mermaid
graph LR
    E[🔍 EXPLORE<br/>/work-explore] --> P[📋 PLAN<br/>/work-plan]
    P --> C[💻 CODE<br/>/dev-tdd]
    C --> M[✅ COMMIT<br/>/work-commit]

    style E fill:#e3f2fd
    style P fill:#fff3e0
    style C fill:#e8f5e9
    style M fill:#fce4ec
```

## Commandes essentielles

| Commande | Usage |
|----------|-------|
| `/assistant` | Guide complet, aide au choix (avec confirmation) |
| `/assistant-auto` | Execution automatique du workflow adapte |
| `/work-explore` | Comprendre le code |
| `/work-plan` | Planifier les changements |
| `/dev-tdd` | Developper en TDD |
| `/work-commit` | Commit propre |
| `/work-pr` | Pull Request |
| `/qa-audit` | Audit complet |

## Workflows pre-definis

| Commande | Pour |
|----------|------|
| `/work-flow-feature` | Nouvelle feature |
| `/work-flow-bugfix` | Correction bug |
| `/work-flow-release` | Preparer release |
| `/work-flow-launch` | Lancer produit |

## Par domaine

### WORK (Workflow)
```bash
/work-explore      # Comprendre
/work-plan         # Planifier
/work-commit       # Commiter
/work-pr           # Pull Request
```

### DEV (Developpement)
```bash
/dev-tdd           # TDD
/dev-test          # Tests
/dev-debug         # Debug
/dev-api           # API REST
/dev-component     # Composant UI
```

### QA (Qualite)
```bash
/qa-review         # Code review
/qa-security       # Securite OWASP
/qa-perf           # Performance
/qa-a11y           # Accessibilite
/qa-audit          # Audit complet
```

### OPS (Operations)
```bash
/ops-release       # Release
/ops-hotfix        # Hotfix urgent
/ops-ci            # CI/CD
/ops-docker        # Docker
/ops-monitoring    # Monitoring
```

### DOC (Documentation)
```bash
/doc-changelog     # Changelog
/doc-readme        # README
/doc-api-spec      # OpenAPI
/doc-architecture  # Architecture
```

### BIZ (Business)
```bash
/biz-model         # Business model
/biz-mvp           # Definition MVP
/biz-pricing       # Pricing
/biz-pitch         # Pitch deck
```

### GROWTH (Croissance)
```bash
/growth-landing    # Landing page
/growth-seo        # SEO
/growth-analytics  # Analytics
/growth-funnel     # Funnel
```

### LEGAL (Legal)
```bash
/legal-rgpd        # RGPD
/legal-terms-of-service   # CGU
/legal-privacy-policy     # Privacy
```

## GitFlow

```bash
# Initialiser
/ops-gitflow-init

# Feature
/ops-gitflow-feature start "ma-feature"
/ops-gitflow-feature finish "ma-feature"

# Release
/ops-gitflow-release start "v1.0.0"
/ops-gitflow-release finish "v1.0.0"

# Hotfix urgent
/ops-gitflow-hotfix start "fix-critical"
/ops-gitflow-hotfix finish "fix-critical"
```

## Composants

| Type | Nombre | Declenchement |
|------|--------|---------------|
| Commands | 118 | Manuel (`/nom`) |
| Agents | 56 | Automatique |
| Skills | 40 | Mots-cles |
| Rules | 20 | Par fichier |

## Modeles d'agents

| Modele | Usage | Vitesse |
|--------|-------|---------|
| Haiku | Taches simples | Rapide |
| Sonnet | Analyses complexes | Moyen |

## Format commit

```
type(scope): description

[corps optionnel]

[footer optionnel]
```

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `style`, `chore`, `perf`

## Aide

```bash
# Point d'entree (mode guide, avec confirmation)
/assistant

# Choisir le bon workflow
/assistant "Comment faire X ?"

# Execution automatique (utilisateurs avances)
/assistant-auto "Ajouter une feature d'authentification"

# Documentation
https://christopherlouet.github.io/claude-socle/
```

---

**claude-socle** | 118 Commands | 56 Agents | 40 Skills | 20 Rules
