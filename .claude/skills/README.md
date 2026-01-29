# Claude Code Skills

Ce dossier contient des **Skills** - des connaissances domaine reutilisables qui enseignent a Claude les patterns et conventions du projet.

## Difference entre Commands et Skills

| Aspect | Commands (`.claude/commands/`) | Skills (`.claude/skills/`) |
|--------|-------------------------------|---------------------------|
| **Invocation** | Explicite: `/nom` | Automatique ou `/nom` |
| **Format** | Un fichier `.md` | Dossier avec `SKILL.md` + ressources |
| **Declenchement** | Manuel uniquement | Base sur la description (semantique) |
| **Ressources** | Non | Oui (examples/, scripts/, references/) |

## Structure d'un Skill

```
skill-name/
├── SKILL.md           # Instructions principales (requis)
├── examples/          # Exemples concrets (optionnel)
│   └── example-1.md
├── references/        # Documentation additionnelle (optionnel)
└── scripts/           # Scripts helper (optionnel)
```

## Skills disponibles (40)

| Skill | Mots-cles declencheurs | Description |
|-------|----------------------|-------------|
| `api-mocking` | mock API, MSW, test sans backend | Configuration de mocks API pour les tests |
| `data-pipeline` | ETL, Airflow, dbt | Conception de pipelines ETL/ELT |
| `dev-api` | API, endpoint, REST, route | Developper et documenter une API REST ou GraphQL |
| `dev-debug` | bug, erreur, debug, ne fonctionne pas | Deboguer et resoudre des problemes |
| `dev-document` | PDF, DOCX, XLSX, PPTX, rapport | Generation de documents bureautiques |
| `dev-error-handling` | gestion erreurs, exceptions, error boundary | Strategie de gestion des erreurs |
| `dev-flutter` | Flutter, widget, BLoC | Developpement Flutter avec Clean Architecture |
| `dev-graphql` | GraphQL, resolver, schema | Developpement d'APIs GraphQL |
| `dev-prompt-engineering` | prompt, instruction, few-shot, LLM | Optimisation de prompts pour LLMs |
| `dev-react-perf` | React perf, re-render, memo | Optimisation performances React/Next.js |
| `dev-refactor` | refactorer, clean code, restructurer | Refactoring de code |
| `dev-supabase` | Supabase, auth, RLS, storage | Developpement backend Supabase |
| `dev-tdd` | TDD, test first, ecrire les tests | Cycle TDD Red-Green-Refactor |
| `doc-changelog` | changelog, release notes | Maintenance du CHANGELOG |
| `doc-generate` | documenter, README, JSDoc | Generation de documentation technique |
| `feature-flags` | feature flag, A/B test, deploiement progressif | Gestion de feature flags et toggles |
| `git-worktrees` | worktree, dev parallele, branches simultanees | Git worktrees pour dev parallele |
| `growth-cro` | conversion, CRO, signup flow, onboarding | Optimisation du taux de conversion |
| `ops-ci` | CI/CD, GitHub Actions, pipeline | Configuration de pipelines CI/CD |
| `ops-database` | schema, migration, index | Conception de schemas de base de donnees |
| `ops-docker` | Docker, container, Dockerfile | Containerisation Docker et Docker Compose |
| `ops-infra-code` | Terraform, IaC, OpenTofu | Infrastructure as Code |
| `ops-mobile-release` | App Store, Play Store, Fastlane | Publication d'apps mobiles |
| `ops-monitoring` | logs, metriques, traces | Instrumentation d'applications |
| `ops-opnsense` | OPNsense, firewall, NAT, DHCP | Configuration OPNsense via Terraform |
| `ops-proxmox` | Proxmox, PVE, VM, LXC, PBS | Infrastructure Proxmox VE avec Terraform |
| `parallel-agents` | parallele, concurrent, fan-out, multi-agents | Orchestration d'agents paralleles |
| `qa-design` | audit design, UI/UX, interface | Audit de design UI/UX |
| `qa-e2e` | E2E, Playwright, Cypress | Tests End-to-End |
| `qa-perf` | optimiser, latence, TTFB | Optimisation des performances |
| `qa-review` | review, relire, verifier le code | Revue de code approfondie |
| `qa-security` | securite, audit, vulnerabilite, OWASP | Audit de securite OWASP |
| `qa-tech-debt` | dette technique, tech debt, refactoring priorite | Gestion de la dette technique |
| `session-handoff` | handoff, reprise, transfert session | Transfert de contexte entre sessions |
| `state-management` | state, Redux, Zustand, store | Patterns de state management |
| `work-commit` | commit, message de commit | Messages Conventional Commits |
| `work-explore` | explorer, comprendre le code, decouvrir | Explorer et comprendre un codebase |
| `work-plan` | planifier, architecture, plan | Planifier une implementation |
| `work-pr` | PR, pull request, merger | Creer une Pull Request complete |
| `writing-skills` | creer skill, nouveau skill, ecrire un skill | Guide pour creer de nouveaux skills |

## Convention de nommage

Les skills suivent la convention `domaine-action` :

| Domaine | Exemples |
|---------|----------|
| `work-` | `work-explore`, `work-plan`, `work-commit`, `work-pr` |
| `dev-` | `dev-tdd`, `dev-debug`, `dev-api`, `dev-flutter` |
| `qa-` | `qa-review`, `qa-security`, `qa-perf`, `qa-e2e` |
| `ops-` | `ops-docker`, `ops-ci`, `ops-database`, `ops-monitoring` |
| `doc-` | `doc-generate`, `doc-changelog` |
| `growth-` | `growth-cro` |
| `data-` | `data-pipeline` |

## Creer un nouveau Skill

1. Creer le dossier: `mkdir .claude/skills/domaine-action`
2. Creer `SKILL.md` avec frontmatter YAML
3. Ajouter des exemples dans `examples/` (recommande)
4. La description doit inclure les declencheurs (quand utiliser)

## Bonnes pratiques

- **Nommage coherent**: Utiliser le format `domaine-action` (ex: `dev-tdd`, `qa-security`)
- **Description riche**: Inclure tous les mots-cles declencheurs
- **SKILL.md < 500 lignes**: Details dans `references/`
- **Exemples concrets**: Montrer le bon ET le mauvais pattern
