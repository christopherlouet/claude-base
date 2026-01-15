# Agent DOC

Génération de documentation pour le code.

## Cible
$ARGUMENTS

## Types de documentation

### 1. Documentation inline (JSDoc/TSDoc)
```typescript
/**
 * Description courte de la fonction.
 *
 * Description détaillée si nécessaire, expliquant
 * le comportement, les cas particuliers, etc.
 *
 * @param paramName - Description du paramètre
 * @returns Description de la valeur retournée
 * @throws {ErrorType} Quand cette erreur est levée
 * @example
 * ```typescript
 * const result = maFonction('input');
 * // result === 'expected'
 * ```
 */
```

### 2. README de module
```markdown
# Nom du Module

## Description
[Ce que fait ce module]

## Installation
[Comment l'installer/configurer]

## Utilisation
[Exemples d'utilisation basiques]

## API
[Documentation des fonctions publiques]

## Exemples
[Cas d'utilisation courants]
```

### 3. Documentation d'API (endpoints)
```markdown
## POST /api/resource

Crée une nouvelle ressource.

### Request
- **Headers**: `Authorization: Bearer <token>`
- **Body**:
```json
{
  "field": "value"
}
```

### Response
- **200 OK**:
```json
{
  "id": "123",
  "field": "value"
}
```
- **400 Bad Request**: Validation error
- **401 Unauthorized**: Token invalide
```

### 4. Documentation d'architecture (ADR)
```markdown
# ADR-001: [Titre de la décision]

## Statut
Accepté | En discussion | Remplacé par ADR-XXX

## Contexte
[Pourquoi cette décision est nécessaire]

## Décision
[Ce qui a été décidé]

## Conséquences
[Impact de cette décision]
```

## Règles de documentation

### À documenter
- [ ] Fonctions publiques/exportées
- [ ] Interfaces et types complexes
- [ ] Comportements non évidents
- [ ] Décisions d'architecture importantes
- [ ] Configuration requise

### À NE PAS documenter
- Code auto-explicatif
- Détails d'implémentation évidents
- Commentaires qui répètent le code

## Output attendu

### Documentation générée
- Type: [inline/README/API/ADR]
- Fichiers créés/modifiés: [liste]

### Contenu
[Documentation générée]

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/api-spec` | Documentation OpenAPI |
| `/readme` | README du projet |
| `/architecture` | Documentation d'architecture |
| `/explain` | Expliquer du code complexe |

---

IMPORTANT: La meilleure documentation est un code lisible.

YOU MUST documenter le "pourquoi", pas le "quoi".

NEVER documenter ce qui est évident dans le code.

Think hard sur ce qui manque pour comprendre le code.
