# Tâches : Consolidation Documentation docs/ ↔ website/

**Plan**: `specs/docs-website-consolidation/plan.md`

---

## Phase 1 — Script sync-docs.ts [US4]

- [ ] **T001** [US4] — Créer `website/scripts/sync-docs.ts` avec la structure de base : imports, constantes (DOCS_DIR, WEBSITE_DOCS_DIR), table de mapping des liens, fonction `slugify()` (kebab-case)
  - Fichier: `website/scripts/sync-docs.ts` (CRÉER)
  - Pattern: copier structure de `generate-agent-docs.ts`

- [ ] **T002** [US4] — Implémenter `syncDirectory()` : lit tous les .md d'un répertoire source, ajoute/met à jour le frontmatter Docusaurus, réécrit les liens relatifs via table de mapping, écrit dans le répertoire destination
  - Fichier: `website/scripts/sync-docs.ts`
  - Utiliser: `generateFrontmatter()`, `parseFrontmatter()`, `extractFirstHeading()`, `escapeMdx()`

- [ ] **T003** [US4] — Implémenter `syncFile()` : sync un fichier unique avec slug personnalisé (pour les docs racine ARCHITECTURE.md → concepts/architecture.md)
  - Fichier: `website/scripts/sync-docs.ts`

- [ ] **T004** [US4] — Implémenter `cleanStaleFiles()` : supprime les fichiers dans la destination qui n'ont plus de source correspondante (sauf les fichiers website-only comme faq.md, troubleshooting.md)
  - Fichier: `website/scripts/sync-docs.ts`
  - Whitelist: `index.md`, `faq.md`, `troubleshooting.md`, `migration.md`, `startup.md`

- [ ] **T005** [US4] — Exporter `syncDocs()` comme fonction principale et ajouter dans `generate-all.ts`
  - Fichier: `website/scripts/sync-docs.ts` + `website/scripts/generate-all.ts`
  - Ajouter: `import { syncDocs } from './sync-docs.js'` + `await syncDocs()`

- [ ] **T006** [US4] — Ajouter script npm `"generate:sync-docs"` dans `website/package.json`
  - Fichier: `website/package.json`

## Phase 2 — Guides [US1]

- [ ] **T007** [US1] — Supprimer les copies manuelles de guides dans `website/docs/guides/` qui seront remplacées
  - Fichiers à supprimer: `web-development.md`, `mobile-development.md`, `api-development.md`, `data-engineering.md`, `best-practices.md`
  - Conserver: `index.md`, `faq.md`, `troubleshooting.md`, `migration.md`, `startup.md` (website-only)

- [ ] **T008** [US1] — Exécuter `npm run generate:sync-docs` et vérifier que les 8 guides sont copiés avec frontmatter
  - Source: `docs/guides/` (WEB-GUIDE.md, MOBILE-GUIDE.md, API-GUIDE.md, DATA-GUIDE.md, BIZ-GUIDE.md, GROWTH-GUIDE.md, INFRA-GUIDE.md, PROMPTING-GUIDE.md)

- [ ] **T009** [US1] — Mettre à jour `website/sidebars.ts` section Guides : remplacer les items hardcodés par les nouveaux slugs
  - Fichier: `website/sidebars.ts`
  - Ex: `'guides/web-development'` → `'guides/web-guide'`

## Phase 3 — Références [US2]

- [ ] **T010** [P] [US2] — Supprimer les copies manuelles de référence dans `website/docs/reference/` qui seront remplacées
  - Fichiers à supprimer: `cheatsheet.md`
  - Conserver: `index.md`, `commands-matrix.md`, `agents-matrix.md`, `scripts.md` (website-only)

- [ ] **T011** [P] [US2] — Exécuter sync et vérifier les 7 fichiers de référence copiés
  - Source: `docs/reference/` (advanced-features.md, agents-catalog.md, best-practices.md, commands.md, hooks-reference.md, project-structures.md, skills-catalog.md)

- [ ] **T012** [US2] — Mettre à jour `website/sidebars.ts` section Reference : ajouter les nouveaux items
  - Fichier: `website/sidebars.ts`

## Phase 4 — Docs racine → Concepts [US3]

- [ ] **T013** [US3] — Ajouter la sync des docs racine dans `syncDocs()` : ARCHITECTURE.md → concepts/architecture.md, WORKFLOWS.md → concepts/workflows.md, CUSTOMIZATION.md → concepts/customization.md
  - Fichier: `website/scripts/sync-docs.ts`

- [ ] **T014** [US3] — Mettre à jour `website/sidebars.ts` section Concepts : ajouter architecture, workflows, customization
  - Fichier: `website/sidebars.ts`

## Phase 5 — Vérification

- [ ] **T015** — Exécuter `npm run generate` complet et vérifier tous les fichiers générés
  - Commande: `cd website && npm run generate`

- [ ] **T016** — Build Docusaurus complet sans erreur
  - Commande: `cd website && npm run build`
  - Attendu: exit 0

- [ ] **T017** — Vérifier que les pages website-only sont préservées (faq, troubleshooting, migration, startup, index)
  - Commande: vérifier présence dans `website/docs/guides/`

- [ ] **T018** — Ajouter commentaire "auto-generated" en haut des fichiers syncés (EF-04)
  - Fichier: `website/scripts/sync-docs.ts` — ajouter `<!-- Auto-generated from docs/ - DO NOT EDIT -->` après le frontmatter

---

## Résumé

| Phase | Tâches | US | Parallélisable |
|-------|--------|----|----------------|
| 1 (Script) | T001-T006 | US4 | T001-T003 séquentiels |
| 2 (Guides) | T007-T009 | US1 | Séquentiel |
| 3 (Références) | T010-T012 | US2 | T010+T011 [P] avec Phase 2 |
| 4 (Concepts) | T013-T014 | US3 | Après Phase 1 |
| 5 (Vérification) | T015-T018 | — | Séquentiel |

**Total**: 18 tâches, complexité Moyenne, 1 fichier TS créé + 4 modifiés + N fichiers supprimés/générés.
