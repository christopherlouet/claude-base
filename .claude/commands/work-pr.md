# Agent PR (Pull Request)

Crée une Pull Request complète et bien documentée.

## Contexte
$ARGUMENTS

## Workflow

### 1. Vérifications pré-PR
```bash
git status                    # Vérifier l'état
git diff main...HEAD          # Voir tous les changements
npm test                      # Tests passent
npm run lint                  # Lint OK
npm run build                 # Build OK
```

### 2. Analyse des changements
- Liste tous les commits depuis la branche main
- Identifie le type de changement (feature/fix/refactor)
- Note les fichiers modifiés et leur impact

### 3. Création de la PR

#### Titre
Format: `type(scope): description concise`
- feat: nouvelle fonctionnalité
- fix: correction de bug
- refactor: refactoring
- docs: documentation
- test: ajout de tests
- chore: maintenance

#### Corps de la PR
```markdown
## Description
[Résumé clair de ce que fait cette PR et pourquoi]

## Changements
- [Changement 1]
- [Changement 2]
- [Changement 3]

## Type de changement
- [ ] Bug fix (changement non-breaking qui corrige un problème)
- [ ] New feature (changement non-breaking qui ajoute une fonctionnalité)
- [ ] Breaking change (fix ou feature qui casserait l'existant)
- [ ] Refactoring (pas de changement fonctionnel)

## Tests
- [ ] Tests unitaires ajoutés/mis à jour
- [ ] Tests d'intégration ajoutés/mis à jour
- [ ] Tests manuels effectués

## Checklist
- [ ] Mon code suit les conventions du projet
- [ ] J'ai fait une self-review de mon code
- [ ] J'ai commenté le code complexe
- [ ] Mes changements ne génèrent pas de warnings
- [ ] Les tests passent localement

## Screenshots (si applicable)
[Ajouter des captures d'écran pour les changements UI]

## Notes pour les reviewers
[Points d'attention particuliers pour la review]
```

### 4. Labels et assignations
```bash
# Labels courants
gh pr create --label "feature"           # Nouvelle fonctionnalité
gh pr create --label "bug"               # Correction de bug
gh pr create --label "breaking-change"   # Changement cassant
gh pr create --label "documentation"     # Documentation
gh pr create --label "needs-review"      # Prêt pour review

# Assigner des reviewers
gh pr create --reviewer "username1,username2"

# Lier à une issue
gh pr create --body "Fixes #123"
```

### 5. Commande finale
```bash
# Création complète
gh pr create \
  --title "type(scope): description" \
  --body "..." \
  --reviewer "team-lead" \
  --label "feature,needs-review" \
  --milestone "v1.2.0"
```

## Erreurs courantes à éviter

| Erreur | Pourquoi c'est problématique | Solution |
|--------|------------------------------|----------|
| PR trop grosse | Difficile à review | Découper en PRs plus petites |
| Titre vague | Historique illisible | Titre descriptif avec type/scope |
| Pas de tests | Régression probable | Toujours inclure des tests |
| Force push | Perte de l'historique de review | Commits additionnels préférés |
| PR sans description | Contexte manquant | Description complète obligatoire |

## Self-review checklist

Avant de demander une review, vérifie :

- [ ] J'ai relu mon propre diff ligne par ligne
- [ ] Je comprends chaque changement que j'ai fait
- [ ] Les noms de variables/fonctions sont explicites
- [ ] Le code est formaté (prettier/eslint)
- [ ] Pas de `console.log` ou code de debug
- [ ] Les imports inutilisés sont supprimés
- [ ] Les commentaires TODO sont adressés ou trackés

## Output
- URL de la PR créée
- Résumé des changements inclus
- Reviewers assignés

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/review` | Self-review avant PR |
| `/commit` | Préparer les commits |
| `/explore` | Vérifier l'impact des changements |
| `/security` | Review sécurité si applicable |

---

IMPORTANT: Une PR = une seule préoccupation. Si les changements sont trop divers, suggère de splitter.

YOU MUST inclure une description claire du "pourquoi" dans la PR.

NEVER créer une PR sans avoir vérifié que les tests passent.
