---
sidebar_position: 4
title: Scripts
description: Catalogue des scripts utilitaires claude-socle
---

import Stats from '@site/src/components/Stats';

# Scripts Utilitaires

> **12 scripts** pour installer, configurer et maintenir claude-socle

<Stats items={[
  { number: 12, label: 'Scripts' },
  { number: 4, label: 'Categories' },
]} />

## Vue d'ensemble

Les scripts sont organises en 4 categories :

| Categorie | Scripts | Description |
|-----------|---------|-------------|
| **Installation** | `new-project.sh`, `install.sh` | Installer le socle |
| **Maintenance** | `update.sh`, `diff.sh`, `uninstall.sh` | Maintenir le socle |
| **Diagnostic** | `doctor.sh`, `validate.sh` | Verifier l'installation |
| **Outils** | `setup-wizard.sh`, `ide.sh`, `learn.sh` | Configuration avancee |

---

## Scripts d'Installation

### new-project.sh

Script principal pour creer un nouveau projet ou configurer un projet existant.

```bash
# Installation rapide (recommande)
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-socle/main/scripts/new-project.sh | bash

# Ou depuis le socle clone
./scripts/new-project.sh [OPTIONS] [CHEMIN]
```

**Options principales :**

| Option | Description |
|--------|-------------|
| `-t, --type TYPE` | Type de projet (react, vue, node-api, python, go, flutter) |
| `-n, --name NOM` | Nom du projet |
| `--cicd` | Inclure les workflows CI/CD |
| `--hooks` | Inclure les hooks Git |
| `--mcp` | Inclure la configuration MCP |
| `--docker` | Inclure la configuration Docker |
| `-y, --yes` | Mode non-interactif |

**Exemple :**

```bash
# Nouveau projet React avec CI/CD
./scripts/new-project.sh -t react -n mon-app --cicd --hooks

# Configurer un projet existant
cd mon-projet-existant
./scripts/new-project.sh --cicd --hooks
```

**Fonctionnalites :**
- Detection automatique du type de projet
- Analyse de la CI/CD existante avec suggestions d'amelioration
- Configuration des hooks Claude Code
- Installation des dependances

---

### install.sh

Installe la configuration Claude Code dans un projet existant (version simplifiee de `new-project.sh`).

```bash
./scripts/install.sh [OPTIONS] [CHEMIN]
```

**Options :**

| Option | Description |
|--------|-------------|
| `--cicd` | Inclure les workflows CI/CD |
| `--hooks` | Inclure les hooks Git |
| `--mcp` | Inclure la configuration MCP |
| `-y, --yes` | Mode non-interactif |

**Exemple :**

```bash
# Installation basique
./scripts/install.sh .

# Installation complete
./scripts/install.sh --cicd --hooks --mcp /chemin/vers/projet
```

---

## Scripts de Maintenance

### update.sh

Met a jour les commandes, agents, skills et rules depuis le socle.

```bash
# Mise a jour rapide
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-socle/main/scripts/update.sh | bash

# Ou depuis le socle clone
./scripts/update.sh [OPTIONS] [CHEMIN]
```

**Options :**

| Option | Description |
|--------|-------------|
| `-f, --force` | Forcer la mise a jour (ecrase les modifications locales) |
| `--backup` | Creer une sauvegarde uniquement |
| `--settings` | Mettre a jour settings.json |
| `--skills` | Mettre a jour les skills uniquement |
| `--agents` | Mettre a jour les agents uniquement |
| `--rules` | Mettre a jour les rules uniquement |
| `--clean` | Nettoyer avant mise a jour |
| `--orphans` | Detecter les fichiers orphelins |
| `--remove-orphans` | Supprimer les fichiers orphelins |

**Exemple :**

```bash
# Mise a jour standard
./scripts/update.sh

# Mise a jour forcee avec nettoyage
./scripts/update.sh --force --clean

# Mise a jour des skills uniquement
./scripts/update.sh --skills
```

---

### diff.sh

Compare la configuration locale avec le socle pour identifier les differences.

```bash
./scripts/diff.sh [OPTIONS] [CHEMIN]
```

**Options :**

| Option | Description |
|--------|-------------|
| `--show new` | Afficher uniquement les nouveaux fichiers |
| `--show modified` | Afficher uniquement les fichiers modifies |
| `--show deleted` | Afficher uniquement les fichiers supprimes |
| `--content` | Afficher le contenu des differences |
| `--no-color` | Desactiver les couleurs |

**Exemple :**

```bash
# Voir toutes les differences
./scripts/diff.sh

# Voir uniquement les modifications locales
./scripts/diff.sh --show modified --content
```

**Output :**

```
📊 Comparaison avec le socle claude-socle

Nouveaux fichiers (locaux):     2
Fichiers modifies:              5
Fichiers supprimes:             0
Fichiers identiques:           98
```

---

### uninstall.sh

Supprime la configuration Claude Code d'un projet.

```bash
./scripts/uninstall.sh [OPTIONS] [CHEMIN]
```

**Options :**

| Option | Description |
|--------|-------------|
| `--keep-claude-md` | Conserver le fichier CLAUDE.md |
| `--no-backup` | Ne pas creer de sauvegarde |
| `-f, --force` | Supprimer sans confirmation |
| `--remove-local` | Supprimer aussi les fichiers locaux |

**Exemple :**

```bash
# Desinstallation avec sauvegarde (defaut)
./scripts/uninstall.sh

# Desinstallation complete
./scripts/uninstall.sh --force --no-backup
```

:::caution
Par defaut, une sauvegarde est creee dans `.claude-backup-YYYYMMDD-HHMMSS/`.
:::

---

## Scripts de Diagnostic

### doctor.sh

Diagnostic complet de l'environnement Claude Code.

```bash
./scripts/doctor.sh [OPTIONS] [CHEMIN]
```

**Options :**

| Option | Description |
|--------|-------------|
| `--fix` | Tenter de corriger les problemes detectes |
| `--json` | Sortie au format JSON |

**Verifications effectuees :**

| Check | Description |
|-------|-------------|
| Claude Code | Version et installation |
| Git | Configuration et version |
| Node.js | Version (si projet JS/TS) |
| Dossier .claude | Presence et permissions |
| settings.json | Validite du JSON |
| Hooks | Configuration des hooks |
| MCP | Serveurs MCP configures |

**Exemple :**

```bash
# Diagnostic complet
./scripts/doctor.sh

# Diagnostic avec corrections automatiques
./scripts/doctor.sh --fix
```

**Output :**

```
🏥 Diagnostic Claude Code

✓ Claude Code installe (v1.0.0)
✓ Git configure
✓ Node.js 20.x
✓ Dossier .claude present
⚠ settings.json: hook manquant
✗ MCP: serveur github non configure

Resultat: 4 OK, 1 warning, 1 erreur
```

---

### validate.sh

Valide la configuration Claude Code et calcule un score de qualite.

```bash
./scripts/validate.sh [OPTIONS] [CHEMIN]
```

**Options :**

| Option | Description |
|--------|-------------|
| `--json` | Sortie au format JSON |
| `--score` | Afficher uniquement le score |

**Actions speciales (utilisees par les hooks) :**

```bash
# Protection de la branche main
./scripts/validate.sh protect-main

# Auto-formatage
./scripts/validate.sh auto-format $FILE_PATH

# Verification des types
./scripts/validate.sh typecheck $FILE_PATH

# Auto-installation des dependances
./scripts/validate.sh auto-install $FILE_PATH

# Message de session
./scripts/validate.sh session-start
```

**Exemple :**

```bash
# Validation complete
./scripts/validate.sh

# Score uniquement
./scripts/validate.sh --score
# Output: 85
```

---

## Scripts Outils

### setup-wizard.sh

Assistant de configuration interactif qui detecte le type de projet et propose une configuration optimale.

```bash
./scripts/setup-wizard.sh [CHEMIN]
```

**Fonctionnalites :**

1. **Detection automatique** du type de projet (React, Vue, Node, Python, Go, Flutter)
2. **Analyse des dependances** et frameworks utilises
3. **Configuration personnalisee** des hooks et settings
4. **Generation de CLAUDE.md** adapte au projet

**Exemple :**

```bash
# Lancer le wizard dans le repertoire courant
./scripts/setup-wizard.sh

# Lancer pour un projet specifique
./scripts/setup-wizard.sh /chemin/vers/projet
```

**Workflow interactif :**

```
═══════════════════════════════════════════════════════════════
  Setup Wizard - Configuration intelligente
═══════════════════════════════════════════════════════════════

→ Detection du type de projet...
✓ Projet detecte: React + TypeScript

→ Souhaitez-vous activer les hooks Claude Code? [Y/n]
→ Souhaitez-vous configurer les serveurs MCP? [Y/n]
→ Souhaitez-vous generer un CLAUDE.md personnalise? [Y/n]

✓ Configuration terminee!
```

---

### ide.sh

Configure les IDE pour une integration optimale avec claude-socle.

```bash
./scripts/ide.sh <setup|check|remove> <ide> [OPTIONS] [CHEMIN]
```

**IDE supportes :**

| IDE | Commande | Fichiers generes |
|-----|----------|------------------|
| VSCode | `vscode` | settings.json, tasks.json, extensions.json, snippets |
| Cursor | `cursor` | Meme que VSCode |
| IntelliJ | `idea` | run configurations, code style, templates |
| Vim/Neovim | `vim` | abbreviations, mappings, autocmds |
| Tous | `all` | Configure tous les IDE detectes |

**Commandes :**

| Commande | Description |
|----------|-------------|
| `setup` | Configure l'IDE |
| `check` | Verifie la configuration |
| `remove` | Supprime la configuration |

**Options :**

| Option | Description |
|--------|-------------|
| `-n, --dry-run` | Simule sans modifier |
| `-f, --force` | Ecrase les fichiers existants |

**Exemple :**

```bash
# Configurer VSCode
./scripts/ide.sh setup vscode

# Verifier la configuration IntelliJ
./scripts/ide.sh check idea

# Supprimer la configuration Vim
./scripts/ide.sh remove vim

# Configurer tous les IDE detectes
./scripts/ide.sh setup all
```

---

### learn.sh

Tutoriel interactif pour apprendre a utiliser claude-socle.

```bash
./scripts/learn.sh [OPTIONS]
```

**Options :**

| Option | Description |
|--------|-------------|
| `-q, --quick` | Mode rapide (5 minutes) |
| `-a, --agent AGENT` | Apprendre un agent specifique |
| `-l, --list` | Lister les agents disponibles |
| `--reset` | Reinitialiser la progression |

**Agents disponibles pour l'apprentissage :**

- `workflow` - Le workflow Explore → Plan → Code → Commit
- `tdd` - Test-Driven Development
- `commit` - Conventional Commits
- `review` - Code Review
- `security` - Audit de securite

**Exemple :**

```bash
# Tutoriel complet (15-20 min)
./scripts/learn.sh

# Version courte (5 min)
./scripts/learn.sh --quick

# Apprendre le TDD
./scripts/learn.sh --agent tdd
```

**Contenu du tutoriel :**

1. **Lecon 1** : Introduction au workflow
2. **Lecon 2** : Les agents et leurs roles
3. **Lecon 3** : TDD avec claude-socle
4. **Lecon 4** : Conventional Commits
5. **Lecon 5** : Code Review
6. **Lecon 6** : Quiz final

---

## Scripts Internes

### lint.sh

Valide la qualite du code du socle lui-meme (utilise par la CI).

```bash
./scripts/lint.sh
```

### test.sh

Execute les tests du socle (tests bats).

```bash
./scripts/test.sh
```

---

## Utilisation avec curl

Plusieurs scripts peuvent etre executes directement depuis GitHub :

```bash
# Installation
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-socle/main/scripts/new-project.sh | bash

# Mise a jour
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-socle/main/scripts/update.sh | bash

# Avec options (necessite de telecharger d'abord)
curl -fsSL https://raw.githubusercontent.com/christopherlouet/claude-socle/main/scripts/new-project.sh -o /tmp/new-project.sh
chmod +x /tmp/new-project.sh
/tmp/new-project.sh --cicd --hooks
```

---

## Resume

| Script | Usage principal | Commande rapide |
|--------|-----------------|-----------------|
| `new-project.sh` | Creer/configurer un projet | `curl ... \| bash` |
| `install.sh` | Installer le socle | `./scripts/install.sh .` |
| `update.sh` | Mettre a jour | `curl ... \| bash` |
| `diff.sh` | Comparer avec le socle | `./scripts/diff.sh` |
| `uninstall.sh` | Desinstaller | `./scripts/uninstall.sh` |
| `doctor.sh` | Diagnostiquer | `./scripts/doctor.sh --fix` |
| `validate.sh` | Valider la config | `./scripts/validate.sh` |
| `setup-wizard.sh` | Configuration guidee | `./scripts/setup-wizard.sh` |
| `ide.sh` | Configurer les IDE | `./scripts/ide.sh setup vscode` |
| `learn.sh` | Tutoriel interactif | `./scripts/learn.sh --quick` |
