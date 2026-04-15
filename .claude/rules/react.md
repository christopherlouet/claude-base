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

### Render optimization patterns
- Colocation du state : descendre le state au composant le plus bas possible pour limiter l'arbre re-rendu
- Composition (children as props) : passer du JSX en props pour eviter les re-renders lors de changements de state parent
- Split context : separer les contextes par frequence de changement (ne pas melanger donnees stables et volatiles)
- `useDeferredValue` / `useTransition` pour prioriser les mises a jour urgentes (React 18+)

### Data fetching patterns
- Server Components (Next.js App Router) : fetch cote serveur, zero JS client
- Suspense + `use()` pour boundaries de chargement declaratives
- SWR/React Query : cache, dedup, revalidation, optimistic updates
- Prefetch sur hover/focus pour routes probables (`router.prefetch()`)
- Parallel fetching (`Promise.all`) et waterfall avoidance : hoister les fetch au plus haut

## Design patterns React

| Pattern | Usage |
|---------|-------|
| **Custom Hooks** | Encapsuler logique stateful reutilisable (defaut moderne) |
| **Compound Components** | API declarative type `<Tabs><Tab/></Tabs>` via Context interne |
| **Render Props / children function** | Partager logique quand hooks insuffisants (rare aujourd'hui) |
| **Container / Presentational** | Separer fetch/state (container) du rendu (presentational) |
| **Provider** | Injecter dependances/theme via Context |
| **HOC** | Legacy -- preferer hooks sauf besoin specifique (ErrorBoundary class) |

## Rendering strategies (Next.js / frameworks)

- **CSR** : dashboards authentifies, contenu dynamique utilisateur
- **SSR** : SEO + donnees fraiches (e-commerce, feeds)
- **SSG** : contenu statique (docs, blog, marketing)
- **ISR** : hybride SSG avec revalidation (catalogues)
- **RSC (Server Components)** : defaut Next.js App Router, zero JS par defaut
- **Streaming SSR + Suspense** : TTFB rapide, contenu progressif

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
