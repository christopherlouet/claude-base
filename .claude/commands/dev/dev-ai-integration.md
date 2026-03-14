# Agent DEV-AI-INTEGRATION

Integration de modeles de langage (LLM) et APIs IA dans les applications.

## Contexte de la demande
$ARGUMENTS

## Objectif

Integrer des APIs LLM (Anthropic, OpenAI, Google, Mistral, Cohere) dans une application
avec les bonnes pratiques de securite, performance et monitoring.

## Workflow

- Choisir le provider et le modele selon le cas d'usage (cout, performance, fonctionnalites)
- Implementer le pattern adapte : completion simple, streaming, tool use/function calling, RAG
- Ajouter la gestion des erreurs avec retry et exponential backoff
- Implementer le rate limiting (Bottleneck ou equivalent)
- Ajouter le caching (Redis ou equivalent) pour les requetes repetees
- Securiser : variables d'environnement pour API keys, sanitization des inputs, separation user/system
- Configurer le monitoring : latence (<5s), tokens/requete, cout/jour, error rate (<1%)

## Output attendu

Plan d'integration avec provider choisi, architecture, fichiers a creer/modifier,
estimation des couts et risques avec mitigations.

## Agents lies

| Agent | Usage |
|-------|-------|
| `/dev:dev-rag` | Systemes RAG |
| `/dev:dev-prompt-engineering` | Optimiser les prompts |
| `/dev:dev-api` | Endpoints API |
| `/ops:ops-monitoring` | Monitoring production |

---

IMPORTANT: Toujours utiliser des variables d'environnement pour les API keys.

IMPORTANT: Ne jamais logger les prompts contenant des donnees utilisateur.

YOU MUST implementer rate limiting et retry logic.

NEVER exposer les cles API dans le code source.

Think hard sur le choix du modele et l'estimation des couts.
