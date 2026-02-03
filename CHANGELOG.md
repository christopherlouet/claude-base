# Changelog

Toutes les modifications notables de ce projet sont documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/),
et ce projet adhère au [Versionnement Sémantique](https://semver.org/lang/fr/).

## [Unreleased]

---

## [1.23.1] - 2026-02-03

### Corrige
- **Compteurs documentation** : correction des incohérences dans tous les fichiers
  - `Stats.tsx` : 100→120 commands, 37→57 agents, 24→41 skills, 15→21 rules
  - `website/docs/intro/index.md` : Rules 20→21, WORK 10→11
  - `website/docs/reference/index.md` : Commands 119→120, Rules 20→21, WORK 10→11
  - `WHEN-TO-USE-WHICH-AGENT.md` : 56→57 agents
  - `docs/ARCHITECTURE.md` : Skills 40→41, Agents 56→57, Rules 20→21
  - `.claude/skills/README.md` : 40→41 skills
- **`/assistant`** : ajout de `/work:work-commit-push-pr` dans le catalogue (11 WORK commands)

---

## [1.23.0] - 2026-02-03

### Ajoute
- **Bonnes pratiques Boris Cherny** : integration des recommandations du createur de Claude Code
  - Nouvelle section "Verification" dans CLAUDE.md (feedback loop = 2-3x qualite)
  - Nouvelle section "Modele Recommande" (Opus 4.5 avec thinking)
  - Nouvelle section "Prompting Avance" ("Grill me", "Prove it", "elegant solution")
  - Nouvelle section "Sessions Paralleles" (git worktrees)
- **`/work:work-commit-push-pr`** : nouvelle commande combinee commit+push+PR (120 commands)
- **`docs/reference/best-practices.md`** : fichier de reference importe via @import
- **`docs/guides/PROMPTING-GUIDE.md`** : guide complet des techniques de prompting
- **Output style `explanatory`** : mode apprentissage avec explications detaillees (8 styles)
- **MCP servers** : ajout Slack, Sentry, BigQuery, Linear, Notion (13 servers)

### Modifie
- **`update.sh`** : amelioration de la mise a jour des @imports
  - Copie toujours `docs/reference/*` (mise a jour des fichiers)
  - Detecte et ajoute les @imports manquants dans CLAUDE.md existants
  - Ajoute automatiquement `@docs/reference/best-practices.md`
- **Skill `git-worktrees`** : enrichi avec le workflow Boris (aliases shell, worktree analyse, notifications)
- **Compteurs documentation** : mise a jour 119 → 120 commands

---

## [1.22.2] - 2026-02-02

### Modifie
- **README** : migration des commandes vers le format namespace, correction badge release, arbre structure et politique de versioning
- **CI** : bump actions/checkout, actions/setup-node et actions/cache via Dependabot

---

## [1.22.1] - 2026-02-02

### Supprime
- **setup-wizard.sh supprime** : le wrapper de compatibilite est retire, utiliser `new-project.sh --simple` directement

---

## [1.22.0] - 2026-02-02

### Modifie
- **setup-wizard.sh deprecie** : remplace par un wrapper de 14 lignes qui redirige vers `new-project.sh --simple`, eliminant 520+ lignes de code duplique

---

## [1.21.0] - 2026-02-02

### Ajoute
- **Auto-creation de branches** : les workflows feature/bugfix/release creent automatiquement une branche et une PR active

### Modifie
- **Commandes namespacees** : toutes les references de commandes utilisent le format namespace (`/work:work-explore` au lieu de `/work-explore`)

### Corrige
- **CI ShellCheck** : resolution de SC2155 (declare and assign separately) dans `update.sh`

---

## [1.20.0] - 2026-02-01

### Ajoute
- **Auto CLAUDE.md** : generation automatique du CLAUDE.md lors de `update.sh` si absent
- **Default .gitignore** : ajout de `.claude/` et `CLAUDE.md` dans le .gitignore par defaut des nouveaux projets
- **Migration CLAUDE.md** : option `--upgrade-claude-md` dans `update.sh` pour migrer les anciens projets vers les @imports

### Modifie
- **CLAUDE.md @imports** : refactoring du CLAUDE.md pour utiliser des @imports vers `docs/reference/` (commands, project-structures, agents-catalog, hooks-reference, skills-catalog, advanced-features)

### Corrige
- **CI workflows** : optimisation pour les repos prives (reduction de la consommation de minutes GitHub Actions)

---

## [1.19.1] - 2026-01-30

### Corrige
- **Compteurs documentation** : alignement des compteurs (120 cmd, 57 agents, 41 skills, 21 rules) dans README badge, Docusaurus config (navbar/footer), quick-start, commands/index, skills/index, CONTRIBUTING, assistant.md
- **Badge version README** : correction v1.17.0 → v1.19.0

---

## [1.19.0] - 2026-01-30

### Ajoute
- **Sync documentation officielle** : alignement avec code.claude.com (nouveau domaine docs Anthropic)
- **Nouveaux Hook Events** : `UserPromptSubmit`, `PermissionRequest`, `PostToolUseFailure`, `SubagentStart`, `Stop` documentes dans CLAUDE.md
- **Prompt-based hooks** : documentation du type `prompt` (evaluation LLM) en plus du type `command`
- **CLAUDE.md @imports** : documentation de la syntaxe `@path/to/file` pour importer des fichiers
- **Plugins system** : documentation du systeme de plugins (`.claude-plugin/plugin.json`, marketplace, namespacing)
- **SessionStart matchers** : documentation des matchers `startup`, `resume`, `clear`, `compact`
- **Notification types** : ajout de `auth_success` et `elicitation_dialog`

### Modifie
- **URLs documentation** : migration de `docs.anthropic.com` vers `code.claude.com` dans tous les fichiers MD
- **Hook Events CLAUDE.md** : table enrichie avec 13 events (etait 8), types command/prompt
- **docs/CHEATSHEET.md** : mise a jour complete avec tous les 120 commandes par categorie, accents corriges
- **docs/ALIASES.md** : enrichissement avec orchestrateur, nouveaux alias dev/qa/ops/growth
- **docs/GUIDE.md** : restructuration et enrichissement du guide complet
- **docs/GUIDE-UTILISATEUR.md** : mise a jour du guide utilisateur
- **docs/CUSTOMIZATION.md** : mise a jour du guide de personnalisation

---

## [1.18.0] - 2026-01-30

### Ajoute
- **LSP Configuration** : `.lsp.json` avec support de 12 langages (TypeScript, Python, Go, Rust, Java, C/C++, C#, PHP, Kotlin, Ruby, HTML, CSS)
- **Regle LSP** : `.claude/rules/lsp.md` pour guider l'utilisation LSP vs Grep (navigation semantique)
- **Hooks Setup** : hook `Setup` avec `init` (install dependances) et `maintenance` (audit + update)
- **Hooks Notification** : hook `Notification` pour `permission_prompt` et `idle_prompt`
- **Hook SubagentStop** : log de fin des sub-agents pour tracabilite
- **Hook SessionEnd** : log de fin de session pour analytics
- **Hook PreCompact** : log avant compaction du contexte pour debugging
- **Skill qa-chrome** : tests visuels Chrome (debugging DOM, responsive, captures GIF)
- **Agent qa-chrome** : agent audit visuel Chrome (sonnet, Bash/Read/Grep/Glob)
- **Commande /qa-chrome** : commande pour invoquer les tests Chrome
- **Script setup-deps.sh** : script hook Setup detectant le type de projet et installant les dependances
- **Section CLI Flags** dans CLAUDE.md : 14 flags documentes (`--agent`, `--chrome`, `--teleport`, `--remote`, `--init`, `--maintenance`, `--max-budget-usd`, etc.)
- **Section LSP** dans CLAUDE.md : activation, langages supportes, guide LSP vs Grep
- **Section Bonnes Pratiques Skills** dans CLAUDE.md : taille, budget, frontmatter, substitutions, dynamic context injection

### Modifie
- **Hooks settings.json** : ajout de 5 nouveaux hook events (Setup, Notification, SubagentStop, SessionEnd, PreCompact)
- **Section Hooks CLAUDE.md** : reecrite avec tableau complet des 23 hooks configures et variables d'environnement
- **Skills frontmatter** : enrichissement de 26 skills avec `disable-model-invocation`, `argument-hint`, `model`, `user-invocable`
- **writing-skills/SKILL.md** : documentation complete des nouveaux champs frontmatter Claude Code 2.1+
- **Compteurs** : 120 commandes, 57 sub-agents, 41 skills, 21 regles (README, CLAUDE.md, website)

---

## [1.17.0] - 2026-01-29

### Securite
- **Mots de passe exemples** : remplacement de tous les `POSTGRES_PASSWORD=pass` par `${POSTGRES_PASSWORD:?required}` ou `${{ secrets.POSTGRES_PASSWORD }}` dans ops-docker, ops-ci, qa-automation
- **curl|sh** : remplacement du pattern `curl | sh` par download-then-execute dans `install-starship-theme.sh`
- **Avertissement curl|sh** : ajout d'un bloc securite dans `ops-vps.md` documentant le risque
- **CLAUDE.md** : enrichissement de la section Securite avec gestion des secrets, MCP security, curl|bash
- **Input validation** : ajout de `sanitize_input()` et `validate_input()` dans `scripts/lib/common.sh`

### Ajoute
- **`.claude/rules/README.md`** : index des 20 regles avec paths cibles et descriptions
- **`.claude/skills/README.md`** : mise a jour complete avec les 40 skills (etait 9)
- **CI validate-counts** : nouveau job `validate-counts` dans le pipeline CI
- **CI Semgrep SAST** : nouveau job `semgrep` (informatif) pour l'analyse statique de securite

### Corrige
- **validate-counts.sh** : exclusion des fichiers `README.md` du comptage (commands, agents, rules)

---

## [1.16.1] - 2026-01-29

### Corrige
- **Compteur DEV** : correction dans CLAUDE.md (24 → 23 commandes)
- **Compteur Skills** : correction dans CLAUDE.md (39 → 40 skills)
- **Index agents** : description mise a jour (37 → 56 sub-agents)
- **Workflows** : ajout de l'etape `/work-specify` dans les exemples de workflows
- **CI/docs** : echappement des chevrons dans dev-debug SKILL.md pour MDX
- **CI** : correction des erreurs ShellCheck et MDX build

### Ajoute
- **CONTRIBUTING.md** : guide de contribution avec setup, conventions et checklist
- **Synchronisation docs** : mise a jour complete de la documentation website (138 fichiers)

---

## [1.16.0] - 2026-01-28

### Ajouté
- **3 nouveaux agents** : `dev-document`, `growth-cro`, `qa-design`
  - `dev-document` (sonnet) : Génération de documents (PDF, DOCX, XLSX, PPTX)
  - `growth-cro` (haiku) : Optimisation du taux de conversion (CRO)
  - `qa-design` (haiku) : Audit UI/UX (100+ règles design web)
- **3 nouvelles commandes** : `/dev-document`, `/growth-cro`, `/qa-design`
- **7 nouveaux skills** :
  - `dev-document` : Génération de documents bureautiques
  - `growth-cro` : Optimisation CRO (conversion, signup, onboarding, paywall)
  - `qa-design` : Audit design UI/UX
  - `git-worktrees` : Développement parallèle avec git worktrees
  - `parallel-agents` : Orchestration d'agents parallèles (fan-out)
  - `session-handoff` : Transfert de contexte entre sessions IA
  - `writing-skills` : Guide pour créer de nouveaux skills
- **2 nouvelles règles** :
  - `nextjs.md` : Règles Next.js (RSC, App Router, data fetching, caching)
  - `verification.md` : Vérification avant completion (4 phases)
- **2 nouveaux scripts** :
  - `scripts/bump-version.sh` : Mise à jour unifiée de la version dans tous les fichiers
  - `scripts/validate-counts.sh` : Validation de la cohérence des compteurs (commands/agents/skills/rules)
- **Script thème GNOME Terminal** : `scripts/themes/install-gnome-terminal-theme.sh`

### Modifié
- **Skills enrichis** : Contenu étendu pour `dev-debug`, `dev-react-perf`, `dev-refactor`, `dev-supabase`, `qa-review`
- **Commandes enrichies** : `assistant`, `assistant-auto`, `doc-architecture`
- **Documentation complètement synchronisée** :
  - Tous les compteurs alignés sur 118 commands, 56 agents, 40 skills, 20 rules
  - README.md : badge version corrigé (v1.12.1 → v1.15.0), compteurs catégories corrigés
  - Website : 8 fichiers corrigés (index.tsx, architecture.md, quick-start.md, cheatsheet.md, FeatureComparison.tsx, docusaurus.config.ts, intro/index.md)
  - Politique de versioning mise à jour dans README.md

### Corrigé
- **Badge README.md** : Version affichée corrigée de v1.12.1 à v1.15.0 (maintenant v1.16.0)
- **Compteurs README.md** : dev (22→23), qa (12→14), ops (27→30), growth (9→11)
- **Website quick-start** : Version et compteurs obsolètes (v1.4.1/109/47 → v1.16.0/118/56)
- **Website architecture** : Compteurs mixtes corrigés (110/52/32/17 → 118/56/40/20)
- **Website index.tsx** : Compteurs homepage corrigés (108/45/27/17 → 118/56/40/20)
- **Website FeatureComparison** : Compteurs comparaison corrigés (100/37/24 → 118/56/40)
- **Website cheatsheet** : Compteurs footer corrigés (111/52/32/17 → 118/56/40/20)
- **Website docusaurus.config.ts** : Labels footer corrigés

### Technique
- Compteurs totaux : 118 commands (+0), 56 agents (+3), 40 skills (+7), 20 rules (+2)
- Nouveau script `bump-version.sh` pour éviter les désynchronisations futures
- Nouveau script `validate-counts.sh` pour validation CI des compteurs
- 38+ fichiers modifiés, ~1000 lignes ajoutées

---

## [1.15.0] - 2026-01-25

### Ajouté
- **Nouveaux hooks de qualité** (synchronisés depuis pve-home)
  - `SessionStart` : Vérification de node_modules manquant
  - `PreToolUse` : Exécution des tests avant commit (désactivable via `SKIP_PRE_COMMIT_TESTS=1`)
  - `PostToolUse` : Type-check TypeScript (`tsc --noEmit`) après modification
  - `PostToolUse` : Vérification ESLint après modification JS/TS
  - `PostToolUse` : Vérification couverture de tests après modification de fichiers `.test.ts`

### Technique
- 5 nouveaux hooks dans `.claude/settings.json`
- Synchronisation des fonctionnalités depuis le projet pve-home
- Variables d'environnement pour désactiver les hooks (SKIP_PRE_COMMIT_TESTS, ALLOW_MAIN_EDIT)
- Détection secrets gitleaks en PreToolUse (avant écriture) - pas de scan post-commit redondant

---

## [1.14.0] - 2026-01-24

### Ajouté
- **Collection de thèmes terminal** : 7 thèmes visuels complets dans `scripts/themes/`
  - Thèmes disponibles : matrix, cyberpunk, dracula, catppuccin, nord, gruvbox, tokyo-night
  - Chaque thème inclut 3 composants :
    - Configuration Starship (prompt) : `starship-themes/<theme>.toml`
    - Couleurs eza (listing moderne) : `eza-<theme>.sh`
    - Couleurs LS_COLORS (ls natif) : `ls-<theme>.sh`
  - Script d'installation interactif : `install-starship-theme.sh`
  - Documentation complète avec palettes de couleurs et aliases

### Technique
- 23 nouveaux fichiers de configuration de thèmes
- Support True Color (RGB 24-bit) pour tous les thèmes
- Aliases inclus : `ls`, `ll`, `la`, `lt`, `l`

---

## [1.13.0] - 2026-01-23

### Ajouté
- **Règle TDD Enforcement** : Nouvelle règle `.claude/rules/tdd-enforcement.md` pour déclencher proactivement le TDD
  - S'applique à tous les fichiers source (TS, JS, Dart, Python, Go, Rust, Java, C#, Ruby, PHP)
  - Mots-clés déclencheurs : "implémenter", "ajouter", "créer", "fixer", "corriger", "feature", "bugfix"
  - Exceptions définies : fichiers de config, documentation, refactoring mineur

- **Documentation Docusaurus** : Page `/docs/rules/tdd-enforcement` avec exemples et intégration

### Modifié
- **Skill dev-tdd** : Description élargie avec nouveaux mots-clés déclencheurs automatiques
- **Agent dev-tdd** : Description alignée avec le skill pour déclenchement étendu
- **Commandes dev-*** : Ajout de la section "Pré-requis TDD" obligatoire
  - `/dev-component` : Ordre de création TDD (types → tests → composant → stories)
  - `/dev-api` : Ordre de création TDD (spec → tests → handler → doc)
  - `/dev-hook` : Ordre de création TDD (types → tests → hook)
- **CLAUDE.md** : Compteur de règles mis à jour (17 → 18), documentation tdd-enforcement
- **Docusaurus** : Mise à jour de l'index des règles, skill TDD et workflow TDD avec cross-links

### Technique
- Score d'enforcement TDD amélioré de 5.4/10 à ~8/10
- Cross-linking établi entre rule, skill et workflow TDD

---

## [1.12.1] - 2026-01-22

### Ajouté
- **Documentation Docusaurus Skills** : 29 nouvelles pages de documentation pour les skills
  - Skills WORK : `work-commit`, `work-explore`, `work-plan`, `work-pr`
  - Skills DEV : `dev-api`, `dev-debug`, `dev-error-handling`, `dev-flutter`, `dev-graphql`, `dev-prompt-engineering`, `dev-react-perf`, `dev-refactor`, `dev-supabase`, `dev-tdd`
  - Skills DOC : `doc-changelog`, `doc-generate`
  - Skills OPS : `ops-ci`, `ops-database`, `ops-docker`, `ops-infra-code`, `ops-mobile-release`, `ops-monitoring`, `ops-opnsense`, `ops-proxmox`
  - Skills QA : `qa-e2e`, `qa-perf`, `qa-review`, `qa-security`, `qa-tech-debt`

### Modifié
- **Agent ops-opnsense** : Ajout des métadonnées standardisées (name, description, tools) dans le frontmatter
- **Documentation agents** : Mise à jour des métadonnées (outils, skills injectés)

### Corrigé
- **Tests smoke** : Mise à jour des noms de skills après harmonisation (test-driven-development → dev-tdd, etc.)

---

## [1.12.0] - 2026-01-22

### Ajouté
- **Support IaC OPNsense** : Configuration complète du firewall OPNsense via Terraform
  - Nouvelle commande `/ops-opnsense` pour gérer OPNsense en Infrastructure as Code
  - Nouvel agent `ops-opnsense` (modèle sonnet) avec skills infrastructure-as-code et opnsense-configuration
  - Nouveau skill `opnsense-configuration` avec patterns et bonnes pratiques

- **Templates Terraform OPNsense** (`.claude/templates/opnsense/`)
  - `provider-template.tf` : Configuration provider `browningluke/opnsense`
  - `interfaces-module.tf` : Interfaces WAN/LAN/VLAN avec gateway
  - `firewall-module.tf` : Règles firewall avec anti-lockout obligatoire
  - `nat-module.tf` : NAT outbound et port forwarding
  - `services-module.tf` : DHCP server et DNS Unbound
  - `aliases-module.tf` : Groupes d'adresses, ports et réseaux

- **Exemple complet Orange Box DMZ** (`examples/orange-box-dmz/`)
  - Configuration OPNsense derrière une box Orange en mode DMZ
  - 7 règles firewall (anti-lockout, web, DNS, NTP, ICMP, block-all)
  - DHCP, DNS forwarders Cloudflare, outputs avec résumé ASCII

- **Documentation Docusaurus**
  - Page commande `/ops-opnsense` (auto-générée)
  - Page agent `ops-opnsense` (auto-générée)
  - Page skill `opnsense-configuration` (auto-générée)
  - Exemple `opnsense-config.md` : Configuration complète avec code Terraform
  - Tutoriel `opnsense-firewall.md` : Guide pas-à-pas (45 min, niveau intermédiaire)

### Modifié
- **CLAUDE.md** : Ajout `/ops-opnsense` (115 commandes, 53 agents, 33 skills)
- **sidebars.ts** : OPS (24 → 30), ajout tutoriel et exemple OPNsense
- **Index pages** : Exemples et tutoriels mis à jour

### Corrigé
- **Provider OPNsense** : `allow_insecure_cert` → `allow_insecure` (attribut correct)

---

## [1.11.0] - 2026-01-22

### Ajouté
- **TDD obligatoire** dans le workflow d'implémentation
  - Le cycle Red-Green-Refactor devient obligatoire pour toute feature
  - Workflow mis à jour : Explore → Plan → **TDD** → Commit
  - Anti-pattern ajouté : "Coder AVANT d'écrire les tests"
  - Documentation Docusaurus mise à jour (13 fichiers)

- **Permissions optimisées** dans `settings.json`
  - `NotebookEdit` : Édition notebooks Jupyter sans confirmation
  - `TodoRead` / `TodoWrite` : Gestion todo list sans confirmation
  - `AskFollowup` : Questions de suivi sans confirmation
  - `mcp__*` : Tous les serveurs MCP autorisés

- **Nouveaux hooks d'auto-installation**
  - `pubspec.yaml` → `flutter pub get` automatique
  - `go.mod` → `go mod tidy` automatique
  - `Cargo.toml` → `cargo check` automatique

### Modifié
- **Deny list renforcée** (+10 patterns de sécurité)
  - `git restore .`, `git checkout .` bloqués
  - `rm -rf node_modules` bloqué
  - `shutdown`, `reboot`, `halt`, `poweroff` bloqués
  - Fork bomb et pipes dangereux bloqués

### Corrigé
- **CVE-2025-13465** : Patch lodash-es via npm overrides

### Documentation
- Mise à jour du workflow dans 13 fichiers Docusaurus
- WorkflowDiagram.tsx : Code → TDD dans les diagrammes
- FAQ et guides mis à jour

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
