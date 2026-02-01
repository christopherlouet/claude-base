---
sidebar_position: 4
title: Installation
description: Guide d'installation complet de claude-socle
---

# Installation

Guide complet pour installer et configurer claude-socle dans votre projet.

## Prerequis

### Obligatoires

- **Claude Code** installe et configure
  ```bash
  # Verifier l'installation
  claude --version
  ```

- **Git** pour le versioning
  ```bash
  git --version
  ```

### Recommandes

- **Node.js 18+** pour les projets web
- **npm** ou **yarn** pour la gestion des dependances

## Methodes d'installation

### Methode 1 : Script automatique (recommande)

```bash
# Dans le repertoire de votre projet
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-socle/main/scripts/new-project.sh | bash
```

Le script effectue :
1. Verification des prerequis
2. Clone du repository
3. Copie du dossier `.claude/`
4. Configuration des permissions
5. Verification de l'installation

### Methode 2 : Clone direct

```bash
# Cloner dans un dossier temporaire
git clone https://github.com/christopherlouet/claude-socle.git temp-socle

# Copier le dossier .claude
cp -r temp-socle/.claude .

# Copier les fichiers de configuration
cp temp-socle/CLAUDE.md .
cp temp-socle/.mcp.json .

# Nettoyer
rm -rf temp-socle
```

### Methode 3 : Submodule Git

```bash
# Ajouter comme submodule
git submodule add https://github.com/christopherlouet/claude-socle.git .claude-socle

# Creer un lien symbolique
ln -s .claude-socle/.claude .claude
```

## Configuration

### Fichier CLAUDE.md

Le fichier `CLAUDE.md` a la racine contient les instructions principales. Adaptez-le a votre projet :

```markdown
# Mon Projet

## Structure
- /src - Code source
- /tests - Tests

## Conventions
- TypeScript strict
- Tests obligatoires

## Workflows
- /work:work-flow-feature pour les features
- /work:work-flow-bugfix pour les bugs
```

### Fichier .mcp.json

Activez les serveurs MCP selon vos besoins :

```json
{
  "mcpServers": {
    "filesystem": {
      "enabled": true,
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-filesystem"]
    },
    "github": {
      "enabled": true,
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-github"]
    }
  }
}
```

### Fichier .claude/settings.json

Personnalisez les hooks et parametres :

```json
{
  "permissions": {
    "allow": ["Read", "Glob", "Grep", "Bash"],
    "deny": []
  },
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

## Verification

### Test de base

```bash
# Lancer Claude Code
claude

# Verifier le message d'accueil
# Vous devriez voir :
# === Claude Code Session ===
# Version socle: 1.2.0
# Commandes: 100
# ===========================
```

### Test des commandes

```bash
# Dans Claude Code, testez :
/assistant

# Vous devriez voir le guide complet des commandes
```

### Test d'un workflow

```bash
# Testez le workflow d'exploration
/work:work-explore

# Claude devrait analyser votre projet
```

## Mise a jour

### Methode automatique

```bash
# Utiliser le script de mise a jour
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-socle/main/scripts/update.sh | bash
```

### Methode manuelle

```bash
# Sauvegarder les modifications locales
cp .claude/settings.json .claude/settings.json.bak

# Mettre a jour
cd .claude
git pull origin main
cd ..

# Restaurer les modifications
cp .claude/settings.json.bak .claude/settings.json
```

## Personnalisation

### Ajouter une commande personnalisee

Creez un fichier dans `.claude/commands/` :

```markdown
# .claude/commands/my-command.md

# Ma Commande Personnalisee

## Contexte
$ARGUMENTS

## Objectif
Description de ce que fait la commande.

## Processus
1. Etape 1
2. Etape 2

## Output
Format de sortie attendu.
```

### Ajouter une regle personnalisee

Creez un fichier dans `.claude/rules/` :

```markdown
# .claude/rules/my-rules.md
---
paths:
  - "**/my-folder/**"
---

# Regles pour my-folder

- Toujours utiliser des fonctions pures
- Documentation obligatoire
```

## Troubleshooting

### Les commandes ne fonctionnent pas

1. Verifiez que le dossier `.claude/` existe
2. Verifiez les permissions des fichiers
3. Relancez Claude Code

### Le message d'accueil n'apparait pas

Verifiez le hook `SessionStart` dans `.claude/settings.json` :

```json
{
  "hooks": {
    "SessionStart": [
      {
        "command": "scripts/validate.sh session-start"
      }
    ]
  }
}
```

### Erreurs de permission

```bash
# Rendre les scripts executables
chmod +x .claude/scripts/*.sh
```

## Prochaines etapes

- [Quick Start](/docs/intro/quick-start) - Premier workflow en 5 minutes
- [Architecture](/docs/intro/architecture) - Comprendre les composants
- [Workflows](/docs/workflow) - Voir les workflows detailles
- [Scripts utilitaires](/docs/reference/scripts) - Tous les scripts disponibles
