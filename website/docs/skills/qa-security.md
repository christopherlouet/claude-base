---
sidebar_position: 28
title: "qa-security"
description: "Effectuer un audit de sécurité basé sur OWASP. Utiliser quand l'utilisateur veut vérifier la sécurité, chercher des vulnérabilités, ou avant un déploiement en production."
tags:
  - "skill"
  - "fork"
---

# Skill: qa-security

<span className="badge" style={{backgroundColor: 'var(--model-haiku)', color: 'white'}}>Fork</span>

> Effectuer un audit de sécurité basé sur OWASP. Utiliser quand l'utilisateur veut vérifier la sécurité, chercher des vulnérabilités, ou avant un déploiement en production.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Contexte** | fork |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Bash` |
| **Mots-cles** | `security`, `**/*`, `password\s*=`, `*.ts`, `api_key\s*=` |

## Description detaillee

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

## Declenchement automatique

Ce skill est automatiquement active lorsque :
- Les mots-cles correspondants sont detectes dans la conversation
- Le contexte de la tache correspond au domaine du skill

### Exemples de declenchement

- _"Je veux security..."_
- _"Je veux **/*..."_
- _"Je veux password\s*=..."_

## Contexte fork


**Fork** signifie que le skill s'execute dans un contexte isole :
- Ne pollue pas la conversation principale
- Les resultats sont retournes proprement
- Ideal pour les taches autonomes


---

## Exemples pratiques


### 1. Exemple d'audit de sécurité

# Exemple d'audit de sécurité

## Contexte
Audit de sécurité d'une application Node.js/Express avant mise en production.

## Scan automatisé

### npm audit
```bash
$ npm audit

found 3 vulnerabilities (1 moderate, 2 high)

┌───────────────┬──────────────────────────────────────────────────────┐
│ High          │ Prototype Pollution in lodash                        │
├───────────────┼──────────────────────────────────────────────────────┤
│ Package       │ lodash                                               │
│ Patched in    │ >=4.17.21                                           │
│ Path          │ lodash                                               │
└───────────────┴──────────────────────────────────────────────────────┘
```

### Recherche de secrets
```bash
$ npx secretlint "**/*"

src/config/database.ts:5
  5:1  error  Found AWS Access Key ID pattern  secretlint/aws

src/services/payment.ts:12
  12:1  error  Found Stripe Secret Key pattern  secretlint/stripe

✖ 2 problems (2 errors, 0 warnings)
```

## Analyse manuelle

### A01 - Broken Access Control

**[CRITICAL] `src/routes/users.ts:34`**
```typescript
// ❌ IDOR - Accès direct sans vérification
router.get('/users/:id', async (req, res) => {
  const user = await User.findById(req.params.id);
  res.json(user); // N'importe qui peut accéder à n'importe quel user
});

// ✅ Correction
router.get('/users/:id', authenticate, async (req, res) => {
  if (req.user.id !== req.params.id && !req.user.isAdmin) {
    return res.status(403).json({ error: 'Forbidden' });
  }
  const user = await User.findById(req.params.id);
  res.json(user);
});
```

### A02 - Cryptographic Failures

**[CRITICAL] `src/config/database.ts:5`**
```typescript
// ❌ Secret hardcodé
const DB_PASSWORD = "SuperSecret123!";

// ✅ Correction
const DB_PASSWORD = process.env.DB_PASSWORD;
```

### A03 - Injection

**[CRITICAL] `src/services/search.ts:23`**
```typescript
// ❌ SQL Injection
const query = `SELECT * FROM products WHERE name LIKE '%${searchTerm}%'`;

// ✅ Correction
const query = 'SELECT * FROM products WHERE name LIKE ?';
db.query(query, [`%${searchTerm}%`]);
```

**[HIGH] `src/components/Comment.tsx:15`**
```typescript
// ❌ XSS via dangerouslySetInnerHTML
<div dangerouslySetInnerHTML={{ __html: comment.content }} />

// ✅ Correction
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(comment.content) }} />
```

### A05 - Security Misconfiguration

**[MEDIUM] Headers de sécurité manquants**
```typescript
// ❌ Pas de headers de sécurité
app.use(express.json());

// ✅ Correction
import helmet from 'helmet';
app.use(helmet());
```

### A07 - Authentication Failures

**[HIGH] `src/services/auth.ts:45`**
```typescript
// ❌ Hash MD5 (obsolète)
const hash = crypto.createHash('md5').update(password).digest('hex');

// ✅ Correction
import bcrypt from 'bcrypt';
const hash = await bcrypt.hash(password, 12);
```

## Rapport final

### Résumé
- **Niveau de risque global**: CRITIQUE
- **Vulnérabilités trouvées**: 8
- **Dépendances vulnérables**: 3

### Vulnérabilités par sévérité

| Sévérité | Quantité | Catégories |
|----------|----------|------------|
| Critique | 3 | A01, A02, A03 |
| Élevée | 3 | A03, A07 |
| Moyenne | 2 | A05, A06 |

### Actions immédiates (P0)

1. **Supprimer les secrets du code**
   - `src/config/database.ts:5`
   - `src/services/payment.ts:12`
   - Utiliser variables d'environnement

2. **Corriger l'injection SQL**
   - `src/services/search.ts:23`
   - Utiliser requêtes paramétrées

3. **Corriger l'IDOR**
   - `src/routes/users.ts:34`
   - Ajouter vérification d'autorisation

### Actions court terme (P1)

4. **Mettre à jour les dépendances**
   ```bash
   npm update lodash
   npm audit fix
   ```

5. **Améliorer le hashing des mots de passe**
   - Migrer de MD5 vers bcrypt

6. **Ajouter Helmet pour les headers**

### Actions moyen terme (P2)

7. **Implémenter rate limiting**
8. **Ajouter CSP strict**
9. **Audit des logs (pas de données sensibles)**

## Commandes de remediation

```bash
# Mettre à jour les dépendances vulnérables
npm update lodash
npm audit fix --force

# Installer les dépendances de sécurité
npm install helmet bcrypt dompurify

# Scanner après corrections
npm audit
npx secretlint "**/*"
```



---

## Voir aussi

- [Retour aux skills](/docs/skills)
- [Architecture](/docs/intro/architecture)
