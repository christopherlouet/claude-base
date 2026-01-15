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
/project:{category}-{action} "contexte"

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

#### `/project:work-explore` - L'Enquêteur

**Quand l'utiliser :**
- Avant de toucher au code existant
- Pour comprendre une architecture inconnue
- Pour identifier les patterns en place

**Exemples pratiques :**
```
/project:work-explore le système d'authentification
/project:work-explore comment les erreurs sont gérées
/project:work-explore la structure de la base de données
```

---

#### `/project:work-plan` - L'Architecte

**Quand l'utiliser :**
- Avant toute fonctionnalité non-triviale
- Pour obtenir une validation avant de coder

**Exemples pratiques :**
```
/project:work-plan ajouter l'authentification OAuth2 Google
/project:work-plan migrer de REST à GraphQL
```

---

#### `/project:work-commit` - Le Scribe

**Format Conventional Commits :**
```
type(scope): description courte (≤50 chars)

Corps optionnel expliquant le "pourquoi"

Closes #123
```

---

#### `/project:work-pr` - Le Communicant

**Quand l'utiliser :**
- Après avoir terminé une feature branch
- Pour créer une PR complète et documentée

---

#### Workflows Chaînés

| Commande | Usage |
|----------|-------|
| `/project:work-flow-feature` | Workflow complet feature (explore→plan→code→pr) |
| `/project:work-flow-bugfix` | Workflow complet bugfix (debug→test→fix→pr) |
| `/project:work-flow-release` | Workflow complet release (audit→changelog→tag→deploy) |
| `/project:work-flow-launch` | Workflow complet lancement produit |

**Exemple :**
```bash
# Au lieu de faire manuellement chaque étape
/project:work-flow-feature "ajouter le dark mode"

# Le workflow enchaîne automatiquement:
# 1. Explore → 2. Plan → 3. TDD → 4. Review → 5. Commit → 6. PR
```

---

### 2.2 DEV- : Développement (7 agents)

#### `/project:dev-tdd` - Le Testeur First

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
/project:dev-tdd fonction de validation d'email
```

---

#### `/project:dev-test` - Le Générateur de Tests

```
/project:dev-test src/services/user-service.ts
```

---

#### `/project:dev-debug` - Le Détective

```
/project:dev-debug erreur 500 sur /api/orders quand panier vide
```

---

#### `/project:dev-refactor` - Le Chirurgien

```
/project:dev-refactor src/components/UserForm.tsx
```

---

#### `/project:dev-api` - L'API Designer

```
/project:dev-api créer endpoint CRUD pour les produits
```

---

#### `/project:dev-component` - Le Créateur de Composants

**Crée un composant complet avec :**
- Code du composant
- Tests unitaires
- Stories Storybook
- Types TypeScript

```
/project:dev-component créer un composant Button avec variantes
```

---

#### `/project:dev-hook` - Le Créateur de Hooks

**Crée un hook React/Vue avec :**
- Code du hook
- Tests unitaires
- Documentation
- Exemples d'utilisation

```
/project:dev-hook créer un hook useLocalStorage
```

---

### 2.3 QA- : Qualité (6 agents)

#### `/project:qa-review` - Le Reviewer

```
/project:qa-review mes changements avant PR
```

---

#### `/project:qa-security` - Le Gardien

**Audit OWASP Top 10**

```
/project:qa-security audit du module de paiement
```

---

#### `/project:qa-perf` - L'Optimiseur

```
/project:qa-perf la page Dashboard charge en 8s
```

---

#### `/project:qa-a11y` - L'Inclusif

**Audit WCAG 2.1**

```
/project:qa-a11y audit du formulaire d'inscription
```

---

#### `/project:qa-audit` - L'Auditeur Complet

**Combine tous les audits en un :**
- Sécurité (OWASP)
- RGPD
- Accessibilité (WCAG)
- Performance
- Qualité de code

```
/project:qa-audit avant mise en production
```

---

#### `/project:qa-responsive` - Le Mobile Expert

**Audit responsive et mobile-first**

```
/project:qa-responsive vérifier l'affichage mobile
```

---

### 2.4 OPS- : Opérations (11 agents)

#### `/project:ops-hotfix` - Le Pompier

```
/project:ops-hotfix les paiements échouent en production
```

---

#### `/project:ops-release` - Le Release Manager

```
/project:ops-release 2.1.0
```

---

#### `/project:ops-deps` - Le Gardien des Dépendances

```
/project:ops-deps audit et mise à jour
```

---

#### `/project:ops-docker` - Le Containeriseur

```
/project:ops-docker containeriser l'application
```

---

#### `/project:ops-migrate` - Le Migrateur

```
/project:ops-migrate de Express à Fastify
```

---

#### `/project:ops-ci` - L'Automatiseur CI/CD

```
/project:ops-ci configurer GitHub Actions
```

---

#### `/project:ops-monitoring` - L'Observateur

```
/project:ops-monitoring mettre en place les alertes
```

---

#### `/project:ops-database` - Le DBA

```
/project:ops-database optimiser les requêtes lentes
```

---

#### `/project:ops-health` - Le Médecin Express

**Diagnostic rapide (5 min) :**

```
/project:ops-health
```

---

#### `/project:ops-env` - Le Gestionnaire d'Environnements

```
/project:ops-env configurer les variables par environnement
```

---

#### `/project:ops-backup` - Le Protecteur de Données

```
/project:ops-backup stratégie de backup PostgreSQL
```

---

### 2.5 DOC- : Documentation (7 agents)

#### `/project:doc-generate` - Le Documentaliste

```
/project:doc-generate API endpoints
```

---

#### `/project:doc-changelog` - L'Historien

```
/project:doc-changelog depuis la dernière release
```

---

#### `/project:doc-explain` - Le Professeur

```
/project:doc-explain src/services/payment-processor.ts
```

---

#### `/project:doc-onboard` - Le Guide

```
/project:doc-onboard
```

---

#### `/project:doc-i18n` - L'Internationalisateur

```
/project:doc-i18n ajouter le support français
```

---

#### `/project:doc-fix-issue` - Le Résolveur d'Issues

```
/project:doc-fix-issue #42
```

---

#### `/project:doc-api-spec` - Le Spécificateur

**Génère une spec OpenAPI/Swagger**

```
/project:doc-api-spec générer la documentation API
```

---

### 2.6 BIZ- : Business (9 agents)

#### `/project:biz-model` - L'Analyste Business

```
/project:biz-model analyser ce projet SaaS
```

---

#### `/project:biz-market` - L'Analyste Marché

```
/project:biz-market analyse concurrentielle pour un outil de gestion
```

---

#### `/project:biz-mvp` - Le Stratège Produit

```
/project:biz-mvp définir le MVP pour une app de livraison
```

---

#### `/project:biz-pricing` - Le Stratège Prix

```
/project:biz-pricing définir les plans tarifaires
```

---

#### `/project:biz-pitch` - Le Présentateur

```
/project:biz-pitch préparer une présentation investisseurs
```

---

#### `/project:biz-roadmap` - Le Planificateur

```
/project:biz-roadmap planifier les 6 prochains mois
```

---

#### `/project:biz-launch` - Le Lanceur

**Workflow complet de lancement business**

```
/project:biz-launch nouveau SaaS de gestion de projet
```

---

#### `/project:biz-competitor` - L'Analyste Concurrentiel

```
/project:biz-competitor analyser Notion comme concurrent
```

---

#### `/project:biz-okr` - Le Définisseur d'Objectifs

```
/project:biz-okr définir les OKRs du trimestre
```

---

### 2.7 GROWTH- : Croissance (6 agents)

#### `/project:growth-landing` - Le Convertisseur

```
/project:growth-landing créer la landing page du produit
```

---

#### `/project:growth-seo` - L'Optimiseur SEO

```
/project:growth-seo audit complet du site
```

---

#### `/project:growth-analytics` - Le Data Analyst

```
/project:growth-analytics définir les KPIs produit
```

---

#### `/project:growth-onboarding` - Le Guide Utilisateur

```
/project:growth-onboarding concevoir l'onboarding utilisateur
```

---

#### `/project:growth-email` - Le Marketeur Email

```
/project:growth-email créer les templates d'onboarding
```

---

#### `/project:growth-ab-test` - L'Expérimentateur

```
/project:growth-ab-test planifier un test sur le CTA principal
```

---

### 2.8 LEGAL- : Légal (3 agents)

#### `/project:legal-docs` - Le Juriste

```
/project:legal-docs générer les CGU et CGV
```

---

#### `/project:legal-rgpd` - Le Protecteur des Données

```
/project:legal-rgpd audit complet de l'application
```

---

#### `/project:legal-payment` - L'Intégrateur Paiements

```
/project:legal-payment intégrer Stripe pour les abonnements
```

---

## 3. Scénarios Pratiques

### Scénario A : Nouvelle Fonctionnalité (Workflow Complet)

```bash
# Option 1 : Workflow automatisé
/project:work-flow-feature "ajouter notifications push mobile"

# Option 2 : Manuellement
/project:work-explore le système de notifications actuel
/project:work-plan ajouter notifications push mobile
/project:dev-tdd service de notifications push
/project:qa-review mes changements
/project:work-commit
/project:work-pr notifications push mobile
```

---

### Scénario B : Corriger un Bug

```bash
# Option 1 : Workflow automatisé
/project:work-flow-bugfix "#123 - emails de confirmation n'arrivent pas"

# Option 2 : Manuellement
/project:dev-debug les emails de confirmation n'arrivent pas
/project:dev-tdd fix du service email
/project:work-commit
```

---

### Scénario C : Nouvelle Release

```bash
# Workflow automatisé
/project:work-flow-release "v2.0.0"
```

---

### Scénario D : Lancement d'un Nouveau Business

```bash
# Option 1 : Workflow automatisé complet
/project:work-flow-launch "mon nouveau SaaS"

# Option 2 : Étape par étape
/project:biz-model analyser le potentiel commercial
/project:biz-market étude concurrentielle
/project:biz-mvp définir les fonctionnalités essentielles
/project:biz-pricing définir les plans tarifaires
/project:growth-landing créer la landing page
/project:growth-seo optimiser pour le référencement
/project:legal-payment intégrer Stripe
/project:legal-docs générer CGU, CGV
/project:legal-rgpd audit conformité
/project:growth-analytics définir les KPIs
/project:biz-pitch préparer le deck investisseurs
```

---

### Scénario E : Audit Complet Avant Production

```bash
/project:qa-audit
```

---

### Scénario F : Health Check Rapide

```bash
/project:ops-health
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
/project:work-flow-feature "ajouter dark mode"
```

### Astuce 2 : Être précis dans les demandes

```bash
# ❌ Trop vague
/project:dev-debug ça marche pas

# ✅ Précis et actionnable
/project:dev-debug erreur 401 sur POST /api/users quand token expiré
```

### Astuce 3 : Health check quotidien

```bash
# Chaque matin
/project:ops-health
```

### Astuce 4 : Audit complet avant release

```bash
# Avant chaque mise en production
/project:qa-audit
```

---

## 6. Pièges à Éviter

| ❌ Ne pas faire | ✅ Faire |
|-----------------|----------|
| Coder sans `/project:work-explore` | Toujours explorer d'abord |
| Implémenter sans `/project:work-plan` | Valider le plan avant de coder |
| Commits géants multi-features | Un commit = une préoccupation |
| Ignorer `/project:qa-security` | Audit régulier |
| `any` partout en TypeScript | Définir des types stricts |
| Skip les tests | Minimum 80% de couverture |

---

## 7. Récapitulatif Rapide

### Par besoin

| Besoin | Agent |
|--------|-------|
| Comprendre du code | `/project:work-explore` |
| Planifier une feature | `/project:work-plan` |
| Développer avec tests | `/project:dev-tdd` |
| Corriger un bug | `/project:dev-debug` |
| Code review | `/project:qa-review` |
| Vérifier la sécurité | `/project:qa-security` |
| Audit complet | `/project:qa-audit` |
| Health check rapide | `/project:ops-health` |
| Créer un commit | `/project:work-commit` |
| Créer une PR | `/project:work-pr` |
| Feature complète | `/project:work-flow-feature` |
| Bugfix complet | `/project:work-flow-bugfix` |
| Release complète | `/project:work-flow-release` |
| Lancement produit | `/project:work-flow-launch` |

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

Les workflows chaînés (`/project:work-flow-*`) automatisent ce processus pour les cas courants.

Bonne programmation !
