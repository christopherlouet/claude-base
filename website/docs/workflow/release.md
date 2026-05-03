---
sidebar_position: 5
title: Release
description: Workflow to prepare a release
---

# Workflow: Release

Guide to prepare and publish a new version.

## Quick command

```bash
/work:work-flow-release "v2.0.0"
```

## Detailed steps

### 1. Preparation

```bash
# Verify that develop is stable
/qa:qa-audit
```

Pre-release checklist:
- [ ] All tests pass
- [ ] Security audit OK
- [ ] Documentation up to date
- [ ] CHANGELOG prepared

### 2. Create the release branch

```bash
/ops:ops-gitflow-release start "v2.0.0"
```

### 3. Version bump

Update the version files:
- `package.json`
- `pubspec.yaml`
- `version.ts`

### 4. Changelog

```bash
/doc:doc-changelog
```

Generate the changelog from commits:
```markdown
## [2.0.0] - 2025-01-17

### Added
- Feature A
- Feature B

### Fixed
- Bug X
- Bug Y

### Changed
- Breaking change Z
```

### 5. Final tests

```bash
/qa:qa-audit
```

Verify one last time:
- Performance
- Security
- Accessibility

### 6. Finalize the release

```bash
/ops:ops-gitflow-release finish "v2.0.0"
```

This:
- Merges into `main`
- Creates the `v2.0.0` tag
- Merges into `develop`
- Deletes the release branch

### 7. Deploy

```bash
# Depending on your pipeline
npm run deploy
```

## Semantic Versioning

| Type | Version | When |
|------|---------|------|
| MAJOR | X.0.0 | Breaking changes |
| MINOR | 0.X.0 | New features |
| PATCH | 0.0.X | Bug fixes |

## Concrete example

```bash
# Prepare release 2.0.0

> /work:work-flow-release "v2.0.0"

# Claude:
# 1. Checks the state of develop
# 2. Creates release/v2.0.0
# 3. Bumps the version
# 4. Generates the changelog
# 5. Runs the audits
# 6. Finalizes the release
# 7. Creates the tag
```

## GitHub Release

After the finish:

```bash
gh release create v2.0.0 \
  --title "Release v2.0.0" \
  --notes-file CHANGELOG.md \
  --latest
```

## Final checklist

- [ ] Version bump done
- [ ] CHANGELOG.md up to date
- [ ] Tests pass
- [ ] Documentation up to date
- [ ] Tag created
- [ ] GitHub Release published
- [ ] Deployment done
- [ ] Announcement communicated

---

## See also

- [GitFlow Release](/docs/commands/ops/ops-gitflow-release)
- [Changelog](/docs/commands/doc/doc-changelog)
- [Audit](/docs/commands/qa/qa-audit)
