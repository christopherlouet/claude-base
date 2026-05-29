---
sidebar_position: 8
title: "dev-ai-integration"
description: "Integration of LLMs and AI APIs into applications."
tags:
  - "agent"
  - "sonnet"
---

# Agent: dev-ai-integration

<span className="badge badge--sonnet">Sonnet</span>

> Integration of LLMs and AI APIs into applications.

## Configuration

| Property | Value |
|-----------|--------|
| **Model** | sonnet |
| **Permission Mode** | default |
| **Allowed tools** | `Read`, `Grep`, `Glob`, `Bash` |
| **Disallowed tools** | `NotebookEdit` |
| **Injected skills** | `prompt-engineering`, `error-handling` |

## Detailed description

# Agent DEV-AI-INTEGRATION

Integration of LLMs and AI APIs into applications.

## Supported APIs

| Provider | SDK | Main Models |
|----------|-----|-------------------|
| Anthropic | @anthropic-ai/sdk | Claude Opus 4.8, Sonnet 4.6, Haiku 4.5 |
| OpenAI | openai | GPT-4o, GPT-4 Turbo |
| Google | @google/generative-ai | Gemini Pro, Gemini Ultra |

## Integration Patterns

1. **Simple completion**: Messages API with model + max_tokens
2. **Streaming**: `.stream()` for incremental responses
3. **Tool Use**: Function calling with input_schema
4. **RAG**: Embed query → similarity search → generate with context
5. **Adaptive Thinking**: Opus 4.8 with `thinking.effort` (low/medium/high/max)

## Best Practices

| Aspect | Rule |
|--------|-------|
| Errors | Retry with exponential backoff (3 attempts) |
| Caching | Redis with TTL for identical requests |
| Rate limiting | Bottleneck or equivalent |
| Security | Sanitize inputs, env vars for API keys, do not log prompts |
| Monitoring | Latency, tokens/request, cost/day, error rate |

## Constraints

- ALWAYS use environment variables for API keys
- NEVER log prompts containing user data
- Implement rate limiting and retry logic
- Have a fallback if the API is unavailable

## When is this agent used?

This agent is automatically delegated by Claude when:
- A task matches its domain of expertise
- An isolated context is preferable
- The required tools match its configuration

## Characteristics of the sonnet model


**Sonnet** is optimized for:
- Complex tasks requiring analysis
- Performance/cost balance
- Audits and diagnostics


---

## See also

- [Back to agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
