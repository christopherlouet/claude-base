# Agent DEV-AI-INTEGRATION

Integration of language models (LLM) and AI APIs into applications.

## Request context
$ARGUMENTS

## Objective

Integrate LLM APIs (Anthropic, OpenAI, Google, Mistral, Cohere) into an application
with security, performance, and monitoring best practices.

## Workflow

- Choose the provider and model based on the use case (cost, performance, features)
- Implement the appropriate pattern: simple completion, streaming, tool use/function calling, RAG
- Add error handling with retry and exponential backoff
- Implement rate limiting (Bottleneck or equivalent)
- Add caching (Redis or equivalent) for repeated requests
- Secure: environment variables for API keys, input sanitization, user/system separation
- Configure monitoring: latency (<5s), tokens/request, cost/day, error rate (<1%)

## Expected output

Integration plan with chosen provider, architecture, files to create/modify,
cost estimation, and risks with mitigations.

## Related agents

| Agent | Usage |
|-------|-------|
| `/dev:dev-rag` | RAG systems |
| `/dev:dev-api` | API endpoints |
| `/ops:ops-monitoring` | Production monitoring |

---

IMPORTANT: Always use environment variables for API keys.

IMPORTANT: Never log prompts containing user data.

YOU MUST implement rate limiting and retry logic.

NEVER expose API keys in source code.

Think hard about model choice and cost estimation.
