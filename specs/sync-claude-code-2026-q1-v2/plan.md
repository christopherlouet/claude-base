# Plan d'implémentation : Sync Claude Code Q1 2026 - Phase 2

**Spec**: `specs/sync-claude-code-2026-q1-v2/spec.md`
**Date**: 2026-03-21
**Complexité globale**: Simple (documentation uniquement, pas de code)

---

## Résumé

Mise à jour de 3 fichiers de documentation existants pour intégrer les nouveautés Claude Code mars 2026. Aucun nouveau fichier à créer. Éditions ciblées pour respecter la contrainte EF-08 (≤ 15 lignes ajoutées à `best-practices.md`).

---

## Contexte technique

### Fichiers @importés dans CLAUDE.md (chargés systématiquement)
- `docs/reference/best-practices.md` — **79 lignes** → cible ≤ 94 lignes (EF-08)
- `docs/reference/project-structures.md` — non impacté

### Fichiers on-demand (pas de contrainte de taille)
- `docs/reference/advanced-features.md` — **184 lignes** → sections à enrichir
- `.claude/rules/workflow.md` — **110 lignes** → nouvelle sous-section

---

## Fichiers impactés

| Fichier | Action | US |
|---------|--------|-----|
| `docs/reference/best-practices.md` | MODIFIER | US1, US2, US3 |
| `docs/reference/advanced-features.md` | MODIFIER | US1, US2, US3, US4, US5 |
| `.claude/rules/workflow.md` | MODIFIER | US2, US3 |

---

## Architecture des modifications

### `best-practices.md` (contraint ≤ +15 lignes)

| Section existante | Modification | Lignes estimées |
|---|---|---|
| Effort Levels (L39-49) | Ajouter `max` dans la table + mention Opus 4.6 | +3 |
| _(nouvelle)_ Gestion du Contexte | `/compact` vs `/clear` — table concise après Sessions Parallèles | +8 |
| _(nouvelle)_ Récupération rapide | Checkpoint/rewind en 2 lignes après Gestion du Contexte | +3 |
| **Total** | | **+14** ✅ |

### `advanced-features.md` (on-demand, pas de contrainte)

| Section existante | Modification |
|---|---|
| Effort Levels (L39-57) | Ajouter `max` dans la table niveaux + table workflow |
| Opus 4.6 (L85-87) | Enrichir : adaptive thinking expliqué, `budget_tokens` déprécié |
| _(nouvelle)_ Checkpoint / Rewind | Après Opus 4.6, avant Agent Teams |
| _(nouvelle)_ Fast Mode | Après Checkpoint/Rewind |
| _(nouvelle)_ Context Compaction | Après Fast Mode, mentionner `/compact` et hooks |
| MCP Configuration (L97-116) | Ajouter sous-section MCP Channels après Elicitation |

### `workflow.md` (rule on-demand)

| Section | Modification |
|---|---|
| TDD > phase 3 REFACTOR (L30-34) | Ajouter mention rewind comme filet de sécurité |
| _(nouvelle)_ Gestion du contexte | Après "Gestion du scope", avant "Anti-patterns". Table `/compact` vs `/clear` par phase |

---

## Phases

### Phase 1 — P1 : Adaptive Thinking + Effort `max` [US1]

Modifier les tables effort levels dans `best-practices.md` et `advanced-features.md`. Enrichir la section Opus 4.6.

### Phase 2 — P1 : Context Compaction [US2]

Ajouter section gestion du contexte dans `best-practices.md` (concis) et `workflow.md` (détaillé). Enrichir `advanced-features.md`.

### Phase 3 — P1 : Checkpoint / Rewind [US3]

Ajouter section dans `advanced-features.md`. Mention dans `workflow.md` (TDD Refactor) et `best-practices.md` (récupération rapide).

### Phase 4 — P2 : Fast Mode + MCP Channels [US4, US5]

Ajouter sections dans `advanced-features.md`. Mention `/fast` dans `best-practices.md` (si budget lignes restant).

---

## Risques

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Dépasser +15 lignes dans best-practices.md | Alourdit le baseline contexte | Compter les lignes après chaque édition, rester concis |
| Incohérence entre les 3 fichiers | Confusion utilisateur | Vérifier la cohérence après chaque phase |
| Information obsolète (features en preview) | Doc trompeuse | Marquer clairement "research preview" ou "Opus 4.6 uniquement" |

---

## Vérification

```bash
# Après implémentation :
wc -l docs/reference/best-practices.md  # ≤ 94
scripts/validate.sh                      # OK
# Relecture manuelle des 3 fichiers pour cohérence
```
