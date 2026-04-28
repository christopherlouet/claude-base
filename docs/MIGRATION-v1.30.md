# Guide de migration v1.30 — relocalisation de la doc socle vers `.claude/docs/`

> **Concerne uniquement les projets utilisateurs** ayant installé une version pré-v1.30 du socle.
> Le repo socle lui-même n'est pas concerné (il garde `docs/` comme source de vérité interne).

---

## Pourquoi cette migration

À partir de v1.30, la documentation du socle (`reference/`, `guides/`) est installée sous `.claude/docs/` au lieu de `docs/`. Deux problèmes de l'ancien comportement :

1. **Collisions** — un projet d'infra avec son propre `docs/ARCHITECTURE.md` (schéma Mermaid, par exemple) le voyait écrasé à chaque install/update.
2. **Pollution** — la doc du socle se mélangeait à la doc du projet, sans marqueur clair de propriété.

Avec v1.30, le `docs/` du projet n'est jamais touché par le socle.

---

## Migration automatique (recommandé)

```bash
cd /chemin/vers/votre/projet
/chemin/vers/claude-socle/scripts/update.sh --upgrade-claude-md .
```

Le script :
1. Crée un backup `CLAUDE.md.backup.AAAAMMJJ_HHMMSS`
2. Déplace `docs/reference/` → `.claude/docs/reference/`
3. Déplace `docs/guides/` → `.claude/docs/guides/` (préserve les fichiers modifiés localement par l'utilisateur)
4. Réécrit les `@imports` dans `CLAUDE.md` : `@docs/reference/X` → `@.claude/docs/reference/X`
5. Avertit (sans supprimer) si `docs/ARCHITECTURE.md` ou `docs/WORKFLOWS.md` existent — ils peuvent être à vous, à vous de décider

**Idempotent** : exécutable plusieurs fois sans casser. Si rien à migrer, no-op silencieux.

---

## Migration manuelle (si vous préférez tout vérifier)

### 1. Identifier l'état initial

```bash
cd /votre/projet
ls docs/reference/         # legacy : doit lister les fichiers du socle
grep '^@docs/reference/' CLAUDE.md  # legacy : doit retourner des @imports
```

Si rien ne sort, vous êtes déjà sur le nouveau layout — rien à faire.

### 2. Backup

```bash
cp CLAUDE.md CLAUDE.md.backup.$(date +%Y%m%d_%H%M%S)
```

### 3. Déplacer les dossiers

```bash
mkdir -p .claude/docs
[ -d docs/reference ] && mv docs/reference .claude/docs/reference
[ -d docs/guides ]    && mv docs/guides    .claude/docs/guides
```

### 4. Réécrire les `@imports` et tables dans `CLAUDE.md`

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

Si ces fichiers viennent d'une **install antérieure du socle** (pre-v1.30), vous pouvez les supprimer — ils sont obsolètes côté socle (accessibles via le website Docusaurus).

Si ce sont **vos propres fichiers** (vous documentez votre projet), gardez-les. Le socle ne les touchera plus.

```bash
# Pour confirmer la provenance, comparez le début du fichier :
head -3 docs/ARCHITECTURE.md
# Si "# Architecture du Socle Claude Code" → c'est l'ancienne copie socle, supprimable
# Si "# My Project Architecture" ou autre titre métier → c'est à vous, garder
```

### 6. Vérifier la cohérence

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

Dans le projet, lancez Claude Code et demandez-lui de lire un guide pour vérifier que les chemins fonctionnent :

```
> Lis .claude/docs/guides/learning-path.md
```

Si Claude le lit sans erreur, la migration est réussie.

---

## Cas particuliers

### J'ai personnalisé un guide (`docs/guides/WEB-GUIDE.md` modifié)

`update.sh --upgrade-claude-md` préserve votre version : votre fichier modifié est déplacé tel quel sous `.claude/docs/guides/WEB-GUIDE.md`. Les autres guides (non modifiés) sont mis à jour avec la version socle courante.

### `.claude/` est dans mon `.gitignore` (cas pve-home)

Aucun problème côté fonctionnel — Claude Code lit toujours `.claude/docs/` correctement. La doc socle n'est juste pas versionnée. Si vous voulez la versionner, retirez `.claude/` de `.gitignore` ou ajoutez une exception : `!.claude/docs/`.

### Mon CLAUDE.md a des `@imports` que vous ne reconnaissez pas

Le rewrite ne touche que les patterns connus (`@docs/reference/X` et table cells `` `docs/reference/X` ``, `` `docs/guides/X` ``). Vos `@imports` personnalisés sont préservés.

---

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

Et restez sur la version pré-1.30 du socle pour le moment :

```bash
cd /chemin/vers/claude-socle
git checkout v1.29.0
```

Signalez le problème via une issue GitHub : <https://github.com/christopherlouet/claude-socle/issues>

---

**Version** : 1.0 | **Créé** : 2026-04-28
