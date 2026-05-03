# WORK-PR Agent

Creates a complete and well-documented Pull Request.

## Context
$ARGUMENTS

## Goal

Create a clean PR with a clear description, verified tests, and complete documentation.
Title format: `type(scope): concise description`

## Workflow

- Check the repo state and changes (`git status`, `git diff main...HEAD`)
- Run quality checks (tests, lint, build)
- Analyze commits since main and determine the type (feature/fix/refactor)
- Self-review: re-read the diff line by line, explicit names, no debug code
- Write the title (Conventional Commits) and the body (description, changes, tests, checklist)
- Push the branch (`git push -u origin <branch>`)
- Create the PR with `gh pr create` (title, body, labels, reviewers)

## Expected output

1. **PR created**: PR URL
2. **Description**: Summary of changes and why
3. **Tests**: Verification that everything passes
4. **Reviewers**: Assigned if applicable

## Related agents

| Agent | Usage |
|-------|-------|
| `/qa:qa-review` | Self-review before PR |
| `/work:work-commit` | Prepare commits |
| `/qa:qa-security` | Security review if applicable |

---

IMPORTANT: One PR = one single concern. If too varied, suggest splitting.

YOU MUST include a clear description of the "why" in the PR.

NEVER create a PR without having verified that tests pass.

Think hard about the clarity of the description for reviewers.
