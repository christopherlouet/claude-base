# Projet claude-socle

> Template de configuration Claude Code pour un workflow optimal : Explore → Plan → Code → Commit

## Commandes Essentielles

### Web (Node/React)
| Commande | Description |
|----------|-------------|
| `npm install` | Installer les dépendances |
| `npm run dev` | Serveur de développement |
| `npm test` | Lancer les tests |
| `npm run test:watch` | Tests en mode watch |
| `npm run lint` | Vérifier le code (ESLint) |
| `npm run lint:fix` | Corriger automatiquement |
| `npm run build` | Build de production |
| `npm run typecheck` | Vérifier les types TypeScript |

### Mobile (Flutter)
| Commande | Description |
|----------|-------------|
| `flutter pub get` | Installer les dépendances |
| `flutter run` | Lancer sur device/émulateur |
| `flutter test` | Lancer les tests |
| `flutter analyze` | Analyser le code (lint) |
| `dart fix --apply` | Corriger automatiquement |
| `flutter build apk` | Build Android |
| `flutter build ios` | Build iOS |
| `flutter build web` | Build Web |

## Structure du Projet

### Web (React/Node)
```
/src
├── /components     # Composants UI réutilisables
├── /services       # Logique métier et appels API
├── /hooks          # Custom hooks React
├── /utils          # Fonctions utilitaires pures
├── /types          # Types et interfaces TypeScript
├── /config         # Configuration de l'application
└── /tests          # Tests unitaires et d'intégration
```

### Mobile (Flutter)
```
/lib
├── /core           # Constantes, erreurs, réseau, utils
├── /features       # Features par domaine (Clean Architecture)
│   └── /[feature]
│       ├── /data          # Datasources, models, repositories impl
│       ├── /domain        # Entities, repositories interfaces, usecases
│       └── /presentation  # BLoC, pages, widgets
├── /shared         # Widgets et thème partagés
├── /l10n           # Traductions (ARB)
└── /config         # Routes (GoRouter), injection (get_it)
/test               # Tests unitaires, widget, integration
```

## Workflow Obligatoire : Explore → Plan → Code → Commit

### 1. EXPLORE (`/work-explore`)
- Lire et comprendre le code existant AVANT de modifier
- Identifier les patterns et conventions en place
- NE JAMAIS coder sans avoir exploré

### 2. PLAN (`/work-plan`)
- Proposer une architecture AVANT d'implémenter
- Lister les fichiers à créer/modifier
- Identifier les risques potentiels
- Attendre validation avant de coder

### 3. CODE (`/dev-tdd` ou direct)
- Implémenter en suivant le plan validé
- Tests first si applicable (TDD)
- Commits atomiques et fréquents

### 4. COMMIT (`/work-commit` ou `/work-pr`)
- Message de commit descriptif
- Référencer les issues si applicable
- PR avec description complète

## Conventions de Code

### TypeScript
- IMPORTANT: Mode strict activé (`"strict": true`)
- IMPORTANT: Pas de `any` sauf cas exceptionnels documentés
- YOU MUST définir des interfaces pour les objets complexes
- Préférer `type` pour unions, `interface` pour objets extensibles

### Nommage
| Type | Convention | Exemple |
|------|------------|---------|
| Variables/Fonctions | camelCase | `getUserById` |
| Classes/Interfaces | PascalCase | `UserService` |
| Constantes | SCREAMING_SNAKE | `MAX_RETRY_COUNT` |
| Fichiers composants | PascalCase | `UserCard.tsx` |
| Fichiers autres | kebab-case | `user-service.ts` |

### Principes
- Fonctions pures quand possible
- Immutabilité des données
- Single Responsibility Principle
- DRY mais pas au détriment de la lisibilité

## Tests

### Règles
- IMPORTANT: Couverture minimum 80% sur nouveau code
- IMPORTANT: Pas de mocks sauf dépendances externes (API, DB)
- YOU MUST tester les edge cases (null, undefined, empty, limites)
- Tests lisibles = documentation vivante

### Structure
```typescript
describe('ModuleName', () => {
  describe('functionName', () => {
    it('should [expected behavior] when [condition]', () => {
      // Arrange → Act → Assert
    });
  });
});
```

## Git & Commits

### Format Conventional Commits
```
type(scope): description courte

[corps optionnel]

[footer optionnel]
```

### Types autorisés
| Type | Usage |
|------|-------|
| `feat` | Nouvelle fonctionnalité |
| `fix` | Correction de bug |
| `refactor` | Refactoring sans changement fonctionnel |
| `test` | Ajout ou modification de tests |
| `docs` | Documentation |
| `style` | Formatage (pas de changement de code) |
| `chore` | Maintenance, dépendances |
| `perf` | Amélioration de performance |

### Branches
- `main` - Production (protégée)
- `develop` - Développement
- `feature/xxx` - Nouvelles fonctionnalités
- `fix/xxx` - Corrections de bugs
- `refactor/xxx` - Refactoring

### Règles Git
- IMPORTANT: Ne jamais push --force sur main
- IMPORTANT: Ne jamais commiter de secrets (.env, credentials)
- Rebase préféré au merge pour feature branches
- Squash commits avant merge si historique bruyant

## Sécurité

- IMPORTANT: Valider TOUTES les entrées utilisateur
- IMPORTANT: Échapper les outputs HTML (prévention XSS)
- IMPORTANT: Utiliser des requêtes paramétrées (prévention SQL injection)
- Ne jamais logger de données sensibles
- Dépendances à jour (`npm audit`)

## Agents Disponibles (85)

### Orchestrateur
| Commande | Usage |
|----------|-------|
| `/assistant` | Guide de choix des agents et workflows |

### WORK- : Workflow Principal (8)
| Commande | Usage |
|----------|-------|
| `/work-explore` | Explorer et comprendre le code |
| `/work-plan` | Planifier une implémentation |
| `/work-commit` | Créer un commit propre |
| `/work-pr` | Créer une Pull Request |
| `/work-flow-feature` | Workflow complet feature |
| `/work-flow-bugfix` | Workflow complet bugfix |
| `/work-flow-release` | Workflow complet release |
| `/work-flow-launch` | Workflow complet lancement produit |

### DEV- : Développement (14)
| Commande | Usage |
|----------|-------|
| `/dev-tdd` | Développement TDD |
| `/dev-test` | Générer des tests |
| `/dev-testing-setup` | Configurer l'infrastructure de tests |
| `/dev-debug` | Déboguer un problème |
| `/dev-refactor` | Refactoring guidé |
| `/dev-api` | Créer/documenter API |
| `/dev-api-versioning` | Versioning d'API |
| `/dev-component` | Créer un composant UI complet |
| `/dev-hook` | Créer un hook React/Vue |
| `/dev-error-handling` | Stratégie de gestion d'erreurs |
| `/dev-flutter` | Widgets et screens Flutter |
| `/dev-supabase` | Backend Supabase (Auth, DB, Storage) |
| `/dev-graphql` | API GraphQL client/serveur |
| `/dev-neovim` | Plugins et config Neovim/Lua |

### QA- : Qualité (10)
| Commande | Usage |
|----------|-------|
| `/qa-review` | Code review approfondie |
| `/qa-security` | Audit de sécurité OWASP |
| `/qa-perf` | Analyse de performance |
| `/qa-a11y` | Audit accessibilité WCAG |
| `/qa-audit` | Audit qualité complet |
| `/qa-responsive` | Audit responsive/mobile web |
| `/qa-automation` | Automatisation des tests |
| `/qa-coverage` | Analyse couverture de tests |
| `/qa-mobile` | Audit qualité apps mobiles (Flutter) |
| `/qa-neovim` | Audit config Neovim (perf, keymaps) |

### OPS- : Opérations (16)
| Commande | Usage |
|----------|-------|
| `/ops-hotfix` | Correction urgente production |
| `/ops-release` | Créer une release |
| `/ops-deps` | Audit et MAJ des dépendances |
| `/ops-docker` | Dockeriser un projet |
| `/ops-migrate` | Migration de code/dépendances |
| `/ops-ci` | Configuration CI/CD |
| `/ops-monitoring` | Logs, métriques, alertes |
| `/ops-database` | Schéma, migrations DB |
| `/ops-health` | Health check rapide |
| `/ops-env` | Gestion des environnements |
| `/ops-backup` | Stratégie backup/restore |
| `/ops-load-testing` | Tests de charge et stress |
| `/ops-cost-optimization` | Optimisation coûts cloud |
| `/ops-disaster-recovery` | Plan de reprise après sinistre |
| `/ops-infra-code` | Infrastructure as Code (Terraform) |
| `/ops-secrets-management` | Gestion sécurisée des secrets |

### DOC- : Documentation (9)
| Commande | Usage |
|----------|-------|
| `/doc-generate` | Générer de la documentation |
| `/doc-changelog` | Générer/maintenir le changelog |
| `/doc-explain` | Expliquer du code complexe |
| `/doc-onboard` | Découvrir un codebase |
| `/doc-i18n` | Internationalisation |
| `/doc-fix-issue` | Corriger une issue GitHub |
| `/doc-api-spec` | Générer spec OpenAPI/Swagger |
| `/doc-readme` | Créer/améliorer README |
| `/doc-architecture` | Documenter l'architecture |

### BIZ- : Business (11)
| Commande | Usage |
|----------|-------|
| `/biz-model` | Business model, Lean Canvas |
| `/biz-market` | Étude de marché |
| `/biz-mvp` | Définir le MVP |
| `/biz-pricing` | Stratégie de pricing |
| `/biz-pitch` | Créer un pitch deck |
| `/biz-roadmap` | Planifier la roadmap |
| `/biz-launch` | Workflow lancement complet |
| `/biz-competitor` | Analyse concurrentielle |
| `/biz-okr` | Définir les OKRs |
| `/biz-personas` | Créer des personas utilisateur |
| `/biz-research` | Recherche utilisateur |

### GROWTH- : Croissance (8)
| Commande | Usage |
|----------|-------|
| `/growth-landing` | Créer/optimiser landing page |
| `/growth-seo` | Audit SEO |
| `/growth-analytics` | Setup tracking et KPIs |
| `/growth-onboarding` | Parcours d'onboarding UX |
| `/growth-email` | Templates email marketing |
| `/growth-ab-test` | Planifier A/B tests |
| `/growth-retention` | Stratégies de rétention |
| `/growth-funnel` | Analyse et optimisation funnels |

### DATA- : Données (3)
| Commande | Usage |
|----------|-------|
| `/data-pipeline` | Concevoir pipelines ETL/ELT |
| `/data-analytics` | Analyse de données et rapports |
| `/data-modeling` | Modélisation data warehouse |

### LEGAL- : Légal (5)
| Commande | Usage |
|----------|-------|
| `/legal-docs` | CGU, CGV, mentions légales |
| `/legal-rgpd` | Conformité RGPD/GDPR |
| `/legal-payment` | Intégration paiement |
| `/legal-terms-of-service` | Conditions Générales d'Utilisation |
| `/legal-privacy-policy` | Politique de Confidentialité |

## Documentation de Navigation

Pour choisir le bon agent :
- **WHEN-TO-USE-WHICH-AGENT.md** : Guide par situation et type de tâche
- **WORKFLOWS.md** : Workflows recommandés détaillés

## Workflows Recommandés

### Nouvelle feature
```bash
/work-flow-feature "description de la feature"
# ou manuellement:
/work-explore → /work-plan → /dev-tdd → /work-pr
```

### Correction de bug
```bash
/work-flow-bugfix "description du bug"
```

### Nouvelle release
```bash
/work-flow-release "v2.0.0"
```

### Lancement produit
```bash
/work-flow-launch "mon nouveau SaaS"
```

### Audit complet
```bash
/qa-audit  # Sécurité + RGPD + A11y + Perf
```

### Application mobile Flutter
```bash
/work-explore → /work-plan → /dev-flutter + /dev-supabase → /qa-mobile → /work-pr
```

## Hooks (Claude Code 2.1+)

Le projet inclut des hooks automatiques dans `.claude/settings.json`:

| Hook | Déclencheur | Action |
|------|-------------|--------|
| **Protection main** | Avant Edit/Write | Bloque modifications sur main/master |
| **Auto-format** | Après Edit/Write | Prettier sur fichiers TS/JS |
| **Type-check** | Après Edit/Write | Vérifie les types TypeScript |
| **Auto-install** | Après Edit package.json | Exécute npm install |

## Skills (Claude Code 2.1+)

En plus des commandes, le projet inclut des **Skills** dans `.claude/skills/`:

| Skill | Déclenchement automatique |
|-------|---------------------------|
| `test-driven-development` | "TDD", "test first", "écrire les tests" |
| `generating-commit-messages` | "commit", "message de commit" |

Les Skills sont déclenchés automatiquement par Claude selon le contexte.

## Anti-patterns à Éviter

- ❌ Coder sans comprendre l'existant
- ❌ Implémenter sans plan validé
- ❌ Commits géants multi-fonctionnalités
- ❌ Tests avec trop de mocks
- ❌ any partout en TypeScript
- ❌ Copier-coller sans adapter
- ❌ Optimiser prématurément
- ❌ Ignorer les warnings de lint/types
