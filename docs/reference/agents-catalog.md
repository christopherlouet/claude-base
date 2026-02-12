# Agents Disponibles (121 commands, 57 sub-agents, 42 skills)

## Orchestrateur (Point d'entree unique)
| Commande | Mode | Usage |
|----------|------|-------|
| `/assistant` | Guide | Analyse → Recommande → Attend confirmation |
| `/assistant-auto` | Automatique | Analyse → Execute directement le workflow |

## WORK- : Workflow Principal (12)
| Commande | Usage |
|----------|-------|
| `/work:work-explore` | Explorer et comprendre le code |
| `/work:work-specify` | Creer une specification fonctionnelle (User Stories, criteres) |
| `/work:work-clarify` | Clarifier les ambiguites de la spec (questions ciblees) |
| `/work:work-plan` | Planifier une implementation (genere plan.md + tasks.md) |
| `/work:work-commit` | Creer un commit propre |
| `/work:work-pr` | Creer une Pull Request |
| `/work:work-commit-push-pr` | **Workflow complet: commit + push + PR** |
| `/work:work-team` | Lancer une equipe d'agents coordonnes (Agent Teams) |
| `/work:work-flow-feature` | Workflow complet feature |
| `/work:work-flow-bugfix` | Workflow complet bugfix |
| `/work:work-flow-release` | Workflow complet release |
| `/work:work-flow-launch` | Workflow complet lancement produit |

## DEV- : Developpement (23)
| Commande | Usage |
|----------|-------|
| `/dev:dev-tdd` | Developpement TDD |
| `/dev:dev-test` | Generer des tests |
| `/dev:dev-testing-setup` | Configurer l'infrastructure de tests |
| `/dev:dev-debug` | Deboguer un probleme (methodologie 4 phases) |
| `/dev:dev-refactor` | Refactoring guide + reduction d'entropie |
| `/dev:dev-document` | Generation de documents (PDF, DOCX, XLSX, PPTX) |
| `/dev:dev-api` | Creer/documenter API |
| `/dev:dev-api-versioning` | Versioning d'API |
| `/dev:dev-component` | Creer un composant UI complet |
| `/dev:dev-hook` | Creer un hook React/Vue |
| `/dev:dev-error-handling` | Strategie de gestion d'erreurs |
| `/dev:dev-react-perf` | Optimisation performance React/Next.js |
| `/dev:dev-mcp` | Creer des serveurs MCP (Model Context Protocol) |
| `/dev:dev-flutter` | Widgets et screens Flutter |
| `/dev:dev-supabase` | Backend Supabase (Auth, DB, Storage, Postgres perf) |
| `/dev:dev-graphql` | API GraphQL client/serveur |
| `/dev:dev-neovim` | Plugins et config Neovim/Lua |
| `/dev:dev-prompt-engineering` | Optimisation de prompts LLM |
| `/dev:dev-rag` | Systemes RAG (Retrieval-Augmented Generation) |
| `/dev:dev-design-system` | Design tokens et bibliotheque de composants |
| `/dev:dev-prisma` | ORM Prisma (schema, migrations, queries) |
| `/dev:dev-trpc` | APIs type-safe avec tRPC |
| `/dev:dev-ai-integration` | Integration LLMs (OpenAI, Claude API) |

## QA- : Qualite (15)
| Commande | Usage |
|----------|-------|
| `/qa:qa-review` | Code review approfondie + analyse de nommage |
| `/qa:qa-security` | Audit de securite OWASP |
| `/qa:qa-perf` | Analyse de performance |
| `/qa:qa-a11y` | Audit accessibilite WCAG |
| `/qa:qa-audit` | Audit qualite complet |
| `/qa:qa-chrome` | Tests visuels Chrome (debugging DOM, responsive, captures) |
| `/qa:qa-design` | Audit UI/UX (100+ regles design web) |
| `/qa:qa-responsive` | Audit responsive/mobile web |
| `/qa:qa-automation` | Automatisation des tests |
| `/qa:qa-coverage` | Analyse couverture de tests |
| `/qa:qa-kaizen` | Amelioration continue (PDCA, Muda) |
| `/qa:qa-mobile` | Audit qualite apps mobiles (Flutter) |
| `/qa:qa-neovim` | Audit config Neovim (perf, keymaps) |
| `/qa:qa-e2e` | Tests End-to-End (Playwright, Cypress) |
| `/qa:qa-tech-debt` | Identifier et prioriser la dette technique |

## OPS- : Operations (30)
| Commande | Usage |
|----------|-------|
| `/ops:ops-hotfix` | Correction urgente production |
| `/ops:ops-release` | Creer une release |
| `/ops:ops-gitflow-init` | Initialiser GitFlow (creer develop, configurer) |
| `/ops:ops-gitflow-feature` | Gerer les branches feature (start/finish) |
| `/ops:ops-gitflow-release` | Gerer les branches release (start/finish) |
| `/ops:ops-gitflow-hotfix` | Gerer les hotfixes GitFlow (start/finish) |
| `/ops:ops-deps` | Audit et MAJ des dependances |
| `/ops:ops-docker` | Dockeriser un projet |
| `/ops:ops-k8s` | Deploiement Kubernetes (manifests, Helm) |
| `/ops:ops-vps` | Deploiement VPS (OVH, Hetzner, DigitalOcean) |
| `/ops:ops-migrate` | Migration de code/dependances |
| `/ops:ops-ci` | Configuration CI/CD |
| `/ops:ops-monitoring` | Instrumentation code (logs, metriques, traces) |
| `/ops:ops-observability-stack` | Deployer Prometheus, Grafana, Loki, Alertmanager |
| `/ops:ops-grafana-dashboard` | Creer dashboards Grafana (templates, alertes) |
| `/ops:ops-database` | Schema, migrations DB |
| `/ops:ops-health` | Health check rapide |
| `/ops:ops-env` | Gestion des environnements |
| `/ops:ops-backup` | Strategie backup/restore |
| `/ops:ops-load-testing` | Tests de charge et stress |
| `/ops:ops-cost-optimization` | Optimisation couts cloud |
| `/ops:ops-disaster-recovery` | Plan de reprise apres sinistre |
| `/ops:ops-infra-code` | Infrastructure as Code (Terraform) |
| `/ops:ops-secrets-management` | Gestion securisee des secrets |
| `/ops:ops-mobile-release` | Publication App Store / Google Play |
| `/ops:ops-serverless` | Deploiement serverless (Lambda, Vercel, CF Workers) |
| `/ops:ops-vercel` | Configuration et deploiement Vercel |
| `/ops:ops-proxmox` | Infrastructure Proxmox VE (VMs, LXC, reseau, backup) |
| `/ops:ops-opnsense` | Configuration OPNsense via Terraform (firewall, NAT, DHCP/DNS) |
| `/ops:ops-rollback` | Procedure de rollback securisee |

## DOC- : Documentation (9)
| Commande | Usage |
|----------|-------|
| `/doc:doc-generate` | Generer de la documentation |
| `/doc:doc-changelog` | Generer/maintenir le changelog |
| `/doc:doc-explain` | Expliquer du code complexe |
| `/doc:doc-onboard` | Decouvrir un codebase |
| `/doc:doc-i18n` | Internationalisation |
| `/doc:doc-fix-issue` | Corriger une issue GitHub |
| `/doc:doc-api-spec` | Generer spec OpenAPI/Swagger |
| `/doc:doc-readme` | Creer/ameliorer README |
| `/doc:doc-architecture` | Documenter l'architecture |

## BIZ- : Business (11)
| Commande | Usage |
|----------|-------|
| `/biz:biz-model` | Business model, Lean Canvas |
| `/biz:biz-market` | Etude de marche |
| `/biz:biz-mvp` | Definir le MVP |
| `/biz:biz-pricing` | Strategie de pricing |
| `/biz:biz-pitch` | Creer un pitch deck |
| `/biz:biz-roadmap` | Planifier la roadmap |
| `/biz:biz-launch` | Workflow lancement complet |
| `/biz:biz-competitor` | Analyse concurrentielle |
| `/biz:biz-okr` | Definir les OKRs |
| `/biz:biz-personas` | Creer des personas utilisateur |
| `/biz:biz-research` | Recherche utilisateur |

## GROWTH- : Croissance (11)
| Commande | Usage |
|----------|-------|
| `/growth:growth-landing` | Creer/optimiser landing page |
| `/growth:growth-seo` | Audit SEO |
| `/growth:growth-analytics` | Setup tracking et KPIs |
| `/growth:growth-app-store-analytics` | Metriques App Store / Google Play |
| `/growth:growth-onboarding` | Parcours d'onboarding UX |
| `/growth:growth-email` | Templates email marketing |
| `/growth:growth-ab-test` | Planifier A/B tests |
| `/growth:growth-retention` | Strategies de retention |
| `/growth:growth-funnel` | Analyse et optimisation funnels |
| `/growth:growth-localization` | Strategie de localisation multi-marches |
| `/growth:growth-cro` | Optimisation du taux de conversion (CRO) |

## DATA- : Donnees (3)
| Commande | Usage |
|----------|-------|
| `/data:data-pipeline` | Concevoir pipelines ETL/ELT |
| `/data:data-analytics` | Analyse de donnees et rapports |
| `/data:data-modeling` | Modelisation data warehouse |

## LEGAL- : Legal (5)
| Commande | Usage |
|----------|-------|
| `/legal:legal-docs` | CGU, CGV, mentions legales |
| `/legal:legal-rgpd` | Conformite RGPD/GDPR |
| `/legal:legal-payment` | Integration paiement |
| `/legal:legal-terms-of-service` | Conditions Generales d'Utilisation |
| `/legal:legal-privacy-policy` | Politique de Confidentialite |

## Sub-Agents (57)

Claude delegue automatiquement aux agents specialises (contexte isole, outils restreints).

### Concepts

| Concept | Dossier | Declenchement | Contexte |
|---------|---------|---------------|----------|
| **Commands** | `.claude/commands/` | Manuel (`/nom`) | Partage |
| **Skills** | `.claude/skills/` | Automatique | Partage |
| **Agents** | `.claude/agents/` | Delegation auto | **Isole** |

### Agents par domaine

| Domaine | Agents | Modeles |
|---------|--------|---------|
| Exploration & Doc | `work-explore`, `doc-onboard`, `doc-generate`, `doc-changelog`, `doc-explain` | haiku |
| Qualite & Audits | `qa-audit`, `qa-security`, `qa-perf`, `qa-a11y`, `qa-coverage`, `qa-responsive`, `qa-e2e`, `qa-tech-debt`, `qa-design`, `qa-chrome` | haiku/sonnet |
| Operations | `ops-deps`, `ops-health`, `ops-docker`, `ops-ci`, `ops-database`, `ops-monitoring`, `ops-serverless`, `ops-vercel`, `ops-infra-code`, `ops-proxmox`, `ops-opnsense`, `ops-migration` | haiku/sonnet |
| Developpement | `dev-debug`, `dev-component`, `dev-test`, `dev-flutter`, `dev-supabase`, `dev-prompt-engineering`, `dev-rag`, `dev-design-system`, `dev-prisma`, `dev-trpc`, `dev-ai-integration`, `dev-document`, `dev-tdd` | haiku/sonnet |
| Business & Growth | `biz-model`, `biz-competitor`, `biz-mvp`, `biz-personas`, `growth-seo`, `growth-analytics`, `growth-landing`, `growth-funnel`, `growth-localization`, `growth-cro` | haiku |
| Data | `data-pipeline`, `data-analytics`, `data-modeling` | haiku/sonnet |
| Legal | `legal-rgpd`, `legal-payment`, `legal-privacy-policy`, `legal-terms-of-service` | haiku/sonnet |

### Configuration des Agents

Chaque agent definit: `model` (haiku/sonnet), `permissionMode` (plan/default), `disallowedTools`, `hooks`, `skills`.
