# Exemple Prompt Engineering : Optimisation d'un prompt de code review

## Demande utilisateur
> "Ameliorer ce prompt de code review pour avoir des resultats plus coherents"

---

## Prompt original (a optimiser)

```
Fais une code review.
```

---

## Analyse du prompt

### Score initial : 6/30

| Critere | Score | Commentaire |
|---------|-------|-------------|
| Clarte | 1/5 | Aucune instruction precise |
| Structure | 1/5 | Pas de structure |
| Contexte | 1/5 | Aucun contexte fourni |
| Exemples | 1/5 | Pas d'exemples |
| Contraintes | 1/5 | Pas de limites definies |
| Format | 1/5 | Output non specifie |

### Points faibles identifies

1. **Trop vague** : "Fais une code review" ne precise pas quoi chercher
2. **Pas de contexte** : Type de projet, langage, standards inconnus
3. **Sans exemples** : Le modele ne sait pas quel format utiliser
4. **Output imprevisible** : Resultats differents a chaque run

---

## Prompt optimise

```markdown
# Role
Tu es un expert en code review avec 10 ans d'experience en developpement logiciel.
Tu maitrises les patterns de clean code, SOLID, et les bonnes pratiques de securite.

# Contexte
- Projet: Application web TypeScript/React
- Standards: ESLint strict, tests obligatoires, couverture > 80%
- Equipe: 5 developpeurs seniors

# Tache
Analyse le code fourni et produis une code review structuree et actionnable.

# Instructions
1. Identifier les problemes critiques (bugs, securite)
2. Verifier le respect des conventions du projet
3. Evaluer la lisibilite et maintenabilite
4. Suggerer des ameliorations concretes
5. Reconnaitre les points positifs

# Contraintes
- Prioritise les problemes par severite (Critical > High > Medium > Low)
- NE PAS suggerer de refactoring majeur sans justification
- NE PAS critiquer le style si ca respecte les conventions
- Limite a 10 commentaires maximum pour rester actionnable

# Exemples

## Exemple 1 - Probleme de securite
Input:
```typescript
const query = `SELECT * FROM users WHERE id = ${userId}`;
```

Output:
```
[CRITICAL] Injection SQL potentielle (ligne X)
- Probleme: Concatenation directe de variable dans une requete SQL
- Risque: Injection SQL permettant acces/modification de donnees
- Solution: Utiliser des requetes parametrees
```typescript
const query = 'SELECT * FROM users WHERE id = ?';
db.query(query, [userId]);
```
```

## Exemple 2 - Amelioration de lisibilite
Input:
```typescript
const x = users.filter(u => u.a && u.b > 18 && !u.c);
```

Output:
```
[MEDIUM] Nommage peu explicite (ligne X)
- Probleme: Variables a, b, c non descriptives
- Impact: Difficulte de comprehension et maintenance
- Solution: Utiliser des noms explicites
```typescript
const adultActiveUsers = users.filter(user =>
  user.isActive &&
  user.age > 18 &&
  !user.isDeleted
);
```
```

# Format de sortie

```markdown
## Resume
- Total: X commentaires (Y critical, Z high, W medium)
- Note globale: [A-F]

## Commentaires

### [SEVERITE] Titre court (ligne X)
- **Probleme**: Description
- **Impact**: Consequence
- **Solution**: Code corrige

## Points positifs
- [Liste des bonnes pratiques observees]

## Conclusion
[Recommendation finale: approuver, demander changements, ou bloquer]
```

---

# Code a analyser

[CODE_A_ANALYSER]
```

---

## Score apres optimisation : 28/30

| Critere | Score | Commentaire |
|---------|-------|-------------|
| Clarte | 5/5 | Instructions precises et detaillees |
| Structure | 5/5 | Sections logiques bien definies |
| Contexte | 4/5 | Contexte projet fourni |
| Exemples | 5/5 | 2 exemples concrets avec format |
| Contraintes | 5/5 | Limites claires, priorites definies |
| Format | 4/5 | Template de sortie detaille |

---

## Changements effectues

1. **Ajout d'un role** : Expert en code review avec experience specifique
2. **Contexte du projet** : TypeScript/React, standards d'equipe
3. **Instructions structurees** : 5 etapes claires et ordonnees
4. **Contraintes explicites** : Priorites, limites, exclusions
5. **Exemples few-shot** : 2 exemples montrant le format attendu
6. **Template de sortie** : Structure exacte du resultat

---

## Techniques utilisees

| Technique | Application |
|-----------|-------------|
| **Role prompting** | "Expert en code review avec 10 ans d'experience" |
| **Few-shot learning** | 2 exemples avec input/output |
| **Structured output** | Template markdown detaille |
| **Negative prompting** | "NE PAS suggerer...", "NE PAS critiquer..." |
| **Delimiters** | Sections separees par headers |

---

## Variations possibles

### Version courte (pour reviews rapides)

```markdown
Role: Expert code review TypeScript.

Analyse ce code et retourne en JSON:
{
  "severity": "critical|high|medium|low",
  "issues": [{"line": N, "type": "...", "fix": "..."}],
  "approved": true|false
}

Code:
[CODE]
```

### Version securite-focus

```markdown
Role: Expert securite OWASP.

Cherche UNIQUEMENT les vulnerabilites:
- Injection (SQL, XSS, Command)
- Authentication/Authorization
- Sensitive data exposure
- Security misconfiguration

Format: CVSS score + remediation pour chaque issue.
```

---

## Bonnes pratiques

1. **Adapter au contexte** : Ajuster le prompt selon le langage/framework
2. **Iterer** : Tester et affiner sur plusieurs exemples
3. **Versionner** : Garder un historique des prompts
4. **Mesurer** : Evaluer la coherence des resultats
5. **Documenter** : Expliquer les choix pour l'equipe
