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
  claude --version
  ```

- **Git** pour le versioning
  ```bash
  git --version
  ```

### Recommandes

- **Node.js 18+** pour les projets web
- **npm** ou **yarn** pour la gestion des dependances
- **Bats** et **ShellCheck** uniquement si vous comptez contribuer au socle

## Methodes d'installation

Trois methodes sont disponibles selon votre cas d'usage. La premiere est recommandee.

### Methode 1 : Script `new-project.sh` (recommande)

Le socle expose un script unique qui copie la configuration `.claude/`, le `CLAUDE.md` et les fichiers necessaires dans votre projet existant ou dans un nouveau projet.

```bash
# 1. Cloner le socle (une seule fois, n'importe ou)
git clone https://github.com/christopherlouet/claude-socle.git ~/.claude-socle

# 2. Installation simple (juste .claude/ + CLAUDE.md)
~/.claude-socle/scripts/new-project.sh --simple /chemin/vers/votre-projet

# 3. Ou installation complete (ajoute hooks, MCP, .github/, scripts CI)
~/.claude-socle/scripts/new-project.sh --all /chemin/vers/votre-projet
```

Vous pouvez aussi lancer le script depuis votre projet :

```bash
cd /chemin/vers/votre-projet
~/.claude-socle/scripts/new-project.sh --simple .
```

#### Options utiles

| Flag | Effet |
|------|-------|
| `--simple` | Copie minimale : `.claude/` + `CLAUDE.md` + `.mcp.json` |
| `--all` | Installation complete : ajoute hooks, GitHub Actions, scripts |
| `-y` | Mode silencieux (CI/CD) |
| `--dry-run` | Simulation sans modifications |
| `--help` | Affiche l'aide complete |

### Methode 2 : Copie manuelle

Pour un controle fin de ce qui est copie :

```bash
# Cloner le socle dans un dossier temporaire
git clone --depth 1 https://github.com/christopherlouet/claude-socle.git temp-socle

# Copier le minimum vital
cp -r temp-socle/.claude /chemin/vers/votre-projet/
cp temp-socle/CLAUDE.md /chemin/vers/votre-projet/

# Optionnel
cp temp-socle/.mcp.json /chemin/vers/votre-projet/
cp -r temp-socle/.github /chemin/vers/votre-projet/

# Nettoyer
rm -rf temp-socle
```

### Methode 3 : Utiliser comme template

Pour un nouveau projet, le socle peut servir directement de squelette :

```bash
git clone https://github.com/christopherlouet/claude-socle.git mon-nouveau-projet
cd mon-nouveau-projet

# Reinitialiser l'historique git (optionnel)
rm -rf .git && git init

# Personnaliser CLAUDE.md selon votre stack
# (templates disponibles dans templates/CLAUDE.*.md)
cp templates/CLAUDE.react.md CLAUDE.md
```

## Verification

Une fois installe, lancez Claude Code dans votre projet :

```bash
cd /chemin/vers/votre-projet
claude
```

Vous devriez voir le message d'accueil du hook `SessionStart` :

```
=== Claude Code Session ===
Version socle: 1.30.0
Commandes: 131
Agents: 63
===========================
```

Si les chiffres different, votre socle est probablement installe mais sur une version differente — c'est normal si vous avez installe une version anterieure.

### Test des commandes

Dans Claude Code, testez :

```
/assistant
```

Vous devriez voir le guide d'orientation. Essayez ensuite un workflow simple :

```
/work:work-explore .
```

## Mise a jour

### Cas standard : meme version majeure

```bash
# Mettre a jour le socle local
cd ~/.claude-socle
git pull origin main

# Re-synchroniser les fichiers dans votre projet
~/.claude-socle/scripts/update.sh /chemin/vers/votre-projet
```

Le script `update.sh` est idempotent : il met a jour les fichiers du socle (commands, agents, skills, rules, scripts/hooks) sans toucher a vos personnalisations (`CLAUDE.md`, `.claude/settings.local.json`).

### Migration depuis une version pre-v1.30

**Breaking change v1.30** : la documentation du socle (`reference/`, `guides/`) est desormais installee sous `.claude/docs/` au lieu de `docs/`. Cela evite les collisions avec le `docs/` de votre projet.

```bash
# Migration automatique (idempotent, backup inclus)
~/.claude-socle/scripts/update.sh --upgrade-claude-md /chemin/vers/votre-projet
```

Le script :
1. Cree un backup `CLAUDE.md.backup.AAAAMMJJ_HHMMSS`
2. Deplace `docs/reference/` → `.claude/docs/reference/`
3. Deplace `docs/guides/` → `.claude/docs/guides/` (preserve les fichiers personnalises)
4. Reecrit les `@imports` dans `CLAUDE.md`

Guide complet (cas particuliers, migration manuelle, rollback) : voir [`docs/MIGRATION-v1.30.md`](https://github.com/christopherlouet/claude-socle/blob/main/docs/MIGRATION-v1.30.md) dans le repo.

## Personnalisation

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

Des templates pre-remplis sont disponibles dans `templates/CLAUDE.*.md` du socle (React, Next.js, Vue, Node API, Python, Go, Rust, Java, Flutter, fullstack, neovim).

### Fichier .mcp.json

Activez les serveurs MCP selon vos besoins. **Par defaut, les MCP sont desactives** pour des raisons de securite.

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "."]
    }
  }
}
```

### Ajouter une commande personnalisee

Creez un fichier dans `.claude/commands/` :

```markdown
---
description: Ma commande
---

# Ma Commande Personnalisee

## Contexte
$ARGUMENTS

## Objectif
Description de ce que fait la commande.

## Processus
1. Etape 1
2. Etape 2
```

### Ajouter une regle contextuelle

Creez un fichier dans `.claude/rules/` :

```markdown
---
paths:
  - "**/my-folder/**"
---

# Regles pour my-folder

- Toujours utiliser des fonctions pures
- Documentation obligatoire
```

## Troubleshooting

### Le message d'accueil n'apparait pas

Verifiez le hook `SessionStart` dans `.claude/settings.json` :

```bash
grep -A 3 SessionStart .claude/settings.json
```

Si le hook est present mais ne s'execute pas, verifiez que les scripts du dossier `scripts/hooks/` sont presents et executables.

### Les commandes slash ne sont pas reconnues

```bash
# Verifier la presence du dossier
ls .claude/commands/

# Re-synchroniser depuis le socle
~/.claude-socle/scripts/update.sh .
```

### Erreurs de permission sur les hooks

```bash
chmod +x .claude/scripts/*.sh scripts/hooks/*.sh
```

### Conflit avec une configuration existante

```bash
# Sauvegarder + reinstaller proprement
./scripts/uninstall.sh --keep-claude-md .
~/.claude-socle/scripts/new-project.sh --simple .
```

### Diagnostic complet

```bash
~/.claude-socle/scripts/doctor.sh /chemin/vers/votre-projet
~/.claude-socle/scripts/diff.sh   /chemin/vers/votre-projet
```

## Prochaines etapes

- [Quick Start](/docs/intro/quick-start) - Premier workflow en 5 minutes
- [Architecture](/docs/intro/architecture) - Comprendre Commands vs Agents vs Skills vs Rules
- [Workflows](/docs/concepts/workflows) - Voir les workflows detailles
- [Scripts utilitaires](/docs/reference/scripts) - Tous les scripts disponibles
