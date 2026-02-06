# Projet claude-socle

> Template de configuration Claude Code pour un workflow optimal : Explore → Specify → Plan → TDD → Commit

@docs/reference/commands.md
@docs/reference/project-structures.md

## Workflow Obligatoire : Explore → Specify → Plan → TDD → Commit

### 1. EXPLORE (`/work:work-explore`)
- Lire et comprendre le code existant AVANT de modifier
- Identifier les patterns et conventions en place
- NE JAMAIS coder sans avoir exploré

### 2. SPECIFY (`/work:work-specify`) - NOUVEAU
- Créer une spécification fonctionnelle structurée
- Définir les User Stories prioritisées (P1 = MVP, P2, P3)
- Rédiger les critères d'acceptation (Given/When/Then)
- Focus sur le QUOI et POURQUOI, pas le COMMENT
- Optionnel : `/work:work-clarify` pour réduire les ambiguïtés

### 3. PLAN (`/work:work-plan`)
- Proposer une architecture AVANT d'implémenter
- Lister les fichiers à créer/modifier
- Découper en tâches par User Story ([US1], [US2]...)
- Marquer les tâches parallélisables [P]
- Identifier les risques potentiels
- Génère `specs/[feature]/plan.md` et `tasks.md`

### 4. TDD (`/dev:dev-tdd`) - OBLIGATOIRE
- IMPORTANT: Toujours écrire les tests AVANT le code
- Cycle Red-Green-Refactor obligatoire:
  1. RED: Écrire un test qui échoue
  2. GREEN: Écrire le code minimal pour passer le test
  3. REFACTOR: Améliorer le code sans casser les tests
- Couverture minimum 80% sur nouveau code
- Commits atomiques et fréquents

### 5. COMMIT (`/work:work-commit` ou `/work:work-pr`)
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
| [docs/guides/PROMPTING-GUIDE.md](docs/guides/PROMPTING-GUIDE.md) | Techniques de prompting avance (Boris Cherny) |

### Setup
```bash
# Configuration automatique du socle
./scripts/new-project.sh --simple .
```

## Workflows Recommandés

### Nouvelle feature
```bash
/work:work-flow-feature "description de la feature"
# ou manuellement (TDD obligatoire):
/work:work-explore → /work:work-specify → /work:work-plan → /dev:dev-tdd → /work:work-pr
```

### Correction de bug
```bash
/work:work-flow-bugfix "description du bug"
```

### Nouvelle release
```bash
/work:work-flow-release "v2.0.0"
```

### Lancement produit
```bash
/work:work-flow-launch "mon nouveau SaaS"
```

### Audit complet
```bash
/qa:qa-audit  # Sécurité + RGPD + A11y + Perf
```

### Équipe d'agents (Agent Teams)
```bash
/work:work-team "audit complet du projet"       # Audit parallèle (3 agents)
/work:work-team "implémenter les notifications"  # Feature en équipe
/work:work-team "investiguer le bug de connexion" # Debug collaboratif
```

### Application mobile Flutter
```bash
/work:work-explore → /work:work-specify → /work:work-plan → /dev:dev-tdd → /dev:dev-flutter + /dev:dev-supabase → /qa:qa-mobile → /work:work-pr
```

### GitFlow (gestion avancée des branches)
```bash
# Initialiser GitFlow sur le repo
/ops:ops-gitflow-init

# Workflow feature
/ops:ops-gitflow-feature start "user-auth"
# ... développer ...
/ops:ops-gitflow-feature finish "user-auth"

# Workflow release
/ops:ops-gitflow-release start "v1.2.0"
# ... bump version, changelog ...
/ops:ops-gitflow-release finish "v1.2.0"

# Hotfix urgent
/ops:ops-gitflow-hotfix start "critical-bug"
# ... fix ...
/ops:ops-gitflow-hotfix finish "critical-bug"
```

@docs/reference/hooks-reference.md
@docs/reference/skills-catalog.md
@docs/reference/advanced-features.md
@docs/reference/best-practices.md

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
- **Ne pas donner de moyen de vérification à Claude**
- **Prompts vagues sans contexte ni exemples**
