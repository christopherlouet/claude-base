---
sidebar_position: 22
title: "security"
description: "3 vecteurs d'attaque identifies (fev. 2026) lors du clonage de depots non-fiables:"
tags:
  - "rule"
  - "security"
---

# Regles: security

> 3 vecteurs d'attaque identifies (fev. 2026) lors du clonage de depots non-fiables:

## Fichiers concernes

Ces regles s'appliquent aux fichiers correspondant aux patterns suivants :

- `**/auth/**`
- `**/api/**`
- `**/routes/**`
- `**/controllers/**`
- `**/middleware/**`
- `**/services/**`

## Regles detaillees

# Security Rules

## Input Validation

- IMPORTANT: Valider TOUTES les entrees utilisateur
- Utiliser des schemas de validation (Zod, Joi, class-validator)
- Rejeter les donnees invalides le plus tot possible
- Sanitizer les entrees avant traitement

## Output Encoding

- IMPORTANT: Echapper les outputs HTML (prevention XSS)
- Utiliser les fonctions d'echappement natives du framework
- Ne jamais inserer de HTML non-sanitise dans le DOM
- Eviter `innerHTML` et `dangerouslySetInnerHTML`

## Database Security

- IMPORTANT: Utiliser des requetes parametrees (prevention SQL injection)
- Preferer les ORM avec requetes preparees
- Ne jamais concatener des entrees utilisateur dans les requetes
- Limiter les privileges des comptes de base de donnees

## Secrets Management

- NEVER commiter de secrets (.env, credentials, API keys)
- Utiliser des variables d'environnement
- Rotater regulierement les secrets
- Utiliser un gestionnaire de secrets en production

## Logging

- Ne jamais logger de donnees sensibles (mots de passe, tokens, PII)
- Masquer les informations sensibles dans les logs
- Logger les evenements de securite (auth, acces)

## Dependencies

- Executer `npm audit` regulierement
- Mettre a jour les dependances avec vulnerabilites critiques
- Verifier les dependances avant installation
- Utiliser des lockfiles (package-lock.json)

## Authentication

- Hasher les mots de passe avec bcrypt ou argon2
- Implementer une protection contre brute force
- Utiliser des sessions securisees (httpOnly, secure, sameSite)
- Implementer une expiration des tokens

## Claude Code Security (depots tiers)

3 vecteurs d'attaque identifies (fev. 2026) lors du clonage de depots non-fiables:

- **Hooks malveillants**: un `.claude/settings.json` du depot peut contenir des hooks executant des commandes arbitraires
- **MCP non-fiables**: un `.mcp.json` peut configurer des serveurs MCP exfiltrant des donnees
- **Variables d'environnement**: des hooks peuvent lire et transmettre le contenu de `.env` ou des secrets systeme

Bonnes pratiques:
- Verifier le contenu de `.claude/settings.json` et `.mcp.json` avant d'ouvrir un depot tiers avec Claude Code
- Garder les serveurs MCP desactives par defaut
- S'assurer que `.env` est dans `.gitignore`
- Le socle inclut des hooks SessionStart de verification automatique

## Application automatique

Ces regles sont automatiquement appliquees par Claude lors de :
- La lecture des fichiers correspondants
- La modification du code
- Les suggestions et corrections

---

## Voir aussi

- [Retour aux regles](/docs/rules)
- [Architecture](/docs/intro/architecture)
