# Spécification : Synchronisation Claude Code Q1 2026 - Phase 2

**Branche**: `feature/sync-claude-code-2026-q1-v2`
**Date**: 2026-03-21
**Statut**: Ready

---

## Résumé

Mettre à jour le socle claude-socle pour intégrer les dernières évolutions de Claude Code (mars 2026) : adaptive thinking avec niveau `max`, context compaction dans les workflows, checkpoint/rewind, et fast mode. L'objectif est que les utilisateurs du socle bénéficient immédiatement de ces nouveautés sans recherche manuelle.

---

## User Stories (prioritisées)

### US1 - Adaptive Thinking et niveau `max` (Priorité: P1) 🎯 MVP

**En tant que** utilisateur du socle
**Je veux** savoir comment utiliser l'adaptive thinking et le niveau d'effort `max`
**Afin de** tirer le meilleur parti du raisonnement de Claude selon la complexité de ma tâche

**Pourquoi P1**: Le niveau `max` (exclusif Opus 4.6) n'est pas documenté dans le socle alors qu'il est disponible. Les tables effort levels sont incomplètes.

**Test indépendant**: Un nouvel utilisateur lisant la doc doit comprendre les 4 niveaux et savoir quand utiliser `max`.

**Critères d'acceptation**:

1. **Étant donné** que je consulte `best-practices.md`, **Quand** je lis la section Effort Levels, **Alors** je vois les 4 niveaux (`low`, `medium`, `high`, `max`) avec des cas d'usage concrets
2. **Étant donné** que je consulte `advanced-features.md`, **Quand** je lis la section Opus 4.6, **Alors** je comprends que l'adaptive thinking remplace `budget_tokens` et que Claude ajuste automatiquement son raisonnement
3. **Étant donné** que je consulte `advanced-features.md`, **Quand** je lis la section Effort Levels, **Alors** le niveau `max` apparaît avec la mention "Opus 4.6 uniquement"
4. **Étant donné** que les recommandations par workflow existent, **Quand** je lis la table workflow/effort, **Alors** `/qa:qa-audit` et `/qa:qa-security` recommandent `max` (avec mention "Opus 4.6 uniquement")

---

### US2 - Context Compaction dans les workflows (Priorité: P1) 🎯 MVP

**En tant que** utilisateur du socle travaillant sur des sessions longues
**Je veux** savoir quand et comment utiliser la compaction de contexte
**Afin de** ne pas perdre de contexte important lors de sessions complexes

**Pourquoi P1**: La compaction est automatique mais l'utilisateur peut aussi la déclencher manuellement (`/compact`). Sans guidance, les utilisateurs perdent du contexte ou font des `/clear` inutiles.

**Test indépendant**: Un utilisateur en milieu de workflow Explore→Plan→TDD sait quoi faire quand le contexte devient long.

**Critères d'acceptation**:

1. **Étant donné** que je lis `best-practices.md`, **Quand** je cherche la gestion de contexte, **Alors** je trouve une section expliquant `/compact` vs `/clear` vs laisser faire l'auto-compaction
2. **Étant donné** que je lis `workflow.md`, **Quand** je consulte la section "Gestion du contexte", **Alors** je trouve une sous-section dédiée avec table `/compact` vs `/clear` et recommandations par phase du workflow
3. **Étant donné** que la compaction se déclenche automatiquement, **Quand** je lis la doc, **Alors** je comprends que les hooks `PreCompact`/`PostCompact` existent et sont configurables

---

### US3 - Checkpoint et Rewind (Priorité: P1) 🎯 MVP

**En tant que** développeur utilisant le cycle TDD du socle
**Je veux** savoir comment revenir à un état précédent du code après une modification ratée
**Afin de** ne pas perdre de temps à débugger un refactoring cassé

**Pourquoi P1**: Les checkpoints sont automatiques (avant chaque modification) mais `/rewind` n'est documenté nulle part dans le socle. C'est un filet de sécurité essentiel pour le TDD.

**Test indépendant**: Un utilisateur en phase Refactor du TDD sait qu'il peut revenir en arrière sans git reset.

**Critères d'acceptation**:

1. **Étant donné** que je lis `advanced-features.md`, **Quand** je cherche checkpoint ou rewind, **Alors** je trouve une section expliquant le mécanisme (sauvegarde auto avant chaque changement, `Esc×2` ou `/rewind` pour revenir)
2. **Étant donné** que je lis la doc TDD ou `workflow.md`, **Quand** je consulte la phase Refactor, **Alors** je vois une mention du rewind comme alternative au revert manuel
3. **Étant donné** que je consulte `best-practices.md`, **Quand** je lis les techniques de récupération, **Alors** checkpoint/rewind est mentionné comme première option avant `git stash` ou `git checkout`

---

### US4 - Fast Mode (Priorité: P2)

**En tant que** utilisateur du socle
**Je veux** savoir quand utiliser le fast mode
**Afin de** accélérer les tâches simples sans sacrifier la qualité sur les tâches complexes

**Pourquoi P2**: Le fast mode (2.5x plus rapide, même modèle) est utile mais en research preview. Pas bloquant.

**Test indépendant**: Un utilisateur sait activer/désactiver le fast mode et connaît les cas d'usage.

**Critères d'acceptation**:

1. **Étant donné** que je lis `best-practices.md`, **Quand** je cherche fast mode, **Alors** je trouve une mention de `/fast` avec les cas d'usage recommandés (exploration, commits, tâches simples)
2. **Étant donné** que je lis `advanced-features.md`, **Quand** je consulte la section, **Alors** je comprends que c'est le même modèle en plus rapide, pas un modèle différent

---

### US5 - MCP Channels (Priorité: P2)

**En tant que** utilisateur avancé du socle
**Je veux** comprendre les MCP Channels (push de messages par les serveurs MCP)
**Afin de** pouvoir recevoir des notifications de Slack, Sentry ou Linear pendant une session

**Pourquoi P2**: Feature en research preview, utile pour les utilisateurs avancés avec MCP activé.

**Critères d'acceptation**:

1. **Étant donné** que je lis `advanced-features.md`, **Quand** je consulte la section MCP, **Alors** je trouve une explication des channels avec un exemple concret (ex: notification Sentry d'une erreur pendant le dev)
2. **Étant donné** que je consulte `.mcp.json`, **Quand** je lis les commentaires/doc, **Alors** je sais quels serveurs supportent les channels

---

### US6 - Compaction API pour développeurs (Priorité: P3)

**En tant que** développeur construisant des apps avec Claude API
**Je veux** que le skill `claude-api` mentionne la Compaction API
**Afin de** pouvoir l'utiliser dans mes propres applications

**Pourquoi P3**: Concerne le skill claude-api, pas le socle directement.

**Critères d'acceptation**:

1. **Étant donné** que j'utilise le skill `claude-api`, **Quand** je consulte les features disponibles, **Alors** la Compaction API (beta) est mentionnée comme option pour les conversations longues

---

## Exigences Fonctionnelles

| ID | Exigence | Vérification |
|----|----------|--------------|
| EF-01 | `best-practices.md` documente les 4 niveaux d'effort (`low`, `medium`, `high`, `max`) | Lecture du fichier, 4 niveaux présents dans la table |
| EF-02 | `advanced-features.md` section Opus 4.6 explique l'adaptive thinking | Section lisible et cohérente |
| EF-03 | `best-practices.md` contient une section gestion de contexte (`/compact` vs `/clear`) | Section présente avec recommandations claires |
| EF-04 | `workflow.md` contient une sous-section "Gestion du contexte" avec table `/compact` vs `/clear` et recommandations par phase | Sous-section présente avec table et recommandations |
| EF-05 | `advanced-features.md` contient une section Checkpoint/Rewind | Section avec instructions `Esc×2` et `/rewind` |
| EF-06 | `best-practices.md` ou `advanced-features.md` mentionne le fast mode | Toggle `/fast` documenté |
| EF-07 | `advanced-features.md` section MCP mentionne les channels | Description et cas d'usage |
| EF-08 | Aucun fichier chargé systématiquement (CLAUDE.md @imports) n'augmente de plus de 15 lignes | Comptage diff avant/après |

---

## Cas Limites

| Cas | Comportement attendu |
|-----|---------------------|
| Utilisateur sur un plan sans Opus 4.6 | Le niveau `max` est clairement marqué "Opus 4.6 uniquement" |
| Utilisateur ne connaissant pas `/compact` | La doc explique la différence avec `/clear` sans jargon |
| Fast mode désactivé par l'utilisateur | `/fast` toggle clairement expliqué comme réversible |
| Checkpoint non disponible (ancienne version CLI) | Mentionner la version minimum requise |

---

## Critères de Succès

| ID | Critère | Mesure |
|----|---------|--------|
| CS-01 | Documentation à jour avec Claude Code mars 2026 | 100% des features P1 documentées |
| CS-02 | Pas d'augmentation significative du baseline contexte | ≤ 15 lignes ajoutées aux fichiers @import |
| CS-03 | Cohérence entre best-practices.md et advanced-features.md | Pas de contradictions entre les deux fichiers |
| CS-04 | Tests de validation du socle passent | `scripts/validate.sh` OK |

---

## Hors Scope

- Mise à jour du site Docusaurus (sera fait dans une spec séparée)
- Implémentation de la spec `check-updates` (spec existante séparée)
- Finalisation de la spec `docs-update-v1.25` (spec existante séparée)
- Ajout de nouvelles rules Kotlin/Swift
- Création d'un skill `context-management`
- Mise à jour du skill `claude-api` pour la Compaction API (US6 P3, différée)

---

## Points de Clarification

1. ~~**Fast mode pricing**~~ : **Résolu** — Pas de montants dans la doc. Mentionner uniquement "coût premium, voir pricing Anthropic" pour éviter l'obsolescence.
2. ~~**`max` effort en recommandation workflow**~~ : **Résolu** — `max` explicite pour `/qa:qa-audit` et `/qa:qa-security`, avec mention "Opus 4.6 uniquement" pour les utilisateurs sur d'autres plans.
3. ~~**Compaction dans workflow.md**~~ : **Résolu** — Sous-section dédiée "Gestion du contexte" dans `workflow.md` avec table `/compact` vs `/clear` et recommandations par phase.
