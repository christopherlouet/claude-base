# Plan d'implémentation : Migration des docs socle vers `.claude/docs/`

**Branche** : `feat/docs-under-claude` (renommer `feature/auto-20260424-111548` via `/git-rename feat/docs-under-claude`)
**Date** : 2026-04-28
**Spec** : [spec.md](./spec.md)
**Statut** : Draft

---

## Résumé

Déplacer les destinations d'install de la doc socle de `docs/` vers `.claude/docs/` pour éviter les collisions avec la propre documentation de l'utilisateur (territoire `docs/`). Le repo socle conserve `docs/` comme source de vérité (option 2B « source duale, install remappe »). Les meta-docs `ARCHITECTURE.md` et `WORKFLOWS.md` ne sont plus copiées chez l'utilisateur (option A).

Périmètre :
- **`new-project.sh`** : sources inchangées (depuis `$SOCLE_DIR/docs/`), destinations passent à `.claude/docs/`, retrait de `ARCHITECTURE.md`/`WORKFLOWS.md`
- **`update.sh`** : pareil + détection layout legacy + migration auto
- **`CLAUDE.md` template + minimal template** : `@imports` pointent vers `@.claude/docs/...`
- **Manifest minimal** : destinations remappées
- **Tests** : `update.bats` adapté
- **CHANGELOG** : breaking change documenté, guide migration

---

## Contexte Technique

| Aspect | Choix | Notes |
|--------|-------|-------|
| **Langage** | Bash 4+ | scripts existants |
| **Tests** | bats-core | suites `update.bats`, `smoke.bats`, `tests/` |
| **Compatibilité** | Linux/macOS | Pas de Windows pour l'instant |
| **Versioning** | Semver | bump v1.29.0 → v1.30.0 (mineur, breaking change documenté) |

### Contraintes

- Pas de breaking change silencieux : `update.sh` doit migrer automatiquement les installs legacy.
- Les `.claude/docs/` doivent être versionnables (retirer `.claude/` du `.gitignore` ne nous concerne pas, mais les `@imports` doivent pointer vers des fichiers présents dans le repo si l'user les commit).
- La logique de préservation user existante (`update.sh` ne réécrit pas les guides modifiés localement) doit être maintenue pour `.claude/docs/guides/`.
- Le repo socle continue de fonctionner pour ses propres `@imports` (`@docs/reference/best-practices.md` reste valide en interne).

### Performance attendue

| Métrique | Cible |
|----------|-------|
| Durée install `--simple` | ≈ identique à aujourd'hui (pas de surcoût notable) |
| Durée update sur projet legacy | < 5s pour migration (lecture/copie/déplacement de ~25 fichiers + rewrite CLAUDE.md) |

---

## Vérification Constitution / Conventions

- [x] Respecte les conventions du projet (Bash, `lib/common.sh`, gestion d'erreurs `set -euo pipefail`)
- [x] Cohérent avec l'architecture existante (scripts `new-project.sh`, `update.sh`, `lib/`)
- [x] Pas d'over-engineering (pas de nouveau script, juste adaptation)
- [x] Tests planifiés (`update.bats`, `smoke.bats`)

---

## Structure du Projet

### Documentation (cette feature)

```
specs/docs-under-claude/
├── spec.md           # Spécification fonctionnelle (✓)
├── plan.md           # Ce fichier (✓)
└── tasks.md          # Découpage en tâches
```

### Code source impacté

```
scripts/
├── new-project.sh                   # Modifier : destinations → .claude/docs/
├── update.sh                        # Modifier : destinations + migration legacy
├── lib/
│   ├── minimal-claude-md.template   # Modifier : @imports → @.claude/docs/
│   └── minimal-manifest.txt         # Modifier : destinations remappées
└── generate-commands-doc.sh         # Inchangé (génère docs/reference/commands.md dans le repo socle)

CLAUDE.md (du repo socle)            # Inchangé (continue de référencer @docs/...)

.claude/rules/
└── socle-maintenance.md             # Inchangé (parle du repo socle, pas du projet user)

tests/
├── update.bats                      # Modifier : nouveaux chemins .claude/docs/, tests migration legacy
└── smoke.bats                       # Inchangé (vérifie source socle, pas destination)

CHANGELOG.md                         # Ajouter : breaking change v1.30.0 + guide migration
VERSION                              # Bump 1.29.0 → 1.30.0
```

---

## Fichiers Impactés

### À créer

| Fichier | Responsabilité |
|---------|----------------|
| `specs/docs-under-claude/spec.md` | Spécification (✓) |
| `specs/docs-under-claude/plan.md` | Plan (ce fichier ✓) |
| `specs/docs-under-claude/tasks.md` | Découpage en tâches |

### À modifier

| Fichier | Modification |
|---------|--------------|
| `scripts/new-project.sh` | Lignes 596-628 : destinations `$target_dir/docs/...` → `$target_dir/.claude/docs/...`. Retirer la copie de `ARCHITECTURE.md` et `WORKFLOWS.md`. Mettre à jour les messages "Fichiers installés" (ligne 767-768). |
| `scripts/update.sh` | Lignes 764-820 : idem. Ajouter fonction `migrate_legacy_docs()` qui détecte `docs/reference/` et déplace vers `.claude/docs/reference/`. Lignes 831-895 : adapter la liste `all_imports` et le rewrite des `@imports` dans CLAUDE.md. |
| `scripts/lib/minimal-claude-md.template` | Lignes 6-7 : `@docs/reference/` → `@.claude/docs/reference/`. Lignes 11, 66-68 : tables référencent `.claude/docs/...`. |
| `scripts/lib/minimal-manifest.txt` | Lignes 53-55 : remapper `docs/reference/...` → `.claude/docs/reference/...` et `docs/guides/learning-path.md` → `.claude/docs/guides/learning-path.md` (syntaxe SRC:DST). |
| `CLAUDE.md` (du socle) | **Inchangé** côté `@imports` (le repo socle conserve `docs/` localement). Vérifier qu'aucune table ne dépend du chemin générique. |
| `tests/update.bats` | Adapter les ~7 tests qui vérifient `$TEST_DIR/docs/reference/`. Ajouter 2-3 tests pour la migration legacy. |
| `tests/smoke.bats` | Vérifier ligne 302 (test sur `$SOCLE_DIR/docs/guides`) — reste valide car source socle. Ajouter test smoke `--simple` qui vérifie `.claude/docs/` créé. |
| `CHANGELOG.md` | Section v1.30.0 : « **BREAKING** : install/update placent désormais la doc sous `.claude/docs/` (au lieu de `docs/`). Migration automatique via `update.sh`. ». Lien vers `docs/MIGRATION-v1.30.md`. |
| `VERSION` | `1.29.0` → `1.30.0` |
| `docs/MIGRATION-v1.30.md` | **Nouveau** : guide de migration manuel pour utilisateurs qui veulent comprendre / migrer à la main. |

### Tests à ajouter

| Fichier | Couverture |
|---------|------------|
| `tests/update.bats` | (1) install simple → `.claude/docs/` créé ; (2) update legacy → migration `docs/reference/` → `.claude/docs/reference/` ; (3) `@imports` réécrits ; (4) guide modifié localement préservé ; (5) `ARCHITECTURE.md` user existant non touché |

---

## Approche Choisie

### Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│ REPO SOCLE (source de vérité)                                       │
│                                                                     │
│   docs/                                                             │
│   ├── reference/        ◄── source @import (auto-load CLAUDE.md)    │
│   ├── guides/           ◄── source guides spécialisés               │
│   ├── ARCHITECTURE.md   ◄── meta-doc (NE PAS copier)                │
│   ├── WORKFLOWS.md      ◄── meta-doc (NE PAS copier)                │
│   ├── CHEATSHEET.md     ◄── doc du repo socle                       │
│   └── ...                                                           │
│                                                                     │
│   .claude/                                                          │
│   ├── commands/                                                     │
│   ├── agents/                                                       │
│   ├── skills/                                                       │
│   ├── rules/                                                        │
│   └── (pas de docs/ ici dans le repo socle — convention 2B)         │
└────────────────────────┬────────────────────────────────────────────┘
                         │ scripts/new-project.sh --simple
                         │ scripts/update.sh
                         ▼
┌─────────────────────────────────────────────────────────────────────┐
│ PROJET UTILISATEUR (cible)                                          │
│                                                                     │
│   docs/                 ◄── territoire user (pve-home/docs/...)     │
│   └── (intact, jamais touché par le socle)                          │
│                                                                     │
│   .claude/                                                          │
│   ├── commands/   etc.                                              │
│   └── docs/             ◄── NOUVEAU : doc socle ici                 │
│       ├── reference/    ◄── @imports CLAUDE.md user                 │
│       └── guides/       ◄── guides à la demande                     │
│                                                                     │
│   CLAUDE.md             ◄── @imports = @.claude/docs/reference/...  │
└─────────────────────────────────────────────────────────────────────┘
```

### Justification

- **Cohérence conceptuelle** : tout ce qui appartient au socle vit sous `.claude/`. Pas de fuite dans `docs/` (territoire user).
- **Update plus simple** : un seul dossier à synchroniser (`.claude/docs/`).
- **Cycle de vie clair** : si l'user veut « tout virer », `rm -rf .claude/` suffit.
- **Pas de migration du repo socle** : la complexité reste minimale, le website Docusaurus continue de lire `docs/` source.
- **`ARCHITECTURE.md` / `WORKFLOWS.md` retirés** : meta-docs sur **comment fonctionne le socle**, pas pertinents dans le contexte d'un projet user. Accessibles via le website / GitHub.

### Alternatives considérées

| Alternative | Pourquoi rejetée |
|-------------|------------------|
| **Option 1 — ne plus rien copier** | Casse les `@imports` auto, perd la valeur des guides spécialisés |
| **Option 2A — migrer aussi le repo socle** | Effort considérable (website Docusaurus, sync, etc.) sans bénéfice direct pour le user |
| **Option 3 — préfixer `docs/socle-...`** | Moche, peu lisible, ne résout pas la pollution |

---

## Phases d'Implémentation

### Phase 1 : Fondation (bloquant)

**Objectif** : Mettre en place le squelette + tests prérequis

- [ ] T001 — Renommer la branche en `feat/docs-under-claude` (`/git-rename`)
- [ ] T002 — Lire et comprendre `tests/update.bats` lignes 264-381 (cas legacy à adapter)
- [ ] T003 — Décider de la convention exacte : `.claude/docs/` ou `.claude/reference/` ? Confirmer **`.claude/docs/`** dans la spec.

**Checkpoint** : Branche prête, contexte tests assimilé.

### Phase 2 : US1 — Install simple vers `.claude/docs/` (P1, MVP) 🎯

**Objectif** : `new-project.sh --simple` installe la doc sous `.claude/docs/`, retire ARCHITECTURE/WORKFLOWS, génère un CLAUDE.md avec `@imports` mis à jour.

#### Tests (TDD)

- [ ] T004 — [P] [US1] Test bats : `new-project.sh --simple` crée `.claude/docs/reference/` (5+ fichiers) — `tests/update.bats` ou nouveau `tests/install.bats`
- [ ] T005 — [P] [US1] Test bats : pas de `docs/reference/`, pas de `docs/ARCHITECTURE.md`, pas de `docs/WORKFLOWS.md` créés par l'install
- [ ] T006 — [P] [US1] Test bats : `CLAUDE.md` contient `@.claude/docs/reference/best-practices.md` et `@.claude/docs/reference/project-structures.md`
- [ ] T007 — [P] [US1] Test bats : un `docs/ARCHITECTURE.md` user existant n'est pas modifié par l'install

#### Implémentation

- [ ] T008 — [US1] Modifier `scripts/new-project.sh` lignes 596-628 : remplacer destinations `$target_dir/docs/...` → `$target_dir/.claude/docs/...`. Retirer le bloc `ARCHITECTURE.md` / `WORKFLOWS.md` (lignes 608-617).
- [ ] T009 — [US1] Mettre à jour le bloc CLAUDE.md template du socle (`CLAUDE.md` lui-même reste inchangé pour le repo socle, mais le **CLAUDE.md copié à l'install** doit être adapté). Vérifier comment c'est fait actuellement (cp direct ou template ?). Si cp direct, créer `scripts/lib/full-claude-md.template` ou patcher après copie via sed.
- [ ] T010 — [US1] Mettre à jour les messages "Fichiers installés" (lignes 767-768) : `.claude/docs/reference/`, `.claude/docs/guides/`
- [ ] T011 — [US1] Mettre à jour le hint final ligne 814 (« Lis `docs/guides/learning-path.md` » → `.claude/docs/guides/learning-path.md`)

**Checkpoint** : `new-project.sh --simple ./test-projet` crée bien `.claude/docs/...`, pas de pollution `docs/`, tests verts.

### Phase 3 : US2 — Update + migration legacy (P2)

**Objectif** : `update.sh` détecte les installs legacy (`docs/reference/` + `@docs/reference/...` dans CLAUDE.md) et migre automatiquement.

#### Tests (TDD)

- [ ] T012 — [P] [US2] Test bats : projet legacy avec `docs/reference/` → `update.sh` déplace vers `.claude/docs/reference/`, supprime ancien
- [ ] T013 — [P] [US2] Test bats : `CLAUDE.md` legacy avec `@docs/reference/...` → réécrit en `@.claude/docs/reference/...`
- [ ] T014 — [P] [US2] Test bats : `docs/guides/WEB-GUIDE.md` modifié localement → préservé sous `.claude/docs/guides/WEB-GUIDE.md`, ancien supprimé
- [ ] T015 — [P] [US2] Test bats : projet vierge (pas de `docs/reference/`) → install propre directement sous `.claude/docs/`
- [ ] T016 — [P] [US2] Test bats : `ARCHITECTURE.md`/`WORKFLOWS.md` user présents → message d'info, pas de suppression auto

#### Implémentation

- [ ] T017 — [US2] Créer fonction `migrate_legacy_docs()` dans `scripts/update.sh` : détecte `$TARGET_DIR/docs/reference/`, déplace vers `$TARGET_DIR/.claude/docs/reference/`, supprime ancien. Mêmes règles pour `docs/guides/`.
- [ ] T018 — [US2] Modifier `scripts/update.sh` lignes 764-820 : destinations `.claude/docs/...`. Préserver la logique de préservation des guides modifiés.
- [ ] T019 — [US2] Modifier la liste `all_imports` (lignes 835-841) : `@.claude/docs/reference/...`
- [ ] T020 — [US2] Ajouter détection des legacy `@docs/reference/` dans CLAUDE.md → réécriture sed vers `@.claude/docs/reference/`
- [ ] T021 — [US2] Ajouter message d'info pour `ARCHITECTURE.md`/`WORKFLOWS.md` détectés (suggest manual cleanup)
- [ ] T022 — [US2] Mettre à jour le help (ligne 121) : `--upgrade-claude-md` mentionne `.claude/docs/reference/`

**Checkpoint** : `update.sh ./projet-legacy` migre proprement sans perte de personnalisation.

### Phase 4 : US3 — Mode minimal aligné (P3)

**Objectif** : Mode `--minimal` cohérent avec le nouveau layout.

#### Tests (TDD)

- [ ] T023 — [P] [US3] Test bats : `new-project.sh --minimal .` crée `.claude/docs/reference/best-practices.md`, `.claude/docs/reference/project-structures.md`, `.claude/docs/guides/learning-path.md`
- [ ] T024 — [P] [US3] Test bats : CLAUDE.md minimal contient `@.claude/docs/reference/best-practices.md`

#### Implémentation

- [ ] T025 — [US3] Modifier `scripts/lib/minimal-manifest.txt` lignes 53-55 : remapper avec syntaxe SRC:DST
  - `docs/reference/best-practices.md:.claude/docs/reference/best-practices.md`
  - `docs/reference/project-structures.md:.claude/docs/reference/project-structures.md`
  - `website/docs/guides/learning-path.md:.claude/docs/guides/learning-path.md`
- [ ] T026 — [US3] Modifier `scripts/lib/minimal-claude-md.template` :
  - Lignes 6-7 : `@.claude/docs/reference/...`
  - Ligne 11 : `Lis d'abord **\`.claude/docs/guides/learning-path.md\`**...`
  - Lignes 66-68 : tables avec `.claude/docs/...`
- [ ] T027 — [US3] Vérifier `scripts/export-minimal.sh` : si génère une archive, s'assurer qu'elle est cohérente avec le manifest

**Checkpoint** : Mode minimal aligné avec `--simple`.

### Phase 5 : Polish & Qualité

- [ ] T028 — [P] Bump `VERSION` 1.29.0 → 1.30.0
- [ ] T029 — [P] Mettre à jour `CHANGELOG.md` : section v1.30.0 avec **BREAKING CHANGE** documenté + guide migration condensé
- [ ] T030 — [P] Créer `docs/MIGRATION-v1.30.md` : guide migration détaillé manuel (pour users qui veulent comprendre ou migrer sans `update.sh`)
- [ ] T031 — [P] Vérifier `tests/smoke.bats` : ajouter assertion `.claude/docs/` après `--simple` install
- [ ] T032 — Mettre à jour `docs/CHEATSHEET.md` si elle mentionne le chemin `docs/reference/` côté user
- [ ] T033 — Mettre à jour `website/docs/intro/installation.md` si elle décrit le layout post-install
- [ ] T034 — Audit final : `grep -rn "docs/reference\|docs/guides\|docs/ARCHITECTURE\|docs/WORKFLOWS" scripts/ tests/` pour traquer les références oubliées
- [ ] T035 — `/qa:qa-loop "score 90"` sur le diff final
- [ ] T036 — Tester end-to-end sur un repo de test : install fresh, update legacy, mode minimal
- [ ] T037 — `/work:work-pr` : créer la PR avec note breaking change visible

---

## Risques et Mitigations

| Risque | Impact | Probabilité | Mitigation |
|--------|--------|-------------|------------|
| Migration auto casse un projet user | Élevé | Moyenne | Backup auto avant migration (déjà fait par `update.sh`), dry-run par défaut sur tests |
| User a personnalisé un `docs/reference/*.md` | Moyen | Faible | Diff vs source socle : si différent, alerter et ne pas écraser silencieusement |
| Confusion entre `docs/` socle et `docs/` user | Moyen | Moyenne | Documentation claire dans MIGRATION-v1.30.md, message au début de l'install |
| `socle-maintenance.md` rule cassée | Faible | Faible | Audit explicite : confirmé qu'elle parle du repo socle, pas modifiée |
| Sync website (`docs-website-consolidation`) impacté | Faible | Faible | Hors scope : sync lit `docs/` source socle (inchangé), pas projet user |
| Tests `update.bats` flaky pendant la transition | Moyen | Élevée | Adapter les fixtures bats par étapes, lancer `bats tests/update.bats` après chaque sous-tâche |

---

## Dépendances et Ordre d'Exécution

### Dépendances entre phases

```
Phase 1 (Fondation)
   │
   ▼
Phase 2 (US1 — Install simple) ◄── MVP, débloque US2 et US3
   │
   ├──▶ Phase 3 (US2 — Update + migration legacy)
   │
   └──▶ Phase 4 (US3 — Mode minimal)

Phases 2/3/4 ──▶ Phase 5 (Polish)
```

### Tâches parallélisables

- T004-T007 (tests US1) parallèles entre eux
- T012-T016 (tests US2) parallèles entre eux
- T023-T024 (tests US3) parallèles entre eux
- T028-T031 (polish) parallèles
- US2 et US3 peuvent démarrer en parallèle après US1 terminée

---

## Critères de Validation

### Avant de commencer (Gate 1)

- [x] Spec approuvée (décisions A + 2B confirmées par user)
- [x] Plan reviewé (ce document)
- [x] Branche dédiée créée

### Avant chaque merge (Gate 2)

- [ ] `bats tests/` passe (update.bats + smoke.bats)
- [ ] `shellcheck scripts/*.sh` clean
- [ ] CHANGELOG mis à jour
- [ ] VERSION bumpée

### Avant déploiement (Gate 3)

- [ ] Test end-to-end sur projet pve-home (repo réel) : install fresh + update sur install legacy
- [ ] `/qa:qa-loop "score 90"` validé
- [ ] PR review (auto ou manuelle)
- [ ] Tag `v1.30.0` créé après merge main

---

## Notes

- **Décision sur le nom du dossier cible** : `.claude/docs/` retenu (cohérent avec convention `.claude/`). Alternatives écartées : `.claude/reference/` (trop restrictif), `.socle/` (pollue racine), `.claude-socle/` (fork inutile de la convention).
- **CLAUDE.md du repo socle** : reste inchangé. Le repo socle continue de référencer `@docs/reference/...` localement. Cette dualité est volontaire et documentée dans la spec.
- **Coordination avec `specs/docs-website-consolidation/`** : pas de conflit identifié. Le sync website lit depuis `docs/` source socle, pas depuis `.claude/docs/` projet user. Si la spec website se finalise après cette migration, elle continuera de fonctionner.
- **Future itération possible** (hors scope) : ajouter `.claude/docs/` au gitignore par défaut dans le template `.gitignore` si on considère que c'est éphémère/regenerable. À débattre.

---

**Version** : 1.0 | **Créé** : 2026-04-28
