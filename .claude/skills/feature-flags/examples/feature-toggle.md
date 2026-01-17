# Exemple Feature Flags : Nouveau systeme de paiement

## Demande utilisateur
> "Implementer un feature flag pour deployer progressivement le nouveau systeme de paiement"

---

## Analyse

### Contexte
- Nouveau systeme de paiement Stripe v2
- Deploiement progressif : 10% -> 50% -> 100%
- Rollback instantane si probleme
- Metriques de suivi

### Strategie
1. Feature flag avec pourcentage
2. Ciblage par utilisateur (beta testers)
3. Fallback sur ancien systeme
4. Logging des performances

---

## Implementation

### 1. Configuration des flags

```typescript
// src/config/feature-flags.ts

export interface FeatureFlag {
  name: string;
  enabled: boolean;
  percentage?: number;        // Rollout progressif (0-100)
  allowedUsers?: string[];    // Beta testers
  startDate?: Date;           // Activation programmee
  endDate?: Date;             // Desactivation programmee
}

export const featureFlags: Record<string, FeatureFlag> = {
  'payment-v2': {
    name: 'Nouveau systeme de paiement',
    enabled: true,
    percentage: 10,           // 10% des utilisateurs
    allowedUsers: [
      'beta-tester-1@example.com',
      'beta-tester-2@example.com',
    ],
  },
  'dark-mode': {
    name: 'Mode sombre',
    enabled: true,
    percentage: 100,
  },
  'ai-recommendations': {
    name: 'Recommandations IA',
    enabled: false,
    startDate: new Date('2024-03-01'),
  },
};
```

### 2. Service de Feature Flags

```typescript
// src/services/feature-flag.service.ts

import { featureFlags, FeatureFlag } from '../config/feature-flags';
import { createHash } from 'crypto';

export class FeatureFlagService {
  /**
   * Verifie si un feature flag est actif pour un utilisateur
   */
  isEnabled(flagName: string, userId?: string): boolean {
    const flag = featureFlags[flagName];

    if (!flag || !flag.enabled) {
      return false;
    }

    // Verification des dates
    if (flag.startDate && new Date() < flag.startDate) {
      return false;
    }
    if (flag.endDate && new Date() > flag.endDate) {
      return false;
    }

    // Beta testers ont toujours acces
    if (userId && flag.allowedUsers?.includes(userId)) {
      return true;
    }

    // Rollout par pourcentage (deterministe par user)
    if (flag.percentage !== undefined && flag.percentage < 100) {
      if (!userId) return false;
      return this.isInPercentage(flagName, userId, flag.percentage);
    }

    return true;
  }

  /**
   * Determine si un utilisateur est dans le pourcentage de rollout
   * Utilise un hash deterministe pour avoir des resultats coherents
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
   * Retourne tous les flags actifs pour un utilisateur
   */
  getEnabledFlags(userId?: string): string[] {
    return Object.keys(featureFlags).filter((flagName) =>
      this.isEnabled(flagName, userId)
    );
  }
}

export const featureFlagService = new FeatureFlagService();
```

### 3. Hook React pour les Feature Flags

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

// Usage dans un composant
export function PaymentPage() {
  const useNewPayment = useFeatureFlag('payment-v2');

  if (useNewPayment) {
    return <PaymentV2 />;
  }

  return <PaymentLegacy />;
}
```

### 4. Composant conditionnel

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

## Monitoring et Analytics

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

// Dans le service de paiement
export async function processPayment(userId: string, amount: number) {
  const useV2 = featureFlagService.isEnabled('payment-v2', userId);

  // Track l'exposition
  trackFeatureFlagExposure('payment-v2', userId, useV2);

  if (useV2) {
    return processPaymentV2(userId, amount);
  }

  return processPaymentLegacy(userId, amount);
}
```

---

## Rollout progressif

```typescript
// scripts/rollout-feature.ts

import { featureFlags } from '../src/config/feature-flags';

async function updateRolloutPercentage(flagName: string, percentage: number) {
  const flag = featureFlags[flagName];

  if (!flag) {
    throw new Error(`Flag ${flagName} not found`);
  }

  console.log(`Updating ${flagName}: ${flag.percentage}% -> ${percentage}%`);

  // En production, cela mettrait a jour une DB ou un service distant
  flag.percentage = percentage;

  // Notifier l'equipe
  await notifySlack(`Feature flag "${flagName}" rolled out to ${percentage}%`);
}

// Plan de rollout
// Jour 1: 10%
// Jour 3: 25%
// Jour 5: 50%
// Jour 7: 100%
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
    // Test avec 1000 utilisateurs fictifs
    let enabledCount = 0;
    for (let i = 0; i < 1000; i++) {
      if (service.isEnabled('payment-v2', `user-${i}@test.com`)) {
        enabledCount++;
      }
    }
    // Avec 10%, on attend environ 100 +/- 30
    expect(enabledCount).toBeGreaterThan(70);
    expect(enabledCount).toBeLessThan(130);
  });
});
```

---

## Bonnes pratiques

1. **Nommage coherent** : `domain-feature` (ex: `payment-v2`, `search-filters`)
2. **Rollout progressif** : 10% -> 25% -> 50% -> 100%
3. **Monitoring** : Tracker les performances de chaque variante
4. **Cleanup** : Supprimer les flags apres deploiement complet
5. **Documentation** : Maintenir une liste des flags actifs
6. **Fallback** : Toujours prevoir un comportement par defaut
