---
sidebar_position: 2
title: "api-development"
description: "Développer et documenter une API REST ou GraphQL. Utiliser quand l'utilisateur veut créer un endpoint, une route, ou structurer une API."
tags:
  - "skill"
  - "fork"
---

# Skill: api-development

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Développer et documenter une API REST ou GraphQL. Utiliser quand l'utilisateur veut créer un endpoint, une route, ou structurer une API.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Edit`, `Write`, `Bash`, `Grep`, `Glob` |
| **Mots-cles** | `api`, `development`, `success`, `data`, `meta`, `page`, `limit` |

## Description detaillee

# Développer une API

## Objectif

Créer des APIs bien structurées, documentées et testables.

## Instructions

### 1. Définir le contrat

Avant de coder, définir:
- Endpoint (URL, méthode HTTP)
- Request (body, query params, headers)
- Response (status codes, body)
- Erreurs possibles

### 2. Structure RESTful

```
GET    /resources          → Liste (avec pagination)
GET    /resources/:id      → Détail
POST   /resources          → Création
PUT    /resources/:id      → Mise à jour complète
PATCH  /resources/:id      → Mise à jour partielle
DELETE /resources/:id      → Suppression
```

### 3. Format de réponse standard

```typescript
// Succès
{
  "success": true,
  "data": { ... },
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100
  }
}

// Erreur
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email is required",
    "details": [
      { "field": "email", "message": "Required" }
    ]
  }
}
```

### 4. Validation des entrées

```typescript
// Avec Zod
const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2).max(100),
  role: z.enum(['user', 'admin']).default('user')
});

// Dans le handler
const data = createUserSchema.parse(req.body);
```

### 5. Documentation OpenAPI

```yaml
paths:
  /users:
    post:
      summary: Créer un utilisateur
      tags: [Users]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUser'
      responses:
        '201':
          description: Utilisateur créé
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '400':
          $ref: '#/components/responses/ValidationError'
```

### 6. Tests d'API

```typescript
describe('POST /api/users', () => {
  it('should create user with valid data', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ email: 'test@example.com', name: 'Test' })
      .expect(201);

    expect(response.body.success).toBe(true);
    expect(response.body.data.email).toBe('test@example.com');
  });

  it('should return 400 for invalid email', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ email: 'invalid', name: 'Test' })
      .expect(400);

    expect(response.body.error.code).toBe('VALIDATION_ERROR');
  });
});
```

## Checklist API

- [ ] Endpoint RESTful
- [ ] Validation des entrées (Zod/Joi)
- [ ] Gestion des erreurs centralisée
- [ ] Status codes appropriés
- [ ] Documentation OpenAPI
- [ ] Tests d'intégration
- [ ] Rate limiting (si public)
- [ ] Authentification (si privé)

## Output attendu

```markdown
## API: [Nom de l'endpoint]

### Endpoint
`POST /api/v1/resources`

### Request
```json
{
  "field1": "string",
  "field2": 123
}
```

### Response (201)
```json
{
  "success": true,
  "data": { ... }
}
```

### Erreurs
| Code | Status | Description |
|------|--------|-------------|
| VALIDATION_ERROR | 400 | Données invalides |
| NOT_FOUND | 404 | Ressource introuvable |
| UNAUTHORIZED | 401 | Non authentifié |
```

## Règles

- IMPORTANT: Toujours valider les entrées
- IMPORTANT: Documenter avec OpenAPI
- YOU MUST retourner des codes HTTP appropriés
- NEVER exposer les erreurs internes en production

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux api..."_
- _"Je veux development..."_
- _"Je veux success..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
