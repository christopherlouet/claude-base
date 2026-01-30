---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.py"
  - "**/*.go"
  - "**/*.rs"
  - "**/*.java"
  - "**/*.cs"
  - "**/*.rb"
  - "**/*.php"
  - "**/*.kt"
  - "**/*.dart"
---

# LSP Usage Rules

## Quand utiliser LSP vs Grep/Glob

### Preferer LSP (precision semantique)

- `goToDefinition` : trouver la definition exacte d'un symbole (fonction, classe, variable)
- `findReferences` : toutes les references typees d'un symbole dans le projet
- `hover` : obtenir le type et la documentation d'un symbole
- `documentSymbol` : lister les symboles d'un fichier (fonctions, classes, exports)
- `getDiagnostics` : erreurs de compilation, types manquants, imports invalides

### Preferer Grep/Glob (couverture textuelle)

- Recherche de texte dans les commentaires, strings, fichiers de config
- Recherche multi-langages ou dans des fichiers non-code (JSON, YAML, MD)
- Recherche de patterns regex complexes
- Recherche dans les fichiers non indexes par le LSP

## Bonnes pratiques

- Combiner les deux : LSP pour naviguer le code, Grep pour chercher large
- Utiliser `getDiagnostics` apres modification pour verifier les erreurs de type
- Utiliser `findReferences` avant un refactoring pour mesurer l'impact

## Activation

LSP disponible via `ENABLE_LSP_TOOL=1` ou plugins LSP configures dans `.lsp.json`.
Les language servers doivent etre installes localement (npm, pip, go install, etc.).
