---
sidebar_position: 17
title: "Guide de Prompting Avance"
description: " Techniques de prompting recommandees par Boris Cherny (createur de Claude Code) pour maximiser la qualite des resultats."
tags:
  - "guide"
---

<!-- Auto-generated from docs/ - DO NOT EDIT -->

# Guide de Prompting Avance

&gt; Techniques de prompting recommandees par Boris Cherny (createur de Claude Code) pour maximiser la qualite des resultats.

## Principe Fondamental

&gt; "The more specific and detailed the specification, the better the output."

Plus vous etes precis dans votre demande, meilleur sera le resultat. Claude Code excelle quand il a un contexte clair et des attentes bien definies.

## Techniques de Prompting

### 1. Challenge Claude ("Grill Me")

Demandez a Claude de vous challenger avant de proceder :

```
"Grill me on these changes and don't make a PR until I pass your test."
```

**Resultat** : Claude pose des questions critiques sur votre comprehension, identifie les edge cases, et s'assure que vous avez pense a tout avant d'implementer.

**Quand l'utiliser** :
- Avant de merger une PR importante
- Pour valider votre comprehension d'un systeme complexe
- Pour identifier les risques que vous n'avez pas anticipes

### 2. Demander des Preuves ("Prove It")

Forcez Claude a justifier ses choix avec des preuves concretes :

```
"Prove to me this works. Show me the diff and explain why it solves the problem."
```

**Resultat** : Claude fournit des justifications detaillees, montre les changements exacts, et explique le raisonnement.

**Quand l'utiliser** :
- Pour des changements critiques (securite, performance)
- Quand vous voulez comprendre le "pourquoi" en profondeur
- Pour documenter la decision pour les futurs developpeurs

### 3. Iterer vers l'Elegance ("Scrap and Redo")

Apres une premiere implementation, demandez une version plus elegante :

```
"Knowing everything you know now, scrap this and implement the elegant solution."
```

**Resultat** : Claude utilise les apprentissages de la premiere iteration pour produire une solution plus propre et mieux structuree.

**Quand l'utiliser** :
- Quand la premiere solution fonctionne mais semble "hacky"
- Pour du code qui sera maintenu longtemps
- Avant de finaliser une API publique

### 4. Specifications Detaillees

Plus la specification est detaillee, meilleur est le resultat :

#### Mauvais prompt
```
"Add error handling"
```

#### Bon prompt
```
"Add error handling for the getUserById function:
- If user doesn't exist, throw UserNotFoundError with user ID
- If database connection fails, retry 3 times with exponential backoff (1s, 2s, 4s)
- If all retries fail, throw DatabaseConnectionError with last error message
- Log each retry attempt with warn level
- Log final failure with error level including stack trace"
```

### 5. Exemples Concrets (Few-Shot)

Donnez des exemples du resultat attendu :

```
"Generate error messages following this pattern:

Input: { field: 'email', value: 'invalid' }
Output: 'Email address is not valid. Please enter a valid email like user@example.com'

Input: { field: 'password', value: '123' }
Output: 'Password is too short. Please use at least 8 characters including a number and symbol'

Now generate messages for: { field: 'phone', value: 'abc' }"
```

### 6. Contraintes Explicites

Specifiez ce que vous ne voulez PAS :

```
"Implement user authentication:
- DO use bcrypt for password hashing
- DO NOT use MD5 or SHA1
- DO NOT store passwords in plain text
- DO NOT log passwords even in debug mode
- DO use constant-time comparison for password verification"
```

### 7. Context Loading (Lecture Prealable)

Demandez a Claude de lire avant d'agir :

```
"Before making any changes:
1. Read src/services/auth.ts to understand the current auth flow
2. Read src/middleware/authenticate.ts to see how tokens are validated
3. Read src/types/user.ts for the User interface
Then implement the password reset feature following existing patterns."
```

### 8. Verification Explicite

Demandez une verification apres l'implementation :

```
"After implementing the feature:
1. Run npm test and show me the results
2. Run npm run lint and fix any issues
3. Explain what could go wrong in production
4. List the edge cases you've handled"
```

## Anti-Patterns de Prompting

| A Eviter | Preferer |
|----------|----------|
| "Fix this bug" | "Fix the null pointer exception in getUserById when the user ID doesn't exist in the database" |
| "Make it better" | "Reduce the time complexity from O(n²) to O(n log n) by using a hash map instead of nested loops" |
| "Add tests" | "Add unit tests for the calculateDiscount function covering: empty cart, single item, multiple items, discount codes, and negative quantities" |
| "Refactor this" | "Extract the validation logic into a separate UserValidator class with methods for email, password, and phone validation" |
| "It doesn't work" | "The function returns undefined instead of the expected User object when I call getUserById(123). Here's the error log: [log]" |

## Prompts par Contexte

### Pour le Debug

```
"I'm seeing this error: [paste error]
Context:
- This started happening after [change]
- It happens when [condition]
- I've already tried [attempts]

Help me debug this step by step."
```

### Pour le Code Review

```
"Review this PR as if you were a senior engineer. Focus on:
1. Security vulnerabilities (especially auth and input validation)
2. Performance issues (N+1 queries, unnecessary renders)
3. Code maintainability (naming, structure, DRY)
4. Edge cases not handled
5. Missing tests

Be critical - I want honest feedback, not validation."
```

### Pour l'Architecture

```
"I need to design a system for [requirement].

Constraints:
- [constraint 1]
- [constraint 2]

Quality attributes (in order of priority):
1. [e.g., Security]
2. [e.g., Scalability]
3. [e.g., Maintainability]

Show me 2-3 options with trade-offs before recommending one."
```

### Pour l'Apprentissage

```
"Explain [concept] as if I'm a developer who knows [related tech] but has never used [new tech].

Include:
- Why it exists (the problem it solves)
- How it compares to [similar thing I know]
- A minimal working example
- Common pitfalls beginners hit
- When NOT to use it"
```

## Combinaison avec les Skills du Socle

| Skill | Prompt recommande |
|-------|-------------------|
| `/dev:dev-tdd` | "Write failing tests first for [feature], then implement the minimal code to pass" |
| `/qa:qa-security` | "Audit this code as if you're a penetration tester. Find vulnerabilities." |
| `/work:work-plan` | "Create a detailed implementation plan. I want to review it before you code." |
| `/dev:dev-debug` | "Debug this systematically. Show me your hypothesis at each step." |

## Voice Dictation pour de Meilleurs Prompts

Boris recommande d'utiliser la dictee vocale (fn x2 sur macOS) pour des prompts plus detailles :

&gt; "When I dictate prompts, I tend to be much more detailed than when I type. The extra context always improves results."

### Avantages
- Plus naturel = plus de details
- Plus rapide que la frappe
- Moins d'auto-censure sur la longueur

## Ressources

- [How Boris Uses Claude Code](https://howborisusesclaudecode.com/)
- [10 Claude Code Tips from Boris](https://ykdojo.github.io/claude-code-tips/content/boris-claude-code-tips)
- [Claude Code Best Practices (Anthropic)](https://docs.anthropic.com/en/docs/claude-code)

---

## Techniques Avancees

### Prompting Iteratif

Le prompting efficace suit rarement un chemin direct. Le pattern recommande est : large d'abord, puis resserrement progressif.

**Pattern : Large -&gt; Precis -&gt; Raffine**

**Tour 1 - Large (exploration)**
```
"Je veux ameliorer les performances de l'API. Quels sont les goulots
d'etranglement classiques dans une API Node.js/PostgreSQL ?"
```

**Tour 2 - Precis (focalisation)**
```
"Pour les N+1 queries que tu as identifiees, montre-moi comment les
detecter dans ce fichier : src/services/userService.ts"
```

**Tour 3 - Raffine (implementation)**
```
"Knowing everything you know now, implement the fix using DataLoader.
Constraints: do NOT change the public API, keep TypeScript strict mode."
```

**Quand recommencer vs continuer a raffiner**

| Signal | Action |
|--------|--------|
| Claude derive du sujet principal | Nouveau tour de recadrage |
| La solution proposee ne correspond pas au contexte | `/clear` et repartir avec plus de contexte initial |
| La conversation depasse 30 tours | Compacter (`/compact`) ou redemarrer |
| Une hypothese de base etait fausse | Corriger explicitement : "En fait, contrairement a ce que j'ai dit plus tot..." |

**Technique "Knowing everything you know now"**

Apres plusieurs tours d'echanges, Claude accumule du contexte implicite. Exploiter ce contexte :

```
"Knowing everything you know now about this codebase and the constraints
we've discussed, implement the cleanest possible solution. Forget the
intermediate versions."
```

Cette formulation pousse Claude a synthetiser les apprentissages de la conversation plutot que de continuer sur la trajectoire incrementale.

---

### Prompting par Niveau de Complexite

Adapter la structure du prompt a la complexite de la tache reduit les iterations inutiles.

| Complexite | Lignes | Structure recommandee | Exemple |
|------------|--------|-----------------------|---------|
| Simple | 1 ligne | Instruction directe | `"Rename variable userId to accountId in auth.ts"` |
| Moyenne | 2-3 lignes | Contexte + instruction + contrainte | `"In the payment module, add input validation for the amount field. Reject negative values and values above 10000."` |
| Complexe | 5+ lignes | Contexte + exemples + contraintes + criteres de verification | Voir gabarit ci-dessous |

**Gabarit pour taches complexes**

```
Context: [what exists, what the system does, relevant constraints]

Task: [precise instruction, single verb, single outcome]

Examples:
  Input:  [exemple d'entree]
  Output: [exemple de sortie attendue]

Constraints:
  - DO: [ce qui est obligatoire]
  - DO NOT: [ce qui est interdit]

Verification: after implementing, run [commande] and show me the output.
```

---

### Prompting Multi-Agents

Quand un workflow delegue du travail a des sous-agents (via `/work:work-team` ou un orchestrateur), le briefing de chaque sous-agent doit etre autonome : l'agent ne voit pas la conversation parente.

**Principes de briefing d'un sous-agent**

1. Inclure le contexte minimal suffisant (pas toute la conversation)
2. Specifier le livrable attendu de facon non ambigue
3. Indiquer les fichiers a lire avant d'agir
4. Definir la commande de verification a executer
5. Preciser le format de sortie si le resultat est consomme par un autre agent

**Gabarit de handoff de contexte**

```
You are working on [projet], a [description courte].

Relevant files:
  - [fichier A] : [son role]
  - [fichier B] : [son role]

Your task: [instruction precise]

Constraints: [contraintes techniques]

When done: run [commande de verification] and report the result.
Output format: [format si consomme par un autre agent]
```

**Quand utiliser Agent Teams vs sequentiel**

| Situation | Approche |
|-----------|----------|
| Taches independantes (pas de dependance entre elles) | Agent Teams (parallelisme) |
| Tache B depend du livrable de tache A | Sequentiel |
| Meme domaine de code, ordre importe | Sequentiel pour eviter les conflits |
| Audit + implementation sur des modules distincts | Agent Teams |

---

### Patterns Avances

**Pattern "Grill Me" (challenger)**

Utilise avant une decision irreversible ou un merge important. Claude prend le role d'un reviewer hostile.

```
"Before we proceed, grill me on this architecture decision.
Ask me the hardest questions a skeptical senior engineer would ask.
Do not let me move forward until I've answered convincingly."
```

Variante pour du code :
```
"Grill me on this implementation. Find every assumption I'm making
that could be wrong in production."
```

**Pattern "Prove It Works" (justification par la preuve)**

Claude ne peut pas se contenter d'affirmer qu'une solution fonctionne - il doit le demontrer.

```
"Prove to me this fix works. Show me:
1. The exact lines changed (diff)
2. The test that was failing and now passes
3. Why the root cause is eliminated, not just masked"
```

**Pattern "Scrap and Redo" (repartir proprement)**

Quand une premiere iteration fonctionne mais est trop complexe pour etre maintenue :

```
"This works but it's too complex. Scrap it. Knowing everything you
know now about the requirements and edge cases, implement the
simplest possible version that still handles all cases correctly."
```

A utiliser apres un premier cycle Red-Green, avant de commiter, quand le code "sent mauvais".

**Pattern Chain-of-Verification**

Force Claude a verifier son propre travail etape par etape avant de livrer :

```
"After implementing, verify your work in this order:
1. Does it compile / pass type-check ?
2. Do all existing tests still pass ?
3. Does the new test I described pass ?
4. Is there any input that could cause a crash ?
Only report completion after all four checks are green."
```

**Negative Prompting ("DO NOT")**

Les contraintes negatives sont souvent plus efficaces que les contraintes positives pour eviter les erreurs repetees :

```
"DO NOT:
- Introduce new dependencies without asking
- Change the public API surface
- Use any (TypeScript strict mode is required)
- Leave console.log statements
- Modify test files unless explicitly asked"
```

A placer en debut de prompt pour les contraintes critiques, en fin de prompt pour les preferences.

---

### Anti-Patterns Detailles

| Anti-pattern | Pourquoi ca echoue | Alternative |
|---|---|---|
| Prompt vague sans contexte ("fix it", "make it better") | Claude invente le contexte manquant et resout le mauvais probleme | Decrire le comportement observe, le comportement attendu, et le fichier concerne |
| Sur-contraindre chaque detail ("use exactly 4 spaces, name the variable x, add a comment every 3 lines") | Claude passe du temps a respecter des contraintes arbitraires au lieu de resoudre le probleme | Contraindre l'interface et le comportement, pas l'implementation interne |
| Demander une confirmation a chaque etape ("tell me before you do anything", "ask me before each file") | Multiplie les tours de conversation, fragmente le contexte, ralentit sans apporter de valeur | Definir les contraintes en amont dans un seul prompt, laisser Claude executer |
| Ne pas fournir de moyen de verification | Claude ne peut pas detecter ses propres erreurs silencieuses | Toujours inclure une commande de verification : `npm test`, `npm run typecheck`, `./scripts/validate.sh` |
| Corriger Claude en cours de route sans reformuler | Les corrections ponctuelles s'accumulent et le contexte devient incohérent | Si plus de 2 corrections sont necessaires, redemarrer avec un prompt reformule integrant les corrections |
