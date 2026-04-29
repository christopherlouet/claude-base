# Guide d'Extension du Socle

> Comment personnaliser et etendre le socle claude-socle pour vos propres projets.

> **Audience double** : ce guide couvre deux cas distincts.
>
> - **Vous etendez votre projet utilisateur** (ajouter des commands/rules/skills custom) : vos `@imports` dans `CLAUDE.md` doivent pointer vers `@.claude/docs/...` (puisque la doc du socle est installee sous `.claude/docs/` chez vous).
> - **Vous contribuez au repo claude-socle** : les `@imports` du socle pointent vers `@docs/...` (le socle garde sa doc dans `docs/` directement). Voir aussi [CONTRIBUTING.md](https://github.com/christopherlouet/claude-socle/blob/main/CONTRIBUTING.md).

## Vue d'ensemble

Le socle est concu pour etre etendu. Quatre points d'extension principaux existent :

| Element | Emplacement | Utilite |
|---------|-------------|---------|
| Rules | `.claude/rules/` | Appliquer des conventions selon le type de fichier |
| Skills | `.claude/skills/` | Encapsuler un workflow reutilisable |
| Agents | `.claude/agents/` | Orchestrer un workflow avec un LLM dedie |
| Hooks | `.claude/settings.json` | Automatiser des actions pre/post outils |

---

## 1. Creer une Rule custom

Les rules sont des fichiers Markdown avec un frontmatter YAML qui definissent des contraintes et conventions. Elles s'activent automatiquement quand Claude modifie un fichier correspondant aux paths declares.

### Format du frontmatter

```yaml
---
paths:
  - "**/*.vue"
  - "**/components/**"
---

# Vue Rules

## Conventions
- IMPORTANT: Utiliser la Composition API (pas Options API)
- YOU MUST declarer les props avec defineProps<T>()
```

Le frontmatter est optionnel. Sans `paths`, la rule s'applique globalement a toutes les interactions.

### Emplacement

Creer le fichier dans `.claude/rules/` :

```
.claude/rules/vue.md
.claude/rules/mon-framework.md
```

### Exemple complet : rule pour Svelte

```markdown
---
paths:
  - "**/*.svelte"
  - "**/src/lib/**"
  - "**/src/routes/**"
---

# Svelte Rules

## Structure des composants

| Element | Convention | Exemple |
|---------|-----------|---------|
| Script | `<script lang="ts">` | Toujours TypeScript |
| Stores | Svelte stores natifs | `writable<User \| null>(null)` |
| Props | `export let prop: Type` | Typage explicite obligatoire |

## Conventions

- IMPORTANT: Preferer les stores Svelte a un state manager externe
- YOU MUST typer toutes les props exportees
- NEVER utiliser `any` dans les composants Svelte
- Nommage fichiers: PascalCase pour composants, kebab-case pour routes

## Lifecycle

- Preferer `onMount` a `beforeUpdate` pour les effets de bord
- Cleanup obligatoire dans `onDestroy` pour les subscriptions
```

### Tester le declenchement

Modifier un fichier `.svelte` et verifier dans la session Claude Code que la rule apparait chargee. Les rules s'affichent dans les informations de session au demarrage (`InstructionsLoaded` hook).

Pour forcer le rechargement : relancer une session ou utiliser `/clear`.

---

## 2. Creer un Skill

Un skill est un fichier `SKILL.md` dans un sous-dossier de `.claude/skills/`. Il encapsule un workflow complet avec ses instructions, ses exemples et ses contraintes.

> Depuis CLI 2.1.x, **slash commands et skills sont unifies** : chaque skill obtient automatiquement une interface `/slash-command`. Les fichiers dans `.claude/commands/` continuent de fonctionner pour la compatibilite, mais l'approche recommandee pour tout nouveau workflow est `.claude/skills/`. Le socle conserve `.claude/commands/` uniquement pour les raccourcis namespaces (ex: `/work:work-pr`).

### Structure du dossier

```
.claude/skills/mon-skill/
├── SKILL.md          # Definition obligatoire
├── examples/         # Exemples concrets (optionnel)
└── references/       # Fichiers de reference (optionnel)
```

### Format du SKILL.md

```yaml
---
name: mon-skill
description: Ce que fait le skill. Declencher quand l'utilisateur [contexte].
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
model: sonnet
argument-hint: "[nom-du-projet] [options]"
---

# Titre du Skill

## Objectif
Description en 1-2 phrases.

## Instructions

1. Etape 1
2. Etape 2
3. Etape 3

## Output attendu
Format de sortie.

## Regles
- IMPORTANT: Regle critique
- NEVER: Ce qu'il ne faut jamais faire
```

### Champs frontmatter disponibles

| Champ | Requis | Valeurs | Description |
|-------|--------|---------|-------------|
| `name` | Non | kebab-case | Nom du skill (defaut: nom du dossier) |
| `description` | Recommande | texte | Contexte de declenchement |
| `allowed-tools` | Non | liste | Outils autorises sans confirmation |
| `context` | Non | `fork` | Execution dans un sub-agent isole |
| `model` | Non | `sonnet`, `opus`, `haiku`, `inherit` | Modele a utiliser |
| `argument-hint` | Non | texte | Autocompletion dans le menu `/` |
| `disable-model-invocation` | Non | `true`/`false` | Invocation manuelle uniquement |
| `user-invocable` | Non | `true`/`false` | Visible dans le menu `/` |

### Bonnes pratiques

- Limiter le SKILL.md a 500 lignes maximum. Deporter le detail dans `examples/` ou `references/`
- Declarer uniquement les outils necessaires (principe du moindre privilege)
- Toujours utiliser `context: fork` pour l'isolation
- Ecrire la `description` avec le contexte de declenchement : Claude utilise ce champ pour decider automatiquement quand charger le skill
- Privilegier les tableaux a la prose pour les references rapides

### Outils par type de skill

| Type de skill | Outils recommandes |
|---------------|-------------------|
| Lecture seule (audit, review) | `Read`, `Glob`, `Grep` |
| Developpement | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| Documentation | `Read`, `Write`, `Edit`, `Glob`, `Grep` |
| Analyse | `Read`, `Glob`, `Grep` |
| Infrastructure | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |

### Exemple complet : skill de generation de changelog

```yaml
---
name: changelog-entry
description: Genere une entree CHANGELOG.md a partir des commits recents. Declencher quand l'utilisateur veut documenter une release ou mettre a jour le changelog.
allowed-tools:
  - Read
  - Edit
  - Bash
  - Glob
context: fork
model: sonnet
argument-hint: "[version] [depuis-tag]"
---

# Generer une Entree Changelog

## Objectif

Analyser les commits Git depuis le dernier tag et generer une entree
CHANGELOG.md formatee selon Keep a Changelog.

## Instructions

1. Lire le CHANGELOG.md existant pour comprendre le format utilise
2. Recuperer les commits : `git log <depuis-tag>..HEAD --oneline`
3. Grouper les commits par type (feat, fix, refactor, docs, etc.)
4. Generer l'entree au format Keep a Changelog
5. Inserer au debut du CHANGELOG.md, apres le titre

## Format de sortie

\`\`\`markdown
## [1.2.0] - 2026-04-03

### Nouvelles fonctionnalites
- Description claire de la feature (ref: commit abc123)

### Corrections
- Description du bug corrige (ref: commit def456)
\`\`\`

## Regles

- NEVER modifier les entrees existantes du changelog
- IMPORTANT: Utiliser le format de date ISO (YYYY-MM-DD)
- Exclure les commits de style et de chore sauf si significatifs
```

---

## 3. Creer un Agent

Un agent est un fichier `.md` dans `.claude/agents/`. Il combine un frontmatter YAML (configuration du sub-agent) avec des instructions Markdown (comportement).

### Format d'un agent

```yaml
---
name: mon-agent
description: Description courte. Declencher quand [contexte d'utilisation].
tools: Read, Grep, Glob, Edit, Write, Bash
model: sonnet
permissionMode: default
skills:
  - mon-skill
---

# Agent MON-AGENT

Corps des instructions de l'agent.
```

### Champs frontmatter d'un agent

| Champ | Description |
|-------|-------------|
| `name` | Identifiant de l'agent (kebab-case) |
| `description` | Contexte d'activation automatique |
| `tools` | Outils autorises (virgule-separes) |
| `model` | `sonnet`, `opus`, `haiku` |
| `permissionMode` | `default`, `acceptEdits`, `bypassPermissions` |
| `skills` | Liste de skills a charger |
| `hooks` | Hooks scopes au lifecycle de l'agent |

### Quand utiliser agent vs skill vs command

| Besoin | Solution | Raison |
|--------|----------|--------|
| Workflow reutilisable avec instructions | Skill | Invocable par `/nom`, partage entre agents |
| Execution isolee avec LLM dedie | Agent | Sub-agent avec son propre contexte |
| Sequence de commandes bash | Command `.md` | Prompt sans LLM supplementaire |
| Automatisation sans interaction | Hook | Execute un script au bon moment |

### Exemple complet : agent d'audit de dependances

```yaml
---
name: deps-audit
description: Audit des dependances obsoletes ou vulnerables. Declencher quand l'utilisateur veut verifier ou mettre a jour les dependances du projet.
tools: Read, Bash, Glob, Edit
model: sonnet
permissionMode: default
---

# Agent DEPS-AUDIT

Analyse les dependances du projet et produit un rapport classe par criticite.

## Workflow

1. Detecter le gestionnaire de paquets (npm, pnpm, yarn, pip, go mod)
2. Lancer l'audit de vulnerabilites (`npm audit`, `pip-audit`, etc.)
3. Identifier les dependances outdated
4. Classer par criticite : CRITIQUE > HAUTE > MOYENNE > FAIBLE
5. Proposer un plan de mise a jour

## Output

Rapport structure avec :
- Tableau des vulnerabilites par niveau
- Commandes de mise a jour a executer
- Dependances a surveiller (breaking changes potentiels)

## Regles

- NEVER mettre a jour automatiquement les dependances majeures sans confirmation
- IMPORTANT: Verifier les breaking changes avant de proposer une mise a jour majeure
```

### Nommage des agents

Respecter la convention `domaine-action` existante :

| Domaine | Prefixe | Exemples |
|---------|---------|----------|
| Developpement | `dev-` | `dev-api`, `dev-tdd`, `dev-debug` |
| Qualite | `qa-` | `qa-review`, `qa-security` |
| Operations | `ops-` | `ops-deploy`, `ops-docker` |
| Documentation | `doc-` | `doc-generate`, `doc-changelog` |
| Business | `biz-` | `biz-model`, `biz-mvp` |
| Workflow | `work-` | `work-explore`, `work-plan` |

---

## 4. Creer un Hook

Les hooks permettent d'automatiser des actions a des moments precis du cycle de vie d'une session Claude Code. Ils se configurent dans `.claude/settings.json` (hooks globaux) ou dans le frontmatter d'un agent/skill (hooks scopes).

### Types de hooks

| Type | Description | Cas d'usage |
|------|-------------|-------------|
| `command` | Execute un script bash | Validation, formatage, logging |
| `prompt` | Evalue via un LLM Haiku | Verification contextuelle intelligente |
| `http` | POST JSON vers une URL | Webhook externe, CI/CD |

### Evenements disponibles

| Evenement | Declenchement | Usage typique |
|-----------|--------------|---------------|
| `SessionStart` | Demarrage de session | Afficher infos projet, verifier prereqs |
| `PreToolUse` | Avant execution d'un outil | Valider, bloquer, transformer |
| `PostToolUse` | Apres execution reussie | Formatter, linter, notifier |
| `Stop` | Fin de reponse Claude | Validation finale, logging |
| `PreCompact` | Avant compaction contexte | Sauvegarder l'etat |
| `SessionEnd` | Fin de session | Cleanup, rapport |

### Proprietes des hooks

| Propriete | Description |
|-----------|-------------|
| `type` | `command`, `prompt`, ou `http` |
| `command` | Script bash a executer (type `command`) |
| `matcher` | Filtre sur le nom de l'outil (regex) |
| `timeout` | Timeout en millisecondes |
| `onFailure` | `"block"` ou `"ignore"` |
| `async` | `true` pour execution en arriere-plan |

### Quand utiliser async

| Situation | async | Raison |
|-----------|-------|--------|
| Logging, monitoring | `true` | Ne bloque pas le workflow |
| Validation bloquante | `false` | Doit s'executer avant de continuer |
| Formatage auto | `false` | Doit finir avant le prochain outil |
| Webhook externe | `true` | Latence reseau non bloquante |

### Exemple : hook PostToolUse pour formatter du SQL

Dans `.claude/settings.json`, section `hooks` :

```json
{
  "PostToolUse": [
    {
      "description": "Formatter les fichiers SQL avec sqlfluff",
      "matcher": "Edit|Write",
      "hooks": [
        {
          "type": "command",
          "command": "bash -c 'if command -v sqlfluff >/dev/null 2>&1; then FILE=$(echo \"$TOOL_INPUT\" | jq -r \".path // empty\"); if [[ \"$FILE\" == *.sql ]]; then sqlfluff fix --dialect ansi \"$FILE\" 2>/dev/null && echo \"[SQL] Formatte: $FILE\"; fi; fi'",
          "timeout": 10000,
          "onFailure": "ignore"
        }
      ]
    }
  ]
}
```

### Exemple : hook PreToolUse de validation metier

```json
{
  "PreToolUse": [
    {
      "description": "Empecher la modification de fichiers de configuration en production",
      "matcher": "Edit|Write",
      "hooks": [
        {
          "type": "command",
          "command": "bash -c 'FILE=$(echo \"$TOOL_INPUT\" | jq -r \".path // empty\"); if [[ \"$FILE\" == *prod* ]] || [[ \"$FILE\" == *production* ]]; then echo \"BLOQUE: Modification d un fichier de production detectee. Utilisez ALLOW_PROD_EDIT=1 pour forcer.\"; if [ \"$ALLOW_PROD_EDIT\" != \"1\" ]; then exit 1; fi; fi'",
          "timeout": 5000,
          "onFailure": "block"
        }
      ]
    }
  ]
}
```

### Hooks dans settings.local.json

Pour des hooks specifiques a votre poste (non commites) :

```json
// .claude/settings.local.json
{
  "hooks": {
    "PostToolUse": [
      {
        "description": "Notification desktop apres chaque modification",
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'notify-send \"Claude Code\" \"Fichier modifie\" 2>/dev/null || true'",
            "timeout": 3000,
            "async": true,
            "onFailure": "ignore"
          }
        ]
      }
    ]
  }
}
```

---

## 5. Personnaliser CLAUDE.md

`CLAUDE.md` est le fichier de configuration principal du projet. Il est charge a chaque session.

### Pattern @import

```markdown
@chemin/vers/fichier.md
```

Les fichiers importes sont injectes directement dans le contexte. Utiliser pour des references volumineuses qui ne sont pas necessaires a chaque session.

Fichiers toujours charges (imports dans ce projet) :
- `@docs/reference/best-practices.md`
- `@docs/reference/project-structures.md`

### Ce qui appartient ou

| Element | Emplacement | Raison |
|---------|-------------|--------|
| Workflow obligatoire | `CLAUDE.md` | S'applique a toute l'equipe |
| Conventions de code | `CLAUDE.md` ou rules | Selon si contextuelles ou globales |
| Preferences personnelles | `~/.claude/memory/` | Non commite, personnel |
| Conventions par langage | `.claude/rules/<lang>.md` | Active seulement sur les bons fichiers |
| Decisions d'architecture | `~/.claude/memory/` | Memorisees par session |
| References longues | Fichier separe avec `@import` | Evite de surcharger le contexte |

### Contenu recommande pour CLAUDE.md

```markdown
# Mon Projet

> Courte description du projet

## Workflow

[Adapter le workflow obligatoire au contexte du projet]

## Conventions

[Conventions specifiques au projet, non couvertes par les rules]

## References

| Sujet | Fichier |
|-------|---------|
| Architecture | `docs/ARCHITECTURE.md` |
| API | `docs/api/README.md` |
```

### Ce qu'il ne faut pas mettre dans CLAUDE.md

- Secrets, credentials, tokens (utiliser `.env`)
- Informations qui changent souvent (versions de dependances, etc.)
- Contenu duplique depuis les rules (inutile, augmente le contexte)
- Historique des decisions (utiliser CHANGELOG.md ou git log)

---

## 6. Contribuer au socle

### Fork et workflow PR

```bash
# 1. Forker le depot sur GitHub
# 2. Cloner votre fork
git clone https://github.com/<vous>/claude-socle.git
cd claude-socle

# 3. Creer une branche feature
git checkout -b feature/mon-skill-python-typing

# 4. Creer ou modifier les fichiers
# 5. Tester manuellement dans une session Claude Code
# 6. Verifier la coherence des compteurs
./scripts/validate-counts.sh

# 7. Commiter en Conventional Commits
git commit -m "feat(skills): add python-typing skill for strict type annotations"

# 8. Pousser et creer la PR
git push origin feature/mon-skill-python-typing
gh pr create --title "feat(skills): add python-typing skill" --body "..."
```

### Conventions de nommage

| Type | Convention | Exemple |
|------|-----------|---------|
| Skills | `domaine-action` | `dev-typing`, `qa-mutation` |
| Agents | `domaine-action` | `dev-typing`, `qa-mutation` |
| Rules | nom du langage/framework | `svelte.md`, `fastapi.md` |
| Commands | `domaine/action.md` | `dev/dev-typing.md` |
| Branches | `feature/xxx`, `fix/xxx` | `feature/svelte-rule` |
| Commits | Conventional Commits | `feat(rules): add svelte rule` |

### Checklist avant PR

```
[ ] Le skill/agent a un nom en kebab-case suivant la convention domaine-action
[ ] Le frontmatter YAML est valide (name, description, allowed-tools)
[ ] La description contient le contexte de declenchement
[ ] Les outils declares sont le minimum necessaire
[ ] context: fork est present pour les skills
[ ] Le fichier fait moins de 500 lignes
[ ] Les exemples de code sont pertinents et fonctionnels
[ ] validate-counts.sh passe sans erreur
[ ] La documentation de reference est mise a jour si necessaire
```

### Compliance validate-counts.sh

Quand vous ajoutez un skill, un agent, une rule ou une command, plusieurs fichiers de documentation doivent etre mis a jour pour reflechir les nouveaux compteurs :

| Fichier | Compteur a mettre a jour |
|---------|--------------------------|
| `README.md` | Nombre de commandes |
| `CLAUDE.md` | Nombre de commandes, agents, skills |
| `docs/reference/agents-catalog.md` | En-tete du fichier |
| `website/src/pages/index.tsx` | Statistiques de la page d'accueil |
| `website/docs/intro/architecture.md` | Compteurs architecture |

Lancer `./scripts/validate-counts.sh --fix` pour identifier les incoherences. Corriger manuellement les valeurs numeriques dans les fichiers signales.

### Structure d'une PR de qualite

```markdown
## Description
Ajout d'un skill `svelte` pour les conventions de developpement Svelte 5.

## Motivation
Le socle ne couvrait pas Svelte. Ce skill active les conventions Composition API,
typage des props, et gestion des stores automatiquement sur les fichiers `.svelte`.

## Changements
- `.claude/skills/dev-svelte/SKILL.md` : nouveau skill
- `.claude/rules/svelte.md` : rule associee
- `docs/reference/skills-catalog.md` : entree ajoutee
- Compteurs mis a jour dans README.md, CLAUDE.md, website

## Tests
- Teste manuellement en modifiant un fichier .svelte dans une session Claude Code
- validate-counts.sh passe

## Checklist
- [x] Conventions de nommage respectees
- [x] validate-counts.sh OK
- [x] Documentation mise a jour
```

---

## Recapitulatif des emplacements

```
.claude/
├── rules/              # Rules par langage/framework
│   ├── python.md       # Activee sur **/*.py
│   └── mon-framework.md
├── skills/             # Skills reutilisables
│   └── mon-skill/
│       ├── SKILL.md    # Definition obligatoire
│       └── examples/
├── agents/             # Sub-agents avec LLM dedie
│   └── mon-agent.md
├── commands/           # Commandes invocables par /domaine:nom
│   └── domaine/
│       └── ma-commande.md
└── settings.json       # Hooks globaux du projet
    settings.local.json # Hooks locaux non commites
```
