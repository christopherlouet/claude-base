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

## Bash Hardening (CLI 2.1.113+)

Renforcements appliques directement par le CLI. A connaitre pour ecrire des rules `permissions` coherentes et eviter les contournements involontaires :

- **Paths dangereux etendus** : `/private/{etc,var,tmp,home}` (macOS) sont traites comme dangerous removal targets au meme titre que `/etc`, `/var`, etc.
- **Deny rules resistantes aux wrappers d'execution** : une regle `deny: Bash(rm -rf *)` matche aussi quand la commande est encapsulee dans `env`, `sudo`, `watch`, `ionice` ou `setsid`. Ne plus s'appuyer sur ces wrappers pour bypasser une deny rule.
- **`Bash(find:*)` n'auto-approuve plus `-exec`/`-delete`** : ces sous-commandes peuvent modifier ou supprimer des fichiers, elles declenchent desormais un prompt de permission separe meme si `find:*` est allowlisted.
- **Sandbox deniedDomains** : privilegier `sandbox.network.deniedDomains` pour exclure explicitement des domaines sensibles meme sous un wildcard `allowedDomains`.
- **UI-spoofing fix** : les commentaires multilignes dans les commandes Bash affichent desormais la commande complete pour eviter qu'un commentaire masque l'intention reelle.

A appliquer dans `.claude/settings.json` :

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
