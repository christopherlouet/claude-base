# Plan d'implementation : Mise a jour Documentation Docusaurus v1.25.0

## Resume

Combler les ecarts entre la documentation Docusaurus et le socle v1.25.0 en creant 4 nouvelles pages (commande work-team, skill agent-teams, guide bonnes pratiques, concept fonctionnalites avancees), en ajoutant le style explanatory a la page existante, et en corrigeant les compteurs obsoletes dans la configuration et les index.

## Contexte Technique

| Aspect | Choix |
|--------|-------|
| Framework doc | Docusaurus 3 (TypeScript config) |
| Format pages | Markdown avec frontmatter YAML + composants React |
| Source de verite | `docs/reference/`, `.claude/commands/`, `.claude/skills/`, `.claude/output-styles/` |
| Verification | `npm run build` dans `website/` |

## Fichiers Impactes

### A creer (4 fichiers)

| Fichier | Responsabilite | US |
|---------|----------------|----|
| `website/docs/commands/work/work-team.md` | Page commande /work:work-team | US1 |
| `website/docs/skills/agent-teams.md` | Page skill agent-teams | US1 |
| `website/docs/guides/best-practices.md` | Guide bonnes pratiques Boris Cherny | US2 |
| `website/docs/concepts/advanced-features.md` | Page fonctionnalites avancees (Opus 4.6, Agent Teams, Plugins, LSP, MCP, @imports) | US3, US6 |

### A modifier (5 fichiers)

| Fichier | Modification | US |
|---------|-------------|----|
| `website/docusaurus.config.ts` | L126: `Skills (41)` → `Skills (42)`, L191: `Skills (41)` → `Skills (42)` | US5 |
| `website/sidebars.ts` | L38: ajouter `'concepts/advanced-features'`, L74: `WORK (11)` → `WORK (12)`, L338: ajouter `'guides/best-practices'` | US6, US7, US2 |
| `website/docs/skills/index.md` | L4, L13, L16, L18, L32: 41 → 42, ajouter agent-teams dans le tableau L38-78 et dans SkillGrid L84-169 | US1, US5 |
| `website/docs/commands/work/index.md` | L16: 11 → 12, ajouter work-team dans le tableau L20-32 et dans CommandGrid L36-103 | US1, US7 |
| `website/docs/concepts/output-styles.md` | Ajouter style explanatory dans la structure des fichiers L43-52, ajouter section Explanatory entre les styles existants, ajouter dans le tableau cas d'usage L371-379 | US4 |

## Phases d'Implementation

### Phase 1 : Compteurs et configuration (bloquant)

Corriger les compteurs avant d'ajouter du contenu pour eviter les incoherences.

- [ ] T001 - [US5] Corriger compteur Skills 41→42 dans `website/docusaurus.config.ts` (L126, L191)
- [ ] T002 - [US5] Corriger compteur Skills 41→42 dans `website/docs/skills/index.md` (L4, L13, L16, L18, L32)
- [ ] T003 - [US7] Corriger compteur WORK 11→12 dans `website/sidebars.ts` (L74)
- [ ] T004 - [US7] Corriger compteur WORK 11→12 dans `website/docs/commands/work/index.md` (L16)

### Phase 2 : Pages Agent Teams (P1 - US1) MVP

- [ ] T005 - [US1] Creer `website/docs/commands/work/work-team.md` - Page commande work-team (format: cf. work-commit-push-pr.md)
- [ ] T006 - [US1] Creer `website/docs/skills/agent-teams.md` - Page skill agent-teams (format: cf. parallel-agents.md)
- [ ] T007 - [US1] Ajouter work-team dans le tableau et CommandGrid de `website/docs/commands/work/index.md`
- [ ] T008 - [US1] Ajouter agent-teams dans le tableau et SkillGrid de `website/docs/skills/index.md`

### Phase 3 : Pages P1 restantes (parallelisables)

- [ ] T009 - [P] [US2] Creer `website/docs/guides/best-practices.md` - Guide bonnes pratiques Boris Cherny (source: `docs/reference/best-practices.md`)
- [ ] T010 - [P] [US3][US6] Creer `website/docs/concepts/advanced-features.md` - Fonctionnalites avancees avec Opus 4.6, Agent Teams, Plugins, LSP, MCP, @imports (source: `docs/reference/advanced-features.md`)

### Phase 4 : Configuration sidebar

- [ ] T011 - [US2] Ajouter `'guides/best-practices'` dans guidesSidebar de `website/sidebars.ts` (apres L338)
- [ ] T012 - [US6] Ajouter `'concepts/advanced-features'` dans conceptsSidebar de `website/sidebars.ts` (apres L37)

### Phase 5 : Style Explanatory (P2 - US4)

- [ ] T013 - [US4] Ajouter le style explanatory dans `website/docs/concepts/output-styles.md` : structure fichiers, section dediee, tableau cas d'usage

### Phase 6 : Verification

- [ ] T014 - [CS-005] Lancer `npm run build` dans `website/` et corriger les erreurs eventuelles
- [ ] T015 - [CS-001..CS-004] Verifier tous les criteres de succes : compteurs, navigation, pages accessibles

## Sources de contenu par page

| Page a creer | Source principale | Source secondaire |
|-------------|-------------------|-------------------|
| `work-team.md` (commande) | `.claude/commands/work/work-team.md` | `docs/reference/advanced-features.md` (section Agent Teams) |
| `agent-teams.md` (skill) | `.claude/skills/agent-teams/SKILL.md` | `docs/reference/advanced-features.md` (section Agent Teams) |
| `best-practices.md` (guide) | `docs/reference/best-practices.md` | `CLAUDE.md` (bonnes pratiques) |
| `advanced-features.md` (concept) | `docs/reference/advanced-features.md` | `.claude/skills/agent-teams/SKILL.md` |
| Style explanatory (ajout) | `.claude/output-styles/explanatory.md` | - |

## Format de reference par type de page

| Type | Exemple existant | Frontmatter requis |
|------|------------------|--------------------|
| Commande | `website/docs/commands/work/work-commit-push-pr.md` | `sidebar_position`, `title`, `description`, `tags: [work, command]` |
| Skill | `website/docs/skills/parallel-agents.md` | `sidebar_position`, `title`, `description`, `tags: [skill, fork]` |
| Guide | `website/docs/guides/web-development.md` | `sidebar_position`, `title`, `description` |
| Concept | `website/docs/concepts/output-styles.md` | `sidebar_position`, `title`, `description` |

## Risques et Mitigations

| Risque | Probabilite | Impact | Mitigation |
|--------|-------------|--------|------------|
| Build Docusaurus casse apres modifications | Moyenne | Haut | T014: build de verification apres chaque phase |
| Liens croises brises entre pages | Faible | Moyen | Verifier les liens relatifs dans chaque nouvelle page |
| Sidebar mal configure | Faible | Moyen | Tester le rendu apres chaque modification de sidebars.ts |
| Contenu duplique entre advanced-features.md et pages individuelles | Moyenne | Faible | La page concept fait un resume avec renvoi vers les pages detaillees |

## Criteres de Validation

- [ ] `npm run build` passe sans erreur dans `website/`
- [ ] Compteurs corrects : Skills (42) dans navbar et footer
- [ ] 4 nouvelles pages accessibles via navigation
- [ ] Liens croises fonctionnels entre les pages
- [ ] 121 commandes documentees (dont work-team)
- [ ] 42 skills documentes (dont agent-teams)
- [ ] Style explanatory visible dans la page output-styles

---

**Version**: 1.0 | **Cree par**: /work:work-plan | **Date**: 2026-02-06
