# Guide de Personnalisation

Comment adapter claude-socle à vos besoins spécifiques.

---

## Table des matières

1. [Personnaliser CLAUDE.md](#1-personnaliser-claudemd)
2. [Créer des commandes personnalisées](#2-créer-des-commandes-personnalisées)
3. [Configurer les permissions](#3-configurer-les-permissions)
4. [Configurer les hooks](#4-configurer-les-hooks)
5. [Intégrer des serveurs MCP](#5-intégrer-des-serveurs-mcp)
6. [Adapter pour votre équipe](#6-adapter-pour-votre-équipe)

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

### Fichier `.claude/hooks.json`

```json
{
  "hooks": {
    "post-edit": {
      "commands": [
        {
          "pattern": "*.ts",
          "command": "npx eslint --fix ${file}",
          "enabled": true
        }
      ]
    },
    "pre-commit": {
      "commands": [
        {
          "command": "npm test",
          "enabled": true
        }
      ]
    }
  }
}
```

### Types de hooks

| Hook | Déclencheur |
|------|-------------|
| `pre-edit` | Avant modification de fichier |
| `post-edit` | Après modification de fichier |
| `pre-commit` | Avant commit |
| `post-commit` | Après commit |
| `session-start` | Au démarrage de session |

### Variables dans les hooks

| Variable | Description |
|----------|-------------|
| `${file}` | Chemin du fichier modifié |
| `${dir}` | Dossier du fichier |

---

## 5. Intégrer des serveurs MCP

### Fichier `.mcp.json`

```json
{
  "mcpServers": {
    "database": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-postgres"],
      "env": {
        "DATABASE_URL": "${DATABASE_URL}"
      },
      "enabled": true
    },
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-puppeteer"],
      "enabled": true
    }
  }
}
```

### Serveurs MCP disponibles

| Serveur | Usage |
|---------|-------|
| `mcp-postgres` | Requêtes PostgreSQL |
| `mcp-puppeteer` | Automatisation navigateur |
| `mcp-filesystem` | Accès fichiers avancé |
| `mcp-github` | Intégration GitHub |
| `mcp-fetch` | Requêtes HTTP |

---

## 6. Adapter pour votre équipe

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
