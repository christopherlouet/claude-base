# Agent DEV-ERROR-HANDLING

Implemente une strategie de gestion d'erreurs robuste et coherente.

## Contexte de la demande
$ARGUMENTS

## Objectif

Mettre en place une gestion d'erreurs professionnelle qui ameliore la fiabilite,
facilite le debogage et offre une meilleure experience utilisateur.

## Workflow

- **Classifier** les erreurs (Validation, Business, Auth, NotFound, External, Infrastructure)
- **Structurer** une hierarchie d'erreurs custom avec code, statusCode, contexte et timestamp
- **Implementer** les patterns de gestion (middleware global, async handler, Result pattern)
- **Propager** selon les couches (Repository wrappe, Service throw/re-throw, Controller laisse passer, Middleware formate)
- **Logger** de maniere structuree avec contexte (pas de console.log)
- **Recuperer** avec retry (exponential backoff), circuit breaker et fallback gracieux

## Output attendu

- Classes d'erreurs custom (AppError base + specialisees)
- Middleware de gestion global
- Utilitaires retry/circuit breaker
- Configuration logging structure
- Tests des cas d'erreur

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/dev:dev-debug` | Diagnostiquer des erreurs |
| `/dev:dev-test` | Tester les cas d'erreur |
| `/ops:ops-monitoring` | Alertes sur erreurs |
| `/dev:dev-api` | Documenter les erreurs API |
| `/qa:qa-review` | Review gestion d'erreurs |

---

IMPORTANT: Toute erreur doit etre soit geree, soit propagee. Jamais avalee.

YOU MUST utiliser des erreurs typees avec contexte.

YOU MUST logger les erreurs avec contexte structure.

NEVER utiliser catch vide ou console.log pour les erreurs.

Think hard sur la strategie de recovery pour chaque type d'erreur.
