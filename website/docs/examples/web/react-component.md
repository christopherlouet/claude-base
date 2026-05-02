---
sidebar_position: 1
title: React Component
description: Complete React component example with tests and stories
---

# Complete React Component

This example shows how to create a professional React component with TypeScript, tests, and Storybook.

## Command used

```bash
/dev:dev-component "Create a UserCard component with avatar, name and role"
```

## Generated structure

```
src/components/UserCard/
├── UserCard.tsx        # Main component
├── UserCard.test.tsx   # Unit tests
├── UserCard.stories.tsx # Storybook stories
├── UserCard.module.css # Styles (or Tailwind)
└── index.ts            # Export
```

## Component code

### `UserCard.tsx`

```tsx
import { memo } from 'react';
import styles from './UserCard.module.css';

export interface UserCardProps {
  /** Avatar URL */
  avatarUrl: string;
  /** User's full name */
  name: string;
  /** Role or title */
  role: string;
  /** Click callback */
  onClick?: () => void;
  /** Style variant */
  variant?: 'default' | 'compact' | 'detailed';
}

/**
 * User card displaying avatar, name and role.
 *
 * @example
 * ```tsx
 * <UserCard
 *   avatarUrl="/avatars/john.jpg"
 *   name="John Doe"
 *   role="Senior Developer"
 *   onClick={() => navigate(`/users/${id}`)}
 * />
 * ```
 */
export const UserCard = memo(function UserCard({
  avatarUrl,
  name,
  role,
  onClick,
  variant = 'default',
}: UserCardProps) {
  return (
    <article
      className={`${styles.card} ${styles[variant]}`}
      onClick={onClick}
      role={onClick ? 'button' : undefined}
      tabIndex={onClick ? 0 : undefined}
      onKeyDown={(e) => {
        if (onClick && (e.key === 'Enter' || e.key === ' ')) {
          e.preventDefault();
          onClick();
        }
      }}
    >
      <img
        src={avatarUrl}
        alt={`Avatar de ${name}`}
        className={styles.avatar}
        loading="lazy"
      />
      <div className={styles.info}>
        <h3 className={styles.name}>{name}</h3>
        <p className={styles.role}>{role}</p>
      </div>
    </article>
  );
});
```

### `UserCard.module.css`

```css
.card {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  border-radius: 8px;
  background: var(--card-background, #ffffff);
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  transition: box-shadow 0.2s ease;
}

.card[role='button'] {
  cursor: pointer;
}

.card[role='button']:hover,
.card[role='button']:focus {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  outline: none;
}

.card[role='button']:focus-visible {
  outline: 2px solid var(--focus-color, #0066cc);
  outline-offset: 2px;
}

.avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  object-fit: cover;
}

.info {
  flex: 1;
  min-width: 0;
}

.name {
  margin: 0;
  font-size: 1rem;
  font-weight: 600;
  color: var(--text-primary, #1a1a1a);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.role {
  margin: 0.25rem 0 0;
  font-size: 0.875rem;
  color: var(--text-secondary, #666666);
}

/* Compact variant */
.compact {
  padding: 0.5rem;
  gap: 0.75rem;
}

.compact .avatar {
  width: 32px;
  height: 32px;
}

.compact .name {
  font-size: 0.875rem;
}

.compact .role {
  font-size: 0.75rem;
}

/* Detailed variant */
.detailed {
  flex-direction: column;
  text-align: center;
  padding: 1.5rem;
}

.detailed .avatar {
  width: 80px;
  height: 80px;
}
```

### `UserCard.test.tsx`

```tsx
import { render, screen, fireEvent } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { UserCard } from './UserCard';

describe('UserCard', () => {
  const defaultProps = {
    avatarUrl: '/avatar.jpg',
    name: 'John Doe',
    role: 'Developer',
  };

  it('renders user information correctly', () => {
    render(<UserCard {...defaultProps} />);

    expect(screen.getByRole('img')).toHaveAttribute(
      'alt',
      'Avatar de John Doe'
    );
    expect(screen.getByText('John Doe')).toBeInTheDocument();
    expect(screen.getByText('Developer')).toBeInTheDocument();
  });

  it('is clickable when onClick is provided', async () => {
    const handleClick = jest.fn();
    render(<UserCard {...defaultProps} onClick={handleClick} />);

    const card = screen.getByRole('button');
    await userEvent.click(card);

    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('supports keyboard navigation', async () => {
    const handleClick = jest.fn();
    render(<UserCard {...defaultProps} onClick={handleClick} />);

    const card = screen.getByRole('button');
    card.focus();
    await userEvent.keyboard('{Enter}');

    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('is not clickable without onClick', () => {
    render(<UserCard {...defaultProps} />);

    expect(screen.queryByRole('button')).not.toBeInTheDocument();
  });

  it('applies variant classes correctly', () => {
    const { rerender } = render(
      <UserCard {...defaultProps} variant="compact" />
    );

    expect(screen.getByRole('article')).toHaveClass('compact');

    rerender(<UserCard {...defaultProps} variant="detailed" />);
    expect(screen.getByRole('article')).toHaveClass('detailed');
  });
});
```

### `UserCard.stories.tsx`

```tsx
import type { Meta, StoryObj } from '@storybook/react';
import { UserCard } from './UserCard';

const meta: Meta<typeof UserCard> = {
  title: 'Components/UserCard',
  component: UserCard,
  tags: ['autodocs'],
  argTypes: {
    onClick: { action: 'clicked' },
    variant: {
      control: 'select',
      options: ['default', 'compact', 'detailed'],
    },
  },
};

export default meta;
type Story = StoryObj<typeof UserCard>;

export const Default: Story = {
  args: {
    avatarUrl: 'https://i.pravatar.cc/150?u=john',
    name: 'John Doe',
    role: 'Senior Developer',
  },
};

export const Clickable: Story = {
  args: {
    ...Default.args,
    onClick: () => alert('Clicked!'),
  },
};

export const Compact: Story = {
  args: {
    ...Default.args,
    variant: 'compact',
  },
};

export const Detailed: Story = {
  args: {
    ...Default.args,
    variant: 'detailed',
  },
};

export const LongName: Story = {
  args: {
    avatarUrl: 'https://i.pravatar.cc/150?u=long',
    name: 'Jean-Pierre de la Montagne du Nord',
    role: 'Principal Software Architect',
  },
};
```

### `index.ts`

```ts
export { UserCard } from './UserCard';
export type { UserCardProps } from './UserCard';
```

## Key points

| Aspect | Implementation |
|--------|----------------|
| **TypeScript** | Typed props with exported interface |
| **Accessibility** | `role="button"`, keyboard navigation, alt text |
| **Performance** | `memo()` to avoid unnecessary re-renders |
| **Tests** | Coverage of interactions and variants |
| **Storybook** | Interactive visual documentation |

## Related commands

- `/dev:dev-test` - Generate more tests
- `/qa:wcag-audit` - Verify accessibility
- `/doc:doc-generate` - Generate API documentation

---

:::tip Tailwind variants
If you use Tailwind CSS, ask Claude to generate the Tailwind version:
```bash
/dev:dev-component "Create UserCard with Tailwind CSS"
```
:::
