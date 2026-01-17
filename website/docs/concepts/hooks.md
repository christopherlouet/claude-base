---
sidebar_position: 6
title: Hooks
description: Comprendre les hooks Claude Code
---

# Hooks

> Actions automatiques avant ou apres l'utilisation d'outils

## Qu'est-ce qu'un Hook ?

Un **hook** est une commande shell executee automatiquement avant (PreToolUse) ou apres (PostToolUse) l'utilisation d'un outil par Claude.

```
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│  Claude veut utiliser l'outil "Edit"                           │
│              │                                                 │
│              ▼                                                 │
│  ┌────────────────────────────────────────┐                    │
│  │ PreToolUse Hook                        │                    │
│  │                                        │                    │
│  │ Matcher: "Edit|Write"                  │                    │
│  │ Command: scripts/validate.sh protect   │                    │
│  │                                        │                    │
│  │ → Verifie qu'on n'est pas sur main     │                    │
│  └────────────────────────────────────────┘                    │
│              │                                                 │
│              ▼ (si hook OK)                                    │
│  ┌────────────────────────────────────────┐                    │
│  │ Outil "Edit" execute                   │                    │
│  └────────────────────────────────────────┘                    │
│              │                                                 │
│              ▼                                                 │
│  ┌────────────────────────────────────────┐                    │
│  │ PostToolUse Hook                       │                    │
│  │                                        │                    │
│  │ Matcher: "Edit|Write"                  │                    │
│  │ Command: scripts/validate.sh format    │                    │
│  │                                        │                    │
│  │ → Formate automatiquement le fichier   │                    │
│  └────────────────────────────────────────┘                    │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

## Configuration

Les hooks sont configures dans `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "scripts/validate.sh protect-main"
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "scripts/validate.sh auto-format $FILE_PATH"
      }
    ]
  }
}
```

## Types de hooks

### PreToolUse

Execute **avant** l'utilisation de l'outil.

**Usages:**
- Bloquer certaines actions
- Valider des preconditions
- Verifier des permissions

**Comportement:**
- Si le hook echoue (exit code != 0), l'outil n'est pas execute
- Le message d'erreur est affiche a l'utilisateur

### PostToolUse

Execute **apres** l'utilisation de l'outil.

**Usages:**
- Formater le code modifie
- Verifier les types
- Mettre a jour des caches

**Comportement:**
- Execute meme si l'outil a echoue
- N'affecte pas le resultat de l'outil

## Structure d'un hook

```json
{
  "matcher": "Edit|Write",
  "command": "scripts/validate.sh action $FILE_PATH"
}
```

### Champ `matcher`

Expression reguliere pour filtrer les outils:

| Matcher | Description |
|---------|-------------|
| `"Edit"` | Uniquement Edit |
| `"Edit\|Write"` | Edit ou Write |
| `".*"` | Tous les outils |
| `"Bash"` | Uniquement Bash |

### Champ `command`

Commande shell a executer. Variables disponibles:

| Variable | Description |
|----------|-------------|
| `$FILE_PATH` | Chemin du fichier concerne |
| `$TOOL_NAME` | Nom de l'outil |

## Exemples de hooks

### Protection de la branche main

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "scripts/validate.sh protect-main"
      }
    ]
  }
}
```

Script `scripts/validate.sh`:

```bash
#!/bin/bash

case "$1" in
  protect-main)
    BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
      echo "BLOCKED: Cannot modify files on $BRANCH branch"
      echo "Please create a feature branch first"
      exit 1
    fi
    ;;
esac
```

### Auto-format avec Prettier

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "scripts/validate.sh auto-format $FILE_PATH"
      }
    ]
  }
}
```

Script:

```bash
#!/bin/bash

case "$1" in
  auto-format)
    FILE="$2"
    if [[ "$FILE" =~ \.(ts|tsx|js|jsx)$ ]]; then
      npx prettier --write "$FILE" 2>/dev/null
    fi
    ;;
esac
```

### Type-check TypeScript

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "scripts/validate.sh typecheck $FILE_PATH"
      }
    ]
  }
}
```

Script:

```bash
#!/bin/bash

case "$1" in
  typecheck)
    FILE="$2"
    if [[ "$FILE" =~ \.(ts|tsx)$ ]]; then
      npx tsc --noEmit 2>&1 | head -20
    fi
    ;;
esac
```

### Auto-install des dependances

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "scripts/validate.sh auto-install $FILE_PATH"
      }
    ]
  }
}
```

Script:

```bash
#!/bin/bash

case "$1" in
  auto-install)
    FILE="$2"
    if [[ "$FILE" == *"package.json" ]]; then
      npm install
    fi
    ;;
esac
```

## Configuration complete

Exemple de `.claude/settings.json` complet:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "scripts/validate.sh protect-main"
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "scripts/validate.sh auto-format $FILE_PATH"
      },
      {
        "matcher": "Edit|Write",
        "command": "scripts/validate.sh typecheck $FILE_PATH"
      },
      {
        "matcher": "Edit|Write",
        "command": "scripts/validate.sh auto-install $FILE_PATH"
      }
    ]
  }
}
```

## Script de validation unifie

Un seul script pour tous les hooks:

```bash
#!/bin/bash
# scripts/validate.sh

set -e

case "$1" in
  protect-main)
    BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
      echo "BLOCKED: Cannot modify files on $BRANCH"
      exit 1
    fi
    ;;

  auto-format)
    FILE="$2"
    if [[ -n "$FILE" && "$FILE" =~ \.(ts|tsx|js|jsx)$ ]]; then
      npx prettier --write "$FILE" 2>/dev/null || true
    fi
    ;;

  typecheck)
    FILE="$2"
    if [[ -n "$FILE" && "$FILE" =~ \.(ts|tsx)$ ]]; then
      npx tsc --noEmit 2>&1 | head -20 || true
    fi
    ;;

  auto-install)
    FILE="$2"
    if [[ "$FILE" == *"package.json" ]]; then
      npm install
    fi
    ;;

  *)
    echo "Unknown action: $1"
    exit 1
    ;;
esac
```

## Bonnes pratiques

### 1. Hooks rapides

Les hooks sont executes a chaque utilisation d'outil. Gardez-les rapides:

```bash
# Bon - rapide
npx prettier --write "$FILE"

# Mauvais - lent
npm run build
```

### 2. Gestion des erreurs

Les PreToolUse peuvent bloquer, mais les PostToolUse ne devraient pas echouer bruyamment:

```bash
# PostToolUse - ne pas bloquer
npx prettier --write "$FILE" 2>/dev/null || true
```

### 3. Messages clairs

Pour les PreToolUse qui bloquent:

```bash
echo "BLOCKED: Raison claire"
echo "Solution: Ce que l'utilisateur doit faire"
exit 1
```

### 4. Filtrage precis

Cibler uniquement les outils necessaires:

```json
{
  "matcher": "Edit|Write",  // Pas ".*"
  "command": "..."
}
```

## Debugger les hooks

### Voir les hooks actifs

```bash
cat .claude/settings.json | jq '.hooks'
```

### Tester un hook manuellement

```bash
scripts/validate.sh protect-main
echo $?  # 0 = OK, 1 = bloque
```

### Logs verbeux

```bash
#!/bin/bash
# Ajouter au debut du script
echo "[HOOK] Action: $1, File: $2" >> /tmp/claude-hooks.log
```

---

## Voir aussi

- [Rules](./rules) - Conventions par fichier
- [MCP Servers](./mcp-servers) - Extensions via MCP
- [Architecture](/docs/intro/architecture) - Vue d'ensemble
