# Agents Disponibles (120 commands, 57 sub-agents, 41 skills)

## Orchestrateur (Point d'entrée unique)
| Commande | Mode | Usage |
|----------|------|-------|
| `/assistant` | Guidé | Analyse → Recommande → Attend confirmation |
| `/assistant-auto` | Automatique | Analyse → Exécute directement le workflow |

## WORK- : Workflow Principal (11)
| Commande | Usage |
|----------|-------|
| `/work:work-explore` | Explorer et comprendre le code |
| `/work:work-specify` | Créer une spécification fonctionnelle (User Stories, critères) |
| `/work:work-clarify` | Clarifier les ambiguïtés de la spec (questions ciblées) |
| `/work:work-plan` | Planifier une implémentation (génère plan.md + tasks.md) |
| `/work:work-commit` | Créer un commit propre |
| `/work:work-pr` | Créer une Pull Request |
| `/work:work-commit-push-pr` | **Workflow complet: commit + push + PR (recommandé par Boris Cherny)** |
| `/work:work-flow-feature` | Workflow complet feature |
| `/work:work-flow-bugfix` | Workflow complet bugfix |
| `/work:work-flow-release` | Workflow complet release |
| `/work:work-flow-launch` | Workflow complet lancement produit |

## DEV- : Développement (23)
| Commande | Usage |
|----------|-------|
| `/dev:dev-tdd` | Développement TDD |
| `/dev:dev-test` | Générer des tests |
| `/dev:dev-testing-setup` | Configurer l'infrastructure de tests |
| `/dev:dev-debug` | Déboguer un problème (méthodologie 4 phases) |
| `/dev:dev-refactor` | Refactoring guidé + réduction d'entropie |
| `/dev:dev-document` | Génération de documents (PDF, DOCX, XLSX, PPTX) |
| `/dev:dev-api` | Créer/documenter API |
| `/dev:dev-api-versioning` | Versioning d'API |
| `/dev:dev-component` | Créer un composant UI complet |
| `/dev:dev-hook` | Créer un hook React/Vue |
| `/dev:dev-error-handling` | Stratégie de gestion d'erreurs |
| `/dev:dev-react-perf` | Optimisation performance React/Next.js |
| `/dev:dev-mcp` | Créer des serveurs MCP (Model Context Protocol) |
| `/dev:dev-flutter` | Widgets et screens Flutter |
| `/dev:dev-supabase` | Backend Supabase (Auth, DB, Storage, Postgres perf) |
| `/dev:dev-graphql` | API GraphQL client/serveur |
| `/dev:dev-neovim` | Plugins et config Neovim/Lua |
| `/dev:dev-prompt-engineering` | Optimisation de prompts LLM |
| `/dev:dev-rag` | Systèmes RAG (Retrieval-Augmented Generation) |
| `/dev:dev-design-system` | Design tokens et bibliothèque de composants |
| `/dev:dev-prisma` | ORM Prisma (schema, migrations, queries) |
| `/dev:dev-trpc` | APIs type-safe avec tRPC |
| `/dev:dev-ai-integration` | Intégration LLMs (OpenAI, Claude API) |

## QA- : Qualité (15)
| Commande | Usage |
|----------|-------|
| `/qa:qa-review` | Code review approfondie + analyse de nommage |
| `/qa:qa-security` | Audit de sécurité OWASP |
| `/qa:qa-perf` | Analyse de performance |
| `/qa:qa-a11y` | Audit accessibilité WCAG |
| `/qa:qa-audit` | Audit qualité complet |
| `/qa:qa-chrome` | Tests visuels Chrome (debugging DOM, responsive, captures) |
| `/qa:qa-design` | Audit UI/UX (100+ règles design web) |
| `/qa:qa-responsive` | Audit responsive/mobile web |
| `/qa:qa-automation` | Automatisation des tests |
| `/qa:qa-coverage` | Analyse couverture de tests |
| `/qa:qa-kaizen` | Amélioration continue (PDCA, Muda) |
| `/qa:qa-mobile` | Audit qualité apps mobiles (Flutter) |
| `/qa:qa-neovim` | Audit config Neovim (perf, keymaps) |
| `/qa:qa-e2e` | Tests End-to-End (Playwright, Cypress) |
| `/qa:qa-tech-debt` | Identifier et prioriser la dette technique |

## OPS- : Opérations (30)
| Commande | Usage |
|----------|-------|
| `/ops:ops-hotfix` | Correction urgente production |
| `/ops:ops-release` | Créer une release |
| `/ops:ops-gitflow-init` | Initialiser GitFlow (créer develop, configurer) |
| `/ops:ops-gitflow-feature` | Gérer les branches feature (start/finish) |
| `/ops:ops-gitflow-release` | Gérer les branches release (start/finish) |
| `/ops:ops-gitflow-hotfix` | Gérer les hotfixes GitFlow (start/finish) |
| `/ops:ops-deps` | Audit et MAJ des dépendances |
| `/ops:ops-docker` | Dockeriser un projet |
| `/ops:ops-k8s` | Déploiement Kubernetes (manifests, Helm) |
| `/ops:ops-vps` | Déploiement VPS (OVH, Hetzner, DigitalOcean) |
| `/ops:ops-migrate` | Migration de code/dépendances |
| `/ops:ops-ci` | Configuration CI/CD |
| `/ops:ops-monitoring` | Instrumentation code (logs, métriques, traces) |
| `/ops:ops-observability-stack` | Déployer Prometheus, Grafana, Loki, Alertmanager |
| `/ops:ops-grafana-dashboard` | Créer dashboards Grafana (templates, alertes) |
| `/ops:ops-database` | Schéma, migrations DB |
| `/ops:ops-health` | Health check rapide |
| `/ops:ops-env` | Gestion des environnements |
| `/ops:ops-backup` | Stratégie backup/restore |
| `/ops:ops-load-testing` | Tests de charge et stress |
| `/ops:ops-cost-optimization` | Optimisation coûts cloud |
| `/ops:ops-disaster-recovery` | Plan de reprise après sinistre |
| `/ops:ops-infra-code` | Infrastructure as Code (Terraform) |
| `/ops:ops-secrets-management` | Gestion sécurisée des secrets |
| `/ops:ops-mobile-release` | Publication App Store / Google Play |
| `/ops:ops-serverless` | Déploiement serverless (Lambda, Vercel, CF Workers) |
| `/ops:ops-vercel` | Configuration et déploiement Vercel |
| `/ops:ops-proxmox` | Infrastructure Proxmox VE (VMs, LXC, réseau, backup) |
| `/ops:ops-opnsense` | Configuration OPNsense via Terraform (firewall, NAT, DHCP/DNS) |
| `/ops:ops-rollback` | Procédure de rollback sécurisée |

## DOC- : Documentation (9)
| Commande | Usage |
|----------|-------|
| `/doc:doc-generate` | Générer de la documentation |
| `/doc:doc-changelog` | Générer/maintenir le changelog |
| `/doc:doc-explain` | Expliquer du code complexe |
| `/doc:doc-onboard` | Découvrir un codebase |
| `/doc:doc-i18n` | Internationalisation |
| `/doc:doc-fix-issue` | Corriger une issue GitHub |
| `/doc:doc-api-spec` | Générer spec OpenAPI/Swagger |
| `/doc:doc-readme` | Créer/améliorer README |
| `/doc:doc-architecture` | Documenter l'architecture |

## BIZ- : Business (11)
| Commande | Usage |
|----------|-------|
| `/biz:biz-model` | Business model, Lean Canvas |
| `/biz:biz-market` | Étude de marché |
| `/biz:biz-mvp` | Définir le MVP |
| `/biz:biz-pricing` | Stratégie de pricing |
| `/biz:biz-pitch` | Créer un pitch deck |
| `/biz:biz-roadmap` | Planifier la roadmap |
| `/biz:biz-launch` | Workflow lancement complet |
| `/biz:biz-competitor` | Analyse concurrentielle |
| `/biz:biz-okr` | Définir les OKRs |
| `/biz:biz-personas` | Créer des personas utilisateur |
| `/biz:biz-research` | Recherche utilisateur |

## GROWTH- : Croissance (11)
| Commande | Usage |
|----------|-------|
| `/growth:growth-landing` | Créer/optimiser landing page |
| `/growth:growth-seo` | Audit SEO |
| `/growth:growth-analytics` | Setup tracking et KPIs |
| `/growth:growth-app-store-analytics` | Métriques App Store / Google Play |
| `/growth:growth-onboarding` | Parcours d'onboarding UX |
| `/growth:growth-email` | Templates email marketing |
| `/growth:growth-ab-test` | Planifier A/B tests |
| `/growth:growth-retention` | Stratégies de rétention |
| `/growth:growth-funnel` | Analyse et optimisation funnels |
| `/growth:growth-localization` | Stratégie de localisation multi-marchés |
| `/growth:growth-cro` | Optimisation du taux de conversion (CRO) |

## DATA- : Données (3)
| Commande | Usage |
|----------|-------|
| `/data:data-pipeline` | Concevoir pipelines ETL/ELT |
| `/data:data-analytics` | Analyse de données et rapports |
| `/data:data-modeling` | Modélisation data warehouse |

## LEGAL- : Légal (5)
| Commande | Usage |
|----------|-------|
| `/legal:legal-docs` | CGU, CGV, mentions légales |
| `/legal:legal-rgpd` | Conformité RGPD/GDPR |
| `/legal:legal-payment` | Intégration paiement |
| `/legal:legal-terms-of-service` | Conditions Générales d'Utilisation |
| `/legal:legal-privacy-policy` | Politique de Confidentialité |

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
