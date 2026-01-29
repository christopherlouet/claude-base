# Projet claude-socle

> Template de configuration Claude Code pour un workflow optimal : Explore → Specify → Plan → TDD → Commit

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

### Backend (Python)
| Commande | Description |
|----------|-------------|
| `pip install -r requirements.txt` | Installer les dépendances |
| `python -m venv .venv` | Créer un environnement virtuel |
| `source .venv/bin/activate` | Activer l'environnement (Linux/Mac) |
| `pytest` | Lancer les tests |
| `pytest --cov` | Tests avec couverture |
| `ruff check .` | Linter rapide |
| `ruff format .` | Formater le code |
| `mypy .` | Vérifier les types |

### Backend (Go)
| Commande | Description |
|----------|-------------|
| `go mod download` | Installer les dépendances |
| `go run .` | Lancer l'application |
| `go test ./...` | Lancer les tests |
| `go test -cover ./...` | Tests avec couverture |
| `go build` | Compiler le binaire |
| `go fmt ./...` | Formater le code |
| `go vet ./...` | Analyser le code |
| `golangci-lint run` | Linter complet |

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

### Backend (Python)
```
/src
├── /api            # Routes FastAPI/Flask
├── /core           # Config, security, dependencies
├── /models         # SQLAlchemy/Pydantic models
├── /schemas        # Pydantic DTOs
├── /services       # Logique métier
├── /repositories   # Accès données
└── /utils          # Fonctions utilitaires
/tests              # Tests pytest
pyproject.toml      # Config projet (deps, tools)
```

### Backend (Go)
```
/cmd
└── /app            # Point d'entrée (main.go)
/internal
├── /api            # Handlers HTTP
├── /domain         # Entities, interfaces
├── /service        # Logique métier
├── /repository     # Accès données
└── /config         # Configuration
/pkg                # Code réutilisable externe
go.mod              # Dépendances
go.sum              # Checksums
```

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

## Agents Disponibles (118 commands, 56 sub-agents, 40 skills)

### Orchestrateur (Point d'entrée unique)
| Commande | Mode | Usage |
|----------|------|-------|
| `/assistant` | Guidé | Analyse → Recommande → Attend confirmation |
| `/assistant-auto` | Automatique | Analyse → Exécute directement le workflow |

### WORK- : Workflow Principal (10)
| Commande | Usage |
|----------|-------|
| `/work-explore` | Explorer et comprendre le code |
| `/work-specify` | Créer une spécification fonctionnelle (User Stories, critères) |
| `/work-clarify` | Clarifier les ambiguïtés de la spec (questions ciblées) |
| `/work-plan` | Planifier une implémentation (génère plan.md + tasks.md) |
| `/work-commit` | Créer un commit propre |
| `/work-pr` | Créer une Pull Request |
| `/work-flow-feature` | Workflow complet feature |
| `/work-flow-bugfix` | Workflow complet bugfix |
| `/work-flow-release` | Workflow complet release |
| `/work-flow-launch` | Workflow complet lancement produit |

### DEV- : Développement (23)
| Commande | Usage |
|----------|-------|
| `/dev-tdd` | Développement TDD |
| `/dev-test` | Générer des tests |
| `/dev-testing-setup` | Configurer l'infrastructure de tests |
| `/dev-debug` | Déboguer un problème (méthodologie 4 phases) |
| `/dev-refactor` | Refactoring guidé + réduction d'entropie |
| `/dev-document` | Génération de documents (PDF, DOCX, XLSX, PPTX) |
| `/dev-api` | Créer/documenter API |
| `/dev-api-versioning` | Versioning d'API |
| `/dev-component` | Créer un composant UI complet |
| `/dev-hook` | Créer un hook React/Vue |
| `/dev-error-handling` | Stratégie de gestion d'erreurs |
| `/dev-react-perf` | Optimisation performance React/Next.js |
| `/dev-mcp` | Créer des serveurs MCP (Model Context Protocol) |
| `/dev-flutter` | Widgets et screens Flutter |
| `/dev-supabase` | Backend Supabase (Auth, DB, Storage, Postgres perf) |
| `/dev-graphql` | API GraphQL client/serveur |
| `/dev-neovim` | Plugins et config Neovim/Lua |
| `/dev-prompt-engineering` | Optimisation de prompts LLM |
| `/dev-rag` | Systèmes RAG (Retrieval-Augmented Generation) |
| `/dev-design-system` | Design tokens et bibliothèque de composants |
| `/dev-prisma` | ORM Prisma (schema, migrations, queries) |
| `/dev-trpc` | APIs type-safe avec tRPC |
| `/dev-ai-integration` | Intégration LLMs (OpenAI, Claude API) |

### QA- : Qualité (14)
| Commande | Usage |
|----------|-------|
| `/qa-review` | Code review approfondie + analyse de nommage |
| `/qa-security` | Audit de sécurité OWASP |
| `/qa-perf` | Analyse de performance |
| `/qa-a11y` | Audit accessibilité WCAG |
| `/qa-audit` | Audit qualité complet |
| `/qa-design` | Audit UI/UX (100+ règles design web) |
| `/qa-responsive` | Audit responsive/mobile web |
| `/qa-automation` | Automatisation des tests |
| `/qa-coverage` | Analyse couverture de tests |
| `/qa-kaizen` | Amélioration continue (PDCA, Muda) |
| `/qa-mobile` | Audit qualité apps mobiles (Flutter) |
| `/qa-neovim` | Audit config Neovim (perf, keymaps) |
| `/qa-e2e` | Tests End-to-End (Playwright, Cypress) |
| `/qa-tech-debt` | Identifier et prioriser la dette technique |

### OPS- : Opérations (30)
| Commande | Usage |
|----------|-------|
| `/ops-hotfix` | Correction urgente production |
| `/ops-release` | Créer une release |
| `/ops-gitflow-init` | Initialiser GitFlow (créer develop, configurer) |
| `/ops-gitflow-feature` | Gérer les branches feature (start/finish) |
| `/ops-gitflow-release` | Gérer les branches release (start/finish) |
| `/ops-gitflow-hotfix` | Gérer les hotfixes GitFlow (start/finish) |
| `/ops-deps` | Audit et MAJ des dépendances |
| `/ops-docker` | Dockeriser un projet |
| `/ops-k8s` | Déploiement Kubernetes (manifests, Helm) |
| `/ops-vps` | Déploiement VPS (OVH, Hetzner, DigitalOcean) |
| `/ops-migrate` | Migration de code/dépendances |
| `/ops-ci` | Configuration CI/CD |
| `/ops-monitoring` | Instrumentation code (logs, métriques, traces) |
| `/ops-observability-stack` | Déployer Prometheus, Grafana, Loki, Alertmanager |
| `/ops-grafana-dashboard` | Créer dashboards Grafana (templates, alertes) |
| `/ops-database` | Schéma, migrations DB |
| `/ops-health` | Health check rapide |
| `/ops-env` | Gestion des environnements |
| `/ops-backup` | Stratégie backup/restore |
| `/ops-load-testing` | Tests de charge et stress |
| `/ops-cost-optimization` | Optimisation coûts cloud |
| `/ops-disaster-recovery` | Plan de reprise après sinistre |
| `/ops-infra-code` | Infrastructure as Code (Terraform) |
| `/ops-secrets-management` | Gestion sécurisée des secrets |
| `/ops-mobile-release` | Publication App Store / Google Play |
| `/ops-serverless` | Déploiement serverless (Lambda, Vercel, CF Workers) |
| `/ops-vercel` | Configuration et déploiement Vercel |
| `/ops-proxmox` | Infrastructure Proxmox VE (VMs, LXC, réseau, backup) |
| `/ops-opnsense` | Configuration OPNsense via Terraform (firewall, NAT, DHCP/DNS) |
| `/ops-rollback` | Procédure de rollback sécurisée |

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

### GROWTH- : Croissance (11)
| Commande | Usage |
|----------|-------|
| `/growth-landing` | Créer/optimiser landing page |
| `/growth-seo` | Audit SEO |
| `/growth-analytics` | Setup tracking et KPIs |
| `/growth-app-store-analytics` | Métriques App Store / Google Play |
| `/growth-onboarding` | Parcours d'onboarding UX |
| `/growth-email` | Templates email marketing |
| `/growth-ab-test` | Planifier A/B tests |
| `/growth-retention` | Stratégies de rétention |
| `/growth-funnel` | Analyse et optimisation funnels |
| `/growth-localization` | Stratégie de localisation multi-marchés |
| `/growth-cro` | Optimisation du taux de conversion (CRO) |

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

## Hooks (Claude Code 2.1+)

Le projet inclut des hooks automatiques dans `.claude/settings.json`:

| Hook | Déclencheur | Action |
|------|-------------|--------|
| **Protection main** | Avant Edit/Write | Bloque modifications sur main/master |
| **Auto-format** | Après Edit/Write | Prettier sur fichiers TS/JS |
| **Type-check** | Après Edit/Write | Vérifie les types TypeScript |
| **Auto-install** | Après Edit package.json | Exécute npm install |

## Skills (Claude Code 2.1+)

En plus des commandes, le projet inclut **40 Skills** dans `.claude/skills/`:

### Skills de base
| Skill | Déclenchement automatique | Context |
|-------|---------------------------|---------|
| `dev-tdd` | "TDD", "test first", "écrire les tests" | fork |
| `work-commit` | "commit", "message de commit" | fork |
| `dev-debug` | "bug", "erreur", "debug" | fork |
| `qa-review` | "review", "code review" | fork |
| `qa-security` | "audit sécurité", "OWASP" | fork |
| `work-plan` | "planifier", "architecture" | fork |
| `work-explore` | "explorer", "comprendre le code" | fork |
| `work-pr` | "PR", "pull request" | fork |
| `dev-api` | "API", "endpoint", "REST" | fork |

### Skills additionnels
| Skill | Déclenchement automatique | Context |
|-------|---------------------------|---------|
| `dev-flutter` | "Flutter", "widget", "BLoC" | fork |
| `dev-supabase` | "Supabase", "auth", "RLS" | fork |
| `dev-react-perf` | "React perf", "re-render", "memo" | fork |
| `ops-docker` | "Docker", "container", "Dockerfile" | fork |
| `ops-ci` | "CI/CD", "GitHub Actions", "pipeline" | fork |
| `ops-database` | "schema", "migration", "index" | fork |
| `ops-monitoring` | "logs", "métriques", "traces" | fork |
| `doc-generate` | "documenter", "README", "JSDoc" | fork |
| `doc-changelog` | "changelog", "release notes" | fork |
| `dev-refactor` | "refactorer", "clean code", "restructurer" | fork |
| `dev-error-handling` | "gestion erreurs", "exceptions", "error boundary" | fork |
| `dev-graphql` | "GraphQL", "resolver", "schema" | fork |
| `ops-mobile-release` | "App Store", "Play Store", "Fastlane" | fork |
| `data-pipeline` | "ETL", "Airflow", "dbt" | fork |
| `qa-perf` | "optimiser", "latence", "TTFB" | fork |
| `dev-prompt-engineering` | "prompt", "instruction", "few-shot", "LLM" | fork |
| `qa-e2e` | "E2E", "Playwright", "Cypress", "parcours utilisateur" | fork |
| `feature-flags` | "feature flag", "A/B test", "deploiement progressif" | fork |
| `ops-infra-code` | "Terraform", "IaC", "OpenTofu", "module", "state" | fork |
| `ops-proxmox` | "Proxmox", "PVE", "VM Proxmox", "LXC", "PBS" | fork |
| `ops-opnsense` | "OPNsense", "firewall", "NAT", "DHCP", "Unbound" | fork |
| `qa-tech-debt` | "dette technique", "tech debt", "refactoring priorité" | fork |
| `qa-design` | "audit design", "UI/UX", "interface utilisateur" | fork |
| `api-mocking` | "mock API", "MSW", "test sans backend" | fork |
| `state-management` | "state", "Redux", "Zustand", "store" | fork |
| `dev-document` | "PDF", "DOCX", "XLSX", "PPTX", "document", "rapport" | fork |
| `growth-cro` | "conversion", "CRO", "signup flow", "onboarding", "paywall" | fork |
| `parallel-agents` | "parallele", "concurrent", "fan-out", "multi-agents" | fork |
| `session-handoff` | "handoff", "reprise", "transfert session", "contexte" | fork |
| `git-worktrees` | "worktree", "dev parallele", "branches simultanées" | fork |
| `writing-skills` | "créer skill", "nouveau skill", "écrire un skill" | fork |

### Configuration des Skills

Chaque skill définit:
- **allowed-tools**: Outils autorisés pour le skill
- **context: fork**: Exécution dans un contexte isolé (recommandé)

Les Skills sont déclenchés automatiquement par Claude selon le contexte.

## Sub-Agents (Claude Code 2.1+)

Le projet inclut des **Sub-Agents** dans `.claude/agents/` pour les tâches qui bénéficient d'un contexte isolé.

### Différence Commands vs Skills vs Agents

| Concept | Dossier | Déclenchement | Contexte |
|---------|---------|---------------|----------|
| **Commands** | `.claude/commands/` | Manuel (`/nom`) | Partagé |
| **Skills** | `.claude/skills/` | Automatique | Partagé |
| **Agents** | `.claude/agents/` | Délégation auto | **Isolé** |

### Avantages des Sub-Agents

- **Contexte isolé** : Ne pollue pas la conversation principale
- **Outils restreints** : Accès limité (lecture seule pour les audits)
- **Modèle optimisé** : Haiku pour tâches simples (économie de tokens)
- **Parallélisation** : Plusieurs agents peuvent tourner simultanément

### Agents disponibles (56)

#### Exploration & Documentation
| Agent | Modèle | Outils | Usage |
|-------|--------|--------|-------|
| `work-explore` | haiku | Read, Grep, Glob | Explorer un codebase (lecture seule) |
| `doc-onboard` | haiku | Read, Grep, Glob | Onboarding nouveau développeur |
| `doc-generate` | haiku | Read, Grep, Glob | Génération documentation |
| `doc-changelog` | haiku | Read, Grep, Glob | Maintenance changelog |
| `doc-explain` | haiku | Read, Grep, Glob | Explication de code |

#### Qualité & Audits
| Agent | Modèle | Outils | Usage |
|-------|--------|--------|-------|
| `qa-audit` | sonnet | Read, Grep, Glob, Bash | Audit complet (sécu + RGPD + a11y + perf) |
| `qa-security` | sonnet | Read, Grep, Glob | Audit sécurité OWASP Top 10 |
| `qa-perf` | sonnet | Read, Grep, Glob, Bash | Audit performance, Core Web Vitals |
| `qa-a11y` | haiku | Read, Grep, Glob | Audit accessibilité WCAG 2.1 |
| `qa-coverage` | haiku | Read, Grep, Glob, Bash | Analyse couverture de tests |
| `qa-responsive` | haiku | Read, Grep, Glob | Audit responsive/mobile-first |
| `qa-e2e` | sonnet | Read, Grep, Glob, Bash | Tests E2E Playwright/Cypress |
| `qa-tech-debt` | haiku | Read, Grep, Glob | Identifier et prioriser la dette technique |
| `qa-design` | haiku | Read, Grep, Glob | Audit UI/UX (100+ règles design web) |

#### Opérations
| Agent | Modèle | Outils | Usage |
|-------|--------|--------|-------|
| `ops-deps` | haiku | Read, Grep, Glob, Bash | Audit dépendances, vulnérabilités |
| `ops-health` | haiku | Read, Grep, Glob, Bash | Health check rapide du projet |
| `ops-docker` | haiku | Read, Grep, Glob, Bash | Containerisation Docker |
| `ops-ci` | haiku | Read, Grep, Glob, Bash | Configuration CI/CD |
| `ops-database` | sonnet | Read, Grep, Glob, Bash | Schémas et migrations DB |
| `ops-monitoring` | haiku | Read, Grep, Glob, Bash | Instrumentation et monitoring |
| `ops-serverless` | haiku | Read, Grep, Glob, Bash | Déploiement serverless |
| `ops-vercel` | haiku | Read, Grep, Glob, Bash | Configuration Vercel |
| `ops-infra-code` | sonnet | Read, Grep, Glob, Edit, Write, Bash | Infrastructure as Code (Terraform/OpenTofu) |
| `ops-proxmox` | sonnet | Read, Grep, Glob, Edit, Write, Bash | Infrastructure Proxmox VE (VMs, LXC, réseau, backup) |
| `ops-opnsense` | sonnet | Read, Grep, Glob, Edit, Write, Bash | Configuration OPNsense (interfaces, firewall, NAT, DHCP/DNS) |
| `ops-migration` | sonnet | Read, Grep, Glob, Bash | Migration de frameworks et versions |

#### Développement
| Agent | Modèle | Outils | Usage |
|-------|--------|--------|-------|
| `dev-debug` | sonnet | Read, Grep, Glob, Bash | Investigation et diagnostic de bugs |
| `dev-component` | haiku | Read, Grep, Glob | Création composants UI |
| `dev-test` | haiku | Read, Grep, Glob, Bash | Génération de tests |
| `dev-flutter` | sonnet | Read, Grep, Glob | Widgets et screens Flutter |
| `dev-supabase` | sonnet | Read, Grep, Glob, Bash | Backend Supabase |
| `dev-prompt-engineering` | sonnet | Read, Grep, Glob, WebFetch | Optimisation prompts LLM |
| `dev-rag` | sonnet | Read, Grep, Glob, Bash | Architecture RAG |
| `dev-design-system` | haiku | Read, Grep, Glob | Design tokens et composants |
| `dev-prisma` | haiku | Read, Grep, Glob, Bash | ORM Prisma |
| `dev-trpc` | haiku | Read, Grep, Glob | APIs type-safe tRPC |
| `dev-ai-integration` | sonnet | Read, Grep, Glob, Bash | Intégration LLMs (OpenAI, Claude) |
| `dev-document` | sonnet | Read, Grep, Glob, Edit, Write, Bash | Génération documents (PDF, DOCX, XLSX, PPTX) |
| `dev-tdd` | sonnet | Read, Grep, Glob, Edit, Write, Bash | Développement TDD (Red-Green-Refactor) |

#### Business & Growth
| Agent | Modèle | Outils | Usage |
|-------|--------|--------|-------|
| `biz-model` | haiku | Read, Grep, Glob, WebSearch | Analyse business model, Lean Canvas |
| `biz-competitor` | haiku | Read, Grep, Glob, WebSearch | Analyse concurrentielle |
| `biz-mvp` | haiku | Read, Grep, Glob | Définition MVP |
| `biz-personas` | haiku | Read, Grep, Glob, WebSearch | Création personas |
| `growth-seo` | haiku | Read, Grep, Glob, WebFetch | Audit SEO technique |
| `growth-analytics` | haiku | Read, Grep, Glob | Setup analytics |
| `growth-landing` | haiku | Read, Grep, Glob | Optimisation landing |
| `growth-funnel` | haiku | Read, Grep, Glob | Analyse funnels |
| `growth-localization` | haiku | Read, Grep, Glob | Stratégie de localisation multi-marchés |
| `growth-cro` | haiku | Read, Grep, Glob | Optimisation taux de conversion (CRO) |

#### Data
| Agent | Modèle | Outils | Usage |
|-------|--------|--------|-------|
| `data-pipeline` | sonnet | Read, Grep, Glob, Bash | Pipelines ETL/ELT |
| `data-analytics` | haiku | Read, Grep, Glob | Analyse de données |
| `data-modeling` | sonnet | Read, Grep, Glob | Modélisation DW |

#### Légal
| Agent | Modèle | Outils | Usage |
|-------|--------|--------|-------|
| `legal-rgpd` | haiku | Read, Grep, Glob | Conformité RGPD |
| `legal-payment` | sonnet | Read, Grep, Glob | Intégration paiement |
| `legal-privacy-policy` | haiku | Read, Grep, Glob | Politique confidentialité |
| `legal-terms-of-service` | haiku | Read, Grep, Glob | CGU |

### Utilisation

Claude délègue automatiquement aux agents appropriés selon le contexte :

```
"Explore le code d'authentification"     → work-explore (haiku, lecture seule)
"Fais un audit de sécurité"              → qa-security (sonnet, OWASP)
"Vérifie les dépendances"                → ops-deps (haiku, npm audit)
"Analyse les concurrents"                → biz-competitor (haiku, recherche web)
```

### Configuration des Agents

Chaque agent définit:
- **model**: `haiku` (rapide/économique) ou `sonnet` (complexe)
- **permissionMode**: `plan` (lecture seule) ou `default`
- **disallowedTools**: Outils interdits (ex: `Edit, Write, NotebookEdit`)
- **hooks**: Validations automatiques (PreToolUse, PostToolUse)
- **skills**: Skills injectés dans l'agent (ex: `qa-security`, `work-explore`)

## Modular Rules (Claude Code 2.1+)

Les règles sont organisées de manière modulaire dans `.claude/rules/` (20 règles):

### Règles par langage
| Fichier | Paths | Contenu |
|---------|-------|---------|
| `typescript.md` | `**/*.ts`, `**/*.tsx` | Strict mode, types, conventions |
| `react.md` | `**/*.tsx`, `**/components/**` | Composants, hooks, performance |
| `flutter.md` | `**/*.dart`, `**/lib/**` | Clean Architecture, BLoC, widgets |
| `python.md` | `**/*.py`, `**/pyproject.toml` | Type hints, PEP 8, async patterns |
| `go.md` | `**/*.go`, `**/go.mod` | Error handling, interfaces, concurrency |
| `java.md` | `**/*.java` | Optional, Streams, Spring Boot |
| `csharp.md` | `**/*.cs` | Nullable, async/await, .NET patterns |
| `ruby.md` | `**/*.rb`, `**/Gemfile` | Rails conventions, RSpec |
| `php.md` | `**/*.php` | PSR-12, Laravel, type declarations |
| `rust.md` | `**/*.rs`, `**/Cargo.toml` | Ownership, error handling, traits |

### Règles transversales
| Fichier | Paths | Contenu |
|---------|-------|---------|
| `tdd-enforcement.md` | `**/*.ts`, `**/*.tsx`, `**/*.dart`, `**/*.py`, `**/*.go`, etc. | **TDD proactif obligatoire** |
| `testing.md` | `**/*.test.ts`, `**/__tests__/**` | Couverture, mocks, edge cases |
| `security.md` | `**/auth/**`, `**/api/**` | Validation, XSS, SQL injection |
| `api.md` | `**/api/**`, `**/routes/**` | REST, validation, status codes |
| `git.md` | - | Conventional commits, branches |
| `workflow.md` | - | Explore → Plan → Code → Commit |
| `accessibility.md` | `**/*.tsx`, `**/components/**` | WCAG 2.1 AA, a11y patterns |
| `performance.md` | `**/*.tsx`, `**/pages/**` | Core Web Vitals, optimisation |
| `nextjs.md` | `**/app/**`, `**/pages/**`, `**/next.config.*` | RSC, data fetching, caching, App Router |
| `verification.md` | `**/*.ts`, `**/*.tsx`, `**/*.py`, `**/*.go`, etc. | Vérification avant completion (4 phases) |

### Path-Specific Rules

Les règles peuvent être conditionnelles par chemin de fichier:
```yaml
---
paths:
  - "**/*.tsx"
  - "**/components/**"
---
# Règles appliquées uniquement à ces fichiers
```

## Output Styles (Claude Code 2.1+)

Modes d'interaction personnalisés dans `.claude/output-styles/` (7 styles):

| Style | Utilisation | Commande |
|-------|-------------|----------|
| `teaching` | Mode pédagogique avec explications | `/output-style teaching` |
| `concise` | Réponses brèves et directes | `/output-style concise` |
| `technical` | Détails techniques approfondis | `/output-style technical` |
| `review` | Revue de code structurée | `/output-style review` |
| `emoji` | Réponses enrichies d'emojis | `/output-style emoji` |
| `minimal` | Réponses épurées sans décoration | `/output-style minimal` |
| `structured` | Structure ASCII avec séparateurs | `/output-style structured` |

Voir `.claude/output-styles/README.md` pour la documentation complète avec exemples.

## Templates de Spécification (inspirés de Spec-Kit)

Templates structurés pour le workflow Explore → Specify → Plan → Code dans `.claude/templates/`:

| Template | Description | Utilisé par |
|----------|-------------|-------------|
| `spec-template.md` | Spécification fonctionnelle avec User Stories | `/work-specify` |
| `plan-template.md` | Plan d'implémentation technique | `/work-plan` |
| `tasks-template.md` | Découpage en tâches par User Story | `/work-plan` |

### Structure d'une Spécification

```
specs/[feature]/
├── spec.md           # Spécification fonctionnelle
├── plan.md           # Plan d'implémentation
├── tasks.md          # Découpage en tâches
└── clarifications.md # Historique des clarifications (opt)
```

### Conventions

| Marqueur | Signification |
|----------|---------------|
| `P1` | Priorité MVP (essentiel) |
| `P2` | Priorité Important |
| `P3` | Priorité Nice-to-have |
| `[P]` | Tâche parallélisable |
| `[US1]` | Appartient à User Story 1 |
| `EF-XXX` | Exigence Fonctionnelle |
| `CS-XXX` | Critère de Succès |

### Workflow Spec-Driven

```
/work-explore → /work-specify → /work-clarify (opt) → /work-plan → /dev-tdd
```

### Templates Proxmox (Terraform)

Templates pour la gestion d'infrastructure Proxmox VE dans `.claude/templates/proxmox/`:

| Template | Description |
|----------|-------------|
| `provider-template.tf` | Configuration provider bpg/proxmox |
| `vm-module-template.tf` | Module VM avec cloud-init |
| `lxc-module-template.tf` | Module conteneur LXC |
| `infrastructure-template.tf` | Infrastructure type complète |
| `README.md` | Guide d'utilisation des templates |

## MCP Configuration (Claude Code 2.1+)

Configuration centralisée des MCP servers dans `.mcp.json`:

| Server | Usage | Activé |
|--------|-------|--------|
| `filesystem` | Accès avancé aux fichiers | Non |
| `memory` | Mémoire persistante | Non |
| `fetch` | Requêtes HTTP externes | Non |
| `github` | Intégration GitHub | Non |
| `postgres` | Connexion PostgreSQL | Non |
| `sqlite` | Base SQLite locale | Non |
| `puppeteer` | Automatisation navigateur | Non |

Pour activer un server: `"enabled": true` dans `.mcp.json`

## Anti-patterns à Éviter

- ❌ Coder sans comprendre l'existant
- ❌ Implémenter sans plan validé
- ❌ Coder AVANT d'écrire les tests (violer TDD)
- ❌ Commits géants multi-fonctionnalités
- ❌ Tests avec trop de mocks
- ❌ any partout en TypeScript
- ❌ Copier-coller sans adapter
- ❌ Optimiser prématurément
- ❌ Ignorer les warnings de lint/types
