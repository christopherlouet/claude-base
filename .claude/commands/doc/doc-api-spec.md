# Agent DOC-API-SPEC

Generer une specification OpenAPI/Swagger pour une API.

## Contexte
$ARGUMENTS

## Objectif

Explorer le code de l'API, identifier les routes et modeles, et generer une specification OpenAPI 3.0 complete avec schemas, authentification et exemples.

## Workflow

- Explorer les routes et controllers existants
- Identifier les modeles de donnees et DTOs
- Generer la structure OpenAPI 3.0 (info, servers, paths, components)
- Documenter chaque endpoint (parametres, body, responses, erreurs)
- Definir les schemas d'authentification (JWT, API Key, OAuth2)
- Standardiser les reponses d'erreur
- Valider la spec avec redocly lint

## Output attendu

### Fichier openapi.yaml
- Specification complete avec paths, schemas, security

### Endpoints documentes
| Methode | Path | Description |
|---------|------|-------------|

### Checklist
- [ ] Tous les endpoints documentes
- [ ] Schemas pour tous les modeles
- [ ] Exemples pour chaque reponse
- [ ] Authentification documentee
- [ ] Codes d'erreur standardises

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/dev:dev-api` | Creer ou modifier l'API |
| `/doc:doc-generate` | Documentation generale |
| `/dev:dev-test` | Tester les endpoints |
| `/qa:qa-security` | Verifier la securite de l'API |

---

IMPORTANT: La documentation API doit etre synchronisee avec le code - utiliser des generateurs si possible.

YOU MUST documenter tous les codes d'erreur possibles.

NEVER oublier les exemples - ils facilitent l'integration pour les developpeurs.

Think hard sur l'ergonomie de l'API avant de documenter.
