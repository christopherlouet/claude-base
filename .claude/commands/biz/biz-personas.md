# Agent PERSONAS

Crée des personas utilisateur détaillés et actionnables pour guider les décisions produit.

## Contexte
$ARGUMENTS

## Objectif

Développer des personas utilisateur basés sur des données réelles qui servent
de référence pour toutes les décisions de conception, développement et marketing.

## Méthodologie de création

```
┌─────────────────────────────────────────────────────────────┐
│                    PERSONA CREATION                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. RECHERCHER    → Collecter données utilisateurs         │
│  ════════════                                               │
│                                                             │
│  2. ANALYSER      → Identifier patterns et segments        │
│  ══════════                                                 │
│                                                             │
│  3. SYNTHÉTISER   → Créer profils représentatifs           │
│  ═════════════                                              │
│                                                             │
│  4. VALIDER       → Tester avec données réelles            │
│  ══════════                                                 │
│                                                             │
│  5. DOCUMENTER    → Formaliser et partager                 │
│  ═════════════                                              │
│                                                             │
│  6. ITÉRER        → Mettre à jour régulièrement            │
│  ══════════                                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Étape 1 : Sources de données

### Sources quantitatives

| Source | Données | Usage |
|--------|---------|-------|
| **Analytics** | Comportements, parcours, devices | Segmentation |
| **CRM** | Profils, historique, valeur | Caractéristiques |
| **Enquêtes** | Réponses structurées | Motivations |
| **A/B Tests** | Préférences | Comportements |

### Sources qualitatives

| Source | Données | Usage |
|--------|---------|-------|
| **Interviews** | Verbatims, émotions | Jobs-to-be-done |
| **Support** | Problèmes récurrents | Pain points |
| **Feedback** | Suggestions, plaintes | Besoins |
| **Observations** | Usage réel | Contexte |

### Questions clés pour les interviews

```markdown
## Guide d'interview utilisateur

### Contexte
1. Décrivez une journée type dans votre travail/vie
2. Quels outils utilisez-vous quotidiennement ?
3. Comment avez-vous découvert notre produit ?

### Problème
4. Quel problème cherchiez-vous à résoudre ?
5. Comment faisiez-vous avant ?
6. Qu'est-ce qui était le plus frustrant ?

### Solution
7. Comment notre produit vous aide-t-il ?
8. Quelle fonctionnalité utilisez-vous le plus ?
9. Que manque-t-il selon vous ?

### Décision
10. Qui d'autre est impliqué dans la décision d'achat ?
11. Quels critères étaient importants ?
12. Qu'est-ce qui pourrait vous faire partir ?
```

## Étape 2 : Template de Persona

### Structure complète

```markdown
# Persona : [Nom]

![Photo placeholder]

## Identité

| Attribut | Valeur |
|----------|--------|
| **Nom** | [Prénom Nom] |
| **Âge** | [XX] ans |
| **Poste** | [Titre] |
| **Entreprise** | [Type/Taille] |
| **Localisation** | [Ville/Pays] |
| **Segment** | [Ex: PME Tech, Enterprise, Freelance] |

## Citation caractéristique

> "[Une phrase qui résume son mindset et ses priorités]"

## Profil

### Background
[2-3 phrases sur son parcours et son contexte actuel]

### Responsabilités
- [Responsabilité 1]
- [Responsabilité 2]
- [Responsabilité 3]

### Une journée type
[Description d'une journée représentative]

## Objectifs et motivations

### Objectifs professionnels
1. [Objectif principal]
2. [Objectif secondaire]
3. [Objectif tertiaire]

### Motivations profondes
| Motivation | Importance |
|------------|------------|
| [Ex: Gain de temps] | ⭐⭐⭐⭐⭐ |
| [Ex: Reconnaissance] | ⭐⭐⭐⭐ |
| [Ex: Évolution] | ⭐⭐⭐ |

### KPIs personnels
- [Métrique 1 qu'il/elle suit]
- [Métrique 2]

## Frustrations et pain points

### Pain points majeurs
| Problème | Impact | Fréquence |
|----------|--------|-----------|
| [Pain point 1] | Élevé | Quotidien |
| [Pain point 2] | Moyen | Hebdomadaire |
| [Pain point 3] | Faible | Mensuel |

### Verbatims typiques
- "[Citation réelle d'interview ou support]"
- "[Autre citation]"

## Comportements

### Usage technologique
| Aspect | Détail |
|--------|--------|
| **Devices** | [Desktop, Mobile, Tablet] |
| **OS** | [Windows, Mac, iOS, Android] |
| **Apps favorites** | [Slack, Notion, etc.] |
| **Réseaux sociaux** | [LinkedIn, Twitter, etc.] |

### Processus de décision
| Étape | Comportement |
|-------|--------------|
| **Découverte** | [Comment il/elle trouve des solutions] |
| **Évaluation** | [Critères de choix] |
| **Décision** | [Qui décide, comment] |
| **Adoption** | [Comment il/elle adopte] |

### Canaux préférés
- Information : [Blog, Newsletter, Podcast...]
- Communication : [Email, Chat, Téléphone...]
- Achat : [Self-service, Commercial, Démo...]

## Relation avec notre produit

### Jobs-to-be-done
| Job | Importance | Satisfaction actuelle |
|-----|------------|----------------------|
| [Job 1] | Haute | ⭐⭐⭐ |
| [Job 2] | Moyenne | ⭐⭐⭐⭐ |
| [Job 3] | Haute | ⭐⭐ |

### Fonctionnalités clés
1. [Feature la plus utilisée]
2. [Feature importante]
3. [Feature désirée mais manquante]

### Objections potentielles
- "[Objection 1]" → [Réponse]
- "[Objection 2]" → [Réponse]

## Scénarios d'usage

### Scénario principal
**Contexte :** [Situation déclencheur]
**Action :** [Ce qu'il/elle fait avec le produit]
**Résultat attendu :** [Ce qu'il/elle veut obtenir]
**Émotion :** [Comment il/elle se sent]

### Scénario secondaire
[Même structure]

## Implications pour le produit

### Features prioritaires
| Feature | Impact pour ce persona |
|---------|----------------------|
| [Feature A] | Résout [pain point] |
| [Feature B] | Améliore [workflow] |

### UX/UI considerations
- [Préférence 1]
- [Préférence 2]

### Messages marketing
- Hook : "[Message d'accroche efficace]"
- Proposition de valeur : "[Bénéfice principal]"
- Proof points : [Éléments de preuve]

## Métriques de succès

| Métrique | Valeur cible | Actuel |
|----------|--------------|--------|
| Activation | [X%] | [Y%] |
| Retention D30 | [X%] | [Y%] |
| NPS | [X] | [Y] |
```

## Étape 3 : Exemples de Personas

### Exemple 1 : Utilisateur B2B SaaS

```markdown
# Persona : Marie, Product Manager

## Identité
| Attribut | Valeur |
|----------|--------|
| **Nom** | Marie Dupont |
| **Âge** | 32 ans |
| **Poste** | Product Manager Senior |
| **Entreprise** | Scale-up Tech (50-200 employés) |
| **Localisation** | Paris |
| **Segment** | Growth Tech |

## Citation caractéristique
> "J'ai besoin d'avoir une vue claire sur ce que fait mon équipe
> pour prendre les bonnes décisions, pas de passer des heures
> à consolider des données de 5 outils différents."

## Objectifs
1. Livrer des features qui ont un impact mesurable
2. Aligner l'équipe produit avec la stratégie
3. Gagner en visibilité auprès de la direction

## Pain points
1. Trop d'outils fragmentés (Jira, Notion, Slack, Figma)
2. Réunions de statut chronophages
3. Difficulté à mesurer l'impact des features

## Comportements
- Travaille sur Mac, iPhone
- Power user de Notion et Slack
- Consomme des newsletters produit (Lenny's, SVPG)
- Décisionnaire sur les outils équipe produit (budget < 500€/mois)
```

### Exemple 2 : Utilisateur B2C

```markdown
# Persona : Thomas, Freelance

## Identité
| Attribut | Valeur |
|----------|--------|
| **Nom** | Thomas Martin |
| **Âge** | 28 ans |
| **Poste** | Développeur Freelance |
| **Statut** | Auto-entrepreneur |
| **Localisation** | Lyon |
| **Segment** | Solo creators |

## Citation caractéristique
> "Je veux me concentrer sur le code, pas sur l'administratif.
> Tout ce qui me fait gagner du temps vaut de l'or."

## Objectifs
1. Trouver des missions intéressantes et bien payées
2. Gérer sa compta simplement
3. Construire sa réputation en ligne

## Pain points
1. Temps perdu sur la facturation et les relances
2. Difficulté à estimer ses prix
3. Isolement (pas de collègues)

## Comportements
- Full remote, travaille de chez lui ou en coworking
- Mac + écran externe
- Très présent sur Twitter/X et GitHub
- Sensible au prix, compare avant d'acheter
```

## Étape 4 : Matrice des Personas

```markdown
## Vue d'ensemble des Personas

| Persona | Segment | % Users | LTV | Priorité |
|---------|---------|---------|-----|----------|
| Marie (PM) | Growth Tech | 35% | 2400€ | P1 |
| Thomas (Freelance) | Solo | 40% | 240€ | P2 |
| Sophie (Enterprise) | Enterprise | 15% | 12000€ | P1 |
| Alex (Student) | Free tier | 10% | 0€ | P3 |

### Matrice besoins vs personas

| Besoin / Feature | Marie | Thomas | Sophie | Alex |
|-----------------|-------|--------|--------|------|
| Collaboration | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Intégrations | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐ |
| Prix bas | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐ | ⭐⭐⭐⭐⭐ |
| Support premium | ⭐⭐⭐ | ⭐ | ⭐⭐⭐⭐⭐ | ⭐ |
| Mobile | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
```

## Étape 5 : Usage des Personas

### En conception produit

```markdown
## Design Review Checklist

Pour chaque feature, vérifier :

### Marie (PM)
- [ ] Résout-il un de ses pain points ?
- [ ] S'intègre-t-il dans son workflow ?
- [ ] Le ROI est-il évident pour elle ?

### Thomas (Freelance)
- [ ] Est-ce simple et rapide à utiliser ?
- [ ] Le prix est-il justifié pour un solo ?
- [ ] Peut-il l'utiliser sur mobile ?

### Sophie (Enterprise)
- [ ] Répond-il aux exigences de sécurité ?
- [ ] Permet-il la collaboration d'équipe ?
- [ ] Y a-t-il des options admin ?
```

### En marketing

```markdown
## Messages par Persona

### Marie (PM)
- **Hook** : "Enfin une vue unifiée de votre roadmap"
- **Canal** : LinkedIn, Newsletter produit
- **Contenu** : Études de cas, templates

### Thomas (Freelance)
- **Hook** : "Automatisez votre facturation en 2 clics"
- **Canal** : Twitter, YouTube
- **Contenu** : Tutoriels, tips & tricks

### Sophie (Enterprise)
- **Hook** : "La solution approuvée par les équipes sécurité"
- **Canal** : Account-based marketing, Événements
- **Contenu** : Whitepaper, démo personnalisée
```

## Bonnes pratiques

### À faire

| Pratique | Raison |
|----------|--------|
| **Baser sur des données** | Éviter les suppositions |
| **Limiter à 3-5 personas** | Focus et mémorisation |
| **Mettre à jour régulièrement** | Évolution du marché |
| **Partager largement** | Alignement équipe |
| **Utiliser dans les décisions** | Impact concret |

### À éviter

| Anti-pattern | Problème |
|--------------|----------|
| Persona fictif sans data | Biais de confirmation |
| Trop de personas | Dilution du focus |
| Persona statique | Déconnexion réalité |
| Persona non utilisé | Effort gaspillé |

## Output attendu

```markdown
## Personas Créés

**Nombre :** [X] personas
**Basés sur :** [X] interviews, [X] réponses enquête

### Résumé

| Persona | Segment | Jobs-to-be-done principal |
|---------|---------|--------------------------|
| [Nom 1] | [Segment] | [Job] |
| [Nom 2] | [Segment] | [Job] |
| [Nom 3] | [Segment] | [Job] |

### Prochaines étapes
1. [ ] Valider avec l'équipe
2. [ ] Créer les visuels
3. [ ] Intégrer au design system
4. [ ] Former l'équipe
```

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/research` | Recherche utilisateur |
| `/market` | Étude de marché |
| `/mvp` | Définir le MVP pour un persona |
| `/onboarding` | Parcours par persona |
| `/ab-test` | Tester hypothèses persona |

---

IMPORTANT: Les personas doivent être basés sur des données réelles, pas des suppositions.

YOU MUST limiter le nombre de personas (3-5 maximum).

YOU MUST les mettre à jour régulièrement (trimestriellement).

NEVER créer un persona sans l'utiliser dans les décisions.

Think hard sur les jobs-to-be-done plutôt que les caractéristiques démographiques.
