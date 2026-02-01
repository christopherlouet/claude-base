# Skills (Claude Code 2.1+)

En plus des commandes, le projet inclut **41 Skills** dans `.claude/skills/`:

## Skills de base
| Skill | Déclenchement automatique | Context |
|-------|---------------------------|---------|
| `dev-tdd` | "TDD", "test first", "écrire les tests" | fork |
| `work-commit` | "commit", "message de commit" | fork |
| `dev-debug` | "bug", "erreur", "debug" | fork |
| `qa-review` | "review", "code review" | fork |
| `qa-security` | "audit sécurité", "OWASP" | fork |
| `work-plan` | "planifier", "architecture" | fork |
| `work-explore` | "explorer", "comprendre le code" | fork |
| `work-pr` | "PR", "pull request" | fork |
| `dev-api` | "API", "endpoint", "REST" | fork |

## Skills additionnels
| Skill | Déclenchement automatique | Context |
|-------|---------------------------|---------|
| `dev-flutter` | "Flutter", "widget", "BLoC" | fork |
| `dev-supabase` | "Supabase", "auth", "RLS" | fork |
| `dev-react-perf` | "React perf", "re-render", "memo" | fork |
| `ops-docker` | "Docker", "container", "Dockerfile" | fork |
| `ops-ci` | "CI/CD", "GitHub Actions", "pipeline" | fork |
| `ops-database` | "schema", "migration", "index" | fork |
| `ops-monitoring` | "logs", "métriques", "traces" | fork |
| `doc-generate` | "documenter", "README", "JSDoc" | fork |
| `doc-changelog` | "changelog", "release notes" | fork |
| `dev-refactor` | "refactorer", "clean code", "restructurer" | fork |
| `dev-error-handling` | "gestion erreurs", "exceptions", "error boundary" | fork |
| `dev-graphql` | "GraphQL", "resolver", "schema" | fork |
| `ops-mobile-release` | "App Store", "Play Store", "Fastlane" | fork |
| `data-pipeline` | "ETL", "Airflow", "dbt" | fork |
| `qa-perf` | "optimiser", "latence", "TTFB" | fork |
| `dev-prompt-engineering` | "prompt", "instruction", "few-shot", "LLM" | fork |
| `qa-e2e` | "E2E", "Playwright", "Cypress", "parcours utilisateur" | fork |
| `feature-flags` | "feature flag", "A/B test", "deploiement progressif" | fork |
| `ops-infra-code` | "Terraform", "IaC", "OpenTofu", "module", "state" | fork |
| `ops-proxmox` | "Proxmox", "PVE", "VM Proxmox", "LXC", "PBS" | fork |
| `ops-opnsense` | "OPNsense", "firewall", "NAT", "DHCP", "Unbound" | fork |
| `qa-tech-debt` | "dette technique", "tech debt", "refactoring priorité" | fork |
| `qa-design` | "audit design", "UI/UX", "interface utilisateur" | fork |
| `api-mocking` | "mock API", "MSW", "test sans backend" | fork |
| `state-management` | "state", "Redux", "Zustand", "store" | fork |
| `dev-document` | "PDF", "DOCX", "XLSX", "PPTX", "document", "rapport" | fork |
| `growth-cro` | "conversion", "CRO", "signup flow", "onboarding", "paywall" | fork |
| `parallel-agents` | "parallele", "concurrent", "fan-out", "multi-agents" | fork |
| `session-handoff` | "handoff", "reprise", "transfert session", "contexte" | fork |
| `git-worktrees` | "worktree", "dev parallele", "branches simultanées" | fork |
| `qa-chrome` | "Chrome", "test visuel", "debugging DOM", "capture" | fork |
| `writing-skills` | "créer skill", "nouveau skill", "écrire un skill" | fork |

## Configuration des Skills

Chaque skill définit:
- **allowed-tools**: Outils autorisés pour le skill
- **context: fork**: Exécution dans un contexte isolé (recommandé)

Les Skills sont déclenchés automatiquement par Claude selon le contexte.

## Bonnes Pratiques Skills

### Taille et Budget
- SKILL.md < 500 lignes (déporter le contenu volumineux dans des fichiers de référence)
- Budget descriptions : 15k caractères max (`SLASH_COMMAND_TOOL_CHAR_BUDGET`)
- Utiliser des fichiers de support : `examples/`, `scripts/`, `reference.md`

### Frontmatter complet
```yaml
---
name: mon-skill
description: Description courte du skill
allowed-tools: Read, Grep, Glob, Bash
context: fork
disable-model-invocation: true   # Ne pas déclencher automatiquement
user-invocable: false             # Skill background-only
argument-hint: "[description]"    # Hint pour les arguments
model: sonnet                     # Modèle préféré (haiku, sonnet, opus)
agent: mon-agent                  # Agent associé
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "echo validation"
---
```

### Substitutions de variables
| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | Tous les arguments passés au skill |
| `$ARGUMENTS[N]` | Argument à l'index N (0-based) |
| `$N` | Raccourci pour `$ARGUMENTS[N]` |
| `${CLAUDE_SESSION_ID}` | ID de la session en cours |

### Dynamic Context Injection
Injecter du contenu dynamique dans un skill avec la syntaxe :
```
!`command`
```
Exemple : `` !`cat package.json | jq .scripts` `` injecte les scripts npm dans le contexte du skill.
