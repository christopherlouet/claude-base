# Spécification : Modularisation de new-project.sh

**Branche**: `feature/modularize-new-project`
**Date**: 2026-03-21
**Statut**: Ready

---

## Résumé

Le script `scripts/new-project.sh` fait 2342 lignes avec 49 fonctions. Sa complexité rend la maintenance difficile et empêche la réutilisation de fonctions utiles par d'autres scripts (doctor.sh, validate.sh, update.sh). L'objectif est d'extraire les groupes de fonctions autonomes dans des modules `scripts/lib/` sans changer le comportement du script.

---

## User Stories (prioritisées)

### US1 - Extraire la détection de stack technique (Priorité: P1) 🎯 MVP

**En tant que** mainteneur du socle
**Je veux** que les 10 fonctions de détection de stack soient dans un module réutilisable
**Afin de** les réutiliser dans doctor.sh, validate.sh et learn.sh

**Pourquoi P1**: 387 lignes de logique de détection (Node.js, Python, Go, Rust, Java, Flutter, Neovim, DB, CI/CD, stack) sont autonomes et réutilisables par 4+ scripts.

**Critères d'acceptation**:

1. **Étant donné** que `scripts/lib/detection.sh` existe, **Quand** je source ce fichier, **Alors** les 10 fonctions `detect_*` sont disponibles
2. **Étant donné** que new-project.sh source detection.sh, **Quand** je lance `./scripts/new-project.sh --simple .`, **Alors** le comportement est identique à avant
3. **Étant donné** un projet Node.js, **Quand** doctor.sh source detection.sh et appelle `detect_nodejs`, **Alors** il obtient les mêmes résultats que new-project.sh

---

### US2 - Extraire la génération CLAUDE.md (Priorité: P1) 🎯 MVP

**En tant que** mainteneur du socle
**Je veux** que la génération de CLAUDE.md soit dans un module séparé
**Afin de** pouvoir maintenir la plus grosse fonction (251 lignes) indépendamment

**Pourquoi P1**: `generate_smart_claude_md()` est la plus grande fonction du script. Son extraction facilite les tests et la maintenance.

**Critères d'acceptation**:

1. **Étant donné** que `scripts/lib/generators.sh` existe, **Quand** je source ce fichier, **Alors** `generate_smart_claude_md()` est disponible
2. **Étant donné** un projet détecté comme Node.js, **Quand** `generate_smart_claude_md` est appelée, **Alors** le CLAUDE.md généré est identique à avant

---

### US3 - Éliminer la duplication avec update.sh (Priorité: P2)

**En tant que** mainteneur du socle
**Je veux** que les fonctions dupliquées entre new-project.sh et update.sh soient factorisées
**Afin de** ne plus corriger les mêmes bugs à deux endroits

**Pourquoi P2**: `clean_claude_dirs()` est dupliquée (44 lignes identiques). `parse_args()` partage la même structure.

**Critères d'acceptation**:

1. **Étant donné** que `clean_claude_dirs()` est dans common.sh, **Quand** new-project.sh et update.sh l'appellent, **Alors** le comportement est identique
2. **Étant donné** que les 258 tests existants passent, **Quand** je lance `scripts/test.sh`, **Alors** 0 régression

---

### US4 - Extraire les templates Docker/CI (Priorité: P3)

**En tant que** mainteneur du socle
**Je veux** que les générateurs de Dockerfile et CI/CD soient dans des modules séparés
**Afin de** faciliter l'ajout de nouveaux templates

**Critères d'acceptation**:

1. **Étant donné** que `scripts/lib/docker.sh` existe, **Quand** `create_dockerfile()` est appelée, **Alors** le Dockerfile généré est identique à avant
2. **Étant donné** que `scripts/lib/cicd.sh` existe, **Quand** les fonctions CI/CD sont appelées, **Alors** les workflows générés sont identiques

---

## Exigences Fonctionnelles

| ID | Exigence | Vérification |
|----|----------|--------------|
| EF-01 | Chaque module `scripts/lib/*.sh` est sourceable indépendamment | `source scripts/lib/detection.sh` ne crash pas |
| EF-02 | new-project.sh produit un résultat identique avant/après modularisation | Snapshot test : lancer `--simple` sur dossier temp avant/après, diff = 0. Ajouter comme test bats. |
| EF-03 | Les 258 tests bats passent sans modification | `scripts/test.sh` OK |
| EF-04 | ShellCheck passe sur tous les nouveaux modules | `shellcheck scripts/lib/*.sh` OK |
| EF-05 | new-project.sh passe de ~2342 à ~1500 lignes max | `wc -l` ≤ 1500 |

---

## Cas Limites

| Cas | Comportement attendu |
|-----|---------------------|
| Module sourcé sans common.sh | Erreur explicite "common.sh must be sourced first" |
| Fonction extraite appelée avec args manquants | Même erreur qu'avant extraction |
| Script exécuté sur Bash 3.x | Même erreur qu'avant (check_base_requirements) |

---

## Critères de Succès

| ID | Critère | Mesure |
|----|---------|--------|
| CS-01 | 0 régression dans les tests | 258/258 tests passent |
| CS-02 | new-project.sh ≤ 1500 lignes | `wc -l` |
| CS-03 | Duplication éliminée | `clean_claude_dirs` dans 1 seul fichier |
| CS-04 | Modules réutilisables | Au moins 1 autre script source detection.sh |

---

## Hors Scope

- Refonte fonctionnelle de new-project.sh (on ne change que la structure)
- Ajout de nouveaux détecteurs de stack
- Modification du comportement de update.sh
- Réécriture en Python ou autre langage

---

## Points de Clarification

Tous résolus :
1. ~~Ordre d'implémentation?~~ → **Modularisation d'abord**, puis docs consolidation. Refactoring pur sans changement fonctionnel = plus sûr en premier.
2. ~~Stratégie de vérification avant/après?~~ → **Snapshot test** : lancer `new-project.sh --simple` sur un dossier temp avant et après refactoring, diff des fichiers générés. Ajouter comme test bats automatisé.

---

**Version**: 1.1 | **Créé par**: /work:work-specify | **Mis à jour**: 2026-03-21
