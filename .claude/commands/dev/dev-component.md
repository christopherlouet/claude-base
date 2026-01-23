# Agent DEV-COMPONENT

Générer un composant UI complet avec tests, types et documentation.

## Contexte
$ARGUMENTS

## Pre-requis TDD

IMPORTANT: Cette commande suit l'approche TDD. Les tests seront ecrits AVANT le code du composant.

**Ordre de creation obligatoire:**
1. `[ComponentName].types.ts` - Definir les types d'abord
2. `[ComponentName].test.tsx` - Ecrire les tests (RED)
3. `[ComponentName].tsx` - Implementer le composant (GREEN)
4. Refactorer si necessaire (REFACTOR)
5. `[ComponentName].stories.tsx` - Documentation Storybook

Si vous souhaitez proceder autrement, utilisez `/dev-component --skip-tdd` (non recommande).

---

## Processus de création

### 1. Définir le composant

#### Questions clés
- Nom du composant ?
- Framework (React, Vue, Svelte) ?
- Props/API attendues ?
- États internes ?
- Variants (tailles, couleurs) ?

### 2. Structure à générer

```
src/components/[ComponentName]/
├── [ComponentName].tsx       # Composant principal
├── [ComponentName].test.tsx  # Tests unitaires
├── [ComponentName].stories.tsx # Storybook (si applicable)
├── [ComponentName].module.css # Styles (ou .styled.ts)
├── [ComponentName].types.ts  # Types TypeScript
└── index.ts                  # Export
```

### 3. Template composant React

```typescript
// [ComponentName].types.ts
export interface [ComponentName]Props {
  /** Description de la prop */
  children?: React.ReactNode;
  /** Variant visuel */
  variant?: 'primary' | 'secondary' | 'outline';
  /** Taille du composant */
  size?: 'sm' | 'md' | 'lg';
  /** Désactivé */
  disabled?: boolean;
  /** Classe CSS additionnelle */
  className?: string;
  /** Callback au clic */
  onClick?: () => void;
}
```

```typescript
// [ComponentName].tsx
import { forwardRef } from 'react';
import { clsx } from 'clsx';
import type { [ComponentName]Props } from './[ComponentName].types';
import styles from './[ComponentName].module.css';

export const [ComponentName] = forwardRef<HTMLDivElement, [ComponentName]Props>(
  ({ children, variant = 'primary', size = 'md', disabled, className, onClick, ...props }, ref) => {
    return (
      <div
        ref={ref}
        className={clsx(
          styles.root,
          styles[variant],
          styles[size],
          disabled && styles.disabled,
          className
        )}
        onClick={disabled ? undefined : onClick}
        {...props}
      >
        {children}
      </div>
    );
  }
);

[ComponentName].displayName = '[ComponentName]';
```

### 4. Template tests

```typescript
// [ComponentName].test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { [ComponentName] } from './[ComponentName]';

describe('[ComponentName]', () => {
  it('renders children correctly', () => {
    render(<[ComponentName]>Hello</[ComponentName]>);
    expect(screen.getByText('Hello')).toBeInTheDocument();
  });

  it('applies variant class', () => {
    const { container } = render(<[ComponentName] variant="secondary" />);
    expect(container.firstChild).toHaveClass('secondary');
  });

  it('handles click events', () => {
    const handleClick = jest.fn();
    render(<[ComponentName] onClick={handleClick}>Click me</[ComponentName]>);
    fireEvent.click(screen.getByText('Click me'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('does not trigger click when disabled', () => {
    const handleClick = jest.fn();
    render(<[ComponentName] disabled onClick={handleClick}>Click me</[ComponentName]>);
    fireEvent.click(screen.getByText('Click me'));
    expect(handleClick).not.toHaveBeenCalled();
  });

  it('applies custom className', () => {
    const { container } = render(<[ComponentName] className="custom" />);
    expect(container.firstChild).toHaveClass('custom');
  });
});
```

### 5. Template Storybook

```typescript
// [ComponentName].stories.tsx
import type { Meta, StoryObj } from '@storybook/react';
import { [ComponentName] } from './[ComponentName]';

const meta: Meta<typeof [ComponentName]> = {
  title: 'Components/[ComponentName]',
  component: [ComponentName],
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: 'select',
      options: ['primary', 'secondary', 'outline'],
    },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg'],
    },
  },
};

export default meta;
type Story = StoryObj<typeof [ComponentName]>;

export const Default: Story = {
  args: {
    children: '[ComponentName]',
  },
};

export const Variants: Story = {
  render: () => (
    <div style={{ display: 'flex', gap: '1rem' }}>
      <[ComponentName] variant="primary">Primary</[ComponentName]>
      <[ComponentName] variant="secondary">Secondary</[ComponentName]>
      <[ComponentName] variant="outline">Outline</[ComponentName]>
    </div>
  ),
};

export const Sizes: Story = {
  render: () => (
    <div style={{ display: 'flex', gap: '1rem', alignItems: 'center' }}>
      <[ComponentName] size="sm">Small</[ComponentName]>
      <[ComponentName] size="md">Medium</[ComponentName]>
      <[ComponentName] size="lg">Large</[ComponentName]>
    </div>
  ),
};

export const Disabled: Story = {
  args: {
    children: 'Disabled',
    disabled: true,
  },
};
```

### 6. Checklist qualité

- [ ] Props typées avec JSDoc
- [ ] ForwardRef si nécessaire
- [ ] Gestion du disabled
- [ ] Classes CSS modulaires
- [ ] Tests unitaires (>80% coverage)
- [ ] Stories Storybook
- [ ] Accessibilité (aria-*, role, tabIndex)
- [ ] Responsive si applicable

## Output attendu

### Fichiers générés
- `[ComponentName].tsx`
- `[ComponentName].types.ts`
- `[ComponentName].test.tsx`
- `[ComponentName].stories.tsx` (si Storybook)
- `[ComponentName].module.css`
- `index.ts`

### Documentation
```markdown
## [ComponentName]

### Usage
\`\`\`tsx
import { [ComponentName] } from '@/components/[ComponentName]';

<[ComponentName] variant="primary" size="md">
  Content
</[ComponentName]>
\`\`\`

### Props
| Prop | Type | Default | Description |
|------|------|---------|-------------|
| variant | 'primary' \| 'secondary' | 'primary' | Variant visuel |
| size | 'sm' \| 'md' \| 'lg' | 'md' | Taille |
| disabled | boolean | false | État désactivé |
```

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/hook` | Créer un hook associé |
| `/test` | Tests complémentaires |
| `/a11y` | Audit accessibilité du composant |
| `/responsive` | Vérifier le responsive |

---

IMPORTANT: Toujours typer les props avec des interfaces explicites.

YOU MUST ajouter des tests pour chaque prop et comportement.

NEVER oublier l'accessibilité (aria-label, role, keyboard navigation).

Think hard sur l'API du composant avant de coder.
