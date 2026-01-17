---
sidebar_position: 23
title: "react-performance"
description: "Optimisation des performances React/Next.js. Declencher quand l'utilisateur veut optimiser le rendu, reduire les re-renders, ou ameliorer les Core Web Vitals."
tags:
  - "skill"
  - "fork"
---

# Skill: react-performance

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Optimisation des performances React/Next.js. Declencher quand l'utilisateur veut optimiser le rendu, reduire les re-renders, ou ameliorer les Core Web Vitals.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep` |
| **Mots-cles** | `react`, `performance`, `/photo.jpg`, `description`, `blur` |

## Description detaillee

# React Performance Optimization

## Eviter les re-renders inutiles

### useMemo - Memoiser les calculs couteux

```tsx
const expensiveValue = useMemo(() => {
  return computeExpensiveValue(items);
}, [items]);
```

### useCallback - Memoiser les fonctions

```tsx
const handleClick = useCallback(() => {
  onSubmit(formData);
}, [formData, onSubmit]);
```

### React.memo - Memoiser les composants

```tsx
const UserCard = memo(({ user }: Props) => {
  return <div>{user.name}</div>;
});
```

## Lazy Loading

```tsx
// Components
const HeavyComponent = lazy(() => import('./HeavyComponent'));

<Suspense fallback={<Loading />}>
  <HeavyComponent />
</Suspense>

// Routes (Next.js)
const DynamicComponent = dynamic(() => import('./Component'), {
  loading: () => <Skeleton />,
  ssr: false,
});
```

## Virtualisation

```tsx
import { FixedSizeList } from 'react-window';

<FixedSizeList
  height={400}
  itemCount={items.length}
  itemSize={50}
>
  {({ index, style }) => (
    <div style={style}>{items[index].name}</div>
  )}
</FixedSizeList>
```

## Images (Next.js)

```tsx
import Image from 'next/image';

<Image
  src="/photo.jpg"
  alt="Description"
  width={800}
  height={600}
  priority={isAboveFold}
  placeholder="blur"
/>
```

## Core Web Vitals

| Metrique | Cible | Optimisation |
|----------|-------|--------------|
| LCP | < 2.5s | Preload hero image, SSR |
| FID | < 100ms | Code splitting, defer JS |
| CLS | < 0.1 | Explicit dimensions |

## Outils

```bash
# Analyser le bundle
npm run build -- --analyze

# Lighthouse
npx lighthouse https://example.com

# React DevTools Profiler
```

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux react..."_
- _"Je veux performance..."_
- _"Je veux /photo.jpg..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
