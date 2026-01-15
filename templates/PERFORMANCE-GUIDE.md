# Guide de Performance Claude Code

Optimisez l'utilisation de Claude Code pour des réponses plus rapides et une consommation de tokens réduite.

## Principes fondamentaux

```
┌─────────────────────────────────────────────────────────────┐
│              OPTIMISATION PERFORMANCE                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. CONTEXTE MINIMAL    → Moins de tokens = plus rapide    │
│  ═══════════════════                                        │
│                                                             │
│  2. AGENTS CIBLÉS       → Prompts optimisés = meilleurs    │
│  ════════════════           résultats                       │
│                                                             │
│  3. REQUÊTES PRÉCISES   → Moins d'allers-retours           │
│  ═════════════════                                          │
│                                                             │
│  4. FICHIERS SPÉCIFIQUES→ Éviter les lectures globales     │
│  ════════════════════                                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Optimisation du contexte

### Ce qui consomme des tokens

| Élément | Impact | Optimisation |
|---------|--------|--------------|
| Fichiers lus | Très élevé | Limiter aux fichiers nécessaires |
| Historique conversation | Élevé | Nouvelles sessions pour nouvelles tâches |
| Instructions agent | Moyen | Agents bien structurés |
| Arguments | Faible | Être concis mais précis |

### Bonnes pratiques

#### Spécifier les fichiers

```bash
# ❌ Éviter - lit potentiellement tout
/explore

# ✅ Préférer - cible les fichiers pertinents
/explore src/services/auth.ts
```

#### Utiliser des chemins précis

```bash
# ❌ Trop large
/review src/

# ✅ Plus ciblé
/review src/services/user-service.ts
```

#### Décomposer les tâches complexes

```bash
# ❌ Une seule requête massive
"Analyse tout le projet, trouve les bugs, refactorise et optimise"

# ✅ Plusieurs requêtes ciblées
/explore src/services/
/review src/services/user-service.ts
/refactor UserService
```

## Choix de l'agent optimal

### Matrice de sélection

| Tâche | Agent optimal | Pourquoi |
|-------|---------------|----------|
| Comprendre du code | `/explore` | Optimisé pour l'analyse |
| Bug à corriger | `/debug` | Workflow de débogage |
| Nouveau code | `/tdd` | Structure TDD |
| Review de PR | `/review` | Checklist qualité |
| Commit | `/commit` | Format conventionnel |

### Éviter les agents génériques

```bash
# ❌ Agent non spécialisé
"Peux-tu regarder ce code et me dire s'il y a des problèmes de sécurité ?"

# ✅ Agent spécialisé
/security src/api/
```

## Réduire les allers-retours

### Fournir le contexte en une fois

```bash
# ❌ Conversation fragmentée
User: "Regarde AuthService"
Claude: [analyse]
User: "Et aussi UserService"
Claude: [analyse]
User: "Compare les deux"

# ✅ Contexte complet
/review "Compare AuthService et UserService, identifie les duplications"
```

### Utiliser des arguments structurés

```bash
# ✅ Arguments clairs et complets
/api POST /api/users {name: string, email: string} -> {id: string, created: Date}
```

## Optimisation des agents

### Structure d'agent performante

```markdown
# Agent PERFORMANT

Description concise.

## Contexte
$ARGUMENTS

## Instructions

1. [Étape 1]
2. [Étape 2]
3. [Étape 3]

## Output

[Format précis et concis]
```

### Éviter dans les agents

| Anti-pattern | Impact | Alternative |
|--------------|--------|-------------|
| Longs exemples | Tokens gaspillés | Exemples courts et pertinents |
| Instructions répétitives | Confusion | Instructions uniques et claires |
| Options multiples | Décisions lentes | Recommandation par défaut |

## Métriques et monitoring

### Indicateurs de performance

| Métrique | Optimal | Action si dépassé |
|----------|---------|-------------------|
| Temps de réponse | < 30s | Réduire le contexte |
| Tokens par requête | < 10k | Cibler les fichiers |
| Allers-retours | < 3 | Compléter le contexte initial |

### Estimation de consommation

```
Tokens ≈ (Fichiers lus × ~100-500 lignes × 4 tokens/ligne)
        + (Instructions agent × 4 tokens/mot)
        + (Arguments × 4 tokens/mot)
```

## Patterns performants

### Pattern "Scout then Act"

```bash
# 1. Scout (rapide, peu de tokens)
/explore src/auth/ --quick

# 2. Identifier les fichiers clés
# -> src/auth/service.ts, src/auth/middleware.ts

# 3. Act (ciblé)
/review src/auth/service.ts src/auth/middleware.ts
```

### Pattern "Divide and Conquer"

```bash
# Diviser une grosse tâche
/plan "Refactoring module auth"
# -> Liste des sous-tâches

# Exécuter chaque sous-tâche séparément
/refactor src/auth/login.ts
/refactor src/auth/session.ts
/refactor src/auth/token.ts
```

### Pattern "Progressive Detail"

```bash
# 1. Vue d'ensemble
/onboard --quick

# 2. Zoom sur un module
/explore src/services/

# 3. Détail d'un fichier
/explain src/services/complex-algorithm.ts
```

## Configuration recommandée

### CLAUDE.md optimisé

```markdown
## Conventions essentielles

- TypeScript strict
- Tests > 80%
- Conventional commits

## Structure
/src - Code source
/tests - Tests
/docs - Documentation

<!-- Éviter les instructions trop longues -->
```

### Exclusions recommandées

Dans `.gitignore` ou instructions :
```
node_modules/
dist/
build/
coverage/
*.log
.env*
```

## Comparatif avant/après

### Exemple : Review de code

**Avant (non optimisé)**
```
Temps: ~2 min
Tokens: ~50k
"Peux-tu faire une review complète de tout le code du projet ?"
```

**Après (optimisé)**
```
Temps: ~20s
Tokens: ~8k
/review src/services/auth-service.ts
```

### Exemple : Debug

**Avant (non optimisé)**
```
Temps: ~3 min
Tokens: ~80k
"Il y a un bug quelque part dans l'application, peux-tu le trouver ?"
```

**Après (optimisé)**
```
Temps: ~30s
Tokens: ~10k
/debug "Error: Token invalid" src/auth/
```

## Checklist d'optimisation

### Avant chaque requête
- [ ] Ai-je identifié les fichiers pertinents ?
- [ ] L'agent choisi est-il le plus adapté ?
- [ ] Le contexte fourni est-il suffisant et pas excessif ?

### Design d'agent
- [ ] Les instructions sont-elles concises ?
- [ ] Y a-t-il des répétitions à éliminer ?
- [ ] Les exemples sont-ils minimaux mais clairs ?

### Workflow
- [ ] Les tâches complexes sont-elles découpées ?
- [ ] Chaque sous-tâche est-elle autonome ?
- [ ] Le pattern scout-then-act est-il applicable ?

---

## Ressources

- [FAQ](./FAQ.md) - Questions fréquentes
- [Troubleshooting](./TROUBLESHOOTING.md) - Résolution de problèmes
- [Architecture](./ARCHITECTURE.md) - Structure du projet
