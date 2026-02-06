---
sidebar_position: 6
title: Bonnes Pratiques
description: Recommandations de Boris Cherny (createur de Claude Code) pour maximiser la productivite
---

# Bonnes Pratiques Claude Code

> Recommandations de Boris Cherny, createur de Claude Code, pour maximiser la productivite et la qualite.

## Verification : Le Multiplicateur de Qualite

> "Give Claude a way to verify its work. If Claude has that feedback loop, it will 2-3x the quality of the final result." — Boris Cherny

### Principe fondamental

La verification est **la recommandation la plus importante** pour obtenir des resultats de qualite avec Claude Code. Donnez toujours a Claude un moyen de valider son travail.

### Types de verification

| Complexite | Methode | Exemple |
|------------|---------|---------|
| Simple | Commande bash | `npm run lint`, `npm run typecheck` |
| Moderee | Suite de tests | `npm test`, `pytest`, `go test` |
| Complexe | Browser/Simulateur | Playwright, Chrome DevTools, emulateur mobile |

### Boucle de feedback

```
┌─────────────────────────────────────────────────────────────────┐
│                    BOUCLE DE VERIFICATION                       │
├─────────────────────────────────────────────────────────────────┤
│  1. IMPLEMENTER  →  2. VERIFIER  →  3. CORRIGER  →  4. VALIDER │
│  Code initial       Tests/Lint      Fix issues      Tous green  │
│                         ↑                ↓                      │
│                         └────────────────┘                      │
│                         (iterer jusqu'a succes)                 │
└─────────────────────────────────────────────────────────────────┘
```

### Integration dans le workflow

- **Hooks PostToolUse** : Auto-format, type-check, lint apres chaque modification
- **PreToolUse sur commit** : Tests obligatoires avant commit
- **Agents de QA** : `/qa:qa-audit`, `/qa:qa-security`, `/qa:qa-perf`

### Verifications recommandees par type de projet

| Type de projet | Verifications |
|---------------|---------------|
| Web Frontend | Tests Jest/Vitest + ESLint + TypeScript + Lighthouse |
| API Backend | Tests unitaires + Tests d'integration + OpenAPI validation |
| Mobile Flutter | Tests widget + Analyse statique + Simulateur |
| Infrastructure | `terraform validate` + `terraform plan` + Tests Terratest |

## Modele Recommande

> "I use Opus 4.6 with adaptive thinking for everything. It's the best coding model I've ever used, and even though it's bigger & slower than Sonnet, since you have to steer it less and it's better at tool use, it is almost always faster than using a smaller model in the end." — Boris Cherny

### Recommandations par contexte

| Contexte | Modele | Justification |
|----------|--------|---------------|
| Taches complexes | **Opus 4.6** | Meilleur raisonnement, adaptive thinking, 1M contexte |
| Audits et analyses | **Sonnet** | Bon equilibre vitesse/qualite |
| Taches simples | **Haiku** | Rapide pour les operations triviales |

### Adaptive Thinking (Opus 4.6)

Opus 4.6 remplace le toggle "extended thinking" par 4 niveaux d'effort adaptatifs :

| Niveau | Usage | Latence | Qualite |
|--------|-------|---------|---------|
| `low` | Taches simples, reformulations | Rapide | Standard |
| `medium` | Code standard, analyses moderees | Moyenne | Bon |
| `high` | Problemes complexes, audits approfondis | Elevee | Excellent |
| `max` | Taches critiques, architecture, debugging avance | Maximale | Optimal |

Le modele ajuste automatiquement son effort de raisonnement selon la complexite de la tache.

### Configuration

```bash
# Utiliser Opus pour les taches de developpement
claude --model opus

# Les sub-agents utilisent le modele optimal par defaut
# (configure dans .claude/agents/)
```

## Prompting Avance

Techniques de prompting recommandees par Boris Cherny pour maximiser la qualite.

### Challenge Claude

```
"Grill me on these changes and don't make a PR until I pass your test."
```

Claude pose des questions critiques et valide la comprehension avant de proceder.

### Demander des preuves

```
"Prove to me this works. Show me the diff and explain why it solves the problem."
```

Force Claude a justifier ses choix avec des preuves concretes.

### Iterer vers l'elegance

```
"Knowing everything you know now, scrap this and implement the elegant solution."
```

Apres une premiere implementation, demander une version plus propre.

### Specifications detaillees

Plus la specification est detaillee, meilleur est le resultat :
- Definir les cas limites
- Preciser le comportement attendu
- Donner des exemples d'entrees/sorties

### Anti-patterns de prompting

| A eviter | Preferer |
|----------|----------|
| "Fix this bug" | "Fix the null pointer in getUserById when user doesn't exist" |
| "Make it better" | "Reduce the time complexity from O(n^2) to O(n log n)" |
| "Add error handling" | "Add try/catch for network errors with retry logic (3 attempts, exponential backoff)" |

Voir `docs/guides/PROMPTING-GUIDE.md` dans le socle pour le guide complet.

## Sessions Paralleles

> "The single biggest productivity unlock." — Boris Cherny

### Workflow multi-sessions

Boris utilise 5+ sessions Claude Code en parallele avec git worktrees :

```bash
# Creer des worktrees pour chaque tache
git worktree add ../myapp-feature-auth -b feature/auth
git worktree add ../myapp-fix-login -b fix/login
git worktree add ../myapp-analysis main  # Pour les analyses

# Chaque worktree a sa propre session Claude
cd ../myapp-feature-auth && claude
cd ../myapp-fix-login && claude
```

### Avantages

| Avantage | Description |
|----------|-------------|
| Pas de context switching | Chaque session garde son contexte |
| Travail parallele | Plusieurs features simultanement |
| Worktree analyse | Requetes sans risque de modification |
| Isolation | Un bug dans une session n'affecte pas les autres |
| Context Compaction | Opus 4.6 resume automatiquement le contexte ancien |

### Aliases recommandes

```bash
# Dans ~/.bashrc ou ~/.zshrc
alias wa="cd ~/projects/myapp"           # Principal
alias wb="cd ~/projects/myapp-feature"   # Feature
alias wc="cd ~/projects/myapp-fix"       # Fix
alias wd="cd ~/projects/myapp-analysis"  # Analyse
```

Voir le [skill git-worktrees](/docs/skills/git-worktrees) pour plus de details.

## Commande Rapide : Commit-Push-PR

> "This is the command I run dozens of times every day." — Boris Cherny

Boris utilise une commande unique pour le cycle complet de livraison :

```bash
/work:work-commit-push-pr "description"
```

Cette commande enchaine automatiquement :
1. Verification des tests et du lint
2. Creation du commit (Conventional Commits)
3. Push sur la branche distante
4. Creation de la Pull Request

Voir la [commande work-commit-push-pr](/docs/commands/work/work-commit-push-pr) pour plus de details.

## Style Explanatory

Boris recommande le style `explanatory` pour comprendre le raisonnement de Claude :

```bash
/output-style explanatory
```

Ce style force Claude a expliquer son raisonnement etape par etape, rendant ses decisions transparentes et facilitant la collaboration.

Voir les [Output Styles](/docs/concepts/output-styles) pour tous les styles disponibles.

---

## Voir aussi

- [Workflows](/docs/workflow) - Les workflows du socle
- [Skill dev-prompt-engineering](/docs/skills/dev-prompt-engineering) - Techniques avancees
- [Fonctionnalites Avancees](/docs/concepts/advanced-features) - Opus 4.6, Agent Teams, Plugins
- [Retour aux guides](/docs/guides)
