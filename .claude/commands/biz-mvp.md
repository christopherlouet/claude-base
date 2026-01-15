# Agent MVP

Définir le Minimum Viable Product et prioriser les fonctionnalités.

## Contexte
$ARGUMENTS

## Processus de définition

### 1. Comprendre la vision

#### Questions clés
- Quel problème résolvons-nous ?
- Pour qui ? (persona principal, pas secondaire)
- Quel est le "job to be done" principal ?
- Comment les utilisateurs résolvent-ils ce problème aujourd'hui ?

#### Explorer le projet existant
```bash
# Structure actuelle
tree -L 2 -I 'node_modules|.git|dist|build' 2>/dev/null

# Documentation
cat README.md 2>/dev/null
```

### 2. Lister toutes les fonctionnalités

#### Inventaire exhaustif
Lister TOUTES les fonctionnalités envisagées :

| # | Fonctionnalité | Description courte |
|---|----------------|-------------------|
| 1 | | |
| 2 | | |
| ... | | |

### 3. Priorisation MoSCoW

#### Définitions
- **Must have** : Sans ça, le produit ne fonctionne pas
- **Should have** : Important mais pas bloquant pour le lancement
- **Could have** : Nice-to-have, si on a le temps
- **Won't have** : Pas maintenant, peut-être plus tard

#### Matrice de priorisation

| Fonctionnalité | Must | Should | Could | Won't | Justification |
|----------------|------|--------|-------|-------|---------------|
| [Feature 1] | ✓ | | | | [Pourquoi] |
| [Feature 2] | | ✓ | | | [Pourquoi] |
| ... | | | | | |

### 4. Critères de décision

Pour chaque fonctionnalité, évaluer :

| Critère | Score (1-5) |
|---------|-------------|
| **Valeur utilisateur** | Résout-il le problème core ? |
| **Différenciation** | Nous distingue de la concurrence ? |
| **Complexité technique** | Effort de développement ? |
| **Risque** | Incertitude technique ou marché ? |
| **Dépendances** | Bloque d'autres features ? |

#### Formule de priorisation
```
Score = (Valeur × Différenciation) / (Complexité × Risque)
```

### 5. Définir le MVP

#### Critères du MVP
- [ ] Résout le problème principal (pas les problèmes secondaires)
- [ ] Utilisable de bout en bout (pas de fonctionnalité à moitié)
- [ ] Testable par de vrais utilisateurs
- [ ] Permet de valider les hypothèses clés
- [ ] Réalisable en [X semaines] (contrainte temps)

#### Le piège à éviter
```
❌ MVP ≠ Produit incomplet
❌ MVP ≠ Prototype
❌ MVP ≠ Version dégradée

✓ MVP = Plus petit produit qui délivre de la valeur
```

### 6. User Stories du MVP

Format :
```
En tant que [persona],
Je veux [action],
Afin de [bénéfice].

Critères d'acceptation :
- [ ] Critère 1
- [ ] Critère 2
```

### 7. Roadmap post-MVP

#### Phases suggérées
```
MVP (Phase 1)
├── [Must-have 1]
├── [Must-have 2]
└── [Must-have 3]

Phase 2 (Should-have)
├── [Feature 1]
├── [Feature 2]
└── [Feature 3]

Phase 3 (Could-have)
├── [Feature 1]
└── [Feature 2]

Backlog (Won't have now)
├── [Feature 1]
└── [Feature 2]
```

## Output attendu

### Vision MVP
```
Problème: [en une phrase]
Cible: [persona principal]
Proposition de valeur: [en une phrase]
Métrique de succès: [KPI principal]
```

### Scope MVP

#### Inclus dans le MVP
| Fonctionnalité | User Story | Complexité |
|----------------|------------|------------|
| [Feature 1] | En tant que... | [S/M/L] |
| [Feature 2] | En tant que... | [S/M/L] |
| ... | ... | ... |

#### Explicitement exclus du MVP
| Fonctionnalité | Raison de l'exclusion | Phase cible |
|----------------|----------------------|-------------|
| [Feature] | [Pourquoi pas maintenant] | Phase 2 |
| ... | ... | ... |

### User Stories détaillées
[Liste des user stories avec critères d'acceptation]

### Hypothèses à valider
| Hypothèse | Comment la tester | Métrique de succès |
|-----------|-------------------|-------------------|
| [Hypothèse 1] | [Méthode] | [KPI] |
| ... | ... | ... |

### Risques identifiés
| Risque | Impact | Probabilité | Mitigation |
|--------|--------|-------------|------------|
| [Risque 1] | Haut/Moyen/Bas | Haute/Moyenne/Basse | [Action] |
| ... | ... | ... | ... |

### Prochaines étapes
1. [Action 1]
2. [Action 2]
3. [Action 3]

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/plan` | Planifier l'implémentation du MVP |
| `/tdd` | Développer avec tests |
| `/roadmap` | Roadmap post-MVP |
| `/launch` | Lancement du MVP |
| `/model` | Valider le business model |

---

IMPORTANT: Le MVP doit être VIABLE - il doit délivrer de la vraie valeur, pas juste être minimal.

YOU MUST challenger chaque "Must have" - est-ce vraiment indispensable pour le lancement ?

NEVER inclure des fonctionnalités "au cas où" - si le doute existe, c'est un "Could have".

Think hard sur ce qui est vraiment essentiel vs ce qui semble essentiel.
