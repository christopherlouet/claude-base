# claude-socle

[![CI](https://github.com/christopherlouet/claude-socle/actions/workflows/ci.yml/badge.svg)](https://github.com/christopherlouet/claude-socle/actions/workflows/ci.yml)
[![CodeQL](https://github.com/christopherlouet/claude-socle/actions/workflows/codeql.yml/badge.svg)](https://github.com/christopherlouet/claude-socle/actions/workflows/codeql.yml)
[![Coverage](https://codecov.io/gh/christopherlouet/claude-socle/branch/main/graph/badge.svg)](https://codecov.io/gh/christopherlouet/claude-socle)
[![ShellCheck](https://img.shields.io/badge/ShellCheck-passing-brightgreen)](https://github.com/christopherlouet/claude-socle/actions)
[![Tests](https://img.shields.io/badge/tests-258%20passing-brightgreen)](./tests)
[![License](https://img.shields.io/badge/License-EULA-orange.svg)](./LICENSE)
[![Release](https://img.shields.io/badge/release-v1.22.1-blue)](https://github.com/christopherlouet/claude-socle/releases/latest)
[![Documentation](https://img.shields.io/badge/docs-Docusaurus-blue)](https://christopherlouet.github.io/claude-socle/)

Template de configuration Claude Code pour un workflow de développement optimal.

## Qu'est-ce que c'est ?

**claude-socle** est un ensemble de fichiers de configuration pour [Claude Code](https://code.claude.com/docs/en/overview) qui permet de :

- Structurer ton workflow de développement : **Explore → Specify → Plan → Code → Commit**
- Disposer de **120 commandes**, **57 sub-agents** et **41 skills** pour différentes tâches
- Avoir des conventions et bonnes pratiques intégrées
- Accélérer ton développement avec des commandes personnalisées
- Intégrer CI/CD et hooks pre-commit prêts à l'emploi
- Support multi-stack : Node.js, Python, Go, Rust, Flutter, Docker, K8s, Terraform, Proxmox

## Installation

### Option 1 : Script d'installation (recommandé)

```bash
# Installer dans un projet existant
./scripts/new-project.sh --simple /chemin/vers/votre-projet

# Ou depuis le projet cible
/chemin/vers/claude-socle/scripts/new-project.sh --simple .

# Installation complète avec CI/CD, hooks, Docker
./scripts/new-project.sh --all /chemin/vers/votre-projet
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
│   ├── skills/                  # 41 skills spécialisés
│   └── commands/                # 120 commandes disponibles
│       ├── assistant.md         # Orchestrateur principal
│       ├── work/                # Workflow (11 commandes)
│       │   ├── work-explore.md
│       │   ├── work-plan.md
│       │   ├── work-commit.md
│       │   ├── work-pr.md
│       │   └── ...
│       ├── dev/                 # Développement (23 commandes)
│       │   ├── dev-tdd.md
│       │   ├── dev-api.md
│       │   └── ...
│       ├── qa/                  # Qualité (15 commandes)
│       │   ├── qa-review.md
│       │   ├── qa-security.md
│       │   └── ...
│       ├── ops/                 # Opérations (30 commandes)
│       ├── doc/                 # Documentation (9 commandes)
│       ├── biz/                 # Business (11 commandes)
│       ├── growth/              # Croissance (11 commandes)
│       ├── data/                # Données (3 commandes)
│       └── legal/               # Légal (5 commandes)
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
│
├── scripts/                     # Scripts utilitaires
│   ├── new-project.sh           # Création projet interactif
│   ├── install.sh               # Installation
│   ├── update.sh                # Mise à jour
│   ├── validate.sh              # Validation
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
│   ├── CLAUDE.vue.md            # Vue.js
│   └── CLAUDE.flutter.md        # Flutter/Dart (Mobile)
│
└── docs/                        # Documentation
    ├── CHEATSHEET.md            # Référence rapide
    ├── CUSTOMIZATION.md         # Guide personnalisation
    ├── GUIDE.md                 # Guide complet
    └── ALIASES.md               # Alias de commandes
```

## Commandes Disponibles (120)

### Workflow Principal

| Commande | Description |
|----------|-------------|
| `/work:work-explore [cible]` | Explorer et comprendre du code |
| `/work:work-specify [feature]` | Creer une specification fonctionnelle |
| `/work:work-plan [feature]` | Planifier une implementation |
| `/work:work-commit [contexte]` | Creer un commit propre |
| `/work:work-pr [contexte]` | Creer une Pull Request |

### Developpement

| Commande | Description |
|----------|-------------|
| `/dev:dev-tdd [feature]` | Test-Driven Development |
| `/dev:dev-test [cible]` | Generer des tests |
| `/dev:dev-debug [probleme]` | Deboguer methodiquement |
| `/dev:dev-refactor [cible]` | Refactoring guide |
| `/dev:dev-api [endpoint]` | Creer/documenter API |
| `/dev:dev-neovim [plugin]` | Plugins et config Neovim/Lua |

### Qualite

| Commande | Description |
|----------|-------------|
| `/qa:qa-review [cible]` | Code review detaillee |
| `/qa:qa-security [cible]` | Audit securite OWASP |
| `/qa:qa-perf [cible]` | Analyse performance |
| `/qa:qa-a11y [cible]` | Audit accessibilite WCAG |
| `/qa:qa-neovim` | Audit config Neovim |

### Maintenance

| Commande | Description |
|----------|-------------|
| `/ops:ops-hotfix [probleme]` | Correction urgente |
| `/ops:ops-release [version]` | Creer une release |
| `/ops:ops-migrate [cible]` | Migration code/deps |
| `/ops:ops-deps [cible]` | Audit et MAJ dependances |
| `/doc:doc-changelog [ctx]` | Generer/maintenir changelog |
| `/ops:ops-docker [cible]` | Dockeriser un projet |
| `/doc:doc-generate [cible]` | Documentation |
| `/doc:doc-fix-issue [#]` | Corriger une issue GitHub |
| `/doc:doc-i18n [cible]` | Internationalisation |

### Decouverte

| Commande | Description |
|----------|-------------|
| `/doc:doc-onboard [cible]` | Decouvrir un codebase |
| `/doc:doc-explain [code]` | Expliquer du code |

### Mobile (Flutter)

| Commande | Description |
|----------|-------------|
| `/dev:dev-flutter [widget]` | Creer widgets/screens Flutter |
| `/dev:dev-supabase [feature]` | Backend Supabase (Auth, DB, Storage) |
| `/qa:qa-mobile [cible]` | Audit qualite app mobile |

## Workflow Recommandé

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ EXPLORE │───▶│ SPECIFY │───▶│  PLAN   │───▶│  CODE   │───▶│ COMMIT  │
└─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘
```

### Exemple pratique (Web)

```bash
# 1. Explorer le systeme existant
/work:work-explore le systeme d'authentification

# 2. Planifier la nouvelle feature
/work:work-plan ajouter OAuth2 Google

# 3. Implementer en TDD
/dev:dev-tdd OAuth2 authentication flow

# 4. Review avant commit
/qa:qa-review les changements

# 5. Creer la PR
/work:work-pr OAuth2 Google authentication
```

### Exemple pratique (Mobile Flutter)

```bash
# 1. Explorer l'architecture existante
/work:work-explore la structure des features

# 2. Planifier le nouveau screen
/work:work-plan ajouter ecran de profil utilisateur

# 3. Creer le widget/screen Flutter
/dev:dev-flutter UserProfileScreen avec BLoC

# 4. Configurer le backend Supabase
/dev:dev-supabase endpoint profil utilisateur

# 5. Audit qualite mobile
/qa:qa-mobile verifier performance et accessibilite

# 6. Creer la PR
/work:work-pr ecran profil utilisateur
```

## Templates Disponibles (10)

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
| `CLAUDE.flutter.md` | Flutter / Dart (Mobile) |
| `CLAUDE.neovim.md` | Neovim / Lua config |

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
- Le workflow Explore → Specify → Plan → Code → Commit
- Les 120 commandes et 57 agents spécialisés
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

### Documentation en ligne

La documentation complète est disponible sur **[https://christopherlouet.github.io/claude-socle/](https://christopherlouet.github.io/claude-socle/)**.

Elle contient :
- Guide de démarrage rapide
- Catalogue des 120 commandes
- Documentation des 57 agents et 41 skills
- Workflows recommandés
- Guides par type de projet

### Documentation locale

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
- [Claude Code Documentation](https://code.claude.com/docs/en/overview)
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
| `smoke.bats` | Tests de smoke (validation rapide de l'intégrité) |
| `common.bats` | Tests des fonctions utilitaires |
| `validate.bats` | Tests du script de validation |
| `gitleaks.bats` | Tests de la configuration gitleaks |
| `new-project.bats` | Tests du script d'installation |
| `doctor.bats` | Tests du script de diagnostic |
| `lint.bats` | Tests du script de linting |

## Migration et Breaking Changes

### Mise à jour vers v1.10.x

#### Breaking Changes

| Changement | Impact | Migration |
|------------|--------|-----------|
| `install.sh` supprimé | Scripts d'installation | Utiliser `new-project.sh --simple` |
| Structure agents YAML | Fichiers agents | Re-copier depuis le socle |

#### Nouvelles fonctionnalités

- **Agent `dev-tdd`** : Développement TDD avec cycle Red-Green-Refactor
- **Commandes** : `/dev:dev-ai-integration`, `/growth:growth-localization`, `/qa:qa-tech-debt`
- **Permissions génériques** : Wildcards pour npm, git, docker, terraform, etc.

#### Guide de migration

```bash
# 1. Sauvegarder vos personnalisations
cp CLAUDE.md CLAUDE.md.backup
cp .claude/settings.local.json .claude/settings.local.json.backup

# 2. Mettre à jour le socle
cd /chemin/vers/claude-socle
git pull origin main

# 3. Réinstaller (écrase les anciens fichiers)
./scripts/new-project.sh --simple /chemin/vers/votre-projet

# 4. Restaurer vos personnalisations
# Fusionner manuellement CLAUDE.md.backup avec le nouveau CLAUDE.md
```

### Politique de versioning

| Version | Support | Notes |
|---------|---------|-------|
| 1.22.x | Actuel | Version stable |
| 1.21.x | Supporte | Corrections de securite |
| 1.20.x | Supporte | Corrections de securite |
| < 1.20 | Non supporte | Mise a jour recommandee |

### Changelog

Voir [CHANGELOG.md](CHANGELOG.md) pour l'historique complet des changements.

## Production Readiness

Le projet claude-socle est **prêt pour la production** avec :

| Critère | Status | Score |
|---------|--------|-------|
| Fonctionnalités | ✅ Mature | 9/10 |
| Tests | ✅ Complet | 8/10 |
| CI/CD | ✅ Mature | 8/10 |
| Sécurité | ✅ Mature | 9/10 |
| Documentation | ✅ Mature | 9/10 |

### Mesures de sécurité

- **Gitleaks** : 24+ règles de détection de secrets
- **Deny list** : Commandes dangereuses bloquées (`rm -rf /`, `sudo`, `git push --force`)
- **Hooks de protection** : Blocage des modifications sur main/master
- **CodeQL** : Analyse de sécurité dans CI

Voir [SECURITY.md](SECURITY.md) pour la politique de sécurité complète.
