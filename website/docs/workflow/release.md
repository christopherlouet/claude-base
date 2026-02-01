---
sidebar_position: 5
title: Release
description: Workflow pour preparer une release
---

# Workflow : Release

Guide pour preparer et publier une nouvelle version.

## Commande rapide

```bash
/work:work-flow-release "v2.0.0"
```

## Etapes detaillees

### 1. Preparation

```bash
# Verifier que develop est stable
/qa:qa-audit
```

Checklist pre-release :
- [ ] Tous les tests passent
- [ ] Audit de securite OK
- [ ] Documentation a jour
- [ ] CHANGELOG prepare

### 2. Creer la branche release

```bash
/ops:ops-gitflow-release start "v2.0.0"
```

### 3. Bump de version

Mettre a jour les fichiers de version :
- `package.json`
- `pubspec.yaml`
- `version.ts`

### 4. Changelog

```bash
/doc:doc-changelog
```

Generer le changelog depuis les commits :
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

### 5. Tests finaux

```bash
/qa:qa-audit
```

Verifier une derniere fois :
- Performance
- Securite
- Accessibilite

### 6. Finaliser la release

```bash
/ops:ops-gitflow-release finish "v2.0.0"
```

Cela :
- Merge dans `main`
- Cree le tag `v2.0.0`
- Merge dans `develop`
- Supprime la branche release

### 7. Deployer

```bash
# Selon votre pipeline
npm run deploy
```

## Versioning Semantique

| Type | Version | Quand |
|------|---------|-------|
| MAJOR | X.0.0 | Breaking changes |
| MINOR | 0.X.0 | Nouvelles features |
| PATCH | 0.0.X | Bug fixes |

## Exemple concret

```bash
# Preparer la release 2.0.0

> /work:work-flow-release "v2.0.0"

# Claude :
# 1. Verifie l'etat de develop
# 2. Cree release/v2.0.0
# 3. Bump la version
# 4. Genere le changelog
# 5. Lance les audits
# 6. Finalise la release
# 7. Cree le tag
```

## Release GitHub

Apres le finish :

```bash
gh release create v2.0.0 \
  --title "Release v2.0.0" \
  --notes-file CHANGELOG.md \
  --latest
```

## Checklist finale

- [ ] Version bump effectue
- [ ] CHANGELOG.md a jour
- [ ] Tests passent
- [ ] Documentation a jour
- [ ] Tag cree
- [ ] Release GitHub publiee
- [ ] Deploiement effectue
- [ ] Annonce communiquee

---

## Voir aussi

- [GitFlow Release](/docs/commands/ops/ops-gitflow-release)
- [Changelog](/docs/commands/doc/doc-changelog)
- [Audit](/docs/commands/qa/qa-audit)
