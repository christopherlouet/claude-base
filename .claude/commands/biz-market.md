# Agent MARKET

Analyse de marché et étude concurrentielle pour un projet.

## Contexte
$ARGUMENTS

## Processus d'analyse

### 1. Comprendre le produit

#### Questions préliminaires
- Quel problème le produit résout-il ?
- Pour qui ? (persona principal)
- Quelle est la proposition de valeur unique ?

#### Analyser le codebase si disponible
```bash
# Comprendre les fonctionnalités
cat README.md 2>/dev/null
tree -L 2 -I 'node_modules|.git|dist' 2>/dev/null
```

### 2. Identifier les concurrents

#### Types de concurrents
- [ ] **Directs** : même solution, même cible
- [ ] **Indirects** : solution différente, même problème
- [ ] **Substituts** : solutions manuelles, statu quo

#### Recherche concurrentielle
Pour chaque concurrent identifié :

| Critère | Concurrent 1 | Concurrent 2 | Concurrent 3 |
|---------|--------------|--------------|--------------|
| Nom | | | |
| URL | | | |
| Pricing | | | |
| Cible | | | |
| Forces | | | |
| Faiblesses | | | |
| Différenciateur | | | |

#### Sources à explorer
- Product Hunt, G2, Capterra (SaaS)
- GitHub (open source)
- App Store / Play Store (mobile)
- LinkedIn, Crunchbase (funding, taille)

### 3. Analyse du marché

#### Taille du marché (TAM/SAM/SOM)
```
TAM (Total Addressable Market)
└── Marché total théorique

SAM (Serviceable Addressable Market)
└── Part du marché accessible avec le produit actuel

SOM (Serviceable Obtainable Market)
└── Part réaliste à court terme (1-2 ans)
```

#### Tendances du marché
- [ ] Croissance ou déclin du secteur ?
- [ ] Nouvelles réglementations ?
- [ ] Évolutions technologiques ?
- [ ] Changements de comportement utilisateur ?

### 4. Positionnement

#### Matrice de positionnement
```
                    Prix élevé
                        │
                        │
        Premium         │         Luxe
                        │
    ────────────────────┼────────────────────
                        │
        Budget          │         Value
                        │
                        │
                    Prix bas

        Simple ◄────────┴────────► Complexe
                    Fonctionnalités
```

#### Avantage concurrentiel
Types d'avantages durables :
- [ ] Technologie propriétaire
- [ ] Effet de réseau
- [ ] Données exclusives
- [ ] Marque forte
- [ ] Coûts de switching élevés
- [ ] Économies d'échelle

### 5. Analyse PESTEL

| Facteur | Impact | Opportunité/Menace |
|---------|--------|-------------------|
| **P**olitique | | |
| **E**conomique | | |
| **S**ocioculturel | | |
| **T**echnologique | | |
| **E**nvironnemental | | |
| **L**égal | | |

### 6. Barrières à l'entrée

- [ ] Capital nécessaire
- [ ] Expertise technique requise
- [ ] Réglementation
- [ ] Accès aux canaux de distribution
- [ ] Fidélité clients existants

## Output attendu

### Résumé exécutif
```
Marché: [nom du marché]
Taille estimée: [TAM/SAM/SOM]
Croissance: [%/an ou tendance]
Maturité: [Émergent/Croissance/Mature/Déclin]
Intensité concurrentielle: [Faible/Moyenne/Forte]
```

### Carte concurrentielle

| Concurrent | Type | Taille | Prix | Force principale |
|------------|------|--------|------|------------------|
| [Nom] | Direct | [PME/ETI/GE] | [€/mois] | [Force] |
| ... | ... | ... | ... | ... |

### Positionnement recommandé
```
Notre position: [description]
Différenciateur clé: [ce qui nous distingue]
Cible prioritaire: [segment]
```

### Opportunités identifiées
1. [Opportunité 1] - [Justification]
2. [Opportunité 2] - [Justification]
3. [Opportunité 3] - [Justification]

### Menaces à surveiller
1. [Menace 1] - [Mitigation possible]
2. [Menace 2] - [Mitigation possible]

### Recommandations stratégiques
1. [Recommandation 1]
2. [Recommandation 2]
3. [Recommandation 3]

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/model` | Business model après étude marché |
| `/competitor` | Analyse concurrentielle détaillée |
| `/personas` | Définir les personas cibles |
| `/research` | Recherche utilisateur approfondie |
| `/pricing` | Stratégie de pricing |

---

IMPORTANT: Utiliser la recherche web pour trouver des données récentes sur les concurrents et le marché.

YOU MUST identifier au moins 3 concurrents directs ou indirects.

NEVER inventer des chiffres de marché - indiquer "à valider" si les données ne sont pas trouvées.

Think hard sur le positionnement et les opportunités de différenciation.
