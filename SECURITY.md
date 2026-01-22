# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.10.x  | :white_check_mark: |
| 1.9.x   | :white_check_mark: |
| 1.8.x   | :white_check_mark: |
| < 1.8   | :x:                |

## Reporting a Vulnerability

We take the security of claude-socle seriously. If you believe you have found a security vulnerability, please report it to us as described below.

### How to Report

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via one of the following methods:

1. **GitHub Security Advisories** (Preferred)
   - Go to the [Security tab](https://github.com/anthropics/claude-socle/security/advisories)
   - Click "Report a vulnerability"
   - Fill out the form with details

2. **Email**
   - Send an email to the maintainers
   - Include "SECURITY" in the subject line

### What to Include

Please include the following information in your report:

- Type of vulnerability (e.g., secret exposure, command injection, etc.)
- Full paths of source file(s) related to the vulnerability
- Location of the affected source code (tag/branch/commit or direct URL)
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

### Response Timeline

| Action | Timeline |
|--------|----------|
| Initial response | Within 48 hours |
| Status update | Within 7 days |
| Vulnerability confirmation | Within 14 days |
| Fix release | Within 30 days (critical) / 90 days (other) |

### What to Expect

1. **Acknowledgment**: We will acknowledge receipt of your vulnerability report within 48 hours.

2. **Communication**: We will keep you informed of our progress throughout the investigation.

3. **Credit**: If you report a valid vulnerability, we will credit you in the security advisory (unless you prefer to remain anonymous).

4. **No Legal Action**: We will not pursue legal action against you if you:
   - Act in good faith
   - Avoid privacy violations, destruction of data, or service interruption
   - Give us reasonable time to address the issue before public disclosure

## Security Measures

### Built-in Protections

claude-socle includes several security measures:

| Measure | Description |
|---------|-------------|
| **Gitleaks** | 24+ rules to detect secrets in code |
| **Pre-commit hooks** | Automatic secret detection before commits |
| **Permission controls** | Blocked dangerous commands (rm -rf /, push --force) |
| **Branch protection** | Prevents direct commits to main/master |
| **Dependency scanning** | npm audit in CI pipeline |
| **Input validation** | Strict bash options (set -euo pipefail) |

### Configuration Files

| File | Purpose |
|------|---------|
| `.gitleaks.toml` | Secret detection rules |
| `.pre-commit-config.yaml` | Pre-commit hook configuration |
| `.claude/settings.json` | Claude Code permissions |

## Security Best Practices

When using claude-socle, follow these best practices:

### Do's

- ✅ Keep the socle updated to the latest version
- ✅ Review `.claude/settings.json` permissions for your needs
- ✅ Use `CLAUDE.local.md` for sensitive project-specific instructions
- ✅ Enable all pre-commit hooks
- ✅ Run `npm audit` regularly
- ✅ Review PRs that modify security-related files

### Don'ts

- ❌ Commit `.env` files or secrets
- ❌ Disable gitleaks or pre-commit hooks
- ❌ Grant broad permissions in settings.json
- ❌ Skip security checks in CI
- ❌ Ignore Dependabot alerts

## Vulnerability Disclosure Policy

We follow a coordinated vulnerability disclosure process:

1. Reporter submits vulnerability
2. We confirm and assess severity
3. We develop and test a fix
4. We release the fix
5. We publish a security advisory
6. Reporter may publish their findings (after fix release)

### Severity Levels

| Level | CVSS Score | Response Time |
|-------|------------|---------------|
| Critical | 9.0 - 10.0 | 7 days |
| High | 7.0 - 8.9 | 14 days |
| Medium | 4.0 - 6.9 | 30 days |
| Low | 0.1 - 3.9 | 90 days |

## Security Updates

Security updates are released as:

- **Patch versions** (x.x.X) for security fixes
- **Security advisories** on GitHub
- **CHANGELOG.md** entries marked with `### Security`

Subscribe to GitHub notifications to receive security alerts.

## Contact

For security-related questions that are not vulnerabilities:

- Open a [GitHub Discussion](https://github.com/anthropics/claude-socle/discussions)
- Tag your question with "security"

---

Thank you for helping keep claude-socle and its users safe!
