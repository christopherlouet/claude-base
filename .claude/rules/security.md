---
paths:
  - "**/auth/**"
  - "**/api/**"
  - "**/routes/**"
  - "**/controllers/**"
  - "**/middleware/**"
  - "**/services/**"
---

# Security Rules

## Input Validation

- IMPORTANT: Validate ALL user inputs
- Use validation schemas (Zod, Joi, class-validator)
- Reject invalid data as early as possible
- Sanitize inputs before processing

## Output Encoding

- IMPORTANT: Escape HTML outputs (XSS prevention)
- Use the framework's native escaping functions
- Never insert non-sanitized HTML into the DOM
- Avoid `innerHTML` and `dangerouslySetInnerHTML`

## Database Security

- IMPORTANT: Use parameterized queries (SQL injection prevention)
- Prefer ORMs with prepared statements
- Never concatenate user inputs into queries
- Limit the privileges of database accounts

## Secrets Management

- NEVER commit secrets (.env, credentials, API keys)
- Use environment variables
- Rotate secrets regularly
- Use a secrets manager in production

## Logging

- Never log sensitive data (passwords, tokens, PII)
- Mask sensitive information in logs
- Log security events (auth, access)

## Dependencies

- Run `npm audit` regularly
- Update dependencies with critical vulnerabilities
- Verify dependencies before installation
- Use lockfiles (package-lock.json)

## Supply chain — installers and pipe-to-shell

- IMPORTANT: Avoid `curl URL | sh` (piping a remote script straight into a shell runs it unverified). Prefer **download → verify → execute**: fetch the script, check it against a published checksum/signature, then run it. The foundation's `command-validator.sh` hook blocks pipe-to-shell in agent sessions.
- Pin installers to a released **tag**, not a moving branch (`main`), so installs are reproducible and a mid-flight bad commit can't reach users.
- Publish per-release `SHA256SUMS` (computed on the tagged commit so they never drift from what ships) and document the verify step; fetch the script from the **same tag** as the checksum, not from `main`.
- Treat `curl URL | sudo sh` as a hard no — it combines unverified code with privilege escalation.

## Security-config propagation (downstream drift)

- A version bump is NOT a security bump: `update` advances the recorded version but leaves `settings.json` / `scripts/hooks/` opt-in, so a downstream project can run stale, inert security hooks while reading as up-to-date.
- The worst case is a **hook contract drift**: hooks reading the old `$TOOL_*` env vars (pre-stdin) silently no-op — a screen like `command-validator.sh` becomes a dead pass-through. A bare `mcp__*` wildcard in `permissions.allow` is also flagged (over-broad: it grants every MCP tool; scope to `mcp__server__tool`).
- Run `claude-base doctor` (section "Security drift") to detect it; re-sync with `update --settings --hook-scripts --force` (overwrites diverged hooks). The `update` advisory flags this automatically after a drifted run.

## Authentication

- Hash passwords with bcrypt or argon2
- Implement brute-force protection
- Use secure sessions (httpOnly, secure, sameSite)
- Implement token expiration

## Claude Code Security (third-party repos)

3 attack vectors identified (Feb. 2026) when cloning untrusted repos:

- **Malicious hooks**: a `.claude/settings.json` from the repo can contain hooks executing arbitrary commands
- **Untrusted MCP**: a `.mcp.json` can configure MCP servers exfiltrating data
- **Environment variables**: hooks can read and transmit the contents of `.env` or system secrets

Best practices:
- Verify the contents of `.claude/settings.json` and `.mcp.json` before opening a third-party repo with Claude Code
- Keep MCP servers disabled by default
- Make sure `.env` is in `.gitignore`
- The foundation includes SessionStart hooks for automatic verification

## Bash Hardening (CLI 2.1.113+)

Hardening applied directly by the CLI. Worth knowing to write consistent `permissions` rules and avoid unintentional bypasses:

- **Extended dangerous paths**: `/private/{etc,var,tmp,home}` (macOS) are treated as dangerous removal targets just like `/etc`, `/var`, etc.
- **Deny rules resistant to execution wrappers**: a `deny: Bash(rm -rf *)` rule also matches when the command is wrapped in `env`, `sudo`, `watch`, `ionice` or `setsid`. No longer rely on these wrappers to bypass a deny rule.
- **`Bash(find:*)` no longer auto-approves `-exec`/`-delete`**: these sub-commands can modify or delete files, so they now trigger a separate permission prompt even if `find:*` is allowlisted.
- **Sandbox deniedDomains**: prefer `sandbox.network.deniedDomains` to explicitly exclude sensitive domains even under a wildcard `allowedDomains`.
- **UI-spoofing fix**: multiline comments in Bash commands now display the full command to prevent a comment from masking the actual intent.

To apply in `.claude/settings.json`:

```json
{
  "permissions": {
    "deny": ["Bash(find:* -delete)", "Bash(find:* -exec *)"],
    "sandbox": {
      "network": {
        "allowedDomains": ["*.npmjs.org", "*.github.com"],
        "deniedDomains": ["pastebin.com", "transfer.sh"]
      },
      "failIfUnavailable": true
    }
  }
}
```
