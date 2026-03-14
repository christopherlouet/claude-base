# Plan d'implémentation : Amélioration Documentation Docusaurus

**Branche**: `feature/doc-improvements`
**Date**: 2026-01-20
**Spec**: [specs/doc-improvements/spec.md](./spec.md)
**Statut**: Completed

---

## Résumé

Enrichir la documentation Docusaurus existante avec :
- 8 tutoriels progressifs (débutant → avancé)
- 1 page FAQ complète avec 20+ questions
- 15+ exemples de code par domaine
- Diagrammes Mermaid pour les workflows et décisions
- Guide de migration vers claude-socle
- Système de badges de niveau

**Approche** : Documentation-as-code avec Mermaid, intégration dans la structure Docusaurus existante, réutilisation des composants React existants.

---

## Contexte Technique

| Aspect | Choix | Notes |
|--------|-------|-------|
| **Framework** | Docusaurus 3.7.0 | Déjà configuré |
| **Langage** | TypeScript + MDX | Composants React dans markdown |
| **Diagrammes** | Mermaid | Intégré à Docusaurus via @docusaurus/theme-mermaid |
| **Composants** | React 18 | Réutiliser CommandCard, AgentCard, etc. |
| **Build** | npm run generate + build | Scripts existants |
| **Recherche** | @easyops-cn/docusaurus-search-local | Déjà configuré |

### Contraintes

- Conserver la structure de navigation existante (8 sidebars)
- Ne pas modifier les scripts de génération automatique (generate-all.ts)
- Fichiers markdown uniquement pour les tutoriels/FAQ (pas de génération)
- Diagrammes Mermaid pour la maintenabilité (pas de SVG statiques)

### Performance attendue

| Métrique | Cible |
|----------|-------|
| Build time | < 2 minutes |
| Lighthouse score | > 90 |
| Mobile responsive | 320px - 1920px |

---

## Vérification Conventions

- [x] Respecte les conventions du projet (CLAUDE.md)
- [x] Cohérent avec l'architecture existante (sidebars.ts)
- [x] Pas d'over-engineering (markdown + Mermaid)
- [x] Tests planifiés (validation manuelle des exemples)

---

## Structure du Projet

### Documentation (cette feature)

```
specs/doc-improvements/
├── spec.md           # Spécification fonctionnelle ✓
├── plan.md           # Ce fichier ✓
└── tasks.md          # Découpage en tâches (à créer)
```

### Code Source (fichiers à créer/modifier)

```
website/
├── docs/
│   ├── tutorials/                    # NOUVEAU - 8 tutoriels
│   │   ├── index.md
│   │   ├── 01-premier-projet.md
│   │   ├── 02-feature-react.md
│   │   ├── 03-api-rest-node.md
│   │   ├── 04-flutter-supabase.md
│   │   ├── 05-audit-securite.md
│   │   ├── 06-cicd-github.md
│   │   ├── 07-refactoring-legacy.md
│   │   └── 08-proxmox-infra.md
│   ├── guides/
│   │   ├── faq.md                    # NOUVEAU - FAQ unique
│   │   ├── troubleshooting.md        # NOUVEAU - Erreurs courantes
│   │   └── migration.md              # NOUVEAU - Guide migration
│   ├── examples/                     # NOUVEAU - Exemples par domaine
│   │   ├── index.md
│   │   ├── web/
│   │   │   ├── react-component.md
│   │   │   ├── react-hook.md
│   │   │   └── nextjs-api.md
│   │   ├── mobile/
│   │   │   ├── flutter-screen.md
│   │   │   └── flutter-bloc.md
│   │   ├── api/
│   │   │   ├── rest-endpoint.md
│   │   │   ├── graphql-resolver.md
│   │   │   └── trpc-procedure.md
│   │   └── ops/
│   │       ├── docker-setup.md
│   │       ├── ci-pipeline.md
│   │       ├── terraform-module.md
│   │       └── proxmox-vm.md
│   └── concepts/
│       └── architecture.md           # MODIFIER - Ajouter diagrammes Mermaid
├── src/
│   ├── components/
│   │   ├── TutorialCard.tsx          # NOUVEAU - Card pour tutoriels
│   │   ├── DifficultyBadge.tsx       # NOUVEAU - Badge niveau
│   │   ├── CommandFinder.tsx         # NOUVEAU (P3) - Recherche interactive
│   │   └── MermaidDiagram.tsx        # NOUVEAU - Wrapper Mermaid (optionnel)
│   └── css/
│       └── custom.css                # MODIFIER - Styles badges
├── sidebars.ts                       # MODIFIER - Ajouter tutorialsSidebar
└── docusaurus.config.ts              # MODIFIER - Activer Mermaid si pas fait
```

---

## Fichiers Impactés

### À créer

| Fichier | Responsabilité | US |
|---------|----------------|-----|
| `website/docs/tutorials/index.md` | Index des tutoriels avec cards | US1 |
| `website/docs/tutorials/01-premier-projet.md` | Tutoriel débutant | US1 |
| `website/docs/tutorials/02-feature-react.md` | Tutoriel React | US1 |
| `website/docs/tutorials/03-api-rest-node.md` | Tutoriel API | US1 |
| `website/docs/tutorials/04-flutter-supabase.md` | Tutoriel Mobile | US1 |
| `website/docs/tutorials/05-audit-securite.md` | Tutoriel Sécurité | US1 |
| `website/docs/tutorials/06-cicd-github.md` | Tutoriel CI/CD | US1 |
| `website/docs/tutorials/07-refactoring-legacy.md` | Tutoriel Avancé | US1 |
| `website/docs/tutorials/08-proxmox-infra.md` | Tutoriel Infra | US1 |
| `website/docs/guides/faq.md` | FAQ avec 20+ questions | US2 |
| `website/docs/guides/troubleshooting.md` | Erreurs et diagnostics | US2 |
| `website/docs/guides/migration.md` | Guide migration | US5 |
| `website/docs/examples/index.md` | Index des exemples | US3 |
| `website/docs/examples/web/*.md` | 3 exemples Web | US3 |
| `website/docs/examples/mobile/*.md` | 2 exemples Mobile | US3 |
| `website/docs/examples/api/*.md` | 3 exemples API | US3 |
| `website/docs/examples/ops/*.md` | 4 exemples Ops | US3 |
| `website/src/components/TutorialCard.tsx` | Composant card tutoriel | US1/US6 |
| `website/src/components/DifficultyBadge.tsx` | Badge de niveau | US6 |

### À modifier

| Fichier | Modification | US |
|---------|--------------|-----|
| `website/sidebars.ts` | Ajouter tutorialsSidebar et examplesSidebar | US1/US3 |
| `website/docusaurus.config.ts` | Activer @docusaurus/theme-mermaid | US4 |
| `website/src/css/custom.css` | Styles pour badges et tutoriels | US6 |
| `website/docs/concepts/architecture.md` | Ajouter diagrammes Mermaid | US4 |
| `website/docs/workflow/*.md` | Ajouter diagrammes Mermaid | US4 |

---

## Approche Choisie

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    DOCUMENTATION DOCUSAURUS                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │  Tutoriels   │  │     FAQ      │  │   Exemples   │           │
│  │   (8 pages)  │  │   (1 page)   │  │  (12 pages)  │           │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘           │
│         │                 │                 │                    │
│         ▼                 ▼                 ▼                    │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │               Composants React partagés                  │    │
│  │  (TutorialCard, DifficultyBadge, CommandCard existant)   │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                   │
│                              ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              Navigation (sidebars.ts)                    │    │
│  │   tutorialsSidebar │ examplesSidebar │ guidesSidebar     │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Diagrammes Mermaid (US4)

```
┌─────────────────────────────────────────────────────────────────┐
│                    TYPES DE DIAGRAMMES                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. Workflow principal (flowchart)                               │
│     Explore → Specify → Plan → Code → Commit                     │
│                                                                  │
│  2. Diagramme de décision (flowchart avec conditions)            │
│     "Quelle commande utiliser ?" avec branches                   │
│                                                                  │
│  3. Comparaison Commands/Agents/Skills (class diagram)           │
│     Relations et différences entre concepts                      │
│                                                                  │
│  4. Architecture du socle (architecture diagram)                 │
│     Vue d'ensemble des composants                                │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Justification

- **Mermaid** : Modifiable en markdown, versionnable, rendu automatique par Docusaurus
- **Composants React** : Réutilisation du pattern existant (CommandCard, etc.)
- **Structure par domaine** : Cohérent avec la navigation existante (WORK, DEV, QA, OPS)
- **FAQ unique** : Une seule page avec ancres, meilleur pour la recherche

### Alternatives considérées

| Alternative | Pourquoi rejetée |
|-------------|------------------|
| SVG statiques | Difficiles à maintenir, pas versionnables |
| FAQ multi-pages | Fragmente la navigation, mauvais pour la recherche |
| Vidéos intégrées | Hors scope (HS-001), complexité de maintenance |
| Génération auto des tutos | Hors scope (HS-005), trop complexe |

---

## Phases d'Implémentation

### Phase 1 : Setup (bloquant)

**Objectif**: Configurer Mermaid et préparer la structure

- [ ] T001 - [P] Configurer @docusaurus/theme-mermaid dans `docusaurus.config.ts`
- [ ] T002 - [P] Créer la structure des dossiers (`tutorials/`, `examples/`)
- [ ] T003 - [P] Créer le composant `TutorialCard.tsx`
- [ ] T004 - [P] Créer le composant `DifficultyBadge.tsx`
- [ ] T005 - Modifier `sidebars.ts` pour ajouter les nouvelles sections

**Checkpoint**: Structure prête, Mermaid fonctionnel.

---

### Phase 2 : User Story 1 - Tutoriels (P1 - MVP) 🎯

**Objectif**: 8 tutoriels progressifs accessibles depuis le menu

- [ ] T006 - [US1] Créer `tutorials/index.md` avec liste des tutoriels
- [ ] T007 - [P] [US1] Créer `tutorials/01-premier-projet.md` (Débutant, 15 min)
- [ ] T008 - [P] [US1] Créer `tutorials/02-feature-react.md` (Débutant, 30 min)
- [ ] T009 - [P] [US1] Créer `tutorials/03-api-rest-node.md` (Intermédiaire, 45 min)
- [ ] T010 - [P] [US1] Créer `tutorials/04-flutter-supabase.md` (Intermédiaire, 60 min)
- [ ] T011 - [P] [US1] Créer `tutorials/05-audit-securite.md` (Intermédiaire, 30 min)
- [ ] T012 - [P] [US1] Créer `tutorials/06-cicd-github.md` (Intermédiaire, 45 min)
- [ ] T013 - [P] [US1] Créer `tutorials/07-refactoring-legacy.md` (Avancé, 60 min)
- [ ] T014 - [P] [US1] Créer `tutorials/08-proxmox-infra.md` (Avancé, 60 min)
- [ ] T015 - [US1] Vérifier la navigation et les liens entre tutoriels

**Checkpoint**: US1 fonctionnelle - 8 tutoriels accessibles et navigables.

---

### Phase 3 : User Story 2 - FAQ (P1 - MVP) 🎯

**Objectif**: FAQ complète avec 20+ questions et troubleshooting

- [ ] T016 - [US2] Créer `guides/faq.md` avec structure et TOC
- [ ] T017 - [P] [US2] Rédiger section "Questions Générales" (5 questions)
- [ ] T018 - [P] [US2] Rédiger section "Commands" (5 questions)
- [ ] T019 - [P] [US2] Rédiger section "Agents & Skills" (5 questions)
- [ ] T020 - [P] [US2] Rédiger section "Workflow" (5 questions)
- [ ] T021 - [US2] Créer `guides/troubleshooting.md` avec erreurs courantes
- [ ] T022 - [US2] Ajouter liens vers issues GitHub pour problèmes non résolus

**Checkpoint**: US2 fonctionnelle - FAQ consultable et trouvable via recherche.

---

### Phase 4 : User Story 3 - Exemples (P1 - MVP) 🎯

**Objectif**: 15 exemples de code complets organisés par domaine

- [ ] T023 - [US3] Créer `examples/index.md` avec organisation par domaine
- [ ] T024 - [P] [US3] Créer `examples/web/react-component.md`
- [ ] T025 - [P] [US3] Créer `examples/web/react-hook.md`
- [ ] T026 - [P] [US3] Créer `examples/web/nextjs-api.md`
- [ ] T027 - [P] [US3] Créer `examples/mobile/flutter-screen.md`
- [ ] T028 - [P] [US3] Créer `examples/mobile/flutter-bloc.md`
- [ ] T029 - [P] [US3] Créer `examples/api/rest-endpoint.md`
- [ ] T030 - [P] [US3] Créer `examples/api/graphql-resolver.md`
- [ ] T031 - [P] [US3] Créer `examples/api/trpc-procedure.md`
- [ ] T032 - [P] [US3] Créer `examples/ops/docker-setup.md`
- [ ] T033 - [P] [US3] Créer `examples/ops/ci-pipeline.md`
- [ ] T034 - [P] [US3] Créer `examples/ops/terraform-module.md`
- [ ] T035 - [P] [US3] Créer `examples/ops/proxmox-vm.md`
- [ ] T036 - [US3] Vérifier que tous les exemples sont copiables et exécutables

**Checkpoint**: US3 fonctionnelle - 12+ exemples accessibles par domaine.

---

### Phase 5 : User Story 4 - Visuels Mermaid (P1 - MVP) 🎯

**Objectif**: Diagrammes Mermaid dans les pages clés

- [ ] T037 - [US4] Créer diagramme workflow principal dans `workflow/index.md`
- [ ] T038 - [US4] Créer diagramme de décision "Quelle commande" dans `guides/cheatsheet.md`
- [ ] T039 - [US4] Créer diagramme comparaison Commands/Agents/Skills dans `concepts/architecture.md`
- [ ] T040 - [US4] Ajouter diagramme architecture socle dans `concepts/overview.md`
- [ ] T041 - [US4] Vérifier le rendu mobile des diagrammes

**Checkpoint**: US4 fonctionnelle - 4+ diagrammes Mermaid visibles.

---

### Phase 6 : User Story 5 - Guide Migration (P2)

**Objectif**: Guide pour migrer un projet existant vers claude-socle

- [ ] T042 - [US5] Créer `guides/migration.md` avec structure
- [ ] T043 - [P] [US5] Rédiger section "Migration projet Web"
- [ ] T044 - [P] [US5] Rédiger section "Migration projet Mobile"
- [ ] T045 - [P] [US5] Rédiger section "Migration projet API"
- [ ] T046 - [US5] Ajouter checklist de validation
- [ ] T047 - [US5] Ajouter commande de vérification

**Checkpoint**: US5 fonctionnelle - Guide migration consultable.

---

### Phase 7 : User Story 6 - Navigation par niveau (P2)

**Objectif**: Badges de difficulté sur les pages

- [ ] T048 - [US6] Ajouter badges aux tutoriels
- [ ] T049 - [US6] Ajouter styles CSS pour les badges dans `custom.css`
- [ ] T050 - [US6] Ajouter liens "Voir aussi" en bas des tutoriels
- [ ] T051 - [US6] Vérifier l'ordre des tutoriels par difficulté

**Checkpoint**: US6 fonctionnelle - Badges visibles, navigation améliorée.

---

### Phase 8 : User Story 7 - Recherche rapide (P3)

**Objectif**: Composant de recherche de commandes interactif

- [ ] T052 - [US7] Créer `CommandFinder.tsx` (si temps disponible)
- [ ] T053 - [US7] Intégrer dans la page d'accueil ou cheatsheet

**Checkpoint**: US7 fonctionnelle (optionnel).

---

### Phase 9 : Polish & Qualité

- [ ] T054 - [P] Vérifier tous les liens internes
- [ ] T055 - [P] Vérifier le build (`npm run build`)
- [ ] T056 - [P] Vérifier le rendu mobile
- [ ] T057 - [P] Vérifier la recherche locale
- [ ] T058 - Mise à jour du README si nécessaire
- [ ] T059 - Code review

**Checkpoint**: Documentation prête pour déploiement.

---

## Risques et Mitigations

| Risque | Impact | Probabilité | Mitigation |
|--------|--------|-------------|------------|
| Mermaid non activé | Élevé | Faible | Vérifier config Phase 1, fallback ASCII |
| Tutoriels trop longs | Moyen | Moyenne | Estimer durées, découper si > 60 min |
| Exemples non fonctionnels | Élevé | Moyenne | Tester chaque exemple sur projet réel |
| Build trop lent | Faible | Faible | Mesurer avant/après, optimiser si > 3 min |
| Diagrammes illisibles mobile | Moyen | Moyenne | Tester sur 320px, simplifier si nécessaire |

---

## Dépendances et Ordre d'Exécution

### Dépendances entre phases

```
Phase 1 (Setup) ──┬──▶ Phase 2 (Tutoriels US1)
                  │
                  ├──▶ Phase 3 (FAQ US2)
                  │
                  ├──▶ Phase 4 (Exemples US3)
                  │
                  └──▶ Phase 5 (Visuels US4)

Phases 2-5 (P1) ──┬──▶ Phase 6 (Migration US5)
                  │
                  └──▶ Phase 7 (Navigation US6)

Phases 6-7 (P2) ──────▶ Phase 8 (Recherche US7 - optionnel)

Toutes les phases ─────▶ Phase 9 (Polish)
```

### Parallélisation recommandée

- **Phase 1** : Toutes les tâches [P] en parallèle
- **Phases 2-5** : Peuvent démarrer en parallèle après Phase 1
- **Au sein de chaque phase** : Les tutoriels/exemples [P] en parallèle

---

## Critères de Validation

### Avant de commencer (Gate 1)
- [x] Spec approuvée
- [ ] Plan reviewé
- [ ] Mermaid vérifié dans Docusaurus

### Avant chaque merge (Gate 2)
- [ ] Build réussit (`npm run build`)
- [ ] Pas de liens cassés
- [ ] Exemples testés

### Avant déploiement (Gate 3)
- [ ] 8 tutoriels complets
- [ ] 20+ questions FAQ
- [ ] 12+ exemples
- [ ] 4+ diagrammes Mermaid
- [ ] Guide migration fonctionnel
- [ ] Lighthouse > 90

---

## Notes

- Les tutoriels utilisent un repo exemple `claude-socle-examples` (à créer séparément)
- Les exemples doivent montrer entrée (commande) ET sortie (résultat)
- Chaque tutoriel doit être testable indépendamment en < 20-60 min
- La FAQ doit couvrir les questions des issues GitHub existantes

---

**Version**: 1.0 | **Créé**: 2026-01-20 | **Dernière modification**: 2026-01-20
