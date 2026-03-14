# Guide Growth & Marketing

> Workflow complet pour mesurer, analyser, optimiser et scaler la croissance

## Stack Supportee

| Categorie | Technologies |
|-----------|--------------|
| Analytics | Google Analytics, Mixpanel, PostHog, Amplitude |
| SEO | Google Search Console, Ahrefs, Screaming Frog |
| CRO | Optimizely, VWO, Google Optimize |
| Email | SendGrid, Mailchimp, Resend, Loops |
| A/B Testing | LaunchDarkly, Statsig, GrowthBook |
| App Stores | App Store Connect, Google Play Console |

## Workflow Recommande

```
/growth:growth-analytics → /growth:growth-funnel → /growth:growth-seo → /growth:growth-cro → /growth:growth-ab-test → /growth:growth-retention
```

## Phase 1: Mesurer (Measure)

| Commande | Description |
|----------|-------------|
| `/growth:growth-analytics` | Configurer le tracking (events, properties, goals) |
| `/growth:growth-funnel` | Definir et analyser les funnels de conversion |
| `/growth:growth-app-store-analytics` | Metriques App Store et Play Store (downloads, ratings, retention) |

### Metriques cles a tracker

| Metrique | Description | Cible |
|----------|-------------|-------|
| MAU/DAU | Utilisateurs actifs | Croissance mois/mois |
| Activation rate | % users qui atteignent le "aha moment" | > 40% |
| Retention D1/D7/D30 | Retour des utilisateurs | D1 > 40%, D7 > 20% |
| Conversion rate | Free → Paid | > 3% |
| CAC / LTV | Cout acquisition vs valeur vie | LTV > 3x CAC |

## Phase 2: Analyser (Analyze)

| Commande | Description |
|----------|-------------|
| `/growth:growth-funnel` | Identifier les points de friction dans le funnel |
| `/growth:growth-seo` | Audit SEO (technique, contenu, backlinks) |

### Audit SEO

- SEO technique : vitesse, mobile, Core Web Vitals
- SEO on-page : titres, metas, headings, contenu
- SEO off-page : backlinks, autorite de domaine

## Phase 3: Optimiser (Optimize)

| Commande | Description |
|----------|-------------|
| `/growth:growth-cro` | Optimisation du taux de conversion (formulaires, checkout, CTA) |
| `/growth:growth-landing` | Creer ou optimiser une landing page |
| `/growth:growth-onboarding` | Ameliorer le parcours d'onboarding |
| `/growth:growth-ab-test` | Configurer et analyser des tests A/B |
| `/growth:growth-email` | Sequences email (onboarding, retention, re-engagement) |

### Priorites CRO

1. Pages a fort trafic et faible conversion
2. Formulaires d'inscription et checkout
3. Onboarding (premiere experience utilisateur)
4. Emails transactionnels et sequences

## Phase 4: Scaler (Scale)

| Commande | Description |
|----------|-------------|
| `/growth:growth-retention` | Strategies de retention (engagement loops, notifications) |
| `/growth:growth-localization` | Internationalisation et localisation (i18n, l10n) |

## Commandes par Use Case

### Lancement SaaS

```bash
1. /growth:growth-analytics     # Tracking de base
2. /growth:growth-landing       # Landing page
3. /growth:growth-seo           # SEO on-page
4. /growth:growth-onboarding    # Parcours onboarding
5. /growth:growth-email         # Sequences email
```

### Optimisation conversion

```bash
1. /growth:growth-funnel        # Analyser le funnel
2. /growth:growth-cro           # Identifier les optimisations
3. /growth:growth-ab-test       # Tester les hypotheses
4. /growth:growth-analytics     # Mesurer les resultats
```

### Expansion internationale

```bash
1. /growth:growth-localization  # i18n/l10n
2. /growth:growth-seo           # SEO multilingue
3. /growth:growth-app-store-analytics  # ASO par pays
```

### Retention et engagement

```bash
1. /growth:growth-retention     # Strategies retention
2. /growth:growth-email         # Re-engagement emails
3. /growth:growth-onboarding    # Ameliorer activation
```

## Agents Automatiques

| Contexte | Agent | Action |
|----------|-------|--------|
| "Configure le tracking" | growth-analytics | Events et funnels |
| "Optimise le SEO" | growth-seo | Audit et recommandations |
| "Ameliore les conversions" | growth-cro | CRO et A/B tests |
| "Cree une landing page" | growth-landing | Landing optimisee |

## Anti-patterns a Eviter

- Tracker sans plan → Definir les events metier d'abord
- Optimiser sans donnees → Mesurer avant d'optimiser
- A/B test sans hypothese → Formuler une hypothese claire
- Ignorer le mobile → Tester sur tous les devices
- Email sans segmentation → Segmenter par comportement
- SEO uniquement technique → Le contenu prime
- Pas de retention → Acquerir coute plus cher que retenir
