# Agent ANALYTICS

Mise en place du tracking et définition des KPIs pour un projet.

## Contexte
$ARGUMENTS

## Processus de mise en place

### 1. Comprendre les objectifs business

#### Questions clés
- Quel est l'objectif principal du produit ?
- Comment définissez-vous le succès ?
- Quelles décisions devront être prises grâce aux données ?

#### Types d'objectifs
| Type | Exemples |
|------|----------|
| Acquisition | Visiteurs, inscriptions, téléchargements |
| Activation | Onboarding complété, première action clé |
| Rétention | Retour J7, J30, usage mensuel |
| Revenu | Conversion paid, ARPU, LTV |
| Référral | Invitations, partages |

### 2. Définir les KPIs (AARRR Framework)

#### Acquisition
| KPI | Description | Cible |
|-----|-------------|-------|
| Visiteurs uniques | Nombre de visiteurs/mois | |
| Sources de trafic | Répartition par canal | |
| Coût par acquisition (CPA) | Budget / Nouveaux users | |

#### Activation
| KPI | Description | Cible |
|-----|-------------|-------|
| Taux d'inscription | Visiteurs → Inscrits | > X% |
| Onboarding completion | Inscrits → Onboarding fini | > X% |
| Time to value | Temps pour première valeur | < X min |

#### Rétention
| KPI | Description | Cible |
|-----|-------------|-------|
| DAU/MAU | Utilisateurs actifs quotidiens/mensuels | |
| Rétention J1/J7/J30 | % utilisateurs revenus | |
| Churn rate | % utilisateurs perdus/mois | < X% |

#### Revenu
| KPI | Description | Cible |
|-----|-------------|-------|
| Taux de conversion | Free → Paid | > X% |
| MRR/ARR | Revenu récurrent | |
| ARPU | Revenu moyen par utilisateur | |
| LTV | Valeur vie client | > 3× CAC |

#### Referral
| KPI | Description | Cible |
|-----|-------------|-------|
| NPS | Net Promoter Score | > 50 |
| Coefficient viral | Invitations × Conversion | > 1 |
| Taux de partage | % utilisateurs qui partagent | |

### 3. Identifier les événements à tracker

#### Événements standards
```javascript
// Page views
analytics.page('Home');
analytics.page('Pricing');

// Identification
analytics.identify(userId, {
  email: user.email,
  plan: user.plan,
  createdAt: user.createdAt
});
```

#### Événements métier
| Catégorie | Événement | Propriétés |
|-----------|-----------|------------|
| **Auth** | `user_signed_up` | method, source |
| | `user_logged_in` | method |
| | `user_logged_out` | |
| **Onboarding** | `onboarding_started` | |
| | `onboarding_step_completed` | step, step_name |
| | `onboarding_completed` | duration |
| **Core Action** | `[action]_created` | type, properties |
| | `[action]_updated` | |
| | `[action]_deleted` | |
| **Conversion** | `trial_started` | plan |
| | `subscription_created` | plan, price, period |
| | `subscription_cancelled` | reason |
| **Engagement** | `feature_used` | feature_name |
| | `invite_sent` | |
| | `feedback_submitted` | type, rating |

### 4. Plan d'implémentation

#### Choix des outils

| Besoin | Options | Recommandation |
|--------|---------|----------------|
| Analytics produit | Mixpanel, Amplitude, PostHog | PostHog (self-hosted possible) |
| Web analytics | GA4, Plausible, Fathom | Plausible (privacy-friendly) |
| Session replay | Hotjar, FullStory, PostHog | PostHog |
| A/B testing | Optimizely, VWO, GrowthBook | GrowthBook (open source) |
| Error tracking | Sentry, Bugsnag | Sentry |

#### Architecture recommandée
```
┌─────────────────────────────────────────────┐
│                 Application                  │
├─────────────────────────────────────────────┤
│          Analytics Wrapper/SDK               │
├──────────┬──────────┬──────────┬────────────┤
│ PostHog  │ Plausible│  Sentry  │  Custom    │
│ (Produit)│  (Web)   │ (Errors) │    DW      │
└──────────┴──────────┴──────────┴────────────┘
```

### 5. Code d'implémentation

#### Wrapper analytics (exemple)
```typescript
// analytics.ts
interface AnalyticsEvent {
  name: string;
  properties?: Record<string, unknown>;
}

class Analytics {
  track(event: AnalyticsEvent) {
    // PostHog
    posthog?.capture(event.name, event.properties);

    // Autres providers...
  }

  identify(userId: string, traits: Record<string, unknown>) {
    posthog?.identify(userId, traits);
  }

  page(name: string) {
    posthog?.capture('$pageview', { page: name });
  }
}

export const analytics = new Analytics();
```

#### Événements typés (TypeScript)
```typescript
// events.ts
type AnalyticsEvents = {
  user_signed_up: { method: 'email' | 'google' | 'github' };
  onboarding_completed: { duration_seconds: number };
  subscription_created: { plan: string; price: number };
  // ...
};

function track<T extends keyof AnalyticsEvents>(
  event: T,
  properties: AnalyticsEvents[T]
) {
  analytics.track({ name: event, properties });
}
```

### 6. Dashboard et reporting

#### Dashboard principal (North Star + KPIs)
```
┌────────────────────────────────────────────────────┐
│  NORTH STAR METRIC: [Métrique principale]          │
│  ████████████████░░░░ 75% of target                │
├─────────────────┬─────────────────┬────────────────┤
│   ACQUISITION   │   ACTIVATION    │   RETENTION    │
│   +12% ▲        │   68% ▲         │   45% ▼        │
├─────────────────┼─────────────────┼────────────────┤
│     REVENUE     │    REFERRAL     │                │
│   $12,450       │   NPS: 45       │                │
└─────────────────┴─────────────────┴────────────────┘
```

#### Fréquence de reporting
| Fréquence | Métriques |
|-----------|-----------|
| Temps réel | Erreurs, incidents |
| Quotidien | DAU, signups, conversions |
| Hebdomadaire | Tendances, funnel, rétention |
| Mensuel | MRR, LTV, cohort analysis |

### 7. RGPD et privacy

#### Checklist conformité
- [ ] Consentement avant tracking non-essentiel
- [ ] Anonymisation des IPs (GA4)
- [ ] Pas de données personnelles dans les events
- [ ] Droit d'accès et suppression
- [ ] Documentation des traitements

> Pour un audit complet, utiliser `/rgpd`

## Output attendu

### North Star Metric
```
Métrique: [nom]
Définition: [formule/description]
Cible: [valeur]
Fréquence: [mesure]
```

### KPIs par catégorie AARRR
| Catégorie | KPI | Définition | Cible | Outil |
|-----------|-----|------------|-------|-------|
| Acquisition | | | | |
| Activation | | | | |
| Retention | | | | |
| Revenue | | | | |
| Referral | | | | |

### Événements à implémenter
| Événement | Trigger | Propriétés | Priorité |
|-----------|---------|------------|----------|
| | | | Haute |
| | | | Moyenne |
| | | | Basse |

### Stack analytics recommandée
| Besoin | Outil | Coût estimé |
|--------|-------|-------------|
| | | |

### Code d'implémentation
[Snippets de code prêts à l'emploi]

### Dashboards à créer
1. [Dashboard 1] - [Audience]
2. [Dashboard 2] - [Audience]

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/funnel` | Analyser les conversions par étape |
| `/retention` | Mesurer la rétention utilisateurs |
| `/ab-test` | Tester les hypothèses |
| `/rgpd` | S'assurer de la conformité RGPD |
| `/monitoring` | Monitoring technique complémentaire |

---

IMPORTANT: Commencer simple - 5-10 événements clés valent mieux que 100 événements jamais analysés.

YOU MUST définir une North Star Metric unique et alignée avec la valeur business.

NEVER tracker des données personnelles sans consentement - respecter le RGPD.

Think hard sur ce qui drive vraiment la valeur du produit avant de définir les KPIs.
