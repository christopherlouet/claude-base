# Agent DOC-API-SPEC

Générer une spécification OpenAPI/Swagger pour une API.

## Contexte
$ARGUMENTS

## Processus de génération

### 1. Explorer l'API existante

```bash
# Rechercher les routes
grep -rn "router\.\|app\.\|@Get\|@Post\|@Put\|@Delete" --include="*.ts" --include="*.js" | head -30

# Rechercher les controllers
find . -name "*controller*" -o -name "*route*" | head -20
```

### 2. Structure OpenAPI 3.0

```yaml
openapi: 3.0.3
info:
  title: API Name
  description: Description de l'API
  version: 1.0.0
  contact:
    email: api@example.com
  license:
    name: MIT

servers:
  - url: https://api.example.com/v1
    description: Production
  - url: https://staging-api.example.com/v1
    description: Staging
  - url: http://localhost:3000/v1
    description: Development

tags:
  - name: Users
    description: Gestion des utilisateurs
  - name: Products
    description: Gestion des produits

paths:
  /users:
    get:
      # ...
    post:
      # ...

components:
  schemas:
    # ...
  securitySchemes:
    # ...
```

### 3. Template endpoint

```yaml
/users:
  get:
    tags:
      - Users
    summary: Liste des utilisateurs
    description: Retourne la liste paginée des utilisateurs
    operationId: getUsers
    parameters:
      - name: page
        in: query
        description: Numéro de page
        schema:
          type: integer
          default: 1
      - name: limit
        in: query
        description: Nombre d'éléments par page
        schema:
          type: integer
          default: 20
          maximum: 100
      - name: search
        in: query
        description: Recherche par nom ou email
        schema:
          type: string
    responses:
      '200':
        description: Liste des utilisateurs
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UserList'
      '401':
        $ref: '#/components/responses/Unauthorized'
      '500':
        $ref: '#/components/responses/InternalError'
    security:
      - bearerAuth: []

  post:
    tags:
      - Users
    summary: Créer un utilisateur
    description: Crée un nouvel utilisateur
    operationId: createUser
    requestBody:
      required: true
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/CreateUserRequest'
    responses:
      '201':
        description: Utilisateur créé
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/User'
      '400':
        $ref: '#/components/responses/BadRequest'
      '409':
        description: Email déjà utilisé
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/Error'
    security:
      - bearerAuth: []

/users/{id}:
  get:
    tags:
      - Users
    summary: Détail d'un utilisateur
    operationId: getUserById
    parameters:
      - name: id
        in: path
        required: true
        description: ID de l'utilisateur
        schema:
          type: string
          format: uuid
    responses:
      '200':
        description: Détail de l'utilisateur
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/User'
      '404':
        $ref: '#/components/responses/NotFound'
    security:
      - bearerAuth: []
```

### 4. Schemas (modèles)

```yaml
components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: string
          format: uuid
          example: "123e4567-e89b-12d3-a456-426614174000"
        email:
          type: string
          format: email
          example: "user@example.com"
        name:
          type: string
          example: "John Doe"
        role:
          type: string
          enum: [user, admin]
          default: user
        createdAt:
          type: string
          format: date-time
        updatedAt:
          type: string
          format: date-time
      required:
        - id
        - email
        - name

    CreateUserRequest:
      type: object
      properties:
        email:
          type: string
          format: email
        name:
          type: string
          minLength: 2
          maxLength: 100
        password:
          type: string
          format: password
          minLength: 8
      required:
        - email
        - name
        - password

    UserList:
      type: object
      properties:
        data:
          type: array
          items:
            $ref: '#/components/schemas/User'
        pagination:
          $ref: '#/components/schemas/Pagination'

    Pagination:
      type: object
      properties:
        page:
          type: integer
        limit:
          type: integer
        total:
          type: integer
        totalPages:
          type: integer

    Error:
      type: object
      properties:
        code:
          type: string
        message:
          type: string
        details:
          type: object
      required:
        - code
        - message
```

### 5. Authentification

```yaml
components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      description: JWT token in Authorization header

    apiKey:
      type: apiKey
      in: header
      name: X-API-Key

    oauth2:
      type: oauth2
      flows:
        authorizationCode:
          authorizationUrl: https://example.com/oauth/authorize
          tokenUrl: https://example.com/oauth/token
          scopes:
            read: Read access
            write: Write access
```

### 6. Réponses communes

```yaml
components:
  responses:
    BadRequest:
      description: Requête invalide
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
          example:
            code: BAD_REQUEST
            message: Validation failed
            details:
              email: Must be a valid email

    Unauthorized:
      description: Non authentifié
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
          example:
            code: UNAUTHORIZED
            message: Authentication required

    Forbidden:
      description: Accès refusé
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
          example:
            code: FORBIDDEN
            message: Insufficient permissions

    NotFound:
      description: Ressource non trouvée
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
          example:
            code: NOT_FOUND
            message: Resource not found

    InternalError:
      description: Erreur serveur
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/Error'
          example:
            code: INTERNAL_ERROR
            message: An unexpected error occurred
```

### 7. Outils de génération

#### Depuis le code (TypeScript)
```bash
# Avec tsoa
npm install tsoa
npx tsoa spec

# Avec @nestjs/swagger
npm install @nestjs/swagger swagger-ui-express
```

#### Vers le code
```bash
# Générer un client TypeScript
npx openapi-generator-cli generate \
  -i openapi.yaml \
  -g typescript-axios \
  -o ./generated/api-client

# Générer types TypeScript
npx openapi-typescript openapi.yaml -o ./types/api.ts
```

### 8. Validation

```bash
# Valider la spec
npx @redocly/cli lint openapi.yaml

# Swagger Editor (online)
# https://editor.swagger.io
```

## Output attendu

### Fichier openapi.yaml

```yaml
# Spécification complète générée
openapi: 3.0.3
info:
  title: [Nom de l'API]
  version: [Version]
# ...
```

### Documentation Swagger UI

```typescript
// swagger.ts (Express)
import swaggerUi from 'swagger-ui-express';
import YAML from 'yamljs';

const swaggerDocument = YAML.load('./openapi.yaml');
app.use('/docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));
```

### Endpoints documentés

| Méthode | Path | Description |
|---------|------|-------------|
| GET | /users | Liste des utilisateurs |
| POST | /users | Créer un utilisateur |
| GET | /users/{id} | Détail utilisateur |
| PUT | /users/{id} | Modifier utilisateur |
| DELETE | /users/{id} | Supprimer utilisateur |

### Checklist

- [ ] Tous les endpoints documentés
- [ ] Schemas pour tous les modèles
- [ ] Exemples pour chaque réponse
- [ ] Authentification documentée
- [ ] Codes d'erreur standardisés
- [ ] Spec valide (lint passed)

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/api` | Créer ou modifier l'API |
| `/doc` | Documentation générale |
| `/test` | Tester les endpoints documentés |
| `/security` | Vérifier la sécurité de l'API |

---

IMPORTANT: La documentation API doit être synchronisée avec le code - utiliser des générateurs si possible.

YOU MUST documenter tous les codes d'erreur possibles.

NEVER oublier les exemples - ils facilitent l'intégration pour les développeurs.

Think hard sur l'ergonomie de l'API avant de documenter.
