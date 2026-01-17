# Changelog

Toutes les modifications notables de ce projet sont documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/),
et ce projet adhère au [Versionnement Sémantique](https://semver.org/lang/fr/).

## [Unreleased]

### Ajouté
- **8 nouveaux Agents** (total: 45 agents)
  - DEV: `dev-design-system`, `dev-prisma`, `dev-trpc`, `dev-prompt-engineering`, `dev-rag`
  - OPS: `ops-serverless`, `ops-vercel`
  - QA: `qa-e2e`
- **3 nouveaux Skills** (total: 27 skills)
  - `e2e-testing` : Tests End-to-End avec Playwright/Cypress
  - `feature-flags` : Gestion de feature flags et déploiement progressif
  - `prompt-engineering` : Optimisation de prompts pour LLMs
- **2 nouvelles Rules** (total: 17 rules)
  - `accessibility.md` : WCAG 2.1 AA, patterns d'accessibilité
  - `performance.md` : Core Web Vitals, optimisation frontend
- **8 nouvelles Commands** (total: 108 commands)
  - `/dev-design-system` : Design tokens et bibliothèque de composants
  - `/dev-prisma` : ORM Prisma (schema, migrations, queries)
  - `/dev-trpc` : APIs type-safe avec tRPC
  - `/dev-prompt-engineering` : Optimisation de prompts LLM
  - `/dev-rag` : Systèmes RAG (Retrieval-Augmented Generation)
  - `/ops-serverless` : Déploiement serverless (Lambda, Vercel, CF Workers)
  - `/ops-vercel` : Configuration et déploiement Vercel
  - `/qa-e2e` : Tests End-to-End avec Playwright ou Cypress
- **Documentation**
  - `docs/QUICKSTART.md` : Guide de démarrage rapide en 5 minutes
  - `WHEN-TO-USE-WHICH-AGENT.md` : Guide de choix des agents

### Corrigé
- Cohérence des chiffres dans la documentation (108/45/27/17)

---

## [1.3.0] - 2025-01-17

### Ajouté
- **Site de documentation Docusaurus** sur GitHub Pages
  - Documentation complète : 100 commandes, 37 agents, 24 skills, 15 rules
  - Auto-génération depuis les fichiers `.claude/`
  - Déploiement automatique via GitHub Actions
  - URL : https://christopherlouet.github.io/claude-socle/
- **37 Sub-Agents** avec contexte isolé (était 14)
  - DEV: `dev-component`, `dev-test`, `dev-flutter`, `dev-supabase`
  - OPS: `ops-docker`, `ops-ci`, `ops-database`, `ops-monitoring`
  - DOC: `doc-generate`, `doc-changelog`, `doc-explain`
  - LEGAL: `legal-rgpd`, `legal-payment`, `legal-privacy-policy`, `legal-terms-of-service`
  - DATA: `data-pipeline`, `data-analytics`, `data-modeling`
  - GROWTH: `growth-analytics`, `growth-landing`, `growth-funnel`
  - BIZ: `biz-mvp`, `biz-personas`
- **24 Skills** avec déclenchement automatique (était 9)
  - `flutter-development`, `supabase-development`, `react-performance`
  - `docker-containerization`, `ci-cd-pipeline`, `database-design`
  - `monitoring-instrumentation`, `documentation-generation`, `changelog-maintenance`
  - `refactoring`, `error-handling`, `graphql-development`
  - `mobile-release`, `data-pipeline`, `performance-optimization`
- **15 Rules modulaires** par langage
  - Nouvelles: `java.md`, `csharp.md`, `ruby.md`, `php.md`, `rust.md`
- **7 Output Styles** documentés avec exemples
  - `teaching`, `concise`, `technical`, `review`, `emoji`, `minimal`, `structured`
- **4 Guides par domaine** dans `docs/guides/`
  - `WEB-GUIDE.md` (React/Next.js/Vue)
  - `MOBILE-GUIDE.md` (Flutter/Clean Architecture)
  - `API-GUIDE.md` (REST/GraphQL)
  - `DATA-GUIDE.md` (ETL/Airflow/dbt)
- **Documentation architecture** (`docs/ARCHITECTURE.md`)
  - Matrice Commands vs Agents vs Skills vs Rules
  - Diagrammes de flux de données
- **Diagrammes workflows** (`docs/WORKFLOWS.md`)
  - Flowcharts ASCII et Mermaid
  - Workflows: Feature, Bugfix, Release, Audit, Mobile, API, Data
- **Setup Wizard** (`scripts/setup-wizard.sh`)
  - Configuration interactive par type de projet
  - Détection automatique des technologies
  - Génération de settings.json personnalisé
- **6 nouvelles commandes OPS**
  - `/ops-grafana-dashboard` : Création dashboards Grafana avec templates
  - `/ops-observability-stack` : Déploiement Prometheus/Grafana/Loki
  - `/ops-k8s` : Déploiement Kubernetes (manifests, Helm)
  - `/ops-vps` : Déploiement VPS (OVH, Hetzner, DigitalOcean)
  - `/ops-mobile-release` : Publication App Store/Google Play avec Fastlane
  - `/growth-app-store-analytics` : Métriques stores mobiles

### Modifié
- **`/assistant`** : Orchestrateur intelligent amélioré
  - Catalogue complet des 94 commandes
  - Détection du type de projet (Web, Mobile, API, Data)
  - Workflows spécifiques par domaine
  - Références aux guides de domaine
- **CLAUDE.md** : Documentation complète mise à jour
  - 94 commandes, 37 agents, 24 skills, 15 rules
  - Section guides et documentation enrichie
- **`/ops-monitoring`** : Enrichi avec instrumentation complète
- Scripts `update.sh`, `validate.sh`, `new-project.sh` améliorés

### Statistiques
- Commands: 94 (était 88)
- Sub-Agents: 37 (était 14)
- Skills: 24 (était 9)
- Rules: 15 (était 10)
- Output Styles: 7 (documentés)
- Guides domaine: 4 (nouveaux)

## [1.2.0] - 2025-01-15

### Ajouté
- **Mode apprentissage interactif** (`learn.sh`) : Tutoriel pour maîtriser claude-socle
  - Tutoriel complet (15-20 min) avec 6 leçons
  - Mode rapide (5 min) pour l'essentiel
  - Apprentissage par agent spécifique (`--agent tdd`, `--agent commit`)
  - Quiz interactifs avec système de score et niveau
  - Couverture : workflow, agents, TDD, Conventional Commits
- **Intégration IDE** (`ide.sh`) : Configuration automatique des IDE
  - Support VSCode/Cursor : settings, tasks, extensions, snippets
  - Support IntelliJ IDEA : run configurations, code style, templates
  - Support Vim/Neovim : abréviations, mappings, autocmds
  - Commandes setup/check/remove pour chaque IDE
  - Option `--force` pour écraser les configurations existantes
- Fichier `.editorconfig` pour formatage cohérent
- Tests bats pour `learn.sh` (40+ tests)
- Tests bats pour `ide.sh` (50+ tests)

### Modifié
- README mis à jour avec documentation des nouvelles fonctionnalités
- Compteur de lignes de tests mis à jour (1664+ lignes)

## [1.1.0] - 2025-01-15

### Ajouté
- **Analyse CI/CD intelligente** : `new-project.sh` analyse maintenant les workflows existants et propose des améliorations
- Fonction `analyze_existing_cicd()` pour détecter 7 aspects de CI/CD (tests, lint, sécurité, cache, coverage, PR, release)
- Fonction `suggest_cicd_improvements()` avec score de qualité CI/CD
- Fonction `merge_cicd_workflows()` pour ajouter uniquement les workflows manquants
- Menu interactif pour choisir entre garder/améliorer/remplacer la CI/CD existante
- Tests bats pour `gitleaks.bats`
- Configuration `.gitleaks.toml` avec 24+ règles de détection de secrets

### Modifié
- `get_options()` propose maintenant des améliorations quand une CI/CD existe
- `create_project()` supporte les actions "merge" et "replace" pour la CI/CD
- Migration de `[ ]` vers `[[ ]]` pour la cohérence bash

### Sécurité
- Hook gitleaks pré-écriture pour détecter les secrets avant commit
- Hook post-commit pour scanner les secrets après commit

## [1.0.0] - 2025-01-14

### Ajouté
- **79 agents Claude Code** organisés par catégorie :
  - WORK (8) : Workflow principal (explore, plan, commit, pr)
  - DEV (10) : Développement (tdd, test, debug, refactor, api)
  - QA (8) : Qualité (review, security, perf, a11y, audit)
  - OPS (16) : Opérations (hotfix, release, deps, docker, ci)
  - DOC (9) : Documentation (generate, changelog, explain, onboard)
  - BIZ (11) : Business (model, market, mvp, pricing, pitch)
  - GROWTH (8) : Croissance (landing, seo, analytics, onboarding)
  - DATA (3) : Données (pipeline, analytics, modeling)
  - LEGAL (5) : Légal (docs, rgpd, payment, terms, privacy)
- **9 skills** avec déclenchement automatique contextuel
- **8 hooks** Claude Code (protection main, auto-format, type-check, gitleaks)
- Script `new-project.sh` pour créer/configurer des projets
- Script `install.sh` pour installer le socle dans un projet existant
- Script `validate.sh` pour valider une configuration Claude Code
- Script `doctor.sh` pour diagnostiquer l'environnement
- Script `diff.sh` pour comparer avec la version installée
- Script `update.sh` pour mettre à jour le socle
- Script `uninstall.sh` pour supprimer la configuration
- Librairie partagée `lib/common.sh` avec 30+ fonctions utilitaires
- 17 templates CLAUDE.md par stack (react, vue, node-api, python, go, rust, java, fullstack)
- Configuration pre-commit avec detect-secrets et commitlint
- Workflows GitHub Actions (ci.yml, pr-check.yml, release.yml)
- Documentation complète (guides, cheatsheet, workflows)

### Configuration
- Permissions granulaires pour Claude Code
- Protection automatique de la branche main/master
- Validation des commits (Conventional Commits)
- Auto-formatage TypeScript/JavaScript après modifications

## Types de changements

- `Ajouté` pour les nouvelles fonctionnalités
- `Modifié` pour les changements aux fonctionnalités existantes
- `Déprécié` pour les fonctionnalités qui seront supprimées
- `Supprimé` pour les fonctionnalités supprimées
- `Corrigé` pour les corrections de bugs
- `Sécurité` pour les vulnérabilités corrigées
