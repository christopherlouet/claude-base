# Guide de choix des commandes

> Quelle commande utiliser selon votre intention

## Par intention

| Je veux... | Commande |
|------------|----------|
| Comprendre le code existant | `/work-explore` |
| Creer une specification | `/work-specify` |
| Clarifier les ambiguites | `/work-clarify` |
| Planifier l'implementation | `/work-plan` |
| Developper avec TDD | `/dev-tdd` |
| Creer des tests | `/dev-test` |
| Debugger un probleme | `/dev-debug` |
| Refactorer du code | `/dev-refactor` |
| Creer une API | `/dev-api` |
| Creer un composant UI | `/dev-component` |
| Creer un commit | `/work-commit` |
| Creer une PR | `/work-pr` |

## Par type de projet

### Web (React/Next.js)

| Tache | Commande |
|-------|----------|
| Optimiser les performances React | `/dev-react-perf` |
| Creer un composant | `/dev-component` |
| Creer un hook | `/dev-hook` |
| Audit accessibilite | `/qa-a11y` |
| Audit responsive | `/qa-responsive` |

### Mobile (Flutter)

| Tache | Commande |
|-------|----------|
| Creer widget/screen | `/dev-flutter` |
| Backend Supabase | `/dev-supabase` |
| Audit qualite mobile | `/qa-mobile` |
| Publication stores | `/ops-mobile-release` |

### API

| Tache | Commande |
|-------|----------|
| Creer endpoint REST | `/dev-api` |
| Creer API GraphQL | `/dev-graphql` |
| Versioning API | `/dev-api-versioning` |
| Documenter API | `/doc-api-spec` |

## Par phase du workflow

### Phase EXPLORE

| Commande | Usage |
|----------|-------|
| `/work-explore` | Comprendre le code, patterns, architecture |
| `/doc-onboard` | Decouvrir un nouveau codebase |
| `/doc-explain` | Expliquer du code complexe |

### Phase SPECIFY

| Commande | Usage |
|----------|-------|
| `/work-specify` | Creer User Stories et criteres d'acceptation |
| `/work-clarify` | Reduire les ambiguites de la spec |

### Phase PLAN

| Commande | Usage |
|----------|-------|
| `/work-plan` | Planifier architecture et taches |

### Phase CODE

| Commande | Usage |
|----------|-------|
| `/dev-tdd` | Developper en Test-Driven Development |
| `/dev-test` | Generer des tests |
| `/dev-refactor` | Refactorer proprement |
| `/dev-debug` | Investiguer un bug |

### Phase COMMIT

| Commande | Usage |
|----------|-------|
| `/work-commit` | Commit avec message Conventional Commits |
| `/work-pr` | Creer une Pull Request complete |

## Workflows complets

| Situation | Workflow |
|-----------|----------|
| Nouvelle feature | `/work-flow-feature "description"` |
| Correction de bug | `/work-flow-bugfix "description"` |
| Nouvelle release | `/work-flow-release "v1.2.0"` |
| Lancement produit | `/work-flow-launch "nom du produit"` |

## Audits et qualite

| Besoin | Commande |
|--------|----------|
| Audit complet (secu + RGPD + a11y + perf) | `/qa-audit` |
| Audit securite OWASP | `/qa-security` |
| Audit performance | `/qa-perf` |
| Audit accessibilite WCAG | `/qa-a11y` |
| Code review | `/qa-review` |
| Couverture de tests | `/qa-coverage` |

## Operations

| Besoin | Commande |
|--------|----------|
| Dockeriser | `/ops-docker` |
| Configurer CI/CD | `/ops-ci` |
| Gerer les dependances | `/ops-deps` |
| Creer une release | `/ops-release` |
| Hotfix urgent | `/ops-hotfix` |
| Health check | `/ops-health` |

## Business

| Besoin | Commande |
|--------|----------|
| Business model / Lean Canvas | `/biz-model` |
| Definir le MVP | `/biz-mvp` |
| Analyse concurrentielle | `/biz-competitor` |
| Creer des personas | `/biz-personas` |
| Strategie de pricing | `/biz-pricing` |
| Roadmap produit | `/biz-roadmap` |

## Point d'entree intelligent

Si vous ne savez pas quelle commande utiliser, demandez a l'orchestrateur :

```bash
/assistant
```

Il analysera votre besoin et vous orientera vers la bonne commande.

---

Voir aussi :
- [ARCHITECTURE.md](docs/ARCHITECTURE.md) - Comprendre Commands vs Agents vs Skills
- [QUICKSTART.md](docs/QUICKSTART.md) - Demarrage rapide
- [CLAUDE.md](CLAUDE.md) - Documentation complete
