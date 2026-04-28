# Tâches : Migration des docs socle vers `.claude/docs/`

**Input** : `specs/docs-under-claude/spec.md` + `specs/docs-under-claude/plan.md`
**Prérequis** : Spec validée (décisions A + 2B confirmées), branche dédiée créée

---

## Format

`[ID] [P?] [US?] Description (chemin exact)`

- **[P]** : parallélisable (fichiers différents, pas de dépendances)
- **[US1/US2/US3]** : traçabilité user story
- Lancer `bats tests/update.bats` après chaque sous-bloc d'implémentation

---

## Phase 1 — Fondation (bloquant)

- [ ] T001 — Renommer la branche : `/git-rename feat/docs-under-claude` (depuis `feature/auto-20260424-111548`)
- [ ] T002 — Lire `tests/update.bats` lignes 264-381 et `tests/smoke.bats` ligne 302 pour bien identifier les fixtures à adapter
- [ ] T003 — Créer fixture bats : projet legacy minimal (`docs/reference/best-practices.md` + `CLAUDE.md` avec `@docs/reference/best-practices.md`) à `tests/fixtures/legacy-docs-layout/`

**Checkpoint** : Contexte de tests assimilé, fixture legacy prête.

---

## Phase 2 — US1 : Install simple vers `.claude/docs/` (P1) 🎯 MVP

**Objectif** : `new-project.sh --simple` installe la doc sous `.claude/docs/`, retire ARCHITECTURE/WORKFLOWS.

**Test indépendant** : `new-project.sh --simple ./tmp-test` → `.claude/docs/reference/` créé, `docs/` du projet intact, CLAUDE.md référence `@.claude/docs/...`.

### Tests US1 (TDD — écrire AVANT l'implémentation)

- [ ] T004 — [P] [US1] Test bats `tests/update.bats` (nouveau cas) : `new-project.sh --simple` crée `.claude/docs/reference/` avec ≥ 7 fichiers .md
- [ ] T005 — [P] [US1] Test bats : après install, `docs/reference/`, `docs/ARCHITECTURE.md` (du socle), `docs/WORKFLOWS.md` n'existent PAS dans la cible
- [ ] T006 — [P] [US1] Test bats : `CLAUDE.md` cible contient `@.claude/docs/reference/best-practices.md` et `@.claude/docs/reference/project-structures.md`
- [ ] T007 — [P] [US1] Test bats : un `docs/ARCHITECTURE.md` user pré-existant (avec contenu spécifique) reste byte-identique après install (cas pve-home)
- [ ] T008 — [US1] Vérifier que les tests T004-T007 ÉCHOUENT (état actuel attendu)

### Implémentation US1

- [ ] T009 — [US1] Modifier `scripts/new-project.sh` lignes 596-607 : changer destinations `$target_dir/docs/reference` → `$target_dir/.claude/docs/reference`
- [ ] T010 — [US1] Modifier `scripts/new-project.sh` lignes 619-628 : changer destinations `$target_dir/docs/guides` → `$target_dir/.claude/docs/guides`
- [ ] T011 — [US1] Modifier `scripts/new-project.sh` lignes 608-617 : **supprimer** la boucle qui copie `ARCHITECTURE.md` et `WORKFLOWS.md`
- [ ] T012 — [US1] Mettre à jour les messages "Fichiers installés" `scripts/new-project.sh` lignes 767-768 : `.claude/docs/reference/`, `.claude/docs/guides/`
- [ ] T013 — [US1] Mettre à jour le hint final `scripts/new-project.sh` ligne 814 : `.claude/docs/guides/learning-path.md`
- [ ] T014 — [US1] Identifier comment `CLAUDE.md` est copié à l'install (cp direct depuis `$SOCLE_DIR/CLAUDE.md` ?). Si oui, créer **`scripts/lib/claude-md.template`** (copie de CLAUDE.md repo socle avec chemins remappés `@.claude/docs/...`) et utiliser ce template au lieu du CLAUDE.md du repo socle. **Décision à valider pendant l'implémentation** : option (a) template séparé vs (b) sed post-copy. Préférer (a) pour la lisibilité.
- [ ] T015 — [US1] Vérifier que tests T004-T007 PASSENT après implémentation
- [ ] T016 — [US1] Smoke manuel : `./scripts/new-project.sh --simple /tmp/test-docs-under-claude` puis `tree -L 3 /tmp/test-docs-under-claude/.claude/docs/` et `ls /tmp/test-docs-under-claude/docs/ 2>&1` (attendu : "No such file or directory" ou pré-existant intact)

**Checkpoint** : US1 fonctionnelle. Install simple ne pollue plus `docs/`. Commit US1 avant US2.

---

## Phase 3 — US2 : Update + migration legacy (P2)

**Objectif** : `update.sh` détecte les installs legacy (`docs/reference/`) et migre automatiquement.

**Test indépendant** : projet avec `docs/reference/` + `@docs/reference/...` dans CLAUDE.md → après `update.sh`, `docs/reference/` n'existe plus, `.claude/docs/reference/` existe, CLAUDE.md a `@.claude/docs/reference/...`.

### Tests US2 (TDD)

- [ ] T017 — [P] [US2] Test bats : projet legacy → `update.sh` déplace `docs/reference/` → `.claude/docs/reference/`, supprime ancien
- [ ] T018 — [P] [US2] Test bats : `update.sh` réécrit dans CLAUDE.md tous les `@docs/reference/X` → `@.claude/docs/reference/X`
- [ ] T019 — [P] [US2] Test bats : `docs/guides/WEB-GUIDE.md` modifié localement (diff vs socle) → préservé byte-identique sous `.claude/docs/guides/WEB-GUIDE.md`, ancien supprimé
- [ ] T020 — [P] [US2] Test bats : projet vierge (pas de `docs/reference/`, pas de `.claude/docs/`) → install propre directement sous `.claude/docs/`, pas de tentative de migration
- [ ] T021 — [P] [US2] Test bats : `docs/ARCHITECTURE.md` legacy (issu d'install antérieure du socle) détecté → message d'info, fichier non supprimé automatiquement
- [ ] T022 — [P] [US2] Test bats : backup auto avant migration (`backup_*` directory créé)
- [ ] T023 — [US2] Vérifier que T017-T022 ÉCHOUENT (état actuel)

### Implémentation US2

- [ ] T024 — [US2] Créer fonction `migrate_legacy_docs()` dans `scripts/update.sh` (avant la copie principale) :
  - Détecter `$TARGET_DIR/docs/reference/` ET CLAUDE.md contenant `@docs/reference/`
  - Si détecté : déplacer (`mv`) vers `$TARGET_DIR/.claude/docs/reference/` ; supprimer ancien dossier
  - Idem pour `$TARGET_DIR/docs/guides/`
  - Logger les actions (warning/info/success)
- [ ] T025 — [US2] Modifier `scripts/update.sh` lignes 764-790 : destinations `$TARGET_DIR/.claude/docs/reference` au lieu de `$TARGET_DIR/docs/reference`
- [ ] T026 — [US2] Modifier `scripts/update.sh` lignes 802-826 (copie guides) : destinations `$TARGET_DIR/.claude/docs/guides`. **Préserver** la logique « ne pas réécrire les guides existants » côté `.claude/docs/guides/`.
- [ ] T027 — [US2] Modifier `scripts/update.sh` lignes 791-800 : retirer la copie de `ARCHITECTURE.md`/`WORKFLOWS.md` ; ajouter à la place une détection-info pour les fichiers legacy (`docs/ARCHITECTURE.md` socle-issu) avec message « ce fichier n'est plus géré par le socle, à supprimer manuellement si non personnalisé »
- [ ] T028 — [US2] Modifier la liste `all_imports` (lignes 835-841) : préfixer chaque entrée par `@.claude/docs/reference/` au lieu de `@docs/reference/`
- [ ] T029 — [US2] Ajouter logique sed/awk dans `upgrade_claude_md()` qui réécrit les `@docs/reference/...` existants en `@.claude/docs/reference/...` (idempotent)
- [ ] T030 — [US2] Mettre à jour le help (`scripts/update.sh` ligne 121) : « `--upgrade-claude-md` Migrer CLAUDE.md vers @imports (copie .claude/docs/reference/) »
- [ ] T031 — [US2] Vérifier que T017-T022 PASSENT
- [ ] T032 — [US2] Smoke manuel sur fixture legacy : créer projet avec `docs/reference/` + CLAUDE.md legacy → `./scripts/update.sh ./fixture-legacy` → vérifier état final

**Checkpoint** : US2 fonctionnelle. Migration legacy fluide. Commit US2.

---

## Phase 4 — US3 : Mode minimal aligné (P3)

**Objectif** : `--minimal` cohérent avec `--simple`.

**Test indépendant** : `new-project.sh --minimal /tmp/test` crée `.claude/docs/reference/best-practices.md`, `.claude/docs/reference/project-structures.md`, `.claude/docs/guides/learning-path.md` ; CLAUDE.md référence `.claude/docs/...`.

### Tests US3 (TDD)

- [ ] T033 — [P] [US3] Test bats : `new-project.sh --minimal` crée les 3 fichiers attendus sous `.claude/docs/...`
- [ ] T034 — [P] [US3] Test bats : CLAUDE.md minimal contient `@.claude/docs/reference/best-practices.md` et `@.claude/docs/reference/project-structures.md`
- [ ] T035 — [US3] Vérifier que T033-T034 ÉCHOUENT

### Implémentation US3

- [ ] T036 — [US3] Modifier `scripts/lib/minimal-manifest.txt` lignes 53-55 :
  - `docs/reference/best-practices.md:.claude/docs/reference/best-practices.md`
  - `docs/reference/project-structures.md:.claude/docs/reference/project-structures.md`
  - `website/docs/guides/learning-path.md:.claude/docs/guides/learning-path.md`
- [ ] T037 — [US3] Modifier `scripts/lib/minimal-claude-md.template` :
  - Lignes 6-7 : `@.claude/docs/reference/best-practices.md`, `@.claude/docs/reference/project-structures.md`
  - Ligne 11 : « Lis d'abord **`.claude/docs/guides/learning-path.md`**... »
  - Lignes 66-68 : tables de référence avec `.claude/docs/...`
- [ ] T038 — [US3] Vérifier `scripts/export-minimal.sh` : si génère une archive .zip/.tar, vérifier qu'elle reflète les nouveaux chemins
- [ ] T039 — [US3] Vérifier que T033-T034 PASSENT
- [ ] T040 — [US3] Smoke manuel : `./scripts/new-project.sh --minimal /tmp/test-minimal` → `tree -L 4 /tmp/test-minimal`

**Checkpoint** : US3 fonctionnelle. Toutes US livrées indépendamment. Commit US3.

---

## Phase 5 — Polish & Documentation

- [ ] T041 — [P] Bumper `VERSION` : `1.29.0` → `1.30.0`
- [ ] T042 — [P] Mettre à jour `CHANGELOG.md` section v1.30.0 :
  - **BREAKING CHANGE** : « Install/update placent désormais la doc socle sous `.claude/docs/` (au lieu de `docs/`). Migration automatique via `update.sh`. `ARCHITECTURE.md` et `WORKFLOWS.md` ne sont plus copiés chez l'utilisateur. »
  - Lien vers `docs/MIGRATION-v1.30.md`
- [ ] T043 — [P] Créer `docs/MIGRATION-v1.30.md` (guide migration manuel) :
  - Pourquoi ce changement
  - Migration auto via `update.sh`
  - Migration manuelle pour ceux qui préfèrent
  - Comment vérifier
- [ ] T044 — [P] Mettre à jour `docs/CHEATSHEET.md` si elle mentionne `docs/reference/` côté projet user
- [ ] T045 — [P] Mettre à jour `website/docs/intro/installation.md` si elle décrit le layout post-install (côté user)
- [ ] T046 — Audit final regex : `grep -rn "docs/reference\|docs/guides\|docs/ARCHITECTURE\|docs/WORKFLOWS" scripts/ tests/ docs/MIGRATION-v1.30.md` — confirmer qu'il ne reste que des références au repo socle local (pas au projet user)
- [ ] T047 — `shellcheck scripts/new-project.sh scripts/update.sh` propre
- [ ] T048 — `bats tests/` complet passe
- [ ] T049 — Smoke end-to-end sur projet réel (pve-home en local) : install fresh sur clone vierge + update sur install legacy
- [ ] T050 — `/qa:qa-loop "score 90"` sur le diff cumulé
- [ ] T051 — `/work:work-pr` : créer la PR avec titre `feat(install)!: relocate socle docs to .claude/docs/ (v1.30.0)` et description complète + breaking note + migration steps

**Checkpoint final** : PR prête, tests verts, version bumpée, doc migration disponible.

---

## Dépendances et Ordre d'Exécution

```
Phase 1 (Fondation)  ◄── T001-T003
   │
   ▼
Phase 2 (US1)        ◄── MVP, débloque US2 et US3
   │  T004-T016
   │
   ├──▶ Phase 3 (US2)  ◄── T017-T032
   │
   └──▶ Phase 4 (US3)  ◄── T033-T040

Phases 2/3/4 ──▶ Phase 5 (Polish)  ◄── T041-T051
```

### Dépendances entre user stories

| Story | Peut commencer après | Dépendances dures |
|-------|---------------------|-------------------|
| US1 (P1) | Phase 1 | Aucune |
| US2 (P2) | US1 (réutilise destinations `.claude/docs/`) | Code US1 stable |
| US3 (P3) | US1 (réutilise template logic) | Code US1 stable |

US2 et US3 peuvent être faites en parallèle après US1.

### Tâches parallèles

- **Tests TDD d'une même US** : T004-T007 (US1), T017-T022 (US2), T033-T034 (US3) — tous parallélisables
- **Phase Polish** : T041-T045 parallèles, puis T046-T051 séquentiels

---

## Stratégie d'implémentation

### MVP first

1. Phase 1 (fondation) → 30 min
2. Phase 2 (US1) → 2h (TDD : tests d'abord, puis impl, puis commit)
3. **STOP & VALIDER** : install simple OK, pas de pollution `docs/`. Si OK, on continue.
4. Phase 3 (US2) → 2-3h (cas legacy plus délicat)
5. Phase 4 (US3) → 1h
6. Phase 5 (Polish) → 1h
7. PR review

**Total estimé** : ~6-8h de travail focalisé.

### Livraison incrémentale

Possible : merger après US1 + US3 même si US2 (migration legacy) prend plus de temps. Mais risque de fragmenter le breaking change. **Préférable : un seul PR cohérent** pour ne pas exposer un état intermédiaire (install simple OK mais update cassé).

---

## Notes

- **Branche** : `feat/docs-under-claude` après `/git-rename`
- **PR title** : `feat(install)!: relocate socle docs to .claude/docs/ (v1.30.0)` (le `!` signale le breaking change)
- **Commit strategy** : un commit par phase (US1, US2, US3, Polish) pour garder un historique lisible
- **Garder en tête** : `socle-maintenance.md` rule parle du **repo socle**, ne pas la modifier
- **Coordination** : si `specs/docs-website-consolidation/` finalise pendant cette implémentation, vérifier que le sync website continue de lire `docs/` (source socle)

---

**Version** : 1.0 | **Créé** : 2026-04-28
