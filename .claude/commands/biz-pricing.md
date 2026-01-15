# Agent PRICING

Définir la stratégie de pricing pour un produit ou service.

## Contexte
$ARGUMENTS

## Processus d'analyse

### 1. Comprendre le produit

#### Analyser le projet
```bash
cat README.md 2>/dev/null
cat package.json 2>/dev/null
```

#### Questions clés
- Quelle valeur le produit apporte-t-il ?
- Quel gain (temps, argent, productivité) pour l'utilisateur ?
- Quelle est la cible ? (B2B, B2C, B2B2C)
- Quel est le modèle de coûts ?

### 2. Analyse des coûts

#### Coûts fixes mensuels
| Poste | Coût estimé |
|-------|-------------|
| Infrastructure (hosting, DB) | |
| Services tiers (APIs, SaaS) | |
| Domaine, SSL, CDN | |
| **Total fixe** | |

#### Coûts variables (par utilisateur/transaction)
| Poste | Coût unitaire |
|-------|---------------|
| Stockage additionnel | |
| Bande passante | |
| Transactions (Stripe ~2.9%) | |
| Support client | |
| **Total variable** | |

#### Seuil de rentabilité
```
Seuil = Coûts fixes / (Prix - Coûts variables)
```

### 3. Analyse de la concurrence

| Concurrent | Modèle | Prix entrée | Prix moyen | Prix premium |
|------------|--------|-------------|------------|--------------|
| [Nom 1] | [SaaS/Usage/...] | | | |
| [Nom 2] | | | | |
| [Nom 3] | | | | |

#### Positionnement prix
```
        Bas                              Élevé
         │                                  │
         ▼                                  ▼
    [Concurrent A]    [Nous?]    [Concurrent B]
         │               │              │
    Budget-friendly   Value        Premium
```

### 4. Modèles de pricing

#### Évaluer chaque modèle

| Modèle | Avantages | Inconvénients | Adapté si... |
|--------|-----------|---------------|--------------|
| **Flat rate** | Simple, prévisible | Pas flexible | Valeur uniforme |
| **Par paliers** | Upsell naturel | Complexity | Segments différents |
| **Par utilisateur** | Scale avec équipe | Frein adoption | B2B, collaboration |
| **Par usage** | Juste, accessible | Revenus imprévisibles | Consommation variable |
| **Freemium** | Acquisition facile | Conversion difficile | Effet viral possible |
| **Essai gratuit** | Démontre la valeur | Coût d'acquisition | Produit complexe |

### 5. Structure de pricing recommandée

#### Modèle à paliers (exemple)
```
┌─────────────┬─────────────┬─────────────┐
│    FREE     │    PRO      │  BUSINESS   │
├─────────────┼─────────────┼─────────────┤
│   0€/mois   │  XX€/mois   │  XX€/mois   │
├─────────────┼─────────────┼─────────────┤
│ Feature 1   │ Feature 1   │ Feature 1   │
│ Feature 2   │ Feature 2   │ Feature 2   │
│ Limite: X   │ Feature 3   │ Feature 3   │
│             │ Limite: Y   │ Feature 4   │
│             │             │ Illimité    │
│             │             │ Support     │
└─────────────┴─────────────┴─────────────┘
```

### 6. Psychologie du pricing

#### Techniques à considérer
- [ ] **Ancrage** : Montrer le plan le plus cher en premier
- [ ] **Decoy** : Un plan "leurre" pour pousser vers le milieu
- [ ] **Prix psychologiques** : 29€ vs 30€
- [ ] **Annuel vs Mensuel** : -20% sur annuel (engagement)
- [ ] **Par valeur, pas par coût** : Facturer selon le ROI client

#### Éléments de la page pricing
- [ ] Comparaison claire des plans
- [ ] CTA différencié par plan
- [ ] FAQ pricing
- [ ] Garantie satisfait ou remboursé
- [ ] Social proof / logos clients

### 7. Métriques à suivre

| Métrique | Description | Cible |
|----------|-------------|-------|
| **ARPU** | Revenu moyen par utilisateur | |
| **LTV** | Valeur vie client | > 3× CAC |
| **CAC** | Coût d'acquisition client | |
| **Churn** | Taux d'attrition mensuel | < 5% |
| **Conversion** | Free → Paid | > 2-5% |
| **Expansion** | Upsell/upgrade | |

### 8. Tests et itération

#### Stratégies de test
- [ ] A/B test sur la page pricing
- [ ] Interviews utilisateurs sur willingness-to-pay
- [ ] Grandfather existing users lors des changements
- [ ] Augmenter les prix progressivement

## Output attendu

### Recommandation de pricing

```
Modèle recommandé: [type]
Cible principale: [segment]
Positionnement: [budget/value/premium]
```

### Grille tarifaire proposée

| Plan | Prix/mois | Prix/an | Cible | Fonctionnalités clés |
|------|-----------|---------|-------|---------------------|
| [Free/Starter] | | | | |
| [Pro] | | | | |
| [Business/Enterprise] | | | | |

### Justification
- Prix basé sur : [valeur/coût/concurrence]
- Différenciation par : [features/limites/support]
- Conversion attendue : [%]

### Analyse financière

| Scénario | Utilisateurs | ARPU | MRR | Rentabilité |
|----------|--------------|------|-----|-------------|
| Pessimiste | | | | |
| Réaliste | | | | |
| Optimiste | | | | |

### Risques et mitigations
| Risque | Mitigation |
|--------|------------|
| Prix trop élevé | [Action] |
| Prix trop bas | [Action] |
| Churn élevé | [Action] |

### Roadmap pricing
1. Lancement : [stratégie]
2. 3 mois : [ajustements]
3. 6 mois : [évolutions]

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/model` | Business model global |
| `/market` | Étude de marché et concurrence |
| `/ab-test` | Tester différents prix |
| `/analytics` | Mesurer l'impact du pricing |
| `/launch` | Lancement avec le pricing |

---

IMPORTANT: Le pricing est une hypothèse - il devra être testé et ajusté.

YOU MUST calculer le seuil de rentabilité avant de proposer un prix.

NEVER sous-estimer la valeur - les clients B2B paient pour le ROI, pas le coût.

Think hard sur la valeur perçue par le client vs le coût de production.
