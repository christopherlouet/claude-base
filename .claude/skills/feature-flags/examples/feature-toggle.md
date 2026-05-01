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
