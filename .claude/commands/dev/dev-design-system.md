# Agent DESIGN-SYSTEM

Creation et maintenance de design systems et bibliotheques de composants.

## Contexte
$ARGUMENTS

## Architecture Design System

```
┌─────────────────────────────────────────────────────────────────┐
│                      DESIGN SYSTEM                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    DESIGN TOKENS                         │   │
│  │  Colors │ Typography │ Spacing │ Shadows │ Animations   │   │
│  └─────────────────────────────────────────────────────────┘   │
│                            │                                    │
│                            ▼                                    │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                  PRIMITIVE COMPONENTS                    │   │
│  │  Button │ Input │ Text │ Icon │ Card │ Badge            │   │
│  └─────────────────────────────────────────────────────────┘   │
│                            │                                    │
│                            ▼                                    │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                  COMPOSITE COMPONENTS                    │   │
│  │  Form │ Modal │ Dropdown │ Table │ Navigation           │   │
│  └─────────────────────────────────────────────────────────┘   │
│                            │                                    │
│                            ▼                                    │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                      PATTERNS                            │   │
│  │  Auth Flow │ Settings │ Dashboard │ Empty States        │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Design Tokens

### Structure recommandee

```
tokens/
├── colors.json
├── typography.json
├── spacing.json
├── shadows.json
├── animations.json
├── breakpoints.json
└── index.ts
```

### Tokens de couleur

```json
// tokens/colors.json
{
  "color": {
    "primitive": {
      "blue": {
        "50": { "value": "#eff6ff" },
        "100": { "value": "#dbeafe" },
        "500": { "value": "#3b82f6" },
        "600": { "value": "#2563eb" },
        "900": { "value": "#1e3a8a" }
      },
      "gray": {
        "50": { "value": "#f9fafb" },
        "100": { "value": "#f3f4f6" },
        "500": { "value": "#6b7280" },
        "900": { "value": "#111827" }
      }
    },
    "semantic": {
      "primary": { "value": "{color.primitive.blue.600}" },
      "secondary": { "value": "{color.primitive.gray.600}" },
      "success": { "value": "#10b981" },
      "warning": { "value": "#f59e0b" },
      "error": { "value": "#ef4444" },
      "background": {
        "default": { "value": "#ffffff" },
        "subtle": { "value": "{color.primitive.gray.50}" }
      },
      "text": {
        "default": { "value": "{color.primitive.gray.900}" },
        "muted": { "value": "{color.primitive.gray.500}" }
      }
    }
  }
}
```

### Tokens de typographie

```json
// tokens/typography.json
{
  "font": {
    "family": {
      "sans": { "value": "Inter, system-ui, sans-serif" },
      "mono": { "value": "JetBrains Mono, monospace" }
    },
    "size": {
      "xs": { "value": "0.75rem" },
      "sm": { "value": "0.875rem" },
      "base": { "value": "1rem" },
      "lg": { "value": "1.125rem" },
      "xl": { "value": "1.25rem" },
      "2xl": { "value": "1.5rem" },
      "3xl": { "value": "1.875rem" },
      "4xl": { "value": "2.25rem" }
    },
    "weight": {
      "normal": { "value": "400" },
      "medium": { "value": "500" },
      "semibold": { "value": "600" },
      "bold": { "value": "700" }
    },
    "lineHeight": {
      "tight": { "value": "1.25" },
      "normal": { "value": "1.5" },
      "relaxed": { "value": "1.75" }
    }
  }
}
```

### Tokens d'espacement

```json
// tokens/spacing.json
{
  "spacing": {
    "0": { "value": "0" },
    "1": { "value": "0.25rem" },
    "2": { "value": "0.5rem" },
    "3": { "value": "0.75rem" },
    "4": { "value": "1rem" },
    "6": { "value": "1.5rem" },
    "8": { "value": "2rem" },
    "12": { "value": "3rem" },
    "16": { "value": "4rem" }
  },
  "radius": {
    "none": { "value": "0" },
    "sm": { "value": "0.125rem" },
    "md": { "value": "0.375rem" },
    "lg": { "value": "0.5rem" },
    "xl": { "value": "0.75rem" },
    "full": { "value": "9999px" }
  }
}
```

## Generation des tokens

### Style Dictionary

```javascript
// style-dictionary.config.js
module.exports = {
  source: ['tokens/**/*.json'],
  platforms: {
    css: {
      transformGroup: 'css',
      buildPath: 'build/css/',
      files: [{
        destination: 'variables.css',
        format: 'css/variables'
      }]
    },
    typescript: {
      transformGroup: 'js',
      buildPath: 'build/ts/',
      files: [{
        destination: 'tokens.ts',
        format: 'javascript/es6'
      }]
    },
    tailwind: {
      transformGroup: 'js',
      buildPath: 'build/tailwind/',
      files: [{
        destination: 'tailwind.config.js',
        format: 'tailwind'
      }]
    }
  }
};
```

### Output CSS

```css
/* build/css/variables.css */
:root {
  --color-primary: #2563eb;
  --color-secondary: #6b7280;
  --color-success: #10b981;
  --color-warning: #f59e0b;
  --color-error: #ef4444;

  --font-family-sans: Inter, system-ui, sans-serif;
  --font-size-base: 1rem;
  --font-weight-medium: 500;

  --spacing-4: 1rem;
  --spacing-8: 2rem;

  --radius-md: 0.375rem;
}
```

## Structure de composants

### Composant primitif - Button

```typescript
// components/Button/Button.tsx
import { forwardRef } from 'react';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';

const buttonVariants = cva(
  // Base styles
  'inline-flex items-center justify-center rounded-md font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        primary: 'bg-primary text-white hover:bg-primary/90',
        secondary: 'bg-secondary text-white hover:bg-secondary/90',
        outline: 'border border-input bg-background hover:bg-accent',
        ghost: 'hover:bg-accent hover:text-accent-foreground',
        destructive: 'bg-error text-white hover:bg-error/90',
      },
      size: {
        sm: 'h-8 px-3 text-sm',
        md: 'h-10 px-4 text-base',
        lg: 'h-12 px-6 text-lg',
        icon: 'h-10 w-10',
      },
    },
    defaultVariants: {
      variant: 'primary',
      size: 'md',
    },
  }
);

interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  isLoading?: boolean;
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, isLoading, children, ...props }, ref) => {
    return (
      <button
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        disabled={isLoading || props.disabled}
        {...props}
      >
        {isLoading && <Spinner className="mr-2 h-4 w-4" />}
        {children}
      </button>
    );
  }
);

Button.displayName = 'Button';
```

### Documentation Storybook

```typescript
// components/Button/Button.stories.tsx
import type { Meta, StoryObj } from '@storybook/react';
import { Button } from './Button';

const meta: Meta<typeof Button> = {
  title: 'Components/Button',
  component: Button,
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: 'select',
      options: ['primary', 'secondary', 'outline', 'ghost', 'destructive'],
    },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg', 'icon'],
    },
  },
};

export default meta;
type Story = StoryObj<typeof Button>;

export const Primary: Story = {
  args: {
    children: 'Button',
    variant: 'primary',
  },
};

export const Secondary: Story = {
  args: {
    children: 'Button',
    variant: 'secondary',
  },
};

export const AllVariants: Story = {
  render: () => (
    <div className="flex gap-4">
      <Button variant="primary">Primary</Button>
      <Button variant="secondary">Secondary</Button>
      <Button variant="outline">Outline</Button>
      <Button variant="ghost">Ghost</Button>
      <Button variant="destructive">Destructive</Button>
    </div>
  ),
};

export const AllSizes: Story = {
  render: () => (
    <div className="flex items-center gap-4">
      <Button size="sm">Small</Button>
      <Button size="md">Medium</Button>
      <Button size="lg">Large</Button>
    </div>
  ),
};

export const Loading: Story = {
  args: {
    children: 'Loading...',
    isLoading: true,
  },
};
```

## Organisation du projet

```
design-system/
├── tokens/
│   ├── colors.json
│   ├── typography.json
│   └── ...
├── components/
│   ├── primitives/
│   │   ├── Button/
│   │   │   ├── Button.tsx
│   │   │   ├── Button.stories.tsx
│   │   │   ├── Button.test.tsx
│   │   │   └── index.ts
│   │   ├── Input/
│   │   ├── Text/
│   │   └── ...
│   ├── composite/
│   │   ├── Form/
│   │   ├── Modal/
│   │   └── ...
│   └── patterns/
│       ├── AuthForm/
│       └── ...
├── hooks/
│   ├── useTheme.ts
│   └── useBreakpoint.ts
├── utils/
│   ├── cn.ts
│   └── variants.ts
├── .storybook/
└── package.json
```

## Theming

### Theme provider

```typescript
// providers/ThemeProvider.tsx
import { createContext, useContext, useState, useEffect } from 'react';

type Theme = 'light' | 'dark' | 'system';

interface ThemeContextType {
  theme: Theme;
  setTheme: (theme: Theme) => void;
  resolvedTheme: 'light' | 'dark';
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setTheme] = useState<Theme>('system');
  const [resolvedTheme, setResolvedTheme] = useState<'light' | 'dark'>('light');

  useEffect(() => {
    const root = document.documentElement;

    if (theme === 'system') {
      const systemTheme = window.matchMedia('(prefers-color-scheme: dark)').matches
        ? 'dark'
        : 'light';
      setResolvedTheme(systemTheme);
      root.classList.toggle('dark', systemTheme === 'dark');
    } else {
      setResolvedTheme(theme);
      root.classList.toggle('dark', theme === 'dark');
    }
  }, [theme]);

  return (
    <ThemeContext.Provider value={{ theme, setTheme, resolvedTheme }}>
      {children}
    </ThemeContext.Provider>
  );
}

export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (!context) throw new Error('useTheme must be used within ThemeProvider');
  return context;
};
```

## Output attendu

### Audit du design system existant

```markdown
## Audit Design System

### Tokens
- [ ] Couleurs definies et semantiques
- [ ] Typographie complete
- [ ] Espacements coherents
- [ ] Ombres et effets

### Composants
| Composant | Existe | Documente | Teste | A11y |
|-----------|--------|-----------|-------|------|
| Button | [x] | [x] | [ ] | [ ] |
| Input | [x] | [ ] | [ ] | [ ] |
| ...

### Recommandations
1. [Recommandation 1]
2. [Recommandation 2]
```

### Plan de creation

```markdown
## Plan Design System

### Phase 1: Tokens
- Definir la palette de couleurs
- Definir la typographie
- Definir les espacements

### Phase 2: Primitives
- Button, Input, Text, Icon, Badge

### Phase 3: Composites
- Form, Modal, Dropdown, Table

### Phase 4: Documentation
- Storybook
- Guidelines d'usage
```

## Agents lies

| Agent | Usage |
|-------|-------|
| `/dev-component` | Creer des composants |
| `/qa-a11y` | Accessibilite |
| `/doc-generate` | Documentation |

---

IMPORTANT: Les tokens sont la source de verite - jamais de valeurs hardcodees.

IMPORTANT: Chaque composant doit etre accessible (WCAG 2.1 AA).

YOU MUST documenter chaque composant dans Storybook.

NEVER dupliquer des styles - utiliser les tokens.
