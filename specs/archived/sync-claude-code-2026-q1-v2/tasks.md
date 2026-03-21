# Tâches : Sync Claude Code Q1 2026 - Phase 2

**Plan**: `specs/sync-claude-code-2026-q1-v2/plan.md`

---

## Phase 1 — Adaptive Thinking + Effort `max` [US1]

- [ ] **T001** [US1] — Modifier `best-practices.md` section Effort Levels : ajouter ligne `max` dans la table avec "Audit critique, debug complexe (Opus 4.6 uniquement)" et ajouter `/effort max` dans la ligne commandes
  - Fichier: `docs/reference/best-practices.md` L39-49
  - Contrainte: +3 lignes max

- [ ] **T002** [US1] — Modifier `advanced-features.md` section Effort Levels : ajouter `max` dans la table niveaux (L43-47) avec mention "Opus 4.6 uniquement"
  - Fichier: `docs/reference/advanced-features.md` L39-57

- [ ] **T003** [US1] — Modifier `advanced-features.md` table workflow/effort : changer `/qa:qa-audit`, `/qa:qa-security` de `high` à `max` avec note "(Opus 4.6)"
  - Fichier: `docs/reference/advanced-features.md` L50-57

- [ ] **T004** [US1] — Enrichir `advanced-features.md` section Opus 4.6 : expliquer adaptive thinking (remplace `budget_tokens`), Claude ajuste le raisonnement automatiquement
  - Fichier: `docs/reference/advanced-features.md` L85-87

## Phase 2 — Context Compaction [US2]

- [ ] **T005** [US2] — Ajouter section "Gestion du Contexte" dans `best-practices.md` après "Sessions Paralleles" : table `/compact` vs `/clear` vs auto-compaction (3 lignes table + titre)
  - Fichier: `docs/reference/best-practices.md` après L67
  - Contrainte: +8 lignes max

- [ ] **T006** [US2] — Ajouter section "Context Compaction" dans `advanced-features.md` : `/compact` manuel, auto-compaction, hooks `PreCompact`/`PostCompact`, lien vers hooks-reference
  - Fichier: `docs/reference/advanced-features.md` (après nouvelle section Fast Mode)

- [ ] **T007** [US2] — Ajouter sous-section "Gestion du contexte" dans `workflow.md` après "Gestion du scope" : table `/compact` vs `/clear` avec recommandation par phase du workflow
  - Fichier: `.claude/rules/workflow.md` après L61

## Phase 3 — Checkpoint / Rewind [US3]

- [ ] **T008** [US3] — Ajouter section "Checkpoint / Rewind" dans `advanced-features.md` après Opus 4.6 : sauvegarde auto, `Esc×2`, `/rewind`, version CLI minimum
  - Fichier: `docs/reference/advanced-features.md` (après section Opus 4.6 enrichie)

- [ ] **T009** [US3] — Modifier `workflow.md` phase TDD > REFACTOR : ajouter mention "Si le refactoring casse les tests, utiliser `/rewind` pour revenir au dernier état stable"
  - Fichier: `.claude/rules/workflow.md` L30-34

- [ ] **T010** [US3] — Ajouter mention checkpoint/rewind dans `best-practices.md` section "Gestion du Contexte" ou nouvelle ligne "Récupération rapide" : `/rewind` comme première option avant `git stash`
  - Fichier: `docs/reference/best-practices.md` après section Gestion du Contexte
  - Contrainte: +3 lignes max

## Phase 4 — Fast Mode + MCP Channels [US4, US5]

- [ ] **T011** [P] [US4] — Ajouter section "Fast Mode" dans `advanced-features.md` : `/fast` toggle, même modèle en plus rapide, research preview, coût premium (voir pricing Anthropic)
  - Fichier: `docs/reference/advanced-features.md` (après Checkpoint/Rewind)

- [ ] **T012** [P] [US5] — Ajouter sous-section "MCP Channels" dans `advanced-features.md` section MCP : push de messages, `--channels` flag, exemple Sentry/Slack, research preview
  - Fichier: `docs/reference/advanced-features.md` après L116 (après Elicitation)

---

## Vérification finale

- [ ] **T013** — Vérifier contrainte EF-08 : `wc -l docs/reference/best-practices.md` ≤ 94
- [ ] **T014** — Vérifier cohérence entre les 3 fichiers (pas de contradictions sur effort levels, compaction, rewind)
- [ ] **T015** — Lancer `scripts/validate.sh` et vérifier OK

---

## Résumé

| Phase | Tâches | US | Parallélisable |
|-------|--------|----|----------------|
| 1 | T001-T004 | US1 | T002+T003 [P] |
| 2 | T005-T007 | US2 | T006+T007 [P] |
| 3 | T008-T010 | US3 | T009+T010 [P] |
| 4 | T011-T012 | US4, US5 | T011+T012 [P] |
| Vérif | T013-T015 | — | Séquentiel |

**Total**: 15 tâches, complexité Simple, 3 fichiers modifiés, 0 fichier créé.
