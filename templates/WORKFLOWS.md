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
/project:explore src/services/user

# Si code complexe, demander une explication
/project:explain src/services/user/auth.ts
```
**Objectif :** Ne jamais coder sans comprendre l'existant

#### 2. PLAN - Planifier l'implémentation
```bash
# Créer un plan d'implémentation
/project:plan Ajouter l'authentification OAuth2
```
**Objectif :** Définir l'architecture avant de coder

#### 3. CODE - Implémenter
```bash
# Option A: TDD (recommandé)
/project:tdd src/services/auth/oauth.ts

# Option B: Code puis tests
# ... coder ...
/project:test src/services/auth/oauth.ts
```
**Objectif :** Code testé et fonctionnel

#### 4. COMMIT - Versionner
```bash
# Créer un commit propre
/project:commit

# Ou créer une PR directement
/project:pr
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
/project:debug L'utilisateur reçoit une erreur 500 lors de la connexion

# 3. Corriger
# ... appliquer le fix ...

# 4. Vérifier
/project:test src/services/auth/login.ts  # Test de non-régression

# 5. Commiter
/project:commit
```

### Pour les issues GitHub
```bash
/project:fix-issue #123
```

### Pour les urgences production
```bash
/project:hotfix Bug critique de paiement en production
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
/project:explore src/features/new-feature

# 2. Review de code
/project:review src/features/new-feature

# 3. Review de sécurité (si applicable)
/project:security src/features/new-feature

# 4. Review performance (si applicable)
/project:perf src/features/new-feature

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
/project:audit
/project:security
/project:coverage

# 2. Préparer le changelog
/project:changelog

# 3. Créer la release
/project:release 1.2.0

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
/project:explore src/services/legacy
/project:review src/services/legacy

# 2. Vérifier la couverture de tests
/project:coverage src/services/legacy

# 3. Ajouter tests si nécessaire (coverage < 80%)
/project:test src/services/legacy

# 4. Refactorer par petites étapes
/project:refactor src/services/legacy

# 5. Vérifier après chaque étape
npm test
/project:commit  # Commit atomique

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
/project:model       # Business model canvas
/project:market      # Étude de marché
/project:mvp         # Définir le MVP
/project:roadmap     # Planifier la roadmap
```

### Phase 2 : Setup technique
```bash
/project:docker      # Configuration Docker
/project:ci          # Pipeline CI/CD
/project:env         # Variables d'environnement
/project:infra-code  # Infrastructure as Code
```

### Phase 3 : Développement
Utiliser le workflow Feature Development pour chaque feature

### Phase 4 : Lancement
```bash
/project:security    # Audit sécurité
/project:launch      # Checklist lancement
/project:landing     # Landing page
/project:seo         # Optimisation SEO
/project:analytics   # Setup analytics
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
/project:deps        # Analyser les dépendances
/project:migrate     # Migrer la dépendance
```

### Pour les bases de données
```bash
/project:database    # Planifier la migration
/project:backup      # Backup avant migration
# Migration
/project:health      # Vérifier post-migration
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
/project:debug       # Identifier la cause
/project:hotfix      # Appliquer le fix

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
/project:onboard

# Explorer les parties clés
/project:explore src/services
/project:explore src/api
```

### Semaine 1 : Apprentissage
```bash
# Comprendre le code complexe
/project:explain src/services/auth

# Observer les patterns
/project:review src/features/recent-feature
```

### Semaine 2+ : Pratique
```bash
# Première feature (simple)
/project:plan
/project:tdd
/project:commit
/project:pr
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
- Commencer par `/project:explore` ou `/project:onboard`
- Planifier avec `/project:plan` avant de coder
- Tester avec `/project:tdd` ou `/project:test`
- Commiter proprement avec `/project:commit`

### Avant une release
- `/project:security` - Audit de sécurité
- `/project:coverage` - Vérifier la couverture
- `/project:changelog` - Mettre à jour le changelog

### En cas de doute
- `/project:explain` - Pour comprendre du code
- `/project:review` - Pour vérifier la qualité
- `/project:debug` - Pour diagnostiquer un problème
