---
sidebar_position: 17
title: "Guide Growth & Marketing"
description: " Workflow complet pour mesurer, analyser, optimiser et scaler la croissance"
tags:
  - "guide"
---

<!-- Auto-generated from docs/ - DO NOT EDIT -->

# Guide Growth & Marketing

&gt; Workflow complet pour mesurer, analyser, optimiser et scaler la croissance

## Stack Supportee

| Categorie | Technologies |
|-----------|--------------|
| Analytics | Google Analytics 4, Mixpanel, PostHog, Amplitude |
| SEO | Google Search Console, Ahrefs, Screaming Frog |
| CRO | Optimizely, VWO, Google Optimize |
| Email | SendGrid, Mailchimp, Resend, Loops |
| A/B Testing | LaunchDarkly, Statsig, GrowthBook |
| App Stores | App Store Connect, Google Play Console |

## Workflow Recommande

```
/growth:growth-analytics → /growth:growth-funnel → /growth:growth-seo → /growth:growth-cro → /growth:growth-ab-test → /growth:growth-retention
```

---

## Framework AARRR (Pirate Metrics)

Le framework AARRR structure la croissance en cinq etapes sequentielles. Chaque etape doit etre mesuree independamment avant d'etre optimisee.

| Etape | Definition | Metriques cles | Cible typique SaaS |
|-------|------------|----------------|--------------------|
| **Acquisition** | Comment les utilisateurs vous trouvent | CAC, trafic organique, CPC, impressions | CAC &lt; LTV / 3 |
| **Activation** | Premiere experience de valeur ("aha moment") | Activation rate, time-to-value, onboarding completion | &gt; 40% |
| **Retention** | Retour et usage regulier | D1/D7/D30, churn rate, DAU/MAU ratio | D30 &gt; 15% |
| **Revenue** | Monetisation | MRR, ARPU, LTV, conversion free → paid | LTV &gt; 3x CAC |
| **Referral** | Croissance organique par bouche-a-oreille | NPS, referral rate, virality coefficient (K) | K &gt; 0.5 |

### Selection de la North Star Metric

La North Star Metric (NSM) represente la valeur fondamentale delivree aux utilisateurs. Elle pilote toutes les decisions produit et growth.

| Type de produit | North Star Metric candidate |
|----------------|-----------------------------|
| SaaS B2B | Seats actifs par semaine |
| Marketplace | Transactions completees par mois |
| Media/contenu | Articles lus par utilisateur par semaine |
| Social | Messages envoyes par jour |
| E-commerce | Commandes recurrentes par client |

**Criteres d'une bonne NSM** : mesurable, correle au chiffre d'affaires, actionnable par les equipes, reflete la valeur utilisateur.

---

## Phase 1: Mesurer (Measure)

| Commande | Description |
|----------|-------------|
| `/growth:growth-analytics` | Configurer le tracking (events, properties, goals) |
| `/growth:growth-funnel` | Definir et analyser les funnels de conversion |
| `/growth:growth-app-store-analytics` | Metriques App Store et Play Store (downloads, ratings, retention) |

### Schema d'evenements analytics

Avant d'implementer le tracking, definir le schema d'evenements avec une convention coherente. Exemple pour un SaaS :

```typescript
// Convention: <objet>_<action> en snake_case
// Proprietes communes a tous les evenements
interface BaseEventProperties {
  user_id: string;
  session_id: string;
  timestamp: string;        // ISO 8601
  platform: 'web' | 'ios' | 'android';
  app_version: string;
}

// Evenements d'acquisition
track('page_viewed', { page_name: 'pricing', referrer: 'google' });
track('signup_started', { plan: 'pro', source: 'landing_cta' });
track('signup_completed', { plan: 'pro', method: 'google_oauth' });

// Evenements d'activation
track('onboarding_step_completed', { step: 'connect_integration', step_index: 2 });
track('aha_moment_reached', { trigger: 'first_report_generated' });

// Evenements de retention et revenue
track('feature_used', { feature_name: 'export_csv', frequency: 'daily' });
track('subscription_upgraded', { from_plan: 'starter', to_plan: 'pro', mrr_delta: 49 });
track('subscription_cancelled', { reason: 'too_expensive', tenure_days: 45 });
```

### Setup PostHog (self-hosted ou cloud)

```typescript
// src/lib/analytics.ts
import posthog from 'posthog-js';

export function initAnalytics() {
  posthog.init(process.env.NEXT_PUBLIC_POSTHOG_KEY!, {
    api_host: process.env.NEXT_PUBLIC_POSTHOG_HOST ?? 'https://app.posthog.com',
    capture_pageview: false,       // Gerer manuellement pour SPA
    persistence: 'localStorage',
  });
}

export function identifyUser(userId: string, traits: Record<string, unknown>) {
  posthog.identify(userId, traits);
}

export function track(event: string, properties?: Record<string, unknown>) {
  posthog.capture(event, properties);
}

export function resetUser() {
  posthog.reset();                 // Appeler au logout
}
```

### Metriques cles a tracker

| Metrique | Description | Formule | Cible |
|----------|-------------|---------|-------|
| MAU/DAU | Utilisateurs actifs | Uniques actifs / periode | Croissance mois/mois |
| Activation rate | % users atteignant l'aha moment | Activated / Signups | &gt; 40% |
| Retention D1/D7/D30 | Retour des utilisateurs | Retained(Dn) / Cohort size | D1 &gt; 40%, D7 &gt; 20%, D30 &gt; 10% |
| Churn rate | Perte mensuelle d'abonnes | Churned / Total subscribers | &lt; 5% / mois |
| Conversion rate | Free → Paid | Paying / Free signups | &gt; 3% |
| CAC | Cout d'acquisition client | Spend / New customers | &lt; LTV / 3 |
| LTV | Valeur vie client | ARPU / Churn rate | &gt; 3x CAC |
| NPS | Satisfaction et referral | % Promoteurs - % Detracteurs | &gt; 30 |

---

## Phase 2: Analyser (Analyze)

| Commande | Description |
|----------|-------------|
| `/growth:growth-funnel` | Identifier les points de friction dans le funnel |
| `/growth:growth-seo` | Audit SEO (technique, contenu, backlinks) |

### Analyse de funnel de conversion

Un funnel represente les etapes successives qu'un utilisateur franchit avant de convertir. Identifier les etapes avec les plus forts taux de chute (drop-off) oriente les efforts d'optimisation.

Exemple de funnel SaaS avec taux de conversion par etape :

```
Page d'accueil         100 000 visiteurs
       |  50% drop
Pricing page            50 000 visiteurs
       |  70% drop
Signup form             15 000 visiteurs
       |  40% drop
Email verified           9 000 utilisateurs
       |  55% drop
Onboarding step 1        4 000 utilisateurs
       |  50% drop
Aha moment reached       2 000 utilisateurs   ← priorite maximale
       |  60% drop
Conversion paid            800 utilisateurs   = 0.8% sur visiteurs initiaux
```

**Diagnostic** : le drop entre "Aha moment" et "Conversion paid" (60%) est anormalement eleve. Piste : tester une reduction de prix ou un essai gratuit etendu.

### Audit SEO - Checklist par niveau

**SEO technique (priorite haute)**
- [ ] Core Web Vitals : LCP &lt; 2.5s, CLS &lt; 0.1, FID &lt; 100ms
- [ ] Mobile-first indexing : responsive, viewport meta tag
- [ ] HTTPS et redirections 301 correctes
- [ ] Sitemap XML soumis a Search Console
- [ ] Robots.txt sans blocage accidentel des pages importantes
- [ ] Pas d'erreurs 404 sur pages indexees
- [ ] Canonical tags sur les pages en double contenu

**SEO on-page (priorite haute)**
- [ ] Title tag unique par page (50-60 caracteres)
- [ ] Meta description engageante (150-160 caracteres)
- [ ] Un seul H1 par page, hierarchie Hx coherente
- [ ] Keyword principal dans title, H1 et premier paragraphe
- [ ] Images avec alt text descriptif
- [ ] Internal linking vers les pages a forte valeur

**SEO off-page (priorite moyenne)**
- [ ] Domain Rating / Domain Authority &gt; 20 (Ahrefs / Moz)
- [ ] Backlinks de sites du meme secteur
- [ ] Pas de liens toxiques pointant vers le domaine
- [ ] Presence dans les annuaires de reference du secteur

### Modeles d'attribution

L'attribution determine quelle source de trafic recoit le credit d'une conversion. Chaque modele repond a une question differente.

| Modele | Description | Avantage | Limite | Usage |
|--------|-------------|----------|--------|-------|
| **First-touch** | 100% au premier canal | Mesure l'acquisition | Ignore le nurturing | Budget acquisition |
| **Last-touch** | 100% au dernier canal | Simple, natif GA4 | Ignore la decouverte | Mesure directe |
| **Linear** | Partage egal entre tous les touchpoints | Equitable | Ne valorise pas l'intention | Vue d'ensemble |
| **Time-decay** | Plus de poids aux touchpoints recents | Reflète l'intention d'achat | Penalise le top of funnel | Cycles de vente courts |
| **Data-driven** | ML sur historique de conversions | Le plus precis | Necessite volume (&gt;1000 conversions) | SaaS mature |

**Recommandation** : utiliser Last-touch pour le reporting operationnel et Data-driven pour les decisions de budget media a partir de 1 000 conversions par mois.

---

## Phase 3: Optimiser (Optimize)

| Commande | Description |
|----------|-------------|
| `/growth:growth-cro` | Optimisation du taux de conversion (formulaires, checkout, CTA) |
| `/growth:growth-landing` | Creer ou optimiser une landing page |
| `/growth:growth-onboarding` | Ameliorer le parcours d'onboarding |
| `/growth:growth-ab-test` | Configurer et analyser des tests A/B |
| `/growth:growth-email` | Sequences email (onboarding, retention, re-engagement) |

### Matrice de decision CRO

| Probleme identifie | Approche recommandee | Commande |
|-------------------|----------------------|----------|
| Taux de rebond elevé sur landing | A/B test headline + CTA | `/growth:growth-ab-test` |
| Drop sur formulaire d'inscription | Reduire les champs, social login | `/growth:growth-cro` |
| Faible activation apres signup | Retravailler l'onboarding | `/growth:growth-onboarding` |
| Churn elevé en mois 1 | Email sequence de retention | `/growth:growth-email` |
| Faible trafic organique | Strategie contenu SEO | `/growth:growth-seo` |
| Conversion free → paid faible | Retravailler pricing page | `/growth:growth-landing` |

### Framework ICE pour prioriser les experiments

Le score ICE (Impact, Confidence, Ease) classe les hypotheses d'optimisation sur 30 points.

| Hypothese | Impact (1-10) | Confidence (1-10) | Ease (1-10) | Score ICE | Priorite |
|-----------|--------------|-------------------|-------------|-----------|----------|
| Simplifier le formulaire signup (5 → 2 champs) | 8 | 9 | 8 | 25 | P1 |
| Ajouter social proof sur pricing page | 7 | 7 | 9 | 23 | P1 |
| Video demo sur landing hero | 8 | 6 | 6 | 20 | P2 |
| Exit-intent popup avec offre | 5 | 7 | 8 | 20 | P2 |
| Redesign complet checkout | 9 | 4 | 3 | 16 | P3 |

### Framework d'experimentation (A/B testing)

#### Template d'hypothese

```
PARCE QUE [observation basee sur donnees]
NOUS PENSONS QUE [changement propose]
POUR [segment d'utilisateurs cible]
PRODUIRA [resultat attendu]
MESURE PAR [metrique principale]
AVEC UNE CONFIANCE DE [niveau statistique, ex: 95%]
```

Exemple concret :
```
PARCE QUE 68% des utilisateurs abandonnent le formulaire signup a la 3eme etape
NOUS PENSONS QUE supprimer le champ "telephone" et "taille de l'entreprise"
POUR les nouveaux visiteurs sur la page /signup
PRODUIRA une augmentation du taux de completion du formulaire
MESURE PAR signup_completed events dans PostHog
AVEC UNE CONFIANCE DE 95% sur un minimum de 1000 visiteurs par variante
```

#### Reference : taille d'echantillon

Pour un test A/B avec un niveau de confiance de 95% et une puissance statistique de 80% :

| Taux de conversion de base | Amelioration minimale detectable | Echantillon par variante |
|---------------------------|----------------------------------|--------------------------|
| 2% | 20% (2% → 2.4%) | ~19 000 visiteurs |
| 5% | 20% (5% → 6%) | ~7 700 visiteurs |
| 10% | 10% (10% → 11%) | ~15 000 visiteurs |
| 10% | 20% (10% → 12%) | ~3 800 visiteurs |

**Regle pratique** : ne jamais arreter un test avant d'atteindre la taille d'echantillon cible, meme si les resultats semblent significatifs.

### Setup A/B test avec GrowthBook

```typescript
// src/lib/experiments.ts
import { GrowthBook } from '@growthbook/growthbook';

export const gb = new GrowthBook({
  apiHost: 'https://cdn.growthbook.io',
  clientKey: process.env.NEXT_PUBLIC_GROWTHBOOK_KEY!,
  enableDevMode: process.env.NODE_ENV === 'development',
  trackingCallback: (experiment, result) => {
    track('experiment_viewed', {
      experiment_id: experiment.key,
      variant_id: result.key,
    });
  },
});

// Utilisation dans un composant
export function SignupButton() {
  const variant = gb.getFeatureValue('signup-cta-text', 'Get started free');
  return <button>{variant}</button>;
}
```

### Template sequence email onboarding (7 jours)

| Jour | Objet | Objectif | Declencheur |
|------|-------|----------|-------------|
| J+0 | "Bienvenue sur [Produit] - votre compte est pret" | Confirmer et orienter | signup_completed |
| J+1 | "Une chose a faire pour demarrer" | Activation (aha moment) | onboarding_incomplete |
| J+3 | "3 fonctionnalites que nos clients adorent" | Education produit | aha_moment_not_reached |
| J+5 | "Comment [Client similaire] a resolu [probleme]" | Social proof et nurturing | conversion_not_started |
| J+7 | "Votre essai gratuit : il reste encore du temps" | Urgence et conversion | trial_not_converted |
| J+14 | "Nous voulons votre avis" | Feedback + re-engagement | churned_trial |

```typescript
// Exemple declenchement sequence avec Resend
import { Resend } from 'resend';

const resend = new Resend(process.env.RESEND_API_KEY);

export async function triggerOnboardingSequence(user: User) {
  // Email J+0 : immediat
  await resend.emails.send({
    from: 'hello@monproduit.com',
    to: user.email,
    subject: `Bienvenue sur MonProduit - votre compte est pret`,
    react: WelcomeEmail({ name: user.firstName }),
  });

  // Email J+1 : schedule avec delay
  await resend.emails.send({
    from: 'hello@monproduit.com',
    to: user.email,
    subject: 'Une chose a faire pour demarrer',
    react: ActivationEmail({ name: user.firstName }),
    scheduledAt: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
  });
}
```

### Structured data et meta tags SEO

```typescript
// src/components/SEO.tsx
interface SEOProps {
  title: string;
  description: string;
  canonical?: string;
  ogImage?: string;
  schema?: Record<string, unknown>;
}

export function SEO({ title, description, canonical, ogImage, schema }: SEOProps) {
  const siteUrl = 'https://monproduit.com';
  const fullTitle = `${title} | MonProduit`;

  return (
    <Head>
      <title>{fullTitle}</title>
      <meta name="description" content={description} />
      {canonical && <link rel="canonical" href={`${siteUrl}${canonical}`} />}

      {/* Open Graph */}
      <meta property="og:title" content={fullTitle} />
      <meta property="og:description" content={description} />
      <meta property="og:type" content="website" />
      {ogImage && <meta property="og:image" content={ogImage} />}

      {/* Twitter Card */}
      <meta name="twitter:card" content="summary_large_image" />
      <meta name="twitter:title" content={fullTitle} />
      <meta name="twitter:description" content={description} />

      {/* JSON-LD Schema */}
      {schema && (
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(schema) }}
        />
      )}
    </Head>
  );
}

// Exemple schema SoftwareApplication
const softwareSchema = {
  '@context': 'https://schema.org',
  '@type': 'SoftwareApplication',
  name: 'MonProduit',
  applicationCategory: 'BusinessApplication',
  offers: {
    '@type': 'Offer',
    price: '49',
    priceCurrency: 'EUR',
  },
  aggregateRating: {
    '@type': 'AggregateRating',
    ratingValue: '4.8',
    ratingCount: '312',
  },
};
```

---

## Phase 4: Scaler (Scale)

| Commande | Description |
|----------|-------------|
| `/growth:growth-retention` | Strategies de retention (engagement loops, notifications) |
| `/growth:growth-localization` | Internationalisation et localisation (i18n, l10n) |

### Matrice de retention : quel levier activer

| Situation | Levier | Commande |
|-----------|--------|----------|
| Churn elevé apres J7 (avant aha moment) | Ameliorer activation et onboarding | `/growth:growth-onboarding` |
| Churn elevé apres J30 (post-activation) | Engagement loops et habitudes | `/growth:growth-retention` |
| DAU/MAU &lt; 20% | Notifications et triggers comportementaux | `/growth:growth-retention` |
| NPS &lt; 20 | Feedback loop et product iteration | `/growth:growth-analytics` |
| K-factor &lt; 0.2 | Programme de referral | `/growth:growth-cro` |

---

## Strategie de contenu SEO

### Workflow recherche de mots-cles

```
1. SEED KEYWORDS    Identifier 5-10 termes metier fondamentaux
         |
2. EXPANSION        Ahrefs / Google Keyword Planner : volume, difficulte, CPC
         |
3. CLUSTERING       Regrouper par intention (informationnel / commercial / transactionnel)
         |
4. PRIORISATION     Score = Volume * (1 - Difficulte) * Pertinence_metier
         |
5. CONTENT BRIEF    Un brief par cluster : structure, longueur cible, sources
```

### Calendrier editorial type (mensuel)

| Semaine | Type de contenu | Intention | Exemple |
|---------|----------------|-----------|---------|
| S1 | Article pilier (2000+ mots) | Informationnel | "Guide complet [theme principal]" |
| S2 | Article comparatif | Commercial | "[Produit] vs [Concurrent] : lequel choisir" |
| S3 | Etude de cas client | Transactionnel | "Comment [Client] a obtenu [Resultat] avec [Produit]" |
| S4 | Article long tail | Informationnel | "Comment resoudre [probleme specifique niche]" |

### Choix de l'outil analytics selon le contexte

| Critere | PostHog | Mixpanel | Google Analytics 4 | Amplitude |
|---------|---------|----------|--------------------|-----------|
| Budget | Self-hosted gratuit | Freemium jusqu'a 20M events | Gratuit | Freemium |
| Data privacy / RGPD | Excellent (self-host EU) | Moyen (US) | Moyen | Moyen |
| Product analytics | Excellent | Excellent | Basique | Excellent |
| Session replay | Inclus | Non | Non | Non |
| Feature flags + A/B | Inclus | Non | Non | Non |
| Courbe apprentissage | Moderee | Elevee | Faible | Elevee |
| **Recommande pour** | Startups RGPD, indie | SaaS B2B | Sites e-commerce / SEO | SaaS B2C scale |

---

## Commandes par Use Case

### Lancement SaaS

```bash
1. /growth:growth-analytics     # Tracking de base (events schema)
2. /growth:growth-landing       # Landing page avec CTA et social proof
3. /growth:growth-seo           # SEO on-page et structured data
4. /growth:growth-onboarding    # Parcours onboarding vers aha moment
5. /growth:growth-email         # Sequences email (welcome + activation)
```

### Optimisation conversion

```bash
1. /growth:growth-funnel        # Analyser le funnel, identifier le top drop-off
2. /growth:growth-cro           # Prioriser avec ICE score
3. /growth:growth-ab-test       # Tester les hypotheses (une a la fois)
4. /growth:growth-analytics     # Mesurer les resultats sur 2+ semaines
```

### Expansion internationale

```bash
1. /growth:growth-localization  # i18n/l10n et hreflang
2. /growth:growth-seo           # SEO multilingue et Google Search Console par pays
3. /growth:growth-app-store-analytics  # ASO par marche et langue
```

### Retention et engagement

```bash
1. /growth:growth-funnel        # Identifier la phase de churn (J7/J30/J90)
2. /growth:growth-retention     # Engagement loops et push notifications
3. /growth:growth-email         # Sequences re-engagement et win-back
4. /growth:growth-onboarding    # Si churn pre-activation : ameliorer onboarding
```

---

## Agents Automatiques

| Contexte | Agent | Action |
|----------|-------|--------|
| "Configure le tracking" | growth-analytics | Events schema, funnels, goals |
| "Optimise le SEO" | growth-seo | Audit technique + contenu + backlinks |
| "Ameliore les conversions" | growth-cro | ICE scoring, A/B hypotheses |
| "Cree une landing page" | growth-landing | Structure, CTA, social proof, SEO |
| "Reduis le churn" | growth-retention | Engagement loops, email sequences |
| "Lance des A/B tests" | growth-ab-test | Hypothese, setup, analyse statistique |

---

## Anti-patterns a Eviter

- Tracker sans plan → Definir le schema d'evenements metier avant d'implementer
- Optimiser sans donnees → Mesurer au moins 2 semaines avant de conclure
- A/B test sans hypothese → Formuler "Parce que... nous pensons que... produira..."
- Arreter un test trop tot → Attendre la taille d'echantillon statistiquement necessaire
- Tester plusieurs variables simultanement → Un seul changement par test A/B
- Ignorer le mobile → Verifier les funnels separement par device et OS
- Email sans segmentation → Segmenter par comportement (activated / not activated / churned)
- SEO uniquement technique → Le contenu de qualite prime sur l'optimisation technique
- Acquerir sans retenir → Un taux de churn de 10%/mois annule toute croissance
- North Star Metric floue → Choisir une seule metrique principale, partagee par toute l'equipe

---

## Ressources

- [AARRR Pirate Metrics](https://500hats.typepad.com/500blogs/2007/09/startup-metrics.html) - Dave McClure
- [ICE Scoring](https://www.intercom.com/blog/product-prioritization-using-ice-scoring/) - Intercom
- [Statistical Significance Calculator](https://www.evanmiller.org/ab-testing/sample-size.html) - Evan Miller
- [GrowthBook Documentation](https://docs.growthbook.io) - Open-source A/B testing
- [PostHog Documentation](https://posthog.com/docs) - Product analytics self-hosted
