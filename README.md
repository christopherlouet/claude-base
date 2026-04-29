# claude-socle

[![CI](https://github.com/christopherlouet/claude-socle/actions/workflows/ci.yml/badge.svg)](https://github.com/christopherlouet/claude-socle/actions/workflows/ci.yml)
[![CodeQL](https://github.com/christopherlouet/claude-socle/actions/workflows/codeql.yml/badge.svg)](https://github.com/christopherlouet/claude-socle/actions/workflows/codeql.yml)
[![Coverage](https://codecov.io/gh/christopherlouet/claude-socle/branch/main/graph/badge.svg)](https://codecov.io/gh/christopherlouet/claude-socle)
[![ShellCheck](https://img.shields.io/badge/ShellCheck-passing-brightgreen)](https://github.com/christopherlouet/claude-socle/actions)
[![Tests](https://img.shields.io/badge/tests-319%20passing-brightgreen)](./tests)
[![License](https://img.shields.io/badge/License-EULA-orange.svg)](./LICENSE)
[![Release](https://img.shields.io/github/v/release/christopherlouet/claude-socle?label=release&color=blue)](https://github.com/christopherlouet/claude-socle/releases/latest)
[![Documentation](https://img.shields.io/badge/docs-Docusaurus-blue)](https://christopherlouet.github.io/claude-socle/)

Template de configuration Claude Code pour un workflow de développement optimal.

## Qu'est-ce que c'est ?

**claude-socle** est un ensemble de fichiers de configuration pour [Claude Code](https://code.claude.com/docs/en/overview) qui permet de :

- Structurer ton workflow de développement : **Explore → (Brainstorm) → Specify → Plan → TDD → Audit → Commit**
- Disposer de **131 commandes**, **63 sub-agents** et **54 skills** pour différentes tâches
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
│   ├── skills/                  # 54 skills spécialisés
│   └── commands/                # 131 commandes disponibles
│       ├── assistant.md         # Orchestrateur principal
│       ├── work/                # Workflow (15 commandes)
│       │   ├── work-explore.md
│       │   ├── work-plan.md
│       │   ├── work-commit.md
│       │   ├── work-pr.md
│       │   └── ...
│       ├── dev/                 # Développement (23 commandes)
│       │   ├── dev-tdd.md
│       │   ├── dev-api.md
│       │   └── ...
│       ├── qa/                  # Qualité (16 commandes)
│       │   ├── qa-review.md
│       │   ├── qa-security.md
│       │   └── ...
│       ├── ops/                 # Opérations (34 commandes)
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
├── tests/                       # 319 tests automatisés (bats)
│   ├── test_helper.bash         # Helpers communs
│   ├── new-project.bats         # Tests installation
│   ├── update.bats              # Tests mise à jour
│   ├── validate.bats            # Tests validation
│   ├── docs-under-claude.bats   # Tests layout v1.30
│   └── ...                      # 12 fichiers de tests au total
│
├── .gitleaks.toml               # Configuration gitleaks (secrets)
├── VERSION                      # Version centralisée du socle (1.30.0)
│
├── scripts/                     # Scripts utilitaires
│   ├── new-project.sh           # Création/installation (modes --simple, --all)
│   ├── update.sh                # Mise à jour
│   ├── validate.sh              # Validation
│   ├── uninstall.sh             # Désinstallation
│   ├── doctor.sh                # Diagnostic
│   ├── diff.sh                  # Comparaison avec socle
│   ├── hooks/                   # Hooks scripts (référencés par settings.json)
│   └── lib/common.sh            # Librairie commune
│
├── templates/                   # 11 templates CLAUDE.*.md par stack
│   ├── CLAUDE.react.md          # React
│   ├── CLAUDE.nextjs.md         # Next.js (App Router)
│   ├── CLAUDE.vue.md            # Vue.js 3
│   ├── CLAUDE.node-api.md       # Node.js API
│   ├── CLAUDE.python.md         # Python
│   ├── CLAUDE.go.md             # Go
│   ├── CLAUDE.rust.md           # Rust
│   ├── CLAUDE.java.md           # Java / Spring Boot
│   ├── CLAUDE.fullstack.md      # Monorepo fullstack
│   ├── CLAUDE.flutter.md        # Flutter / Dart (Mobile)
│   └── CLAUDE.neovim.md         # Neovim / Lua config
│
└── docs/                        # Documentation
    ├── QUICKSTART.md            # Démarrage en 5 minutes
    ├── CHEATSHEET.md            # Référence rapide commandes
    ├── ARCHITECTURE.md          # Commands vs Agents vs Skills vs Rules
    ├── WORKFLOWS.md             # Diagrammes des workflows
    ├── STACK-RECIPES.md         # Commandes/agents/skills par stack
    ├── CUSTOMIZATION.md         # Guide personnalisation
    ├── reference/               # Doc de référence (best-practices, hooks, etc.)
    └── guides/                  # 4 guides spécifiques
        ├── EXTENDING-GUIDE.md   # Étendre le socle
        ├── TEAM-GUIDE.md        # Adoption en équipe
        ├── PROMPTING-GUIDE.md   # Techniques de prompting
        └── TROUBLESHOOTING-GUIDE.md
```

## Commandes Disponibles (131)

Les commandes sont organisées en 9 domaines :

| Domaine | Nombre | Exemples |
|---------|-------:|----------|
| `work-` | 15 | `/work:work-explore`, `/work:work-plan`, `/work:work-commit`, `/work:work-pr`, `/work:work-flow-feature` |
| `dev-` | 23 | `/dev:dev-tdd`, `/dev:dev-debug`, `/dev:dev-api`, `/dev:dev-flutter`, `/dev:dev-prisma` |
| `qa-` | 16 | `/qa:qa-loop`, `/qa:qa-security`, `/qa:qa-perf`, `/qa:wcag-audit`, `/qa:qa-e2e` |
| `ops-` | 34 | `/ops:ops-deploy`, `/ops:ops-docker`, `/ops:ops-monitoring`, `/ops:ops-k8s`, `/ops:ops-rollback` |
| `doc-` | 9 | `/doc:doc-onboard`, `/doc:doc-explain`, `/doc:doc-changelog`, `/doc:doc-architecture` |
| `biz-` | 11 | `/biz:biz-model`, `/biz:biz-mvp`, `/biz:biz-pricing`, `/biz:biz-personas` |
| `growth-` | 11 | `/growth:growth-landing`, `/growth:growth-seo`, `/growth:growth-cro`, `/growth:growth-funnel` |
| `data-` | 3 | `/data:data-pipeline`, `/data:data-modeling`, `/data:data-analytics` |
| `legal-` | 5 | `/legal:legal-rgpd`, `/legal:legal-terms-of-service`, `/legal:legal-privacy-policy` |

→ **Liste complète** : [docs/CHEATSHEET.md](docs/CHEATSHEET.md) ou [Catalogue Docusaurus](https://christopherlouet.github.io/claude-socle/docs/commands).

→ **Par stack** : [docs/STACK-RECIPES.md](docs/STACK-RECIPES.md) liste les commandes pertinentes pour chaque stack (Web, Mobile, API, Auth, etc.).

## Workflow Recommandé

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ EXPLORE │───▶│ SPECIFY │───▶│  PLAN   │───▶│   TDD   │───▶│  AUDIT  │───▶│ COMMIT  │
└─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘
```

### Exemple pratique (Web)

```bash
# 1. Explorer le systeme existant
/work:work-explore le systeme d'authentification

# 2. Specifier la feature (User Stories + criteres)
/work:work-specify ajouter OAuth2 Google

# 3. Planifier l'implementation
/work:work-plan OAuth2 Google

# 4. Implementer en TDD (tests AVANT le code)
/dev:dev-tdd OAuth2 authentication flow

# 5. Audit + fix en boucle (score 90 obligatoire)
/qa:qa-loop "score 90"

# 6. Creer la PR
/work:work-pr OAuth2 Google authentication
```

### Exemple pratique (Mobile Flutter)

```bash
# 1. Explorer l'architecture existante
/work:work-explore la structure des features

# 2. Specifier l'ecran (User Stories + criteres)
/work:work-specify ecran de profil utilisateur

# 3. Planifier l'implementation
/work:work-plan ecran de profil utilisateur

# 4. Creer le widget/screen Flutter en TDD
/dev:dev-tdd UserProfileScreen avec BLoC + tests widget

# 5. Configurer le backend Supabase
/dev:dev-supabase endpoint profil utilisateur

# 6. Audit qualite mobile + fix en boucle
/qa:qa-loop "score 90"

# 7. Creer la PR
/work:work-pr ecran profil utilisateur
```

## Templates Disponibles (11)

| Template | Langage/Framework |
|----------|-------------------|
| `CLAUDE.react.md` | React |
| `CLAUDE.nextjs.md` | Next.js (App Router) |
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
./scripts/new-project.sh --simple /chemin/projet

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

# Intégration IDE (VSCode, IntelliJ, Vim/Neovim)
./scripts/ide.sh setup vscode

# Tutoriel interactif sur le workflow
./scripts/learn.sh
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
- Le workflow Explore → Specify → Plan → TDD → Audit → Commit
- Les 131 commandes et 63 agents spécialisés
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
- Catalogue des 131 commandes, 63 agents, 54 skills, 30 rules
- Workflows recommandés (Explore → Specify → Plan → TDD → Audit → Commit)
- Stack Recipes : commandes pertinentes par stack (Web, Mobile, API, Auth, Database, Infra, Observability, Testing, Data, IA/LLM, Business, Growth)
- Guides spécifiques : Extending, Team, Prompting, Troubleshooting

### Documentation locale

- **[QUICKSTART.md](docs/QUICKSTART.md)** : Démarrage en 5 minutes
- **[CHEATSHEET.md](docs/CHEATSHEET.md)** : Référence rapide des commandes
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** : Commands vs Agents vs Skills vs Rules
- **[WORKFLOWS.md](docs/WORKFLOWS.md)** : Diagrammes des workflows
- **[STACK-RECIPES.md](docs/STACK-RECIPES.md)** : Commandes/agents/skills par stack (Web, Mobile, API…)
- **[CUSTOMIZATION.md](docs/CUSTOMIZATION.md)** : Guide de personnalisation
- **[guides/EXTENDING-GUIDE.md](docs/guides/EXTENDING-GUIDE.md)** : Étendre le socle (commands/skills/rules custom)
- **[guides/TEAM-GUIDE.md](docs/guides/TEAM-GUIDE.md)** : Adoption en équipe

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

### Structure des tests (17 fichiers, 319 tests)

| Fichier | Description |
|---------|-------------|
| `smoke.bats` | Tests de smoke (validation rapide de l'intégrité) |
| `common.bats` | Tests des fonctions utilitaires |
| `new-project.bats` | Tests du script d'installation |
| `update.bats` | Tests du script de mise à jour |
| `docs-under-claude.bats` | Tests du layout v1.30 (docs sous `.claude/docs/`) |
| `validate.bats` | Tests du script de validation |
| `doctor.bats` | Tests du script de diagnostic |
| `gitleaks.bats` | Tests de la configuration gitleaks |
| `qa-loop.bats` | Tests du workflow audit-fix en boucle |
| `lint.bats` | Tests du script de linting |
| `e2e.bats` | Tests end-to-end |
| `prompt-context.bats` | Tests du hook UserPromptSubmit |
| `diff.bats`, `ide.bats`, `learn.bats`, `uninstall.bats`, `test-runner.bats` | Tests des scripts associés |

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
| 1.30.x | Actuel | Version stable (relocalisation docs vers `.claude/docs/`) |
| 1.29.x | Supporté | Corrections de sécurité |
| 1.28.x | Supporté | Corrections de sécurité |
| < 1.28 | Non supporté | Mise à jour recommandée |

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
