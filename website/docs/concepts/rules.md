---
sidebar_position: 5
title: Rules
description: Comprendre les rules Claude Code
---

# Rules

> Conventions appliquees automatiquement selon le chemin des fichiers

## Qu'est-ce qu'une Rule ?

Une **rule** est un ensemble de conventions et bonnes pratiques appliquees automatiquement quand vous travaillez sur certains types de fichiers.

```
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│  User: "Modifie src/components/Button.tsx"                     │
│              │                                                 │
│              ▼                                                 │
│  ┌────────────────────────────────────────┐                    │
│  │ Detection du path                      │                    │
│  │                                        │                    │
│  │ "**/*.tsx" → Rule TypeScript active    │                    │
│  │ "**/components/**" → Rule React active │                    │
│  └────────────────────────────────────────┘                    │
│              │                                                 │
│              ▼                                                 │
│  ┌────────────────────────────────────────┐                    │
│  │ Conventions injectees                  │                    │
│  │                                        │                    │
│  │ - Strict mode TypeScript               │                    │
│  │ - Pas de `any`                         │                    │
│  │ - Composants fonctionnels              │                    │
│  │ - Hooks pour la logique                │                    │
│  └────────────────────────────────────────┘                    │
│              │                                                 │
│              ▼                                                 │
│  Claude applique les conventions automatiquement               │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

## Structure des fichiers

Les rules sont dans `.claude/rules/`:

```
.claude/rules/
├── typescript.md      # Conventions TypeScript
├── react.md           # Conventions React
├── flutter.md         # Conventions Flutter/Dart
├── python.md          # Conventions Python
├── go.md              # Conventions Go
├── testing.md         # Conventions de tests
├── security.md        # Regles de securite
├── api.md             # Conventions API
├── git.md             # Conventions Git
├── workflow.md        # Workflow obligatoire
├── accessibility.md   # Regles accessibilite
└── performance.md     # Regles performance
```

## Anatomie d'une rule

### Avec frontmatter (path-specific)

```markdown
---
paths:
  - "**/*.ts"
  - "**/*.tsx"
---

# TypeScript Rules

## Mode strict

IMPORTANT: Mode strict active (`"strict": true`)

## Types

IMPORTANT: Pas de `any` sauf cas exceptionnels documentes

YOU MUST definir des interfaces pour les objets complexes

## Nommage

| Type | Convention | Exemple |
|------|------------|---------|
| Variables | camelCase | `getUserById` |
| Interfaces | PascalCase | `UserService` |
| Constantes | SCREAMING_SNAKE | `MAX_RETRY` |
```

### Sans frontmatter (globale)

```markdown
# Git Rules

## Conventional Commits

\`\`\`
type(scope): description courte
\`\`\`

### Types autorises

| Type | Usage |
|------|-------|
| feat | Nouvelle fonctionnalite |
| fix | Correction de bug |
| docs | Documentation |
| refactor | Refactoring |
```

## Frontmatter

### Champ `paths`

Definit quand la rule s'applique:

```yaml
---
paths:
  - "**/*.ts"           # Tous les fichiers .ts
  - "**/*.tsx"          # Tous les fichiers .tsx
  - "**/components/**"  # Dossier components
  - "**/api/**"         # Dossier api
---
```

### Patterns supportes

| Pattern | Description | Exemple |
|---------|-------------|---------|
| `*` | Un segment | `*.ts` |
| `**` | Zero ou plus segments | `**/*.ts` |
| `?` | Un caractere | `file?.ts` |

## Categories de rules

### Par langage

| Rule | Paths | Contenu |
|------|-------|---------|
| `typescript.md` | `**/*.ts`, `**/*.tsx` | Strict mode, types, conventions |
| `react.md` | `**/*.tsx`, `**/components/**` | Composants, hooks, performance |
| `flutter.md` | `**/*.dart`, `**/lib/**` | Clean Architecture, BLoC |
| `python.md` | `**/*.py` | Type hints, PEP 8 |
| `go.md` | `**/*.go` | Error handling, interfaces |

### Transversales

| Rule | Paths | Contenu |
|------|-------|---------|
| `testing.md` | `**/*.test.ts`, `**/__tests__/**` | Couverture, mocks |
| `security.md` | `**/auth/**`, `**/api/**` | Validation, XSS, injection |
| `api.md` | `**/api/**`, `**/routes/**` | REST, status codes |
| `git.md` | - | Conventional commits |
| `workflow.md` | - | Explore → Plan → Code |

## Exemples de rules

### Rule TypeScript

```markdown
---
paths:
  - "**/*.ts"
  - "**/*.tsx"
---

# TypeScript Rules

## Configuration

IMPORTANT: Mode strict active

\`\`\`json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true
  }
}
\`\`\`

## Types

IMPORTANT: Pas de `any` sauf cas documentes

YOU MUST definir des interfaces:

\`\`\`typescript
// Bon
interface User {
  id: string;
  name: string;
}

// Mauvais
const user: any = { ... };
\`\`\`

## Nommage

| Type | Convention |
|------|------------|
| Variables/Fonctions | camelCase |
| Interfaces/Classes | PascalCase |
| Constantes | SCREAMING_SNAKE |
```

### Rule React

```markdown
---
paths:
  - "**/*.tsx"
  - "**/components/**"
---

# React Rules

## Composants

YOU MUST utiliser des composants fonctionnels:

\`\`\`tsx
// Bon
function Button({ label }: ButtonProps) {
  return <button>{label}</button>;
}

// Eviter
class Button extends Component { ... }
\`\`\`

## Hooks

IMPORTANT: Extraire la logique dans des hooks custom:

\`\`\`tsx
// Bon
function useUser(id: string) {
  const [user, setUser] = useState<User | null>(null);
  // ...
  return { user, loading, error };
}

// Utilisation
function UserProfile({ id }: Props) {
  const { user, loading } = useUser(id);
  // ...
}
\`\`\`

## Performance

- Utiliser `memo()` pour les composants purs
- Utiliser `useMemo()` pour les calculs couteux
- Utiliser `useCallback()` pour les callbacks passes en props
```

### Rule Securite

```markdown
---
paths:
  - "**/auth/**"
  - "**/api/**"
  - "**/routes/**"
---

# Security Rules

## Validation des entrees

IMPORTANT: Valider TOUTES les entrees utilisateur

\`\`\`typescript
// Avec Zod
const userSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});
\`\`\`

## Prevention XSS

NEVER inserer du HTML non echappe:

\`\`\`tsx
// Dangereux
<div dangerouslySetInnerHTML={{ __html: userInput }} />

// Securise
<div>{sanitize(userInput)}</div>
\`\`\`

## Requetes SQL

IMPORTANT: Utiliser des requetes parametrees:

\`\`\`typescript
// Dangereux
const query = \`SELECT * FROM users WHERE id = \${userId}\`;

// Securise
const query = 'SELECT * FROM users WHERE id = ?';
db.query(query, [userId]);
\`\`\`
```

## Creer une nouvelle rule

### 1. Creer le fichier

```bash
touch .claude/rules/ma-rule.md
```

### 2. Definir le frontmatter (optionnel)

```yaml
---
paths:
  - "**/*.extension"
  - "**/dossier/**"
---
```

### 3. Ecrire les conventions

```markdown
# Ma Rule

## Convention 1

IMPORTANT: Description de la regle.

## Convention 2

YOU MUST suivre cette pratique.

NEVER faire ceci.

## Exemples

\`\`\`typescript
// Bon
...

// Mauvais
...
\`\`\`
```

## Priorite des rules

Quand plusieurs rules s'appliquent au meme fichier:

1. Rules specifiques (path plus precis) > Rules generales
2. Rules definies plus bas dans le fichier > Rules definies plus haut
3. Les rules ne se remplacent pas, elles s'accumulent

## Bonnes pratiques

1. **Paths precis**: Cibler exactement les fichiers concernes
2. **Conventions claires**: Utiliser IMPORTANT, YOU MUST, NEVER
3. **Exemples concrets**: Montrer le bon et le mauvais
4. **Pas de duplication**: Une convention a un seul endroit
5. **Maintenabilite**: Mettre a jour quand les standards evoluent

---

## Voir aussi

- [Commands](./commands) - Instructions manuelles
- [Skills](./skills) - Comportements automatiques
- [Hooks](./hooks) - Actions pre/post tool
