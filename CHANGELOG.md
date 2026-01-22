# Changelog

Toutes les modifications notables de ce projet sont documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/),
et ce projet adhère au [Versionnement Sémantique](https://semver.org/lang/fr/).

## [Unreleased]

---

## [1.10.1] - 2026-01-22

### Corrigé
- **Correction settings.json** : Erreurs de syntaxe des permissions
  - `Bash(*)` → `Bash` (syntaxe correcte pour autoriser toutes les commandes)
  - Suppression du pattern fork bomb invalide
  - Ajout de `Task(*)` dans les permissions

### Ajouté
- **Tests de smoke** (`tests/smoke.bats`) : Validation rapide de l'intégrité du socle

### Documentation
- **README.md** : Mise à jour badges (250 tests), section migration v1.10.x
- **SECURITY.md** : Mise à jour versions supportées (1.8.x à 1.10.x)

---

## [1.10.0] - 2026-01-22

### Ajouté
- **Nouvel Agent**
  - `dev-tdd` : Agent TDD pour le développement guidé par les tests
- **3 nouvelles Commandes** (total: 114 commandes)
  - `/dev-ai-integration` : Intégration LLMs et APIs AI (OpenAI, Claude, Gemini)
  - `/growth-localization` : Stratégie de localisation et internationalisation multi-marchés
  - `/qa-tech-debt` : Identifier et prioriser la dette technique

### Modifié
- **Fusion de `install.sh` dans `new-project.sh`**
  - Nouveau mode `--simple` (ou `--install-only`) pour installation rapide
  - Options ajoutées : `--dry-run`, `--quiet`, `--verbose`, `--skip-prompts`
  - L'ancien comportement de `install.sh` est maintenant accessible via `new-project.sh --simple .`
- **Compteurs mis à jour** dans la documentation : 114 commandes, 52 agents, 32 skills

### Supprimé
- **`scripts/install.sh`** : Fonctionnalités fusionnées dans `new-project.sh --simple`
- **`tests/install.bats`** : Tests migrés vers les tests de `new-project.sh`

### Statistiques
- Commands: 114 (+3)
- Sub-Agents: 52 (+1)
- Skills: 32 (inchangé)

---

## [1.9.0] - 2026-01-20

### Modifié
- **Configuration settings.json optimisée**
  - Permissions génériques avec wildcards (npm, git, docker, terraform, etc.)
  - Support multi-stack : Node.js, Python, Go, Rust, Flutter, Docker, Kubernetes, Terraform
  - Wildcards pour Skills (`Skill(*)`) et MCP tools (`mcp__*`)
  - Scripts locaux via pattern relatif `Bash(./scripts/*:*)`
  - Hooks conditionnels vérifiant l'existence des outils avant exécution

### Supprimé
- **Hooks redondants**
  - Vérification npm install au démarrage
  - TypeScript type-check après modification (bruit)
  - ESLint check après modification (bruit)
  - Couverture de tests après modification (bruit)
  - Scan gitleaks post-commit (redondant avec PreToolUse)

### Sécurité
- **Deny list étendue**
  - `git reset --hard` bloqué
  - `rm -rf ~` bloqué
  - `sudo` et `su` bloqués
  - `chmod 777` bloqué
  - Commandes destructives bas niveau bloquées (mkfs, dd)

### Amélioré
- **Portabilité** : Plus de chemins absolus, configuration universelle
- **Moins d'interactions** : Permissions élargies réduisent les prompts
- **Maintenance** : settings.local.json minimal (11 lignes vs 135)

---

## [1.8.0] - 2026-01-20

### Ajouté
- **8 tutoriels progressifs** (`docs/tutorials/`)
  - 01 - Premier projet : workflow de base (débutant)
  - 02 - Feature React : composant et hook complets (débutant)
  - 03 - API REST Node.js : TDD et documentation OpenAPI (intermédiaire)
  - 04 - Flutter + Supabase : app mobile avec backend (intermédiaire)
  - 05 - Audit de sécurité : OWASP Top 10 (intermédiaire)
  - 06 - Pipeline CI/CD : GitHub Actions (intermédiaire)
  - 07 - Refactoring Legacy : approche méthodique (avancé)
  - 08 - Infrastructure Proxmox : Terraform et monitoring (avancé)

- **Guides utilisateur** (`docs/guides/`)
  - `faq.md` : 20+ questions fréquentes avec réponses détaillées
  - `troubleshooting.md` : 15+ problèmes courants et solutions
  - `migration.md` : guide complet de migration vers claude-socle

- **12 exemples de code** (`docs/examples/`)
  - Web : React component, custom hook, Next.js API route
  - Mobile : Flutter screen (Clean Architecture), BLoC pattern
  - API : REST endpoint, GraphQL resolver, tRPC procedure
  - Ops : Docker multi-stage, CI/CD pipeline, Terraform module, Proxmox VM

- **Composants React Docusaurus**
  - `TutorialCard.tsx` : cartes de tutoriel avec durée et difficulté
  - `DifficultyBadge.tsx` : badges beginner/intermediate/advanced

- **Diagrammes Mermaid**
  - Workflow principal dans `cheatsheet.md`
  - Arbre de décision dans `choosing-workflow.md`
  - Séquence dans `explore-plan-code-commit.md`
  - Vue d'ensemble architecture dans `intro/architecture.md`

### Modifié
- **Skill infrastructure-as-code** : suppression des liens vers fichiers de référence inexistants
- **Sidebars** : ajout des tutoriels, exemples et guides

### Corrigé
- Liens internes dans les tutoriels (suppression préfixes numériques des IDs)
- Lien vers agent `qa-tech-debt` (était incorrectement lié à commands)
- Lien vers guide ops (remplacé par exemples)

---

## [1.7.0] - 2025-01-20

### Ajouté
- **Option `--path` pour `new-project.sh`**
  - Permet de spécifier le dossier parent où créer le projet
  - Exemple : `./scripts/new-project.sh --path ~/projects mon-app`
  - Crée automatiquement le dossier parent s'il n'existe pas (avec confirmation)
  - Mode interactif : demande le dossier si non spécifié

### Corrigé
- **Synchronisation des compteurs dans les scripts**
  - `scripts/new-project.sh` : Compteurs mis à jour (111 commandes, 51 agents, 32 skills)
  - `scripts/install.sh` : Compteurs synchronisés
  - `scripts/learn.sh` : Compteurs synchronisés

---

## [1.6.1] - 2025-01-20

### Ajouté
- **Documentation Docusaurus Orchestrateur**
  - Catégorie "Orchestrateur (2)" dans le sidebar avec `/assistant` et `/assistant-auto`
  - Page `concepts/orchestrator.md` enrichie : guide de décision rapide, workflows par type de projet, agents activés, skills déclenchés
  - Section dédiée dans `commands/index.md` pour mettre en avant le point d'entrée unique

### Modifié
- **Consolidation de la documentation**
  - Suppression des pages dupliquées dans `commands/other/` (contenu fusionné dans orchestrator.md)
  - Liens corrigés dans toute la documentation
- **Compteurs mis à jour**
  - `reference/cheatsheet.md` : 111 Commands, 51 Agents, 32 Skills, 17 Rules
  - `intro/quick-start.md` : 111 commandes
  - `commands/index.md` : 111 commandes en 10 domaines + orchestrateur

### Supprimé
- `website/docs/commands/other/assistant.md` (fusionné dans orchestrator.md)
- `website/docs/commands/other/assistant-auto.md` (fusionné dans orchestrator.md)
- `website/docs/commands/other/index.md` (dossier supprimé)

---

## [1.6.0] - 2025-01-20

### Ajouté
- **4 nouveaux Agents** (total: 51 agents)
  - `dev-ai-integration` : Intégration LLMs et APIs AI (OpenAI, Claude, Gemini)
  - `growth-localization` : Stratégie de localisation et internationalisation multi-marchés
  - `ops-migration` : Migrations de frameworks, versions et dépendances
  - `qa-tech-debt` : Identification et priorisation de la dette technique
- **3 nouveaux Skills** (total: 32 skills)
  - `api-mocking` : Configuration de mocks API avec MSW pour les tests
  - `state-management` : Patterns de state management (Redux, Zustand, Jotai)
  - `tech-debt-management` : Gestion et priorisation de la dette technique
- **1 nouvelle Command** (total: 110 commands)
  - `/ops-rollback` : Procédure de rollback sécurisée (Git, Vercel, K8s, Docker)
- **Documentation Docusaurus**
  - Nouveau chapitre `concepts/orchestrator.md` : Documentation dédiée de `/assistant` comme point d'entrée
  - `docs/README.md` : Index de navigation pour la documentation
  - 9 concepts clés documentés (ajout de l'Orchestrateur)
- **Guides améliorés**
  - `WEB-GUIDE.md` : Ajout section Architecture (React/Next.js et Vue.js)
  - `API-GUIDE.md` : Amélioration phase Testing avec objectifs de couverture

### Modifié
- **WHEN-TO-USE-WHICH-AGENT.md** : Guide de choix enrichi avec les 51 agents
- **CLAUDE.md** : Mise à jour sections agents, skills et commands
- **Concepts index** : L'Orchestrateur est maintenant le 1er concept recommandé aux nouveaux utilisateurs

### Corrigé
- Synchronisation de tous les compteurs dans la documentation (110 commandes, 51 agents, 32 skills)
- Compteurs dans README.md, CHEATSHEET.md, et toute la documentation Docusaurus
- Section legal agents tronquée dans CLAUDE.md

### Statistiques
- Commands: 110 (+1)
- Sub-Agents: 51 (+4)
- Skills: 32 (+3)
- Concepts documentés: 9 (+1 Orchestrateur)

---

## [1.5.0] - 2025-01-19

### Ajouté
- **Proxmox Infrastructure Support**
  - Nouvelle commande `/ops-proxmox` : Gestion complète Proxmox VE (VMs, LXC, réseau, stockage, backup)
  - Nouvel agent `ops-proxmox` : Provisioning infrastructure Proxmox avec Terraform
  - Nouveaux templates Terraform dans `.claude/templates/proxmox/` :
    - `provider-template.tf` : Configuration provider bpg/proxmox
    - `vm-module-template.tf` : Module VM QEMU/KVM avec cloud-init
    - `lxc-module-template.tf` : Module conteneur LXC
    - `infrastructure-template.tf` : Infrastructure complète multi-VMs/LXC
- **Infrastructure as Code**
  - Nouveau skill `infrastructure-as-code` : Terraform/OpenTofu avec best practices
  - Nouvel agent `ops-infra-code` : Création de modules Terraform, gestion state, HCL idiomatique
- **Scripts**
  - `install.sh` : Copie maintenant agents, rules, output-styles, templates
  - `new-project.sh` : Inclut templates et compteurs mis à jour
  - `update.sh` : Support des fichiers `.tf`, `.yaml`, `.yml`, `.json` pour les templates

### Corrigé
- Synchronisation des compteurs dans toute la documentation (109 commandes, 47 agents, 29 skills)
- `learn.sh` : Correction du nombre d'agents (était 85, maintenant 47)
- Documentation Docusaurus : Tous les compteurs mis à jour

### Statistiques
- Commands: 109 (était 108)
- Sub-Agents: 47 (était 45)
- Skills: 29 (était 27)
- Templates: 7 (nouveau dossier proxmox avec 4 templates)

---

## [1.4.1] - 2025-01-18

### Ajouté
- **Scripts**
  - Option `--templates` dans `update.sh` pour synchroniser `.claude/templates/`
  - Inclusion de templates dans `--all`, `--detect-orphans` et `--clean`
- **Documentation**
  - Nouvelle page `docs/concepts/templates.md` documentant les 3 templates de spécification
  - Mise à jour de l'index des concepts (8 concepts au lieu de 7)

### Corrigé
- Templates de spécification (spec, plan, tasks) maintenant synchronisés par `update.sh`

---

## [1.4.0] - 2025-01-18

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

### Statistiques
- Commands: 108 (était 94)
- Sub-Agents: 45 (était 37)
- Skills: 27 (était 24)
- Rules: 17 (était 15)

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
