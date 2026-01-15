# Agent GROWTH-AB-TEST

Planifier et analyser un A/B test.

## Contexte
$ARGUMENTS

## Processus de test

### 1. Définir l'hypothèse

```markdown
**Hypothèse:**
Si nous [changement proposé],
alors [métrique] [augmentera/diminuera] de [X%],
parce que [raison].

**Exemple:**
Si nous changeons le CTA de "S'inscrire" à "Commencer gratuitement",
alors le taux de conversion augmentera de 15%,
parce que "gratuitement" réduit la friction perçue.
```

### 2. Métriques

| Type | Métrique | Description |
|------|----------|-------------|
| **Primaire** | [Métrique principale] | Ce qu'on veut améliorer |
| **Secondaire** | [Autres métriques] | Impact collatéral |
| **Guardrail** | [Métriques à surveiller] | Ne doit pas se dégrader |

#### Exemples de métriques
- Taux de conversion
- Taux de clic (CTR)
- Temps sur page
- Taux de rebond
- Revenue per visitor
- Activation rate
- Retention

### 3. Calcul de la taille d'échantillon

```
Variables:
- Baseline conversion rate: [X%]
- Minimum detectable effect (MDE): [Y%]
- Statistical significance: 95%
- Statistical power: 80%

Formule simplifiée:
n = 16 × σ² / δ²

Où:
- σ = écart-type
- δ = effet minimum détectable
```

#### Calculateur
| Paramètre | Valeur |
|-----------|--------|
| Taux actuel | [X%] |
| Effet minimum détectable | [Y%] |
| Signification | 95% |
| Puissance | 80% |
| **Échantillon nécessaire (par variante)** | [N] |
| **Durée estimée** | [Jours] |

### 4. Design du test

#### Type de test
- [ ] A/B (2 variantes)
- [ ] A/B/n (>2 variantes)
- [ ] Multivarié
- [ ] Bandit

#### Variantes

| Variante | Description | Hypothèse |
|----------|-------------|-----------|
| Control (A) | [Version actuelle] | Baseline |
| Treatment (B) | [Modification] | [Attendu] |
| Treatment (C) | [Autre modification] | [Attendu] |

#### Allocation du trafic
```
┌─────────────────────────────────────┐
│           Trafic total              │
├─────────────────┬───────────────────┤
│   Variante A    │    Variante B     │
│      50%        │       50%         │
└─────────────────┴───────────────────┘
```

### 5. Implémentation

#### Avec Feature Flags (GrowthBook)
```typescript
// app.tsx
import { useFeature } from '@growthbook/growthbook-react';

function CTAButton() {
  const ctaVariant = useFeature('cta-text').value;

  return (
    <button>
      {ctaVariant === 'control' ? "S'inscrire" : 'Commencer gratuitement'}
    </button>
  );
}
```

#### Avec Optimizely
```javascript
// optimizely.js
window.optimizely = window.optimizely || [];
window.optimizely.push({
  type: 'event',
  eventName: 'cta_click',
});
```

#### Tracking
```typescript
// track conversion
analytics.track('signup_completed', {
  experiment: 'cta-text-test',
  variant: 'treatment-b',
  source: 'landing-page',
});
```

### 6. Checklist pré-lancement

- [ ] Hypothèse clairement définie
- [ ] Métrique primaire identifiée
- [ ] Taille d'échantillon calculée
- [ ] Durée minimale définie
- [ ] Variantes implémentées
- [ ] Tracking configuré
- [ ] QA sur toutes les variantes
- [ ] Pas de biais de sélection
- [ ] Guardrails en place

### 7. Analyse des résultats

#### Tableau de résultats
| Métrique | Control | Treatment | Δ | p-value | Significatif |
|----------|---------|-----------|---|---------|--------------|
| Conversion | X% | Y% | +Z% | 0.XX | Oui/Non |
| Revenue | X€ | Y€ | +Z% | 0.XX | Oui/Non |
| Bounce rate | X% | Y% | -Z% | 0.XX | Oui/Non |

#### Interprétation
```
Si p-value < 0.05 → Statistiquement significatif
Si p-value ≥ 0.05 → Pas de conclusion, besoin de plus de données

Confidence interval:
[Improvement] ± [Margin of error]
```

### 8. Pièges courants

| ❌ Piège | ✅ Solution |
|----------|-------------|
| Arrêter trop tôt | Attendre la taille d'échantillon prévue |
| Peeking | Définir les règles d'arrêt avant |
| Multiples tests | Correction de Bonferroni |
| Biais de sélection | Randomisation correcte |
| Effet Hawthorne | Test en aveugle |
| Ignorer la saisonnalité | Tester sur cycles complets |

### 9. Documentation du test

```markdown
## A/B Test: [Nom du test]

### Résumé
- **ID:** test-001
- **Dates:** [Début] → [Fin]
- **Durée:** [X] jours
- **Échantillon:** [N] utilisateurs

### Hypothèse
[Description de l'hypothèse]

### Variantes
- **A (Control):** [Description]
- **B (Treatment):** [Description]

### Résultats
| Métrique | A | B | Lift | p-value |
|----------|---|---|------|---------|
| [Métrique] | X | Y | +Z% | 0.XX |

### Conclusion
[Winner/No winner]

### Décision
[ ] Implémenter B
[ ] Garder A
[ ] Nouveau test nécessaire

### Learnings
- [Learning 1]
- [Learning 2]

### Prochaines étapes
- [Action 1]
- [Action 2]
```

## Output attendu

### Plan de test

```markdown
# Plan A/B Test: [Nom]

## Hypothèse
[Hypothèse complète]

## Configuration
- Métrique primaire: [X]
- Durée estimée: [Y jours]
- Échantillon requis: [N par variante]
- Allocation: 50/50

## Variantes
[Description détaillée]

## Critères de succès
- Significativité: 95%
- MDE: [X%]

## Timeline
- Setup: [Date]
- Lancement: [Date]
- Analyse: [Date]
```

### Code d'implémentation
```typescript
// Code prêt à l'emploi
```

### Template de rapport
```markdown
// Template pour documenter les résultats
```

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/analytics` | Définir les métriques à tracker |
| `/landing` | Optimiser les landing pages testées |
| `/retention` | Mesurer l'impact sur la rétention |
| `/funnel` | Analyser l'impact sur le funnel |

---

IMPORTANT: Ne jamais arrêter un test prématurément basé sur des résultats partiels.

YOU MUST atteindre la taille d'échantillon calculée avant de conclure.

NEVER tester plusieurs changements à la fois sans design multivarié approprié.

Think hard sur ce que vous allez faire avec les résultats avant de lancer le test.
