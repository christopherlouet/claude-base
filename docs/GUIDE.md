# Guide Complet : Maîtriser claude-socle

> Ce guide vous accompagne pas à pas pour utiliser efficacement les 57 agents de claude-socle et adopter le workflow optimal.

## Table des matières

- [1. Le Workflow Fondamental](#1-le-workflow-fondamental)
- [2. Les 57 Agents par Catégorie](#2-les-57-agents-par-catégorie)
  - [2.1 WORK- : Workflow Principal](#21-work---workflow-principal)
  - [2.2 DEV- : Développement](#22-dev---développement)
  - [2.3 QA- : Qualité](#23-qa---qualité)
  - [2.4 OPS- : Opérations](#24-ops---opérations)
  - [2.5 DOC- : Documentation](#25-doc---documentation)
  - [2.6 BIZ- : Business](#26-biz---business)
  - [2.7 GROWTH- : Croissance](#27-growth---croissance)
  - [2.8 LEGAL- : Légal](#28-legal---légal)
- [3. Scénarios Pratiques](#3-scénarios-pratiques)
- [4. Configuration Avancée](#4-configuration-avancée)
- [5. Astuces de Pro](#5-astuces-de-pro)
- [6. Pièges à Éviter](#6-pièges-à-éviter)
- [7. Récapitulatif Rapide](#7-récapitulatif-rapide)

---

## 1. Le Workflow Fondamental

### La règle d'or : EXPLORE → PLAN → CODE → COMMIT

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│ EXPLORE  │ →  │   PLAN   │ →  │   CODE   │ →  │  COMMIT  │
│          │    │          │    │          │    │          │
│Comprendre│    │ Concevoir│    │Implémenter│    │Documenter│
└──────────┘    └──────────┘    └──────────┘    └──────────┘
```

### Format des commandes

```
/{category}-{action} "contexte"

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

### Pourquoi ce workflow ?

- **Évite le code "à l'aveugle"** qui génère des bugs
- **Force la réflexion** avant l'action
- **Produit des commits propres** et traçables
- **Facilite les code reviews**

---

## 2. Les 57 Agents par Catégorie

### 2.1 WORK- : Workflow Principal (8 agents)

#### `/work-explore` - L'Enquêteur

**Quand l'utiliser :**
- Avant de toucher au code existant
- Pour comprendre une architecture inconnue
- Pour identifier les patterns en place

**Exemples pratiques :**
```
/work-explore le système d'authentification
/work-explore comment les erreurs sont gérées
/work-explore la structure de la base de données
```

---

#### `/work-plan` - L'Architecte

**Quand l'utiliser :**
- Avant toute fonctionnalité non-triviale
- Pour obtenir une validation avant de coder

**Exemples pratiques :**
```
/work-plan ajouter l'authentification OAuth2 Google
/work-plan migrer de REST à GraphQL
```

---

#### `/work-commit` - Le Scribe

**Format Conventional Commits :**
```
type(scope): description courte (≤50 chars)

Corps optionnel expliquant le "pourquoi"

Closes #123
```

---

#### `/work-pr` - Le Communicant

**Quand l'utiliser :**
- Après avoir terminé une feature branch
- Pour créer une PR complète et documentée

---

#### Workflows Chaînés

| Commande | Usage |
|----------|-------|
| `/work-flow-feature` | Workflow complet feature (explore→plan→code→pr) |
| `/work-flow-bugfix` | Workflow complet bugfix (debug→test→fix→pr) |
| `/work-flow-release` | Workflow complet release (audit→changelog→tag→deploy) |
| `/work-flow-launch` | Workflow complet lancement produit |

**Exemple :**
```bash
# Au lieu de faire manuellement chaque étape
/work-flow-feature "ajouter le dark mode"

# Le workflow enchaîne automatiquement:
# 1. Explore → 2. Plan → 3. TDD → 4. Review → 5. Commit → 6. PR
```

---

### 2.2 DEV- : Développement (7 agents)

#### `/dev-tdd` - Le Testeur First

**Le cycle TDD :**
```
┌───────┐      ┌───────┐      ┌──────────┐
│  RED  │  →   │ GREEN │  →   │ REFACTOR │
│ Test  │      │ Code  │      │ Nettoyer │
│ fail  │      │ pass  │      │          │
└───────┘      └───────┘      └──────────┘
```

**Exemple :**
```
/dev-tdd fonction de validation d'email
```

---

#### `/dev-test` - Le Générateur de Tests

```
/dev-test src/services/user-service.ts
```

---

#### `/dev-debug` - Le Détective

```
/dev-debug erreur 500 sur /api/orders quand panier vide
```

---

#### `/dev-refactor` - Le Chirurgien

```
/dev-refactor src/components/UserForm.tsx
```

---

#### `/dev-api` - L'API Designer

```
/dev-api créer endpoint CRUD pour les produits
```

---

#### `/dev-component` - Le Créateur de Composants

**Crée un composant complet avec :**
- Code du composant
- Tests unitaires
- Stories Storybook
- Types TypeScript

```
/dev-component créer un composant Button avec variantes
```

---

#### `/dev-hook` - Le Créateur de Hooks

**Crée un hook React/Vue avec :**
- Code du hook
- Tests unitaires
- Documentation
- Exemples d'utilisation

```
/dev-hook créer un hook useLocalStorage
```

---

### 2.3 QA- : Qualité (6 agents)

#### `/qa-review` - Le Reviewer

```
/qa-review mes changements avant PR
```

---

#### `/qa-security` - Le Gardien

**Audit OWASP Top 10**

```
/qa-security audit du module de paiement
```

---

#### `/qa-perf` - L'Optimiseur

```
/qa-perf la page Dashboard charge en 8s
```

---

#### `/qa-a11y` - L'Inclusif

**Audit WCAG 2.1**

```
/qa-a11y audit du formulaire d'inscription
```

---

#### `/qa-audit` - L'Auditeur Complet

**Combine tous les audits en un :**
- Sécurité (OWASP)
- RGPD
- Accessibilité (WCAG)
- Performance
- Qualité de code

```
/qa-audit avant mise en production
```

---

#### `/qa-responsive` - Le Mobile Expert

**Audit responsive et mobile-first**

```
/qa-responsive vérifier l'affichage mobile
```

---

### 2.4 OPS- : Opérations (11 agents)

#### `/ops-hotfix` - Le Pompier

```
/ops-hotfix les paiements échouent en production
```

---

#### `/ops-release` - Le Release Manager

```
/ops-release 2.1.0
```

---

#### `/ops-deps` - Le Gardien des Dépendances

```
/ops-deps audit et mise à jour
```

---

#### `/ops-docker` - Le Containeriseur

```
/ops-docker containeriser l'application
```

---

#### `/ops-migrate` - Le Migrateur

```
/ops-migrate de Express à Fastify
```

---

#### `/ops-ci` - L'Automatiseur CI/CD

```
/ops-ci configurer GitHub Actions
```

---

#### `/ops-monitoring` - L'Observateur

```
/ops-monitoring mettre en place les alertes
```

---

#### `/ops-database` - Le DBA

```
/ops-database optimiser les requêtes lentes
```

---

#### `/ops-health` - Le Médecin Express

**Diagnostic rapide (5 min) :**

```
/ops-health
```

---

#### `/ops-env` - Le Gestionnaire d'Environnements

```
/ops-env configurer les variables par environnement
```

---

#### `/ops-backup` - Le Protecteur de Données

```
/ops-backup stratégie de backup PostgreSQL
```

---

### 2.5 DOC- : Documentation (7 agents)

#### `/doc-generate` - Le Documentaliste

```
/doc-generate API endpoints
```

---

#### `/doc-changelog` - L'Historien

```
/doc-changelog depuis la dernière release
```

---

#### `/doc-explain` - Le Professeur

```
/doc-explain src/services/payment-processor.ts
```

---

#### `/doc-onboard` - Le Guide

```
/doc-onboard
```

---

#### `/doc-i18n` - L'Internationalisateur

```
/doc-i18n ajouter le support français
```

---

#### `/doc-fix-issue` - Le Résolveur d'Issues

```
/doc-fix-issue #42
```

---

#### `/doc-api-spec` - Le Spécificateur

**Génère une spec OpenAPI/Swagger**

```
/doc-api-spec générer la documentation API
```

---

### 2.6 BIZ- : Business (9 agents)

#### `/biz-model` - L'Analyste Business

```
/biz-model analyser ce projet SaaS
```

---

#### `/biz-market` - L'Analyste Marché

```
/biz-market analyse concurrentielle pour un outil de gestion
```

---

#### `/biz-mvp` - Le Stratège Produit

```
/biz-mvp définir le MVP pour une app de livraison
```

---

#### `/biz-pricing` - Le Stratège Prix

```
/biz-pricing définir les plans tarifaires
```

---

#### `/biz-pitch` - Le Présentateur

```
/biz-pitch préparer une présentation investisseurs
```

---

#### `/biz-roadmap` - Le Planificateur

```
/biz-roadmap planifier les 6 prochains mois
```

---

#### `/biz-launch` - Le Lanceur

**Workflow complet de lancement business**

```
/biz-launch nouveau SaaS de gestion de projet
```

---

#### `/biz-competitor` - L'Analyste Concurrentiel

```
/biz-competitor analyser Notion comme concurrent
```

---

#### `/biz-okr` - Le Définisseur d'Objectifs

```
/biz-okr définir les OKRs du trimestre
```

---

### 2.7 GROWTH- : Croissance (6 agents)

#### `/growth-landing` - Le Convertisseur

```
/growth-landing créer la landing page du produit
```

---

#### `/growth-seo` - L'Optimiseur SEO

```
/growth-seo audit complet du site
```

---

#### `/growth-analytics` - Le Data Analyst

```
/growth-analytics définir les KPIs produit
```

---

#### `/growth-onboarding` - Le Guide Utilisateur

```
/growth-onboarding concevoir l'onboarding utilisateur
```

---

#### `/growth-email` - Le Marketeur Email

```
/growth-email créer les templates d'onboarding
```

---

#### `/growth-ab-test` - L'Expérimentateur

```
/growth-ab-test planifier un test sur le CTA principal
```

---

### 2.8 LEGAL- : Légal (3 agents)

#### `/legal-docs` - Le Juriste

```
/legal-docs générer les CGU et CGV
```

---

#### `/legal-rgpd` - Le Protecteur des Données

```
/legal-rgpd audit complet de l'application
```

---

#### `/legal-payment` - L'Intégrateur Paiements

```
/legal-payment intégrer Stripe pour les abonnements
```

---

## 3. Scénarios Pratiques

### Scénario A : Nouvelle Fonctionnalité (Workflow Complet)

```bash
# Option 1 : Workflow automatisé
/work-flow-feature "ajouter notifications push mobile"

# Option 2 : Manuellement
/work-explore le système de notifications actuel
/work-plan ajouter notifications push mobile
/dev-tdd service de notifications push
/qa-review mes changements
/work-commit
/work-pr notifications push mobile
```

---

### Scénario B : Corriger un Bug

```bash
# Option 1 : Workflow automatisé
/work-flow-bugfix "#123 - emails de confirmation n'arrivent pas"

# Option 2 : Manuellement
/dev-debug les emails de confirmation n'arrivent pas
/dev-tdd fix du service email
/work-commit
```

---

### Scénario C : Nouvelle Release

```bash
# Workflow automatisé
/work-flow-release "v2.0.0"
```

---

### Scénario D : Lancement d'un Nouveau Business

```bash
# Option 1 : Workflow automatisé complet
/work-flow-launch "mon nouveau SaaS"

# Option 2 : Étape par étape
/biz-model analyser le potentiel commercial
/biz-market étude concurrentielle
/biz-mvp définir les fonctionnalités essentielles
/biz-pricing définir les plans tarifaires
/growth-landing créer la landing page
/growth-seo optimiser pour le référencement
/legal-payment intégrer Stripe
/legal-docs générer CGU, CGV
/legal-rgpd audit conformité
/growth-analytics définir les KPIs
/biz-pitch préparer le deck investisseurs
```

---

### Scénario E : Audit Complet Avant Production

```bash
/qa-audit
```

---

### Scénario F : Health Check Rapide

```bash
/ops-health
```

---

## 4. Configuration Avancée

### 4.1 Permissions (`.claude/settings.json`)

```json
{
  "permissions": {
    "allow": [
      "Edit",
      "Write",
      "Bash(npm test:*)",
      "Bash(npm run lint:*)"
    ],
    "deny": [
      "Bash(git push --force:*)",
      "Bash(rm -rf:*)"
    ]
  }
}
```

### 4.2 Hooks (`.claude/hooks.json`)

```json
{
  "hooks": {
    "post-edit": {
      "commands": [
        {
          "pattern": "*.ts",
          "command": "npx eslint --fix ${file}",
          "enabled": true
        }
      ]
    }
  }
}
```

---

## 5. Astuces de Pro

### Astuce 1 : Utiliser les workflows chaînés

```bash
# Au lieu de 6 commandes manuelles
/work-flow-feature "ajouter dark mode"
```

### Astuce 2 : Être précis dans les demandes

```bash
# ❌ Trop vague
/dev-debug ça marche pas

# ✅ Précis et actionnable
/dev-debug erreur 401 sur POST /api/users quand token expiré
```

### Astuce 3 : Health check quotidien

```bash
# Chaque matin
/ops-health
```

### Astuce 4 : Audit complet avant release

```bash
# Avant chaque mise en production
/qa-audit
```

---

## 6. Pièges à Éviter

| ❌ Ne pas faire | ✅ Faire |
|-----------------|----------|
| Coder sans `/work-explore` | Toujours explorer d'abord |
| Implémenter sans `/work-plan` | Valider le plan avant de coder |
| Commits géants multi-features | Un commit = une préoccupation |
| Ignorer `/qa-security` | Audit régulier |
| `any` partout en TypeScript | Définir des types stricts |
| Skip les tests | Minimum 80% de couverture |

---

## 7. Récapitulatif Rapide

### Par besoin

| Besoin | Agent |
|--------|-------|
| Comprendre du code | `/work-explore` |
| Planifier une feature | `/work-plan` |
| Développer avec tests | `/dev-tdd` |
| Corriger un bug | `/dev-debug` |
| Code review | `/qa-review` |
| Vérifier la sécurité | `/qa-security` |
| Audit complet | `/qa-audit` |
| Health check rapide | `/ops-health` |
| Créer un commit | `/work-commit` |
| Créer une PR | `/work-pr` |
| Feature complète | `/work-flow-feature` |
| Bugfix complet | `/work-flow-bugfix` |
| Release complète | `/work-flow-release` |
| Lancement produit | `/work-flow-launch` |

### Par catégorie

```
WORK   (8)  = Workflow de base + workflows chaînés
DEV    (7)  = Développement (tdd, test, debug, refactor, api, component, hook)
QA     (6)  = Qualité (review, security, perf, a11y, audit, responsive)
OPS   (11)  = Opérations (hotfix, release, deps, docker, migrate, ci, monitoring, database, health, env, backup)
DOC    (7)  = Documentation (generate, changelog, explain, onboard, i18n, fix-issue, api-spec)
BIZ    (9)  = Business (model, market, mvp, pricing, pitch, roadmap, launch, competitor, okr)
GROWTH (6)  = Croissance (landing, seo, analytics, onboarding, email, ab-test)
LEGAL  (3)  = Légal (docs, rgpd, payment)
```

---

## Conclusion

Le principe clé de claude-socle est simple : **toujours EXPLORE → PLAN → CODE → COMMIT** pour un workflow professionnel et maintenable.

Les workflows chaînés (`/work-flow-*`) automatisent ce processus pour les cas courants.

Bonne programmation !
