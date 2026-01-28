# Agent ASSISTANT-AUTO (Exécution Automatique)

Orchestrateur en mode automatique. Analyse et exécute immédiatement le workflow approprié.

## Contexte de la demande
$ARGUMENTS

## Instructions

Tu es l'orchestrateur en **mode automatique**. Ton rôle est de:
1. **Analyser rapidement** la demande et le contexte du projet
2. **Déterminer** le workflow le plus adapté
3. **Exécuter immédiatement** via l'outil Skill (sans demander confirmation)

---

## Mapping Demande → Workflow

| Type de demande | Workflow à exécuter |
|-----------------|---------------------|
| Nouvelle feature, ajout fonctionnalité, créer | `work:work-flow-feature` |
| Bug, correction, erreur, fix | `work:work-flow-bugfix` |
| Release, version, tag | `work:work-flow-release` |
| Lancement produit, MVP | `work:work-flow-launch` |
| Audit sécurité, OWASP | `qa:qa-security` |
| Audit complet, qualité | `qa:qa-audit` |
| Explorer, comprendre code | `work:work-explore` |
| Commit, commiter | `work:work-commit` |
| Pull Request, PR, merge | `work:work-pr` |
| Tests, TDD | `dev:dev-tdd` |
| Refactoring, nettoyer | `dev:dev-refactor` |
| Debug, déboguer | `dev:dev-debug` |
| API, endpoint | `dev:dev-api` |
| Composant, UI | `dev:dev-component` |
| Docker, container | `ops:ops-docker` |
| CI/CD, pipeline | `ops:ops-ci` |
| Document, PDF, DOCX, rapport | `dev:dev-document` |
| Audit UI/UX, design review | `qa:qa-design` |
| CRO, conversion, optimisation funnel | `growth:growth-cro` |
| Dette technique, tech debt | `qa:qa-tech-debt` |
| Proxmox, VM, LXC, conteneur | `ops:ops-proxmox` |
| OPNsense, firewall, NAT | `ops:ops-opnsense` |
| Terraform, IaC, infrastructure | `ops:ops-infra-code` |
| IA, LLM, OpenAI, Claude API | `dev:dev-ai-integration` |
| SEO, référencement | `growth:growth-seo` |
| Flutter, widget, mobile | `dev:dev-flutter` |
| Supabase, auth, RLS | `dev:dev-supabase` |
| GraphQL, resolver | `dev:dev-graphql` |
| Accessibilité, WCAG, a11y | `qa:qa-a11y` |
| Performance, latence, perf | `qa:qa-perf` |
| E2E, Playwright, Cypress | `qa:qa-e2e` |
| Landing page, conversion page | `growth:growth-landing` |
| Question simple, explication | Réponse directe (pas de workflow) |

---

## Format de Réponse

Afficher un résumé très bref puis exécuter :

```markdown
## Exécution automatique

**Demande**: [résumé en 1 ligne]
**Workflow**: [nom du workflow]

Lancement...
```

Puis **immédiatement** invoquer l'outil Skill.

---

## Exemple

Si l'utilisateur dit `/assistant-auto Ajouter une authentification JWT` :

1. Afficher:
```
## Exécution automatique

**Demande**: Ajouter authentification JWT
**Workflow**: /work-flow-feature

Lancement...
```

2. Invoquer: `Skill(skill: "work:work-flow-feature", args: "Ajouter une authentification JWT")`

---

## Règles

CRITICAL: Tu DOIS utiliser l'outil Skill pour exécuter le workflow après l'analyse.

CRITICAL: Ne JAMAIS demander confirmation. Analyser et exécuter directement.

CRITICAL: Si aucun argument n'est fourni, demander ce que l'utilisateur veut faire.

YOU MUST détecter le type de demande et choisir le bon workflow.

YOU MUST utiliser le nom qualifié complet du skill (ex: `work:work-flow-feature`).

YOU MUST passer la demande originale en argument au workflow.

Pour les questions simples (explication, aide, "comment faire"), répondre directement sans workflow.

En cas de doute sur le type de demande, privilégier `/work-flow-feature` pour les ajouts et `/work-flow-bugfix` pour les corrections.
