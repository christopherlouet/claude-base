---
sidebar_position: 10
title: "/growth:growth-onboarding"
description: "Concevoir un parcours d'onboarding utilisateur efficace."
tags:
  - "growth"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--growth">GROWTH</span>


# Agent UX-ONBOARDING

Concevoir un parcours d'onboarding utilisateur efficace.

## Contexte
`&lt;arguments&gt;`

## Processus de conception

### 1. Comprendre le produit

#### Explorer le projet
```bash
# Structure de l'app
tree -L 2 -I 'node_modules|.git|dist' src/ 2>/dev/null

# Rechercher l'onboarding existant
grep -rn "onboard\|welcome\|setup\|wizard\|tour" --include="*.ts" --include="*.tsx" | head -20
```

#### Questions clés
- Quelle est la proposition de valeur principale ?
- Quel est le "Aha moment" ? (quand l'utilisateur comprend la valeur)
- Quelles sont les actions essentielles pour activer l'utilisateur ?
- Quel est le Time to Value actuel ?

### 2. Définir le parcours utilisateur

#### User Journey Map
```
Inscription → Welcome → Setup → First Action → Aha Moment → Activation
     │           │         │          │             │            │
   [État]     [État]    [État]     [État]        [État]       [État]
   [Émotion]  [Émotion] [Émotion]  [Émotion]     [Émotion]    [Émotion]
   [Action]   [Action]  [Action]   [Action]      [Action]     [Action]
```

#### Étapes critiques
| Étape | Objectif | Métrique de succès |
|-------|----------|-------------------|
| Inscription | Créer un compte | Taux de complétion |
| Welcome | Comprendre le produit | Clic sur CTA |
| Setup | Configurer l'essentiel | Setup complété |
| First Action | Première action clé | Action réalisée |
| Aha Moment | Réaliser la valeur | [Métrique spécifique] |

### 3. Patterns d'onboarding

#### Types d'onboarding

| Pattern | Description | Quand l'utiliser |
|---------|-------------|------------------|
| **Welcome screens** | Slides de présentation | App mobile, produit simple |
| **Product tour** | Guide interactif | Interface complexe |
| **Checklist** | Liste de tâches | Plusieurs actions requises |
| **Progressive disclosure** | Découverte progressive | Produit riche en features |
| **Empty states** | Guidance via états vides | Contenu généré par l'utilisateur |
| **Tooltips** | Bulles d'aide contextuelles | Features spécifiques |
| **Coach marks** | Spots lumineux sur UI | Première visite |
| **Wizard** | Étapes guidées | Setup complexe |

#### Recommandation par type de produit
```
Produit simple          →  Welcome screens + Empty states
Produit complexe        →  Product tour + Checklist
SaaS B2B               →  Wizard setup + Checklist
App mobile             →  Welcome screens + Tooltips
Outil collaboration    →  Checklist + Invite flow
```

### 4. Concevoir l'onboarding

#### Écran de bienvenue
```
┌─────────────────────────────────────┐
│                                     │
│         [Illustration/Logo]         │
│                                     │
│     Bienvenue sur [Produit] !       │
│                                     │
│   [Proposition de valeur courte]    │
│                                     │
│      [ Commencer →]                 │
│                                     │
│         ○ ○ ○ (progress)            │
└─────────────────────────────────────┘
```

#### Checklist d'activation
```
┌─────────────────────────────────────┐
│  Configurez votre compte            │
│  ████████░░░░░░░░░░ 40%             │
├─────────────────────────────────────┤
│  ✓ Créer votre compte               │
│  ✓ Confirmer votre email            │
│  ○ Compléter votre profil      →    │
│  ○ [Action clé 1]              →    │
│  ○ [Action clé 2]              →    │
│  ○ Inviter un collègue         →    │
└─────────────────────────────────────┘
```

#### Product Tour
```typescript
const tourSteps = [
  {
    target: '#dashboard',
    title: 'Votre tableau de bord',
    content: 'Retrouvez toutes vos métriques ici.',
    placement: 'bottom',
  },
  {
    target: '#create-button',
    title: 'Créez votre premier projet',
    content: 'Cliquez ici pour commencer.',
    placement: 'left',
    action: 'highlight',
  },
  // ...
];
```

### 5. Réduire les frictions

#### Inscription
- [ ] Inscription en 1 clic (Google, GitHub, etc.)
- [ ] Formulaire minimal (email + mot de passe max)
- [ ] Pas de confirmation email bloquante
- [ ] Accès immédiat après inscription

#### Setup
- [ ] Pré-remplir quand possible
- [ ] Valeurs par défaut intelligentes
- [ ] Permettre de "Skip" les étapes non essentielles
- [ ] Progress bar visible
- [ ] Possibilité de revenir en arrière

#### First Action
- [ ] Guider vers l'action sans forcer
- [ ] Exemple/template pour démarrer
- [ ] Feedback positif immédiat
- [ ] Célébration des micro-accomplissements

### 6. Empty States

#### Avant la première action
```
┌─────────────────────────────────────┐
│                                     │
│        [Illustration]               │
│                                     │
│   Aucun [élément] pour l'instant    │
│                                     │
│   [Explication courte de la         │
│    valeur de créer un élément]      │
│                                     │
│   [ + Créer votre premier [X] ]     │
│                                     │
│   💡 Astuce : [Conseil contextuel]  │
└─────────────────────────────────────┘
```

### 7. Personnalisation

#### Segmentation à l'inscription
```
┌─────────────────────────────────────┐
│  Comment allez-vous utiliser [App]? │
├─────────────────────────────────────┤
│  [ ] Pour un projet personnel       │
│  [ ] Pour mon équipe                │
│  [ ] Pour mon entreprise            │
├─────────────────────────────────────┤
│  Quel est votre rôle ?              │
│  [Développeur ▼]                    │
└─────────────────────────────────────┘
```

Utiliser ces données pour :
- Personnaliser le parcours
- Adapter les exemples
- Prioriser les features montrées

### 8. Métriques d'onboarding

| Métrique | Description | Cible |
|----------|-------------|-------|
| **Completion rate** | % ayant fini l'onboarding | &gt; 70% |
| **Time to complete** | Temps pour finir | &lt; 5 min |
| **Drop-off points** | Où les users abandonnent | Identifier |
| **Activation rate** | % ayant fait l'action clé | &gt; 50% |
| **Time to value** | Temps avant le "Aha" | &lt; 10 min |
| **D1/D7 retention** | Retour J1 et J7 | &gt; 40%/20% |

### 9. Implémentation technique

#### Librairies recommandées
| Besoin | React | Vue | Vanilla |
|--------|-------|-----|---------|
| Product tour | react-joyride | vue-tour | shepherd.js |
| Tooltips | react-tooltip | v-tooltip | tippy.js |
| Modals | radix-ui | headlessui | - |

#### Exemple avec react-joyride
```typescript
import Joyride from 'react-joyride';

const OnboardingTour = () => {
  const [run, setRun] = useState(true);

  const steps = [
    {
      target: '.dashboard',
      content: 'Bienvenue ! Voici votre tableau de bord.',
      disableBeacon: true,
    },
    {
      target: '.create-button',
      content: 'Cliquez ici pour créer votre premier projet.',
    },
  ];

  return (
    <Joyride
      steps={steps}
      run={run}
      continuous
      showProgress
      showSkipButton
      callback={(data) => {
        if (data.status === 'finished') {
          markOnboardingComplete();
        }
      }}
    />
  );
};
```

#### Tracking des étapes
```typescript
// Tracker l'avancement
analytics.track('onboarding_step_completed', {
  step: 'profile_setup',
  step_number: 2,
  total_steps: 5,
});

// Tracker l'abandon
analytics.track('onboarding_abandoned', {
  last_step: 'invite_team',
  completion_rate: 0.6,
});
```

## Output attendu

### Parcours utilisateur

```
[Inscription] → [Welcome] → [Setup] → [First Action] → [Aha]
     2s           10s         1min        30s           -
```

### Étapes d'onboarding

| Étape | Type | Contenu | Skip possible ? |
|-------|------|---------|-----------------|
| 1. Welcome | Screen | | Non |
| 2. [Étape] | | | |
| ... | | | |

### Wireframes / Maquettes
[Descriptions détaillées de chaque écran]

### Checklist utilisateur
```markdown
- [ ] [Action 1]
- [ ] [Action 2]
- [ ] [Action 3]
```

### Empty states
[Contenu pour chaque état vide]

### Implémentation
[Composants et code à créer]

### Métriques à suivre
| Métrique | Outil | Cible |
|----------|-------|-------|
| | | |

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/growth:growth-analytics` | Tracker les étapes d'onboarding |
| `/growth:growth-retention` | Mesurer l'impact sur la rétention |
| `/growth:growth-email` | Séquence d'emails d'accompagnement |
| `/dev:dev-component` | Créer les composants UI |
| `/qa:qa-a11y` | Accessibilité du parcours |

---

IMPORTANT: L'objectif n°1 est d'amener l'utilisateur au "Aha moment" le plus vite possible.

YOU MUST permettre de skip les étapes non essentielles - certains users veulent explorer seuls.

NEVER bloquer l'accès au produit avec un onboarding trop long - max 3-5 étapes obligatoires.

Think hard sur le "Aha moment" - c'est LA métrique clé de l'onboarding.


---

## Voir aussi

- [Retour aux commandes GROWTH](/docs/commands/growth)
- [Toutes les commandes](/docs/commands)
