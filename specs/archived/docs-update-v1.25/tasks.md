# Taches : Mise a jour Documentation Docusaurus v1.25.0

## Phase 1 : Compteurs et configuration [US5][US7]

> Corriger les compteurs avant d'ajouter du contenu.

### T001 - [US5] Corriger compteur Skills navbar/footer
- **Fichier**: `website/docusaurus.config.ts`
- **Modifications**:
  - L126: `'Skills (41)'` → `'Skills (42)'`
  - L191: `'Skills (41)'` → `'Skills (42)'`
- **Complexite**: Simple

### T002 - [US5] Corriger compteur Skills index
- **Fichier**: `website/docs/skills/index.md`
- **Modifications**:
  - L4: `"Catalogue des 41 skills auto-declenches"` → `"Catalogue des 42 skills auto-declenches"`
  - L13: `**41 skills**` → `**42 skills**`
  - L16: `{ number: 41, label: 'Skills Fork' }` → `{ number: 42, label: 'Skills Fork' }`
  - L18: `{ number: 41, label: 'Total' }` → `{ number: 42, label: 'Total' }`
  - L32: `### Fork (41 skills)` → `### Fork (42 skills)`
- **Complexite**: Simple

### T003 - [US7] Corriger compteur WORK sidebar
- **Fichier**: `website/sidebars.ts`
- **Modification**: L74: `'WORK (11)'` → `'WORK (12)'`
- **Complexite**: Simple

### T004 - [US7] Corriger compteur WORK index
- **Fichier**: `website/docs/commands/work/index.md`
- **Modification**: L16: `**11 commandes**` → `**12 commandes**`
- **Complexite**: Simple

---

## Phase 2 : Pages Agent Teams [US1]

> Feature majeure v1.25.0, completement absente.

### T005 - [US1] Creer page commande work-team
- **Fichier a creer**: `website/docs/commands/work/work-team.md`
- **Source**: `.claude/commands/work/work-team.md`
- **Format de reference**: `website/docs/commands/work/work-commit-push-pr.md`
- **Frontmatter**:
  ```yaml
  sidebar_position: 12
  title: "/work:work-team"
  description: "Lancer une equipe d'agents coordonnes (Agent Teams)"
  tags: [work, command]
  ```
- **Sections requises**: Objectif, Workflow, Patterns pre-configures (Audit, Feature, Debug, Review), Prerequis/activation, Modes d'affichage, Agents lies, Voir aussi
- **Complexite**: Moyenne

### T006 - [US1] Creer page skill agent-teams
- **Fichier a creer**: `website/docs/skills/agent-teams.md`
- **Source**: `.claude/skills/agent-teams/SKILL.md`
- **Format de reference**: `website/docs/skills/parallel-agents.md`
- **Frontmatter**:
  ```yaml
  sidebar_position: 2
  title: "agent-teams"
  description: "Orchestration d'equipes d'agents avec Agent Teams natif. Declencher quand l'utilisateur veut lancer une equipe d'agents ou coordonner du travail parallele."
  tags: [skill, fork]
  ```
- **Sections requises**: Configuration, Description detaillee, Patterns, Comparaison Sub-Agents vs Agent Teams, Prerequis, Raccourcis clavier, Limitations, Declenchement automatique
- **Complexite**: Moyenne

### T007 - [US1] Ajouter work-team dans index WORK
- **Fichier**: `website/docs/commands/work/index.md`
- **Modifications**:
  - Ajouter ligne dans le tableau (apres L32):
    ```
    | [`/work:work-team`](/docs/commands/work/work-team) | Lancer une equipe d'agents coordonnes (Agent Teams). |
    ```
  - Ajouter CommandCard dans CommandGrid (apres L102):
    ```jsx
    <CommandCard
      name="work-team"
      description="Lancer une equipe d'agents coordonnes (Agent Teams)."
      domain="work"
      href="/docs/commands/work/work-team"
    />
    ```
- **Complexite**: Simple

### T008 - [US1] Ajouter agent-teams dans index Skills
- **Fichier**: `website/docs/skills/index.md`
- **Modifications**:
  - Ajouter ligne dans le tableau (ordre alphabetique, apres L37 api-mocking):
    ```
    | [`agent-teams`](/docs/skills/agent-teams) | Orchestration d'equipes d'agents avec Agent Teams natif... | agent, teams, equipe d'agents |
    ```
  - Ajouter SkillCard dans SkillGrid (ordre alphabetique, apres api-mocking card):
    ```jsx
    <SkillCard
      name="agent-teams"
      description="Orchestration d'equipes d'agents avec Agent Teams natif. Declencher quand l'utilisateur ve"
      keywords={["agent","teams","equipe d'agents","swarm"]}
      context="fork"
      href="/docs/skills/agent-teams"
    />
    ```
- **Complexite**: Simple

---

## Phase 3 : Pages P1 restantes [US2][US3][US6]

> Parallelisables car fichiers independants.

### T009 - [P] [US2] Creer guide bonnes pratiques
- **Fichier a creer**: `website/docs/guides/best-practices.md`
- **Source**: `docs/reference/best-practices.md`
- **Format de reference**: `website/docs/guides/web-development.md`
- **Frontmatter**:
  ```yaml
  sidebar_position: 6
  title: "Bonnes Pratiques"
  description: "Recommandations de Boris Cherny (createur de Claude Code) pour maximiser la productivite et la qualite"
  ```
- **Sections requises**:
  1. Verification : Le Multiplicateur de Qualite (avec citation Boris Cherny, boucle feedback, types de verification)
  2. Modele Recommande (Opus 4.6, Adaptive Thinking, tableau de choix)
  3. Prompting Avance (Challenge Claude, Preuves, Iterer vers l'elegance, Anti-patterns)
  4. Sessions Paralleles (Git worktrees, 5+ sessions, aliases)
  5. Commande Rapide Commit-Push-PR (avec citation Boris Cherny)
  6. Voir aussi (liens vers concepts, workflows)
- **Complexite**: Moyenne

### T010 - [P] [US3][US6] Creer page fonctionnalites avancees
- **Fichier a creer**: `website/docs/concepts/advanced-features.md`
- **Source**: `docs/reference/advanced-features.md`
- **Format de reference**: `website/docs/concepts/output-styles.md`
- **Frontmatter**:
  ```yaml
  sidebar_position: 9
  title: "Fonctionnalites Avancees"
  description: "Opus 4.6, Agent Teams, Plugins, LSP, MCP et autres capacites avancees"
  ```
- **Sections requises**:
  1. Opus 4.6 (Adaptive Thinking 4 niveaux, 1M tokens, 128k output, Context Compaction, exemple code API)
  2. Agent Teams (resume avec renvoi vers `/docs/commands/work/work-team` et `/docs/skills/agent-teams`)
  3. Plugins (structure, manifeste, utilisation, namespacing)
  4. LSP (activation, 12 langages, quand utiliser LSP vs Grep)
  5. MCP Configuration (serveurs de base, serveurs Boris Cherny, variables d'env)
  6. CLAUDE.md @imports (syntaxe, regles, niveaux recursifs)
  7. Voir aussi
- **Complexite**: Complexe

---

## Phase 4 : Configuration sidebar [US2][US6]

> Depend de T009, T010 (pages doivent exister avant d'etre referencees).

### T011 - [US2] Ajouter best-practices dans sidebar Guides
- **Fichier**: `website/sidebars.ts`
- **Modification**: Ajouter `'guides/best-practices'` dans la liste items de guidesSidebar (apres L338 `'guides/migration'`)
- **Complexite**: Simple

### T012 - [US6] Ajouter advanced-features dans sidebar Concepts
- **Fichier**: `website/sidebars.ts`
- **Modification**: Ajouter `'concepts/advanced-features'` dans la liste items de conceptsSidebar (apres L37 `'concepts/output-styles'`)
- **Complexite**: Simple

---

## Phase 5 : Style Explanatory [US4]

### T013 - [US4] Ajouter style explanatory dans output-styles
- **Fichier**: `website/docs/concepts/output-styles.md`
- **Source**: `.claude/output-styles/explanatory.md`
- **Modifications**:
  1. Ajouter `├── explanatory.md    # Raisonnement detaille` dans la structure des fichiers (apres L46 teaching.md)
  2. Ajouter section "### Explanatory (Raisonnement detaille)" apres Teaching (apres L96), avec:
     - Quand l'utiliser: Comprendre le "pourquoi", analyse de decisions, debugging conceptuel
     - Caracteristiques: Raisonnement structure, contexte et motivation, alternatives expliquees
     - Exemple de reponse
     - Note: "Recommande par Boris Cherny"
  3. Ajouter ligne dans le tableau cas d'usage (L371-379):
     ```
     | Comprendre une decision | `explanatory` |
     ```
- **Complexite**: Simple

---

## Phase 6 : Verification [CS-001..CS-005]

### T014 - [CS-005] Build de verification
- **Commande**: `cd website && npm run build`
- **Critere**: Build passe sans erreur
- **Actions si erreur**: Corriger les liens brises, frontmatter invalide, imports manquants
- **Complexite**: Simple

### T015 - [CS-001..CS-004] Verification criteres de succes
- **Verifications**:
  - [ ] CS-001: Compteurs corrects (42 skills dans navbar, footer, index)
  - [ ] CS-002: 121 commandes documentees (work-team ajoutee)
  - [ ] CS-003: 42 skills documentes (agent-teams ajoutee)
  - [ ] CS-004: 3 pages majeures accessibles (Agent Teams, Best Practices, Opus 4.6)
  - [ ] CS-005: Build OK
- **Complexite**: Simple

---

## Diagramme d'execution

```
Phase 1 (T001-T004)  ──▶  Phase 2 (T005-T008)  ──▶  Phase 4 (T011-T012)
   Compteurs                  Agent Teams               Sidebar config
                                    │
                                    ├──▶  Phase 3 (T009 [P] + T010 [P])
                                    │        Bonnes Pratiques + Avancees
                                    │
                                    ├──▶  Phase 5 (T013)
                                    │        Style Explanatory
                                    │
                                    └──▶  Phase 6 (T014-T015)
                                             Verification
```

## Estimation globale

| Phase | Taches | Complexite |
|-------|--------|------------|
| Phase 1 | 4 taches simples | Simple |
| Phase 2 | 2 creations + 2 modifications | Moyenne |
| Phase 3 | 2 creations [P] | Moyenne/Complexe |
| Phase 4 | 2 modifications simples | Simple |
| Phase 5 | 1 modification | Simple |
| Phase 6 | 2 verifications | Simple |
| **Total** | **15 taches** | **Moyenne** |

---

**Version**: 1.0 | **Cree par**: /work:work-plan | **Date**: 2026-02-06
