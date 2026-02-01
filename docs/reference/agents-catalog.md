# Agents Disponibles (119 commands, 57 sub-agents, 41 skills)

## Orchestrateur (Point d'entrée unique)
| Commande | Mode | Usage |
|----------|------|-------|
| `/assistant` | Guidé | Analyse → Recommande → Attend confirmation |
| `/assistant-auto` | Automatique | Analyse → Exécute directement le workflow |

## WORK- : Workflow Principal (10)
| Commande | Usage |
|----------|-------|
| `/work-explore` | Explorer et comprendre le code |
| `/work-specify` | Créer une spécification fonctionnelle (User Stories, critères) |
| `/work-clarify` | Clarifier les ambiguïtés de la spec (questions ciblées) |
| `/work-plan` | Planifier une implémentation (génère plan.md + tasks.md) |
| `/work-commit` | Créer un commit propre |
| `/work-pr` | Créer une Pull Request |
| `/work-flow-feature` | Workflow complet feature |
| `/work-flow-bugfix` | Workflow complet bugfix |
| `/work-flow-release` | Workflow complet release |
| `/work-flow-launch` | Workflow complet lancement produit |

## DEV- : Développement (23)
| Commande | Usage |
|----------|-------|
| `/dev-tdd` | Développement TDD |
| `/dev-test` | Générer des tests |
| `/dev-testing-setup` | Configurer l'infrastructure de tests |
| `/dev-debug` | Déboguer un problème (méthodologie 4 phases) |
| `/dev-refactor` | Refactoring guidé + réduction d'entropie |
| `/dev-document` | Génération de documents (PDF, DOCX, XLSX, PPTX) |
| `/dev-api` | Créer/documenter API |
| `/dev-api-versioning` | Versioning d'API |
| `/dev-component` | Créer un composant UI complet |
| `/dev-hook` | Créer un hook React/Vue |
| `/dev-error-handling` | Stratégie de gestion d'erreurs |
| `/dev-react-perf` | Optimisation performance React/Next.js |
| `/dev-mcp` | Créer des serveurs MCP (Model Context Protocol) |
| `/dev-flutter` | Widgets et screens Flutter |
| `/dev-supabase` | Backend Supabase (Auth, DB, Storage, Postgres perf) |
| `/dev-graphql` | API GraphQL client/serveur |
| `/dev-neovim` | Plugins et config Neovim/Lua |
| `/dev-prompt-engineering` | Optimisation de prompts LLM |
| `/dev-rag` | Systèmes RAG (Retrieval-Augmented Generation) |
| `/dev-design-system` | Design tokens et bibliothèque de composants |
| `/dev-prisma` | ORM Prisma (schema, migrations, queries) |
| `/dev-trpc` | APIs type-safe avec tRPC |
| `/dev-ai-integration` | Intégration LLMs (OpenAI, Claude API) |

## QA- : Qualité (15)
| Commande | Usage |
|----------|-------|
| `/qa-review` | Code review approfondie + analyse de nommage |
| `/qa-security` | Audit de sécurité OWASP |
| `/qa-perf` | Analyse de performance |
| `/qa-a11y` | Audit accessibilité WCAG |
| `/qa-audit` | Audit qualité complet |
| `/qa-chrome` | Tests visuels Chrome (debugging DOM, responsive, captures) |
| `/qa-design` | Audit UI/UX (100+ règles design web) |
| `/qa-responsive` | Audit responsive/mobile web |
| `/qa-automation` | Automatisation des tests |
| `/qa-coverage` | Analyse couverture de tests |
| `/qa-kaizen` | Amélioration continue (PDCA, Muda) |
| `/qa-mobile` | Audit qualité apps mobiles (Flutter) |
| `/qa-neovim` | Audit config Neovim (perf, keymaps) |
| `/qa-e2e` | Tests End-to-End (Playwright, Cypress) |
| `/qa-tech-debt` | Identifier et prioriser la dette technique |

## OPS- : Opérations (30)
| Commande | Usage |
|----------|-------|
| `/ops-hotfix` | Correction urgente production |
| `/ops-release` | Créer une release |
| `/ops-gitflow-init` | Initialiser GitFlow (créer develop, configurer) |
| `/ops-gitflow-feature` | Gérer les branches feature (start/finish) |
| `/ops-gitflow-release` | Gérer les branches release (start/finish) |
| `/ops-gitflow-hotfix` | Gérer les hotfixes GitFlow (start/finish) |
| `/ops-deps` | Audit et MAJ des dépendances |
| `/ops-docker` | Dockeriser un projet |
| `/ops-k8s` | Déploiement Kubernetes (manifests, Helm) |
| `/ops-vps` | Déploiement VPS (OVH, Hetzner, DigitalOcean) |
| `/ops-migrate` | Migration de code/dépendances |
| `/ops-ci` | Configuration CI/CD |
| `/ops-monitoring` | Instrumentation code (logs, métriques, traces) |
| `/ops-observability-stack` | Déployer Prometheus, Grafana, Loki, Alertmanager |
| `/ops-grafana-dashboard` | Créer dashboards Grafana (templates, alertes) |
| `/ops-database` | Schéma, migrations DB |
| `/ops-health` | Health check rapide |
| `/ops-env` | Gestion des environnements |
| `/ops-backup` | Stratégie backup/restore |
| `/ops-load-testing` | Tests de charge et stress |
| `/ops-cost-optimization` | Optimisation coûts cloud |
| `/ops-disaster-recovery` | Plan de reprise après sinistre |
| `/ops-infra-code` | Infrastructure as Code (Terraform) |
| `/ops-secrets-management` | Gestion sécurisée des secrets |
| `/ops-mobile-release` | Publication App Store / Google Play |
| `/ops-serverless` | Déploiement serverless (Lambda, Vercel, CF Workers) |
| `/ops-vercel` | Configuration et déploiement Vercel |
| `/ops-proxmox` | Infrastructure Proxmox VE (VMs, LXC, réseau, backup) |
| `/ops-opnsense` | Configuration OPNsense via Terraform (firewall, NAT, DHCP/DNS) |
| `/ops-rollback` | Procédure de rollback sécurisée |

## DOC- : Documentation (9)
| Commande | Usage |
|----------|-------|
| `/doc-generate` | Générer de la documentation |
| `/doc-changelog` | Générer/maintenir le changelog |
| `/doc-explain` | Expliquer du code complexe |
| `/doc-onboard` | Découvrir un codebase |
| `/doc-i18n` | Internationalisation |
| `/doc-fix-issue` | Corriger une issue GitHub |
| `/doc-api-spec` | Générer spec OpenAPI/Swagger |
| `/doc-readme` | Créer/améliorer README |
| `/doc-architecture` | Documenter l'architecture |

## BIZ- : Business (11)
| Commande | Usage |
|----------|-------|
| `/biz-model` | Business model, Lean Canvas |
| `/biz-market` | Étude de marché |
| `/biz-mvp` | Définir le MVP |
| `/biz-pricing` | Stratégie de pricing |
| `/biz-pitch` | Créer un pitch deck |
| `/biz-roadmap` | Planifier la roadmap |
| `/biz-launch` | Workflow lancement complet |
| `/biz-competitor` | Analyse concurrentielle |
| `/biz-okr` | Définir les OKRs |
| `/biz-personas` | Créer des personas utilisateur |
| `/biz-research` | Recherche utilisateur |

## GROWTH- : Croissance (11)
| Commande | Usage |
|----------|-------|
| `/growth-landing` | Créer/optimiser landing page |
| `/growth-seo` | Audit SEO |
| `/growth-analytics` | Setup tracking et KPIs |
| `/growth-app-store-analytics` | Métriques App Store / Google Play |
| `/growth-onboarding` | Parcours d'onboarding UX |
| `/growth-email` | Templates email marketing |
| `/growth-ab-test` | Planifier A/B tests |
| `/growth-retention` | Stratégies de rétention |
| `/growth-funnel` | Analyse et optimisation funnels |
| `/growth-localization` | Stratégie de localisation multi-marchés |
| `/growth-cro` | Optimisation du taux de conversion (CRO) |

## DATA- : Données (3)
| Commande | Usage |
|----------|-------|
| `/data-pipeline` | Concevoir pipelines ETL/ELT |
| `/data-analytics` | Analyse de données et rapports |
| `/data-modeling` | Modélisation data warehouse |

## LEGAL- : Légal (5)
| Commande | Usage |
|----------|-------|
| `/legal-docs` | CGU, CGV, mentions légales |
| `/legal-rgpd` | Conformité RGPD/GDPR |
| `/legal-payment` | Intégration paiement |
| `/legal-terms-of-service` | Conditions Générales d'Utilisation |
| `/legal-privacy-policy` | Politique de Confidentialité |

## Sub-Agents (Claude Code 2.1+)

Le projet inclut des **Sub-Agents** dans `.claude/agents/` pour les tâches qui bénéficient d'un contexte isolé.

### Différence Commands vs Skills vs Agents

| Concept | Dossier | Déclenchement | Contexte |
|---------|---------|---------------|----------|
| **Commands** | `.claude/commands/` | Manuel (`/nom`) | Partagé |
| **Skills** | `.claude/skills/` | Automatique | Partagé |
| **Agents** | `.claude/agents/` | Délégation auto | **Isolé** |

### Avantages des Sub-Agents

- **Contexte isolé** : Ne pollue pas la conversation principale
- **Outils restreints** : Accès limité (lecture seule pour les audits)
- **Modèle optimisé** : Haiku pour tâches simples (économie de tokens)
- **Parallélisation** : Plusieurs agents peuvent tourner simultanément

### Agents disponibles (57)

#### Exploration & Documentation
| Agent | Modèle | Outils | Usage |
|-------|--------|--------|-------|
| `work-explore` | haiku | Read, Grep, Glob | Explorer un codebase (lecture seule) |
| `doc-onboard` | haiku | Read, Grep, Glob | Onboarding nouveau développeur |
| `doc-generate` | haiku | Read, Grep, Glob | Génération documentation |
| `doc-changelog` | haiku | Read, Grep, Glob | Maintenance changelog |
| `doc-explain` | haiku | Read, Grep, Glob | Explication de code |

#### Qualité & Audits
| Agent | Modèle | Outils | Usage |
|-------|--------|--------|-------|
| `qa-audit` | sonnet | Read, Grep, Glob, Bash | Audit complet (sécu + RGPD + a11y + perf) |
| `qa-security` | sonnet | Read, Grep, Glob | Audit sécurité OWASP Top 10 |
| `qa-perf` | sonnet | Read, Grep, Glob, Bash | Audit performance, Core Web Vitals |
| `qa-a11y` | haiku | Read, Grep, Glob | Audit accessibilité WCAG 2.1 |
| `qa-coverage` | haiku | Read, Grep, Glob, Bash | Analyse couverture de tests |
| `qa-responsive` | haiku | Read, Grep, Glob | Audit responsive/mobile-first |
| `qa-e2e` | sonnet | Read, Grep, Glob, Bash | Tests E2E Playwright/Cypress |
| `qa-tech-debt` | haiku | Read, Grep, Glob | Identifier et prioriser la dette technique |
| `qa-design` | haiku | Read, Grep, Glob | Audit UI/UX (100+ règles design web) |
| `qa-chrome` | sonnet | Read, Grep, Glob, Bash | Tests visuels Chrome (DOM, console, responsive) |

#### Opérations
| Agent | Modèle | Outils | Usage |
|-------|--------|--------|-------|
| `ops-deps` | haiku | Read, Grep, Glob, Bash | Audit dépendances, vulnérabilités |
| `ops-health` | haiku | Read, Grep, Glob, Bash | Health check rapide du projet |
| `ops-docker` | haiku | Read, Grep, Glob, Bash | Containerisation Docker |
| `ops-ci` | haiku | Read, Grep, Glob, Bash | Configuration CI/CD |
| `ops-database` | sonnet | Read, Grep, Glob, Bash | Schémas et migrations DB |
| `ops-monitoring` | haiku | Read, Grep, Glob, Bash | Instrumentation et monitoring |
| `ops-serverless` | haiku | Read, Grep, Glob, Bash | Déploiement serverless |
| `ops-vercel` | haiku | Read, Grep, Glob, Bash | Configuration Vercel |
| `ops-infra-code` | sonnet | Read, Grep, Glob, Edit, Write, Bash | Infrastructure as Code (Terraform/OpenTofu) |
| `ops-proxmox` | sonnet | Read, Grep, Glob, Edit, Write, Bash | Infrastructure Proxmox VE (VMs, LXC, réseau, backup) |
| `ops-opnsense` | sonnet | Read, Grep, Glob, Edit, Write, Bash | Configuration OPNsense (interfaces, firewall, NAT, DHCP/DNS) |
| `ops-migration` | sonnet | Read, Grep, Glob, Bash | Migration de frameworks et versions |

#### Développement
| Agent | Modèle | Outils | Usage |
|-------|--------|--------|-------|
| `dev-debug` | sonnet | Read, Grep, Glob, Bash | Investigation et diagnostic de bugs |
| `dev-component` | haiku | Read, Grep, Glob | Création composants UI |
| `dev-test` | haiku | Read, Grep, Glob, Bash | Génération de tests |
| `dev-flutter` | sonnet | Read, Grep, Glob | Widgets et screens Flutter |
| `dev-supabase` | sonnet | Read, Grep, Glob, Bash | Backend Supabase |
| `dev-prompt-engineering` | sonnet | Read, Grep, Glob, WebFetch | Optimisation prompts LLM |
| `dev-rag` | sonnet | Read, Grep, Glob, Bash | Architecture RAG |
| `dev-design-system` | haiku | Read, Grep, Glob | Design tokens et composants |
| `dev-prisma` | haiku | Read, Grep, Glob, Bash | ORM Prisma |
| `dev-trpc` | haiku | Read, Grep, Glob | APIs type-safe tRPC |
| `dev-ai-integration` | sonnet | Read, Grep, Glob, Bash | Intégration LLMs (OpenAI, Claude) |
| `dev-document` | sonnet | Read, Grep, Glob, Edit, Write, Bash | Génération documents (PDF, DOCX, XLSX, PPTX) |
| `dev-tdd` | sonnet | Read, Grep, Glob, Edit, Write, Bash | Développement TDD (Red-Green-Refactor) |

#### Business & Growth
| Agent | Modèle | Outils | Usage |
|-------|--------|--------|-------|
| `biz-model` | haiku | Read, Grep, Glob, WebSearch | Analyse business model, Lean Canvas |
| `biz-competitor` | haiku | Read, Grep, Glob, WebSearch | Analyse concurrentielle |
| `biz-mvp` | haiku | Read, Grep, Glob | Définition MVP |
| `biz-personas` | haiku | Read, Grep, Glob, WebSearch | Création personas |
| `growth-seo` | haiku | Read, Grep, Glob, WebFetch | Audit SEO technique |
| `growth-analytics` | haiku | Read, Grep, Glob | Setup analytics |
| `growth-landing` | haiku | Read, Grep, Glob | Optimisation landing |
| `growth-funnel` | haiku | Read, Grep, Glob | Analyse funnels |
| `growth-localization` | haiku | Read, Grep, Glob | Stratégie de localisation multi-marchés |
| `growth-cro` | haiku | Read, Grep, Glob | Optimisation taux de conversion (CRO) |

#### Data
| Agent | Modèle | Outils | Usage |
|-------|--------|--------|-------|
| `data-pipeline` | sonnet | Read, Grep, Glob, Bash | Pipelines ETL/ELT |
| `data-analytics` | haiku | Read, Grep, Glob | Analyse de données |
| `data-modeling` | sonnet | Read, Grep, Glob | Modélisation DW |

#### Légal
| Agent | Modèle | Outils | Usage |
|-------|--------|--------|-------|
| `legal-rgpd` | haiku | Read, Grep, Glob | Conformité RGPD |
| `legal-payment` | sonnet | Read, Grep, Glob | Intégration paiement |
| `legal-privacy-policy` | haiku | Read, Grep, Glob | Politique confidentialité |
| `legal-terms-of-service` | haiku | Read, Grep, Glob | CGU |

### Utilisation

Claude délègue automatiquement aux agents appropriés selon le contexte :

```
"Explore le code d'authentification"     → work-explore (haiku, lecture seule)
"Fais un audit de sécurité"              → qa-security (sonnet, OWASP)
"Vérifie les dépendances"                → ops-deps (haiku, npm audit)
"Analyse les concurrents"                → biz-competitor (haiku, recherche web)
```

### Configuration des Agents

Chaque agent définit:
- **model**: `haiku` (rapide/économique) ou `sonnet` (complexe)
- **permissionMode**: `plan` (lecture seule) ou `default`
- **disallowedTools**: Outils interdits (ex: `Edit, Write, NotebookEdit`)
- **hooks**: Validations automatiques (PreToolUse, PostToolUse)
- **skills**: Skills injectés dans l'agent (ex: `qa-security`, `work-explore`)
