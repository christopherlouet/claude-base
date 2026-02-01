# Projet claude-socle

> Template de configuration Claude Code pour un workflow optimal : Explore → Specify → Plan → TDD → Commit

@docs/reference/commands.md
@docs/reference/project-structures.md

## Workflow Obligatoire : Explore → Specify → Plan → TDD → Commit

### 1. EXPLORE (`/work-explore`)
- Lire et comprendre le code existant AVANT de modifier
- Identifier les patterns et conventions en place
- NE JAMAIS coder sans avoir exploré

### 2. SPECIFY (`/work-specify`) - NOUVEAU
- Créer une spécification fonctionnelle structurée
- Définir les User Stories prioritisées (P1 = MVP, P2, P3)
- Rédiger les critères d'acceptation (Given/When/Then)
- Focus sur le QUOI et POURQUOI, pas le COMMENT
- Optionnel : `/work-clarify` pour réduire les ambiguïtés

### 3. PLAN (`/work-plan`)
- Proposer une architecture AVANT d'implémenter
- Lister les fichiers à créer/modifier
- Découper en tâches par User Story ([US1], [US2]...)
- Marquer les tâches parallélisables [P]
- Identifier les risques potentiels
- Génère `specs/[feature]/plan.md` et `tasks.md`

### 4. TDD (`/dev-tdd`) - OBLIGATOIRE
- IMPORTANT: Toujours écrire les tests AVANT le code
- Cycle Red-Green-Refactor obligatoire:
  1. RED: Écrire un test qui échoue
  2. GREEN: Écrire le code minimal pour passer le test
  3. REFACTOR: Améliorer le code sans casser les tests
- Couverture minimum 80% sur nouveau code
- Commits atomiques et fréquents

### 5. COMMIT (`/work-commit` ou `/work-pr`)
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

## Sécurité

- IMPORTANT: Valider TOUTES les entrées utilisateur
- IMPORTANT: Échapper les outputs HTML (prévention XSS)
- IMPORTANT: Utiliser des requêtes paramétrées (prévention SQL injection)
- Ne jamais logger de données sensibles
- Dépendances à jour (`npm audit`)

### Gestion des secrets
- IMPORTANT: Ne jamais commiter de secrets (.env, credentials, API keys)
- Utiliser des variables d'environnement pour les valeurs sensibles
- Dans les exemples et templates, utiliser des placeholders : `${POSTGRES_PASSWORD:?required}`, `${{ secrets.API_KEY }}`
- Référencer `.env.example` avec des valeurs fictives, jamais de vrais secrets

### MCP Security
- Tous les serveurs MCP sont désactivés par défaut dans `.mcp.json`
- N'activer que les serveurs nécessaires au projet
- Vérifier les permissions accordées avant activation (filesystem, réseau, DB)
- Ne jamais exposer de credentials dans la configuration MCP

### curl | bash
- Éviter le pattern `curl URL | sh` qui exécute du code distant sans vérification
- Préférer : télécharger le script, vérifier son contenu/checksum, puis exécuter
- Voir `scripts/lib/common.sh` pour les fonctions `sanitize_input()` et `validate_input()`

@docs/reference/agents-catalog.md

## Documentation de Navigation

### Guides principaux
| Document | Description |
|----------|-------------|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Architecture Commands vs Agents vs Skills vs Rules |
| [docs/WORKFLOWS.md](docs/WORKFLOWS.md) | Diagrammes visuels des workflows |
| [WHEN-TO-USE-WHICH-AGENT.md](WHEN-TO-USE-WHICH-AGENT.md) | Guide de choix des agents |

### Guides par domaine
| Guide | Stack |
|-------|-------|
| [docs/guides/WEB-GUIDE.md](docs/guides/WEB-GUIDE.md) | React, Next.js, Vue, Node.js |
| [docs/guides/MOBILE-GUIDE.md](docs/guides/MOBILE-GUIDE.md) | Flutter, Clean Architecture, BLoC |
| [docs/guides/API-GUIDE.md](docs/guides/API-GUIDE.md) | REST, GraphQL, Express, Fastify |
| [docs/guides/DATA-GUIDE.md](docs/guides/DATA-GUIDE.md) | ETL, Airflow, dbt, Data Warehouse |

### Setup
```bash
# Configuration automatique du socle
./scripts/setup-wizard.sh
```

## Workflows Recommandés

### Nouvelle feature
```bash
/work-flow-feature "description de la feature"
# ou manuellement (TDD obligatoire):
/work-explore → /work-specify → /work-plan → /dev-tdd → /work-pr
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
/work-explore → /work-specify → /work-plan → /dev-tdd → /dev-flutter + /dev-supabase → /qa-mobile → /work-pr
```

### GitFlow (gestion avancée des branches)
```bash
# Initialiser GitFlow sur le repo
/ops-gitflow-init

# Workflow feature
/ops-gitflow-feature start "user-auth"
# ... développer ...
/ops-gitflow-feature finish "user-auth"

# Workflow release
/ops-gitflow-release start "v1.2.0"
# ... bump version, changelog ...
/ops-gitflow-release finish "v1.2.0"

# Hotfix urgent
/ops-gitflow-hotfix start "critical-bug"
# ... fix ...
/ops-gitflow-hotfix finish "critical-bug"
```

@docs/reference/hooks-reference.md
@docs/reference/skills-catalog.md
@docs/reference/advanced-features.md

## Anti-patterns à Éviter

- Coder sans comprendre l'existant
- Implémenter sans plan validé
- Coder AVANT d'écrire les tests (violer TDD)
- Commits géants multi-fonctionnalités
- Tests avec trop de mocks
- any partout en TypeScript
- Copier-coller sans adapter
- Optimiser prématurément
- Ignorer les warnings de lint/types
