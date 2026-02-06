---
sidebar_position: 18
title: "feature-flags"
description: "Gestion de feature flags et toggles. Declencher quand l'utilisateur veut implementer du feature flagging, A/B testing, ou deploiement progressif."
tags:
  - "skill"
  - "fork"
---

# Skill: feature-flags

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Gestion de feature flags et toggles. Declencher quand l'utilisateur veut implementer du feature flagging, A/B testing, ou deploiement progressif.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Write`, `Edit`, `Glob`, `Grep` |
| **Mots-cles** | `feature`, `flags`, `feature flag`, `feature toggle`, `a/b test`, `experimentation`, `deploiement progressif` |

## Description detaillee

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

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux feature..."_
- _"Je veux flags..."_
- _"Je veux feature flag..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Exemples pratiques


### 1. Exemple Feature Flags : Nouveau systeme de paiement

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



---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
