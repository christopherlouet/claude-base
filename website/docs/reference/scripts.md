---
sidebar_position: 4
title: Scripts
description: Catalogue des scripts utilitaires claude-socle
---

import Stats from '@site/src/components/Stats';

# Scripts Utilitaires

> **14 scripts** pour installer, configurer et maintenir claude-socle

<Stats items={[
  { number: 14, label: 'Scripts' },
  { number: 5, label: 'Categories' },
]} />

## Vue d'ensemble

Les scripts sont organises en 5 categories :

| Categorie | Scripts | Description |
|-----------|---------|-------------|
| **Installation** | `new-project.sh` | Installer le socle |
| **Maintenance** | `update.sh`, `diff.sh`, `uninstall.sh`, `check-updates.sh` | Maintenir le socle |
| **Diagnostic** | `doctor.sh`, `validate.sh`, `validate-counts.sh` | Verifier l'installation |
| **Outils** | `ide.sh` | Configuration IDE |
| **Internes** | `lint.sh`, `test.sh`, `bump-version.sh`, `audit-socle.sh`, `export-minimal.sh` | CI et maintenance du socle |

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

### check-updates.sh

Verifie les mises a jour disponibles pour Claude Code CLI et les skills communautaires.

```bash
./scripts/check-updates.sh [OPTIONS]
```

**Options :**

| Option | Description |
|--------|-------------|
| `--json` | Sortie au format JSON |
| `--quiet` | Mode silencieux (uniquement si mises a jour) |
| `--force` | Ignorer le cache (TTL 24h par defaut) |
| `--no-cli` | Ne pas verifier Claude Code CLI |
| `--no-skills` | Ne pas verifier skills.sh |
| `--timeout N` | Timeout reseau en secondes (defaut: 10) |

**Codes de retour :**

| Code | Signification |
|------|---------------|
| 0 | Tout est a jour |
| 1 | Mises a jour disponibles |
| 2 | Erreur lors de la verification |

**Exemple :**

```bash
# Verification complete
./scripts/check-updates.sh

# Sortie JSON pour CI/CD
./scripts/check-updates.sh --json

# CLI uniquement, sans cache
./scripts/check-updates.sh --no-skills --force
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

### bump-version.sh

Met a jour la version du socle (`VERSION`, badges, references).

```bash
./scripts/bump-version.sh <new-version>
```

### audit-socle.sh

Audit structurel complet : detecte fichiers orphelins, references cassees, incoherences entre socle et documentation.

```bash
./scripts/audit-socle.sh
```

### export-minimal.sh

Exporte une configuration minimale du socle dans une archive `.tar.gz` (ou copie directement vers un dossier cible). Utilise par `new-project.sh --minimal` pour les projets qui ne veulent qu'un sous-ensemble du socle.

```bash
# Archive par defaut (dist/claude-socle-minimal.tar.gz)
./scripts/export-minimal.sh

# Archive avec chemin personnalise
./scripts/export-minimal.sh --output /tmp/socle.tar.gz

# Copie directe vers un dossier (sans archive)
./scripts/export-minimal.sh --dest-dir /chemin/projet
```

Le manifest des fichiers inclus est defini dans `scripts/lib/minimal-manifest.txt`.

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
| `update.sh` | Mettre a jour | `curl ... \| bash` |
| `check-updates.sh` | Verifier les mises a jour | `./scripts/check-updates.sh` |
| `diff.sh` | Comparer avec le socle | `./scripts/diff.sh` |
| `uninstall.sh` | Desinstaller | `./scripts/uninstall.sh` |
| `doctor.sh` | Diagnostiquer | `./scripts/doctor.sh --fix` |
| `validate.sh` | Valider la config | `./scripts/validate.sh` |
| `ide.sh` | Configurer les IDE | `./scripts/ide.sh setup vscode` |
