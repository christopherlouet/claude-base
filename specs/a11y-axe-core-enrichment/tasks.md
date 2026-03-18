# Tâches : Enrichissement A11Y inspiré d'axe-core

**Input**: `specs/a11y-axe-core-enrichment/plan.md`
**Prérequis**: Exploration faite (analyse comparative axe-core vs couverture actuelle)

---

## Format : `[ID] [P?] Description`

- **[P]** : Peut être exécutée en parallèle
- Chemins de fichiers exacts inclus

---

## Phase 1 : Rule enrichie (P1 - fondation) 🎯

**Objectif** : Enrichir la rule accessibility avec 6 nouvelles catégories + système d'impact

- [ ] T001 - Ajouter le système de niveaux d'impact dans `.claude/rules/accessibility.md` : table Critical/Serious/Moderate/Minor avec définitions alignées axe-core
- [ ] T002 - [P] Ajouter catégorie **ARIA complet** dans `.claude/rules/accessibility.md` : attrs autorisés/requis/prohibés, rôles valides, relations parent/enfant, aria-hidden+focus, WCAG 4.1.2
- [ ] T003 - [P] Ajouter catégorie **Structure/Sémantique** dans `.claude/rules/accessibility.md` : document-title, html-lang, landmarks uniques, regions, heading-order, listes structurées, WCAG 1.3.1/2.4.1/2.4.6/3.1.1
- [ ] T004 - [P] Ajouter catégorie **Tables accessibles** dans `.claude/rules/accessibility.md` : th/headers, scope, data-cells, caption, WCAG 1.3.1
- [ ] T005 - [P] Ajouter catégorie **Frames/Iframes** dans `.claude/rules/accessibility.md` : title obligatoire, titres uniques, focus, WCAG 4.1.2
- [ ] T006 - [P] Ajouter catégorie **Éléments dépréciés** dans `.claude/rules/accessibility.md` : blink, marquee, meta-refresh, autoplay-audio, WCAG 2.2.1/2.2.2/1.4.2
- [ ] T007 - [P] Ajouter catégorie **WCAG 2.2** dans `.claude/rules/accessibility.md` : target-size 44x44px (2.5.8), focus-not-obscured (2.4.11)
- [ ] T008 - Enrichir les catégories existantes dans `.claude/rules/accessibility.md` : ajouter mapping WCAG + niveau d'impact à chaque règle existante (images, formulaires, clavier, boutons, couleurs, modales)

**Checkpoint** : Rule complète, toutes catégories avec impact + WCAG ref.

---

## Phase 2 : Agent enrichi (P1)

**Objectif** : Enrichir les patterns de détection et le format de sortie

- [ ] T009 - Ajouter patterns regex ARIA dans `.claude/agents/qa-a11y.md` : `role="[invalide]"`, `aria-[inconnu]`, `aria-hidden.*tabindex`, `aria-required` sans attrs requis
- [ ] T010 - [P] Ajouter patterns regex structure dans `.claude/agents/qa-a11y.md` : `<html` sans `lang`, `<title></title>` vide, heading sauts (h1→h3), absence landmarks
- [ ] T011 - [P] Ajouter patterns regex tables/frames dans `.claude/agents/qa-a11y.md` : `<table` sans headers, `<iframe` sans title, `<th` sans scope
- [ ] T012 - Restructurer format de sortie dans `.claude/agents/qa-a11y.md` : tableau avec colonnes Impact (Critical/Serious/Moderate/Minor) + WCAG ref + Type (violation/needs-review)
- [ ] T013 - Ajouter section "Needs Review" dans `.claude/agents/qa-a11y.md` : items non détectables automatiquement (contraste dynamique, contenu généré, ordre de lecture)

**Checkpoint** : Agent détecte et classifie les nouvelles catégories.

---

## Phase 3 : Command enrichi (P2)

**Objectif** : Enrichir les catégories d'audit et recommander les outils runtime

- [ ] T014 - Ajouter les catégories d'audit enrichies dans `.claude/commands/qa/qa-a11y.md` : ARIA, Structure, Tables, Frames, Dépréciés, WCAG 2.2
- [ ] T015 - Ajouter section "Outils complémentaires recommandés" dans `.claude/commands/qa/qa-a11y.md` : axe-core (npx @axe-core/cli), Playwright+axe (@axe-core/playwright), Pa11y, Lighthouse

**Checkpoint** : Command couvre toutes les catégories.

---

## Phase 4 : Documentation website (P2)

**Objectif** : Exemples de code pour chaque nouvelle catégorie

- [ ] T016 - [P] Ajouter exemples **ARIA** dans `website/docs/rules/accessibility.md` : bon/mauvais usage attrs, rôles, relations
- [ ] T017 - [P] Ajouter exemples **Structure/Sémantique** dans `website/docs/rules/accessibility.md` : landmarks, lang, title, heading-order
- [ ] T018 - [P] Ajouter exemples **Tables** dans `website/docs/rules/accessibility.md` : headers, scope, caption
- [ ] T019 - [P] Ajouter exemples **Frames** dans `website/docs/rules/accessibility.md` : iframe title, focus
- [ ] T020 - [P] Ajouter exemples **WCAG 2.2** dans `website/docs/rules/accessibility.md` : target-size CSS, focus-not-obscured
- [ ] T021 - Mettre à jour `website/docs/agents/qa-a11y.md` : checklist enrichie, nouveau format de sortie avec impact levels

**Checkpoint** : Documentation complète avec exemples.

---

## Phase 5 : Polish & Validation

**Objectif** : Cohérence et qualité finale

- [ ] T022 - Vérifier cohérence entre les 5 fichiers (rule ↔ agent ↔ command ↔ website×2)
- [ ] T023 - Vérifier que la rule reste compacte (<150 lignes, pas d'exemples de code)
- [ ] T024 - Relecture finale et ajustements

---

## Dépendances

```
Phase 1 (Rule) ──┬──▶ Phase 2 (Agent)
                  │         │
                  │         ▼
                  │    Phase 3 (Command)
                  │
                  └──▶ Phase 4 (Website) [parallèle Phase 2-3]

Phases 2, 3, 4 ──────▶ Phase 5 (Polish)
```

Au sein de chaque phase : les tâches [P] sont parallélisables.

---

**Version**: 1.0 | **Créé**: 2026-03-18
