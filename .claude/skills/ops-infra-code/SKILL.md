---
name: ops-infra-code
description: Infrastructure as Code with Terraform/OpenTofu. Points to Anton Babenko's terraform-skill and HashiCorp's own Terraform skills, and keeps the foundation's discipline (state and secrets, plan review, scans, deploy gate). Trigger to create modules, configure backends, write idiomatic HCL, or audit infrastructure.
argument-hint: "[module-name]"
---

# Infrastructure as Code (pointer)

This skill used to be an excerpt of Anton Babenko's terraform-skill. The upstream is now a strict superset (state management, CI/CD workflows, terraform-ls, OpenTofu-specific guidance, a failure-mode diagnosis workflow), and HashiCorp publishes its own Terraform skills. Install them; this file keeps only the foundation's discipline.

## Delegate to the vendor skills

| Skill | Publisher | Covers | Pin |
|-------|-----------|--------|-----|
| [`antonbabenko/terraform-skill`](https://github.com/antonbabenko/terraform-skill) | Anton Babenko (community, Apache-2.0) | Terraform **and OpenTofu**: modules, testing strategy, state, CI/CD, security scans, version management | `v1.17.1` |
| [`hashicorp/agent-skills`](https://github.com/hashicorp/agent-skills) `terraform/*` | HashiCorp (MPL-2.0) | Official style guide, `terraform test`, module refactoring, Stacks, search/import, policy; Packer image builders | `v1.0.0` |

```bash
# Babenko — the depth, Terraform and OpenTofu
git clone --depth 1 --branch v1.17.1 https://github.com/antonbabenko/terraform-skill ~/dev/vendor-skills/terraform-skill
ln -s ~/dev/vendor-skills/terraform-skill/skills/terraform-skill ./.claude/skills/terraform-skill

# HashiCorp — install the skills you need, not the plugins
npx skills add hashicorp/agent-skills/terraform/code-generation/skills/terraform-style-guide
npx skills add hashicorp/agent-skills/terraform/code-generation/skills/terraform-test
```

HashiCorp's Claude **plugins** (`terraform-code-generation`, `-module-generation`, `-policy-code`) also register an MCP server that runs the unpinned `hashicorp/terraform-mcp-server` Docker image with your `TFE_TOKEN`: install the skill folders unless you want that server.

Neither covers OpenTofu-only features as HashiCorp would (HashiCorp's skills are Terraform-only); Babenko's does. For Pulumi, see [`pulumi/agent-skills`](https://github.com/pulumi/agent-skills).

Recipe entries: [`docs/recipes/recommended-vendor-skills.md`](../../../docs/recipes/recommended-vendor-skills.md) §"Anton Babenko" and §"HashiCorp".

## Foundation discipline (keep across releases)

- **State and secrets**: never commit `*.tfstate`, `*.tfstate.backup`, `.terraform/` or a `*.tfvars` holding secrets; use a remote backend with locking and encryption at rest. Secrets come from a secret manager or the CI's secret store, never from a committed variable — `.claude/rules/security.md`.
- **Plan before apply, always**: review `terraform plan` (or `tofu plan`) output before any `apply`; in CI, apply the saved plan file that was reviewed, not a fresh plan.
- **Scan in CI**: `trivy config .` or `checkov -d .` as a blocking step — the `ops-ci` skill wires it.
- **Production goes through the deploy gate**: an apply against production follows `/ops:ops-deploy` (pre-deploy checklist, rollback plan) and `.claude/rules/deploy-safety.md`.
- **Version constraints**: `~> 5.0` allows any 5.x (≥ 5.0, < 6.0); `~> 5.0.1` allows only 5.0.x. Pin providers to a major, production modules to an exact version, and commit `.terraform.lock.hcl`.
- **Destructive changes**: a plan that destroys or replaces stateful resources (databases, volumes, buckets) needs an explicit human go — `prevent_destroy` on those resources, `moved` blocks for renames instead of destroy/create.
