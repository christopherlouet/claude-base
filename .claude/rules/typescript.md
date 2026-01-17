---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.mts"
---

# TypeScript Rules

## Strict Mode

- IMPORTANT: Mode strict active (`"strict": true`)
- Ne pas desactiver les checks TypeScript
- Corriger les erreurs de type, ne pas les ignorer

## Type Safety

- IMPORTANT: Pas de `any` sauf cas exceptionnels documentes
- YOU MUST definir des interfaces pour les objets complexes
- Preferer `unknown` a `any` quand le type est inconnu
- Utiliser les type guards pour le narrowing

## Types vs Interfaces

- Preferer `type` pour unions et intersections
- Preferer `interface` pour objets extensibles
- Utiliser `interface` pour les APIs publiques

## Naming Conventions

| Type | Convention | Exemple |
|------|------------|---------|
| Variables/Fonctions | camelCase | `getUserById` |
| Classes/Interfaces | PascalCase | `UserService` |
| Constantes | SCREAMING_SNAKE | `MAX_RETRY_COUNT` |
| Types generiques | T, K, V ou descriptif | `TData`, `TError` |
| Enums | PascalCase (nom et valeurs) | `UserRole.Admin` |

## File Naming

| Type | Convention | Exemple |
|------|------------|---------|
| Composants React | PascalCase | `UserCard.tsx` |
| Services/Utils | kebab-case | `user-service.ts` |
| Types/Interfaces | kebab-case ou PascalCase | `user-types.ts` |
| Tests | meme nom + .test | `user-service.test.ts` |

## Best Practices

- Fonctions pures quand possible
- Immutabilite des donnees
- Single Responsibility Principle
- DRY mais pas au detriment de la lisibilite
- Eviter les effets de bord dans les fonctions
