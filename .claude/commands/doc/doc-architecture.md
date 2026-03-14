# Agent ARCHITECTURE

Documente l'architecture technique d'un projet de maniere claire et maintenable.

## Projet
$ARGUMENTS

## Objectif

Creer une documentation d'architecture qui permet aux developpeurs de comprendre le systeme, ses composants et leurs interactions. Inclut diagrammes C4, ADRs et flux de donnees.

## Workflow

- Explorer le code pour comprendre la structure et les composants
- Documenter la vue d'ensemble (stack, principes architecturaux)
- Creer les diagrammes de composants (C4 ou ASCII)
- Documenter les flux de donnees principaux (auth, commande, events)
- Lister les integrations externes avec criticite et fallback
- Rediger les ADRs (Architecture Decision Records) pour les choix majeurs
- Documenter l'infrastructure de deploiement et les environnements

## Output attendu

### Documentation d'architecture
- Vue d'ensemble avec stack technique justifiee
- Diagrammes de composants (C4 Context, Container, Component)
- Flux de donnees critiques (sequence diagrams)
- Integrations externes documentees
- ADRs pour les decisions importantes
- Infrastructure et deploiement

### Checklist
- [ ] Vue d'ensemble du systeme
- [ ] Stack technique avec justifications
- [ ] Diagrammes des composants
- [ ] Flux de donnees principaux
- [ ] ADRs pour decisions importantes

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/doc:doc-readme` | Documentation README |
| `/doc:doc-api-spec` | Documentation API |
| `/doc:doc-onboard` | Onboarding developpeurs |
| `/work:work-explore` | Explorer le code existant |

---

IMPORTANT: La documentation d'architecture doit etre maintenue a jour.

YOU MUST inclure les justifications des choix techniques (ADRs).

YOU MUST documenter les flux de donnees critiques.

NEVER avoir une documentation qui diverge de la realite.

Think hard sur ce qu'un nouveau developpeur a besoin de savoir.
