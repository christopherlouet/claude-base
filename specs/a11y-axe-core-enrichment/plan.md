# Plan d'implémentation : Enrichissement A11Y inspiré d'axe-core

**Branche**: `feature/a11y-axe-core-enrichment`
**Date**: 2026-03-18
**Spec**: Pas de spec formelle — basé sur l'analyse comparative axe-core vs couverture actuelle
**Statut**: Draft

---

## Résumé

Enrichir les 3 fichiers a11y du socle (rule, agent, command) en s'inspirant du référentiel axe-core (93+ règles) pour combler les gaps majeurs : ARIA complet, structure/sémantique, tables, frames, niveaux d'impact, et WCAG 2.2. L'objectif n'est pas de reproduire axe-core (outil runtime) mais d'aligner notre audit statique sur les mêmes catégories et classifications.

---

## Contexte Technique

| Aspect | Choix | Notes |
|--------|-------|-------|
| **Type de projet** | Socle Claude Code (Markdown) | Pas de code exécutable — uniquement des fichiers .md |
| **Fichiers cibles** | 3 fichiers socle + 2 fichiers website | Rules, agents, commands |
| **Référence** | axe-core v4.11 (93+ règles) | [github.com/dequelabs/axe-core](https://github.com/dequelabs/axe-core) |
| **Contrainte tokens** | Rules compactes (tables, pas d'exemples) | Exemples dans website/ uniquement |

### Contraintes

- Les rules (.claude/rules/) doivent rester compactes : tables + directives, pas d'exemples de code
- Les exemples de code vont uniquement dans website/docs/rules/
- L'agent reste en mode read-only (Haiku, outils: Read/Grep/Glob)
- Le command reste un orchestrateur léger

### Philosophie axe-core à intégrer

| Principe axe-core | Application au socle |
|-------------------|---------------------|
| Zero false positives | Patterns regex précis, pas de faux positifs |
| Niveaux d'impact (Critical/Serious/Moderate/Minor) | Classifier chaque règle par impact |
| Violation vs Needs Review | Distinguer détectable auto vs vérification manuelle |
| Mapping WCAG explicite | Référencer les critères WCAG pour chaque règle |

---

## Vérification Constitution/Conventions

- [x] Respecte les conventions du projet (Markdown, pas de code dans rules)
- [x] Cohérent avec l'architecture existante (rule + agent + command)
- [x] Pas d'over-engineering (enrichissement incrémental)
- [ ] Revue avant merge

---

## Fichiers Impactés

### À modifier

| Fichier | Modification |
|---------|--------------|
| `.claude/rules/accessibility.md` | Ajouter 6 nouvelles catégories de règles + niveaux d'impact |
| `.claude/agents/wcag-audit.md` | Enrichir patterns regex + classification d'impact + catégories |
| `.claude/commands/qa/wcag-audit.md` | Ajouter recommandation axe-core/Playwright + catégories enrichies |
| `website/docs/rules/accessibility.md` | Ajouter exemples de code pour nouvelles catégories |
| `website/docs/agents/wcag-audit.md` | Mettre à jour la checklist et le format de sortie |

### Aucun fichier à créer

Enrichissement de l'existant uniquement.

---

## Approche Choisie

### Architecture

```
Enrichissement en 3 couches :

┌──────────────────────────────────────────────────────────┐
│  Rule (accessibility.md)                                  │
│  = Directives compactes par catégorie                     │
│  + Niveaux d'impact (Critical/Serious/Moderate/Minor)     │
│  + Mapping WCAG explicite                                 │
├──────────────────────────────────────────────────────────┤
│  Agent (wcag-audit.md)                                       │
│  = Patterns regex enrichis pour détection automatique     │
│  + Format de sortie avec impact levels                    │
│  + Distinction violation / needs-review                   │
├──────────────────────────────────────────────────────────┤
│  Command (wcag-audit.md)                                     │
│  = Orchestration + recommandation outils runtime          │
│  + Catégories d'audit enrichies                           │
├──────────────────────────────────────────────────────────┤
│  Website (docs/)                                          │
│  = Exemples de code TSX/CSS pour chaque catégorie         │
└──────────────────────────────────────────────────────────┘
```

### Nouvelles catégories à ajouter (inspirées axe-core)

| # | Catégorie | Règles axe-core | Impact |
|---|-----------|----------------|--------|
| 1 | **ARIA complet** | 20+ règles (allowed/required/prohibited attrs, rôles, relations) | Critical-Serious |
| 2 | **Structure/Sémantique** | document-title, html-lang, landmarks, regions, heading-order, lists | Serious-Moderate |
| 3 | **Tables** | headers, scope, data-cells, doublons caption/summary | Serious |
| 4 | **Frames/Iframes** | titres, focus, unicité | Serious |
| 5 | **Éléments dépréciés** | blink, marquee, meta-refresh, autoplay-audio | Serious-Minor |
| 6 | **WCAG 2.2** | target-size (44x44px), focus-not-obscured | Serious-Moderate |

### Enrichissements transversaux

| Enrichissement | Description |
|----------------|-------------|
| **Niveaux d'impact** | Chaque règle classifiée Critical/Serious/Moderate/Minor |
| **Mapping WCAG** | Référence explicite du critère WCAG pour chaque règle |
| **Violation vs Needs Review** | Distinguer ce qui est détectable automatiquement |

### Justification

Enrichir l'existant plutôt que recréer : on garde notre structure rule/agent/command et on l'aligne sur le standard de facto (axe-core) pour la classification et la couverture.

### Alternatives considérées

| Alternative | Pourquoi rejetée |
|-------------|------------------|
| Intégrer axe-core comme dépendance | Le socle est du Markdown, pas un projet Node — axe-core est recommandé comme outil complémentaire, pas intégré |
| Créer une rule par catégorie (aria.md, tables.md...) | Over-engineering — une seule rule enrichie est plus cohérente |
| Copier toutes les 93+ règles axe-core | Trop verbeux pour un audit statique — sélectionner les plus pertinentes |

---

## Phases d'Implémentation

### Phase 1 : Rule enrichie (P1 - fondation) 🎯

**Objectif** : Enrichir `.claude/rules/accessibility.md` avec toutes les nouvelles catégories et le système d'impact

- [ ] T001 - Ajouter le système de niveaux d'impact (Critical/Serious/Moderate/Minor) avec définitions
- [ ] T002 - [P] Ajouter la catégorie ARIA complet (attrs, rôles, relations)
- [ ] T003 - [P] Ajouter la catégorie Structure/Sémantique (landmarks, lang, title, heading-order)
- [ ] T004 - [P] Ajouter la catégorie Tables accessibles
- [ ] T005 - [P] Ajouter la catégorie Frames/Iframes
- [ ] T006 - [P] Ajouter la catégorie Éléments dépréciés
- [ ] T007 - [P] Ajouter la catégorie WCAG 2.2 (target-size, focus-not-obscured)
- [ ] T008 - Enrichir les catégories existantes avec mapping WCAG + impact

**Checkpoint** : Rule complète avec toutes les catégories et classifications.

### Phase 2 : Agent enrichi (P1)

**Objectif** : Enrichir `.claude/agents/wcag-audit.md` avec les patterns de détection et le format de sortie

- [ ] T009 - Ajouter les patterns regex pour ARIA (attrs invalides, rôles inconnus)
- [ ] T010 - [P] Ajouter les patterns regex pour structure (lang manquant, title vide, landmarks)
- [ ] T011 - [P] Ajouter les patterns regex pour tables et frames
- [ ] T012 - Restructurer le format de sortie avec niveaux d'impact
- [ ] T013 - Ajouter la distinction violation / needs-review

**Checkpoint** : Agent capable de détecter et classifier les nouvelles catégories.

### Phase 3 : Command enrichi (P2)

**Objectif** : Enrichir `.claude/commands/qa/wcag-audit.md` avec les catégories et recommandations outils

- [ ] T014 - Ajouter les catégories d'audit enrichies au workflow
- [ ] T015 - Ajouter la recommandation d'outils runtime (axe-core + Playwright)

**Checkpoint** : Command couvre toutes les catégories.

### Phase 4 : Documentation website (P2)

**Objectif** : Enrichir les docs website avec les exemples de code

- [ ] T016 - [P] Ajouter exemples ARIA (bon/mauvais) dans `website/docs/rules/accessibility.md`
- [ ] T017 - [P] Ajouter exemples Structure/Sémantique
- [ ] T018 - [P] Ajouter exemples Tables accessibles
- [ ] T019 - [P] Ajouter exemples Frames/Iframes
- [ ] T020 - [P] Ajouter exemples WCAG 2.2 (target-size)
- [ ] T021 - Mettre à jour `website/docs/agents/wcag-audit.md` avec le nouveau format

**Checkpoint** : Documentation complète avec exemples pour chaque catégorie.

### Phase 5 : Polish & Validation

- [ ] T022 - Vérifier la cohérence entre rule, agent, command et website
- [ ] T023 - Vérifier que la rule reste compacte (pas d'exemples de code)
- [ ] T024 - Relecture finale

---

## Risques et Mitigations

| Risque | Impact | Probabilité | Mitigation |
|--------|--------|-------------|------------|
| Rule trop longue (tokens) | Élevé | Moyenne | Garder format table, pas d'exemples dans la rule |
| Patterns regex faux positifs | Moyen | Moyenne | Tester sur des fichiers réels, préférer la précision |
| Incohérence rule/agent/website | Moyen | Faible | Phase 5 de validation croisée |
| Surcharge d'information pour l'agent Haiku | Moyen | Faible | Garder l'agent concis, détails dans la rule |

---

## Dépendances et Ordre d'Exécution

```
Phase 1 (Rule) ──┬──▶ Phase 2 (Agent) ──▶ Phase 3 (Command)
                  │
                  └──▶ Phase 4 (Website) [parallèle avec Phase 2-3]

Phases 2, 3, 4 ──────▶ Phase 5 (Polish)
```

---

## Critères de Validation

### Avant merge
- [ ] Les 6 nouvelles catégories sont couvertes dans rule + agent + command
- [ ] Chaque règle a un niveau d'impact et une référence WCAG
- [ ] Les patterns regex de l'agent sont précis (pas de faux positifs évidents)
- [ ] La rule reste compacte (<150 lignes)
- [ ] Les exemples de code sont dans website/ uniquement
- [ ] Cohérence entre les 5 fichiers

---

**Version**: 1.0 | **Créé**: 2026-03-18
