---
sidebar_position: 23
title: "feature-flags"
description: "Feature flags and toggles management. Trigger when the user wants to implement feature flagging, A/B testing, or progressive deployment."
tags:
  - "skill"
  - "fork"
---

# Skill: feature-flags

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Feature flags and toggles management. Trigger when the user wants to implement feature flagging, A/B testing, or progressive deployment.

## Configuration

| Property | Value |
|-----------|--------|
| **Context** | fork |
| **Allowed tools** | `Read`, `Write`, `Edit`, `Glob`, `Grep` |
| **Keywords** | `feature`, `flags`, `feature flag`, `feature toggle`, `experimentation`, `progressive deployment`, `canary` |

## Detailed description

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
  return newDashboard ? <New />: <Old />;
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

## Automatic triggering

This skill is automatically activated when:
- The matching keywords are detected in the conversation
- The task context matches the skill's domain

### Triggering examples

- _"I want to feature..."_
- _"I want to flags..."_
- _"I want to feature flag..."_

## Context fork


**Fork** means the skill runs in an isolated context:
- Does not pollute the main conversation
- Results are returned cleanly
- Ideal for autonomous tasks


---

## Practical examples


### 1. Feature Flags Example: New payment system

# Feature Flags Example: New payment system

## User request
> "Implement a feature flag to progressively roll out the new payment system"

---

## Analysis

### Context
- New Stripe v2 payment system
- Progressive rollout: 10% -> 50% -> 100%
- Instant rollback if issue
- Tracking metrics

### Strategy
1. Feature flag with percentage
2. User targeting (beta testers)
3. Fallback to old system
4. Performance logging

---

## Implementation

### 1. Flag configuration

```typescript
// src/config/feature-flags.ts

export interface FeatureFlag {
  name: string;
  enabled: boolean;
  percentage?: number;        // Progressive rollout (0-100)
  allowedUsers?: string[];    // Beta testers
  startDate?: Date;           // Scheduled activation
  endDate?: Date;             // Scheduled deactivation
}

export const featureFlags: Record<string, FeatureFlag> = {
  'payment-v2': {
    name: 'New payment system',
    enabled: true,
    percentage: 10,           // 10% of users
    allowedUsers: [
      'beta-tester-1@example.com',
      'beta-tester-2@example.com',
    ],
  },
  'dark-mode': {
    name: 'Dark mode',
    enabled: true,
    percentage: 100,
  },
  'ai-recommendations': {
    name: 'AI recommendations',
    enabled: false,
    startDate: new Date('2024-03-01'),
  },
};
```

### 2. Feature Flag service

```typescript
// src/services/feature-flag.service.ts

import { featureFlags, FeatureFlag } from '../config/feature-flags';
import { createHash } from 'crypto';

export class FeatureFlagService {
  /**
   * Checks whether a feature flag is active for a user
   */
  isEnabled(flagName: string, userId?: string): boolean {
    const flag = featureFlags[flagName];

    if (!flag || !flag.enabled) {
      return false;
    }

    // Date checks
    if (flag.startDate && new Date() < flag.startDate) {
      return false;
    }
    if (flag.endDate && new Date() > flag.endDate) {
      return false;
    }

    // Beta testers always have access
    if (userId && flag.allowedUsers?.includes(userId)) {
      return true;
    }

    // Percentage rollout (deterministic per user)
    if (flag.percentage !== undefined && flag.percentage < 100) {
      if (!userId) return false;
      return this.isInPercentage(flagName, userId, flag.percentage);
    }

    return true;
  }

  /**
   * Determines whether a user is within the rollout percentage
   * Uses a deterministic hash to get consistent results
   */
  private isInPercentage(
    flagName: string,
    userId: string,
    percentage: number
  ): boolean {
    const hash = createHash('md5')
      .update(`${flagName}:${userId}`)
      .digest('hex');
    const hashValue = parseInt(hash.substring(0, 8), 16);
    const userPercentage = hashValue % 100;
    return userPercentage < percentage;
  }

  /**
   * Returns all active flags for a user
   */
  getEnabledFlags(userId?: string): string[] {
    return Object.keys(featureFlags).filter((flagName) =>
      this.isEnabled(flagName, userId)
    );
  }
}

export const featureFlagService = new FeatureFlagService();
```

### 3. React hook for Feature Flags

```typescript
// src/hooks/useFeatureFlag.ts

import { useMemo } from 'react';
import { useUser } from './useUser';
import { featureFlagService } from '../services/feature-flag.service';

export function useFeatureFlag(flagName: string): boolean {
  const { user } = useUser();

  return useMemo(
    () => featureFlagService.isEnabled(flagName, user?.email),
    [flagName, user?.email]
  );
}

// Usage in a component
export function PaymentPage() {
  const useNewPayment = useFeatureFlag('payment-v2');

  if (useNewPayment) {
    return <PaymentV2 />;
  }

  return <PaymentLegacy />;
}
```

### 4. Conditional component

```typescript
// src/components/FeatureGate.tsx

import { ReactNode } from 'react';
import { useFeatureFlag } from '../hooks/useFeatureFlag';

interface FeatureGateProps {
  flag: string;
  children: ReactNode;
  fallback?: ReactNode;
}

export function FeatureGate({ flag, children, fallback = null }: FeatureGateProps) {
  const isEnabled = useFeatureFlag(flag);

  if (!isEnabled) {
    return <>{fallback}</>;
  }

  return <>{children}</>;
}

// Usage
function App() {
  return (
    <FeatureGate flag="payment-v2" fallback={<PaymentLegacy />}>
      <PaymentV2 />
    </FeatureGate>
  );
}
```

---

## Monitoring and Analytics

```typescript
// src/services/feature-flag-analytics.ts

import { analytics } from './analytics';
import { featureFlagService } from './feature-flag.service';

export function trackFeatureFlagExposure(
  flagName: string,
  userId: string,
  isEnabled: boolean
) {
  analytics.track('Feature Flag Exposure', {
    flag_name: flagName,
    user_id: userId,
    is_enabled: isEnabled,
    timestamp: new Date().toISOString(),
  });
}

// In the payment service
export async function processPayment(userId: string, amount: number) {
  const useV2 = featureFlagService.isEnabled('payment-v2', userId);

  // Track exposure
  trackFeatureFlagExposure('payment-v2', userId, useV2);

  if (useV2) {
    return processPaymentV2(userId, amount);
  }

  return processPaymentLegacy(userId, amount);
}
```

---

## Progressive rollout

```typescript
// scripts/rollout-feature.ts

import { featureFlags } from '../src/config/feature-flags';

async function updateRolloutPercentage(flagName: string, percentage: number) {
  const flag = featureFlags[flagName];

  if (!flag) {
    throw new Error(`Flag ${flagName} not found`);
  }

  console.log(`Updating ${flagName}: ${flag.percentage}% -> ${percentage}%`);

  // In production, this would update a DB or remote service
  flag.percentage = percentage;

  // Notify the team
  await notifySlack(`Feature flag "${flagName}" rolled out to ${percentage}%`);
}

// Rollout plan
// Day 1: 10%
// Day 3: 25%
// Day 5: 50%
// Day 7: 100%
```

---

## Tests

```typescript
// src/services/__tests__/feature-flag.service.test.ts

import { FeatureFlagService } from '../feature-flag.service';

describe('FeatureFlagService', () => {
  let service: FeatureFlagService;

  beforeEach(() => {
    service = new FeatureFlagService();
  });

  it('should return false for disabled flag', () => {
    expect(service.isEnabled('ai-recommendations')).toBe(false);
  });

  it('should return true for beta tester', () => {
    expect(
      service.isEnabled('payment-v2', 'beta-tester-1@example.com')
    ).toBe(true);
  });

  it('should be deterministic for percentage rollout', () => {
    const result1 = service.isEnabled('payment-v2', 'user@example.com');
    const result2 = service.isEnabled('payment-v2', 'user@example.com');
    expect(result1).toBe(result2);
  });

  it('should respect percentage distribution', () => {
    // Test with 1000 fictitious users
    let enabledCount = 0;
    for (let i = 0; i < 1000; i++) {
      if (service.isEnabled('payment-v2', `user-${i}@test.com`)) {
        enabledCount++;
      }
    }
    // With 10%, we expect roughly 100 +/- 30
    expect(enabledCount).toBeGreaterThan(70);
    expect(enabledCount).toBeLessThan(130);
  });
});
```

---

## Best practices

1. **Consistent naming**: `domain-feature` (e.g., `payment-v2`, `search-filters`)
2. **Progressive rollout**: 10% -> 25% -> 50% -> 100%
3. **Monitoring**: Track the performance of each variant
4. **Cleanup**: Remove flags after full deployment
5. **Documentation**: Maintain a list of active flags
6. **Fallback**: Always plan a default behavior



---

## See also

- [Back to skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
