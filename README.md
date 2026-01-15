# claude-socle

[![CI](https://github.com/anthropics/claude-socle/actions/workflows/ci.yml/badge.svg)](https://github.com/anthropics/claude-socle/actions/workflows/ci.yml)
[![ShellCheck](https://img.shields.io/badge/ShellCheck-passing-brightgreen)](https://github.com/anthropics/claude-socle/actions)
[![Bats](https://img.shields.io/badge/Bats-2089%20lines-blue)](./tests)
[![License](https://img.shields.io/badge/License-EULA-orange.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/version-1.2.0-blue)](./VERSION)

Template de configuration Claude Code pour un workflow de développement optimal.

## Qu'est-ce que c'est ?

**claude-socle** est un ensemble de fichiers de configuration pour [Claude Code](https://docs.anthropic.com/en/docs/claude-code) qui permet de :

- Structurer ton workflow de développement : **Explore → Plan → Code → Commit**
- Disposer de **79 agents spécialisés** pour différentes tâches
- Avoir des conventions et bonnes pratiques intégrées
- Accélérer ton développement avec des commandes personnalisées
- Intégrer CI/CD et hooks pre-commit prêts à l'emploi

## Installation

### Option 1 : Script d'installation (recommandé)

```bash
# Installer dans un projet existant
./scripts/install.sh /chemin/vers/votre-projet

# Ou depuis le projet cible
/chemin/vers/claude-socle/scripts/install.sh .
```

### Option 2 : Copie manuelle

```bash
# Copier la configuration Claude
cp -r claude-socle/.claude votre-projet/
cp claude-socle/CLAUDE.md votre-projet/

# Optionnel
cp claude-socle/.mcp.json votre-projet/
cp claude-socle/.github votre-projet/ -r
```

### Option 3 : Utiliser comme template

```bash
cp -r claude-socle mon-nouveau-projet
cd mon-nouveau-projet
# Personnaliser CLAUDE.md selon ton projet
```

## Structure

```
claude-socle/
├── CLAUDE.md                    # Instructions principales
├── CLAUDE.local.md.example      # Template config locale
├── README.md                    # Ce fichier
├── .gitignore
│
├── .claude/
│   ├── settings.json            # Permissions et hooks
│   ├── skills/                  # 9 skills spécialisés
│   └── commands/                # 79 agents disponibles
│       ├── explore.md           # Exploration de code
│       ├── plan.md              # Planification
│       ├── commit.md            # Commits
│       ├── pr.md                # Pull Requests
│       ├── review.md            # Code review
│       ├── tdd.md               # Test-Driven Development
│       ├── test.md              # Génération de tests
│       ├── debug.md             # Débogage
│       ├── refactor.md          # Refactoring
│       ├── security.md          # Audit sécurité
│       ├── perf.md              # Performance
│       ├── migrate.md           # Migrations
│       ├── doc.md               # Documentation
│       ├── fix-issue.md         # Correction d'issues
│       ├── hotfix.md            # Corrections urgentes
│       ├── release.md           # Releases
│       ├── onboard.md           # Onboarding
│       ├── explain.md           # Explications de code
│       ├── api.md               # Création d'API
│       ├── a11y.md              # Accessibilité
│       ├── i18n.md              # Internationalisation
│       ├── changelog.md         # Génération changelog
│       ├── deps.md              # Audit dépendances
│       └── docker.md            # Dockerisation
│
├── .mcp.json                    # Configuration MCP
│
├── .github/workflows/           # CI/CD GitHub Actions
│   ├── ci.yml                   # Tests, lint, build
│   ├── pr-check.yml             # Validation de PR
│   └── release.yml              # Releases automatiques
│
├── .husky/                      # Git hooks
│   ├── pre-commit
│   └── commit-msg
├── .pre-commit-config.yaml      # Config pre-commit
├── .lintstagedrc.json           # Config lint-staged
├── .commitlintrc.json           # Config commitlint
│
├── scripts/                     # Scripts utilitaires
│
├── tests/                       # Tests automatisés (bats)
│   ├── test_helper.bash         # Fonctions helper pour tests
│   ├── common.bats              # Tests lib/common.sh
│   ├── validate.bats            # Tests validate.sh
│   └── gitleaks.bats            # Tests configuration gitleaks
│
├── .gitleaks.toml               # Configuration gitleaks (secrets)
├── VERSION                      # Version centralisée du socle
│   ├── install.sh               # Installation
│   ├── update.sh                # Mise à jour
│   ├── validate.sh              # Validation
│   ├── new-project.sh           # Création projet interactif
│   ├── uninstall.sh             # Désinstallation
│   ├── doctor.sh                # Diagnostic
│   ├── diff.sh                  # Comparaison avec socle
│   └── lib/common.sh            # Librairie commune
│
├── templates/                   # Templates par langage
│   ├── CLAUDE.react.md          # React/Next.js
│   ├── CLAUDE.node-api.md       # Node.js API
│   ├── CLAUDE.python.md         # Python
│   ├── CLAUDE.fullstack.md      # Monorepo fullstack
│   ├── CLAUDE.go.md             # Go
│   ├── CLAUDE.rust.md           # Rust
│   ├── CLAUDE.java.md           # Java/Spring
│   └── CLAUDE.vue.md            # Vue.js
│
└── docs/                        # Documentation
    ├── CHEATSHEET.md            # Référence rapide
    ├── CUSTOMIZATION.md         # Guide personnalisation
    ├── GUIDE.md                 # Guide complet
    └── ALIASES.md               # Alias de commandes
```

## Agents Disponibles (79)

### Workflow Principal

| Commande | Description |
|----------|-------------|
| `/project:explore [cible]` | Explorer et comprendre du code |
| `/project:plan [feature]` | Planifier une implémentation |
| `/project:commit [contexte]` | Créer un commit propre |
| `/project:pr [contexte]` | Créer une Pull Request |

### Développement

| Commande | Description |
|----------|-------------|
| `/project:tdd [feature]` | Test-Driven Development |
| `/project:test [cible]` | Générer des tests |
| `/project:debug [problème]` | Déboguer méthodiquement |
| `/project:refactor [cible]` | Refactoring guidé |
| `/project:api [endpoint]` | Créer/documenter API |

### Qualité

| Commande | Description |
|----------|-------------|
| `/project:review [cible]` | Code review détaillée |
| `/project:security [cible]` | Audit sécurité OWASP |
| `/project:perf [cible]` | Analyse performance |
| `/project:a11y [cible]` | Audit accessibilité WCAG |

### Maintenance

| Commande | Description |
|----------|-------------|
| `/project:hotfix [problème]` | Correction urgente |
| `/project:release [version]` | Créer une release |
| `/project:migrate [cible]` | Migration code/deps |
| `/project:deps [cible]` | Audit et MAJ dépendances |
| `/project:changelog [ctx]` | Générer/maintenir changelog |
| `/project:docker [cible]` | Dockeriser un projet |
| `/project:doc [cible]` | Documentation |
| `/project:fix-issue [#]` | Corriger une issue GitHub |
| `/project:i18n [cible]` | Internationalisation |

### Découverte

| Commande | Description |
|----------|-------------|
| `/project:onboard [cible]` | Découvrir un codebase |
| `/project:explain [code]` | Expliquer du code |

## Workflow Recommandé

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ EXPLORE │───▶│  PLAN   │───▶│  CODE   │───▶│ COMMIT  │
└─────────┘    └─────────┘    └─────────┘    └─────────┘
```

### Exemple pratique

```bash
# 1. Explorer le système existant
/project:explore le système d'authentification

# 2. Planifier la nouvelle feature
/project:plan ajouter OAuth2 Google

# 3. Implémenter en TDD
/project:tdd OAuth2 authentication flow

# 4. Review avant commit
/project:review les changements

# 5. Créer la PR
/project:pr OAuth2 Google authentication
```

## Templates Disponibles (8)

| Template | Langage/Framework |
|----------|-------------------|
| `CLAUDE.react.md` | React / Next.js |
| `CLAUDE.vue.md` | Vue.js 3 |
| `CLAUDE.node-api.md` | Node.js API |
| `CLAUDE.python.md` | Python |
| `CLAUDE.go.md` | Go |
| `CLAUDE.rust.md` | Rust |
| `CLAUDE.java.md` | Java / Spring Boot |
| `CLAUDE.fullstack.md` | Monorepo fullstack |

```bash
# Utiliser un template
cp templates/CLAUDE.react.md CLAUDE.md
```

## Scripts Utilitaires

```bash
# Créer un nouveau projet (interactif)
./scripts/new-project.sh

# Installer dans un projet existant
./scripts/install.sh /chemin/projet

# Mettre à jour les commandes
./scripts/update.sh /chemin/projet

# Valider la configuration
./scripts/validate.sh /chemin/projet
./scripts/validate.sh --json /chemin/projet  # Pour CI/CD

# Diagnostic complet
./scripts/doctor.sh /chemin/projet

# Comparer avec le socle
./scripts/diff.sh /chemin/projet

# Désinstaller
./scripts/uninstall.sh /chemin/projet
```

## Apprentissage Interactif

Le socle inclut un tutoriel interactif pour apprendre à l'utiliser efficacement.

```bash
# Tutoriel complet (15-20 min)
./scripts/learn.sh

# Version rapide (5 min)
./scripts/learn.sh --quick

# Apprendre un agent spécifique
./scripts/learn.sh --agent tdd
./scripts/learn.sh --agent commit

# Voir les agents disponibles
./scripts/learn.sh --list
```

Le tutoriel couvre :
- Le workflow Explore → Plan → Code → Commit
- Les 79 agents spécialisés
- Le développement TDD
- Les Conventional Commits
- Quiz interactifs avec score

## Intégration IDE

Configurez votre IDE pour une intégration optimale avec claude-socle.

```bash
# Configurer VSCode/Cursor
./scripts/ide.sh setup vscode

# Configurer IntelliJ IDEA
./scripts/ide.sh setup idea

# Configurer Vim/Neovim
./scripts/ide.sh setup vim

# Configurer tous les IDE
./scripts/ide.sh setup all

# Vérifier la configuration
./scripts/ide.sh check vscode

# Supprimer la configuration
./scripts/ide.sh remove vscode
```

### Fonctionnalités IDE

| IDE | Fonctionnalités |
|-----|-----------------|
| **VSCode/Cursor** | Settings, Tasks, Extensions, Snippets |
| **IntelliJ IDEA** | Run Configurations, Code Style, Templates |
| **Vim/Neovim** | Abréviations, Mappings, Autocmds |

## CI/CD Inclus

### GitHub Actions

- **ci.yml** : Tests, lint, build, audit sécurité
- **pr-check.yml** : Validation format PR, taille, labels
- **release.yml** : Releases automatiques avec changelog

### Pre-commit Hooks

- Lint et format automatique
- Validation des commits (conventional commits)
- Détection de secrets

```bash
# Activer husky
npm install husky lint-staged @commitlint/cli @commitlint/config-conventional -D
npx husky install
```

## Documentation

- **[CHEATSHEET.md](docs/CHEATSHEET.md)** : Référence rapide des commandes
- **[CUSTOMIZATION.md](docs/CUSTOMIZATION.md)** : Guide de personnalisation

## Permissions par Défaut

| Autorisé | Bloqué |
|----------|--------|
| ✅ Édition de fichiers | ❌ `git push --force` |
| ✅ npm test/lint/build | ❌ `rm -rf` |
| ✅ git status/diff/add/commit | |
| ✅ gh issue/pr | |

## Ressources

- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [How Anthropic Teams Use Claude Code](https://www.anthropic.com/news/how-anthropic-teams-use-claude-code)

## Détection de Secrets (gitleaks)

Le socle utilise [gitleaks](https://github.com/gitleaks/gitleaks) pour détecter automatiquement les secrets dans le code.

### Installation de gitleaks

```bash
# macOS
brew install gitleaks

# Linux (via go)
go install github.com/gitleaks/gitleaks/v8@latest

# Docker
docker pull ghcr.io/gitleaks/gitleaks:latest
```

### Utilisation

```bash
# Scanner le projet
gitleaks detect --source . --config .gitleaks.toml

# Scanner avant commit (automatique via hooks)
gitleaks detect --staged --config .gitleaks.toml
```

### Secrets détectés

- AWS Access Keys
- GitHub/GitLab tokens
- Stripe API keys
- Slack tokens/webhooks
- JWT tokens
- Clés privées (RSA, EC, etc.)
- URLs de base de données
- Et bien d'autres...

## Tests Automatisés

Le socle inclut des tests [bats-core](https://github.com/bats-core/bats-core) pour valider son bon fonctionnement.

### Installation de bats

```bash
# Via npm
npm install -g bats

# Via brew (macOS)
brew install bats-core

# Via le script
./scripts/test.sh --install-bats
```

### Lancer les tests

```bash
# Tous les tests
./scripts/test.sh

# Tests spécifiques
./scripts/test.sh validate
./scripts/test.sh gitleaks

# Mode verbeux
./scripts/test.sh -v
```

### Structure des tests

| Fichier | Description |
|---------|-------------|
| `common.bats` | Tests des fonctions utilitaires |
| `validate.bats` | Tests du script de validation |
| `gitleaks.bats` | Tests de la configuration gitleaks |
