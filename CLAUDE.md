# Projet claude-socle

> Template de configuration Claude Code pour un workflow optimal : Explore → Plan → Code → Commit

## Commandes Essentielles

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

## Structure du Projet

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

## Workflow Obligatoire : Explore → Plan → Code → Commit

### 1. EXPLORE (`/project:work-explore`)
- Lire et comprendre le code existant AVANT de modifier
- Identifier les patterns et conventions en place
- NE JAMAIS coder sans avoir exploré

### 2. PLAN (`/project:work-plan`)
- Proposer une architecture AVANT d'implémenter
- Lister les fichiers à créer/modifier
- Identifier les risques potentiels
- Attendre validation avant de coder

### 3. CODE (`/project:dev-tdd` ou direct)
- Implémenter en suivant le plan validé
- Tests first si applicable (TDD)
- Commits atomiques et fréquents

### 4. COMMIT (`/project:work-commit` ou `/project:work-pr`)
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

## Agents Disponibles (79)

### Orchestrateur
| Commande | Usage |
|----------|-------|
| `/project:assistant` | Guide de choix des agents et workflows |

### WORK- : Workflow Principal (8)
| Commande | Usage |
|----------|-------|
| `/project:work-explore` | Explorer et comprendre le code |
| `/project:work-plan` | Planifier une implémentation |
| `/project:work-commit` | Créer un commit propre |
| `/project:work-pr` | Créer une Pull Request |
| `/project:work-flow-feature` | Workflow complet feature |
| `/project:work-flow-bugfix` | Workflow complet bugfix |
| `/project:work-flow-release` | Workflow complet release |
| `/project:work-flow-launch` | Workflow complet lancement produit |

### DEV- : Développement (10)
| Commande | Usage |
|----------|-------|
| `/project:dev-tdd` | Développement TDD |
| `/project:dev-test` | Générer des tests |
| `/project:dev-testing-setup` | Configurer l'infrastructure de tests |
| `/project:dev-debug` | Déboguer un problème |
| `/project:dev-refactor` | Refactoring guidé |
| `/project:dev-api` | Créer/documenter API |
| `/project:dev-api-versioning` | Versioning d'API |
| `/project:dev-component` | Créer un composant UI complet |
| `/project:dev-hook` | Créer un hook React/Vue |
| `/project:dev-error-handling` | Stratégie de gestion d'erreurs |

### QA- : Qualité (8)
| Commande | Usage |
|----------|-------|
| `/project:qa-review` | Code review approfondie |
| `/project:qa-security` | Audit de sécurité OWASP |
| `/project:qa-perf` | Analyse de performance |
| `/project:qa-a11y` | Audit accessibilité WCAG |
| `/project:qa-audit` | Audit qualité complet |
| `/project:qa-responsive` | Audit responsive/mobile |
| `/project:qa-automation` | Automatisation des tests |
| `/project:qa-coverage` | Analyse couverture de tests |

### OPS- : Opérations (16)
| Commande | Usage |
|----------|-------|
| `/project:ops-hotfix` | Correction urgente production |
| `/project:ops-release` | Créer une release |
| `/project:ops-deps` | Audit et MAJ des dépendances |
| `/project:ops-docker` | Dockeriser un projet |
| `/project:ops-migrate` | Migration de code/dépendances |
| `/project:ops-ci` | Configuration CI/CD |
| `/project:ops-monitoring` | Logs, métriques, alertes |
| `/project:ops-database` | Schéma, migrations DB |
| `/project:ops-health` | Health check rapide |
| `/project:ops-env` | Gestion des environnements |
| `/project:ops-backup` | Stratégie backup/restore |
| `/project:ops-load-testing` | Tests de charge et stress |
| `/project:ops-cost-optimization` | Optimisation coûts cloud |
| `/project:ops-disaster-recovery` | Plan de reprise après sinistre |
| `/project:ops-infra-code` | Infrastructure as Code (Terraform) |
| `/project:ops-secrets-management` | Gestion sécurisée des secrets |

### DOC- : Documentation (9)
| Commande | Usage |
|----------|-------|
| `/project:doc-generate` | Générer de la documentation |
| `/project:doc-changelog` | Générer/maintenir le changelog |
| `/project:doc-explain` | Expliquer du code complexe |
| `/project:doc-onboard` | Découvrir un codebase |
| `/project:doc-i18n` | Internationalisation |
| `/project:doc-fix-issue` | Corriger une issue GitHub |
| `/project:doc-api-spec` | Générer spec OpenAPI/Swagger |
| `/project:doc-readme` | Créer/améliorer README |
| `/project:doc-architecture` | Documenter l'architecture |

### BIZ- : Business (11)
| Commande | Usage |
|----------|-------|
| `/project:biz-model` | Business model, Lean Canvas |
| `/project:biz-market` | Étude de marché |
| `/project:biz-mvp` | Définir le MVP |
| `/project:biz-pricing` | Stratégie de pricing |
| `/project:biz-pitch` | Créer un pitch deck |
| `/project:biz-roadmap` | Planifier la roadmap |
| `/project:biz-launch` | Workflow lancement complet |
| `/project:biz-competitor` | Analyse concurrentielle |
| `/project:biz-okr` | Définir les OKRs |
| `/project:biz-personas` | Créer des personas utilisateur |
| `/project:biz-research` | Recherche utilisateur |

### GROWTH- : Croissance (8)
| Commande | Usage |
|----------|-------|
| `/project:growth-landing` | Créer/optimiser landing page |
| `/project:growth-seo` | Audit SEO |
| `/project:growth-analytics` | Setup tracking et KPIs |
| `/project:growth-onboarding` | Parcours d'onboarding UX |
| `/project:growth-email` | Templates email marketing |
| `/project:growth-ab-test` | Planifier A/B tests |
| `/project:growth-retention` | Stratégies de rétention |
| `/project:growth-funnel` | Analyse et optimisation funnels |

### DATA- : Données (3)
| Commande | Usage |
|----------|-------|
| `/project:data-pipeline` | Concevoir pipelines ETL/ELT |
| `/project:data-analytics` | Analyse de données et rapports |
| `/project:data-modeling` | Modélisation data warehouse |

### LEGAL- : Légal (5)
| Commande | Usage |
|----------|-------|
| `/project:legal-docs` | CGU, CGV, mentions légales |
| `/project:legal-rgpd` | Conformité RGPD/GDPR |
| `/project:legal-payment` | Intégration paiement |
| `/project:legal-terms-of-service` | Conditions Générales d'Utilisation |
| `/project:legal-privacy-policy` | Politique de Confidentialité |

## Documentation de Navigation

Pour choisir le bon agent :
- **WHEN-TO-USE-WHICH-AGENT.md** : Guide par situation et type de tâche
- **WORKFLOWS.md** : Workflows recommandés détaillés

## Workflows Recommandés

### Nouvelle feature
```bash
/project:work-flow-feature "description de la feature"
# ou manuellement:
/project:work-explore → /project:work-plan → /project:dev-tdd → /project:work-pr
```

### Correction de bug
```bash
/project:work-flow-bugfix "description du bug"
```

### Nouvelle release
```bash
/project:work-flow-release "v2.0.0"
```

### Lancement produit
```bash
/project:work-flow-launch "mon nouveau SaaS"
```

### Audit complet
```bash
/project:qa-audit  # Sécurité + RGPD + A11y + Perf
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
