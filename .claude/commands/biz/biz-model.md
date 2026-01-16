# Agent BUSINESS

Analyse un projet pour proposer un business model et les éléments clés d'un business plan.

## Projet à analyser
$ARGUMENTS

## Processus d'analyse

### 1. Analyse technique du projet

#### Explorer le codebase
```bash
# Structure du projet
tree -L 2 -I 'node_modules|.git|dist|build|coverage'

# Dépendances et stack
cat package.json 2>/dev/null || cat requirements.txt 2>/dev/null || cat Cargo.toml 2>/dev/null

# Documentation existante
cat README.md 2>/dev/null
```

#### Identifier les fonctionnalités
- [ ] Features principales (ce que fait le produit)
- [ ] Features secondaires (nice-to-have)
- [ ] Intégrations externes (APIs, services tiers)
- [ ] Données manipulées (type, volume, sensibilité)

#### Évaluer la maturité technique
- [ ] Tests présents ? Couverture ?
- [ ] CI/CD configuré ?
- [ ] Documentation technique ?
- [ ] Scalabilité de l'architecture ?

### 2. Analyse de la proposition de valeur

#### Questions clés
- Quel problème ce projet résout-il ?
- Pour qui ? (persona cible)
- Quelle est l'alternative actuelle ? (concurrence, solutions manuelles)
- Quel est l'avantage différenciant ?

#### Recherche marché (si pertinent)
- Rechercher des solutions similaires existantes
- Identifier le positionnement possible
- Estimer la taille du marché potentiel

### 3. Estimation des coûts techniques

#### Infrastructure
| Composant | Estimation mensuelle |
|-----------|---------------------|
| Hosting (serveurs) | [À estimer selon stack] |
| Base de données | [À estimer selon volume] |
| CDN / Storage | [À estimer selon usage] |
| Services tiers | [APIs, SaaS utilisés] |
| **Total estimé** | **[Fourchette]** |

#### Maintenance
- Temps développeur estimé pour maintenance
- Coûts de sécurité et mises à jour
- Support technique

### 4. Business Models possibles

#### Évaluer chaque modèle
Pour chaque modèle, analyser :
- Compatibilité avec le produit
- Complexité d'implémentation
- Potentiel de revenus
- Risques

#### Modèles à considérer
- [ ] **SaaS** (abonnement mensuel/annuel)
- [ ] **Freemium** (gratuit + premium)
- [ ] **Pay-per-use** (facturation à l'usage)
- [ ] **Licence** (vente one-shot ou licence annuelle)
- [ ] **Open-core** (core open source + features payantes)
- [ ] **Marketplace** (commission sur transactions)
- [ ] **API-as-a-Service** (facturation aux appels API)
- [ ] **White-label** (revente en marque blanche)

### 5. Lean Canvas

Remplir le Lean Canvas basé sur l'analyse :

```
┌─────────────────┬─────────────────┬─────────────────┐
│ PROBLÈME        │ SOLUTION        │ PROPOSITION     │
│                 │                 │ DE VALEUR       │
│ - Problème 1    │ - Solution 1    │ UNIQUE          │
│ - Problème 2    │ - Solution 2    │                 │
│ - Problème 3    │ - Solution 3    │ [Message clé]   │
├─────────────────┼─────────────────┼─────────────────┤
│ MÉTRIQUES CLÉS  │                 │ AVANTAGE        │
│                 │                 │ COMPÉTITIF      │
│ - Métrique 1    │   CANAUX        │                 │
│ - Métrique 2    │                 │ [Ce qui ne peut │
│                 │ - Canal 1       │  pas être copié │
├─────────────────┤ - Canal 2       │  facilement]    │
│ STRUCTURE       │                 │                 │
│ DE COÛTS        ├─────────────────┼─────────────────┤
│                 │ SEGMENTS        │ SOURCES DE      │
│ - Coût 1        │ CLIENTS         │ REVENUS         │
│ - Coût 2        │                 │                 │
│ - Coût 3        │ - Segment 1     │ - Revenu 1      │
│                 │ - Segment 2     │ - Revenu 2      │
└─────────────────┴─────────────────┴─────────────────┘
```

## Output attendu

### Résumé exécutif
```
Projet: [nom]
Proposition de valeur: [une phrase]
Marché cible: [segment principal]
Business model recommandé: [modèle + justification courte]
```

### Analyse SWOT
| Forces | Faiblesses |
|--------|------------|
| - ... | - ... |

| Opportunités | Menaces |
|--------------|---------|
| - ... | - ... |

### Business Models recommandés
1. **[Modèle principal]** - [Justification]
   - Pricing suggéré : [fourchette]
   - Complexité d'implémentation : [faible/moyenne/haute]

2. **[Modèle alternatif]** - [Justification]
   - Pricing suggéré : [fourchette]
   - Complexité d'implémentation : [faible/moyenne/haute]

### Lean Canvas complété
[Canvas rempli selon template ci-dessus]

### Estimation financière préliminaire
| Élément | Estimation |
|---------|------------|
| Coûts mensuels infrastructure | [fourchette] |
| Coûts mensuels maintenance | [fourchette] |
| Prix cible client | [fourchette] |
| Clients nécessaires pour rentabilité | [nombre] |

### Prochaines étapes recommandées
1. [Action 1]
2. [Action 2]
3. [Action 3]

### Risques identifiés
- [Risque 1] → [Mitigation]
- [Risque 2] → [Mitigation]

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/mvp` | Définir le MVP après le business model |
| `/market` | Approfondir l'étude de marché |
| `/pricing` | Définir la stratégie de prix |
| `/pitch` | Préparer un pitch deck |
| `/roadmap` | Planifier la roadmap produit |

---

IMPORTANT: Cette analyse est basée uniquement sur le code et les informations disponibles. Elle ne remplace pas une étude de marché approfondie.

YOU MUST rechercher des concurrents et solutions alternatives si le contexte le permet.

NEVER promettre des chiffres de revenus ou de croissance - fournir uniquement des estimations et fourchettes.

Think hard sur la proposition de valeur et le positionnement marché avant de proposer un business model.
