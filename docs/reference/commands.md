# Commandes Essentielles

## Web (Node/React)
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

## Mobile (Flutter)
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

## Backend (Python)
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

## Backend (Go)
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

## CLI Flags Avancés

| Flag | Description | Exemple |
|------|-------------|---------|
| `--agent <name>` | Lancer un agent spécifique directement | `claude --agent qa-security` |
| `--agents` | Lister tous les agents disponibles | `claude --agents` |
| `--chrome` | Activer l'intégration Chrome (tests visuels) | `claude --chrome` |
| `--teleport` | Activer la connexion Teleport (remote) | `claude --teleport` |
| `--remote` | Se connecter à une session distante | `claude --remote <session-id>` |
| `--fallback-model` | Modèle de secours si le principal est indisponible | `claude --fallback-model haiku` |
| `--plugin-dir` | Répertoire de plugins à charger | `claude --plugin-dir ./plugins` |
| `--tools` | Restreindre les outils disponibles | `claude --tools "Read,Grep,Glob"` |
| `--init` | Initialiser le projet (hook Setup init) | `claude --init` |
| `--init-only` | Initialiser sans démarrer de session | `claude --init-only` |
| `--maintenance` | Lancer la maintenance (hook Setup maintenance) | `claude --maintenance` |
| `--max-budget-usd` | Budget maximum en USD pour la session | `claude --max-budget-usd 5.00` |
| `--fork-session` | Forker une session existante | `claude --fork-session <id>` |
| `--strict-mcp-config` | Mode strict pour la config MCP | `claude --strict-mcp-config` |
