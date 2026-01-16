# Agent WORK-FLOW-BUGFIX

Workflow complet pour corriger un bug, du diagnostic au déploiement.

## Contexte
$ARGUMENTS

## Workflow automatisé

```
┌─────────────────────────────────────────────────────────────┐
│                    WORKFLOW BUGFIX                           │
├─────────────────────────────────────────────────────────────┤
│  1. DEBUG      → Identifier la cause racine                 │
│  2. TEST       → Écrire le test qui reproduit               │
│  3. FIX        → Implémenter la correction                  │
│  4. VERIFY     → Vérifier la non-régression                 │
│  5. COMMIT     → Commit avec référence issue                │
│  6. PR/HOTFIX  → PR normale ou hotfix selon urgence         │
└─────────────────────────────────────────────────────────────┘
```

---

## ÉTAPE 1/6 : DIAGNOSTIC

### Objectif
Identifier la cause racine du bug.

### Questions à répondre
1. **Quoi ?** - Quel est le comportement incorrect ?
2. **Quand ?** - Dans quelles conditions ?
3. **Où ?** - Quel fichier/fonction ?
4. **Pourquoi ?** - Quelle est la cause racine ?

### Méthodes de debug
```
1. Reproduire le bug
   ↓
2. Isoler le problème
   ↓
3. Formuler une hypothèse
   ↓
4. Vérifier l'hypothèse
   ↓
5. Identifier la cause racine
```

### Rapport de diagnostic
```markdown
## Bug: [Description courte]

### Symptôme
[Ce qui se passe]

### Comportement attendu
[Ce qui devrait se passer]

### Reproduction
1. [Étape 1]
2. [Étape 2]
3. Bug apparaît

### Cause racine
[Explication technique]

### Fichier(s) concerné(s)
- [fichier:ligne]
```

### Checklist diagnostic
- [ ] Bug reproduit
- [ ] Cause racine identifiée
- [ ] Impact évalué
- [ ] Solution envisagée

---

## ÉTAPE 2/6 : TEST DE RÉGRESSION

### Objectif
Écrire un test qui échoue et prouve le bug.

### Principe
```
Test DOIT échouer AVANT le fix
Test DOIT passer APRÈS le fix
```

### Template de test
```typescript
describe('Bug #[numero]', () => {
  it('should [comportement attendu] when [condition]', () => {
    // Arrange - Setup qui reproduit le bug

    // Act - Action qui déclenche le bug

    // Assert - Vérification du comportement correct
  });
});
```

### Checklist test
- [ ] Test écrit
- [ ] Test échoue (prouve le bug)
- [ ] Test cible le bon comportement
- [ ] Edge cases couverts

---

## ÉTAPE 3/6 : CORRECTION

### Objectif
Implémenter la correction minimale.

### Principes
- **Minimal** : Ne corriger QUE le bug
- **Ciblé** : Pas de refactoring opportuniste
- **Sûr** : Ne pas introduire de régression

### Anti-patterns à éviter
| ❌ Ne pas faire | ✅ Faire |
|-----------------|----------|
| Refactorer autour | Fix minimal |
| Corriger d'autres bugs | Un bug = un fix |
| Ajouter des features | Bug fix seulement |
| Over-engineer | Solution simple |

### Checklist fix
- [ ] Correction minimale
- [ ] Code propre
- [ ] Pas d'effets de bord
- [ ] Test passe maintenant

---

## ÉTAPE 4/6 : VÉRIFICATION

### Objectif
S'assurer qu'il n'y a pas de régression.

### Vérifications à faire
```bash
# 1. Tous les tests passent
npm test

# 2. Lint OK
npm run lint

# 3. Types OK
npm run typecheck

# 4. Build OK
npm run build
```

### Test manuel
- [ ] Reproduire le scénario du bug → Corrigé
- [ ] Tester les cas connexes → OK
- [ ] Tester sur différents environnements

### Checklist vérification
- [ ] Tests unitaires passent
- [ ] Tests d'intégration passent
- [ ] Lint/Types OK
- [ ] Test manuel OK
- [ ] Pas de régression détectée

---

## ÉTAPE 5/6 : COMMIT

### Objectif
Commit propre avec traçabilité.

### Format obligatoire
```
fix(scope): description du fix

- Cause: [cause racine]
- Solution: [ce qui a été fait]

Fixes #[numero_issue]
```

### Exemple
```
fix(auth): prevent token expiration during refresh

- Cause: Race condition when multiple tabs refresh token
- Solution: Added mutex lock on refresh operation

Fixes #456
```

### Checklist commit
- [ ] Type "fix" utilisé
- [ ] Scope précis
- [ ] Référence à l'issue
- [ ] Description de la cause et solution

---

## ÉTAPE 6/6 : PR OU HOTFIX

### Décision : PR normale ou Hotfix ?

```
                    Bug en production ?
                          │
              ┌───────────┴───────────┐
              │                       │
             Oui                     Non
              │                       │
        Critique ?              PR normale
              │                       │
    ┌─────────┴─────────┐            │
    │                   │            │
   Oui                 Non           │
    │                   │            │
 HOTFIX            PR + merge      PR
 (bypass)            rapide      standard
```

### Option A : PR normale
```markdown
## Bug Fix: [Description]

### Issue
Fixes #[numero]

### Cause racine
[Explication]

### Solution
[Ce qui a été fait]

### Tests
- [x] Test de régression ajouté
- [x] Tous les tests passent

### Vérification
- [ ] Code review
- [ ] QA validation
```

### Option B : Hotfix (urgent)
```bash
# 1. Créer branche hotfix depuis main
git checkout main
git checkout -b hotfix/[nom]

# 2. Cherry-pick ou appliquer le fix
git cherry-pick [commit] # ou coder

# 3. PR directe vers main
# Avec label "hotfix" et reviewers d'urgence
```

### Checklist PR/Hotfix
- [ ] PR créée avec description complète
- [ ] Reviewers assignés
- [ ] CI verte
- [ ] Issue liée

---

## Output final attendu

### Résumé
```
✅ WORKFLOW BUGFIX TERMINÉ

Bug: [Description]
Issue: #[numero]
Cause: [Cause racine]

Fix appliqué dans: [fichier(s)]
Test ajouté: [fichier test]

Branch: fix/[nom]
PR: #[numero]

Status: Ready for review/merge
```

### Post-merge
- [ ] Vérifier le déploiement
- [ ] Monitorer les erreurs
- [ ] Fermer l'issue
- [ ] Informer les stakeholders

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/debug` | Diagnostic approfondi |
| `/test` | Générer les tests de régression |
| `/hotfix` | Bug critique en production |
| `/commit` | Format de commit |

---

IMPORTANT: Toujours écrire un test qui reproduit le bug AVANT de le corriger.

YOU MUST référencer l'issue dans le commit et la PR.

NEVER faire de refactoring dans un fix de bug - un fix = un bug.

Think hard sur les effets de bord potentiels de la correction.
