# Contribuer a claude-socle

Merci de contribuer au projet. Ce guide explique comment participer efficacement.

## Pre-requis

- Node.js >= 20
- npm >= 10
- Git
- [Bats](https://github.com/bats-core/bats-core) (pour les tests)
- [ShellCheck](https://www.shellcheck.net/) (pour le linting des scripts)

## Installation de l'environnement

```bash
# Cloner le repo
git clone https://github.com/christopherlouet/claude-socle.git
cd claude-socle

# Installer les dependances du site de documentation
cd website && npm install && cd ..

# Verifier que tout fonctionne
./scripts/doctor.sh
```

## Structure du projet

```
.claude/
  commands/    # 118 commandes (source de verite)
  agents/      # 56 sub-agents
  skills/      # 40 skills
  rules/       # 20 regles contextuelles
  templates/   # Templates de specification
  settings.json # Hooks et permissions
website/       # Site Docusaurus (docs generees)
scripts/       # Scripts utilitaires et CI
tests/         # Tests Bats
```

Les fichiers dans `.claude/` sont la **source de verite**. Les docs dans `website/docs/` sont **generees** a partir de ces fichiers.

## Workflow de contribution

### 1. Creer une branche

```bash
git checkout -b feature/ma-feature
# ou
git checkout -b fix/mon-fix
```

Les branches suivent la convention : `feature/xxx`, `fix/xxx`, `refactor/xxx`.

### 2. Faire les modifications

- **Nouvelle commande** : creer dans `.claude/commands/[categorie]/`
- **Nouvel agent** : creer dans `.claude/agents/`
- **Nouveau skill** : creer dans `.claude/skills/[nom]/SKILL.md`
- **Nouvelle regle** : creer dans `.claude/rules/`

### 3. Regenerer la documentation

```bash
cd website
npm run generate
```

### 4. Lancer les tests

```bash
# Tests complets
./scripts/test.sh

# Validation des compteurs
./scripts/validate-counts.sh

# Linting des scripts
./scripts/lint.sh
```

### 5. Commiter

Les commits suivent [Conventional Commits](https://www.conventionalcommits.org/) :

```
feat(commands): add dev-xxx command
fix(agents): correct qa-security model
docs(rules): update typescript rule
chore(deps): bump docusaurus to 3.8
test(scripts): add validate-counts tests
```

Types autorises : `feat`, `fix`, `refactor`, `test`, `docs`, `style`, `chore`, `perf`.

### 6. Creer une Pull Request

```bash
# Pousser la branche
git push -u origin feature/ma-feature
```

La PR doit inclure :
- Un titre court (< 70 caracteres)
- Une description avec le contexte et les changements
- Les tests passent (CI verte)

## Conventions

### Nommage des fichiers

| Type | Convention | Exemple |
|------|------------|---------|
| Commands | `kebab-case.md` | `dev-tdd.md` |
| Agents | `kebab-case.md` | `qa-security.md` |
| Skills | `kebab-case/SKILL.md` | `dev-tdd/SKILL.md` |
| Rules | `kebab-case.md` | `typescript.md` |

### Frontmatter des agents

```yaml
---
name: nom-agent
description: Description en francais
tools: Read, Grep, Glob
model: haiku  # ou sonnet pour les taches complexes
permissionMode: plan
disallowedTools: Edit, Write, NotebookEdit
skills:
  - skill-associe
---
```

### Frontmatter des skills

```yaml
---
allowed-tools:
  - Read
  - Grep
  - Glob
  - Edit
  - Write
  - Bash
context: fork
---
```

### Choix du modele pour les agents

- **haiku** : exploration, audit lecture seule, documentation
- **sonnet** : debug, ecriture de code, analyses complexes

## Verification avant soumission

- [ ] Les tests passent (`./scripts/test.sh`)
- [ ] Les compteurs sont corrects (`./scripts/validate-counts.sh`)
- [ ] La doc est regeneree (`cd website && npm run generate`)
- [ ] Le commit suit Conventional Commits
- [ ] Pas de secrets dans le code (gitleaks)
- [ ] ShellCheck passe pour les scripts bash (`./scripts/lint.sh`)

## Hooks automatiques

Le projet utilise des hooks Claude Code qui s'executent automatiquement :

- **Protection main** : impossible d'editer directement sur main/master
- **Gitleaks** : detection de secrets avant ecriture
- **Tests pre-commit** : les tests sont lances avant chaque commit
- **Auto-format** : formatage automatique apres modification (TS, Python, Go, Rust, Dart, Lua)
