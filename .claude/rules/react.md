---
paths:
  - "**/*.tsx"
  - "**/components/**"
  - "**/hooks/**"
  - "**/pages/**"
  - "**/app/**"
---

# React Rules

## Components

- Utiliser des composants fonctionnels avec hooks
- Un composant par fichier
- Nommage PascalCase pour les composants
- Props typees avec interface ou type

## Hooks

- Prefixe `use` pour tous les hooks custom
- Respecter les regles des hooks (ordre, conditionnels)
- Extraire la logique complexe dans des hooks custom
- Documenter les hooks avec JSDoc

## State Management

- useState pour etat local simple
- useReducer pour etat local complexe
- Context pour etat partage limite
- Zustand/Redux pour etat global complexe

## Performance

- Utiliser React.memo pour composants purs
- useMemo pour calculs couteux
- useCallback pour fonctions passees en props
- Eviter les re-renders inutiles

## Patterns

```tsx
// Composant type
interface Props {
  title: string;
  onAction: () => void;
}

export function MyComponent({ title, onAction }: Props) {
  const [state, setState] = useState<string>('');

  return (
    <div>
      <h1>{title}</h1>
      <button onClick={onAction}>Action</button>
    </div>
  );
}
```

## Anti-patterns

- NEVER utiliser `any` pour les props
- NEVER muter le state directement
- Eviter les effets de bord dans le render
- Eviter les index comme keys dans les listes
