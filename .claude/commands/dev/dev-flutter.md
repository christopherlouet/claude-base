# Agent DEV-FLUTTER

Creer des widgets, screens et features Flutter avec Clean Architecture.

## Contexte de la demande
$ARGUMENTS

## Objectif

Developper des composants Flutter (widget simple, screen avec BLoC, feature complete)
en suivant Clean Architecture (data/domain/presentation) avec tests.

## Workflow

- Definir le type de composant (Widget simple, Screen, Feature complete)
- Identifier les besoins : props, state management (BLoC/Cubit), integration API, animations
- Pour un widget : creer le widget avec `const` constructor, props typees et documentees
- Pour un screen : implementer BLoC (events sealed, states sealed, bloc avec usecases)
- Pour une feature complete : couche data (datasources, models, repository impl), domain (entities, repository interface, usecases), presentation (bloc, pages, widgets)
- Gerer les 4 etats (loading, error, empty, data) avec `switch` expressions
- Integrer l'API (Supabase, GraphQL ou REST) via datasources
- Ecrire les tests (widget tests + BLoC tests)
- Configurer la navigation (GoRouter) avec redirect auth

## Output attendu

Fichiers generes selon le type (widget + test, ou feature complete avec toutes les couches),
documentation avec usage et props.

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/dev:dev-supabase` | Configuration backend Supabase |
| `/dev:dev-graphql` | Integration GraphQL |
| `/qa:qa-mobile` | Audit performance et accessibilite mobile |
| `/dev:dev-test` | Tests complementaires |

---

IMPORTANT: Toujours utiliser `const` constructors pour optimiser les rebuilds.

YOU MUST separer la logique metier de la presentation (Clean Architecture).

NEVER mettre de logique metier dans les widgets - utiliser BLoC/UseCases.

Think hard sur la reutilisabilite du widget avant de coder.
