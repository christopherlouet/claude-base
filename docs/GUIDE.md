# Guide Complet : Maîtriser claude-socle

> Ce guide vous accompagne pas à pas pour utiliser efficacement les 83 agents de claude-socle et adopter le workflow optimal.

## Table des matières

- [1. Le Workflow Fondamental](#1-le-workflow-fondamental)
- [2. Les 83 Agents par Catégorie](#2-les-83-agents-par-catégorie)
  - [2.0 Orchestrateur](#20-orchestrateur)
  - [2.1 WORK- : Workflow Principal](#21-work---workflow-principal)
  - [2.2 DEV- : Développement](#22-dev---développement)
  - [2.3 QA- : Qualité](#23-qa---qualité)
  - [2.4 OPS- : Opérations](#24-ops---opérations)
  - [2.5 DOC- : Documentation](#25-doc---documentation)
  - [2.6 BIZ- : Business](#26-biz---business)
  - [2.7 GROWTH- : Croissance](#27-growth---croissance)
  - [2.8 DATA- : Données](#28-data---données)
  - [2.9 LEGAL- : Légal](#29-legal---légal)
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

### Pourquoi ce workflow ?

- **Évite le code "à l'aveugle"** qui génère des bugs
- **Force la réflexion** avant l'action
- **Produit des commits propres** et traçables
- **Facilite les code reviews**

---

## 2. Les 83 Agents par Catégorie

### 2.0 Orchestrateur (1 agent)

#### `/assistant` - Le Guide

**Quand l'utiliser :**
- Quand vous ne savez pas quel agent utiliser
- Pour obtenir des recommandations de workflow
- Pour découvrir les agents disponibles

**Exemple pratique :**
```
/assistant je veux améliorer les performances de mon app
```

---

### 2.1 WORK- : Workflow Principal (8 agents)

#### `/work:work-explore` - L'Enquêteur

**Quand l'utiliser :**
- Avant de toucher au code existant
- Pour comprendre une architecture inconnue
- Pour identifier les patterns en place

**Exemples pratiques :**
```
/work:work-explore le système d'authentification
/work:work-explore comment les erreurs sont gérées
/work:work-explore la structure de la base de données
```

---

#### `/work:work-plan` - L'Architecte

**Quand l'utiliser :**
- Avant toute fonctionnalité non-triviale
- Pour obtenir une validation avant de coder

**Exemples pratiques :**
```
/work:work-plan ajouter l'authentification OAuth2 Google
/work:work-plan migrer de REST à GraphQL
```

---

#### `/work:work-commit` - Le Scribe

**Format Conventional Commits :**
```
type(scope): description courte (≤50 chars)

Corps optionnel expliquant le "pourquoi"

Closes #123
```

---

#### `/work:work-pr` - Le Communicant

**Quand l'utiliser :**
- Après avoir terminé une feature branch
- Pour créer une PR complète et documentée

---

#### Workflows Chaînés

| Commande | Usage |
|----------|-------|
| `/work:work-flow-feature` | Workflow complet feature (explore→plan→code→pr) |
| `/work:work-flow-bugfix` | Workflow complet bugfix (debug→test→fix→pr) |
| `/work:work-flow-release` | Workflow complet release (audit→changelog→tag→deploy) |
| `/work:work-flow-launch` | Workflow complet lancement produit |

**Exemple :**
```bash
# Au lieu de faire manuellement chaque étape
/work:work-flow-feature "ajouter le dark mode"

# Le workflow enchaîne automatiquement:
# 1. Explore → 2. Plan → 3. TDD → 4. Review → 5. Commit → 6. PR
```

---

### 2.2 DEV- : Développement (13 agents)

#### `/dev:dev-tdd` - Le Testeur First

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
/dev:dev-tdd fonction de validation d'email
```

---

#### `/dev:dev-test` - Le Générateur de Tests

```
/dev:dev-test src/services/user-service.ts
```

---

#### `/dev:dev-testing-setup` - Le Configurateur de Tests

**Quand l'utiliser :**
- Pour configurer l'infrastructure de tests d'un projet
- Pour mettre en place Jest, Vitest, Pytest, etc.

```
/dev:dev-testing-setup configurer Vitest avec couverture
```

---

#### `/dev:dev-debug` - Le Détective

```
/dev:dev-debug erreur 500 sur /api/orders quand panier vide
```

---

#### `/dev:dev-refactor` - Le Chirurgien

```
/dev:dev-refactor src/components/UserForm.tsx
```

---

#### `/dev:dev-api` - L'API Designer REST

```
/dev:dev-api créer endpoint CRUD pour les produits
```

---

#### `/dev:dev-api-versioning` - Le Gestionnaire de Versions API

```
/dev:dev-api-versioning migrer v1 vers v2 avec rétrocompatibilité
```

---

#### `/dev:dev-component` - Le Créateur de Composants

**Crée un composant complet avec :**
- Code du composant
- Tests unitaires
- Stories Storybook
- Types TypeScript

```
/dev:dev-component créer un composant Button avec variantes
```

---

#### `/dev:dev-hook` - Le Créateur de Hooks

**Crée un hook React/Vue avec :**
- Code du hook
- Tests unitaires
- Documentation
- Exemples d'utilisation

```
/dev:dev-hook créer un hook useLocalStorage
```

---

#### `/dev:dev-error-handling` - Le Gestionnaire d'Erreurs

```
/dev:dev-error-handling implémenter une stratégie de gestion d'erreurs
```

---

#### `/dev:dev-flutter` - Le Développeur Mobile

**Pour les applications Flutter :**
- Widgets et screens
- Intégration BLoC
- Tests widget

```
/dev:dev-flutter créer un écran de profil utilisateur
```

---

#### `/dev:dev-supabase` - Le Backend Supabase

**Pour l'intégration Supabase :**
- Auth, Database, Storage
- Row Level Security
- Edge Functions

```
/dev:dev-supabase configurer l'authentification avec magic link
```

---

#### `/dev:dev-graphql` - L'API GraphQL

**Pour GraphQL client et serveur :**
- Schémas et resolvers
- Queries et mutations
- Subscriptions

```
/dev:dev-graphql créer un schéma pour les utilisateurs
```

---

### 2.3 QA- : Qualité (9 agents)

#### `/qa:qa-review` - Le Reviewer

```
/qa:qa-review mes changements avant PR
```

---

#### `/qa:qa-security` - Le Gardien

**Audit OWASP Top 10**

```
/qa:qa-security audit du module de paiement
```

---

#### `/qa:qa-perf` - L'Optimiseur

```
/qa:qa-perf la page Dashboard charge en 8s
```

---

#### `/qa:qa-a11y` - L'Inclusif

**Audit WCAG 2.1**

```
/qa:qa-a11y audit du formulaire d'inscription
```

---

#### `/qa:qa-audit` - L'Auditeur Complet

**Combine tous les audits en un :**
- Sécurité (OWASP)
- RGPD
- Accessibilité (WCAG)
- Performance
- Qualité de code

```
/qa:qa-audit avant mise en production
```

---

#### `/qa:qa-responsive` - Le Mobile Expert Web

**Audit responsive et mobile-first**

```
/qa:qa-responsive vérifier l'affichage mobile
```

---

#### `/qa:qa-automation` - L'Automatiseur de Tests

```
/qa:qa-automation mettre en place les tests E2E avec Playwright
```

---

#### `/qa:qa-coverage` - L'Analyste de Couverture

```
/qa:qa-coverage analyser la couverture et identifier les manques
```

---

#### `/qa:qa-mobile` - L'Expert Apps Mobiles

**Audit qualité pour Flutter/React Native :**
- Performance mobile
- UX mobile
- Tests sur devices

```
/qa:qa-mobile auditer l'application Flutter
```

---

### 2.4 OPS- : Opérations (16 agents)

#### `/ops:ops-hotfix` - Le Pompier

```
/ops:ops-hotfix les paiements échouent en production
```

---

#### `/ops:ops-release` - Le Release Manager

```
/ops:ops-release 2.1.0
```

---

#### `/ops:ops-deps` - Le Gardien des Dépendances

```
/ops:ops-deps audit et mise à jour
```

---

#### `/ops:ops-docker` - Le Containeriseur

```
/ops:ops-docker containeriser l'application
```

---

#### `/ops:ops-migrate` - Le Migrateur

```
/ops:ops-migrate de Express à Fastify
```

---

#### `/ops:ops-ci` - L'Automatiseur CI/CD

```
/ops:ops-ci configurer GitHub Actions
```

---

#### `/ops:ops-monitoring` - L'Observateur

```
/ops:ops-monitoring mettre en place les alertes
```

---

#### `/ops:ops-database` - Le DBA

```
/ops:ops-database optimiser les requêtes lentes
```

---

#### `/ops:ops-health` - Le Médecin Express

**Diagnostic rapide (5 min) :**

```
/ops:ops-health
```

---

#### `/ops:ops-env` - Le Gestionnaire d'Environnements

```
/ops:ops-env configurer les variables par environnement
```

---

#### `/ops:ops-backup` - Le Protecteur de Données

```
/ops:ops-backup stratégie de backup PostgreSQL
```

---

#### `/ops:ops-load-testing` - Le Testeur de Charge

```
/ops:ops-load-testing simuler 1000 utilisateurs concurrents
```

---

#### `/ops:ops-cost-optimization` - L'Optimiseur de Coûts

```
/ops:ops-cost-optimization réduire la facture AWS
```

---

#### `/ops:ops-disaster-recovery` - Le Planificateur de Reprise

```
/ops:ops-disaster-recovery créer un plan de reprise après sinistre
```

---

#### `/ops:ops-infra-code` - L'Infrastructure as Code

```
/ops:ops-infra-code créer l'infrastructure Terraform pour AWS
```

---

#### `/ops:ops-secrets-management` - Le Gardien des Secrets

```
/ops:ops-secrets-management migrer vers HashiCorp Vault
```

---

### 2.5 DOC- : Documentation (9 agents)

#### `/doc:doc-generate` - Le Documentaliste

```
/doc:doc-generate API endpoints
```

---

#### `/doc:doc-changelog` - L'Historien

```
/doc:doc-changelog depuis la dernière release
```

---

#### `/doc:doc-explain` - Le Professeur

```
/doc:doc-explain src/services/payment-processor.ts
```

---

#### `/doc:doc-onboard` - Le Guide

```
/doc:doc-onboard
```

---

#### `/doc:doc-i18n` - L'Internationalisateur

```
/doc:doc-i18n ajouter le support français
```

---

#### `/doc:doc-fix-issue` - Le Résolveur d'Issues

```
/doc:doc-fix-issue #42
```

---

#### `/doc:doc-api-spec` - Le Spécificateur

**Génère une spec OpenAPI/Swagger**

```
/doc:doc-api-spec générer la documentation API
```

---

#### `/doc:doc-readme` - Le Rédacteur README

```
/doc:doc-readme créer un README complet
```

---

#### `/doc:doc-architecture` - L'Architecte Documentaire

```
/doc:doc-architecture documenter l'architecture du projet
```

---

### 2.6 BIZ- : Business (11 agents)

#### `/biz:biz-model` - L'Analyste Business

```
/biz:biz-model analyser ce projet SaaS
```

---

#### `/biz:biz-market` - L'Analyste Marché

```
/biz:biz-market analyse concurrentielle pour un outil de gestion
```

---

#### `/biz:biz-mvp` - Le Stratège Produit

```
/biz:biz-mvp définir le MVP pour une app de livraison
```

---

#### `/biz:biz-pricing` - Le Stratège Prix

```
/biz:biz-pricing définir les plans tarifaires
```

---

#### `/biz:biz-pitch` - Le Présentateur

```
/biz:biz-pitch préparer une présentation investisseurs
```

---

#### `/biz:biz-roadmap` - Le Planificateur

```
/biz:biz-roadmap planifier les 6 prochains mois
```

---

#### `/biz:biz-launch` - Le Lanceur

**Workflow complet de lancement business**

```
/biz:biz-launch nouveau SaaS de gestion de projet
```

---

#### `/biz:biz-competitor` - L'Analyste Concurrentiel

```
/biz:biz-competitor analyser Notion comme concurrent
```

---

#### `/biz:biz-okr` - Le Définisseur d'Objectifs

```
/biz:biz-okr définir les OKRs du trimestre
```

---

#### `/biz:biz-research` - Le Chercheur Utilisateur

```
/biz:biz-research mener une étude utilisateur
```

---

#### `/biz:biz-personas` - Le Créateur de Personas

```
/biz:biz-personas créer les personas pour notre SaaS B2B
```

---

### 2.7 GROWTH- : Croissance (8 agents)

#### `/growth:growth-landing` - Le Convertisseur

```
/growth:growth-landing créer la landing page du produit
```

---

#### `/growth:growth-seo` - L'Optimiseur SEO

```
/growth:growth-seo audit complet du site
```

---

#### `/growth:growth-analytics` - Le Data Analyst

```
/growth:growth-analytics définir les KPIs produit
```

---

#### `/growth:growth-onboarding` - Le Guide Utilisateur

```
/growth:growth-onboarding concevoir l'onboarding utilisateur
```

---

#### `/growth:growth-email` - Le Marketeur Email

```
/growth:growth-email créer les templates d'onboarding
```

---

#### `/growth:growth-ab-test` - L'Expérimentateur

```
/growth:growth-ab-test planifier un test sur le CTA principal
```

---

#### `/growth:growth-retention` - Le Fidélisateur

```
/growth:growth-retention améliorer la rétention utilisateur
```

---

#### `/growth:growth-funnel` - L'Optimiseur de Tunnel

```
/growth:growth-funnel analyser et optimiser le funnel d'acquisition
```

---

### 2.8 DATA- : Données (3 agents)

#### `/data:data-pipeline` - L'Ingénieur Data

```
/data:data-pipeline concevoir un pipeline ETL pour les logs
```

---

#### `/data:data-analytics` - L'Analyste Data

```
/data:data-analytics créer un dashboard de métriques
```

---

#### `/data:data-modeling` - Le Modélisateur

```
/data:data-modeling concevoir le schéma du data warehouse
```

---

### 2.9 LEGAL- : Légal (5 agents)

#### `/legal:legal-docs` - Le Juriste

```
/legal:legal-docs générer les CGU et CGV
```

---

#### `/legal:legal-rgpd` - Le Protecteur des Données

```
/legal:legal-rgpd audit complet de l'application
```

---

#### `/legal:legal-payment` - L'Intégrateur Paiements

```
/legal:legal-payment intégrer Stripe pour les abonnements
```

---

#### `/legal:legal-terms-of-service` - Le Rédacteur CGU

```
/legal:legal-terms-of-service créer des CGU complètes
```

---

#### `/legal:legal-privacy-policy` - Le Rédacteur Confidentialité

```
/legal:legal-privacy-policy créer une politique de confidentialité RGPD
```

---

## 3. Scénarios Pratiques

### Scénario A : Nouvelle Fonctionnalité (Workflow Complet)

```bash
# Option 1 : Workflow automatisé
/work:work-flow-feature "ajouter notifications push mobile"

# Option 2 : Manuellement
/work:work-explore le système de notifications actuel
/work:work-plan ajouter notifications push mobile
/dev:dev-tdd service de notifications push
/qa:qa-review mes changements
/work:work-commit
/work:work-pr notifications push mobile
```

---

### Scénario B : Corriger un Bug

```bash
# Option 1 : Workflow automatisé
/work:work-flow-bugfix "#123 - emails de confirmation n'arrivent pas"

# Option 2 : Manuellement
/dev:dev-debug les emails de confirmation n'arrivent pas
/dev:dev-tdd fix du service email
/work:work-commit
```

---

### Scénario C : Nouvelle Release

```bash
# Workflow automatisé
/work:work-flow-release "v2.0.0"
```

---

### Scénario D : Lancement d'un Nouveau Business

```bash
# Option 1 : Workflow automatisé complet
/work:work-flow-launch "mon nouveau SaaS"

# Option 2 : Étape par étape
/biz:biz-model analyser le potentiel commercial
/biz:biz-market étude concurrentielle
/biz:biz-mvp définir les fonctionnalités essentielles
/biz:biz-pricing définir les plans tarifaires
/growth:growth-landing créer la landing page
/growth:growth-seo optimiser pour le référencement
/legal:legal-payment intégrer Stripe
/legal:legal-docs générer CGU, CGV
/legal:legal-rgpd audit conformité
/growth:growth-analytics définir les KPIs
/biz:biz-pitch préparer le deck investisseurs
```

---

### Scénario E : Audit Complet Avant Production

```bash
/qa:qa-audit
```

---

### Scénario F : Health Check Rapide

```bash
/ops:ops-health
```

---

### Scénario G : Application Mobile Flutter

```bash
/work:work-explore → /work:work-plan → /dev:dev-flutter + /dev:dev-supabase → /qa:qa-mobile → /work:work-pr
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

### 4.2 Hooks (`.claude/settings.json`)

Les hooks sont configurés dans la section `hooks` du fichier `settings.json` :

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "description": "Protection branche main",
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c '[script de vérification]'",
            "onFailure": "block"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "description": "Auto-format après édition",
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write $CLAUDE_FILE_PATH"
          }
        ]
      }
    ]
  }
}
```

---

## 5. Astuces de Pro

### Astuce 1 : Utiliser les workflows chaînés

```bash
# Au lieu de 6 commandes manuelles
/work:work-flow-feature "ajouter dark mode"
```

### Astuce 2 : Être précis dans les demandes

```bash
# Trop vague
/dev:dev-debug ça marche pas

# Précis et actionnable
/dev:dev-debug erreur 401 sur POST /api/users quand token expiré
```

### Astuce 3 : Health check quotidien

```bash
# Chaque matin
/ops:ops-health
```

### Astuce 4 : Audit complet avant release

```bash
# Avant chaque mise en production
/qa:qa-audit
```

### Astuce 5 : Utiliser l'orchestrateur

```bash
# Quand vous ne savez pas par où commencer
/assistant je veux améliorer mon app
```

---

## 6. Pièges à Éviter

| Ne pas faire | Faire |
|--------------|-------|
| Coder sans `/work:work-explore` | Toujours explorer d'abord |
| Implémenter sans `/work:work-plan` | Valider le plan avant de coder |
| Commits géants multi-features | Un commit = une préoccupation |
| Ignorer `/qa:qa-security` | Audit régulier |
| `any` partout en TypeScript | Définir des types stricts |
| Skip les tests | Minimum 80% de couverture |

---

## 7. Récapitulatif Rapide

### Par besoin

| Besoin | Agent |
|--------|-------|
| Comprendre du code | `/work:work-explore` |
| Planifier une feature | `/work:work-plan` |
| Développer avec tests | `/dev:dev-tdd` |
| Corriger un bug | `/dev:dev-debug` |
| Code review | `/qa:qa-review` |
| Vérifier la sécurité | `/qa:qa-security` |
| Audit complet | `/qa:qa-audit` |
| Health check rapide | `/ops:ops-health` |
| Créer un commit | `/work:work-commit` |
| Créer une PR | `/work:work-pr` |
| Feature complète | `/work:work-flow-feature` |
| Bugfix complet | `/work:work-flow-bugfix` |
| Release complète | `/work:work-flow-release` |
| Lancement produit | `/work:work-flow-launch` |
| App mobile Flutter | `/dev:dev-flutter` |
| Backend Supabase | `/dev:dev-supabase` |
| API GraphQL | `/dev:dev-graphql` |

### Par catégorie

```
ASSISTANT (1) = Orchestrateur
WORK      (8) = Workflow de base + workflows chaînés
DEV      (13) = Développement (tdd, test, debug, refactor, api, component, hook, flutter, supabase, graphql...)
QA        (9) = Qualité (review, security, perf, a11y, audit, responsive, automation, coverage, mobile)
OPS      (16) = Opérations (hotfix, release, deps, docker, migrate, ci, monitoring, database, health, env, backup, load-testing, cost-optimization, disaster-recovery, infra-code, secrets-management)
DOC       (9) = Documentation (generate, changelog, explain, onboard, i18n, fix-issue, api-spec, readme, architecture)
BIZ      (11) = Business (model, market, mvp, pricing, pitch, roadmap, launch, competitor, okr, research, personas)
GROWTH    (8) = Croissance (landing, seo, analytics, onboarding, email, ab-test, retention, funnel)
DATA      (3) = Données (pipeline, analytics, modeling)
LEGAL     (5) = Légal (docs, rgpd, payment, terms-of-service, privacy-policy)
```

---

## Conclusion

Le principe clé de claude-socle est simple : **toujours EXPLORE → PLAN → CODE → COMMIT** pour un workflow professionnel et maintenable.

Les workflows chaînés (`/work:work-flow-*`) automatisent ce processus pour les cas courants.

Utilisez `/assistant` quand vous ne savez pas par où commencer.

Bonne programmation !

---

*Claude-Socle v2.1 - 83 agents - 10 catégories - 9 skills*
