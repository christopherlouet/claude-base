# Agent DOC-FIX-ISSUE

Corrige une issue GitHub de manière autonome et complète.

## Contexte
$ARGUMENTS

## Objectif

Analyser, comprendre et résoudre une issue GitHub en suivant un processus structuré,
de la lecture de l'issue jusqu'à la création de la PR.

## Workflow complet

```
┌─────────────────────────────────────────────────────────────┐
│                    FIX ISSUE WORKFLOW                        │
├─────────────────────────────────────────────────────────────┤
│  1. RÉCUPÉRER   → Lire les détails de l'issue               │
│  2. ANALYSER    → Comprendre le problème                    │
│  3. EXPLORER    → Identifier les fichiers concernés         │
│  4. PLANIFIER   → Définir la solution                       │
│  5. IMPLÉMENTER → Coder la correction                       │
│  6. TESTER      → Vérifier le fix                           │
│  7. COMMITER    → Créer le commit avec référence            │
│  8. PR          → Créer la Pull Request                     │
└─────────────────────────────────────────────────────────────┘
```

## Étape 1 : Récupérer l'issue

### Commandes GitHub CLI

```bash
# Voir les détails de l'issue
gh issue view <numero>

# Voir avec les commentaires
gh issue view <numero> --comments

# Lister les issues assignées
gh issue list --assignee @me

# Lister les issues par label
gh issue list --label bug
```

### Informations à extraire

| Information | Importance |
|-------------|------------|
| Titre | Description courte du problème |
| Description | Détails et contexte |
| Labels | Type (bug, feature, etc.) |
| Assignee | Qui travaille dessus |
| Milestone | Planning prévu |
| Commentaires | Discussions et clarifications |

## Étape 2 : Analyser le problème

### Questions à se poser

1. **Quel est le symptôme ?**
   - Comportement actuel vs attendu
   - Messages d'erreur

2. **Quand ça se produit ?**
   - Conditions de reproduction
   - Fréquence (toujours, parfois)

3. **Quel est l'impact ?**
   - Critique (bloquant)
   - Majeur (dégradé)
   - Mineur (cosmétique)

4. **Quelle est la cause probable ?**
   - Hypothèses initiales
   - Pistes d'investigation

### Template d'analyse

```markdown
## Analyse de l'issue #[numero]

### Symptôme
[Description du problème observé]

### Comportement attendu
[Ce qui devrait se passer]

### Reproduction
1. [Étape 1]
2. [Étape 2]
3. [Bug apparaît]

### Impact
- Sévérité : [Critique/Majeur/Mineur]
- Utilisateurs affectés : [tous/certains/peu]

### Hypothèses
1. [Hypothèse 1]
2. [Hypothèse 2]
```

## Étape 3 : Explorer le code

### Identifier les fichiers

```bash
# Rechercher par mots-clés de l'issue
grep -r "error message" src/
grep -r "functionName" src/

# Trouver les fichiers liés à un module
find src/ -name "*auth*" -o -name "*login*"
```

### Analyser le contexte

- [ ] Lire le code impliqué
- [ ] Comprendre le flux de données
- [ ] Identifier les dépendances
- [ ] Vérifier les tests existants

> Utiliser `/work-explore` si l'exploration est complexe.

## Étape 4 : Planifier la solution

### Définir l'approche

```markdown
## Plan de correction

### Cause racine identifiée
[Explication technique]

### Solution proposée
[Description de la correction]

### Fichiers à modifier
- [ ] `src/file1.ts` - [modification]
- [ ] `src/file2.ts` - [modification]

### Tests à ajouter
- [ ] Test de régression pour le bug
- [ ] Test des edge cases liés

### Risques
- [Risque potentiel] → [Mitigation]
```

## Étape 5 : Implémenter la correction

### Principes

- **Fix minimal** : corriger uniquement le bug
- **Pas de refactoring** : sauf si nécessaire pour le fix
- **Test de régression** : ajouter un test qui échouait avant

### Process

1. Créer une branche
```bash
git checkout -b fix/issue-<numero>-description
```

2. Écrire le test de régression (TDD)
```typescript
describe('Bug #<numero>', () => {
  it('should [comportement correct]', () => {
    // Ce test échouait avant le fix
  });
});
```

3. Implémenter le fix

4. Vérifier que le test passe

## Étape 6 : Tester la correction

### Vérifications obligatoires

```bash
# Tests unitaires
npm test

# Tests spécifiques au fix
npm test -- --grep "Bug #<numero>"

# Lint
npm run lint

# Types
npm run typecheck

# Build
npm run build
```

### Test manuel

- [ ] Reproduire le scénario original → Bug corrigé
- [ ] Tester les cas connexes → Pas de régression
- [ ] Tester sur différents environnements si applicable

## Étape 7 : Commiter

### Format du message

```
fix(scope): description courte

[Description détaillée si nécessaire]

- Cause: [explication de la cause racine]
- Solution: [ce qui a été fait]

Fixes #<numero>
```

### Exemple

```bash
git add .
git commit -m "fix(auth): prevent token expiration during refresh

Users were being logged out unexpectedly because the token
refresh was happening after expiration check.

- Cause: Race condition in token validation
- Solution: Check expiration before refresh attempt

Fixes #234"
```

## Étape 8 : Créer la Pull Request

### Template de PR

```markdown
## Fixes #<numero>

### Problème
[Description du bug corrigé]

### Cause racine
[Explication technique]

### Solution
[Ce qui a été fait pour corriger]

### Changements
- `src/file1.ts` - [modification]
- `src/file2.ts` - [modification]

### Tests
- [x] Test de régression ajouté
- [x] Tests existants passent
- [x] Test manuel effectué

### Checklist
- [x] Code review ready
- [x] Lint/Types OK
- [x] Documentation mise à jour (si applicable)

### Comment tester
1. [Étape 1]
2. [Étape 2]
3. Vérifier que [résultat attendu]
```

### Commande GitHub CLI

```bash
gh pr create --title "fix(scope): description" --body-file PR_BODY.md
```

## Checklist complète

### Avant de commencer
- [ ] Issue lue et comprise
- [ ] Reproduction confirmée
- [ ] Fichiers identifiés

### Pendant le fix
- [ ] Test de régression écrit
- [ ] Fix minimal implémenté
- [ ] Tests passent

### Avant la PR
- [ ] Commit message correct avec "Fixes #numero"
- [ ] Tous les tests passent
- [ ] Code review prêt

## Agents liés

| Agent | Usage |
|-------|-------|
| `/work-explore` | Explorer le code concerné |
| `/dev-debug` | Debug approfondi si nécessaire |
| `/dev-tdd` | Approche TDD pour le fix |
| `/work-commit` | Format du commit |
| `/work-pr` | Création de la PR |

---

IMPORTANT: Toujours ajouter un test de régression qui échouait avant le fix.

YOU MUST référencer l'issue dans le commit avec "Fixes #numero".

NEVER faire de refactoring ou d'autres corrections dans le même commit.

NEVER fermer l'issue manuellement - le merge de la PR la fermera automatiquement.

Think hard sur la cause racine avant de coder - un fix superficiel reviendra.
