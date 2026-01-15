# Guide : Quel Agent Utiliser ?

Ce guide vous aide à choisir le bon agent selon votre situation.

## Par Situation

### "Je découvre un nouveau projet"
```
/project:onboard → Comprendre l'architecture globale
/project:explore → Explorer une partie spécifique
/project:explain → Comprendre du code complexe
```

### "Je dois implémenter une nouvelle feature"
```
/project:plan     → Planifier l'implémentation
/project:tdd      → Développer avec tests first
/project:test     → Générer les tests après
/project:commit   → Commiter les changements
/project:pr       → Créer la Pull Request
```

### "J'ai un bug à corriger"
```
/project:debug    → Diagnostiquer le problème
/project:fix-issue → Corriger une issue GitHub
/project:hotfix   → Correction urgente en prod
/project:test     → Ajouter test de non-régression
```

### "Je dois améliorer le code existant"
```
/project:refactor → Refactoring guidé
/project:perf     → Optimiser les performances
/project:review   → Code review du refactoring
```

### "Je prépare une release"
```
/project:review    → Review finale
/project:security  → Audit de sécurité
/project:changelog → Mettre à jour le changelog
/project:release   → Créer la release
```

### "Je configure l'infrastructure"
```
/project:docker    → Containeriser l'application
/project:ci        → Configurer CI/CD
/project:infra-code → Infrastructure as Code
/project:secrets-management → Gérer les secrets
/project:env       → Configurer les environnements
```

### "Je travaille sur l'API"
```
/project:api       → Créer/documenter une API
/project:api-versioning → Gérer le versioning
/project:api-spec  → Générer la spec OpenAPI
```

### "Je lance un produit"
```
/project:mvp       → Définir le MVP
/project:launch    → Checklist de lancement
/project:landing   → Créer une landing page
/project:seo       → Optimiser le SEO
```

---

## Par Type de Tâche

### Développement

| Tâche | Agent | Description |
|-------|-------|-------------|
| Créer un composant | `/project:component` | Composant React avec tests |
| Créer un hook | `/project:hook` | Custom hook React |
| Créer une API | `/project:api` | Endpoint RESTful/GraphQL |
| Développer en TDD | `/project:tdd` | Test-Driven Development |
| Gérer les erreurs | `/project:error-handling` | Stratégie d'erreurs |

### Qualité

| Tâche | Agent | Description |
|-------|-------|-------------|
| Review de code | `/project:review` | Code review complète |
| Audit sécurité | `/project:security` | Audit OWASP |
| Audit accessibilité | `/project:a11y` | Audit WCAG |
| Audit performance | `/project:perf` | Analyse performance |
| Couverture tests | `/project:coverage` | Analyser la couverture |
| Tests responsive | `/project:responsive` | Tests multi-écrans |

### Documentation

| Tâche | Agent | Description |
|-------|-------|-------------|
| Documenter du code | `/project:doc` | Générer documentation |
| Expliquer du code | `/project:explain` | Explication détaillée |
| Spec OpenAPI | `/project:api-spec` | Documentation API |
| Changelog | `/project:changelog` | Générer changelog |
| Internationalisation | `/project:i18n` | Traductions |

### Ops / DevOps

| Tâche | Agent | Description |
|-------|-------|-------------|
| CI/CD | `/project:ci` | Pipeline de build |
| Docker | `/project:docker` | Containerisation |
| Infrastructure | `/project:infra-code` | Terraform/CloudFormation |
| Monitoring | `/project:monitoring` | Alertes et dashboards |
| Base de données | `/project:database` | Schéma et migrations |
| Environnements | `/project:env` | Configuration env |
| Secrets | `/project:secrets-management` | Gestion secrets |
| Backups | `/project:backup` | Stratégie backup |
| Health checks | `/project:health` | Endpoints santé |
| Load testing | `/project:load-testing` | Tests de charge |
| Disaster recovery | `/project:disaster-recovery` | Plan de reprise |
| Coûts cloud | `/project:cost-optimization` | Optimisation coûts |

### Business

| Tâche | Agent | Description |
|-------|-------|-------------|
| Business model | `/project:model` | Canvas business model |
| Étude de marché | `/project:market` | Analyse marché |
| MVP | `/project:mvp` | Définir le MVP |
| Pricing | `/project:pricing` | Stratégie prix |
| Pitch | `/project:pitch` | Préparer un pitch |
| Roadmap | `/project:roadmap` | Planifier roadmap |
| OKRs | `/project:okr` | Définir objectifs |
| Concurrence | `/project:competitor` | Analyse concurrentielle |
| Lancement | `/project:launch` | Checklist lancement |

### Growth

| Tâche | Agent | Description |
|-------|-------|-------------|
| Landing page | `/project:landing` | Créer landing |
| SEO | `/project:seo` | Optimisation SEO |
| Analytics | `/project:analytics` | Configurer analytics |
| Email | `/project:email` | Campagnes email |
| A/B Testing | `/project:ab-test` | Expérimentations |
| Onboarding | `/project:onboarding` | Parcours utilisateur |
| Rétention | `/project:retention` | Stratégies rétention |

### Legal

| Tâche | Agent | Description |
|-------|-------|-------------|
| RGPD | `/project:rgpd` | Conformité RGPD |
| Paiements | `/project:payment` | Conformité paiement |
| Documents légaux | `/project:legal-docs` | CGU, mentions légales |

---

## Par Niveau d'Expérience

### Débutant
Commencez par ces agents :
1. `/project:onboard` - Comprendre le projet
2. `/project:explore` - Explorer le code
3. `/project:explain` - Comprendre les parties complexes
4. `/project:commit` - Faire des commits propres

### Intermédiaire
Ajoutez ces agents :
1. `/project:plan` - Planifier avant de coder
2. `/project:tdd` - Développer avec des tests
3. `/project:review` - Faire des code reviews
4. `/project:debug` - Déboguer efficacement

### Avancé
Maîtrisez ces agents :
1. `/project:refactor` - Améliorer le code existant
2. `/project:security` - Auditer la sécurité
3. `/project:perf` - Optimiser les performances
4. `/project:ci` - Automatiser le déploiement

### Expert
Utilisez l'ensemble :
1. `/project:infra-code` - Infrastructure as Code
2. `/project:disaster-recovery` - Plans de reprise
3. `/project:cost-optimization` - Optimisation coûts
4. Tous les agents business et growth

---

## Arbre de Décision

```
Que voulez-vous faire ?
│
├─ Comprendre du code
│  ├─ Nouveau sur le projet? → /project:onboard
│  ├─ Explorer une partie? → /project:explore
│  └─ Code complexe? → /project:explain
│
├─ Écrire du code
│  ├─ Nouvelle feature
│  │  ├─ Besoin de planifier? → /project:plan
│  │  ├─ Tests d'abord? → /project:tdd
│  │  └─ Tests après? → /project:test
│  │
│  ├─ Composant React → /project:component
│  ├─ Custom Hook → /project:hook
│  └─ API endpoint → /project:api
│
├─ Corriger un problème
│  ├─ Bug connu → /project:debug
│  ├─ Issue GitHub → /project:fix-issue
│  └─ Urgence prod → /project:hotfix
│
├─ Améliorer le code
│  ├─ Refactoring → /project:refactor
│  ├─ Performance → /project:perf
│  └─ Review → /project:review
│
├─ Déployer
│  ├─ Commit → /project:commit
│  ├─ Pull Request → /project:pr
│  ├─ Release → /project:release
│  └─ Hotfix → /project:hotfix
│
├─ Infrastructure
│  ├─ Docker → /project:docker
│  ├─ CI/CD → /project:ci
│  ├─ Terraform → /project:infra-code
│  └─ Secrets → /project:secrets-management
│
├─ Documentation
│  ├─ Code → /project:doc
│  ├─ API → /project:api-spec
│  └─ Changelog → /project:changelog
│
├─ Qualité
│  ├─ Sécurité → /project:security
│  ├─ Accessibilité → /project:a11y
│  ├─ Couverture → /project:coverage
│  └─ Audit global → /project:audit
│
└─ Business
   ├─ Lancement → /project:launch
   ├─ Growth → /project:landing, /project:seo
   └─ Analyse → /project:market, /project:competitor
```

---

## Combinaisons Courantes

### Feature complète (du plan au merge)
```bash
/project:plan        # 1. Planifier
/project:tdd         # 2. Développer
/project:review      # 3. Self-review
/project:commit      # 4. Commiter
/project:pr          # 5. Pull Request
```

### Correction de bug
```bash
/project:debug       # 1. Diagnostiquer
# ... correction ...
/project:test        # 2. Test de régression
/project:commit      # 3. Commiter
```

### Nouveau projet
```bash
/project:mvp         # 1. Définir le MVP
/project:plan        # 2. Architecture
/project:docker      # 3. Setup Docker
/project:ci          # 4. CI/CD
```

### Mise en production
```bash
/project:security    # 1. Audit sécurité
/project:perf        # 2. Audit performance
/project:changelog   # 3. Changelog
/project:release     # 4. Release
```

### Optimisation existant
```bash
/project:audit       # 1. Audit global
/project:coverage    # 2. Couverture tests
/project:perf        # 3. Performance
/project:refactor    # 4. Refactoring
```
