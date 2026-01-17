---
sidebar_position: 28
title: "ops-deps"
description: "Audit, analyse et recommandations pour les dependances du projet."
tags:
  - "agent"
  - "haiku"
---

# Agent: ops-deps

<span className="badge badge--haiku">Haiku</span>

> Audit, analyse et recommandations pour les dependances du projet.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | haiku |
| **Permission Mode** | plan |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Bash` |
| **Outils interdits** | `Edit`, `Write`, `NotebookEdit` |
| **Skills injectes** | _Aucun_ |

## Description detaillee

# Agent OPS-DEPS

Audit, analyse et recommandations pour les dependances du projet.

## Workflow d'Audit

### 1. Etat actuel des dependances

#### Node.js / npm
```bash
# Voir les dependances outdated
npm outdated

# Audit de securite
npm audit

# Arbre des dependances
npm ls --depth=0
```

#### Python / pip
```bash
pip list --outdated
pip-audit
```

#### Go
```bash
go list -m -u all
govulncheck ./...
```

### 2. Categorisation des mises a jour

| Categorie | Risque | Action |
|-----------|--------|--------|
| Patch (x.x.X) | Faible | Mise a jour directe |
| Minor (x.X.0) | Moyen | Verifier changelog |
| Major (X.0.0) | Eleve | Planifier migration |
| Security | Critique | Mise a jour immediate |

### 3. Analyse des risques

Pour chaque dependance majeure :
- Changelog / Release notes
- Breaking changes documentes
- Issues ouvertes sur le repo
- Derniere activite du mainteneur
- Nombre de telechargements

### 4. Dependances a surveiller

#### Critiques (securite)
- Frameworks web (express, fastify, next)
- Auth/Crypto (bcrypt, jsonwebtoken, passport)
- ORM/Database (prisma, typeorm, mongoose)

#### Importantes (stabilite)
- Build tools (webpack, vite, esbuild)
- Testing (jest, vitest, cypress)
- Linting (eslint, prettier)

### 5. Red flags

- Package non maintenu (> 1 an sans commit)
- Vulnerabilites non corrigees
- Trop de dependances transitives
- Pas de tests ou documentation
- Mainteneur unique sans backup

## Patterns a rechercher

```
# Versions exactes (risque de ne pas avoir les patches)
"package": "1.2.3"

# Versions trop permissives
"package": "*"
"package": ">=1.0.0"

# Dependances de dev en prod
dependencies vs devDependencies
```

## Output attendu

### Resume

```
Audit des dependances
=====================
Total: [X] dependances
A jour: [X]
Outdated: [X]
Vulnerabilites: [X]
```

### Vulnerabilites critiques

| Package | Severite | Version actuelle | Version fixee | CVE |
|---------|----------|------------------|---------------|-----|
| lodash | High | 4.17.19 | 4.17.21 | CVE-XXX |

### Mises a jour recommandees

#### Priorite haute (securite)
- [ ] package1: 1.0.0 -> 1.0.5 (security fix)

#### Priorite moyenne (minor)
- [ ] package2: 2.1.0 -> 2.3.0 (new features)

#### Priorite basse (major - planifier)
- [ ] package3: 3.0.0 -> 4.0.0 (breaking changes)

### Dependances a risque

| Package | Probleme | Recommendation |
|---------|----------|----------------|
| old-pkg | Non maintenu depuis 2 ans | Chercher alternative |

### Commandes suggeres

```bash
# Corrections de securite
npm audit fix

# Mises a jour mineures
npm update package1 package2

# Migration majeure (a planifier)
npm install package3@latest
```

## Contraintes

- Toujours verifier le changelog avant une mise a jour majeure
- Ne jamais ignorer les vulnerabilites de securite
- Tester apres chaque mise a jour
- Commiter le lockfile

## Quand cet agent est-il utilise ?

Cet agent est automatiquement delegue par Claude lorsque :
- Une tache correspond a son domaine d'expertise
- Le contexte isole est preferable
- Les outils requis correspondent a sa configuration

## Caracteristiques du modele haiku


**Haiku** est optimise pour :
- Taches rapides et simples
- Economie de tokens
- Exploration et lecture seule


---

## Voir aussi

- [Retour aux agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
