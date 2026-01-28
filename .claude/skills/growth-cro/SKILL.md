---
name: growth-cro
description: Optimisation du taux de conversion (CRO). Declencher quand l'utilisateur veut optimiser les conversions, ameliorer un formulaire d'inscription, un checkout, une landing page, ou un onboarding.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Edit
  - Write
context: fork
---

# Conversion Rate Optimization (CRO)

## Objectif

Identifier et corriger les points de friction dans les parcours utilisateur pour maximiser le taux de conversion.

## Domaines CRO

```
┌──────────────────────────────────────────────────────────────────┐
│                    CRO FRAMEWORK                                  │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  PAGE CRO           Optimiser les pages marketing/landing        │
│  ═════════                                                        │
│                                                                   │
│  SIGNUP FLOW CRO    Ameliorer inscription et creation compte     │
│  ══════════════                                                   │
│                                                                   │
│  ONBOARDING CRO     Reduire time-to-value post-inscription      │
│  ═════════════                                                    │
│                                                                   │
│  FORM CRO           Optimiser les formulaires de capture         │
│  ════════                                                         │
│                                                                   │
│  POPUP CRO          Ameliorer popups, modals, overlays           │
│  ═════════                                                        │
│                                                                   │
│  PAYWALL CRO        Optimiser paywalls et upsells                │
│  ═══════════                                                      │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

## 1. Page CRO

### Checklist landing page

| # | Element | Bonnes pratiques |
|---|---------|-----------------|
| 1 | **Headline** | Benefice clair en < 10 mots, pas de jargon |
| 2 | **Sub-headline** | Expliquer le "comment" en 1 phrase |
| 3 | **CTA primaire** | Action specifique, visible above-the-fold |
| 4 | **Social proof** | Temoignages, logos clients, chiffres |
| 5 | **Objections** | FAQ ou sections repondant aux doutes |
| 6 | **Urgence/Rarete** | Timer, places limitees (si authentique) |
| 7 | **Visuel hero** | Screenshot produit ou demo video |
| 8 | **Navigation** | Minimale (pas de menu complet sur landing) |

### Patterns de conversion

```
Hero section (benefice + CTA)
    ↓
Social proof (logos, temoignages)
    ↓
Features/Benefits (3-5 max)
    ↓
How it works (3 etapes)
    ↓
Pricing (si applicable)
    ↓
FAQ (objections courantes)
    ↓
CTA final (meme action que le hero)
```

## 2. Signup Flow CRO

### Regles d'or

| # | Regle | Impact |
|---|-------|--------|
| 1 | Minimum de champs (email seul pour commencer) | +20-30% signups |
| 2 | Social login (Google, GitHub) | +15-25% signups |
| 3 | Pas de confirmation email bloquante | -40% drop-off |
| 4 | Progress indicator si multi-step | +10% completion |
| 5 | Proposition de valeur visible a cote du form | +15% signups |
| 6 | Password strength indicator | +5% completion |
| 7 | Error inline, pas au submit | +20% completion |

### Anti-patterns a eviter

- Demander trop d'info au signup (nom, tel, adresse)
- CAPTCHA visible pour tous les utilisateurs
- Email de confirmation avant acces au produit
- Redirection vers page de login apres signup
- Pas de feedback apres soumission du formulaire

## 3. Onboarding CRO

### Framework Time-to-Value

```
Signup → [Activation] → [Aha Moment] → [Habit Formation]
           |                |                |
           v                v                v
    Premier setup     Premiere valeur    Usage regulier
    (< 2 min)         (< 5 min)         (Jour 7+)
```

### Patterns efficaces

| Pattern | Quand | Exemple |
|---------|-------|---------|
| **Checklist** | 3-5 etapes d'activation | "Complete your profile: 3/5" |
| **Wizard** | Setup technique requis | "Connect your GitHub repo" |
| **Empty state** | Premiere visite page vide | "Create your first project" |
| **Template** | Produit complexe | "Start from a template" |
| **Tour guide** | Interface complexe | Tooltips de decouverte |

## 4. Form CRO

### Optimisation des formulaires

| # | Technique | Detail |
|---|-----------|--------|
| 1 | Un champ par ligne | Pas de layout multi-colonnes sur mobile |
| 2 | Labels au-dessus des champs | Pas de labels flottants |
| 3 | Input type correct | `email`, `tel`, `number` pour clavier adapte |
| 4 | Autocomplete HTML | `autocomplete="email"`, `"given-name"` |
| 5 | Taille de police >= 16px | Evite le zoom iOS |
| 6 | Bouton submit descriptif | "Create account" pas "Submit" |
| 7 | Feedback immediat | Validation au blur, pas au submit |
| 8 | Error recovery facile | Message + focus sur le champ en erreur |

## 5. Popup/Modal CRO

### Regles

| # | Regle | Detail |
|---|-------|--------|
| 1 | Timing: pas avant 30s ou 50% scroll | Laisser decouvrir le contenu |
| 2 | Exit-intent > time-based | Moins intrusif |
| 3 | Fermeture facile | X visible, click outside, Escape |
| 4 | Un seul popup a la fois | Pas de stack de modals |
| 5 | Frequence limitee | Max 1x par session ou 1x par semaine |
| 6 | Proposition de valeur claire | Pas juste "Subscribe" |
| 7 | Mobile: bottom sheet > modal centre | Meilleur UX mobile |

## 6. Paywall/Upgrade CRO

### Strategies

| Strategy | Detail | Quand |
|----------|--------|-------|
| **Feature gate** | Montrer la feature, bloquer l'acces | Feature premium demandee |
| **Usage limit** | "3/5 projects used" | Approche limite gratuite |
| **Trial expiration** | Countdown + valeur demontree | Fin de trial |
| **Upgrade prompt** | Suggestion contextuelle | Action premium tentee |
| **Social proof** | "Join 10,000+ teams" | Page pricing |

### Pricing page patterns

```
[ Free ]        [ Pro ★ ]        [ Enterprise ]
  $0              $29/mo           Custom
  3 projects      Unlimited        Unlimited
  1 user          10 users         Unlimited
  Basic support   Priority         Dedicated
                 [Start trial]
```

- Mettre en avant le plan recommande (badge, couleur)
- Toggle mensuel/annuel (montrer l'economie)
- Feature comparison table en dessous
- FAQ sur le billing

## Metriques a suivre

| Metrique | Formule | Cible |
|----------|---------|-------|
| **Conversion rate** | Conversions / Visiteurs | Depend du domaine |
| **Drop-off rate** | Abandons par etape du funnel | < 20% par etape |
| **Time to convert** | Duree visite → conversion | Reduire |
| **Bounce rate** | Rebonds / Sessions | < 40% landing pages |
| **Activation rate** | Users actives / Signups | > 40% |
| **Trial-to-paid** | Paiements / Trials | > 15% |

## Output attendu

```markdown
## Audit CRO : [Page/Flow]

### Taux de conversion estime actuel : X%
### Potentiel d'amelioration : +Y%

### Quick wins (impact immediat)
1. [Action] - Impact estime: +X%
2. [Action] - Impact estime: +X%

### Ameliorations structurelles
1. [Action] - Detail et implementation

### Tests A/B recommandes
1. [Hypothese] - Variante A vs B
```

## Regles

- Toujours baser les recommandations sur des donnees ou des best practices prouvees
- Proposer des quick wins ET des changements structurels
- Ne pas sacrifier l'UX pour la conversion (dark patterns interdits)
- Suggerer des tests A/B pour valider les changements importants
