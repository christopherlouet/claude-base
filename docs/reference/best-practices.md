# Bonnes Pratiques Claude Code (Boris Cherny)

Recommandations du créateur de Claude Code pour maximiser la productivité et la qualité.

## Vérification : Le Multiplicateur de Qualité

> "Give Claude a way to verify its work. If Claude has that feedback loop, it will 2-3x the quality of the final result." — Boris Cherny, créateur de Claude Code

### Principe fondamental

La vérification est **la recommandation la plus importante** pour obtenir des résultats de qualité avec Claude Code. Donnez toujours à Claude un moyen de valider son travail.

### Types de vérification

| Complexité | Méthode | Exemple |
|------------|---------|---------|
| Simple | Commande bash | `npm run lint`, `npm run typecheck` |
| Modérée | Suite de tests | `npm test`, `pytest`, `go test` |
| Complexe | Browser/Simulateur | Playwright, Chrome DevTools, émulateur mobile |

### Boucle de feedback

```
┌─────────────────────────────────────────────────────────────────┐
│                    BOUCLE DE VÉRIFICATION                       │
├─────────────────────────────────────────────────────────────────┤
│  1. IMPLÉMENTER  →  2. VÉRIFIER  →  3. CORRIGER  →  4. VALIDER │
│  Code initial       Tests/Lint      Fix issues      Tous green  │
│                         ↑                ↓                      │
│                         └────────────────┘                      │
│                         (itérer jusqu'à succès)                 │
└─────────────────────────────────────────────────────────────────┘
```

### Intégration dans le workflow

- **Hooks PostToolUse** : Auto-format, type-check, lint après chaque modification
- **PreToolUse sur commit** : Tests obligatoires avant commit
- **Agents de QA** : `/qa:qa-audit`, `/qa:qa-security`, `/qa:qa-perf`

### Vérifications recommandées par type de projet

| Type de projet | Vérifications |
|---------------|---------------|
| Web Frontend | Tests Jest/Vitest + ESLint + TypeScript + Lighthouse |
| API Backend | Tests unitaires + Tests d'intégration + OpenAPI validation |
| Mobile Flutter | Tests widget + Analyse statique + Simulateur |
| Infrastructure | `terraform validate` + `terraform plan` + Tests Terratest |

## Modèle Recommandé

> "I use Opus 4.5 with thinking for everything. It's the best coding model I've ever used, and even though it's bigger & slower than Sonnet, since you have to steer it less and it's better at tool use, it is almost always faster than using a smaller model in the end." — Boris Cherny

### Recommandations

| Contexte | Modèle | Justification |
|----------|--------|---------------|
| Tâches complexes | **Opus 4.5** | Meilleur raisonnement, moins de corrections |
| Audits et analyses | **Sonnet** | Bon équilibre vitesse/qualité |
| Tâches simples | **Haiku** | Rapide pour les opérations triviales |

### Configuration

```bash
# Utiliser Opus pour les tâches de développement
claude --model opus

# Les sub-agents utilisent le modèle optimal par défaut
# (configuré dans .claude/agents/)
```

## Prompting Avancé

Techniques de prompting recommandées par Boris Cherny pour maximiser la qualité.

### Challenge Claude

```
"Grill me on these changes and don't make a PR until I pass your test."
```
→ Claude pose des questions critiques et valide la compréhension avant de procéder.

### Demander des preuves

```
"Prove to me this works. Show me the diff and explain why it solves the problem."
```
→ Force Claude à justifier ses choix avec des preuves concrètes.

### Itérer vers l'élégance

```
"Knowing everything you know now, scrap this and implement the elegant solution."
```
→ Après une première implémentation, demander une version plus propre.

### Spécifications détaillées

Plus la spécification est détaillée, meilleur est le résultat :
- Définir les cas limites
- Préciser le comportement attendu
- Donner des exemples d'entrées/sorties

### Anti-patterns de prompting

| À éviter | Préférer |
|----------|----------|
| "Fix this bug" | "Fix the null pointer in getUserById when user doesn't exist" |
| "Make it better" | "Reduce the time complexity from O(n²) to O(n log n)" |
| "Add error handling" | "Add try/catch for network errors with retry logic (3 attempts, exponential backoff)" |

Voir [docs/guides/PROMPTING-GUIDE.md](../guides/PROMPTING-GUIDE.md) pour le guide complet.

## Sessions Parallèles

> "The single biggest productivity unlock." — Boris Cherny

### Workflow multi-sessions

Boris utilise 5+ sessions Claude Code en parallèle avec git worktrees :

```bash
# Créer des worktrees pour chaque tâche
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
| Travail parallèle | Plusieurs features simultanément |
| Worktree analyse | Requêtes sans risque de modification |
| Isolation | Un bug dans une session n'affecte pas les autres |

### Aliases recommandés

```bash
# Dans ~/.bashrc ou ~/.zshrc
alias wa="cd ~/projects/myapp"           # Principal
alias wb="cd ~/projects/myapp-feature"   # Feature
alias wc="cd ~/projects/myapp-fix"       # Fix
alias wd="cd ~/projects/myapp-analysis"  # Analyse
```

Voir le skill `git-worktrees` pour plus de détails.

## Commande Rapide : Commit-Push-PR

Boris utilise une commande unique pour le cycle complet de livraison :

```bash
/work:work-commit-push-pr "description"
```

Cette commande enchaîne automatiquement :
1. Vérification des tests et du lint
2. Création du commit (Conventional Commits)
3. Push sur la branche distante
4. Création de la Pull Request

> "This is the command I run dozens of times every day." — Boris Cherny
