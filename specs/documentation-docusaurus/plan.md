# Plan : Documentation Docusaurus pour claude-socle

## Objectif

Creer une documentation complete et interactive au format Docusaurus 3.x, publiable sur GitHub Pages, couvrant les 100 commandes, 37 agents, 24 skills et 15 rules du projet claude-socle.

---

## Fichiers a creer

### Infrastructure Docusaurus

| Fichier | Description |
|---------|-------------|
| `website/docusaurus.config.ts` | Configuration principale Docusaurus |
| `website/sidebars.ts` | Configuration de la sidebar avec categories |
| `website/package.json` | Dependances npm (Docusaurus 3.x, plugins) |
| `website/tsconfig.json` | Configuration TypeScript |
| `website/src/css/custom.css` | Styles personnalises |
| `website/static/img/logo.svg` | Logo du projet |

### Composants React personnalises

| Fichier | Description |
|---------|-------------|
| `website/src/components/CommandCard.tsx` | Carte de commande avec tags et description |
| `website/src/components/AgentCard.tsx` | Carte d'agent avec modele et outils |
| `website/src/components/SkillCard.tsx` | Carte de skill avec mots-cles |
| `website/src/components/WorkflowDiagram.tsx` | Diagramme de workflow interactif |
| `website/src/components/SearchMatrix.tsx` | Matrice de recherche filtrable |
| `website/src/components/FeatureComparison.tsx` | Tableau comparatif Commands/Agents/Skills |

### Pages d'introduction (4 pages)

| Fichier | Description |
|---------|-------------|
| `website/docs/intro/index.md` | Page d'accueil - Qu'est-ce que claude-socle |
| `website/docs/intro/quick-start.md` | Demarrage rapide en 5 minutes |
| `website/docs/intro/architecture.md` | Architecture et concepts cles |
| `website/docs/intro/installation.md` | Installation et configuration |

### Pages de workflows (8 pages)

| Fichier | Description |
|---------|-------------|
| `website/docs/workflow/index.md` | Vue d'ensemble des workflows |
| `website/docs/workflow/explore-plan-code-commit.md` | Workflow principal |
| `website/docs/workflow/feature.md` | Workflow nouvelle feature |
| `website/docs/workflow/bugfix.md` | Workflow correction de bug |
| `website/docs/workflow/release.md` | Workflow release |
| `website/docs/workflow/launch.md` | Workflow lancement produit |
| `website/docs/workflow/tdd.md` | Workflow TDD |
| `website/docs/workflow/choosing-workflow.md` | Guide de choix du workflow |

### Pages de commandes (100 pages)

**WORK (10 commandes)**
| Fichier | Commande |
|---------|----------|
| `website/docs/commands/work/index.md` | Vue d'ensemble WORK |
| `website/docs/commands/work/work-explore.md` | /work-explore |
| `website/docs/commands/work/work-plan.md` | /work-plan |
| `website/docs/commands/work/work-commit.md` | /work-commit |
| `website/docs/commands/work/work-pr.md` | /work-pr |
| `website/docs/commands/work/work-flow-feature.md` | /work-flow-feature |
| `website/docs/commands/work/work-flow-bugfix.md` | /work-flow-bugfix |
| `website/docs/commands/work/work-flow-release.md` | /work-flow-release |
| `website/docs/commands/work/work-flow-launch.md` | /work-flow-launch |
| `website/docs/commands/work/work-clarify.md` | /work-clarify |
| `website/docs/commands/work/work-specify.md` | /work-specify |

**DEV (16 commandes)**
| Fichier | Commande |
|---------|----------|
| `website/docs/commands/dev/index.md` | Vue d'ensemble DEV |
| `website/docs/commands/dev/dev-tdd.md` | /dev-tdd |
| `website/docs/commands/dev/dev-test.md` | /dev-test |
| `website/docs/commands/dev/dev-testing-setup.md` | /dev-testing-setup |
| `website/docs/commands/dev/dev-debug.md` | /dev-debug |
| `website/docs/commands/dev/dev-refactor.md` | /dev-refactor |
| `website/docs/commands/dev/dev-api.md` | /dev-api |
| `website/docs/commands/dev/dev-api-versioning.md` | /dev-api-versioning |
| `website/docs/commands/dev/dev-component.md` | /dev-component |
| `website/docs/commands/dev/dev-hook.md` | /dev-hook |
| `website/docs/commands/dev/dev-error-handling.md` | /dev-error-handling |
| `website/docs/commands/dev/dev-react-perf.md` | /dev-react-perf |
| `website/docs/commands/dev/dev-mcp.md` | /dev-mcp |
| `website/docs/commands/dev/dev-flutter.md` | /dev-flutter |
| `website/docs/commands/dev/dev-supabase.md` | /dev-supabase |
| `website/docs/commands/dev/dev-graphql.md` | /dev-graphql |
| `website/docs/commands/dev/dev-neovim.md` | /dev-neovim |

**QA (11 commandes)**
| Fichier | Commande |
|---------|----------|
| `website/docs/commands/qa/index.md` | Vue d'ensemble QA |
| `website/docs/commands/qa/qa-review.md` | /qa-review |
| `website/docs/commands/qa/qa-security.md` | /qa-security |
| `website/docs/commands/qa/qa-perf.md` | /qa-perf |
| `website/docs/commands/qa/qa-a11y.md` | /qa-a11y |
| `website/docs/commands/qa/qa-audit.md` | /qa-audit |
| `website/docs/commands/qa/qa-responsive.md` | /qa-responsive |
| `website/docs/commands/qa/qa-automation.md` | /qa-automation |
| `website/docs/commands/qa/qa-coverage.md` | /qa-coverage |
| `website/docs/commands/qa/qa-kaizen.md` | /qa-kaizen |
| `website/docs/commands/qa/qa-mobile.md` | /qa-mobile |
| `website/docs/commands/qa/qa-neovim.md` | /qa-neovim |

**OPS (24 commandes)**
| Fichier | Commande |
|---------|----------|
| `website/docs/commands/ops/index.md` | Vue d'ensemble OPS |
| `website/docs/commands/ops/ops-hotfix.md` | /ops-hotfix |
| `website/docs/commands/ops/ops-release.md` | /ops-release |
| `website/docs/commands/ops/ops-deps.md` | /ops-deps |
| `website/docs/commands/ops/ops-docker.md` | /ops-docker |
| `website/docs/commands/ops/ops-migrate.md` | /ops-migrate |
| `website/docs/commands/ops/ops-ci.md` | /ops-ci |
| `website/docs/commands/ops/ops-monitoring.md` | /ops-monitoring |
| `website/docs/commands/ops/ops-database.md` | /ops-database |
| `website/docs/commands/ops/ops-health.md` | /ops-health |
| `website/docs/commands/ops/ops-env.md` | /ops-env |
| `website/docs/commands/ops/ops-backup.md` | /ops-backup |
| `website/docs/commands/ops/ops-load-testing.md` | /ops-load-testing |
| `website/docs/commands/ops/ops-cost-optimization.md` | /ops-cost-optimization |
| `website/docs/commands/ops/ops-disaster-recovery.md` | /ops-disaster-recovery |
| `website/docs/commands/ops/ops-infra-code.md` | /ops-infra-code |
| `website/docs/commands/ops/ops-secrets-management.md` | /ops-secrets-management |
| `website/docs/commands/ops/ops-k8s.md` | /ops-k8s |
| `website/docs/commands/ops/ops-vps.md` | /ops-vps |
| `website/docs/commands/ops/ops-mobile-release.md` | /ops-mobile-release |
| `website/docs/commands/ops/ops-gitflow-init.md` | /ops-gitflow-init |
| `website/docs/commands/ops/ops-gitflow-feature.md` | /ops-gitflow-feature |
| `website/docs/commands/ops/ops-gitflow-release.md` | /ops-gitflow-release |
| `website/docs/commands/ops/ops-gitflow-hotfix.md` | /ops-gitflow-hotfix |
| `website/docs/commands/ops/ops-grafana-dashboard.md` | /ops-grafana-dashboard |
| `website/docs/commands/ops/ops-observability-stack.md` | /ops-observability-stack |

**DOC (9 commandes)**
| Fichier | Commande |
|---------|----------|
| `website/docs/commands/doc/index.md` | Vue d'ensemble DOC |
| `website/docs/commands/doc/doc-generate.md` | /doc-generate |
| `website/docs/commands/doc/doc-changelog.md` | /doc-changelog |
| `website/docs/commands/doc/doc-explain.md` | /doc-explain |
| `website/docs/commands/doc/doc-onboard.md` | /doc-onboard |
| `website/docs/commands/doc/doc-i18n.md` | /doc-i18n |
| `website/docs/commands/doc/doc-fix-issue.md` | /doc-fix-issue |
| `website/docs/commands/doc/doc-api-spec.md` | /doc-api-spec |
| `website/docs/commands/doc/doc-readme.md` | /doc-readme |
| `website/docs/commands/doc/doc-architecture.md` | /doc-architecture |

**BIZ (11 commandes)**
| Fichier | Commande |
|---------|----------|
| `website/docs/commands/biz/index.md` | Vue d'ensemble BIZ |
| `website/docs/commands/biz/biz-model.md` | /biz-model |
| `website/docs/commands/biz/biz-market.md` | /biz-market |
| `website/docs/commands/biz/biz-mvp.md` | /biz-mvp |
| `website/docs/commands/biz/biz-pricing.md` | /biz-pricing |
| `website/docs/commands/biz/biz-pitch.md` | /biz-pitch |
| `website/docs/commands/biz/biz-roadmap.md` | /biz-roadmap |
| `website/docs/commands/biz/biz-launch.md` | /biz-launch |
| `website/docs/commands/biz/biz-competitor.md` | /biz-competitor |
| `website/docs/commands/biz/biz-okr.md` | /biz-okr |
| `website/docs/commands/biz/biz-personas.md` | /biz-personas |
| `website/docs/commands/biz/biz-research.md` | /biz-research |

**GROWTH (9 commandes)**
| Fichier | Commande |
|---------|----------|
| `website/docs/commands/growth/index.md` | Vue d'ensemble GROWTH |
| `website/docs/commands/growth/growth-landing.md` | /growth-landing |
| `website/docs/commands/growth/growth-seo.md` | /growth-seo |
| `website/docs/commands/growth/growth-analytics.md` | /growth-analytics |
| `website/docs/commands/growth/growth-onboarding.md` | /growth-onboarding |
| `website/docs/commands/growth/growth-email.md` | /growth-email |
| `website/docs/commands/growth/growth-ab-test.md` | /growth-ab-test |
| `website/docs/commands/growth/growth-retention.md` | /growth-retention |
| `website/docs/commands/growth/growth-funnel.md` | /growth-funnel |
| `website/docs/commands/growth/growth-app-store-analytics.md` | /growth-app-store-analytics |

**DATA (3 commandes)**
| Fichier | Commande |
|---------|----------|
| `website/docs/commands/data/index.md` | Vue d'ensemble DATA |
| `website/docs/commands/data/data-pipeline.md` | /data-pipeline |
| `website/docs/commands/data/data-analytics.md` | /data-analytics |
| `website/docs/commands/data/data-modeling.md` | /data-modeling |

**LEGAL (5 commandes)**
| Fichier | Commande |
|---------|----------|
| `website/docs/commands/legal/index.md` | Vue d'ensemble LEGAL |
| `website/docs/commands/legal/legal-docs.md` | /legal-docs |
| `website/docs/commands/legal/legal-rgpd.md` | /legal-rgpd |
| `website/docs/commands/legal/legal-payment.md` | /legal-payment |
| `website/docs/commands/legal/legal-terms-of-service.md` | /legal-terms-of-service |
| `website/docs/commands/legal/legal-privacy-policy.md` | /legal-privacy-policy |

**ASSISTANT (1 commande)**
| Fichier | Commande |
|---------|----------|
| `website/docs/commands/assistant.md` | /assistant (orchestrateur) |

### Pages d'agents (37 pages)

| Fichier | Agent | Modele |
|---------|-------|--------|
| `website/docs/agents/index.md` | Vue d'ensemble des agents | - |
| `website/docs/agents/work-explore.md` | work-explore | haiku |
| `website/docs/agents/biz-competitor.md` | biz-competitor | haiku |
| `website/docs/agents/biz-model.md` | biz-model | haiku |
| `website/docs/agents/biz-mvp.md` | biz-mvp | haiku |
| `website/docs/agents/biz-personas.md` | biz-personas | haiku |
| `website/docs/agents/data-analytics.md` | data-analytics | haiku |
| `website/docs/agents/data-modeling.md` | data-modeling | haiku |
| `website/docs/agents/data-pipeline.md` | data-pipeline | haiku |
| `website/docs/agents/dev-component.md` | dev-component | haiku |
| `website/docs/agents/dev-debug.md` | dev-debug | sonnet |
| `website/docs/agents/dev-flutter.md` | dev-flutter | haiku |
| `website/docs/agents/dev-supabase.md` | dev-supabase | haiku |
| `website/docs/agents/dev-test.md` | dev-test | haiku |
| `website/docs/agents/doc-changelog.md` | doc-changelog | haiku |
| `website/docs/agents/doc-explain.md` | doc-explain | haiku |
| `website/docs/agents/doc-generate.md` | doc-generate | haiku |
| `website/docs/agents/doc-onboard.md` | doc-onboard | haiku |
| `website/docs/agents/growth-analytics.md` | growth-analytics | haiku |
| `website/docs/agents/growth-funnel.md` | growth-funnel | haiku |
| `website/docs/agents/growth-landing.md` | growth-landing | haiku |
| `website/docs/agents/growth-seo.md` | growth-seo | haiku |
| `website/docs/agents/legal-payment.md` | legal-payment | haiku |
| `website/docs/agents/legal-privacy-policy.md` | legal-privacy-policy | haiku |
| `website/docs/agents/legal-rgpd.md` | legal-rgpd | haiku |
| `website/docs/agents/legal-terms-of-service.md` | legal-terms-of-service | haiku |
| `website/docs/agents/ops-ci.md` | ops-ci | haiku |
| `website/docs/agents/ops-database.md` | ops-database | haiku |
| `website/docs/agents/ops-deps.md` | ops-deps | haiku |
| `website/docs/agents/ops-docker.md` | ops-docker | haiku |
| `website/docs/agents/ops-health.md` | ops-health | haiku |
| `website/docs/agents/ops-monitoring.md` | ops-monitoring | haiku |
| `website/docs/agents/qa-a11y.md` | qa-a11y | haiku |
| `website/docs/agents/qa-audit.md` | qa-audit | sonnet |
| `website/docs/agents/qa-coverage.md` | qa-coverage | haiku |
| `website/docs/agents/qa-perf.md` | qa-perf | sonnet |
| `website/docs/agents/qa-responsive.md` | qa-responsive | haiku |
| `website/docs/agents/qa-security.md` | qa-security | sonnet |

### Pages de skills (24 pages)

| Fichier | Skill |
|---------|-------|
| `website/docs/skills/index.md` | Vue d'ensemble des skills |
| `website/docs/skills/api-development.md` | api-development |
| `website/docs/skills/changelog-maintenance.md` | changelog-maintenance |
| `website/docs/skills/ci-cd-pipeline.md` | ci-cd-pipeline |
| `website/docs/skills/creating-pull-requests.md` | creating-pull-requests |
| `website/docs/skills/data-pipeline.md` | data-pipeline |
| `website/docs/skills/database-design.md` | database-design |
| `website/docs/skills/debugging-issues.md` | debugging-issues |
| `website/docs/skills/docker-containerization.md` | docker-containerization |
| `website/docs/skills/documentation-generation.md` | documentation-generation |
| `website/docs/skills/error-handling.md` | error-handling |
| `website/docs/skills/exploring-codebase.md` | exploring-codebase |
| `website/docs/skills/flutter-development.md` | flutter-development |
| `website/docs/skills/generating-commit-messages.md` | generating-commit-messages |
| `website/docs/skills/graphql-development.md` | graphql-development |
| `website/docs/skills/mobile-release.md` | mobile-release |
| `website/docs/skills/monitoring-instrumentation.md` | monitoring-instrumentation |
| `website/docs/skills/performance-optimization.md` | performance-optimization |
| `website/docs/skills/planning-implementation.md` | planning-implementation |
| `website/docs/skills/react-performance.md` | react-performance |
| `website/docs/skills/refactoring.md` | refactoring |
| `website/docs/skills/reviewing-code.md` | reviewing-code |
| `website/docs/skills/security-audit.md` | security-audit |
| `website/docs/skills/supabase-development.md` | supabase-development |
| `website/docs/skills/test-driven-development.md` | test-driven-development |

### Pages de rules (15 pages)

| Fichier | Rule |
|---------|------|
| `website/docs/rules/index.md` | Vue d'ensemble des rules |
| `website/docs/rules/api.md` | api |
| `website/docs/rules/csharp.md` | csharp |
| `website/docs/rules/flutter.md` | flutter |
| `website/docs/rules/git.md` | git |
| `website/docs/rules/go.md` | go |
| `website/docs/rules/java.md` | java |
| `website/docs/rules/php.md` | php |
| `website/docs/rules/python.md` | python |
| `website/docs/rules/react.md` | react |
| `website/docs/rules/ruby.md` | ruby |
| `website/docs/rules/rust.md` | rust |
| `website/docs/rules/security.md` | security |
| `website/docs/rules/testing.md` | testing |
| `website/docs/rules/typescript.md` | typescript |
| `website/docs/rules/workflow.md` | workflow |

### Pages de guides thematiques (6 pages)

| Fichier | Description |
|---------|-------------|
| `website/docs/guides/index.md` | Vue d'ensemble des guides |
| `website/docs/guides/web-development.md` | Guide developpement Web (React/Node) |
| `website/docs/guides/mobile-development.md` | Guide developpement Mobile (Flutter) |
| `website/docs/guides/api-development.md` | Guide developpement API |
| `website/docs/guides/data-engineering.md` | Guide Data Engineering |
| `website/docs/guides/startup.md` | Guide pour startups |

### Pages de reference (3 pages)

| Fichier | Description |
|---------|-------------|
| `website/docs/reference/index.md` | Acces rapide aux references |
| `website/docs/reference/commands-matrix.md` | Matrice des 100 commandes |
| `website/docs/reference/agents-matrix.md` | Matrice des 37 agents |
| `website/docs/reference/cheatsheet.md` | Aide-memoire rapide |

### Scripts de generation

| Fichier | Description |
|---------|-------------|
| `website/scripts/generate-command-docs.ts` | Genere les pages de commandes depuis .claude/commands |
| `website/scripts/generate-agent-docs.ts` | Genere les pages d'agents depuis .claude/agents |
| `website/scripts/generate-skill-docs.ts` | Genere les pages de skills depuis .claude/skills |
| `website/scripts/generate-rule-docs.ts` | Genere les pages de rules depuis .claude/rules |
| `website/scripts/generate-all.ts` | Script principal qui orchestre la generation |

### CI/CD

| Fichier | Description |
|---------|-------------|
| `.github/workflows/docs.yml` | GitHub Actions pour build et deploy |

---

## Fichiers a modifier

| Fichier | Modifications |
|---------|---------------|
| `package.json` (racine) | Ajouter script `docs:dev`, `docs:build`, `docs:deploy` |
| `.gitignore` | Ajouter `website/node_modules/`, `website/build/`, `website/.docusaurus/` |

---

## Tests a ecrire

### Tests unitaires des scripts de generation
- [ ] `generate-command-docs.test.ts` - Verifier la generation correcte des pages de commandes
- [ ] `generate-agent-docs.test.ts` - Verifier la generation correcte des pages d'agents
- [ ] `generate-skill-docs.test.ts` - Verifier la generation correcte des pages de skills

### Tests E2E avec Playwright (optionnel P3)
- [ ] Navigation dans la sidebar fonctionne
- [ ] Recherche retourne des resultats pertinents
- [ ] Toutes les pages sont accessibles
- [ ] Liens internes ne sont pas casses

---

## Etapes d'implementation

### Phase 1 : Infrastructure (MVP - US1)
1. [ ] Initialiser Docusaurus dans `website/`
2. [ ] Configurer `docusaurus.config.ts` avec metadata du projet
3. [ ] Configurer `sidebars.ts` avec structure de navigation
4. [ ] Creer les styles personnalises (theme claude-socle)
5. [ ] Creer les composants React de base (CommandCard, etc.)

### Phase 2 : Contenu Introduction (MVP - US1)
6. [ ] Ecrire la page d'accueil (index.md)
7. [ ] Ecrire le Quick Start (quick-start.md)
8. [ ] Ecrire l'architecture (architecture.md)
9. [ ] Ecrire l'installation (installation.md)

### Phase 3 : Scripts de generation (US2/US4)
10. [ ] Developper `generate-command-docs.ts`
11. [ ] Developper `generate-agent-docs.ts`
12. [ ] Developper `generate-skill-docs.ts`
13. [ ] Developper `generate-rule-docs.ts`
14. [ ] Developper `generate-all.ts`

### Phase 4 : Generation contenu (US2/US4)
15. [ ] Generer les 100 pages de commandes
16. [ ] Generer les 37 pages d'agents
17. [ ] Generer les 24 pages de skills
18. [ ] Generer les 15 pages de rules
19. [ ] Creer les 10 pages index de categories

### Phase 5 : Workflows (US3)
20. [ ] Ecrire les 8 pages de workflows
21. [ ] Creer les diagrammes de workflow (Mermaid ou SVG)

### Phase 6 : Reference et Guides (US4/US5)
22. [ ] Creer la matrice des commandes
23. [ ] Creer la matrice des agents
24. [ ] Creer le cheatsheet
25. [ ] Ecrire les 5 guides thematiques

### Phase 7 : CI/CD et Finalisation
26. [ ] Configurer GitHub Actions pour build automatique
27. [ ] Configurer deploy sur GitHub Pages
28. [ ] Tester le build complet
29. [ ] Verifier les liens internes
30. [ ] Optimiser les performances (Lighthouse)

---

## Risques identifies

| Risque | Impact | Probabilite | Mitigation |
|--------|--------|-------------|------------|
| Volume de contenu (100+ pages) | Haut | Certaine | Scripts de generation automatique |
| Maintenance synchronisation avec sources | Moyen | Haute | Scripts CI qui regenerent a chaque push |
| Temps de build long | Moyen | Moyenne | Build incremental, cache |
| Liens casses | Faible | Moyenne | Plugin de verification des liens |
| Accessibilite insuffisante | Moyen | Faible | Tests Lighthouse automatises |

---

## Dependances

### Techniques
- Node.js 18+ (requis par Docusaurus 3.x)
- npm ou yarn
- GitHub Actions runner

### Packages npm
- `@docusaurus/core@3.x`
- `@docusaurus/preset-classic@3.x`
- `@docusaurus/plugin-search-local`
- `@docusaurus/plugin-ideal-image`
- `typescript`
- `@types/node`

### Donnees sources
- `.claude/commands/**/*.md` (100 fichiers)
- `.claude/agents/**/*.md` (37 fichiers)
- `.claude/skills/**/SKILL.md` (24 fichiers)
- `.claude/rules/*.md` (15 fichiers)

---

## Estimation

| Phase | Complexite | Estimation |
|-------|------------|------------|
| Phase 1 : Infrastructure | Moyenne | 2-3h |
| Phase 2 : Introduction | Faible | 1-2h |
| Phase 3 : Scripts generation | Haute | 3-4h |
| Phase 4 : Generation contenu | Faible (automatise) | 1h |
| Phase 5 : Workflows | Moyenne | 2h |
| Phase 6 : Reference et Guides | Moyenne | 2-3h |
| Phase 7 : CI/CD | Faible | 1h |
| **Total** | | **12-16h** |

---

## Definition of Done

- [ ] Toutes les 100 commandes sont documentees avec format standardise
- [ ] Tous les 37 agents sont documentes avec modele et outils
- [ ] Tous les 24 skills sont documentes avec mots-cles
- [ ] Toutes les 15 rules sont documentees avec paths
- [ ] Quick Start fonctionne pour un nouvel utilisateur
- [ ] Recherche retourne des resultats pertinents
- [ ] Score Lighthouse Performance > 90
- [ ] Score Lighthouse Accessibility > 90
- [ ] Build automatique sur push main
- [ ] Deploy automatique sur GitHub Pages

---

**Version**: 1.0 | **Cree**: 2025-01-17 | **Auteur**: Claude
