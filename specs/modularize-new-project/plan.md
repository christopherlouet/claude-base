# Plan d'implémentation : Modularisation de new-project.sh

**Spec**: `specs/modularize-new-project/spec.md`
**Date**: 2026-03-21
**Complexité globale**: Complexe (refactoring pur, 0 changement fonctionnel, 2342 lignes à réorganiser)

---

## Résumé

Extraire les groupes de fonctions autonomes de `scripts/new-project.sh` (2342 lignes, 49 fonctions) vers des modules dans `scripts/lib/`. Approche incrémentale : un module à la fois, tests après chaque extraction. Snapshot test avant/après pour garantir 0 régression.

---

## Contexte technique

### État actuel de scripts/lib/

| Fichier | Lignes | Rôle |
|---------|--------|------|
| `common.sh` | 653 | Logging, version, JSON, cache, file ops |

### Carte des fonctions à extraire (new-project.sh)

| Groupe | Fonctions | Lignes source | Lignes total | Module cible |
|--------|-----------|---------------|--------------|--------------|
| Détection | 11 fonctions (detect_*) | 282-731 | 383 | `lib/detection.sh` |
| Génération | generate_smart_claude_md | 1259-1509 | 251 | `lib/generators.sh` |
| Docker | create_dockerfile | 1979-2152 | 174 | `lib/docker.sh` |
| Installation | 8 fonctions (install_*, copy_*) | 936-1162 | 159 | _(reste dans new-project.sh)_ |
| CI/CD | 4 fonctions | 829-935 | 112 | _(reste dans new-project.sh)_ |
| Cleanup | clean_claude_dirs | 1833-1854 | 22 | `lib/common.sh` (dédup) |

### Réduction estimée

| Métrique | Avant | Après |
|----------|-------|-------|
| new-project.sh | 2342 lignes | ~1500 lignes |
| Modules lib/ | 1 (common.sh) | 4 (common, detection, generators, docker) |
| Duplication clean_claude_dirs | 2 copies | 1 (common.sh) |

---

## Fichiers impactés

| Fichier | Action | US |
|---------|--------|-----|
| `scripts/lib/detection.sh` | CRÉER | US1 |
| `scripts/lib/generators.sh` | CRÉER | US2 |
| `scripts/lib/docker.sh` | CRÉER | US4 (P3, bonus) |
| `scripts/lib/common.sh` | MODIFIER | US3 |
| `scripts/new-project.sh` | MODIFIER | US1, US2, US3, US4 |
| `scripts/update.sh` | MODIFIER | US3 |
| `tests/new-project.bats` | MODIFIER | EF-02 (snapshot test) |

---

## Stratégie d'extraction

Chaque module suit le même pattern :

```bash
#!/bin/bash
# Guard: common.sh must be sourced first
if ! declare -f info >/dev/null 2>&1; then
    echo "ERROR: common.sh must be sourced before $(basename "${BASH_SOURCE[0]}")" >&2
    exit 1
fi

# ... fonctions extraites ...

export -f function1 function2 ...
```

L'extraction est mécanique : couper les fonctions, coller dans le module, ajouter `source "$SCRIPT_DIR/lib/module.sh"` dans new-project.sh.

---

## Phases

### Phase 0 — Snapshot de référence [EF-02]

Créer le snapshot avant toute modification. C'est le filet de sécurité.

### Phase 1 — P1 : Extraire detection.sh [US1]

Le plus gros module (383 lignes, 11 fonctions). Aucune dépendance sur d'autres fonctions de new-project.sh — extraction propre.

### Phase 2 — P1 : Extraire generators.sh [US2]

La plus grosse fonction (251 lignes). Dépend de `detect_stack()` (dans detection.sh) — donc après Phase 1.

### Phase 3 — P2 : Factoriser clean_claude_dirs [US3]

Déplacer dans common.sh, mettre à jour new-project.sh et update.sh.

### Phase 4 — P3 : Extraire docker.sh [US4]

174 lignes, autonome. Bonus si le temps le permet.

### Phase 5 — Vérification finale

Tests bats + ShellCheck + snapshot diff + comptage lignes.

---

## Risques

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Variables globales partagées entre fonctions | Extraction casse l'accès aux variables | Identifier les variables globales utilisées par chaque groupe avant extraction |
| Ordre de sourcing des modules | Crash au démarrage | Source detection.sh avant generators.sh (dépendance) |
| Tests bats mockent des fonctions internes | Tests cassés si fonctions renommées/déplacées | Vérifier les mocks dans les tests avant de toucher aux fonctions |
| ShellCheck warnings sur les nouveaux modules | CI rouge | Ajouter les disable pragmas nécessaires |

---

## Vérification

```bash
# Phase 0 : Snapshot avant
mkdir /tmp/socle-before && scripts/new-project.sh --simple /tmp/socle-before

# Phase 5 : Snapshot après
mkdir /tmp/socle-after && scripts/new-project.sh --simple /tmp/socle-after

# Diff
diff -r /tmp/socle-before /tmp/socle-after  # Doit être vide

# Tests
scripts/test.sh                              # 258/258
shellcheck scripts/lib/detection.sh scripts/lib/generators.sh scripts/lib/docker.sh
wc -l scripts/new-project.sh                 # ≤ 1500
```
