---
name: qa-security
description: Effectuer un audit de sécurité basé sur OWASP. Utiliser quand l'utilisateur veut vérifier la sécurité, chercher des vulnérabilités, ou avant un déploiement en production.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
context: fork
---

# Audit de Sécurité

## Objectif

Identifier les vulnérabilités de sécurité basées sur OWASP Top 10.

## Instructions

### 1. Scan automatisé

```bash
# Audit des dépendances npm
npm audit --audit-level=moderate

# Recherche de secrets
npx secretlint "**/*"

# Analyse statique sécurité
npx eslint --plugin security src/
```

### 2. Checklist OWASP Top 10

#### A01 - Broken Access Control
- [ ] Vérification des autorisations sur chaque endpoint
- [ ] Pas d'IDOR (accès direct via ID prévisibles)
- [ ] CORS correctement configuré
- [ ] Principe du moindre privilège

#### A02 - Cryptographic Failures
- [ ] Données sensibles chiffrées (repos + transit)
- [ ] Pas de secrets dans le code
- [ ] Algorithmes de hash sécurisés (bcrypt, argon2)
- [ ] TLS/HTTPS forcé

#### A03 - Injection
- [ ] SQL: Requêtes paramétrées / ORM
- [ ] XSS: Échappement des outputs HTML
- [ ] Command injection: Pas de shell avec input user
- [ ] NoSQL: Validation des requêtes

#### A04 - Insecure Design
- [ ] Validation côté serveur (pas seulement client)
- [ ] Rate limiting sur endpoints sensibles
- [ ] Séparation des environnements

#### A05 - Security Misconfiguration
- [ ] Headers de sécurité (CSP, X-Frame-Options)
- [ ] Pas de stack traces en production
- [ ] Permissions fichiers correctes

#### A06 - Vulnerable Components
- [ ] `npm audit` sans vulnérabilités critiques
- [ ] Dépendances maintenues et à jour

#### A07 - Authentication Failures
- [ ] Mots de passe hashés correctement
- [ ] Protection contre brute force
- [ ] Sessions sécurisées (httpOnly, secure, sameSite)

#### A08 - Data Integrity Failures
- [ ] Validation des données entrantes
- [ ] Désérialisation sécurisée

#### A09 - Logging Failures
- [ ] Logs des événements de sécurité
- [ ] Pas de données sensibles dans les logs

#### A10 - SSRF
- [ ] Validation des URLs utilisateur
- [ ] Whitelist des domaines autorisés

### 3. Patterns de recherche

```bash
# Secrets potentiels
grep -rn "password\s*=" --include="*.ts"
grep -rn "api_key\s*=" --include="*.ts"
grep -rn "secret\s*=" --include="*.ts"

# SQL Injection potentielle
grep -rn "query.*\$\{" --include="*.ts"
grep -rn "execute.*\+" --include="*.ts"

# XSS potentiel
grep -rn "innerHTML" --include="*.tsx"
grep -rn "dangerouslySetInnerHTML" --include="*.tsx"

# Eval dangereux
grep -rn "eval(" --include="*.ts"
grep -rn "new Function(" --include="*.ts"
```

### 4. Headers de sécurité recommandés

```typescript
// Express avec Helmet
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
    }
  },
  hsts: { maxAge: 31536000, includeSubDomains: true }
}));
```

## Output attendu

```markdown
## Rapport de Sécurité

### Résumé
- **Niveau de risque global**: [Critique/Élevé/Moyen/Faible]
- **Vulnérabilités trouvées**: X
- **Dépendances vulnérables**: Y

### Vulnérabilités critiques
| Sévérité | Catégorie | Fichier:Ligne | Description | Remediation |
|----------|-----------|---------------|-------------|-------------|
| CRITIQUE | A03 | auth.ts:45 | SQL injection | Requête paramétrée |

### Vulnérabilités importantes
[...]

### Recommandations prioritaires
1. [Action immédiate]
2. [Court terme]
3. [Moyen terme]

### Dépendances à mettre à jour
| Package | Version | Vulnérabilité | Sévérité |
|---------|---------|---------------|----------|
| lodash | 4.17.19 | Prototype pollution | High |
```

## Règles

- IMPORTANT: Vérifier les 10 catégories OWASP
- IMPORTANT: Prioriser par sévérité
- YOU MUST proposer des remédiations concrètes
- NEVER ignorer les vulnérabilités critiques

Think hard sur chaque vecteur d'attaque potentiel.
