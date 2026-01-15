# Aliases - Commandes Courtes

> Référence rapide pour utiliser les commandes en version abrégée.

## Comment utiliser

Les commandes complètes suivent le format `/project:categorie-action`.
Cette page fournit des raccourcis mentaux pour les mémoriser plus facilement.

---

## Workflow Principal

| Alias | Commande complète | Usage |
|-------|-------------------|-------|
| `/ex` | `/project:work-explore` | Explorer le code |
| `/pl` | `/project:work-plan` | Planifier |
| `/co` | `/project:work-commit` | Commiter |
| `/pr` | `/project:work-pr` | Pull Request |

## Workflows Chaînés

| Alias | Commande complète | Usage |
|-------|-------------------|-------|
| `/feat` | `/project:work-flow-feature` | Workflow feature complet |
| `/bugf` | `/project:work-flow-bugfix` | Workflow bugfix complet |
| `/rel` | `/project:work-flow-release` | Workflow release complet |
| `/launch` | `/project:work-flow-launch` | Workflow lancement complet |

---

## Développement (dev-)

| Alias | Commande complète | Usage |
|-------|-------------------|-------|
| `/tdd` | `/project:dev-tdd` | Test-Driven Development |
| `/test` | `/project:dev-test` | Générer des tests |
| `/dbg` | `/project:dev-debug` | Déboguer |
| `/ref` | `/project:dev-refactor` | Refactoring |
| `/api` | `/project:dev-api` | API endpoints |
| `/comp` | `/project:dev-component` | Créer un composant |
| `/hook` | `/project:dev-hook` | Créer un hook |

---

## Qualité (qa-)

| Alias | Commande complète | Usage |
|-------|-------------------|-------|
| `/rev` | `/project:qa-review` | Code review |
| `/sec` | `/project:qa-security` | Audit sécurité |
| `/perf` | `/project:qa-perf` | Performance |
| `/a11y` | `/project:qa-a11y` | Accessibilité |
| `/audit` | `/project:qa-audit` | Audit complet |
| `/resp` | `/project:qa-responsive` | Responsive |

---

## Opérations (ops-)

| Alias | Commande complète | Usage |
|-------|-------------------|-------|
| `/hot` | `/project:ops-hotfix` | Hotfix urgent |
| `/rls` | `/project:ops-release` | Release |
| `/deps` | `/project:ops-deps` | Dépendances |
| `/dock` | `/project:ops-docker` | Docker |
| `/mig` | `/project:ops-migrate` | Migration |
| `/ci` | `/project:ops-ci` | CI/CD |
| `/mon` | `/project:ops-monitoring` | Monitoring |
| `/db` | `/project:ops-database` | Base de données |
| `/health` | `/project:ops-health` | Health check |
| `/env` | `/project:ops-env` | Environnements |
| `/bak` | `/project:ops-backup` | Backup |

---

## Documentation (doc-)

| Alias | Commande complète | Usage |
|-------|-------------------|-------|
| `/doc` | `/project:doc-generate` | Générer doc |
| `/chg` | `/project:doc-changelog` | Changelog |
| `/exp` | `/project:doc-explain` | Expliquer code |
| `/onb` | `/project:doc-onboard` | Onboarding |
| `/i18n` | `/project:doc-i18n` | Internationalisation |
| `/fix` | `/project:doc-fix-issue` | Fix issue |
| `/spec` | `/project:doc-api-spec` | OpenAPI spec |

---

## Business (biz-)

| Alias | Commande complète | Usage |
|-------|-------------------|-------|
| `/biz` | `/project:biz-model` | Business model |
| `/mkt` | `/project:biz-market` | Analyse marché |
| `/mvp` | `/project:biz-mvp` | Définir MVP |
| `/price` | `/project:biz-pricing` | Pricing |
| `/pitch` | `/project:biz-pitch` | Pitch deck |
| `/road` | `/project:biz-roadmap` | Roadmap |
| `/lnch` | `/project:biz-launch` | Lancement |
| `/comp` | `/project:biz-competitor` | Analyse concurrent |
| `/okr` | `/project:biz-okr` | OKRs |

---

## Growth (growth-)

| Alias | Commande complète | Usage |
|-------|-------------------|-------|
| `/land` | `/project:growth-landing` | Landing page |
| `/seo` | `/project:growth-seo` | SEO |
| `/ana` | `/project:growth-analytics` | Analytics |
| `/ux` | `/project:growth-onboarding` | UX Onboarding |
| `/email` | `/project:growth-email` | Templates email |
| `/ab` | `/project:growth-ab-test` | A/B testing |

---

## Légal (legal-)

| Alias | Commande complète | Usage |
|-------|-------------------|-------|
| `/legal` | `/project:legal-docs` | Documents légaux |
| `/rgpd` | `/project:legal-rgpd` | Conformité RGPD |
| `/pay` | `/project:legal-payment` | Paiement |

---

## Mémo par catégorie

```
WORK   = Workflow de base (explore, plan, commit, pr)
DEV    = Développement (tdd, test, debug, refactor, api, component, hook)
QA     = Qualité (review, security, perf, a11y, audit, responsive)
OPS    = Opérations (hotfix, release, deps, docker, migrate, ci, monitoring, database, health, env, backup)
DOC    = Documentation (generate, changelog, explain, onboard, i18n, fix-issue, api-spec)
BIZ    = Business (model, market, mvp, pricing, pitch, roadmap, launch, competitor, okr)
GROWTH = Croissance (landing, seo, analytics, onboarding, email, ab-test)
LEGAL  = Légal (docs, rgpd, payment)
```

---

## Usage recommandé

### Workflow quotidien
```bash
# Nouvelle feature
/project:work-explore "comprendre l'auth"
/project:work-plan "ajouter 2FA"
/project:dev-tdd "implémenter 2FA"
/project:qa-review
/project:work-commit
/project:work-pr
```

### Workflow complet automatisé
```bash
# Feature complète
/project:work-flow-feature "ajouter dark mode"

# Bug fix complet
/project:work-flow-bugfix "bug #123"

# Release
/project:work-flow-release "v2.0.0"

# Lancement produit
/project:work-flow-launch "mon nouveau SaaS"
```

---

## Note

Les alias présentés dans ce document sont des **raccourcis mentaux** pour mémoriser les commandes.
La commande réelle à taper reste `/project:categorie-action`.

Pour une intégration shell avec de vrais alias, vous pouvez configurer votre `.bashrc` ou `.zshrc` :

```bash
# Exemple d'alias shell (optionnel)
alias cex="claude /project:work-explore"
alias cpl="claude /project:work-plan"
alias cco="claude /project:work-commit"
alias cpr="claude /project:work-pr"
```
