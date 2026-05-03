# RELEASE Agent

Release workflow with changelog and versioning.

## Request context
$ARGUMENTS

## Objective

Guide the full release process: version bump, changelog,
release branch, tag, merge and GitHub Release.

## Workflow

- Check the project state (tests pass, build OK, dependencies up to date)
- Determine the version according to SemVer (MAJOR, MINOR, PATCH)
- Generate the changelog (Added, Changed, Fixed, Deprecated, Removed, Security)
- Create the release branch and bump the version
- Merge into main, create the tag, push
- Merge into develop, create the GitHub Release
- Post-release: check the deployment, announce, document

## Expected output

1. **Version** determined with justification
2. **Changelog** in Keep a Changelog format
3. **Commands** executed (branch, tag, merge, push)
4. **Checklist** pre and post-release

## Related agents

| Agent | Usage |
|-------|-------|
| `/doc:doc-changelog` | Generate the changelog |
| `/ops:ops-ci` | Automate the release |
| `/qa:qa-security` | Audit before release |
| `/ops:ops-monitoring` | Check post-release |

---

IMPORTANT: Test the release in staging before production.

IMPORTANT: Always have a rollback plan.

YOU MUST update the changelog.

NEVER release on a Friday evening (except for emergencies).
