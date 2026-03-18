---
sidebar_position: 2
title: Developpement Web
description: Guide pour React, Next.js et Node.js
---

# Guide : Developpement Web

Guide complet pour les projets React, Next.js et Node.js.

## Stack supportee

- **Frontend** : React, Next.js, Vue.js
- **Backend** : Node.js, Express, NestJS
- **Langage** : TypeScript
- **Tests** : Jest, Vitest, Playwright

## Commandes recommandees

### Developpement

| Commande | Usage |
|----------|-------|
| `/dev:dev-component` | Creer un composant React complet |
| `/dev:dev-hook` | Creer un hook personnalise |
| `/dev:dev-react-perf` | Optimiser les performances React |
| `/dev:dev-tdd` | Developper en TDD |

### Qualite

| Commande | Usage |
|----------|-------|
| `/qa:qa-review` | Code review |
| `/qa:wcag-audit` | Audit accessibilite |
| `/qa:qa-perf` | Audit performance |
| `/qa:qa-responsive` | Audit responsive |

### Operations

| Commande | Usage |
|----------|-------|
| `/ops:ops-ci` | Configuration CI/CD |
| `/ops:ops-docker` | Dockerisation |
| `/ops:ops-deps` | Mise a jour dependances |

## Workflow type

### Nouvelle feature

```bash
# 1. Explorer le code existant
/work:work-explore "systeme de composants"

# 2. Planifier
/work:work-plan "Ajouter un composant DataTable"

# 3. Creer le composant
/dev:dev-component "DataTable avec tri et pagination"

# 4. Optimiser si necessaire
/dev:dev-react-perf

# 5. Review et PR
/qa:qa-review
/work:work-pr
```

### Nouveau hook

```bash
# 1. Planifier
/work:work-plan "Hook useDebounce"

# 2. Developper en TDD
/dev:dev-tdd "Creer useDebounce"

# 3. Commit
/work:work-commit
```

## Bonnes pratiques

### Structure de composant

```typescript
// src/components/Button/Button.tsx
import { type FC } from 'react';
import styles from './Button.module.css';

interface ButtonProps {
  variant?: 'primary' | 'secondary';
  onClick?: () => void;
  children: React.ReactNode;
}

export const Button: FC<ButtonProps> = ({
  variant = 'primary',
  onClick,
  children,
}) => {
  return (
    <button
      className={styles[variant]}
      onClick={onClick}
    >
      {children}
    </button>
  );
};
```

### Structure de hook

```typescript
// src/hooks/useDebounce.ts
import { useState, useEffect } from 'react';

export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => clearTimeout(timer);
  }, [value, delay]);

  return debouncedValue;
}
```

## Regles appliquees

Les regles suivantes s'appliquent automatiquement :

- **typescript.md** - Strict mode, pas de any
- **react.md** - Composants fonctionnels, hooks
- **testing.md** - Couverture 80%, edge cases

## Exemple complet

```bash
# Creer une page de dashboard

> /work:work-flow-feature "Page Dashboard avec widgets"

# Claude :
# 1. Explore la structure existante
# 2. Propose l'architecture (composants, hooks)
# 3. Cree les composants en TDD
# 4. Ajoute les tests
# 5. Optimise les performances
# 6. Cree la PR
```

---

## Voir aussi

- [Composants](/docs/commands/dev/dev-component)
- [Hooks](/docs/commands/dev/dev-hook)
- [React Performance](/docs/commands/dev/dev-react-perf)
