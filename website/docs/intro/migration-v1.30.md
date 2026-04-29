---
sidebar_position: 5
title: Migration v1.30
description: Guide de migration vers v1.30 (relocalisation des docs vers .claude/docs/)
---

# Migration v1.30 — relocalisation de la doc socle vers `.claude/docs/`

> **Concerne uniquement les projets utilisateurs** ayant installe une version pre-v1.30 du socle.
> Le repo socle lui-meme n'est pas concerne (il garde `docs/` comme source de verite interne).

## Pourquoi cette migration

A partir de v1.30, la documentation du socle (`reference/`, `guides/`) est installee sous `.claude/docs/` au lieu de `docs/`. Deux problemes de l'ancien comportement :

1. **Collisions** — un projet d'infra avec son propre `docs/ARCHITECTURE.md` (schema Mermaid, par exemple) le voyait ecrase a chaque install/update.
2. **Pollution** — la doc du socle se melangeait a la doc du projet, sans marqueur clair de propriete.

Avec v1.30, le `docs/` du projet n'est jamais touche par le socle.

## Migration automatique (recommande)

```bash
cd /chemin/vers/votre/projet
/chemin/vers/claude-socle/scripts/update.sh --upgrade-claude-md .
```

Le script :

1. Cree un backup `CLAUDE.md.backup.AAAAMMJJ_HHMMSS`
2. Deplace `docs/reference/` → `.claude/docs/reference/`
3. Deplace `docs/guides/` → `.claude/docs/guides/` (preserve les fichiers modifies localement)
4. Reecrit les `@imports` dans `CLAUDE.md` : `@docs/reference/X` → `@.claude/docs/reference/X`
5. Avertit (sans supprimer) si `docs/ARCHITECTURE.md` ou `docs/WORKFLOWS.md` existent — ils peuvent etre a vous, a vous de decider

**Idempotent** : executable plusieurs fois sans casser. Si rien a migrer, no-op silencieux.

## Migration manuelle (si vous preferez tout verifier)

### 1. Identifier l'etat initial

```bash
cd /votre/projet
ls docs/reference/                    # legacy : doit lister les fichiers du socle
grep '^@docs/reference/' CLAUDE.md    # legacy : doit retourner des @imports
```

Si rien ne sort, vous etes deja sur le nouveau layout — rien a faire.

### 2. Backup

```bash
cp CLAUDE.md CLAUDE.md.backup.$(date +%Y%m%d_%H%M%S)
```

### 3. Deplacer les dossiers

```bash
mkdir -p .claude/docs
[ -d docs/reference ] && mv docs/reference .claude/docs/reference
[ -d docs/guides ]    && mv docs/guides    .claude/docs/guides
```

### 4. Reecrire les `@imports` et tables dans `CLAUDE.md`

```bash
sed -i \
  -e 's|^@docs/reference/|@.claude/docs/reference/|g' \
  -e 's|`docs/reference/|`.claude/docs/reference/|g' \
  -e 's|`docs/guides/|`.claude/docs/guides/|g' \
  -e '/| Architecture |.*`docs\/ARCHITECTURE\.md`/d' \
  -e '/| Workflows visuels |.*`docs\/WORKFLOWS\.md`/d' \
  CLAUDE.md
```

### 5. Inspecter `docs/ARCHITECTURE.md` et `docs/WORKFLOWS.md` s'ils existent

Si ces fichiers viennent d'une **install anterieure du socle** (pre-v1.30), vous pouvez les supprimer — ils sont obsoletes cote socle (accessibles via le website Docusaurus).

Si ce sont **vos propres fichiers** (vous documentez votre projet), gardez-les. Le socle ne les touchera plus.

```bash
# Pour confirmer la provenance, comparez le debut du fichier :
head -3 docs/ARCHITECTURE.md
# Si "# Architecture du Socle Claude Code" → c'est l'ancienne copie socle, supprimable
# Si "# My Project Architecture" ou autre titre metier → c'est a vous, garder
```

### 6. Verifier la coherence

```bash
# Plus aucun @import legacy
! grep -qE '^@docs/reference/' CLAUDE.md && echo "OK"

# La doc socle est en place
[ -d .claude/docs/reference ] && echo "OK reference"
[ -d .claude/docs/guides ]    && echo "OK guides"

# Le dossier docs/ ne contient plus de fichiers socle
ls docs/reference 2>&1 | grep -q "No such" && echo "OK no legacy reference"
```

### 7. Tester avec Claude Code

Dans le projet, lancez Claude Code et demandez-lui de lire un guide pour verifier que les chemins fonctionnent :

```
> Lis .claude/docs/guides/learning-path.md
```

Si Claude le lit sans erreur, la migration est reussie.

## Cas particuliers

### J'ai personnalise un guide (`docs/guides/WEB-GUIDE.md` modifie)

`update.sh --upgrade-claude-md` preserve votre version : votre fichier modifie est deplace tel quel sous `.claude/docs/guides/WEB-GUIDE.md`. Les autres guides (non modifies) sont mis a jour avec la version socle courante.

### `.claude/` est dans mon `.gitignore`

Aucun probleme cote fonctionnel — Claude Code lit toujours `.claude/docs/` correctement. La doc socle n'est juste pas versionnee. Si vous voulez la versionner, retirez `.claude/` de `.gitignore` ou ajoutez une exception : `!.claude/docs/`.

### Mon CLAUDE.md a des `@imports` que vous ne reconnaissez pas

Le rewrite ne touche que les patterns connus (`@docs/reference/X` et table cells `` `docs/reference/X` ``, `` `docs/guides/X` ``). Vos `@imports` personnalises sont preserves.

## Rollback

Si quelque chose casse :

```bash
# Restaurer le CLAUDE.md depuis backup
cp CLAUDE.md.backup.AAAAMMJJ_HHMMSS CLAUDE.md

# Restaurer l'ancien layout
mv .claude/docs/reference docs/reference
mv .claude/docs/guides    docs/guides
rmdir .claude/docs
```

Et restez sur la version pre-1.30 du socle pour le moment :

```bash
cd /chemin/vers/claude-socle
git checkout v1.29.0
```

Signalez le probleme via une issue GitHub : <https://github.com/christopherlouet/claude-socle/issues>
