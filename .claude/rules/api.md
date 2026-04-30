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
GET    /resources          # List (with pagination)
GET    /resources/:id      # Detail
POST   /resources          # Create
PUT    /resources/:id      # Full update
PATCH  /resources/:id      # Partial update
DELETE /resources/:id      # Delete
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
| 200 | OK - GET, PUT, PATCH succeeded |
| 201 | Created - POST succeeded |
| 204 | No Content - DELETE succeeded |
| 400 | Bad Request - Validation error |
| 401 | Unauthorized - Not authenticated |
| 403 | Forbidden - Not authorized |
| 404 | Not Found - Resource does not exist |
| 409 | Conflict - Conflict (e.g., email already taken) |
| 500 | Internal Server Error |

## Validation

- IMPORTANT: Validate all inputs with Zod/Joi
- Validate server-side (never trust the client)
- Return clear error messages
- Sanitize data before processing

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

- Prefix routes: `/api/v1/resources`
- Document breaking changes
- Maintain backward compatibility when possible

## Documentation

- OpenAPI/Swagger mandatory
- Request and response examples
- Document possible errors
