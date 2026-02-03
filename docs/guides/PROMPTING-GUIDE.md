# Guide de Prompting Avance

> Techniques de prompting recommandees par Boris Cherny (createur de Claude Code) pour maximiser la qualite des resultats.

## Principe Fondamental

> "The more specific and detailed the specification, the better the output."

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

> "When I dictate prompts, I tend to be much more detailed than when I type. The extra context always improves results."

### Avantages
- Plus naturel = plus de details
- Plus rapide que la frappe
- Moins d'auto-censure sur la longueur

## Ressources

- [How Boris Uses Claude Code](https://howborisusesclaudecode.com/)
- [10 Claude Code Tips from Boris](https://ykdojo.github.io/claude-code-tips/content/boris-claude-code-tips)
- [Claude Code Best Practices (Anthropic)](https://docs.anthropic.com/en/docs/claude-code)
