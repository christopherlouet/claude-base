# WORK-FLOW-RELEASE Agent

Complete workflow to prepare and publish a release.

## Context
$ARGUMENTS

## Objective

Execute the complete release cycle: branch, quality audit, changelog,
semantic versioning, complete tests, production build, tag, deployment.

## Workflow

- **BRANCH**: Create `release/vX.Y.Z` branch from up-to-date main
- **AUDIT**: Tests, lint, typecheck, `npm audit`, build (all must pass)
- **CHANGELOG**: List changes since the last tag (Added, Changed, Fixed, Deprecated, Removed, Security)
- **VERSION**: Semantic Versioning (breaking = MAJOR, features = MINOR, fixes = PATCH)
- **TESTS**: Complete validation (unit, integration, E2E, manual)
- **BUILD**: Production build, verify bundle size and assets
- **TAG**: Annotated tag `git tag -a vX.Y.Z`, push, GitHub release with notes
- **DEPLOY**: Production deployment with rollback plan ready

## Performance notes

- **Use the project's parallel test runner** when one exists. On claude-base specifically, `bash scripts/test.sh` runs ~4.5x faster than `bats tests/*.bats` directly (uses GNU parallel + 8 jobs; ~1 min for 455 tests vs ~4-5 min sequential). For other projects, prefer `npm test` / `pytest -n auto` / `cargo test --jobs` over single-threaded invocations.
- **Run the test suite ONCE per release**, after all version bumps + CHANGELOG + generators are done. Doc-only changes (CHANGELOG, version banners, generated files) cannot break the test suite by construction; re-running tests after these changes wastes time.

## Expected output

1. **Audit**: Quality go/no-go report
2. **Changelog**: CHANGELOG.md updated
3. **Release**: Tag + release notes on GitHub
4. **Deploy**: Application deployed, monitoring OK

## Related agents

| Agent | Usage |
|-------|-------|
| `/qa:qa-audit` | Quality audit |
| `/doc:doc-changelog` | Changelog |
| `/dev:dev-tdd` | Complete tests |
| `/ops:ops-release` | Simplified alternative |
| `/ops:ops-monitoring` | Post-deployment |

---

IMPORTANT: Never skip tests before a release.

YOU MUST have a rollback plan ready before deploying.

NEVER deploy on a Friday evening (except critical hotfix).

Think hard about the impact of each change on users.
