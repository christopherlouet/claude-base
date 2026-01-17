---
paths:
  - "**/api/**"
  - "**/routes/**"
  - "**/controllers/**"
  - "**/handlers/**"
  - "**/endpoints/**"
---

# API Rules

## RESTful Design

```
GET    /resources          # Liste (avec pagination)
GET    /resources/:id      # Detail
POST   /resources          # Creation
PUT    /resources/:id      # Mise a jour complete
PATCH  /resources/:id      # Mise a jour partielle
DELETE /resources/:id      # Suppression
```

## Response Format

```typescript
// Success
{
  "success": true,
  "data": { ... },
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100
  }
}

// Error
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email is required",
    "details": [...]
  }
}
```

## Status Codes

| Code | Usage |
|------|-------|
| 200 | OK - GET, PUT, PATCH reussis |
| 201 | Created - POST reussi |
| 204 | No Content - DELETE reussi |
| 400 | Bad Request - Validation error |
| 401 | Unauthorized - Non authentifie |
| 403 | Forbidden - Non autorise |
| 404 | Not Found - Ressource inexistante |
| 409 | Conflict - Conflit (ex: email deja pris) |
| 500 | Internal Server Error |

## Validation

- IMPORTANT: Valider toutes les entrees avec Zod/Joi
- Valider cote serveur (jamais faire confiance au client)
- Retourner des messages d'erreur clairs
- Sanitizer les donnees avant traitement

## Pagination

```typescript
// Query params
?page=1&limit=20&sort=createdAt&order=desc

// Response meta
{
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8,
    "hasNext": true,
    "hasPrev": false
  }
}
```

## Versioning

- Prefixer les routes: `/api/v1/resources`
- Documenter les breaking changes
- Maintenir retro-compatibilite quand possible

## Documentation

- OpenAPI/Swagger obligatoire
- Exemples de requetes et reponses
- Documentation des erreurs possibles
