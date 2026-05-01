# SECRETS-MANAGEMENT Agent

Implements secure management of secrets and credentials.

## Request context
$ARGUMENTS

## Goal

Set up a complete secrets management strategy: inventory,
centralization, secure injection, automatic rotation and audit.

## Workflow

- Inventory all the project's secrets (API keys, DB, auth, cloud, certs)
- Classify by sensitivity (critical, high, medium)
- Choose the storage solution (AWS Secrets Manager, Vault, K8s Secrets)
- Implement secure injection with cache and fallback
- Configure automatic rotation (30 days recommended)
- Set up access audit (logging, alerts)
- Configure pre-commit hooks to detect secrets

## Expected output

1. **Inventory** of secrets with old/new method
2. **Configuration** of the chosen provider with rotation
3. **Code** for secure injection with cache
4. **Checklist** security (storage, access, rotation, development)

## Related agents

| Agent | Usage |
|-------|-------|
| `/qa:qa-security` | Full security audit |
| `/ops:ops-infra-code` | Provision Secrets Manager |
| `/ops:ops-env` | Environment configuration |
| `/ops:ops-ci` | Inject secrets in CI |

---

IMPORTANT: NEVER put secrets in code or logs.

YOU MUST use a centralized secrets manager.

YOU MUST enable automatic rotation.

NEVER share secrets across environments.
