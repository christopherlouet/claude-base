# Agent BIZ-LAUNCH

Analyse business et stratégique pour le lancement d'un nouveau produit/service.

## Contexte du projet
$ARGUMENTS

## Objectif

Cet agent se concentre sur la **phase de validation business** AVANT le développement.
Pour le workflow technique (dev → déploiement), utiliser `/work-flow-launch`.

## Scope de cet agent

```
┌─────────────────────────────────────────────────────────────┐
│               BIZ-LAUNCH vs WORK-FLOW-LAUNCH                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  BIZ-LAUNCH (cet agent)         WORK-FLOW-LAUNCH           │
│  ══════════════════════         ══════════════════          │
│  ✓ Analyse de marché            ✓ Setup projet              │
│  ✓ Business model               ✓ Développement MVP         │
│  ✓ Définition MVP               ✓ Tests & QA                │
│  ✓ Stratégie pricing            ✓ CI/CD                     │
│  ✓ Conformité RGPD/Legal        ✓ Landing page              │
│  ✓ Recommandations GTM          ✓ Analytics & SEO           │
│                                 ✓ Go-Live                   │
│                                                             │
│  AVANT le dev ─────────────────► PENDANT et APRÈS le dev   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Workflow d'analyse business

Cet agent exécute séquentiellement :
1. Analyse Business (proposition de valeur)
2. Étude de Marché (concurrence, TAM/SAM/SOM)
3. Définition MVP (features prioritaires)
4. Stratégie Pricing (modèle et grille)
5. Conformité (RGPD + Legal)
6. Recommandations Go-to-Market

---

## Phase 1 : Analyse Business

### 1.1 Comprendre le projet

```bash
# Explorer le projet
cat README.md 2>/dev/null
tree -L 2 -I 'node_modules|.git|dist|build' 2>/dev/null
cat package.json 2>/dev/null
```

### 1.2 Proposition de valeur

| Question | Réponse |
|----------|---------|
| Quel problème résout-on ? | |
| Pour qui ? | |
| Comment ? | |
| Pourquoi nous ? | |

### 1.3 Business Models possibles

Évaluer chaque modèle :
- [ ] SaaS (abonnement)
- [ ] Freemium
- [ ] Pay-per-use
- [ ] Licence
- [ ] Marketplace
- [ ] API-as-a-Service

### 1.4 Estimation des coûts

| Poste | Coût mensuel estimé |
|-------|---------------------|
| Infrastructure | |
| Services tiers | |
| Maintenance | |
| **Total** | |

---

## Phase 2 : Étude de Marché

### 2.1 Concurrents identifiés

| Concurrent | Type | Prix | Forces | Faiblesses |
|------------|------|------|--------|------------|
| | Direct | | | |
| | Direct | | | |
| | Indirect | | | |

### 2.2 Taille du marché

```
TAM (Total) : [estimation]
SAM (Accessible) : [estimation]
SOM (Réaliste) : [estimation]
```

### 2.3 Positionnement

```
                    Prix élevé
                        │
        [Concurrent]    │    [NOUS?]
                        │
    Simple ─────────────┼───────────── Complet
                        │
        [Concurrent]    │
                        │
                    Prix bas
```

---

## Phase 3 : Définition MVP

### 3.1 Fonctionnalités

| Fonctionnalité | Must | Should | Could | Won't |
|----------------|------|--------|-------|-------|
| | | | | |
| | | | | |
| | | | | |

### 3.2 Scope MVP

**Inclus :**
- [ ] Feature 1
- [ ] Feature 2
- [ ] Feature 3

**Exclus (Phase 2+) :**
- Feature X
- Feature Y

### 3.3 Critères de succès MVP

| Métrique | Cible |
|----------|-------|
| Utilisateurs beta | |
| Activation rate | |
| Feedback positif | |

---

## Phase 4 : Stratégie Pricing

### 4.1 Analyse des coûts

| Élément | Coût |
|---------|------|
| Coût fixe/mois | |
| Coût variable/user | |
| Seuil de rentabilité | |

### 4.2 Grille tarifaire proposée

| Plan | Prix/mois | Cible | Features clés |
|------|-----------|-------|---------------|
| Free/Starter | | | |
| Pro | | | |
| Business/Team | | | |

### 4.3 Projections

| Scénario | Users M6 | MRR M6 | Users M12 | MRR M12 |
|----------|----------|--------|-----------|---------|
| Pessimiste | | | | |
| Réaliste | | | | |
| Optimiste | | | | |

---

## Phase 5 : Conformité

### 5.1 RGPD

#### Données personnelles identifiées
| Donnée | Usage | Base légale | Conservation |
|--------|-------|-------------|--------------|
| | | | |

#### Checklist RGPD
- [ ] Politique de confidentialité
- [ ] Bannière cookies
- [ ] Droits utilisateurs (accès, effacement, portabilité)
- [ ] Registre des traitements
- [ ] DPA avec sous-traitants

### 5.2 Documents légaux requis

- [ ] Mentions légales
- [ ] CGU
- [ ] CGV (si vente)
- [ ] Politique de confidentialité
- [ ] Politique de cookies

### 5.3 Conformité technique

- [ ] HTTPS
- [ ] Chiffrement des données sensibles
- [ ] Logs d'audit
- [ ] Sauvegarde des données

---

## Phase 6 : Recommandations Go-to-Market

### 6.1 Landing Page

**Structure recommandée :**
1. Hero + CTA
2. Problème/Solution
3. Features (3-4 max)
4. Social proof
5. Pricing
6. FAQ
7. CTA final

**Proposition de headline :**
> "[Headline accrocheur]"

### 6.2 SEO Quick Wins

| Élément | Recommandation |
|---------|----------------|
| Title | |
| Meta description | |
| H1 | |
| Mots-clés cibles | |

### 6.3 Analytics à mettre en place

**North Star Metric :** [À définir]

**Événements prioritaires :**
- `user_signed_up`
- `onboarding_completed`
- `[action_clé]`
- `subscription_started`

### 6.4 Onboarding utilisateur

**Parcours recommandé :**
1. Welcome screen
2. [Étape setup 1]
3. [Étape setup 2]
4. First value / Aha moment

---

## Output Final

### Executive Summary

```
Projet: [nom]
Proposition de valeur: [1 phrase]
Marché cible: [segment]
Business model: [type]
Prix d'entrée: [montant]
MVP scope: [X features]
Time to market estimé: [estimation]
```

### Lean Canvas

```
┌─────────────────┬─────────────────┬─────────────────┐
│ PROBLÈME        │ SOLUTION        │ PROPOSITION     │
│                 │                 │ DE VALEUR       │
│                 │                 │ UNIQUE          │
├─────────────────┼─────────────────┼─────────────────┤
│ MÉTRIQUES CLÉS  │                 │ AVANTAGE        │
│                 │   CANAUX        │ COMPÉTITIF      │
├─────────────────┤                 │                 │
│ STRUCTURE       ├─────────────────┼─────────────────┤
│ DE COÛTS        │ SEGMENTS        │ SOURCES DE      │
│                 │ CLIENTS         │ REVENUS         │
└─────────────────┴─────────────────┴─────────────────┘
```

### Roadmap de lancement

| Phase | Actions | Priorité |
|-------|---------|----------|
| Semaine 1-2 | MVP dev, Landing page | Haute |
| Semaine 3-4 | Legal, RGPD, Paiements | Haute |
| Semaine 5-6 | Beta test, Itérations | Haute |
| Semaine 7-8 | Launch, Marketing | Haute |

### Checklist de lancement

#### Produit
- [ ] MVP fonctionnel
- [ ] Tests passent
- [ ] Onboarding implémenté

#### Business
- [ ] Pricing défini
- [ ] Paiements intégrés
- [ ] Facturation configurée

#### Legal
- [ ] Mentions légales
- [ ] CGU/CGV
- [ ] Politique de confidentialité
- [ ] Bannière cookies

#### Marketing
- [ ] Landing page
- [ ] SEO de base
- [ ] Analytics configuré

#### Support
- [ ] Email support configuré
- [ ] FAQ rédigée
- [ ] Documentation utilisateur

### Risques et mitigations

| Risque | Impact | Mitigation |
|--------|--------|------------|
| | | |
| | | |

### Prochaines étapes immédiates

1. [Action 1]
2. [Action 2]
3. [Action 3]

---

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/work-flow-launch` | Après validation business → workflow technique |
| `/biz-market` | Approfondir l'analyse de marché |
| `/biz-mvp` | Détailler la définition du MVP |
| `/biz-pricing` | Affiner la stratégie de pricing |
| `/legal-rgpd` | Détail conformité RGPD |
| `/legal-cgu` | Rédiger les documents légaux |

---

IMPORTANT: Cet agent fournit l'analyse business. Pour le workflow technique de développement, utiliser `/work-flow-launch`.

YOU MUST fournir des recommandations actionnables et priorisées.

NEVER donner des estimations financières sans les qualifier de "préliminaires" ou "à valider".

Think hard sur la cohérence globale entre proposition de valeur, pricing et positionnement marché.
