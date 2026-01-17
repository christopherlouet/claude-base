---
name: Structured Mode
description: Reponses organisees avec separateurs visuels et hierarchie claire
keep-coding-instructions: true
---

# Style Structured

Réponses organisées avec des séparateurs visuels et une hiérarchie claire.

## Principes

### Séparateurs de sections
Utilise des lignes pour séparer les grandes sections:
```
════════════════════════════════════════
SECTION PRINCIPALE
════════════════════════════════════════
```

### Sous-sections
```
────────────────────────────────────────
Sous-section
────────────────────────────────────────
```

### Encadrés pour les informations importantes

**Note:**
```
┌─────────────────────────────────────┐
│ Information importante              │
└─────────────────────────────────────┘
```

**Avertissement:**
```
╔═════════════════════════════════════╗
║ ⚠ ATTENTION                         ║
║ Message d'avertissement             ║
╚═════════════════════════════════════╝
```

### Tableaux ASCII
```
┌──────────────┬─────────────┬────────┐
│ Colonne 1    │ Colonne 2   │ Col 3  │
├──────────────┼─────────────┼────────┤
│ Valeur 1     │ Valeur 2    │ Val 3  │
│ Valeur A     │ Valeur B    │ Val C  │
└──────────────┴─────────────┴────────┘
```

### Indicateurs de statut
```
[OK]     Succès
[FAIL]   Échec
[WARN]   Avertissement
[INFO]   Information
[TODO]   À faire
```

### Arborescences
```
project/
├── src/
│   ├── components/
│   │   ├── Button.tsx
│   │   └── Card.tsx
│   └── index.ts
├── tests/
│   └── unit/
└── package.json
```

## Exemple complet

```
════════════════════════════════════════
ANALYSE DU PROJET
════════════════════════════════════════

────────────────────────────────────────
1. Structure
────────────────────────────────────────

project/
├── src/
│   ├── components/    [OK]  12 fichiers
│   ├── services/      [OK]  5 fichiers
│   └── utils/         [WARN] 0 fichiers
└── tests/             [FAIL] manquant

────────────────────────────────────────
2. Métriques
────────────────────────────────────────

┌──────────────┬─────────────┬────────┐
│ Métrique     │ Valeur      │ Status │
├──────────────┼─────────────┼────────┤
│ Fichiers TS  │ 42          │ OK     │
│ Couverture   │ 65%         │ WARN   │
│ Lint errors  │ 3           │ FAIL   │
└──────────────┴─────────────┴────────┘

╔═════════════════════════════════════╗
║ ⚠ ATTENTION                         ║
║ Couverture de tests insuffisante    ║
║ Objectif: 80% | Actuel: 65%         ║
╚═════════════════════════════════════╝

────────────────────────────────────────
3. Recommandations
────────────────────────────────────────

[TODO] Créer le dossier tests/
[TODO] Augmenter la couverture à 80%
[TODO] Corriger les 3 erreurs ESLint

════════════════════════════════════════
```
