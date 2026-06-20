# Agent DOC-API-SPEC

Generate an OpenAPI/Swagger specification for an API.

## Context
$ARGUMENTS

## Goal

Explore the API code, identify routes and models, and generate a complete OpenAPI 3.0 specification with schemas, authentication and examples.

## Workflow

- Explore existing routes and controllers
- Identify data models and DTOs
- Generate the OpenAPI 3.0 structure (info, servers, paths, components)
- Document each endpoint (parameters, body, responses, errors)
- Define authentication schemas (JWT, API Key, OAuth2)
- Standardize error responses
- Validate the spec with redocly lint

## Expected output

### openapi.yaml file
- Complete specification with paths, schemas, security

### Documented endpoints
| Method | Path | Description |
|--------|------|-------------|

### Checklist
- [ ] All endpoints documented
- [ ] Schemas for all models
- [ ] Examples for each response
- [ ] Authentication documented
- [ ] Standardized error codes

## Related agents

| Agent | When to use it |
|-------|----------------|
| `/dev:dev-api` | Create or modify the API |
| `/doc:doc-generate` | General documentation |
| `/dev:dev-tdd` | Test endpoints |
| `/qa:qa-security` | Check API security |

---

IMPORTANT: API documentation must be synchronized with the code - use generators if possible.

YOU MUST document all possible error codes.

NEVER forget examples - they make integration easier for developers.

Think hard about API ergonomics before documenting.
