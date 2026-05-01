---
name: feature-flags
description: Feature flags and toggles management. Trigger when the user wants to implement feature flagging, A/B testing, or progressive deployment.
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
context: fork
user-invocable: false
---

# Feature Flags Skill

## Triggers

This skill activates when the user mentions:
- "feature flag", "feature toggle"
- "A/B test", "experimentation"
- "progressive deployment", "canary"
- "enable/disable a feature"

## Use cases

| Use case | Description |
|----------|-------------|
| **Release toggles** | Deploy inactive code |
| **Experiment toggles** | A/B testing |
| **Ops toggles** | Circuit breakers |
| **Permission toggles** | Features by role/plan |

## Solutions

| Solution | Type | Advantages |
|----------|------|-----------|
| **LaunchDarkly** | SaaS | Complete, advanced targeting |
| **Unleash** | Self-hosted | Open source, free |
| **ConfigCat** | SaaS | Simple, generous free tier |
| **Custom** | DIY | Full control |

## Simple implementation

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
  // In production: fetch from service
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

### React hook

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

### Usage

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

## With LaunchDarkly

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
// React client
import { useFlags } from 'launchdarkly-react-client-sdk';

function Component() {
  const { newDashboard } = useFlags();
  return newDashboard ? <New /> : <Old />;
}
```

## Best practices

### Naming

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
// Targeting rules
const rules = [
  { attribute: 'email', operator: 'endsWith', value: '@company.com', enabled: true },
  { attribute: 'plan', operator: 'equals', value: 'enterprise', enabled: true },
  { attribute: 'userId', operator: 'inList', value: betaUserIds, enabled: true },
  { attribute: 'percentage', operator: 'lessThan', value: 10, enabled: true },
];
```

## Rules

IMPORTANT: Always have a default value (flag off).

IMPORTANT: Remove obsolete flags (technical debt).

YOU MUST log flag evaluations for debugging.

NEVER store complex business logic in flags.

NEVER leave flags in production more than 2 sprints after full rollout.
