# Agent API

Créer ou documenter des endpoints REST/GraphQL.

## Endpoint ou API à traiter
$ARGUMENTS

## Pre-requis TDD

IMPORTANT: Cette commande suit l'approche TDD. Les tests seront ecrits AVANT le code de l'endpoint.

**Ordre de creation obligatoire:**
1. Definir le contrat API (spec OpenAPI/types)
2. Ecrire les tests d'integration (RED)
3. Implementer le handler (GREEN)
4. Refactorer si necessaire (REFACTOR)
5. Documenter (Swagger/OpenAPI)

Si vous souhaitez proceder autrement, utilisez `/dev-api --skip-tdd` (non recommande).

---

## Modes disponibles

### Mode 1 : Créer un nouvel endpoint

#### Design de l'endpoint
```
Méthode: GET | POST | PUT | PATCH | DELETE
Path: /api/v1/[resource]
Description: [Ce que fait l'endpoint]
```

#### Convention REST
| Action | Méthode | Path | Body |
|--------|---------|------|------|
| Liste | GET | /resources | - |
| Détail | GET | /resources/:id | - |
| Créer | POST | /resources | { data } |
| Modifier | PUT | /resources/:id | { data } |
| Modifier partiel | PATCH | /resources/:id | { partial } |
| Supprimer | DELETE | /resources/:id | - |

### Mode 2 : Documenter un endpoint existant

#### Template OpenAPI/Swagger
```yaml
/api/v1/[resource]:
  [method]:
    summary: [Description courte]
    description: [Description détaillée]
    tags:
      - [Tag]
    parameters:
      - name: [param]
        in: query | path | header
        required: true | false
        schema:
          type: string | integer | boolean
        description: [Description]
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            properties:
              [field]:
                type: [type]
                description: [description]
            required:
              - [field]
    responses:
      '200':
        description: Succès
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/[Schema]'
      '400':
        description: Erreur de validation
      '401':
        description: Non authentifié
      '403':
        description: Non autorisé
      '404':
        description: Ressource non trouvée
      '500':
        description: Erreur serveur
```

## Checklist de conception API

### Sécurité
- [ ] Authentification requise ?
- [ ] Autorisations (qui peut accéder ?)
- [ ] Rate limiting
- [ ] Validation des entrées
- [ ] Sanitization des sorties

### Performance
- [ ] Pagination pour les listes
- [ ] Filtrage côté serveur
- [ ] Caching possible ?
- [ ] Champs à inclure/exclure

### Cohérence
- [ ] Conventions de nommage respectées
- [ ] Format de réponse standard
- [ ] Codes HTTP appropriés
- [ ] Messages d'erreur clairs

## Formats de réponse standards

### Succès
```json
{
  "success": true,
  "data": { ... },
  "meta": {
    "page": 1,
    "perPage": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

### Erreur
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Message lisible par l'utilisateur",
    "details": [
      {
        "field": "email",
        "message": "Format d'email invalide"
      }
    ]
  }
}
```

## Implémentation type (Node.js/Express)

```typescript
// Route
router.post('/api/v1/users',
  authenticate,
  validate(createUserSchema),
  createUserHandler
);

// Handler
async function createUserHandler(req: Request, res: Response) {
  try {
    const user = await userService.create(req.body);
    res.status(201).json({
      success: true,
      data: user
    });
  } catch (error) {
    next(error);
  }
}
```

## Output attendu

### Spécification de l'endpoint
- Méthode et path
- Description
- Paramètres
- Body (si applicable)
- Réponses possibles

### Code d'implémentation
- Route
- Validation
- Handler
- Tests

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/api-spec` | Générer spec OpenAPI/Swagger |
| `/api-versioning` | Gérer le versioning d'API |
| `/test` | Tester les endpoints |
| `/security` | Audit sécurité de l'API |
| `/review` | Code review de l'API |

---

IMPORTANT: Une API est un contrat. Documenter avant d'implémenter.

IMPORTANT: Versionner l'API (/v1/, /v2/) pour éviter les breaking changes.

YOU MUST valider toutes les entrées utilisateur.

NEVER exposer de données sensibles dans les réponses API.
