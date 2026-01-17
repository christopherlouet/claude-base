# Output Styles Guide

## Vue d'ensemble

Les **Output Styles** permettent de personnaliser le format des reponses de Claude Code selon le contexte et les preferences de l'utilisateur.

## Styles Disponibles

| Style | Commande | Description | Cas d'usage |
|-------|----------|-------------|-------------|
| **teaching** | `/output-style teaching` | Mode pedagogique | Apprentissage, formation, explications |
| **concise** | `/output-style concise` | Bref et direct | Dev experimente, rapidite |
| **technical** | `/output-style technical` | Technique approfondi | Architecture, decisions techniques |
| **review** | `/output-style review` | Revue de code | Code review, PR, audits |
| **emoji** | `/output-style emoji` | Enrichi d'emojis | Presentations, documentation |
| **minimal** | `/output-style minimal` | Epure, sans decoration | Terminal, logs, CI/CD |
| **structured** | `/output-style structured` | Structure ASCII | Rapports, analyses |

## Matrice de Choix

### Par niveau d'experience

| Niveau | Style recommande |
|--------|------------------|
| Debutant | teaching |
| Intermediaire | technical |
| Expert | concise ou minimal |

### Par type de tache

| Tache | Style recommande |
|-------|------------------|
| Apprendre un concept | teaching |
| Fix rapide | concise |
| Decisions d'architecture | technical |
| Code review | review |
| Documentation README | emoji |
| Rapport d'audit | structured |
| Script CI/CD | minimal |

### Par contexte

| Contexte | Style recommande |
|----------|------------------|
| Pair programming | teaching |
| Deadline serree | concise |
| Planning technique | technical |
| Pull Request | review |
| Demo client | emoji |
| Logs serveur | minimal |
| Rapport de sprint | structured |

## Exemples Comparatifs

### Question: "Comment implementer une pagination?"

---

#### Teaching Mode
```markdown
## Concept: Pagination

### Qu'est-ce que c'est?
La pagination permet de diviser de grandes listes de donnees en pages
plus petites pour ameliorer les performances et l'UX.

### Pourquoi c'est utile?
- Reduit la charge serveur (moins de donnees par requete)
- Ameliore le temps de chargement
- Permet a l'utilisateur de naviguer facilement

### Comment ca marche?
Nous utilisons deux parametres: `page` (numero de page) et `limit`
(elements par page). Le serveur calcule le `offset` ainsi:
offset = (page - 1) * limit

### Exemple pratique
[Code detaille avec commentaires...]

### Points cles a retenir
- Toujours definir une limite par defaut
- Valider les parametres cote serveur
- Retourner le total pour le calcul des pages
```

---

#### Concise Mode
```typescript
const paginate = <T>(items: T[], page = 1, limit = 10) =>
  items.slice((page - 1) * limit, page * limit);
```

---

#### Technical Mode
```markdown
## Implementation: Pagination

### Analyse
Pagination offset-based vs cursor-based. Offset simple mais inefficace
sur grandes tables. Cursor stable mais complexe.

### Implementation
[Code TypeScript avec types complets]

### Complexite
- Temps: O(n) offset / O(1) cursor
- Espace: O(limit)

### Trade-offs
| Approche | Avantages | Inconvenients |
|----------|-----------|---------------|
| Offset | Simple, page numero | Lent sur gros datasets |
| Cursor | Performant, stable | Pas de jump de page |
```

---

#### Structured Mode
```
════════════════════════════════════════
PAGINATION
════════════════════════════════════════

────────────────────────────────────────
Approches
────────────────────────────────────────

┌─────────────┬──────────────┬──────────┐
│ Type        │ Performance  │ Usage    │
├─────────────┼──────────────┼──────────┤
│ Offset      │ O(n)         │ Simple   │
│ Cursor      │ O(1)         │ Scale    │
│ Keyset      │ O(log n)     │ Mixte    │
└─────────────┴──────────────┴──────────┘

[OK]   Offset pour < 10k items
[WARN] Cursor recommande > 10k items
```

---

## Configuration

### Frontmatter requis

Chaque fichier de style doit avoir:

```yaml
---
name: Nom du Style
description: Description courte
keep-coding-instructions: true
---
```

### Options

| Option | Type | Description |
|--------|------|-------------|
| `name` | string | Nom affiche du style |
| `description` | string | Description courte |
| `keep-coding-instructions` | boolean | Conserver les instructions de code |

## Creer un Style Personnalise

1. Creer un fichier `.md` dans `.claude/output-styles/`
2. Ajouter le frontmatter YAML
3. Documenter le format et les exemples

### Template

```markdown
---
name: Mon Style
description: Description de mon style personnalise
keep-coding-instructions: true
---

# Mon Style

## Principes
- Principe 1
- Principe 2

## Format
[Description du format]

## Exemples
[Exemples d'utilisation]
```

## Combinaisons Recommandees

| Workflow | Styles |
|----------|--------|
| Onboarding | teaching → technical |
| Bug fix | concise → review |
| Feature | technical → review |
| Release | structured → emoji |
| Audit | technical → structured |
