# Agent MIGRATE

Migration de code, dépendances ou données.

## Migration à effectuer
$ARGUMENTS

## Types de migrations supportés

### 1. Migration de dépendances
```bash
# Vérifier les outdated
npm outdated

# Vérifier les vulnérabilités
npm audit
```

### 2. Migration de version majeure (breaking changes)
- Lire le CHANGELOG/release notes
- Identifier les breaking changes
- Planifier les modifications nécessaires

### 3. Migration de code (refactoring à grande échelle)
- Renommage de fonctions/classes
- Changement de patterns
- Migration de syntaxe

### 4. Migration de données/schéma
- Scripts de migration up/down
- Backup avant migration
- Plan de rollback

## Workflow de migration

### Phase 1 - Préparation
1. [ ] Documenter l'état actuel
2. [ ] Identifier toutes les occurrences à migrer
3. [ ] Créer une branche dédiée
4. [ ] S'assurer que tous les tests passent

### Phase 2 - Planification
1. [ ] Lister les étapes de migration
2. [ ] Estimer l'impact sur chaque partie du code
3. [ ] Identifier les dépendances entre étapes
4. [ ] Préparer le plan de rollback

### Phase 3 - Exécution
```
Pour chaque étape:
1. Effectuer la modification
2. Lancer les tests
3. Si OK → commit
4. Si KO → analyser et corriger ou rollback
```

### Phase 4 - Validation
1. [ ] Tous les tests passent
2. [ ] Build en production OK
3. [ ] Smoke tests manuels
4. [ ] Documentation mise à jour

## Techniques de migration sécurisée

### Strangler Fig Pattern
- Nouvelle implémentation en parallèle
- Redirection progressive du trafic
- Suppression de l'ancien code une fois validé

### Feature Flags
```typescript
if (featureFlags.useNewImplementation) {
  return newImplementation();
} else {
  return oldImplementation();
}
```

### Codemods
- Scripts automatisés pour transformations de code
- jscodeshift pour JavaScript/TypeScript

## Output attendu

### Plan de migration
| Étape | Description | Fichiers impactés | Risque |
|-------|-------------|-------------------|--------|
| 1     | ...         | X fichiers        | Faible |

### Checklist de migration
- [ ] Étape 1 complétée
- [ ] Étape 2 complétée
- [ ] Tests passent
- [ ] Review effectuée

### Rollback plan
```bash
# En cas de problème
git revert [commits]
# ou
git reset --hard [commit-avant-migration]
```

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/database` | Migrations de schéma |
| `/test` | Tester après migration |
| `/backup` | Backup avant migration |
| `/deps` | Migration de dépendances |
| `/review` | Review du plan de migration |

---

IMPORTANT: Toujours avoir un plan de rollback testé.

IMPORTANT: Petits commits, migrations incrémentales.

YOU MUST sauvegarder les données avant toute migration.

NEVER migrer en production sans avoir testé en staging.
