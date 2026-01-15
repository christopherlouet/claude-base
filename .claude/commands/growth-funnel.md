# Agent FUNNEL

Analyse et optimise les funnels de conversion pour maximiser les taux de conversion.

## Funnel à analyser
$ARGUMENTS

## Objectif

Identifier les points de friction dans le parcours utilisateur et optimiser
chaque étape pour améliorer le taux de conversion global.

## Méthodologie d'analyse

```
┌─────────────────────────────────────────────────────────────┐
│                    FUNNEL OPTIMIZATION                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. MAPPER        → Définir les étapes du funnel           │
│  ══════════                                                 │
│                                                             │
│  2. MESURER       → Collecter données de conversion        │
│  ══════════                                                 │
│                                                             │
│  3. ANALYSER      → Identifier les drop-offs               │
│  ══════════                                                 │
│                                                             │
│  4. DIAGNOSTIQUER → Comprendre les causes                  │
│  ═════════════                                              │
│                                                             │
│  5. OPTIMISER     → Implémenter des améliorations          │
│  ═══════════                                                │
│                                                             │
│  6. ITÉRER        → Mesurer et répéter                     │
│  ══════════                                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Types de funnels

### Funnel d'acquisition (AARRR)

```
┌─────────────────────────────────────────────────────────────┐
│                    PIRATE METRICS (AARRR)                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ACQUISITION    → Comment les users arrivent               │
│  ════════════      Métriques: Visits, Sources              │
│       ↓                                                    │
│  ACTIVATION     → Première expérience de valeur            │
│  ════════════      Métriques: Signup, Onboarding complete  │
│       ↓                                                    │
│  RETENTION      → Les users reviennent                     │
│  ═══════════       Métriques: DAU/MAU, Return rate         │
│       ↓                                                    │
│  REVENUE        → Les users paient                         │
│  ══════════        Métriques: Conversion, ARPU             │
│       ↓                                                    │
│  REFERRAL       → Les users recommandent                   │
│  ══════════        Métriques: NPS, Referrals               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Funnel de signup

```
┌─────────────────────────────────────────────────────────────┐
│                    SIGNUP FUNNEL                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Landing Page   ──────────────────→ 100%                   │
│       ↓ [XX%]                                              │
│  CTA Click      ──────────────────→ XX%                    │
│       ↓ [XX%]                                              │
│  Form Start     ──────────────────→ XX%                    │
│       ↓ [XX%]                                              │
│  Form Complete  ──────────────────→ XX%                    │
│       ↓ [XX%]                                              │
│  Email Verified ──────────────────→ XX%                    │
│       ↓ [XX%]                                              │
│  Onboarding Done ─────────────────→ XX%                    │
│       ↓ [XX%]                                              │
│  First Value    ──────────────────→ XX%                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Funnel d'achat e-commerce

```
┌─────────────────────────────────────────────────────────────┐
│                    E-COMMERCE FUNNEL                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Product View   ──────────────────→ 100%                   │
│       ↓ [XX%]                                              │
│  Add to Cart    ──────────────────→ XX%                    │
│       ↓ [XX%]                                              │
│  Cart View      ──────────────────→ XX%                    │
│       ↓ [XX%]                                              │
│  Checkout Start ──────────────────→ XX%                    │
│       ↓ [XX%]                                              │
│  Payment Info   ──────────────────→ XX%                    │
│       ↓ [XX%]                                              │
│  Purchase       ──────────────────→ XX%                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Étape 1 : Mapper le funnel

### Template de mapping

```markdown
## Funnel Map

### Nom du funnel
[Ex: Signup to Activation]

### Étapes du funnel

| # | Étape | Event trackté | Page/Screen | Action utilisateur |
|---|-------|---------------|-------------|-------------------|
| 1 | [Nom] | `event_name` | [URL/Screen] | [Description] |
| 2 | [Nom] | `event_name` | [URL/Screen] | [Description] |
| 3 | [Nom] | `event_name` | [URL/Screen] | [Description] |

### Points de sortie identifiés
- Entre étape 1 et 2 : [Page/Action de sortie]
- Entre étape 2 et 3 : [Page/Action de sortie]

### Segmentations pertinentes
- [ ] Par source d'acquisition
- [ ] Par device (mobile/desktop)
- [ ] Par pays/langue
- [ ] Par persona/segment utilisateur
- [ ] Par période (jour/semaine/mois)
```

## Étape 2 : Mesurer

### Configuration du tracking

```typescript
// Exemple avec Segment/Amplitude
interface FunnelStep {
  step: number;
  name: string;
  event: string;
  properties?: Record<string, unknown>;
}

const SIGNUP_FUNNEL: FunnelStep[] = [
  {
    step: 1,
    name: 'Landing Page View',
    event: 'page_viewed',
    properties: { page: 'landing' },
  },
  {
    step: 2,
    name: 'CTA Clicked',
    event: 'cta_clicked',
    properties: { cta: 'signup_hero' },
  },
  {
    step: 3,
    name: 'Signup Form Started',
    event: 'signup_started',
  },
  {
    step: 4,
    name: 'Signup Form Completed',
    event: 'signup_completed',
  },
  {
    step: 5,
    name: 'Email Verified',
    event: 'email_verified',
  },
  {
    step: 6,
    name: 'Onboarding Completed',
    event: 'onboarding_completed',
  },
  {
    step: 7,
    name: 'First Value Moment',
    event: 'first_value_achieved',
  },
];

// Tracker chaque étape
function trackFunnelStep(step: FunnelStep) {
  analytics.track(step.event, {
    funnel: 'signup',
    step: step.step,
    stepName: step.name,
    ...step.properties,
  });
}
```

### Métriques clés

| Métrique | Formule | Benchmark |
|----------|---------|-----------|
| **Conversion Rate** | Users étape N+1 / Users étape N | Variable |
| **Overall Conversion** | Users dernière étape / Users première étape | 2-5% |
| **Drop-off Rate** | 1 - Conversion Rate | < 30% par étape |
| **Time to Convert** | Temps médian entre étapes | Variable |
| **Abandonment Rate** | Users qui commencent mais ne finissent pas | < 70% |

## Étape 3 : Analyser

### Rapport d'analyse

```markdown
## Funnel Analysis Report

### Période
[Date début] - [Date fin]

### Volume
- Entrées dans le funnel : [N]
- Conversions : [N] ([X%])

### Performance par étape

| Étape | Users | Conv. | Drop-off | Trend vs M-1 |
|-------|-------|-------|----------|--------------|
| 1. Landing | 10,000 | 100% | - | - |
| 2. CTA Click | 3,500 | 35% | 65% | ↑ +2% |
| 3. Form Start | 2,800 | 80% | 20% | = |
| 4. Form Complete | 1,400 | 50% | 50% | ↓ -5% ⚠️ |
| 5. Email Verified | 1,200 | 86% | 14% | ↑ +3% |
| 6. Onboarding Done | 800 | 67% | 33% | = |
| 7. First Value | 500 | 63% | 37% | ↓ -2% |

### Conversion globale
500 / 10,000 = **5%**

### Points de friction identifiés
1. **Form Complete (50%)** - Drop majeur, investiguer
2. **Onboarding Done (67%)** - Taux acceptable mais améliorable
3. **First Value (63%)** - Attention à maintenir
```

### Segmentation de l'analyse

```markdown
## Analyse par segment

### Par device

| Device | Conv. globale | Étape problématique |
|--------|---------------|---------------------|
| Desktop | 6.2% | Onboarding (58%) |
| Mobile | 3.1% | Form Complete (35%) |
| Tablet | 4.8% | - |

→ **Insight** : Formulaire non optimisé mobile

### Par source

| Source | Conv. globale | CAC | ROI |
|--------|---------------|-----|-----|
| Organic | 7.1% | $0 | ∞ |
| Google Ads | 4.2% | $45 | 2.1x |
| Facebook | 2.8% | $38 | 1.4x |
| Referral | 8.5% | $10 | 5.2x |

→ **Insight** : Referral = meilleure source

### Par cohorte

| Cohorte signup | D7 Retention | D30 Retention |
|----------------|--------------|---------------|
| Jan 2024 | 45% | 28% |
| Feb 2024 | 48% | 31% |
| Mar 2024 | 52% | 35% |

→ **Insight** : Amélioration continue
```

## Étape 4 : Diagnostiquer

### Matrice de diagnostic

```markdown
## Diagnostic des drop-offs

### Étape : Form Complete (50% drop)

#### Données quantitatives
- Temps moyen sur le formulaire : 4min 30s
- Champs avec le plus d'erreurs : Email (15%), Password (22%)
- Abandon par champ : Étape 2/3 du formulaire (45%)

#### Données qualitatives
- Session recordings : [X] sessions analysées
- Patterns observés : Hésitation sur les champs optionnels
- Feedback support : "Le formulaire demande trop d'infos"

#### Hypothèses
| Hypothèse | Probabilité | Test possible |
|-----------|-------------|---------------|
| Trop de champs | Haute | Réduire les champs |
| Validation temps réel manquante | Moyenne | Ajouter validation |
| Social login absent | Haute | Ajouter Google/Apple |
| Confiance insuffisante | Moyenne | Ajouter social proof |

#### Action prioritaire
→ **A/B Test : Formulaire simplifié (3 champs vs 7)**
```

### Framework de diagnostic

```
┌─────────────────────────────────────────────────────────────┐
│                    DIAGNOSTIC FRAMEWORK                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  FRICTION TYPES                                             │
│                                                             │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │
│  │   CLARITY   │ │   ANXIETY   │ │  FRICTION   │           │
│  │             │ │             │ │             │           │
│  │ User ne     │ │ User a      │ │ User trouve │           │
│  │ comprend    │ │ peur/doute  │ │ trop        │           │
│  │ pas quoi    │ │             │ │ compliqué   │           │
│  │ faire       │ │             │ │             │           │
│  └─────────────┘ └─────────────┘ └─────────────┘           │
│                                                             │
│  SOLUTIONS                                                  │
│                                                             │
│  → Meilleure   → Trust signals → Simplifier    │           │
│    UX copy     → Garanties     → Réduire       │           │
│  → Guidage     → Social proof  → Automatiser   │           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Étape 5 : Optimiser

### Playbook d'optimisation par étape

#### Landing → CTA Click

| Levier | Impact potentiel | Effort |
|--------|------------------|--------|
| Value proposition plus claire | Élevé | Faible |
| CTA plus visible (couleur, taille) | Moyen | Faible |
| Social proof au-dessus du fold | Moyen | Faible |
| Réduire les distractions | Moyen | Faible |
| Personnalisation par source | Élevé | Moyen |

#### CTA → Form Start

| Levier | Impact potentiel | Effort |
|--------|------------------|--------|
| Progress indicator | Moyen | Faible |
| Temps estimé affiché | Faible | Faible |
| Bénéfices rappelés | Moyen | Faible |
| Exit-intent popup | Moyen | Moyen |

#### Form → Complete

| Levier | Impact potentiel | Effort |
|--------|------------------|--------|
| Réduire le nombre de champs | Élevé | Faible |
| Social login (Google, Apple) | Élevé | Moyen |
| Validation en temps réel | Moyen | Moyen |
| Auto-fill (adresse, etc.) | Moyen | Moyen |
| Formulaire multi-étapes | Moyen | Moyen |
| Sauvegarde automatique | Faible | Moyen |

#### Form Complete → Email Verified

| Levier | Impact potentiel | Effort |
|--------|------------------|--------|
| Email clair et rapide | Élevé | Faible |
| Skip verification (trust score) | Élevé | Élevé |
| Renvoyer facilement | Moyen | Faible |
| Magic link | Moyen | Moyen |

#### Email Verified → First Value

| Levier | Impact potentiel | Effort |
|--------|------------------|--------|
| Onboarding personnalisé | Élevé | Moyen |
| Template/contenu de départ | Élevé | Moyen |
| Checklist gamifiée | Moyen | Moyen |
| Support proactif | Moyen | Élevé |

### A/B Test prioritization

```markdown
## A/B Test Backlog

| Test | Étape impactée | Impact estimé | Effort | ICE Score |
|------|----------------|---------------|--------|-----------|
| Formulaire 3 champs | Form Complete | +15% conv. | 2j | 9.5 |
| Social login | Form Complete | +10% conv. | 5j | 8.0 |
| Nouveau hero copy | Landing→CTA | +5% conv. | 1j | 7.5 |
| Progress bar | Form Start | +3% conv. | 1j | 6.0 |

### Calcul ICE Score
ICE = (Impact × Confidence × Ease) / 10
- Impact : 1-10 (effet sur la métrique)
- Confidence : 1-10 (certitude du résultat)
- Ease : 1-10 (facilité d'implémentation)
```

## Monitoring continu

### Dashboard de suivi

```markdown
## Funnel Dashboard

### KPIs temps réel
| Métrique | Actuel | Target | Trend |
|----------|--------|--------|-------|
| Conv. Landing→Signup | 5.2% | 6% | ↑ |
| Conv. Signup→Activation | 65% | 70% | = |
| Conv. globale | 3.4% | 4% | ↑ |

### Alertes configurées
- [ ] Conv. < 3% sur 24h → Alerte
- [ ] Drop-off > 60% sur une étape → Alerte
- [ ] Erreur formulaire > 20% → Alerte

### Review cadence
- Daily : Check des KPIs
- Weekly : Analyse des trends
- Monthly : Deep dive + tests
- Quarterly : Révision du funnel
```

## Output attendu

```markdown
## Funnel Optimization Report

### Funnel analysé
[Nom du funnel]

### Performance actuelle
- Conversion globale : [X%]
- Volume : [N] users/mois
- Revenus impactés : [€]

### Opportunités identifiées

| Opportunité | Impact potentiel | Effort | Priorité |
|-------------|------------------|--------|----------|
| [Opp. 1] | +[X%] conv. | [Effort] | P1 |
| [Opp. 2] | +[X%] conv. | [Effort] | P2 |

### Plan d'action
1. [ ] [Action 1] - [Owner] - [Date]
2. [ ] [Action 2] - [Owner] - [Date]

### Tests A/B planifiés
1. [Test 1] - Lancement [Date]
2. [Test 2] - Lancement [Date]
```

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/analytics` | Configurer le tracking |
| `/ab-test` | Lancer des tests |
| `/landing` | Optimiser landing page |
| `/onboarding` | Améliorer activation |
| `/retention` | Post-conversion |

---

IMPORTANT: Optimiser une étape à la fois pour mesurer l'impact réel.

YOU MUST avoir un tracking fiable avant d'analyser.

YOU MUST segmenter les analyses pour des insights actionnables.

NEVER optimiser sans hypothèse claire et mesure d'impact.

Think hard sur le "pourquoi" du drop-off, pas juste le "combien".
