---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.py"
  - "**/*.go"
  - "**/*.dart"
  - "**/*.rs"
---

# Verification Before Completion

## Principe

Toute implementation doit etre verifiee AVANT d'etre consideree comme terminee.
Ne jamais presumer qu'un fix fonctionne sans le prouver.

## Checklist de verification obligatoire

### Apres un fix de bug

```
[ ] Le bug original est reproduit
[ ] Le fix corrige effectivement le probleme
[ ] Les tests existants passent toujours
[ ] Un test de non-regression est ajoute
[ ] Pas d'effets de bord detectes
```

### Apres une nouvelle feature

```
[ ] La feature fonctionne comme specifie
[ ] Les edge cases sont geres (null, vide, limites)
[ ] Les tests couvrent le happy path ET les erreurs
[ ] Le code compile/lint sans warning
[ ] La feature n'a pas degrade les performances
```

### Apres un refactoring

```
[ ] Le comportement est identique avant/apres
[ ] Les tests passent sans modification
[ ] Pas de regression fonctionnelle
[ ] Le code est effectivement plus simple/lisible
```

## Methode de verification

### 1. Verification automatisee

```bash
# Lancer les tests
npm test           # ou pytest, go test, flutter test

# Verifier les types
npm run typecheck  # ou mypy, go vet

# Lancer le linter
npm run lint       # ou ruff, golangci-lint
```

### 2. Verification manuelle

- Relire le diff complet (`git diff`)
- Verifier que chaque changement est intentionnel
- S'assurer qu'aucun debug/TODO n'est reste
- Confirmer que les imports inutiles sont supprimes

### 3. Defense en profondeur

- Ajouter des assertions sur les invariants critiques
- Valider les preconditions en entree de fonction
- Logger les etats inattendus sans crasher

## Gate Function (obligatoire avant toute affirmation de completion)

```
AVANT de declarer un statut ou exprimer une satisfaction:

1. IDENTIFIER: Quelle commande prouve cette affirmation ?
2. EXECUTER: Lancer la commande COMPLETE (fresh, pas un run precedent)
3. LIRE: Sortie complete, verifier le code retour, compter les erreurs
4. CONFIRMER: La sortie confirme-t-elle l'affirmation ?
   - Si NON: Donner le statut reel avec preuves
   - Si OUI: Affirmer AVEC les preuves
5. SEULEMENT ALORS: Faire l'affirmation

Sauter une etape = affirmation non verifiee
```

## Red Flags — STOP immediat

| Signal d'alerte | Reaction |
|-----------------|----------|
| Utiliser "devrait", "probablement", "semble" | STOP — lancer la verification |
| Exprimer une satisfaction avant verification ("Super!", "Parfait!", "Fait!") | STOP — evidence d'abord |
| Sur le point de commit/push/PR sans verification | STOP — Gate Function |
| Se fier au rapport de succes d'un sub-agent | STOP — verifier independamment |
| Se contenter d'une verification partielle | STOP — partiel ne prouve rien |
| "Juste cette fois" ou "Ca devrait marcher" | STOP — pas d'exception |

## Table de preuve requise

| Affirmation | Preuve requise | Insuffisant |
|-------------|---------------|-------------|
| "Les tests passent" | Sortie test: 0 echecs | Run precedent, "devrait passer" |
| "Le linter est propre" | Sortie linter: 0 erreurs | Verification partielle |
| "Le build reussit" | Commande build: exit 0 | "Le linter passe donc ca build" |
| "Le bug est corrige" | Test du symptome original: passe | "J'ai change le code" |
| "Les exigences sont remplies" | Checklist ligne par ligne | "Les tests passent" |

## Regles

IMPORTANT: Ne JAMAIS dire "c'est corrige" sans avoir lance les tests.

IMPORTANT: Toujours verifier le diff complet avant de commiter.

NEVER presumer qu'un changement est safe. Le prouver.

NEVER exprimer de satisfaction ou de completion sans preuve fraiche.
