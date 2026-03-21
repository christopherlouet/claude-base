# Tâches : Modularisation de new-project.sh

**Plan**: `specs/modularize-new-project/plan.md`

---

## Phase 0 — Snapshot de référence [EF-02]

- [ ] **T001** [EF-02] — Créer un snapshot de référence : lancer `scripts/new-project.sh --simple` sur un dossier temp, sauvegarder l'arborescence générée pour comparaison après refactoring
  - Commande: `mkdir /tmp/socle-snapshot-before && ./scripts/new-project.sh --simple /tmp/socle-snapshot-before`
  - Garder le résultat pour T016

- [ ] **T002** [EF-02] — Identifier les variables globales utilisées par les fonctions detect_* et generate_smart_claude_md : grep des variables définies hors fonctions et lues dans les fonctions à extraire
  - Fichier: `scripts/new-project.sh` L28-95 (variables globales)
  - Livrable: liste des variables à documenter dans chaque module

## Phase 1 — Extraire detection.sh [US1]

- [ ] **T003** [US1] — Créer `scripts/lib/detection.sh` avec le guard common.sh et extraire les 11 fonctions de détection
  - Source: `scripts/new-project.sh` L282-731
  - Cible: `scripts/lib/detection.sh` (CRÉER, ~400 lignes)
  - Fonctions: `detect_nodejs`, `detect_python`, `detect_go`, `detect_rust`, `detect_java`, `detect_flutter`, `detect_neovim`, `detect_database`, `detect_cicd`, `detect_folder_structure`, `detect_stack`
  - Inclure aussi: `extract_npm_scripts` (L669-686), `extract_main_dependencies` (L687-701), `extract_python_dependencies` (L702-709)

- [ ] **T004** [US1] — Modifier `scripts/new-project.sh` : remplacer les fonctions extraites par `source "$SCRIPT_DIR/lib/detection.sh"`
  - Fichier: `scripts/new-project.sh`
  - Supprimer L282-731 (fonctions detect_* et extract_*)
  - Ajouter source après le source de common.sh

- [ ] **T005** [US1] — Ajouter `export -f` pour toutes les fonctions de detection.sh
  - Fichier: `scripts/lib/detection.sh` (fin de fichier)

- [ ] **T006** [US1] — Lancer les tests bats et vérifier 0 régression
  - Commande: `scripts/test.sh`
  - Attendu: 258/258 passent

- [ ] **T007** [US1] — ShellCheck sur detection.sh
  - Commande: `shellcheck scripts/lib/detection.sh`

## Phase 2 — Extraire generators.sh [US2]

- [ ] **T008** [US2] — Créer `scripts/lib/generators.sh` avec guard et extraire `generate_smart_claude_md()`
  - Source: `scripts/new-project.sh` L1259-1509
  - Cible: `scripts/lib/generators.sh` (CRÉER, ~270 lignes)
  - Note: dépend de detection.sh (appelle `detect_stack`), s'assurer que detection.sh est sourcé avant

- [ ] **T009** [US2] — Modifier `scripts/new-project.sh` : remplacer la fonction par `source "$SCRIPT_DIR/lib/generators.sh"`
  - Fichier: `scripts/new-project.sh`
  - Supprimer L1259-1509
  - Ajouter source après detection.sh

- [ ] **T010** [US2] — Lancer les tests bats + ShellCheck
  - Commande: `scripts/test.sh && shellcheck scripts/lib/generators.sh`

## Phase 3 — Factoriser clean_claude_dirs [US3]

- [ ] **T011** [US3] — Déplacer `clean_claude_dirs()` dans `scripts/lib/common.sh`
  - Source: `scripts/new-project.sh` L1833-1854
  - Cible: `scripts/lib/common.sh` (ajouter avant la section "Gestion des erreurs")
  - Ajouter à la ligne `export -f`

- [ ] **T012** [US3] — Supprimer `clean_claude_dirs()` de `scripts/new-project.sh` L1833-1854
  - Fichier: `scripts/new-project.sh`

- [ ] **T013** [US3] — Supprimer `clean_claude_dirs()` de `scripts/update.sh` L1058-1077
  - Fichier: `scripts/update.sh`

- [ ] **T014** [US3] — Lancer les tests bats pour les deux scripts
  - Commande: `scripts/test.sh`

## Phase 4 — Extraire docker.sh [US4] (P3, bonus)

- [ ] **T015** [P] [US4] — Créer `scripts/lib/docker.sh` et extraire `create_dockerfile()`
  - Source: `scripts/new-project.sh` L1979-2152
  - Cible: `scripts/lib/docker.sh` (CRÉER, ~190 lignes)

## Phase 5 — Vérification finale

- [ ] **T016** [EF-02] — Snapshot après : lancer `new-project.sh --simple` sur un nouveau dossier temp et diff avec le snapshot T001
  - Commande: `mkdir /tmp/socle-snapshot-after && ./scripts/new-project.sh --simple /tmp/socle-snapshot-after && diff -r /tmp/socle-snapshot-before /tmp/socle-snapshot-after`
  - Attendu: diff vide

- [ ] **T017** [EF-05] — Vérifier la réduction de taille
  - Commande: `wc -l scripts/new-project.sh`
  - Attendu: ≤ 1500 lignes

- [ ] **T018** [EF-03] — Tests complets finaux
  - Commande: `scripts/test.sh`
  - Attendu: 258/258

- [ ] **T019** [EF-04] — ShellCheck sur tous les nouveaux modules
  - Commande: `shellcheck scripts/lib/detection.sh scripts/lib/generators.sh scripts/lib/docker.sh`

- [ ] **T020** — Lancer `scripts/validate.sh` pour cohérence globale
  - Attendu: 84%+ score

---

## Résumé

| Phase | Tâches | US | Lignes extraites |
|-------|--------|----|------------------|
| 0 (Snapshot) | T001-T002 | EF-02 | 0 |
| 1 (Detection) | T003-T007 | US1 | ~450 |
| 2 (Generators) | T008-T010 | US2 | ~250 |
| 3 (Duplication) | T011-T014 | US3 | ~44 |
| 4 (Docker) | T015 | US4 | ~174 |
| 5 (Vérification) | T016-T020 | — | 0 |

**Total**: 20 tâches, complexité Complexe, 3 fichiers créés + 3 modifiés.
**Réduction estimée**: 2342 → ~1450 lignes (-38%).
