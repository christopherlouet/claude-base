# Testing Frameworks - Detailed Guide

> **Part of:** [infrastructure-as-code](../SKILL.md)
> **Goal:** In-depth guide to testing frameworks for Terraform/OpenTofu

---

## Table of Contents

1. [Static Analysis](#static-analysis)
2. [Plan Testing](#plan-testing)
3. [Native Terraform Tests](#native-terraform-tests)
4. [Terratest (Go)](#terratest-go)

---

## Static Analysis

**Always do this first.** Zero cost, catches 40%+ of issues before deployment.

### Pre-commit Hooks

```yaml
# In .pre-commit-config.yaml
- repo: https://github.com/antonbabenko/pre-commit-terraform
  hooks:
    - id: terraform_fmt
    - id: terraform_validate
    - id: terraform_tflint
```

### What Each Tool Checks

- **`terraform fmt`** - Formatting consistency
- **`terraform validate`** - Syntax and internal consistency
- **`TFLint`** - Best practices, provider-specific rules
- **`trivy` / `checkov`** - Security vulnerabilities

### When to Use

On every commit, always. Zero cost, catches 40%+ of issues.

---

## Plan Testing

### What terraform plan Validates

- Verify that expected resources will be created/modified/destroyed
- Detect provider authentication issues
- Validate variable combinations
- Review before apply

### In CI/CD

```bash
terraform init
terraform plan -out=tfplan

# Optional: Convert plan to JSON and validate with tools
terraform show -json tfplan | jq '.'
```

### Limitations

- Doesn't deploy real infrastructure
- Cannot detect runtime issues (IAM permissions, network connectivity)
- Doesn't find resource-specific bugs

---

## Native Terraform Tests

**Available:** Terraform 1.6+, OpenTofu 1.6+

### When to Use

- Team works primarily in HCL (no Go/Ruby experience needed)
- Testing logical operations and module behavior
- Avoiding external test dependencies

### Basic Structure

```hcl
# tests/s3_bucket.tftest.hcl
run "create_bucket" {
  command = apply

  assert {
    condition     = aws_s3_bucket.main.bucket != ""
    error_message = "S3 bucket name must be set"
  }
}

run "verify_encryption" {
  command = plan

  assert {
    condition     = aws_s3_bucket_server_side_encryption_configuration.main.rule[0].apply_server_side_encryption_by_default[0].sse_algorithm == "AES256"
    error_message = "Bucket must use AES256 encryption"
  }
}
```

### Important: Validate Resource Schemas

**Always check schemas before writing tests:**

- Some blocks are **sets** (unordered, no indexing with `[0]`)
- Some blocks are **lists** (ordered, indexable)
- Some attributes are **computed** (known only after apply)

**Common Schema Patterns:**

| AWS Resource | Block Type | Indexing |
|---------------|--------------|------------|
| `rule` in `aws_s3_bucket_server_side_encryption_configuration` | **set** | Not possible with `[0]` |
| `transition` in `aws_s3_bucket_lifecycle_configuration` | **set** | Not possible with `[0]` |
| `noncurrent_version_expiration` in lifecycle | **list** | Possible with `[0]` |

### Working with Set-Type Blocks

**Issue:** Cannot index sets with `[0]`
```hcl
# WRONG: Will fail
condition = aws_s3_bucket_server_side_encryption_configuration.this.rule[0].bucket_key_enabled == true
# Error: Cannot index a set value
```

**Solution 1:** Use `command = apply` to materialize the set
```hcl
run "test_encryption" {
  command = apply  # Creates real/mocked resources

  assert {
    condition = alltrue([
      for rule in aws_s3_bucket_server_side_encryption_configuration.this.rule :
      rule.bucket_key_enabled == true
    ])
    error_message = "Bucket key should be enabled"
  }
}
```

**Solution 2:** Check at the resource level (avoid accessing nested blocks)
```hcl
run "test_encryption_exists" {
  command = plan

  assert {
    condition     = aws_s3_bucket_server_side_encryption_configuration.this != null
    error_message = "Encryption configuration should be created"
  }
}
```

### command = plan vs command = apply

**Critical decision:** When to use each mode

#### Use `command = plan`

**When:**
- Verifying input validation
- Verifying that a resource will be created
- Testing variable defaults
- Verifying attributes derived from inputs (not computed)

```hcl
run "test_input_validation" {
  command = plan  # Fast, no resource creation

  variables {
    bucket = "test-bucket"
  }

  assert {
    condition     = aws_s3_bucket.this.bucket == "test-bucket"
    error_message = "Bucket name should match input"
  }
}
```

#### Use `command = apply`

**When:**
- Verifying computed attributes (IDs, ARNs, generated names)
- Accessing set-type blocks
- Verifying actual resource behavior
- Testing with real/mocked provider responses

```hcl
run "test_computed_values" {
  command = apply  # Executes and gets computed values

  variables {
    bucket_prefix = "test-"  # AWS generates the full name
  }

  assert {
    condition     = length(aws_s3_bucket.this.bucket) > 0
    error_message = "Bucket should have a generated name"
  }
}
```

**Quick Decision Guide:**
```
Verify input values? -> command = plan
Verify computed values? -> command = apply
Access set-type blocks? -> command = apply
Need fast feedback? -> command = plan (with mocks)
Test real behavior? -> command = apply (without mocks)
```

### With Mocking (1.7+)

```hcl
mock_provider "aws" {
  mock_resource "aws_instance" {
    defaults = {
      id  = "i-mock123"
      arn = "arn:aws:ec2:us-east-1:123456789:instance/i-mock123"
    }
  }
}
```

### Advantages

- Native HCL syntax (familiar to Terraform users)
- No external dependencies
- Fast execution with mocks
- Good for unit tests of module logic

### Disadvantages

- Newer feature (less mature than Terratest)
- Limited ecosystem/examples
- Mocking does not capture real AWS behavior

---

## Terratest (Go)

**Recommended for:** Teams with Go experience, robust integration tests

### When to Use

- Team has Go experience
- Need robust integration tests
- Testing multiple providers/complex infrastructure
- Battle-tested framework with large community

### Basic Structure

```go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestS3Module(t *testing.T) {
    t.Parallel() // ALWAYS include for parallel execution

    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/complete",
        Vars: map[string]interface{}{
            "bucket_name": "test-bucket-" + uniqueId(),
        },
    }

    // Clean up resources after test
    defer terraform.Destroy(t, terraformOptions)

    // Run terraform init and apply
    terraform.InitAndApply(t, terraformOptions)

    // Get outputs and verify
    bucketName := terraform.Output(t, terraformOptions, "bucket_name")
    assert.NotEmpty(t, bucketName)
}
```

### Cost Management

```go
// Use tags for automated cleanup
Vars: map[string]interface{}{
    "tags": map[string]string{
        "Environment": "test",
        "TTL":         "2h", // Auto-delete after 2 hours
    },
}
```

### Critical Patterns

1. **Always use `t.Parallel()`** - Enables parallel execution
2. **Always use `defer terraform.Destroy()`** - Ensures cleanup
3. **Use unique identifiers** - Avoid resource conflicts
4. **Tag resources** - Cost tracking and automated cleanup
5. **Use separate AWS accounts** - Isolate test infrastructure

### Real Costs

- Small module (S3, IAM): $0-5 per run
- Medium module (VPC, EC2): $5-20 per run
- Large module (RDS, ECS cluster): $20-100 per run

### Optimization with Test Stages

```go
// Test stages for faster iteration
stage := test_structure.RunTestStage

stage(t, "setup", func() {
    terraform.InitAndApply(t, opts)
})

stage(t, "validate", func() {
    // Assertions here
})

stage(t, "teardown", func() {
    terraform.Destroy(t, opts)
})

// Skip stages during development:
// export SKIP_setup=true
// export SKIP_teardown=true
```

---

## Best Practices Summary

### For All Frameworks

1. **Start with static analysis** - Always free, always fast
2. **Use unique identifiers** - Prevent resource conflicts
3. **Tag test resources** - Tracking and cleanup
4. **Separate test accounts** - Isolate test infrastructure
5. **Implement TTL** - Automatic resource cleanup

### Framework Selection

```
Quick syntax check? -> terraform validate + fmt
Security scan? -> trivy + checkov
Terraform 1.6+, simple logic? -> Native tests
Pre-1.6, or complex integration? -> Terratest
```

### Cost Optimization

1. Use mocking for unit tests
2. Implement TTL tags on resources
3. Run integration tests only on main branch
4. Use smaller instance types in tests
5. Share test resources when safe

---

**Back to:** [Main Skill File](../SKILL.md)
