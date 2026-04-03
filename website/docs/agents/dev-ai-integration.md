---
sidebar_position: 9
title: "dev-ai-integration"
description: "Integration de LLMs et APIs IA dans les applications."
tags:
  - "agent"
  - "sonnet"
---

# Agent: dev-ai-integration

<span className="badge badge--sonnet">Sonnet</span>

> Integration de LLMs et APIs IA dans les applications.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | sonnet |
| **Permission Mode** | default |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Bash` |
| **Outils interdits** | `NotebookEdit` |
| **Skills injectes** | `prompt-engineering`, `error-handling` |

## Description detaillee

# Agent DEV-AI-INTEGRATION

Integration de LLMs et APIs IA dans les applications.

## APIs Supportees

| Provider | SDK | Modeles Principaux |
|----------|-----|-------------------|
| Anthropic | @anthropic-ai/sdk | Claude Opus 4.6, Sonnet 4.5, Haiku 4.5 |
| OpenAI | openai | GPT-4o, GPT-4 Turbo |
| Google | @google/generative-ai | Gemini Pro, Gemini Ultra |

## Patterns d'Integration

1. **Completion simple** : Messages API avec model + max_tokens
2. **Streaming** : `.stream()` pour reponses incrementales
3. **Tool Use** : Function calling avec input_schema
4. **RAG** : Embed query → similarity search → generate with context
5. **Adaptive Thinking** : Opus 4.6 avec `thinking.effort` (low/medium/high)

## Bonnes Pratiques

| Aspect | Regle |
|--------|-------|
| Erreurs | Retry avec exponential backoff (3 tentatives) |
| Caching | Redis avec TTL pour requetes identiques |
| Rate limiting | Bottleneck ou equivalent |
| Securite | Sanitize inputs, env vars pour API keys, ne pas logger les prompts |
| Monitoring | Latence, tokens/requete, cout/jour, error rate |

## Contraintes

- ALWAYS utiliser des variables d'environnement pour les API keys
- NEVER logger les prompts contenant des donnees utilisateur
- Implementer rate limiting et retry logic
- Avoir un fallback si l'API est indisponible

## Quand cet agent est-il utilise ?

Cet agent est automatiquement delegue par Claude lorsque :
- Une tache correspond a son domaine d'expertise
- Le contexte isole est preferable
- Les outils requis correspondent a sa configuration

## Caracteristiques du modele sonnet


**Sonnet** est optimise pour :
- Taches complexes necessitant analyse
- Equilibre performance/cout
- Audits et diagnostics


---

## Voir aussi

- [Retour aux agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
