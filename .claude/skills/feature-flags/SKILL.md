---
name: feature-flags
description: Gestion de feature flags et toggles. Declencher quand l'utilisateur veut implementer du feature flagging, A/B testing, ou deploiement progressif.
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
context: fork
---

# Feature Flags Skill

## Declencheurs

Ce skill s'active quand l'utilisateur mentionne:
- "feature flag", "feature toggle"
- "A/B test", "experimentation"
- "deploiement progressif", "canary"
- "activer/desactiver une feature"

## Cas d'usage

| Use case | Description |
|----------|-------------|
| **Release toggles** | Deployer du code inactif |
| **Experiment toggles** | A/B testing |
| **Ops toggles** | Circuit breakers |
| **Permission toggles** | Features par role/plan |

## Solutions

| Solution | Type | Avantages |
|----------|------|-----------|
| **LaunchDarkly** | SaaS | Complet, targeting avance |
| **Unleash** | Self-hosted | Open source, gratuit |
| **ConfigCat** | SaaS | Simple, genereux free tier |
| **Custom** | DIY | Controle total |

## Implementation simple

### Configuration

```typescript
// lib/features.ts
type FeatureFlags = {
  newDashboard: boolean;
  darkMode: boolean;
  betaFeatures: boolean;
};

const defaultFlags: FeatureFlags = {
  newDashboard: false,
  darkMode: true,
  betaFeatures: false,
};

export function getFeatureFlags(userId?: string): FeatureFlags {
  // En production: fetch depuis service
  if (process.env.NODE_ENV === 'development') {
    return {
      ...defaultFlags,
      newDashboard: true,
      betaFeatures: true,
    };
  }

  return defaultFlags;
}

export function isFeatureEnabled(
  flag: keyof FeatureFlags,
  userId?: string
): boolean {
  const flags = getFeatureFlags(userId);
  return flags[flag];
}
```

### Hook React

```typescript
// hooks/useFeatureFlag.ts
import { useEffect, useState } from 'react';
import { isFeatureEnabled } from '@/lib/features';
import { useUser } from './useUser';

export function useFeatureFlag(flag: string): boolean {
  const { user } = useUser();
  const [enabled, setEnabled] = useState(false);

  useEffect(() => {
    setEnabled(isFeatureEnabled(flag, user?.id));
  }, [flag, user?.id]);

  return enabled;
}
```

### Utilisation

```tsx
// components/Dashboard.tsx
import { useFeatureFlag } from '@/hooks/useFeatureFlag';

export function Dashboard() {
  const showNewDashboard = useFeatureFlag('newDashboard');

  if (showNewDashboard) {
    return <NewDashboard />;
  }

  return <LegacyDashboard />;
}
```

## Avec LaunchDarkly

```typescript
// lib/launchdarkly.ts
import * as LaunchDarkly from 'launchdarkly-node-server-sdk';

const client = LaunchDarkly.init(process.env.LAUNCHDARKLY_SDK_KEY!);

export async function getFlag(
  flagKey: string,
  user: { key: string; email?: string },
  defaultValue: boolean = false
): Promise<boolean> {
  await client.waitForInitialization();
  return client.variation(flagKey, user, defaultValue);
}
```

```tsx
// Client React
import { useFlags } from 'launchdarkly-react-client-sdk';

function Component() {
  const { newDashboard } = useFlags();
  return newDashboard ? <New /> : <Old />;
}
```

## Bonnes pratiques

### Nommage

```
# Format: <scope>_<feature>_<variant>
dashboard_new_layout
checkout_express_enabled
user_profile_v2
```

### Lifecycle

```
1. Create flag (disabled)
2. Deploy code behind flag
3. Enable for internal users
4. Gradual rollout (10% → 50% → 100%)
5. Remove flag + old code
```

### Targeting

```typescript
// Regles de targeting
const rules = [
  { attribute: 'email', operator: 'endsWith', value: '@company.com', enabled: true },
  { attribute: 'plan', operator: 'equals', value: 'enterprise', enabled: true },
  { attribute: 'userId', operator: 'inList', value: betaUserIds, enabled: true },
  { attribute: 'percentage', operator: 'lessThan', value: 10, enabled: true },
];
```

## Regles

IMPORTANT: Toujours avoir une valeur par defaut (flag off).

IMPORTANT: Supprimer les flags obsoletes (dette technique).

YOU MUST logger les evaluations de flags pour le debugging.

NEVER stocker de logique metier complexe dans les flags.

NEVER laisser des flags en production plus de 2 sprints apres rollout complet.
