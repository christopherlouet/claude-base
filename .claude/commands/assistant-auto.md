# Agent ASSISTANT-AUTO (Execution Automatique)

Orchestrateur en mode automatique. Analyse et execute immediatement le workflow approprie.

## Contexte de la demande
$ARGUMENTS

## Objectif

Analyser rapidement la demande, determiner le workflow le plus adapte,
et l'executer immediatement via l'outil Skill (sans demander confirmation).

## Mapping Demande -> Workflow

| Type de demande | Workflow |
|-----------------|---------|
| Nouvelle feature, ajout, creer | `work:work-flow-feature` |
| Bug, correction, erreur, fix | `work:work-flow-bugfix` |
| Release, version, tag | `work:work-flow-release` |
| Lancement produit, MVP | `work:work-flow-launch` |
| Audit securite, OWASP | `qa:qa-security` |
| Audit complet, qualite | `qa:qa-audit` |
| Explorer, comprendre code | `work:work-explore` |
| Commit, commiter | `work:work-commit` |
| Pull Request, PR, merge | `work:work-pr` |
| Tests, TDD | `dev:dev-tdd` |
| Refactoring, nettoyer | `dev:dev-refactor` |
| Debug, deboguer | `dev:dev-debug` |
| API, endpoint | `dev:dev-api` |
| Composant, UI | `dev:dev-component` |
| Docker, container | `ops:ops-docker` |
| CI/CD, pipeline | `ops:ops-ci` |
| Document, PDF, rapport | `dev:dev-document` |
| Audit UI/UX | `qa:qa-design` |
| CRO, conversion | `growth:growth-cro` |
| Dette technique | `qa:qa-tech-debt` |
| Proxmox, VM, LXC | `ops:ops-proxmox` |
| OPNsense, firewall | `ops:ops-opnsense` |
| Terraform, IaC | `ops:ops-infra-code` |
| IA, LLM, Claude API | `dev:dev-ai-integration` |
| SEO, referencement | `growth:growth-seo` |
| Flutter, mobile | `dev:dev-flutter` |
| Supabase, auth, RLS | `dev:dev-supabase` |
| GraphQL, resolver | `dev:dev-graphql` |
| Accessibilite, WCAG | `qa:wcag-audit` |
| Performance, latence | `qa:qa-perf` |
| E2E, Playwright | `qa:qa-e2e` |
| Landing page | `growth:growth-landing` |
| Review, code review | `qa:qa-review` |
| Chrome, test visuel | `qa:qa-chrome` |
| Responsive | `qa:qa-responsive` |
| Couverture tests | `qa:qa-coverage` |
| Documentation | `doc:doc-generate` |
| Changelog | `doc:doc-changelog` |
| Expliquer code | `doc:doc-explain` |
| Onboarding | `doc:doc-onboard` |
| README | `doc:doc-readme` |
| Architecture | `doc:doc-architecture` |
| i18n | `doc:doc-i18n` |
| Issue GitHub | `doc:doc-fix-issue` |
| OpenAPI, Swagger | `doc:doc-api-spec` |
| Business model | `biz:biz-model` |
| MVP | `biz:biz-mvp` |
| Etude de marche | `biz:biz-market` |
| Pricing | `biz:biz-pricing` |
| Pitch deck | `biz:biz-pitch` |
| Roadmap | `biz:biz-roadmap` |
| Lancement produit | `biz:biz-launch` |
| Concurrents | `biz:biz-competitor` |
| OKR | `biz:biz-okr` |
| Personas | `biz:biz-personas` |
| UX research | `biz:biz-research` |
| ETL, pipeline donnees | `data:data-pipeline` |
| Analyse donnees | `data:data-analytics` |
| Data warehouse | `data:data-modeling` |
| RGPD, GDPR | `legal:legal-rgpd` |
| CGU | `legal:legal-terms-of-service` |
| Privacy policy | `legal:legal-privacy-policy` |
| Paiement, Stripe | `legal:legal-payment` |
| CGV, mentions legales | `legal:legal-docs` |
| Dependencies, npm audit | `ops:ops-deps` |
| Health check | `ops:ops-health` |
| Release ops | `ops:ops-release` |
| Hotfix | `ops:ops-hotfix` |
| Rollback | `ops:ops-rollback` |
| Kubernetes | `ops:ops-k8s` |
| Database, migration | `ops:ops-database` |
| Monitoring, logs | `ops:ops-monitoring` |
| GitFlow | `ops:ops-gitflow-feature` |
| Serverless, Lambda | `ops:ops-serverless` |
| Vercel | `ops:ops-vercel` |
| Question simple | Reponse directe (pas de workflow) |

## Output attendu

Afficher un resume bref puis invoquer immediatement l'outil Skill :
- **Demande** : resume en 1 ligne
- **Workflow** : nom du workflow
- Puis `Skill(skill: "xxx", args: "...")`

---

CRITICAL: Tu DOIS utiliser l'outil Skill pour executer le workflow apres l'analyse.

CRITICAL: Ne JAMAIS demander confirmation. Analyser et executer directement.

CRITICAL: Si aucun argument fourni, demander ce que l'utilisateur veut faire.

YOU MUST utiliser le nom qualifie complet du skill (ex: `work:work-flow-feature`).

YOU MUST passer la demande originale en argument au workflow.
