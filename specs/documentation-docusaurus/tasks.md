# Tasks : Documentation Docusaurus pour claude-socle

Liste detaillee des taches a realiser, organisees par phase.

---

## Phase 1 : Infrastructure Docusaurus (MVP)

### 1.1 Initialisation du projet

- [ ] **TASK-001** : Creer le dossier `website/`
  - Executer `npx create-docusaurus@latest website classic --typescript`
  - Verifier la structure generee
  - **Livrable** : Projet Docusaurus fonctionnel

- [ ] **TASK-002** : Nettoyer le contenu par defaut
  - Supprimer les pages d'exemple dans `docs/`
  - Supprimer le blog (ou le desactiver)
  - **Livrable** : Projet vierge pret a personnaliser

### 1.2 Configuration principale

- [ ] **TASK-003** : Configurer `docusaurus.config.ts`
  - Title : "claude-socle"
  - Tagline : "Template de configuration Claude Code pour un workflow optimal"
  - URL : GitHub Pages URL
  - Base URL : `/claude-socle/`
  - Theme color : Bleu claude (#6366F1)
  - Navbar : Intro, Commands, Agents, Skills, Rules, Guides, Reference
  - Footer : Links, copyright
  - **Livrable** : Configuration complete

- [ ] **TASK-004** : Configurer `sidebars.ts`
  - Structure hierarchique :
    ```
    - Introduction
      - Accueil
      - Quick Start
      - Architecture
      - Installation
    - Workflow
      - Vue d'ensemble
      - Feature
      - Bugfix
      - Release
      - Launch
      - TDD
    - Commands
      - WORK (10)
      - DEV (16)
      - QA (11)
      - OPS (24)
      - DOC (9)
      - BIZ (11)
      - GROWTH (9)
      - DATA (3)
      - LEGAL (5)
      - ASSISTANT (1)
    - Agents (37)
    - Skills (24)
    - Rules (15)
    - Guides (5)
    - Reference
    ```
  - **Livrable** : Navigation complete

- [ ] **TASK-005** : Configurer la recherche locale
  - Installer `@easyops-cn/docusaurus-search-local`
  - Configurer l'indexation
  - Tester la recherche
  - **Livrable** : Recherche fonctionnelle

### 1.3 Styles et theme

- [ ] **TASK-006** : Creer `src/css/custom.css`
  - Variables CSS (couleurs claude-socle)
  - Styles pour les badges de domaine
  - Styles pour les cartes de commandes
  - Responsive design
  - **Livrable** : Theme personnalise

- [ ] **TASK-007** : Creer le logo et favicon
  - Logo SVG claude-socle
  - Favicon multi-resolution
  - **Livrable** : Assets visuels

### 1.4 Composants React

- [ ] **TASK-008** : Creer `CommandCard.tsx`
  ```tsx
  interface CommandCardProps {
    name: string;
    description: string;
    domain: 'work' | 'dev' | 'qa' | 'ops' | 'doc' | 'biz' | 'growth' | 'data' | 'legal';
    tags?: string[];
  }
  ```
  - Affiche nom, description, badge domaine
  - Liens vers la page de detail
  - **Livrable** : Composant reutilisable

- [ ] **TASK-009** : Creer `AgentCard.tsx`
  ```tsx
  interface AgentCardProps {
    name: string;
    description: string;
    model: 'haiku' | 'sonnet' | 'opus';
    tools: string[];
  }
  ```
  - Affiche nom, modele (avec badge couleur), outils
  - **Livrable** : Composant reutilisable

- [ ] **TASK-010** : Creer `SkillCard.tsx`
  ```tsx
  interface SkillCardProps {
    name: string;
    description: string;
    keywords: string[];
    context: 'fork' | 'shared';
  }
  ```
  - Affiche nom, mots-cles, type de contexte
  - **Livrable** : Composant reutilisable

- [ ] **TASK-011** : Creer `WorkflowDiagram.tsx`
  - Support Mermaid ou SVG inline
  - Diagramme interactif avec liens
  - **Livrable** : Composant pour workflows

- [ ] **TASK-012** : Creer `FeatureComparison.tsx`
  - Tableau comparatif Commands vs Agents vs Skills
  - **Livrable** : Composant pedagogique

---

## Phase 2 : Contenu Introduction (MVP - US1)

- [ ] **TASK-013** : Ecrire `docs/intro/index.md`
  - Hero section avec tagline
  - Value proposition en 3 points
  - Chiffres cles (100 commands, 37 agents, etc.)
  - CTA vers Quick Start
  - **Livrable** : Page d'accueil

- [ ] **TASK-014** : Ecrire `docs/intro/quick-start.md`
  - Prerequis (Claude Code installe)
  - Installation en 3 etapes
  - Premier workflow en 5 minutes
  - Exemples concrets
  - **Livrable** : Guide de demarrage

- [ ] **TASK-015** : Ecrire `docs/intro/architecture.md`
  - Schema global (Commands, Agents, Skills, Rules)
  - Difference entre chaque concept
  - Quand utiliser quoi
  - Diagramme avec FeatureComparison
  - **Livrable** : Page architecture

- [ ] **TASK-016** : Ecrire `docs/intro/installation.md`
  - Installation via `new-project.sh`
  - Configuration `.claude/`
  - Verification de l'installation
  - Troubleshooting
  - **Livrable** : Guide installation

---

## Phase 3 : Scripts de generation

### 3.1 Utilitaires communs

- [ ] **TASK-017** : Creer `scripts/utils/parse-frontmatter.ts`
  - Parse le frontmatter YAML des fichiers .md
  - Extrait les metadonnees (name, description, tools, etc.)
  - **Livrable** : Utilitaire reutilisable

- [ ] **TASK-018** : Creer `scripts/utils/template.ts`
  - Fonction de templating pour generer le markdown
  - Support des variables interpolees
  - **Livrable** : Utilitaire de templating

- [ ] **TASK-019** : Creer `scripts/utils/file-scanner.ts`
  - Scan recursif des dossiers sources
  - Filtre par extension
  - **Livrable** : Utilitaire de scan

### 3.2 Scripts de generation

- [ ] **TASK-020** : Creer `scripts/generate-command-docs.ts`
  - Lit tous les fichiers `.claude/commands/**/*.md`
  - Extrait : nom, domaine, description, usage, exemples
  - Genere les pages Docusaurus avec frontmatter
  - Genere les index par domaine
  - **Template de sortie** :
    ```md
    ---
    sidebar_position: X
    title: /command-name
    description: Description courte
    tags: [domain, tags]
    ---
    # /command-name
    ## Description
    ## Usage
    ## Processus
    ## Exemples
    ## Best Practices
    ## Pieges a eviter
    ## Commandes liees
    ```
  - **Livrable** : Script fonctionnel

- [ ] **TASK-021** : Creer `scripts/generate-agent-docs.ts`
  - Lit tous les fichiers `.claude/agents/*.md`
  - Extrait : nom, model, tools, permissionMode, skills
  - Genere les pages avec informations techniques
  - **Template de sortie** :
    ```md
    ---
    sidebar_position: X
    title: agent-name
    description: Description
    ---
    # Agent: agent-name
    ## Configuration
    | Propriete | Valeur |
    |-----------|--------|
    | Modele | haiku/sonnet |
    | Outils | Read, Grep, ... |
    | Permission | plan/default |
    ## Declenchement
    ## Processus
    ## Output attendu
    ## Limitations
    ```
  - **Livrable** : Script fonctionnel

- [ ] **TASK-022** : Creer `scripts/generate-skill-docs.ts`
  - Lit tous les fichiers `.claude/skills/*/SKILL.md`
  - Extrait : name, description, allowed-tools, context
  - Genere les pages avec exemples
  - **Livrable** : Script fonctionnel

- [ ] **TASK-023** : Creer `scripts/generate-rule-docs.ts`
  - Lit tous les fichiers `.claude/rules/*.md`
  - Extrait : paths, contenu des regles
  - Genere les pages avec fichiers concernes
  - **Livrable** : Script fonctionnel

- [ ] **TASK-024** : Creer `scripts/generate-all.ts`
  - Orchestration des 4 scripts
  - Verification de coherence
  - Report de generation
  - **Livrable** : Script principal

---

## Phase 4 : Generation du contenu (100 commands + 37 agents + 24 skills + 15 rules)

### 4.1 Commandes WORK (10)

- [ ] **TASK-025** : Generer `docs/commands/work/index.md` - Vue d'ensemble WORK
- [ ] **TASK-026** : Generer pages WORK individuelles (10 pages)
  - work-explore
  - work-plan
  - work-commit
  - work-pr
  - work-flow-feature
  - work-flow-bugfix
  - work-flow-release
  - work-flow-launch
  - work-clarify
  - work-specify

### 4.2 Commandes DEV (16)

- [ ] **TASK-027** : Generer `docs/commands/dev/index.md` - Vue d'ensemble DEV
- [ ] **TASK-028** : Generer pages DEV individuelles (16 pages)
  - dev-tdd, dev-test, dev-testing-setup, dev-debug, dev-refactor
  - dev-api, dev-api-versioning, dev-component, dev-hook
  - dev-error-handling, dev-react-perf, dev-mcp
  - dev-flutter, dev-supabase, dev-graphql, dev-neovim

### 4.3 Commandes QA (11)

- [ ] **TASK-029** : Generer `docs/commands/qa/index.md` - Vue d'ensemble QA
- [ ] **TASK-030** : Generer pages QA individuelles (11 pages)
  - qa-review, qa-security, qa-perf, qa-a11y, qa-audit
  - qa-responsive, qa-automation, qa-coverage, qa-kaizen
  - qa-mobile, qa-neovim

### 4.4 Commandes OPS (24)

- [ ] **TASK-031** : Generer `docs/commands/ops/index.md` - Vue d'ensemble OPS
- [ ] **TASK-032** : Generer pages OPS individuelles (24 pages)
  - ops-hotfix, ops-release, ops-deps, ops-docker, ops-migrate
  - ops-ci, ops-monitoring, ops-database, ops-health, ops-env
  - ops-backup, ops-load-testing, ops-cost-optimization
  - ops-disaster-recovery, ops-infra-code, ops-secrets-management
  - ops-k8s, ops-vps, ops-mobile-release
  - ops-gitflow-init, ops-gitflow-feature, ops-gitflow-release, ops-gitflow-hotfix
  - ops-grafana-dashboard, ops-observability-stack

### 4.5 Commandes DOC (9)

- [ ] **TASK-033** : Generer `docs/commands/doc/index.md` - Vue d'ensemble DOC
- [ ] **TASK-034** : Generer pages DOC individuelles (9 pages)
  - doc-generate, doc-changelog, doc-explain, doc-onboard
  - doc-i18n, doc-fix-issue, doc-api-spec, doc-readme, doc-architecture

### 4.6 Commandes BIZ (11)

- [ ] **TASK-035** : Generer `docs/commands/biz/index.md` - Vue d'ensemble BIZ
- [ ] **TASK-036** : Generer pages BIZ individuelles (11 pages)
  - biz-model, biz-market, biz-mvp, biz-pricing, biz-pitch
  - biz-roadmap, biz-launch, biz-competitor, biz-okr, biz-personas, biz-research

### 4.7 Commandes GROWTH (9)

- [ ] **TASK-037** : Generer `docs/commands/growth/index.md` - Vue d'ensemble GROWTH
- [ ] **TASK-038** : Generer pages GROWTH individuelles (9 pages)
  - growth-landing, growth-seo, growth-analytics, growth-onboarding
  - growth-email, growth-ab-test, growth-retention, growth-funnel
  - growth-app-store-analytics

### 4.8 Commandes DATA (3)

- [ ] **TASK-039** : Generer `docs/commands/data/index.md` - Vue d'ensemble DATA
- [ ] **TASK-040** : Generer pages DATA individuelles (3 pages)
  - data-pipeline, data-analytics, data-modeling

### 4.9 Commandes LEGAL (5)

- [ ] **TASK-041** : Generer `docs/commands/legal/index.md` - Vue d'ensemble LEGAL
- [ ] **TASK-042** : Generer pages LEGAL individuelles (5 pages)
  - legal-docs, legal-rgpd, legal-payment, legal-terms-of-service, legal-privacy-policy

### 4.10 Commande ASSISTANT

- [ ] **TASK-043** : Generer `docs/commands/assistant.md`

### 4.11 Agents (37)

- [ ] **TASK-044** : Generer `docs/agents/index.md` - Vue d'ensemble Agents
- [ ] **TASK-045** : Generer pages Agents individuelles (37 pages)
  - work-explore
  - biz-competitor, biz-model, biz-mvp, biz-personas
  - data-analytics, data-modeling, data-pipeline
  - dev-component, dev-debug, dev-flutter, dev-supabase, dev-test
  - doc-changelog, doc-explain, doc-generate, doc-onboard
  - growth-analytics, growth-funnel, growth-landing, growth-seo
  - legal-payment, legal-privacy-policy, legal-rgpd, legal-terms-of-service
  - ops-ci, ops-database, ops-deps, ops-docker, ops-health, ops-monitoring
  - qa-a11y, qa-audit, qa-coverage, qa-perf, qa-responsive, qa-security

### 4.12 Skills (24)

- [ ] **TASK-046** : Generer `docs/skills/index.md` - Vue d'ensemble Skills
- [ ] **TASK-047** : Generer pages Skills individuelles (24 pages)
  - api-development, changelog-maintenance, ci-cd-pipeline
  - creating-pull-requests, data-pipeline, database-design
  - debugging-issues, docker-containerization, documentation-generation
  - error-handling, exploring-codebase, flutter-development
  - generating-commit-messages, graphql-development, mobile-release
  - monitoring-instrumentation, performance-optimization, planning-implementation
  - react-performance, refactoring, reviewing-code
  - security-audit, supabase-development, test-driven-development

### 4.13 Rules (15)

- [ ] **TASK-048** : Generer `docs/rules/index.md` - Vue d'ensemble Rules
- [ ] **TASK-049** : Generer pages Rules individuelles (15 pages)
  - api, csharp, flutter, git, go, java, php, python
  - react, ruby, rust, security, testing, typescript, workflow

---

## Phase 5 : Workflows (US3)

- [ ] **TASK-050** : Ecrire `docs/workflow/index.md`
  - Vue d'ensemble du cycle Explore -> Plan -> Code -> Commit
  - Diagramme principal
  - Navigation vers workflows specifiques

- [ ] **TASK-051** : Ecrire `docs/workflow/explore-plan-code-commit.md`
  - Detail du workflow principal
  - Chaque etape avec commandes associees

- [ ] **TASK-052** : Ecrire `docs/workflow/feature.md`
  - Workflow nouvelle feature avec `/work-flow-feature`
  - Diagramme de sequence
  - Exemple concret

- [ ] **TASK-053** : Ecrire `docs/workflow/bugfix.md`
  - Workflow correction de bug avec `/work-flow-bugfix`
  - Diagramme de sequence

- [ ] **TASK-054** : Ecrire `docs/workflow/release.md`
  - Workflow release avec `/work-flow-release`
  - Checklist de release

- [ ] **TASK-055** : Ecrire `docs/workflow/launch.md`
  - Workflow lancement produit avec `/work-flow-launch`
  - Checklist de lancement

- [ ] **TASK-056** : Ecrire `docs/workflow/tdd.md`
  - Workflow TDD avec `/dev-tdd`
  - Cycle Red-Green-Refactor

- [ ] **TASK-057** : Ecrire `docs/workflow/choosing-workflow.md`
  - Arbre de decision pour choisir le bon workflow
  - FAQ

---

## Phase 6 : Reference et Guides (US4/US5)

### 6.1 Reference

- [ ] **TASK-058** : Creer `docs/reference/index.md`
  - Liens vers matrices et cheatsheet

- [ ] **TASK-059** : Creer `docs/reference/commands-matrix.md`
  - Tableau des 100 commandes avec : nom, domaine, description, tags
  - Filtrable par domaine
  - Recherchable

- [ ] **TASK-060** : Creer `docs/reference/agents-matrix.md`
  - Tableau des 37 agents avec : nom, modele, outils
  - Filtrable par modele

- [ ] **TASK-061** : Creer `docs/reference/cheatsheet.md`
  - Aide-memoire format A4
  - Commandes les plus utiles par scenario
  - Raccourcis et astuces

### 6.2 Guides thematiques

- [ ] **TASK-062** : Ecrire `docs/guides/index.md`
  - Navigation vers les guides par profil

- [ ] **TASK-063** : Ecrire `docs/guides/web-development.md`
  - Stack : React, Next.js, Node.js
  - Commandes recommandees : dev-component, dev-hook, dev-react-perf
  - Workflow type

- [ ] **TASK-064** : Ecrire `docs/guides/mobile-development.md`
  - Stack : Flutter, Dart
  - Commandes recommandees : dev-flutter, dev-supabase, qa-mobile
  - Workflow type

- [ ] **TASK-065** : Ecrire `docs/guides/api-development.md`
  - Stack : REST, GraphQL
  - Commandes recommandees : dev-api, dev-graphql, doc-api-spec
  - Workflow type

- [ ] **TASK-066** : Ecrire `docs/guides/data-engineering.md`
  - Stack : Pipelines, Analytics
  - Commandes recommandees : data-pipeline, data-modeling, data-analytics
  - Workflow type

- [ ] **TASK-067** : Ecrire `docs/guides/startup.md`
  - Pour les entrepreneurs
  - Commandes recommandees : biz-*, growth-*, legal-*
  - Workflow de lancement

---

## Phase 7 : CI/CD et Finalisation

### 7.1 CI/CD

- [ ] **TASK-068** : Creer `.github/workflows/docs.yml`
  ```yaml
  name: Deploy Docs
  on:
    push:
      branches: [main]
      paths:
        - 'website/**'
        - '.claude/**'
    workflow_dispatch:
  jobs:
    build-and-deploy:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
        - uses: actions/setup-node@v4
          with:
            node-version: 18
        - name: Install dependencies
          run: npm ci
          working-directory: website
        - name: Generate docs from sources
          run: npm run generate
          working-directory: website
        - name: Build
          run: npm run build
          working-directory: website
        - name: Deploy to GitHub Pages
          uses: peaceiris/actions-gh-pages@v3
          with:
            github_token: ${{ secrets.GITHUB_TOKEN }}
            publish_dir: ./website/build
  ```

- [ ] **TASK-069** : Configurer GitHub Pages
  - Activer GitHub Pages sur le repo
  - Configurer la branche gh-pages

### 7.2 Scripts npm

- [ ] **TASK-070** : Mettre a jour `website/package.json`
  ```json
  {
    "scripts": {
      "generate": "ts-node scripts/generate-all.ts",
      "start": "npm run generate && docusaurus start",
      "build": "npm run generate && docusaurus build",
      "serve": "docusaurus serve",
      "deploy": "npm run generate && docusaurus deploy"
    }
  }
  ```

### 7.3 Verification et qualite

- [ ] **TASK-071** : Verifier tous les liens internes
  - Utiliser `docusaurus build` qui detecte les liens casses
  - Corriger les eventuels problemes

- [ ] **TASK-072** : Tester l'accessibilite
  - Lighthouse accessibility > 90
  - Tester avec lecteur d'ecran

- [ ] **TASK-073** : Optimiser les performances
  - Lighthouse performance > 90
  - Verifier le bundle size
  - Activer la compression

- [ ] **TASK-074** : Mise a jour `.gitignore`
  ```gitignore
  # Docusaurus
  website/node_modules/
  website/build/
  website/.docusaurus/
  website/.cache-loader/
  ```

- [ ] **TASK-075** : Mise a jour `package.json` racine
  ```json
  {
    "scripts": {
      "docs:dev": "npm --prefix website start",
      "docs:build": "npm --prefix website build",
      "docs:deploy": "npm --prefix website deploy"
    }
  }
  ```

---

## Checklist de validation finale

### Completude du contenu
- [ ] 100 pages de commandes generees
- [ ] 37 pages d'agents generees
- [ ] 24 pages de skills generees
- [ ] 15 pages de rules generees
- [ ] 4 pages d'introduction ecrites
- [ ] 8 pages de workflows ecrites
- [ ] 5 pages de guides ecrites
- [ ] 4 pages de reference ecrites

### Qualite technique
- [ ] Build sans erreur
- [ ] Tous les liens fonctionnels
- [ ] Recherche fonctionnelle
- [ ] Responsive design OK
- [ ] Lighthouse Performance > 90
- [ ] Lighthouse Accessibility > 90

### CI/CD
- [ ] Build automatique sur push
- [ ] Deploy automatique sur GitHub Pages
- [ ] Regeneration quand sources modifiees

---

## Metriques de succes

| Metrique | Objectif | Verification |
|----------|----------|--------------|
| Temps Quick Start | < 5 min | Test utilisateur |
| Temps recherche commande | < 30 sec | Test utilisateur |
| Lighthouse Performance | > 90 | CI automatique |
| Lighthouse Accessibility | > 90 | CI automatique |
| Build time | < 2 min | CI automatique |
| Couverture contenu | 100% | Script de verification |

---

**Total taches** : 75
**Estimation totale** : 12-16 heures

---

**Version**: 1.0 | **Cree**: 2025-01-17 | **Auteur**: Claude
