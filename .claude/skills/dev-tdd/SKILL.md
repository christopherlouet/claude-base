---
name: dev-tdd
description: Développement TDD avec cycle Red-Green-Refactor. Utiliser pour implémenter une fonctionnalité en écrivant les tests AVANT le code. Déclencher automatiquement quand l'utilisateur demande du TDD, veut écrire des tests d'abord, mentionne "test first", ou demande d'implémenter, ajouter, créer, fixer, corriger du code, une nouvelle feature, un bugfix, ou une fonctionnalité.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
context: fork
model: sonnet
argument-hint: "[feature-description]"
---

# Test-Driven Development (TDD)

## Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Si du code a ete ecrit avant le test : le supprimer. Recommencer avec TDD.

- Ne pas le garder "comme reference"
- Ne pas "l'adapter" en ecrivant les tests
- Ne pas le regarder
- Supprimer = supprimer

Implementer de zero a partir des tests. Point final.

## Cycle TDD

```
┌─────────┐     ┌─────────┐     ┌──────────┐
│   RED   │ ──▶ │  GREEN  │ ──▶ │ REFACTOR │
│  Test   │     │  Code   │     │  Clean   │
│  fail   │     │  pass   │     │   up     │
└─────────┘     └─────────┘     └──────────┘
      ▲                              │
      └──────────────────────────────┘
```

## Phase 1: RED - Ecrire un test qui echoue

### Ecrire UN test minimal montrant le comportement attendu

```typescript
describe('Module', () => {
  describe('fonction', () => {
    it('should [comportement] when [condition]', () => {
      // Arrange - Preparer
      // Act - Executer
      // Assert - Verifier
    });
  });
});
```

### Bon test vs Mauvais test

**Bon** : Nom clair, teste le comportement reel, une seule chose
```typescript
test('retries failed operations 3 times', async () => {
  let attempts = 0;
  const operation = () => {
    attempts++;
    if (attempts < 3) throw new Error('fail');
    return 'success';
  };

  const result = await retryOperation(operation);

  expect(result).toBe('success');
  expect(attempts).toBe(3);
});
```

**Mauvais** : Nom vague, teste le mock au lieu du code
```typescript
test('retry works', async () => {
  const mock = jest.fn()
    .mockRejectedValueOnce(new Error())
    .mockRejectedValueOnce(new Error())
    .mockResolvedValueOnce('success');
  await retryOperation(mock);
  expect(mock).toHaveBeenCalledTimes(3);
});
```

### Verifier RED (OBLIGATOIRE - ne jamais sauter)

```bash
npm test path/to/test.test.ts
```

Confirmer :
- Le test echoue (pas d'erreur de syntaxe)
- Le message d'echec est celui attendu
- L'echec vient de l'absence de la feature (pas d'un typo)

**Le test passe immediatement ?** On teste du comportement existant. Corriger le test.

**Le test a une erreur de syntaxe ?** Corriger, relancer jusqu'a obtenir un echec correct.

## Phase 2: GREEN - Code minimal

Ecrire le code le plus simple pour passer le test. Rien de plus.

**Bon** : Juste assez pour passer
```typescript
async function retryOperation<T>(fn: () => Promise<T>): Promise<T> {
  for (let i = 0; i < 3; i++) {
    try {
      return await fn();
    } catch (e) {
      if (i === 2) throw e;
    }
  }
  throw new Error('unreachable');
}
```

**Mauvais** : Sur-ingenierie, YAGNI
```typescript
async function retryOperation<T>(
  fn: () => Promise<T>,
  options?: {
    maxRetries?: number;
    backoff?: 'linear' | 'exponential';
    onRetry?: (attempt: number) => void;
  }
): Promise<T> {
  // Features pas demandees par un test
}
```

Ne pas ajouter de features, refactorer d'autre code, ou "ameliorer" au-dela du test.

### Verifier GREEN (OBLIGATOIRE)

```bash
npm test path/to/test.test.ts
```

Confirmer :
- Le test passe
- Les autres tests passent toujours
- Sortie propre (pas d'erreurs, warnings)

**Le test echoue ?** Corriger le code, pas le test.

**D'autres tests echouent ?** Les corriger maintenant.

## Phase 3: REFACTOR - Nettoyer

Apres GREEN uniquement :
- Supprimer les duplications
- Ameliorer les noms
- Extraire des helpers

Garder les tests verts. Ne pas ajouter de comportement.

### Commiter

```bash
git commit -m "test(scope): add tests for [feature]"
git commit -m "feat(scope): implement [feature]"
```

Puis recommencer : prochain test echouant pour la prochaine feature.

## Pourquoi l'ordre compte

### "J'ecrirai les tests apres pour verifier"

Les tests ecrits apres le code passent immediatement. Passer immediatement ne prouve rien :
- Le test peut tester la mauvaise chose
- Le test peut tester l'implementation au lieu du comportement
- Le test peut rater des edge cases oublies
- On n'a jamais vu le test attraper le bug

Test-first force a voir le test echouer, prouvant qu'il teste quelque chose.

### "J'ai deja teste manuellement tous les cas"

Le test manuel est ad-hoc :
- Pas de trace de ce qui a ete teste
- Impossible a relancer quand le code change
- Facile d'oublier des cas sous pression
- "Ca marchait quand j'ai essaye" ≠ test complet

Les tests automatises sont systematiques. Ils tournent de la meme facon a chaque fois.

### "Supprimer X heures de travail c'est du gaspillage"

Erreur du cout irrecuperable (sunk cost). Le temps est deja perdu. Le choix maintenant :
- Supprimer et reecrire en TDD (X heures de plus, haute confiance)
- Garder et ajouter les tests apres (30 min, basse confiance, bugs probables)

Le "gaspillage" c'est garder du code auquel on ne peut pas faire confiance.

## Rationalisations courantes

| Excuse | Realite |
|--------|---------|
| "Trop simple pour tester" | Le code simple casse. Le test prend 30 secondes. |
| "J'ecrirai les tests apres" | Les tests qui passent immediatement ne prouvent rien. |
| "Les tests apres atteignent le meme objectif" | Tests-apres = "qu'est-ce que ca fait ?" Tests-first = "qu'est-ce que ca devrait faire ?" |
| "J'ai deja teste manuellement" | Ad-hoc ≠ systematique. Pas de trace, pas rejouable. |
| "Supprimer X heures de travail c'est du gaspillage" | Sunk cost. Garder du code non verifie = dette technique. |
| "Je garde comme reference et j'ecris les tests d'abord" | On va l'adapter. C'est du test-after deguise. Supprimer = supprimer. |
| "J'ai besoin d'explorer d'abord" | OK. Jeter l'exploration, commencer en TDD. |
| "C'est dur a tester = design pas clair" | Ecouter le test. Dur a tester = dur a utiliser. |
| "Le TDD va me ralentir" | TDD plus rapide que le debug. Pragmatique = test-first. |
| "Le test manuel est plus rapide" | Le test manuel ne prouve pas les edge cases. On reteste a chaque changement. |
| "Le code existant n'a pas de tests" | On l'ameliore. Ajouter des tests pour le code existant. |
| "C'est different parce que..." | Non. Pas d'exception sans permission explicite de l'utilisateur. |

## Red Flags — STOP et recommencer

S'arreter immediatement si on se retrouve a :

- Ecrire du code avant le test
- Ecrire le test apres l'implementation
- Un test qui passe immediatement
- Ne pas pouvoir expliquer pourquoi le test a echoue
- Ajouter des tests "plus tard"
- Rationaliser "juste cette fois"
- "J'ai deja teste manuellement"
- "Les tests apres atteignent le meme objectif"
- "C'est l'esprit qui compte, pas le rituel"
- "Je garde comme reference" ou "j'adapte le code existant"
- "J'ai deja passe X heures, supprimer c'est du gaspillage"
- "Le TDD c'est dogmatique, je suis pragmatique"
- "C'est different parce que..."

**Tous ces signaux signifient : supprimer le code. Recommencer en TDD.**

## Qualites d'un bon test

| Qualite | Bon | Mauvais |
|---------|-----|---------|
| **Minimal** | Une seule chose. "et" dans le nom ? Decouper. | `test('validates email and domain and whitespace')` |
| **Clair** | Le nom decrit le comportement | `test('test1')` |
| **Intentionnel** | Demontre l'API souhaitee | Obscurcit ce que le code devrait faire |

## Exemple complet : Bug Fix

**Bug :** Email vide accepte

**RED**
```typescript
test('rejects empty email', async () => {
  const result = await submitForm({ email: '' });
  expect(result.error).toBe('Email required');
});
```

**Verifier RED**
```bash
$ npm test
FAIL: expected 'Email required', got undefined
```

**GREEN**
```typescript
function submitForm(data: FormData) {
  if (!data.email?.trim()) {
    return { error: 'Email required' };
  }
  // ...
}
```

**Verifier GREEN**
```bash
$ npm test
PASS
```

**REFACTOR** : Extraire la validation pour d'autres champs si necessaire.

## Checklist de verification

Avant de declarer le travail termine :

- [ ] Chaque nouvelle fonction/methode a un test
- [ ] Chaque test a ete vu echouer avant d'implementer
- [ ] Chaque test a echoue pour la bonne raison (feature absente, pas un typo)
- [ ] Code minimal ecrit pour passer chaque test
- [ ] Tous les tests passent
- [ ] Sortie propre (pas d'erreurs, warnings)
- [ ] Tests sur du code reel (mocks uniquement si inevitable)
- [ ] Edge cases et erreurs couverts

Impossible de cocher toutes les cases ? TDD a ete saute. Recommencer.

## Quand on est bloque

| Probleme | Solution |
|----------|----------|
| Ne sait pas comment tester | Ecrire l'API souhaitee. Ecrire l'assertion d'abord. Demander a l'utilisateur. |
| Test trop complique | Design trop complique. Simplifier l'interface. |
| Tout doit etre mocke | Code trop couple. Utiliser l'injection de dependances. |
| Setup de test enorme | Extraire des helpers. Toujours complexe ? Simplifier le design. |

## Commandes utiles

```bash
# Lancer les tests
npm test

# Tests en watch mode
npm run test:watch

# Avec couverture
npm run test:coverage

# Un fichier specifique
npm test -- --grep "nom du test"
```

## Regles

- JAMAIS ecrire le code avant les tests
- Un test qui passe des le debut est un MAUVAIS test
- Couvrir les edge cases (null, undefined, empty, limites)
- Mocks UNIQUEMENT pour dependances externes (API, DB, filesystem)
- Ne JAMAIS modifier un test pour le faire passer — corriger l'implementation
- Chaque test DOIT etre vu echouer avant d'ecrire le code
- Supprimer le code ecrit sans test. Pas d'exception.
