---
name: ops-infra-code
description: Infrastructure as Code with Terraform/OpenTofu. Points to Anton Babenko's terraform-skill and HashiCorp's own Terraform skills, and keeps the foundation's discipline (state and secrets, plan review, scans, deploy gate). Trigger to create modules, configure backends, write idiomatic HCL, or audit infrastructure.
argument-hint: "[module-name]"
---

# Infrastructure as Code (pointer)

This skill used to be an excerpt of Anton Babenko's terraform-skill. The upstream is now a strict superset (state management, CI/CD workflows, terraform-ls, OpenTofu-specific guidance, a failure-mode diagnosis workflow), and HashiCorp publishes its own Terraform skills. Install them; this file keeps the foundation's discipline and the core patterns below.

## Delegate to the vendor skills

| Skill | Publisher | Covers | Pin |
|-------|-----------|--------|-----|
| [`antonbabenko/terraform-skill`](https://github.com/antonbabenko/terraform-skill) | Anton Babenko (community, Apache-2.0) | Terraform **and OpenTofu**: modules, testing strategy, state, CI/CD, security scans, version management | `v1.17.1` |
| [`hashicorp/agent-skills`](https://github.com/hashicorp/agent-skills) `terraform/*` | HashiCorp (MPL-2.0) | Official style guide, `terraform test`, module refactoring, Stacks, search/import, policy; Packer image builders | `v1.0.0` |

```bash
# Babenko — the depth, Terraform and OpenTofu (pinned release)
git clone --depth 1 --branch v1.17.1 https://github.com/antonbabenko/terraform-skill ~/dev/vendor-skills/terraform-skill
ln -s ~/dev/vendor-skills/terraform-skill/skills/terraform-skill ./.claude/skills/terraform-skill

# HashiCorp — the skill folders you need, not the plugins (pinned release)
git clone --depth 1 --branch v1.0.0 https://github.com/hashicorp/agent-skills ~/dev/vendor-skills/hashicorp
ln -s ~/dev/vendor-skills/hashicorp/terraform/code-generation/skills/terraform-style-guide ./.claude/skills/terraform-style-guide
ln -s ~/dev/vendor-skills/hashicorp/terraform/code-generation/skills/terraform-test ./.claude/skills/terraform-test
```

HashiCorp's Claude **plugins** (`terraform-code-generation`, `-module-generation`, `-policy-code`) also register an MCP server that runs the unpinned `hashicorp/terraform-mcp-server` Docker image with your `TFE_TOKEN`: install the skill folders unless you want that server.

HashiCorp's skills are Terraform-only; for OpenTofu, rely on Babenko's. Its security reference installs Trivy with an unpinned `curl … | sh`: prefer a pinned release or a package manager. For Pulumi, see [`pulumi/agent-skills`](https://github.com/pulumi/agent-skills).

Recipe entries: [`docs/recipes/recommended-vendor-skills.md`](../../../docs/recipes/recommended-vendor-skills.md) §"Anton Babenko" and §"HashiCorp".

## Core HCL patterns (kept for the `ops-infra-code` agent, which preloads this skill and cannot load a vendor skill)

**Layout**: `modules/<name>/` (`main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`) reused by `environments/{dev,staging,prod}/`; one state per environment. Hierarchy: resource → resource module (VPC + subnets) → infrastructure module (a region/account) → composition.

**Naming**: descriptive resource names (`aws_s3_bucket.application_logs`), `this` for the single resource of its type in a module, context-prefixed variables (`vpc_cidr_block`, not `cidr`).

**Block order** — resource: `count`/`for_each` first, then arguments, `tags`, `depends_on`, `lifecycle` last. Variable: `description` (always), `type`, `default`, `validation`, `nullable = false`.

**`count` vs `for_each`**:

| Case | Use |
|------|-----|
| Create or not | `count = var.enabled ? 1 : 0` |
| Items that can be added, removed or reordered | `for_each = toset(var.items)` — removing one item touches only that item |
| Access by name | `for_each = var.map` |

`count = length(var.list)` re-addresses every item after a removed one, so Terraform destroys and recreates them.

**Testing ladder**: `terraform fmt -check` + `validate` + `tflint` + `trivy config .` on every commit → `terraform test` (1.6+, mock providers from 1.7) for module logic → real-resource tests (Terratest) in a sandbox account only where behaviour cannot be mocked → policy as code (OPA/Conftest) for compliance.

## Foundation discipline (keep across releases)

- **State and secrets**: never commit `*.tfstate`, `*.tfstate.backup`, `.terraform/` or a `*.tfvars` holding secrets; use a remote backend with locking and encryption at rest. Secrets come from a secret manager or the CI's secret store, never from a committed variable — `.claude/rules/security.md`.
- **Plan before apply, always**: review `terraform plan` (or `tofu plan`) output before any `apply`; in CI, apply the saved plan file that was reviewed, not a fresh plan.
- **Scan in CI**: `trivy config .` or `checkov -d .` as a blocking step — the `ops-ci` skill wires it.
- **Production goes through the deploy gate**: an apply against production follows `/ops:ops-deploy` (pre-deploy checklist, rollback plan) and `.claude/rules/deploy-safety.md`.
- **Version constraints**: `~> 5.0` allows any 5.x (≥ 5.0, < 6.0); `~> 5.0.1` allows only 5.0.x. Pin providers to a major, production modules to an exact version, and commit `.terraform.lock.hcl`.
- **Destructive changes**: a plan that destroys or replaces stateful resources (databases, volumes, buckets) needs an explicit human go — `prevent_destroy` on those resources, `moved` blocks for renames instead of destroy/create.
