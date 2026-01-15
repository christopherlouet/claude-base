# Agent RETENTION

Analyse et améliore la rétention utilisateur avec des stratégies data-driven.

## Cible
$ARGUMENTS

## Objectif

Identifier les facteurs de churn, améliorer l'engagement et mettre en place
des mécanismes pour maximiser la rétention à long terme.

## Stratégie de rétention

```
┌─────────────────────────────────────────────────────────────┐
│                    RETENTION STRATEGY                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. MESURER       → Définir et tracker les métriques       │
│  ══════════                                                 │
│                                                             │
│  2. ANALYSER      → Identifier patterns de churn           │
│  ══════════                                                 │
│                                                             │
│  3. SEGMENTER     → Cohortes et comportements              │
│  ════════════                                               │
│                                                             │
│  4. ENGAGER       → Stratégies de ré-engagement            │
│  ══════════                                                 │
│                                                             │
│  5. OPTIMISER     → Tests et itérations                    │
│  ═══════════                                                │
│                                                             │
│  6. FIDÉLISER     → Programmes de loyalty                  │
│  ═══════════                                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Étape 1 : Métriques de rétention

### KPIs essentiels

| Métrique | Formule | Benchmark SaaS |
|----------|---------|----------------|
| **Retention Rate** | (Users fin - Nouveaux) / Users début × 100 | 85-95% mensuel |
| **Churn Rate** | Users perdus / Users début × 100 | 3-8% mensuel |
| **DAU/MAU Ratio** | Daily Active / Monthly Active × 100 | 20-30% |
| **NRR (Net Revenue Retention)** | (MRR fin + Expansion - Churn) / MRR début × 100 | >100% |
| **Customer Lifetime Value** | ARPU × (1 / Churn Rate) | Variable |

### Courbes de rétention

```
┌─────────────────────────────────────────────────────────────┐
│                    RETENTION CURVES                          │
├─────────────────────────────────────────────────────────────┤
│  100% ┤                                                     │
│       │ ●                                                   │
│   80% ┤  ●                                                  │
│       │   ●                                                 │
│   60% ┤    ●                                                │
│       │     ● ─ ─ ● ─ ─ ● ─ ─ ● ← Bonne rétention          │
│   40% ┤      ●                                              │
│       │       ●                                             │
│   20% ┤        ● ─ ─ ● ─ ─ ● ─ ─ ● ← Problème              │
│       │                                                     │
│    0% └─────┬─────┬─────┬─────┬─────┬─────→                │
│             D1    D7    D14   D30   D60   Jours            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Implémentation du tracking

```typescript
// src/analytics/retention.ts
import { analytics } from './client';

interface RetentionEvent {
  userId: string;
  event: string;
  timestamp: Date;
  properties?: Record<string, unknown>;
}

// Événements clés à tracker
export const RETENTION_EVENTS = {
  // Activation
  SIGNUP_COMPLETED: 'signup_completed',
  ONBOARDING_STARTED: 'onboarding_started',
  ONBOARDING_COMPLETED: 'onboarding_completed',
  FIRST_VALUE_MOMENT: 'first_value_moment',

  // Engagement
  FEATURE_USED: 'feature_used',
  SESSION_STARTED: 'session_started',
  CORE_ACTION_COMPLETED: 'core_action_completed',

  // Rétention
  RETURN_VISIT: 'return_visit',
  STREAK_MILESTONE: 'streak_milestone',

  // Expansion
  UPGRADE_INITIATED: 'upgrade_initiated',
  FEATURE_UNLOCKED: 'feature_unlocked',

  // Churn signals
  INACTIVITY_WARNING: 'inactivity_warning',
  DOWNGRADE_INITIATED: 'downgrade_initiated',
  CANCELLATION_INITIATED: 'cancellation_initiated',
};

export function trackRetentionEvent(event: RetentionEvent): void {
  analytics.track({
    userId: event.userId,
    event: event.event,
    timestamp: event.timestamp,
    properties: {
      ...event.properties,
      daysSinceSignup: calculateDaysSinceSignup(event.userId),
      cohort: getCohort(event.userId),
      plan: getUserPlan(event.userId),
    },
  });
}

// Calcul de la rétention par cohorte
export async function calculateCohortRetention(
  cohortDate: Date,
  periods: number[] = [1, 7, 14, 30, 60, 90]
): Promise<Record<number, number>> {
  const cohortUsers = await getUsersInCohort(cohortDate);
  const totalUsers = cohortUsers.length;

  const retention: Record<number, number> = {};

  for (const period of periods) {
    const activeUsers = await countActiveUsersAfterDays(cohortUsers, period);
    retention[period] = (activeUsers / totalUsers) * 100;
  }

  return retention;
}
```

## Étape 2 : Analyse du churn

### Indicateurs prédictifs

```typescript
// src/services/churnPrediction.ts
interface ChurnIndicator {
  name: string;
  weight: number;
  threshold: number;
  currentValue: number;
}

interface ChurnRiskScore {
  userId: string;
  score: number; // 0-100
  riskLevel: 'low' | 'medium' | 'high' | 'critical';
  indicators: ChurnIndicator[];
  suggestedActions: string[];
}

export async function calculateChurnRisk(userId: string): Promise<ChurnRiskScore> {
  const user = await getUser(userId);
  const activity = await getUserActivity(userId, 30); // 30 derniers jours

  const indicators: ChurnIndicator[] = [
    {
      name: 'login_frequency',
      weight: 25,
      threshold: 5, // logins par semaine
      currentValue: activity.weeklyLogins,
    },
    {
      name: 'feature_usage',
      weight: 20,
      threshold: 3, // features différentes utilisées
      currentValue: activity.uniqueFeaturesUsed,
    },
    {
      name: 'session_duration',
      weight: 15,
      threshold: 300, // secondes
      currentValue: activity.avgSessionDuration,
    },
    {
      name: 'support_tickets',
      weight: 15,
      threshold: 2, // tickets ouverts
      currentValue: activity.openTickets,
    },
    {
      name: 'days_since_last_login',
      weight: 25,
      threshold: 7,
      currentValue: activity.daysSinceLastLogin,
    },
  ];

  // Calculer le score
  let totalScore = 0;
  for (const indicator of indicators) {
    const ratio = indicator.currentValue / indicator.threshold;
    const normalizedScore = Math.min(ratio, 1) * indicator.weight;

    // Inverser pour certains indicateurs (plus c'est haut, plus c'est risqué)
    if (['support_tickets', 'days_since_last_login'].includes(indicator.name)) {
      totalScore += indicator.weight - normalizedScore;
    } else {
      totalScore += normalizedScore;
    }
  }

  // Normaliser sur 100 et inverser (100 = haut risque)
  const riskScore = 100 - totalScore;

  return {
    userId,
    score: riskScore,
    riskLevel: getRiskLevel(riskScore),
    indicators,
    suggestedActions: getSuggestedActions(riskScore, indicators),
  };
}

function getRiskLevel(score: number): ChurnRiskScore['riskLevel'] {
  if (score < 25) return 'low';
  if (score < 50) return 'medium';
  if (score < 75) return 'high';
  return 'critical';
}

function getSuggestedActions(score: number, indicators: ChurnIndicator[]): string[] {
  const actions: string[] = [];

  // Trouver les indicateurs problématiques
  for (const indicator of indicators) {
    const ratio = indicator.currentValue / indicator.threshold;

    if (indicator.name === 'days_since_last_login' && ratio > 1) {
      actions.push('Envoyer email de ré-engagement');
    }
    if (indicator.name === 'feature_usage' && ratio < 0.5) {
      actions.push('Proposer tutoriel des fonctionnalités');
    }
    if (indicator.name === 'support_tickets' && ratio > 1) {
      actions.push('Escalade au customer success');
    }
  }

  if (score > 75) {
    actions.push('Appel proactif du customer success');
    actions.push('Proposer offre de rétention');
  }

  return actions;
}
```

### Dashboard de churn

```markdown
## Churn Dashboard

### Vue d'ensemble (30 derniers jours)
| Métrique | Valeur | Trend | Target |
|----------|--------|-------|--------|
| Churn Rate | 4.2% | ↓ 0.3% | < 5% |
| At-Risk Users | 127 | ↑ 15 | - |
| Churned Revenue | $12,450 | ↓ $2,100 | - |
| Save Rate | 35% | ↑ 5% | > 30% |

### Top raisons de churn
| Raison | % | Action |
|--------|---|--------|
| Prix trop élevé | 32% | Review pricing |
| Feature manquante | 24% | Roadmap communication |
| Pas assez utilisé | 21% | Improve onboarding |
| Concurrent | 15% | Competitive analysis |
| Autre | 8% | - |

### Users à risque par segment
| Segment | Count | Avg Risk Score |
|---------|-------|----------------|
| Enterprise | 12 | 62 |
| Pro | 45 | 58 |
| Starter | 70 | 71 |
```

## Étape 3 : Segmentation des cohortes

### Définition des segments

```typescript
// src/services/cohortSegmentation.ts
interface UserSegment {
  id: string;
  name: string;
  criteria: SegmentCriteria;
  retentionRate: number;
  avgLifetime: number;
  ltv: number;
}

interface SegmentCriteria {
  signupDateRange?: { from: Date; to: Date };
  plan?: string[];
  activityLevel?: 'power' | 'regular' | 'casual' | 'dormant';
  acquisitionChannel?: string[];
  industry?: string[];
  companySize?: string[];
}

// Segments prédéfinis
export const SEGMENTS: UserSegment[] = [
  {
    id: 'power_users',
    name: 'Power Users',
    criteria: {
      activityLevel: 'power',
    },
    retentionRate: 95,
    avgLifetime: 24, // mois
    ltv: 2400,
  },
  {
    id: 'at_risk',
    name: 'At Risk',
    criteria: {
      activityLevel: 'dormant',
    },
    retentionRate: 40,
    avgLifetime: 3,
    ltv: 150,
  },
  // ...
];

// Analyse par cohorte d'acquisition
export async function analyzeAcquisitionCohorts(): Promise<CohortAnalysis[]> {
  const channels = ['organic', 'paid', 'referral', 'content'];
  const results: CohortAnalysis[] = [];

  for (const channel of channels) {
    const users = await getUsersByChannel(channel);
    const retention = await calculateRetentionCurve(users);
    const avgLTV = await calculateAverageLTV(users);

    results.push({
      channel,
      userCount: users.length,
      retention,
      avgLTV,
      d30Retention: retention[30],
      d90Retention: retention[90],
    });
  }

  return results.sort((a, b) => b.d90Retention - a.d90Retention);
}
```

### Analyse comportementale

```typescript
// src/services/behaviorAnalysis.ts
interface BehaviorPattern {
  pattern: string;
  userCount: number;
  retentionRate: number;
  conversionRate: number;
  correlation: number;
}

// Identifier les comportements corrélés à la rétention
export async function findRetentionCorrelations(): Promise<BehaviorPattern[]> {
  const patterns: BehaviorPattern[] = [];

  // Analyser différentes actions
  const actionsToAnalyze = [
    'completed_onboarding',
    'invited_team_member',
    'connected_integration',
    'created_first_project',
    'exported_data',
    'used_advanced_feature',
  ];

  for (const action of actionsToAnalyze) {
    const usersWithAction = await getUsersWhoCompleted(action, 7); // dans les 7 premiers jours
    const usersWithoutAction = await getUsersWhoDidNotComplete(action, 7);

    const retentionWith = await calculate90DayRetention(usersWithAction);
    const retentionWithout = await calculate90DayRetention(usersWithoutAction);

    patterns.push({
      pattern: action,
      userCount: usersWithAction.length,
      retentionRate: retentionWith,
      conversionRate: usersWithAction.length / (usersWithAction.length + usersWithoutAction.length),
      correlation: retentionWith - retentionWithout,
    });
  }

  // Trier par corrélation
  return patterns.sort((a, b) => b.correlation - a.correlation);
}

// Résultat exemple:
// [
//   { pattern: 'invited_team_member', correlation: +45% },
//   { pattern: 'connected_integration', correlation: +38% },
//   { pattern: 'created_first_project', correlation: +32% },
//   ...
// ]
```

## Étape 4 : Stratégies de ré-engagement

### Emails automatisés

```typescript
// src/services/reengagement.ts
interface ReengagementCampaign {
  trigger: string;
  delay: number; // jours
  template: string;
  channel: 'email' | 'push' | 'in-app';
  personalization: Record<string, string>;
}

export const REENGAGEMENT_CAMPAIGNS: ReengagementCampaign[] = [
  // Inactivité légère
  {
    trigger: 'no_login_7_days',
    delay: 7,
    template: 'we_miss_you',
    channel: 'email',
    personalization: {
      subject: '{{firstName}}, votre projet vous attend',
      cta: 'Reprendre là où vous en étiez',
    },
  },
  // Inactivité moyenne
  {
    trigger: 'no_login_14_days',
    delay: 14,
    template: 'whats_new',
    channel: 'email',
    personalization: {
      subject: 'Nouveautés que vous avez manquées',
      cta: 'Découvrir les nouvelles fonctionnalités',
    },
  },
  // Inactivité importante
  {
    trigger: 'no_login_30_days',
    delay: 30,
    template: 'special_offer',
    channel: 'email',
    personalization: {
      subject: '{{firstName}}, un mois gratuit pour revenir',
      cta: 'Activer mon offre',
    },
  },
  // Avant expiration trial
  {
    trigger: 'trial_ending_3_days',
    delay: 0,
    template: 'trial_ending',
    channel: 'email',
    personalization: {
      subject: 'Votre essai se termine dans 3 jours',
      cta: 'Passer au plan payant',
    },
  },
];

// Processeur de campagnes
export async function processReengagement(): Promise<void> {
  for (const campaign of REENGAGEMENT_CAMPAIGNS) {
    const eligibleUsers = await findEligibleUsers(campaign.trigger);

    for (const user of eligibleUsers) {
      // Vérifier si déjà contacté récemment
      if (await wasContactedRecently(user.id, campaign.channel, 3)) {
        continue;
      }

      await sendReengagementMessage({
        userId: user.id,
        campaign,
        personalization: {
          ...campaign.personalization,
          firstName: user.firstName,
          lastProject: user.lastProject?.name,
        },
      });

      await trackReengagementSent(user.id, campaign);
    }
  }
}
```

### Notifications in-app

```typescript
// src/components/RetentionPrompts.tsx
import React from 'react';

interface RetentionPrompt {
  id: string;
  type: 'feature_discovery' | 'milestone' | 'streak' | 'social_proof';
  content: {
    title: string;
    body: string;
    cta: string;
    image?: string;
  };
  trigger: {
    event: string;
    conditions: Record<string, unknown>;
  };
}

export const RETENTION_PROMPTS: RetentionPrompt[] = [
  {
    id: 'discover_integrations',
    type: 'feature_discovery',
    content: {
      title: 'Connectez vos outils',
      body: 'Les utilisateurs avec des intégrations sont 3x plus actifs',
      cta: 'Voir les intégrations',
    },
    trigger: {
      event: 'session_5',
      conditions: { hasIntegrations: false },
    },
  },
  {
    id: 'streak_3_days',
    type: 'streak',
    content: {
      title: 'Série de 3 jours !',
      body: 'Continuez demain pour débloquer un badge',
      cta: 'Voir mes badges',
    },
    trigger: {
      event: 'login',
      conditions: { streakDays: 3 },
    },
  },
  {
    id: 'social_proof',
    type: 'social_proof',
    content: {
      title: '10,000 projets créés cette semaine',
      body: 'Rejoignez la communauté qui construit',
      cta: 'Créer un projet',
    },
    trigger: {
      event: 'dashboard_view',
      conditions: { projectCount: 0 },
    },
  },
];

// Hook pour afficher les prompts
export function useRetentionPrompts(user: User): RetentionPrompt | null {
  const [activePrompt, setActivePrompt] = useState<RetentionPrompt | null>(null);

  useEffect(() => {
    const checkPrompts = async () => {
      for (const prompt of RETENTION_PROMPTS) {
        if (await shouldShowPrompt(user, prompt)) {
          if (!await wasPromptDismissed(user.id, prompt.id)) {
            setActivePrompt(prompt);
            return;
          }
        }
      }
    };

    checkPrompts();
  }, [user]);

  return activePrompt;
}
```

## Étape 5 : Programme de fidélité

### Gamification

```typescript
// src/services/gamification.ts
interface Achievement {
  id: string;
  name: string;
  description: string;
  icon: string;
  points: number;
  criteria: {
    event: string;
    count: number;
  };
  rarity: 'common' | 'rare' | 'epic' | 'legendary';
}

export const ACHIEVEMENTS: Achievement[] = [
  {
    id: 'first_project',
    name: 'Pionnier',
    description: 'Créer votre premier projet',
    icon: '🚀',
    points: 10,
    criteria: { event: 'project_created', count: 1 },
    rarity: 'common',
  },
  {
    id: 'power_user',
    name: 'Power User',
    description: 'Connectez-vous 30 jours consécutifs',
    icon: '⚡',
    points: 100,
    criteria: { event: 'login_streak', count: 30 },
    rarity: 'epic',
  },
  {
    id: 'team_builder',
    name: 'Team Builder',
    description: 'Invitez 10 membres dans votre équipe',
    icon: '👥',
    points: 50,
    criteria: { event: 'team_member_invited', count: 10 },
    rarity: 'rare',
  },
  {
    id: 'integration_master',
    name: 'Maître des Intégrations',
    description: 'Connectez 5 intégrations différentes',
    icon: '🔗',
    points: 75,
    criteria: { event: 'integration_connected', count: 5 },
    rarity: 'rare',
  },
];

// Vérifier et attribuer les achievements
export async function checkAchievements(userId: string, event: string): Promise<Achievement[]> {
  const newAchievements: Achievement[] = [];
  const userAchievements = await getUserAchievements(userId);

  for (const achievement of ACHIEVEMENTS) {
    // Skip si déjà obtenu
    if (userAchievements.includes(achievement.id)) continue;

    // Vérifier le critère
    if (achievement.criteria.event === event) {
      const count = await getEventCount(userId, event);

      if (count >= achievement.criteria.count) {
        await grantAchievement(userId, achievement.id);
        await addPoints(userId, achievement.points);
        newAchievements.push(achievement);

        // Notification
        await notifyAchievement(userId, achievement);
      }
    }
  }

  return newAchievements;
}
```

### Programme de rewards

```typescript
// src/services/rewards.ts
interface RewardTier {
  name: string;
  minPoints: number;
  benefits: string[];
  badge: string;
}

export const REWARD_TIERS: RewardTier[] = [
  {
    name: 'Bronze',
    minPoints: 0,
    benefits: ['Accès basique'],
    badge: '🥉',
  },
  {
    name: 'Silver',
    minPoints: 100,
    benefits: ['Support prioritaire', '10% réduction'],
    badge: '🥈',
  },
  {
    name: 'Gold',
    minPoints: 500,
    benefits: ['Support VIP', '20% réduction', 'Accès beta'],
    badge: '🥇',
  },
  {
    name: 'Platinum',
    minPoints: 1000,
    benefits: ['Account manager dédié', '30% réduction', 'Features exclusives'],
    badge: '💎',
  },
];

export function getUserTier(points: number): RewardTier {
  return REWARD_TIERS.reduce((current, tier) => {
    return points >= tier.minPoints ? tier : current;
  }, REWARD_TIERS[0]);
}
```

## Output attendu

```markdown
## Retention Analysis Report

### Métriques actuelles
| Période | Retention | Benchmark | Status |
|---------|-----------|-----------|--------|
| D1 | 75% | 70% | ✅ |
| D7 | 45% | 40% | ✅ |
| D30 | 28% | 30% | ⚠️ |
| D90 | 18% | 20% | ⚠️ |

### Segments à risque
| Segment | Users | Churn Risk | Action recommandée |
|---------|-------|------------|-------------------|
| Trial no-convert | 234 | 85% | Email série conversion |
| Dormant Pro | 89 | 72% | Outreach CS |
| Low engagement | 156 | 65% | Feature discovery |

### Corrélations identifiées
| Action (J1-J7) | Impact D30 Retention |
|----------------|---------------------|
| Invite team member | +45% |
| Connect integration | +38% |
| Complete onboarding | +32% |

### Plan d'action
1. [ ] Implémenter emails ré-engagement
2. [ ] Ajouter gamification (achievements)
3. [ ] Créer dashboard CS pour at-risk users
4. [ ] A/B test offres de rétention
```

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/analytics` | Configurer le tracking |
| `/onboarding` | Améliorer activation |
| `/email` | Campagnes ré-engagement |
| `/ab-test` | Tester stratégies |
| `/funnel` | Analyser conversions |

---

IMPORTANT: La rétention se joue dès l'onboarding. Les 7 premiers jours sont critiques.

YOU MUST tracker les indicateurs de churn pour agir proactivement.

YOU MUST personnaliser les stratégies par segment.

NEVER ignorer les signaux de désengagement.

Think hard sur le "Aha moment" qui convertit les users en users fidèles.
