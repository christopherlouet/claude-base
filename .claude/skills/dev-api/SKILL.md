---
name: dev-api
description: Develop and document a REST or GraphQL API. Use when the user wants to create an endpoint, a route, or structure an API.
allowed-tools:
  - Read
  - Edit
  - Write
  - Bash
  - Grep
  - Glob
context: fork
argument-hint: "[endpoint-name]"
---

# Develop an API

## Objective

Create well-structured, documented and testable APIs.

## Instructions

### 1. Define the contract

Before coding, define:
- Endpoint (URL, HTTP method)
- Request (body, query params, headers)
- Response (status codes, body)
- Possible errors

### 2. RESTful structure

```
GET    /resources          → List (with pagination)
GET    /resources/:id      → Detail
POST   /resources          → Create
PUT    /resources/:id      → Full update
PATCH  /resources/:id      → Partial update
DELETE /resources/:id      → Delete
```

### 3. Standard response format

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
    "details": [
      { "field": "email", "message": "Required" }
    ]
  }
}
```

### 4. Input validation

```typescript
// With Zod
const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2).max(100),
  role: z.enum(['user', 'admin']).default('user')
});

// In the handler
const data = createUserSchema.parse(req.body);
```

### 5. OpenAPI documentation

```yaml
paths:
  /users:
    post:
      summary: Create a user
      tags: [Users]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUser'
      responses:
        '201':
          description: User created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '400':
          $ref: '#/components/responses/ValidationError'
```

### 6. API tests

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

## API Checklist

- [ ] RESTful endpoint
- [ ] Input validation (Zod/Joi)
- [ ] Centralized error handling
- [ ] Appropriate status codes
- [ ] OpenAPI documentation
- [ ] Integration tests
- [ ] Rate limiting (if public)
- [ ] Authentication (if private)

## Expected output

```markdown
## API: [Endpoint name]

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

### Errors
| Code | Status | Description |
|------|--------|-------------|
| VALIDATION_ERROR | 400 | Invalid data |
| NOT_FOUND | 404 | Resource not found |
| UNAUTHORIZED | 401 | Not authenticated |
```

## Rules

- IMPORTANT: Always validate inputs
- IMPORTANT: Document with OpenAPI
- YOU MUST return appropriate HTTP status codes
- NEVER expose internal errors in production
