---
sidebar_position: 22
title: "Guide de Personnalisation"
description: "Comment adapter claude-socle à vos besoins spécifiques."
tags:
  - "concept"
---

<!-- Auto-generated from docs/ - DO NOT EDIT -->

# Guide de Personnalisation

Comment adapter claude-socle à vos besoins spécifiques.

---

## 1. Personnaliser CLAUDE.md

### Structure recommandée

```markdown
# Projet [Nom]

## Commandes Essentielles
[Commandes npm/yarn/make spécifiques à votre projet]

## Structure du Projet
[Arborescence avec description de chaque dossier]

## Conventions de Code
[Règles spécifiques à votre équipe]

## Git & Commits
[Format de commit, branches, workflow]

## Points d'attention
[Pièges courants, dette technique, zones sensibles]
```

### Mots-clés d'emphase

Claude accorde plus d'attention à certains mots-clés :

| Mot-clé | Usage |
|---------|-------|
| `IMPORTANT:` | Règle critique à respecter |
| `YOU MUST` | Obligation absolue |
| `NEVER` | Interdiction |
| `ALWAYS` | Toujours faire ainsi |
| `WARNING:` | Point d'attention |

**Exemple:**
```markdown
## Sécurité
- IMPORTANT: Toujours valider les entrées utilisateur
- YOU MUST utiliser des requêtes paramétrées
- NEVER logger de mots de passe ou tokens
```

### Contexte métier

Ajoutez du contexte métier pour que Claude comprenne mieux :

```markdown
## Contexte métier
Ce projet est une application e-commerce B2B.
- Les "clients" sont des entreprises, pas des particuliers
- Un "panier" peut contenir des milliers d'articles
- Les "commandes" passent par un workflow de validation
```

---

## 2. Créer des commandes personnalisées

### Emplacement

- **Projet**: `.claude/commands/` (partagé via git)
- **Personnel**: `~/.claude/commands/` (global)

&gt; **Note**: Les commandes du socle sont organisées en sous-répertoires par catégorie
&gt; (work/, dev/, qa/, ops/, doc/, biz/, growth/, data/, legal/).
&gt; Vos commandes personnalisées peuvent être à la racine de `.claude/commands/`
&gt; ou dans un sous-répertoire de votre choix.

### Structure d'une commande

```markdown
# Nom de la commande

Description courte de ce que fait la commande.

## Contexte
$ARGUMENTS

## Instructions
1. Étape 1
2. Étape 2
...

## Output attendu
[Format de sortie]

---

[Instructions supplémentaires avec IMPORTANT/YOU MUST]
```

### Exemple: Commande de déploiement

`.claude/commands/deploy.md`:
```markdown
# Agent DEPLOY

Déploie l'application sur l'environnement spécifié.

## Environnement
$ARGUMENTS

## Prérequis
- [ ] Tests passent
- [ ] Build OK
- [ ] Changelog à jour

## Workflow

### Staging
```bash
npm run build
npm run deploy:staging
```

### Production
IMPORTANT: Nécessite approbation manuelle
```bash
npm run build:prod
npm run deploy:prod
```

## Post-déploiement
- [ ] Vérifier les healthchecks
- [ ] Monitorer les erreurs
- [ ] Notifier l'équipe

---

NEVER déployer en production sans review.
```

Usage: `/deploy staging` ou `/deploy production`

### Variables disponibles

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | Arguments passés à la commande |

---

## 3. Configurer les permissions

### Fichier `.claude/settings.json`

```json
{
  "permissions": {
    "allow": [
      "Edit",
      "Write",
      "Bash(npm test:*)",
      "Bash(npm run lint:*)",
      "Bash(git status:*)",
      "Bash(git diff:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)"
    ],
    "deny": [
      "Bash(rm -rf:*)",
      "Bash(git push --force:*)",
      "Bash(DROP TABLE:*)"
    ]
  }
}
```

### Patterns de permission

| Pattern | Description |
|---------|-------------|
| `Bash(cmd:*)` | Autorise `cmd` avec tous arguments |
| `Bash(cmd arg:*)` | Autorise `cmd arg` avec suite libre |
| `Edit` | Modification de fichiers |
| `Write` | Création de fichiers |

### Permissions par environnement

Créez `.claude/settings.local.json` (gitignore) pour des permissions locales plus permissives :

```json
{
  "permissions": {
    "allow": [
      "Bash(docker:*)",
      "Bash(kubectl:*)"
    ]
  }
}
```

---

## 4. Configurer les hooks

### Dans `.claude/settings.json`

Les hooks sont configurés directement dans le fichier `settings.json` :

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "description": "Protection branche main",
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); if [ \"$branch\" = \"main\" ] || [ \"$branch\" = \"master\" ]; then echo \"Modification bloquée sur $branch\"; exit 1; fi'",
            "onFailure": "block"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "description": "Auto-format après édition",
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write $CLAUDE_FILE_PATH"
          }
        ]
      }
    ]
  }
}
```

### Types de hooks

| Hook | Déclencheur |
|------|-------------|
| `SessionStart` | Démarrage de session (matchers : `startup`, `resume`, `clear`, `compact`) |
| `SessionEnd` | Fin de session |
| `UserPromptSubmit` | Quand l'utilisateur soumet un prompt (peut injecter du contexte) |
| `PreToolUse` | Avant l'utilisation d'un outil (Edit, Write, Bash, Read…) |
| `PostToolUse` | Après l'utilisation d'un outil |
| `Stop` | Quand Claude termine une réponse |
| `Notification` | Notifications système (permissions, idle…) |

### Matchers disponibles

| Matcher | Outils ciblés |
|---------|---------------|
| `Edit` | Modifications de fichiers |
| `Write` | Création de fichiers |
| `Bash` | Commandes shell |
| `Read` | Lecture de fichiers |
| `Glob`, `Grep` | Recherche |
| `Edit\|Write` | Plusieurs outils (regex) |
| `*` | Tous les outils |

### Variables d'environnement

| Variable | Description |
|----------|-------------|
| `$CLAUDE_PROJECT_DIR` | Racine du projet (équivalent `pwd` au démarrage) |
| `$CLAUDE_SESSION_ID` | Identifiant unique de la session |
| `$CLAUDE_FILE_PATH` | Chemin du fichier concerné (PreToolUse/PostToolUse Edit/Write) |
| `$CLAUDE_TOOL_NAME` | Nom de l'outil utilisé |

Les hooks reçoivent aussi le payload JSON sur `stdin` (utiliser `jq` pour parser).

### Comportement en cas d'échec

| onFailure | Effet |
|-----------|-------|
| `block` | Bloque l'action (PreToolUse uniquement) |
| `continue` | Continue malgré l'erreur |
| (absent) | Continue par défaut |

---

## 5. Créer des skills personnalisés

Les skills sont déclenchés automatiquement par Claude selon le contexte (mots-clés dans la conversation). Idéaux pour les patterns récurrents qu'on ne veut pas invoquer manuellement.

### Emplacement

```
.claude/skills/
└── mon-skill/
    ├── SKILL.md          # Frontmatter + instructions principales
    ├── examples/         # (optionnel) Exemples détaillés
    └── references/       # (optionnel) Références volumineuses
```

### Format `SKILL.md`

```yaml
---
name: mon-skill
description: Quand déclencher ce skill (mots-clés ou contexte)
allowed-tools:
  - Read
  - Grep
  - Glob
  - Edit
  - Write
context: fork    # `fork` (recommandé) ou `inherit`
---

# Mon Skill

## Trigger

Activé quand l'utilisateur mentionne :
- "pattern X"
- "approche Y"

## Instructions

[Le prompt complet du skill — peut faire jusqu'à 500 lignes]

## Examples

Pour les exemples volumineux, déporter dans `examples/` et inclure via lien.
```

### Bonnes pratiques

- **`context: fork`** : isole le skill de la conversation principale (recommandé pour les workflows complexes).
- **Limiter `allowed-tools`** : principe du moindre privilège.
- **Description précise** : Claude utilise la description pour décider du déclenchement, soyez spécifique.
- **Skills ≠ Agents** : un skill complète Claude ; un agent est un sous-processus isolé.

### Exemple : skill de revue de code TypeScript

```yaml
---
name: review-typescript-strict
description: Activer quand l'utilisateur veut une review TypeScript stricte (any, types implicites, null safety)
allowed-tools:
  - Read
  - Grep
  - Glob
context: fork
---

# Review TypeScript Strict

Quand l'utilisateur demande une review TypeScript :

1. Détecter les `any` explicites (autres que les justifiés en commentaire).
2. Détecter les types implicites (paramètres sans type).
3. Vérifier la null safety (optional chaining, nullish coalescing).
4. Produire un rapport avec ligne:colonne pour chaque problème.
```

---

## 6. Intégrer des serveurs MCP

### Fichier `.mcp.json`

&gt; **Important sécurité** : par défaut, les MCP sont désactivés dans le socle (`.mcp.json` minimal). N'activez que les serveurs nécessaires et examinez leurs permissions.

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "."]
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "${DATABASE_URL}"
      }
    }
  }
}
```

### Serveurs MCP populaires

| Serveur | Package | Usage |
|---------|---------|-------|
| Filesystem | `@modelcontextprotocol/server-filesystem` | Accès fichiers contrôlé |
| Postgres | `@modelcontextprotocol/server-postgres` | Requêtes PostgreSQL |
| GitHub | `@modelcontextprotocol/server-github` | API GitHub (issues, PRs) |
| Puppeteer | `@modelcontextprotocol/server-puppeteer` | Automatisation navigateur |
| Fetch | `@modelcontextprotocol/server-fetch` | Requêtes HTTP |
| Memory | `@modelcontextprotocol/server-memory` | Mémoire knowledge graph |

Liste complète : &lt;https://github.com/modelcontextprotocol/servers&gt;.

---

## 7. Adapter pour votre équipe

### Conventions d'équipe

Ajoutez dans CLAUDE.md :

```markdown
## Conventions d'équipe

### Code review
- Minimum 1 approbation requise
- Auteur ne merge pas sa propre PR
- Squash merge préféré

### Communication
- Tickets Jira format: PROJ-123
- Commits référencent le ticket: "feat(PROJ-123): ..."

### Déploiements
- Staging: automatique sur develop
- Production: manuel, les mercredis uniquement
```

### Onboarding

Créez une commande d'onboarding spécifique :

`.claude/commands/team-onboard.md`:
```markdown
# Onboarding Équipe

Guide le nouveau développeur à travers le projet.

## Étapes

1. **Architecture**: Expliquer la structure
2. **Setup**: Guider l'installation locale
3. **Workflow**: Expliquer le processus de dev
4. **Conventions**: Présenter les règles d'équipe
5. **Ressources**: Lister la documentation importante

## Liens utiles
- Wiki: [lien]
- Jira: [lien]
- Slack: #channel-dev
```

### Partage des configurations

1. **Versionner** `.claude/` et `CLAUDE.md` dans git
2. **Gitignore** `CLAUDE.local.md` et `.claude/settings.local.json`
3. **Documenter** les commandes personnalisées dans le README

---

## Bonnes pratiques

1. **Commencer simple** - Ajouter des commandes au fur et à mesure des besoins
2. **Documenter les commandes** - Le futur vous remerciera
3. **Tester les permissions** - Vérifier que rien de dangereux n'est autorisé
4. **Itérer** - Améliorer CLAUDE.md basé sur l'expérience
5. **Partager** - Les bonnes configurations profitent à toute l'équipe

---

## Dépannage

### Claude ne trouve pas mes commandes

- Vérifier le chemin: `.claude/commands/nom.md`
- Vérifier que le fichier a l'extension `.md`
- Relancer Claude Code après ajout

### Les permissions ne fonctionnent pas

- Vérifier la syntaxe JSON
- Les patterns sont sensibles à la casse
- Utiliser des wildcards `:*` pour les arguments

### Les hooks ne se déclenchent pas

- Vérifier `"enabled": true`
- Vérifier que la commande existe
- Consulter les logs Claude
