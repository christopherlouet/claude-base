# Aliases - Commandes Courtes

> Référence rapide pour utiliser les commandes en version abrégée.

## Comment utiliser

Les commandes complètes suivent le format `/categorie-action`.
Cette page fournit des raccourcis mentaux pour les mémoriser plus facilement.

---

## Orchestrateur

| Alias | Commande complète | Usage |
|-------|-------------------|-------|
| `/assist` | `/assistant` | Guide de choix des agents |

## Workflow Principal

| Alias | Commande complète | Usage |
|-------|-------------------|-------|
| `/ex` | `/work-explore` | Explorer le code |
| `/pl` | `/work-plan` | Planifier |
| `/co` | `/work-commit` | Commiter |
| `/pr` | `/work-pr` | Pull Request |

## Workflows Chaînés

| Alias | Commande complète | Usage |
|-------|-------------------|-------|
| `/feat` | `/work-flow-feature` | Workflow feature complet |
| `/bugf` | `/work-flow-bugfix` | Workflow bugfix complet |
| `/rel` | `/work-flow-release` | Workflow release complet |
| `/launch` | `/work-flow-launch` | Workflow lancement complet |

---

## Développement (dev-)

| Alias | Commande complète | Usage |
|-------|-------------------|-------|
| `/tdd` | `/dev-tdd` | Test-Driven Development |
| `/test` | `/dev-test` | Générer des tests |
| `/testsetup` | `/dev-testing-setup` | Configurer l'infra de tests |
| `/dbg` | `/dev-debug` | Déboguer |
| `/ref` | `/dev-refactor` | Refactoring |
| `/api` | `/dev-api` | API endpoints REST |
| `/apiv` | `/dev-api-versioning` | Versioning d'API |
| `/comp` | `/dev-component` | Créer un composant |
| `/hook` | `/dev-hook` | Créer un hook |
| `/err` | `/dev-error-handling` | Gestion d'erreurs |
| `/flutter` | `/dev-flutter` | Widgets Flutter |
| `/supa` | `/dev-supabase` | Backend Supabase |
| `/gql` | `/dev-graphql` | API GraphQL |

---

## Qualité (qa-)

| Alias | Commande complète | Usage |
|-------|-------------------|-------|
| `/rev` | `/qa-review` | Code review |
| `/sec` | `/qa-security` | Audit sécurité |
| `/perf` | `/qa-perf` | Performance |
| `/a11y` | `/qa-a11y` | Accessibilité |
| `/audit` | `/qa-audit` | Audit complet |
| `/resp` | `/qa-responsive` | Responsive |
| `/auto` | `/qa-automation` | Tests automatisés |
| `/cov` | `/qa-coverage` | Couverture de tests |
| `/mob` | `/qa-mobile` | Audit apps mobiles |

---

## Opérations (ops-)

| Alias | Commande complète | Usage |
|-------|-------------------|-------|
| `/hot` | `/ops-hotfix` | Hotfix urgent |
| `/rls` | `/ops-release` | Release |
| `/deps` | `/ops-deps` | Dépendances |
| `/dock` | `/ops-docker` | Docker |
| `/mig` | `/ops-migrate` | Migration |
| `/ci` | `/ops-ci` | CI/CD |
| `/mon` | `/ops-monitoring` | Monitoring |
| `/db` | `/ops-database` | Base de données |
| `/health` | `/ops-health` | Health check |
| `/env` | `/ops-env` | Environnements |
| `/bak` | `/ops-backup` | Backup |
| `/load` | `/ops-load-testing` | Tests de charge |
| `/cost` | `/ops-cost-optimization` | Optimisation coûts |
| `/disaster` | `/ops-disaster-recovery` | Plan de reprise |
| `/infra` | `/ops-infra-code` | Infrastructure as Code |
| `/secrets` | `/ops-secrets-management` | Gestion des secrets |

---

## Documentation (doc-)

| Alias | Commande complète | Usage |
|-------|-------------------|-------|
| `/doc` | `/doc-generate` | Générer doc |
| `/chg` | `/doc-changelog` | Changelog |
| `/exp` | `/doc-explain` | Expliquer code |
| `/onb` | `/doc-onboard` | Onboarding |
| `/i18n` | `/doc-i18n` | Internationalisation |
| `/fix` | `/doc-fix-issue` | Fix issue |
| `/spec` | `/doc-api-spec` | OpenAPI spec |
| `/readme` | `/doc-readme` | README |
| `/arch` | `/doc-architecture` | Architecture |

---

## Business (biz-)

| Alias | Commande complète | Usage |
|-------|-------------------|-------|
| `/biz` | `/biz-model` | Business model |
| `/mkt` | `/biz-market` | Analyse marché |
| `/mvp` | `/biz-mvp` | Définir MVP |
| `/price` | `/biz-pricing` | Pricing |
| `/pitch` | `/biz-pitch` | Pitch deck |
| `/road` | `/biz-roadmap` | Roadmap |
| `/lnch` | `/biz-launch` | Lancement |
| `/competitor` | `/biz-competitor` | Analyse concurrent |
| `/okr` | `/biz-okr` | OKRs |
| `/research` | `/biz-research` | Recherche utilisateur |
| `/personas` | `/biz-personas` | Personas |

---

## Growth (growth-)

| Alias | Commande complète | Usage |
|-------|-------------------|-------|
| `/land` | `/growth-landing` | Landing page |
| `/seo` | `/growth-seo` | SEO |
| `/ana` | `/growth-analytics` | Analytics |
| `/ux` | `/growth-onboarding` | UX Onboarding |
| `/email` | `/growth-email` | Templates email |
| `/ab` | `/growth-ab-test` | A/B testing |
| `/retain` | `/growth-retention` | Rétention |
| `/funnel` | `/growth-funnel` | Funnels |

---

## Données (data-)

| Alias | Commande complète | Usage |
|-------|-------------------|-------|
| `/pipe` | `/data-pipeline` | Pipelines ETL/ELT |
| `/dataana` | `/data-analytics` | Analyse de données |
| `/model` | `/data-modeling` | Modélisation DWH |

---

## Légal (legal-)

| Alias | Commande complète | Usage |
|-------|-------------------|-------|
| `/legal` | `/legal-docs` | Documents légaux |
| `/rgpd` | `/legal-rgpd` | Conformité RGPD |
| `/pay` | `/legal-payment` | Paiement |
| `/terms` | `/legal-terms-of-service` | CGU |
| `/privacy` | `/legal-privacy-policy` | Confidentialité |

---

## Mémo par catégorie

```
ASSISTANT = Orchestrateur (guide de choix des agents)
WORK      = Workflow de base (explore, plan, commit, pr) + workflows chaînés
DEV       = Développement (tdd, test, debug, refactor, api, component, hook, flutter, supabase, graphql...)
QA        = Qualité (review, security, perf, a11y, audit, responsive, automation, coverage, mobile)
OPS       = Opérations (hotfix, release, deps, docker, migrate, ci, monitoring, database, health, env, backup, load-testing, cost-optimization, disaster-recovery, infra-code, secrets-management)
DOC       = Documentation (generate, changelog, explain, onboard, i18n, fix-issue, api-spec, readme, architecture)
BIZ       = Business (model, market, mvp, pricing, pitch, roadmap, launch, competitor, okr, research, personas)
GROWTH    = Croissance (landing, seo, analytics, onboarding, email, ab-test, retention, funnel)
DATA      = Données (pipeline, analytics, modeling)
LEGAL     = Légal (docs, rgpd, payment, terms-of-service, privacy-policy)
```

---

## Usage recommandé

### Workflow quotidien
```bash
# Nouvelle feature
/work-explore "comprendre l'auth"
/work-plan "ajouter 2FA"
/dev-tdd "implémenter 2FA"
/qa-review
/work-commit
/work-pr
```

### Workflow complet automatisé
```bash
# Feature complète
/work-flow-feature "ajouter dark mode"

# Bug fix complet
/work-flow-bugfix "bug #123"

# Release
/work-flow-release "v2.0.0"

# Lancement produit
/work-flow-launch "mon nouveau SaaS"
```

### Application mobile Flutter
```bash
/work-explore → /work-plan → /dev-flutter + /dev-supabase → /qa-mobile → /work-pr
```

---

## Note

Les alias présentés dans ce document sont des **raccourcis mentaux** pour mémoriser les commandes.
La commande réelle à taper reste `/categorie-action`.

Pour une intégration shell avec de vrais alias, vous pouvez configurer votre `.bashrc` ou `.zshrc` :

```bash
# Exemple d'alias shell (optionnel)
alias cex="claude /work-explore"
alias cpl="claude /work-plan"
alias cco="claude /work-commit"
alias cpr="claude /work-pr"
```

---

*Claude-Socle v2.1 - 83 agents - 10 catégories - 9 skills*
