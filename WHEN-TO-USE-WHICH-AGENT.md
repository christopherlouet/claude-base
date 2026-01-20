# Guide de Choix des Agents et Commandes

> Comment choisir le bon agent parmi les 47 disponibles dans claude-socle.

## Matrice de Decision Rapide

### Par Situation

| Je veux... | Agent Recommande | Commande |
|------------|------------------|----------|
| Comprendre du code existant | `work-explore` | `/work-explore` |
| Creer une specification | - | `/work-specify` |
| Clarifier les ambiguites | - | `/work-clarify` |
| Planifier une feature | - | `/work-plan` |
| Debugger un probleme | `dev-debug` | `/dev-debug` |
| Faire une code review | - | `/qa-review` |
| Verifier la securite | `qa-security` | `/qa-security` |
| Auditer la performance | `qa-perf` | `/qa-perf` |
| Verifier l'accessibilite | `qa-a11y` | `/qa-a11y` |
| Creer des tests | `dev-test` | `/dev-test` |
| Refactorer du code | - | `/dev-refactor` |
| Creer un commit | - | `/work-commit` |
| Creer une PR | - | `/work-pr` |

### Par Type de Projet

| Type de Projet | Agents Cles |
|----------------|-------------|
| **Web React/Next.js** | `work-explore`, `dev-component`, `qa-perf`, `qa-responsive` |
| **Mobile Flutter** | `work-explore`, `dev-flutter`, `dev-supabase`, `qa-mobile` |
| **API REST/GraphQL** | `work-explore`, `qa-security`, `doc-generate` |
| **Data/ETL** | `data-pipeline`, `data-modeling`, `data-analytics` |
| **Infrastructure** | `ops-docker`, `ops-ci`, `ops-infra-code`, `ops-proxmox` |

---

## Agents par Categorie (47)

### WORK- : Workflow Principal (1 agent)

| Agent | Quand l'utiliser | Modele | Outils |
|-------|------------------|--------|--------|
| `work-explore` | Decouvrir et comprendre un codebase | haiku | Read, Grep, Glob |

**Exemple d'utilisation :**
```
"Explore le systeme d'authentification"
→ Agent work-explore analyse le code en lecture seule
```

### DEV- : Developpement (11 agents)

| Agent | Quand l'utiliser | Modele |
|-------|------------------|--------|
| `dev-debug` | Diagnostiquer et resoudre un bug | sonnet |
| `dev-component` | Creer un composant UI complet | haiku |
| `dev-test` | Generer des tests unitaires/integration | haiku |
| `dev-flutter` | Creer widgets et screens Flutter | sonnet |
| `dev-supabase` | Configurer Auth, DB, Storage Supabase | sonnet |
| `dev-prompt-engineering` | Optimiser des prompts LLM | sonnet |
| `dev-rag` | Architecturer des systemes RAG | sonnet |
| `dev-design-system` | Creer design tokens et composants | haiku |
| `dev-prisma` | Schema, migrations, queries Prisma | haiku |
| `dev-trpc` | APIs type-safe avec tRPC | haiku |

**Choisir selon la complexite :**
- **haiku** (rapide, economique) : taches simples, generation de code standard
- **sonnet** (approfondi) : debug complexe, architecture, integration

### QA- : Qualite (7 agents)

| Agent | Quand l'utiliser | Modele |
|-------|------------------|--------|
| `qa-audit` | Audit complet (secu + RGPD + a11y + perf) | sonnet |
| `qa-security` | Audit securite OWASP Top 10 | sonnet |
| `qa-perf` | Audit performance, Core Web Vitals | sonnet |
| `qa-a11y` | Audit accessibilite WCAG 2.1 | haiku |
| `qa-coverage` | Analyser la couverture de tests | haiku |
| `qa-responsive` | Audit responsive/mobile-first | haiku |
| `qa-e2e` | Tests E2E Playwright/Cypress | sonnet |

**Avant mise en production :**
```bash
/qa-audit  # Audit complet recommande
```

### OPS- : Operations (12 agents)

| Agent | Quand l'utiliser | Modele |
|-------|------------------|--------|
| `ops-deps` | Audit dependances, vulnerabilites | haiku |
| `ops-health` | Health check rapide du projet | haiku |
| `ops-docker` | Dockeriser une application | haiku |
| `ops-ci` | Configurer GitHub Actions, GitLab CI | haiku |
| `ops-database` | Schemas et migrations DB | sonnet |
| `ops-monitoring` | Instrumentation logs/metriques/traces | haiku |
| `ops-serverless` | Deploiement Lambda, Vercel, CF Workers | haiku |
| `ops-vercel` | Configuration et deploiement Vercel | haiku |
| `ops-infra-code` | Infrastructure as Code (Terraform) | sonnet |
| `ops-proxmox` | Infrastructure Proxmox VE | sonnet |

**Health check rapide :**
```bash
/ops-health  # Diagnostic en 30 secondes
```

### DOC- : Documentation (5 agents)

| Agent | Quand l'utiliser | Modele |
|-------|------------------|--------|
| `doc-onboard` | Decouverte nouveau projet | haiku |
| `doc-generate` | Generation documentation technique | haiku |
| `doc-changelog` | Maintenance changelog | haiku |
| `doc-explain` | Explication de code complexe | haiku |

### BIZ- : Business (4 agents)

| Agent | Quand l'utiliser | Modele |
|-------|------------------|--------|
| `biz-model` | Business model, Lean Canvas | haiku |
| `biz-competitor` | Analyse concurrentielle | haiku |
| `biz-mvp` | Definition MVP | haiku |
| `biz-personas` | Creation personas utilisateur | haiku |

### GROWTH- : Croissance (4 agents)

| Agent | Quand l'utiliser | Modele |
|-------|------------------|--------|
| `growth-seo` | Audit SEO technique | haiku |
| `growth-analytics` | Setup tracking et KPIs | haiku |
| `growth-landing` | Optimisation landing pages | haiku |
| `growth-funnel` | Analyse funnels de conversion | haiku |

### DATA- : Donnees (3 agents)

| Agent | Quand l'utiliser | Modele |
|-------|------------------|--------|
| `data-pipeline` | Pipelines ETL/ELT, DAGs Airflow | sonnet |
| `data-analytics` | Analyse de donnees, rapports | haiku |
| `data-modeling` | Modelisation data warehouse | sonnet |

### LEGAL- : Legal (4 agents)

| Agent | Quand l'utiliser | Modele |
|-------|------------------|--------|
| `legal-rgpd` | Conformite RGPD/GDPR | haiku |
| `legal-payment` | Integration paiement (Stripe, etc.) | sonnet |
| `legal-privacy-policy` | Politique de confidentialite | haiku |
| `legal-terms-of-service` | CGU | haiku |

---

## Commandes par Intention

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

---

## Workflows Recommandes

### Nouvelle Feature

```
/work-explore → /work-specify → /work-plan → /dev-tdd → /qa-review → /work-pr
```

| Etape | Agent/Commande | Action |
|-------|----------------|--------|
| 1 | `/work-explore` | Comprendre l'existant |
| 2 | `/work-specify` | Specifier la feature |
| 3 | `/work-plan` | Planifier l'implementation |
| 4 | `/dev-tdd` | Developper avec tests |
| 5 | `/qa-review` | Code review |
| 6 | `/work-pr` | Creer la PR |

### Correction de Bug

```
/dev-debug → /dev-test → /work-commit
```

| Etape | Agent/Commande | Action |
|-------|----------------|--------|
| 1 | `/dev-debug` | Diagnostiquer la cause |
| 2 | `/dev-test` | Ajouter test de non-regression |
| 3 | `/work-commit` | Commit avec reference issue |

### Audit Avant Production

```
/qa-audit (ou /qa-security + /qa-perf + /qa-a11y)
```

| Priorite | Agent | Focus |
|----------|-------|-------|
| P0 | `/qa-security` | Vulnerabilites OWASP |
| P1 | `/qa-perf` | Core Web Vitals |
| P2 | `/qa-a11y` | Accessibilite WCAG |
| ALL | `/qa-audit` | Audit complet |

### Workflows Complets

| Situation | Workflow |
|-----------|----------|
| Nouvelle feature | `/work-flow-feature "description"` |
| Correction de bug | `/work-flow-bugfix "description"` |
| Nouvelle release | `/work-flow-release "v1.2.0"` |
| Lancement produit | `/work-flow-launch "nom du produit"` |

---

## Agents vs Skills vs Commands

| Concept | Contexte | Outils | Declenchement |
|---------|----------|--------|---------------|
| **Agent** | Isole | Restreints | Automatique |
| **Skill** | Partage | Definis | Automatique |
| **Command** | Partage | Tous | Manuel (`/cmd`) |

### Quand utiliser un Agent ?

- Tache d'**analyse** (exploration, audit)
- Besoin d'**isolation** (pas de modifications accidentelles)
- Tache **repetitive** et standardisee

### Quand utiliser une Command ?

- Workflow **interactif**
- Besoin de **modifications** directes
- Tache **unique** et specifique

---

## Tableau des Modeles

| Modele | Cas d'usage | Nombre |
|--------|-------------|--------|
| **haiku** | Taches simples, rapides | 28 agents |
| **sonnet** | Taches complexes, analyse approfondie | 19 agents |

### Agents Haiku (28)
Exploration, documentation, audits simples, generation standard

### Agents Sonnet (19)
Debug complexe, securite, performance, architecture, data modeling

---

## Commandes par Domaine

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

### Operations

| Besoin | Commande |
|--------|----------|
| Dockeriser | `/ops-docker` |
| Configurer CI/CD | `/ops-ci` |
| Gerer les dependances | `/ops-deps` |
| Creer une release | `/ops-release` |
| Hotfix urgent | `/ops-hotfix` |
| Health check | `/ops-health` |

### Business

| Besoin | Commande |
|--------|----------|
| Business model / Lean Canvas | `/biz-model` |
| Definir le MVP | `/biz-mvp` |
| Analyse concurrentielle | `/biz-competitor` |
| Creer des personas | `/biz-personas` |
| Strategie de pricing | `/biz-pricing` |
| Roadmap produit | `/biz-roadmap` |

---

## FAQ

### Comment savoir si un agent existe pour ma tache ?

1. Verifier cette page
2. Lister les agents : `ls .claude/agents/`
3. Demander a `/assistant`

### Puis-je combiner plusieurs agents ?

Oui ! Les workflows chaines sont recommandes :
```bash
/work-flow-feature "ma feature"  # Enchaine automatiquement
```

### Que faire si aucun agent ne correspond ?

1. Utiliser `/assistant` pour etre guide
2. Creer une commande personnalisee dans `.claude/commands/`
3. Demander directement a Claude avec le contexte

### Comment verifier les outils d'un agent ?

Lire le fichier de l'agent :
```bash
cat .claude/agents/qa-security.md
```

---

## Point d'entree intelligent

Si vous ne savez pas quelle commande utiliser, demandez a l'orchestrateur :

```bash
/assistant
```

Il analysera votre besoin et vous orientera vers la bonne commande.

---

## Ressources

- [CLAUDE.md](./CLAUDE.md) - Instructions completes
- [docs/CHEATSHEET.md](./docs/CHEATSHEET.md) - Reference rapide
- [docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md) - Architecture Commands/Agents/Skills
- [docs/WORKFLOWS.md](./docs/WORKFLOWS.md) - Diagrammes visuels
- [docs/QUICKSTART.md](./docs/QUICKSTART.md) - Demarrage rapide
