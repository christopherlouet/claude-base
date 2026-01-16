# Guide : Quel Agent Utiliser ?

Ce guide vous aide à choisir le bon agent selon votre situation.

## Par Situation

### "Je découvre un nouveau projet"
```
/onboard → Comprendre l'architecture globale
/explore → Explorer une partie spécifique
/explain → Comprendre du code complexe
```

### "Je dois implémenter une nouvelle feature"
```
/plan     → Planifier l'implémentation
/tdd      → Développer avec tests first
/test     → Générer les tests après
/commit   → Commiter les changements
/pr       → Créer la Pull Request
```

### "J'ai un bug à corriger"
```
/debug    → Diagnostiquer le problème
/fix-issue → Corriger une issue GitHub
/hotfix   → Correction urgente en prod
/test     → Ajouter test de non-régression
```

### "Je dois améliorer le code existant"
```
/refactor   → Refactoring guidé
/perf       → Optimiser les performances (générique)
/react-perf → Optimiser React/Next.js (45 règles priorisées)
/review     → Code review du refactoring
```

### "Je prépare une release"
```
/review    → Review finale
/security  → Audit de sécurité
/changelog → Mettre à jour le changelog
/release   → Créer la release
```

### "Je configure l'infrastructure"
```
/docker    → Containeriser l'application
/ci        → Configurer CI/CD
/infra-code → Infrastructure as Code
/secrets-management → Gérer les secrets
/env       → Configurer les environnements
```

### "Je travaille sur l'API"
```
/api       → Créer/documenter une API
/api-versioning → Gérer le versioning
/api-spec  → Générer la spec OpenAPI
```

### "Je lance un produit"
```
/mvp       → Définir le MVP
/launch    → Checklist de lancement
/landing   → Créer une landing page
/seo       → Optimiser le SEO
```

### "Je développe une app mobile (Flutter)"
```
/explore   → Comprendre l'architecture existante
/plan      → Planifier la feature mobile
/flutter   → Créer widgets et screens
/supabase  → Configurer le backend (Auth, DB, Storage)
/mobile    → Audit qualité mobile (perf, a11y, responsive)
/commit    → Commiter avec scope mobile
/pr        → Pull Request
```

---

## Par Type de Tâche

### Développement

| Tâche | Agent | Description |
|-------|-------|-------------|
| Créer un composant | `/component` | Composant React avec tests |
| Créer un hook | `/hook` | Custom hook React |
| Créer une API | `/api` | Endpoint RESTful/GraphQL |
| Développer en TDD | `/tdd` | Test-Driven Development |
| Gérer les erreurs | `/error-handling` | Stratégie d'erreurs |
| Optimiser React/Next.js | `/react-perf` | 45 règles priorisées par impact |

### Mobile (Flutter)

| Tâche | Agent | Description |
|-------|-------|-------------|
| Widget/Screen Flutter | `/flutter` | Widgets, screens, BLoC |
| Backend Supabase | `/supabase` | Auth, Database, Storage, Realtime |
| Audit qualité mobile | `/mobile` | Perf, a11y, responsive, devices |
| API GraphQL | `/graphql` | Client/serveur GraphQL |

### Qualité

| Tâche | Agent | Description |
|-------|-------|-------------|
| Review de code | `/review` | Code review complète |
| Audit sécurité | `/security` | Audit OWASP |
| Audit accessibilité | `/a11y` | Audit WCAG |
| Audit performance | `/perf` | Analyse performance |
| Couverture tests | `/coverage` | Analyser la couverture |
| Tests responsive | `/responsive` | Tests multi-écrans |

### Documentation

| Tâche | Agent | Description |
|-------|-------|-------------|
| Documenter du code | `/doc` | Générer documentation |
| Expliquer du code | `/explain` | Explication détaillée |
| Spec OpenAPI | `/api-spec` | Documentation API |
| Changelog | `/changelog` | Générer changelog |
| Internationalisation | `/i18n` | Traductions |

### Ops / DevOps

| Tâche | Agent | Description |
|-------|-------|-------------|
| CI/CD | `/ci` | Pipeline de build |
| Docker | `/docker` | Containerisation |
| Infrastructure | `/infra-code` | Terraform/CloudFormation |
| Monitoring | `/monitoring` | Alertes et dashboards |
| Base de données | `/database` | Schéma et migrations |
| Environnements | `/env` | Configuration env |
| Secrets | `/secrets-management` | Gestion secrets |
| Backups | `/backup` | Stratégie backup |
| Health checks | `/health` | Endpoints santé |
| Load testing | `/load-testing` | Tests de charge |
| Disaster recovery | `/disaster-recovery` | Plan de reprise |
| Coûts cloud | `/cost-optimization` | Optimisation coûts |

### Business

| Tâche | Agent | Description |
|-------|-------|-------------|
| Business model | `/model` | Canvas business model |
| Étude de marché | `/market` | Analyse marché |
| MVP | `/mvp` | Définir le MVP |
| Pricing | `/pricing` | Stratégie prix |
| Pitch | `/pitch` | Préparer un pitch |
| Roadmap | `/roadmap` | Planifier roadmap |
| OKRs | `/okr` | Définir objectifs |
| Concurrence | `/competitor` | Analyse concurrentielle |
| Lancement | `/launch` | Checklist lancement |

### Growth

| Tâche | Agent | Description |
|-------|-------|-------------|
| Landing page | `/landing` | Créer landing |
| SEO | `/seo` | Optimisation SEO |
| Analytics | `/analytics` | Configurer analytics |
| Email | `/email` | Campagnes email |
| A/B Testing | `/ab-test` | Expérimentations |
| Onboarding | `/onboarding` | Parcours utilisateur |
| Rétention | `/retention` | Stratégies rétention |

### Legal

| Tâche | Agent | Description |
|-------|-------|-------------|
| RGPD | `/rgpd` | Conformité RGPD |
| Paiements | `/payment` | Conformité paiement |
| Documents légaux | `/legal-docs` | CGU, mentions légales |

---

## Par Niveau d'Expérience

### Débutant
Commencez par ces agents :
1. `/onboard` - Comprendre le projet
2. `/explore` - Explorer le code
3. `/explain` - Comprendre les parties complexes
4. `/commit` - Faire des commits propres

### Intermédiaire
Ajoutez ces agents :
1. `/plan` - Planifier avant de coder
2. `/tdd` - Développer avec des tests
3. `/review` - Faire des code reviews
4. `/debug` - Déboguer efficacement

### Avancé
Maîtrisez ces agents :
1. `/refactor` - Améliorer le code existant
2. `/security` - Auditer la sécurité
3. `/perf` - Optimiser les performances
4. `/ci` - Automatiser le déploiement

### Expert
Utilisez l'ensemble :
1. `/infra-code` - Infrastructure as Code
2. `/disaster-recovery` - Plans de reprise
3. `/cost-optimization` - Optimisation coûts
4. Tous les agents business et growth

---

## Arbre de Décision

```
Que voulez-vous faire ?
│
├─ Comprendre du code
│  ├─ Nouveau sur le projet? → /onboard
│  ├─ Explorer une partie? → /explore
│  └─ Code complexe? → /explain
│
├─ Écrire du code
│  ├─ Nouvelle feature
│  │  ├─ Besoin de planifier? → /plan
│  │  ├─ Tests d'abord? → /tdd
│  │  └─ Tests après? → /test
│  │
│  ├─ Web
│  │  ├─ Composant React → /component
│  │  ├─ Custom Hook → /hook
│  │  └─ API endpoint → /api
│  │
│  └─ Mobile (Flutter)
│     ├─ Widget/Screen → /flutter
│     ├─ Backend Supabase → /supabase
│     └─ GraphQL client → /graphql
│
├─ Corriger un problème
│  ├─ Bug connu → /debug
│  ├─ Issue GitHub → /fix-issue
│  └─ Urgence prod → /hotfix
│
├─ Améliorer le code
│  ├─ Refactoring → /refactor
│  ├─ Performance générique → /perf
│  ├─ Performance React/Next.js → /react-perf
│  └─ Review → /review
│
├─ Déployer
│  ├─ Commit → /commit
│  ├─ Pull Request → /pr
│  ├─ Release → /release
│  └─ Hotfix → /hotfix
│
├─ Infrastructure
│  ├─ Docker → /docker
│  ├─ CI/CD → /ci
│  ├─ Terraform → /infra-code
│  └─ Secrets → /secrets-management
│
├─ Documentation
│  ├─ Code → /doc
│  ├─ API → /api-spec
│  └─ Changelog → /changelog
│
├─ Qualité
│  ├─ Sécurité → /security
│  ├─ Accessibilité → /a11y
│  ├─ Couverture → /coverage
│  └─ Audit global → /audit
│
└─ Business
   ├─ Lancement → /launch
   ├─ Growth → /landing, /seo
   └─ Analyse → /market, /competitor
```

---

## Combinaisons Courantes

### Feature complète (du plan au merge)
```bash
/plan        # 1. Planifier
/tdd         # 2. Développer
/review      # 3. Self-review
/commit      # 4. Commiter
/pr          # 5. Pull Request
```

### Correction de bug
```bash
/debug       # 1. Diagnostiquer
# ... correction ...
/test        # 2. Test de régression
/commit      # 3. Commiter
```

### Nouveau projet
```bash
/mvp         # 1. Définir le MVP
/plan        # 2. Architecture
/docker      # 3. Setup Docker
/ci          # 4. CI/CD
```

### Mise en production
```bash
/security    # 1. Audit sécurité
/perf        # 2. Audit performance
/changelog   # 3. Changelog
/release     # 4. Release
```

### Optimisation existant
```bash
/audit       # 1. Audit global
/coverage    # 2. Couverture tests
/perf        # 3. Performance
/refactor    # 4. Refactoring
```

### Application mobile Flutter
```bash
/explore     # 1. Comprendre l'existant
/plan        # 2. Planifier la feature
/flutter     # 3. Créer widgets/screens
/supabase    # 4. Backend si nécessaire
/mobile      # 5. Audit qualité mobile
/commit      # 6. Commiter
/pr          # 7. Pull Request
```
