# Workflows de Développement

Ce document décrit les workflows recommandés pour différents scénarios de développement.

---

## Workflow Principal : Feature Development

```
┌─────────────────────────────────────────────────────────────────────┐
│                    FEATURE DEVELOPMENT WORKFLOW                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐         │
│  │ EXPLORE │ → │  PLAN   │ → │  CODE   │ → │ COMMIT  │          │
│  └─────────┘    └─────────┘    └─────────┘    └─────────┘         │
│       ↓              ↓              ↓              ↓               │
│  /explore       /plan          /tdd ou       /commit              │
│  /explain                      /test         /pr                  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Étapes détaillées

#### 1. EXPLORE - Comprendre le contexte
```bash
# Comprendre le code existant
/explore src/services/user

# Si code complexe, demander une explication
/explain src/services/user/auth.ts
```
**Objectif :** Ne jamais coder sans comprendre l'existant

#### 2. PLAN - Planifier l'implémentation
```bash
# Créer un plan d'implémentation
/plan Ajouter l'authentification OAuth2
```
**Objectif :** Définir l'architecture avant de coder

#### 3. CODE - Implémenter
```bash
# Option A: TDD (recommandé)
/tdd src/services/auth/oauth.ts

# Option B: Code puis tests
# ... coder ...
/test src/services/auth/oauth.ts
```
**Objectif :** Code testé et fonctionnel

#### 4. COMMIT - Versionner
```bash
# Créer un commit propre
/commit

# Ou créer une PR directement
/pr
```
**Objectif :** Historique git propre et traçable

---

## Workflow : Bug Fix

```
┌─────────────────────────────────────────────────────────────────────┐
│                       BUG FIX WORKFLOW                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐     │
│  │ REPRODUCE│ → │ DIAGNOSE │ → │   FIX    │ → │  VERIFY  │      │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘     │
│       ↓               ↓               ↓               ↓            │
│  Reproduire       /debug          Corriger        /test            │
│  le bug                           + test          /commit          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Étapes détaillées

```bash
# 1. Reproduire le bug
# Créer un cas de test qui échoue

# 2. Diagnostiquer
/debug L'utilisateur reçoit une erreur 500 lors de la connexion

# 3. Corriger
# ... appliquer le fix ...

# 4. Vérifier
/test src/services/auth/login.ts  # Test de non-régression

# 5. Commiter
/commit
```

### Pour les issues GitHub
```bash
/fix-issue #123
```

### Pour les urgences production
```bash
/hotfix Bug critique de paiement en production
```

---

## Workflow : Code Review

```
┌─────────────────────────────────────────────────────────────────────┐
│                     CODE REVIEW WORKFLOW                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐     │
│  │UNDERSTAND│ → │  REVIEW  │ → │ SECURITY │ → │ APPROVE  │      │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘     │
│       ↓               ↓               ↓               ↓            │
│  /explore         /review        /security        Merge PR         │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Étapes détaillées

```bash
# 1. Comprendre les changements
/explore src/features/new-feature

# 2. Review de code
/review src/features/new-feature

# 3. Review de sécurité (si applicable)
/security src/features/new-feature

# 4. Review performance (si applicable)
/perf src/features/new-feature

# 5. Approuver et merger
```

---

## Workflow : Release

```
┌─────────────────────────────────────────────────────────────────────┐
│                       RELEASE WORKFLOW                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐     │
│  │  AUDIT   │ → │ CHANGELOG│ → │ RELEASE  │ → │  DEPLOY  │      │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘     │
│       ↓               ↓               ↓               ↓            │
│  /audit          /changelog      /release         CI/CD            │
│  /security                                                          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Étapes détaillées

```bash
# 1. Audit complet
/audit
/security
/coverage

# 2. Préparer le changelog
/changelog

# 3. Créer la release
/release 1.2.0

# 4. Déploiement automatique via CI/CD
```

---

## Workflow : Refactoring

```
┌─────────────────────────────────────────────────────────────────────┐
│                     REFACTORING WORKFLOW                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐     │
│  │ ANALYZE  │ → │  TESTS   │ → │ REFACTOR │ → │  VERIFY  │      │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘     │
│       ↓               ↓               ↓               ↓            │
│  /explore         /coverage      /refactor        Tests OK         │
│  /review          /test          (steps)          /commit          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Règles du refactoring
1. **Jamais** de refactoring sans tests existants
2. **Un** changement à la fois
3. **Tests** après chaque changement
4. **Commits** atomiques

### Étapes détaillées

```bash
# 1. Analyser le code à refactorer
/explore src/services/legacy
/review src/services/legacy

# 2. Vérifier la couverture de tests
/coverage src/services/legacy

# 3. Ajouter tests si nécessaire (coverage < 80%)
/test src/services/legacy

# 4. Refactorer par petites étapes
/refactor src/services/legacy

# 5. Vérifier après chaque étape
npm test
/commit  # Commit atomique

# Répéter 4-5 jusqu'à terminé
```

---

## Workflow : Nouveau Projet

```
┌─────────────────────────────────────────────────────────────────────┐
│                    NEW PROJECT WORKFLOW                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐     │
│  │ BUSINESS │ → │  SETUP   │ → │   DEV    │ → │ LAUNCH   │      │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘     │
│       ↓               ↓               ↓               ↓            │
│  /model           /docker         Feature         /launch          │
│  /mvp             /ci             Workflow        /landing         │
│  /roadmap         /env                            /seo             │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Phase 1 : Business
```bash
/model       # Business model canvas
/market      # Étude de marché
/mvp         # Définir le MVP
/roadmap     # Planifier la roadmap
```

### Phase 2 : Setup technique
```bash
/docker      # Configuration Docker
/ci          # Pipeline CI/CD
/env         # Variables d'environnement
/infra-code  # Infrastructure as Code
```

### Phase 3 : Développement
Utiliser le workflow Feature Development pour chaque feature

### Phase 4 : Lancement
```bash
/security    # Audit sécurité
/launch      # Checklist lancement
/landing     # Landing page
/seo         # Optimisation SEO
/analytics   # Setup analytics
```

---

## Workflow : Migration

```
┌─────────────────────────────────────────────────────────────────────┐
│                     MIGRATION WORKFLOW                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐     │
│  │  PLAN    │ → │   TEST   │ → │ MIGRATE  │ → │  VERIFY  │      │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘     │
│       ↓               ↓               ↓               ↓            │
│  /migrate         Staging         Production      /health          │
│  /plan            Tests           Rollout         /monitoring      │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Pour les dépendances
```bash
/deps        # Analyser les dépendances
/migrate     # Migrer la dépendance
```

### Pour les bases de données
```bash
/database    # Planifier la migration
/backup      # Backup avant migration
# Migration
/health      # Vérifier post-migration
```

---

## Workflow : Incident Production

```
┌─────────────────────────────────────────────────────────────────────┐
│                    INCIDENT WORKFLOW                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐     │
│  │ DETECT   │ → │ MITIGATE │ → │   FIX    │ → │  REVIEW  │      │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘     │
│       ↓               ↓               ↓               ↓            │
│  /monitoring      Rollback        /hotfix         Post-mortem      │
│  Alertes          ou workaround   /debug                           │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Étapes détaillées

```bash
# 1. Détection (automatique via monitoring)
# Alerte reçue

# 2. Mitigation immédiate
# - Rollback si possible
# - Feature flag off
# - Scaling up

# 3. Fix
/debug       # Identifier la cause
/hotfix      # Appliquer le fix

# 4. Post-mortem
# Documentation de l'incident
# Actions préventives
```

---

## Workflow : Onboarding Nouveau Développeur

```
┌─────────────────────────────────────────────────────────────────────┐
│                    ONBOARDING WORKFLOW                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐     │
│  │  SETUP   │ → │ DISCOVER │ → │  LEARN   │ → │ PRACTICE │      │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘     │
│       ↓               ↓               ↓               ↓            │
│  Clone, npm i     /onboard        /explore        First PR         │
│  Docker           /explain        /review                          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Jour 1 : Setup
```bash
# Clone et installation
git clone <repo>
npm install
docker-compose up

# Vérifier que tout fonctionne
npm test
npm run dev
```

### Jour 2-3 : Découverte
```bash
# Comprendre le projet
/onboard

# Explorer les parties clés
/explore src/services
/explore src/api
```

### Semaine 1 : Apprentissage
```bash
# Comprendre le code complexe
/explain src/services/auth

# Observer les patterns
/review src/features/recent-feature
```

### Semaine 2+ : Pratique
```bash
# Première feature (simple)
/plan
/tdd
/commit
/pr
```

---

## Quick Reference

| Situation | Workflow | Agents clés |
|-----------|----------|-------------|
| Nouvelle feature | Feature Development | plan → tdd → commit → pr |
| Bug fix | Bug Fix | debug → test → commit |
| Code review | Code Review | explore → review → security |
| Release | Release | audit → changelog → release |
| Refactoring | Refactoring | coverage → test → refactor |
| Nouveau projet | New Project | model → mvp → docker → ci |
| Migration | Migration | migrate → test → verify |
| Incident | Incident | monitoring → hotfix |
| Onboarding | Onboarding | onboard → explore → explain |

---

## Bonnes Pratiques

### Toujours
- Commencer par `/explore` ou `/onboard`
- Planifier avec `/plan` avant de coder
- Tester avec `/tdd` ou `/test`
- Commiter proprement avec `/commit`

### Avant une release
- `/security` - Audit de sécurité
- `/coverage` - Vérifier la couverture
- `/changelog` - Mettre à jour le changelog

### En cas de doute
- `/explain` - Pour comprendre du code
- `/review` - Pour vérifier la qualité
- `/debug` - Pour diagnostiquer un problème
