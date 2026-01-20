---
sidebar_position: 6
title: "05 - Audit de sécurité"
description: Réalisez un audit de sécurité OWASP complet et corrigez les vulnérabilités
---

import DifficultyBadge from '@site/src/components/DifficultyBadge';

# Audit de sécurité OWASP

<DifficultyBadge level="intermediate" /> **Durée estimée : 30 minutes**

Ce tutoriel vous montre comment réaliser un audit de sécurité complet basé sur l'OWASP Top 10 et corriger les vulnérabilités détectées.

## Objectifs

À la fin de ce tutoriel, vous saurez :
- Utiliser `/qa-security` pour un audit OWASP
- Identifier les vulnérabilités courantes
- Corriger les problèmes de sécurité
- Mettre en place des bonnes pratiques

## Prérequis

- Un projet web existant (Node.js, Python, ou autre)
- Connaissances de base en sécurité web

## L'OWASP Top 10

L'OWASP Top 10 liste les vulnérabilités web les plus critiques :

| # | Vulnérabilité | Description |
|---|---------------|-------------|
| A01 | Broken Access Control | Contrôle d'accès défaillant |
| A02 | Cryptographic Failures | Failles cryptographiques |
| A03 | Injection | SQL, XSS, Command injection |
| A04 | Insecure Design | Conception non sécurisée |
| A05 | Security Misconfiguration | Mauvaise configuration |
| A06 | Vulnerable Components | Dépendances vulnérables |
| A07 | Auth Failures | Authentification défaillante |
| A08 | Data Integrity Failures | Intégrité des données |
| A09 | Logging Failures | Logging insuffisant |
| A10 | SSRF | Server-Side Request Forgery |

## Étape 1 : Lancer l'audit

```bash
/qa-security
```

Claude va analyser votre projet et produire un rapport détaillé.

## Étape 2 : Analyser le rapport

**Exemple de rapport :**

```markdown
## Audit de Sécurité OWASP

### 🔴 Critiques (2)

#### A03 - SQL Injection
**Fichier**: `src/routes/users.ts:45`
**Code vulnérable**:
```typescript
const user = await db.query(`SELECT * FROM users WHERE id = '${req.params.id}'`);
```
**Risque**: Un attaquant peut injecter du SQL malveillant
**Fix**: Utiliser des requêtes paramétrées

#### A03 - XSS (Cross-Site Scripting)
**Fichier**: `src/views/profile.ejs:12`
**Code vulnérable**:
```html
<h1>Bienvenue <%- user.name %></h1>
```
**Risque**: Injection de scripts malveillants
**Fix**: Utiliser `<%= %>` pour échapper le HTML

### 🟠 Élevés (3)

#### A06 - Dépendances vulnérables
**Détail**: 3 dépendances avec des CVE connues
- lodash@4.17.15 → CVE-2021-23337 (Prototype Pollution)
- axios@0.21.0 → CVE-2021-3749 (ReDoS)
- express@4.17.0 → Mise à jour recommandée

#### A02 - Secrets en clair
**Fichier**: `.env.example`
**Problème**: Clés API visibles dans le repo
**Fix**: Utiliser `.env.example` sans valeurs réelles

### 🟡 Moyens (2)

#### A05 - Headers de sécurité manquants
**Manquants**:
- X-Content-Type-Options
- X-Frame-Options
- Content-Security-Policy

#### A09 - Logging insuffisant
**Problème**: Les tentatives de connexion échouées ne sont pas loguées
```

## Étape 3 : Corriger les vulnérabilités critiques

### Fix SQL Injection

**Avant (vulnérable):**
```typescript
const user = await db.query(`SELECT * FROM users WHERE id = '${req.params.id}'`);
```

**Après (sécurisé):**
```typescript
const user = await db.query('SELECT * FROM users WHERE id = $1', [req.params.id]);
```

Ou avec un ORM (Prisma) :
```typescript
const user = await prisma.user.findUnique({
  where: { id: req.params.id }
});
```

### Fix XSS

**Avant (vulnérable):**
```html
<h1>Bienvenue <%- user.name %></h1>
```

**Après (sécurisé):**
```html
<h1>Bienvenue <%= user.name %></h1>
```

En React (automatiquement sécurisé) :
```tsx
<h1>Bienvenue {user.name}</h1>
```

:::warning dangerouslySetInnerHTML
En React, n'utilisez **jamais** `dangerouslySetInnerHTML` avec des données utilisateur sans les sanitizer avec DOMPurify.
:::

## Étape 4 : Mettre à jour les dépendances

```bash
/ops-deps
```

Claude va :
1. Identifier les dépendances vulnérables
2. Proposer les mises à jour
3. Vérifier la compatibilité

```bash
# Mise à jour automatique des patches de sécurité
npm audit fix

# Voir les vulnérabilités restantes
npm audit
```

## Étape 5 : Ajouter les headers de sécurité

Utilisez **helmet** pour Express :

```bash
npm install helmet
```

```typescript
import helmet from 'helmet';

app.use(helmet());

// Configuration personnalisée
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
  crossOriginEmbedderPolicy: false,
}));
```

## Étape 6 : Améliorer le logging

Ajoutez le logging des événements de sécurité :

```typescript
import winston from 'winston';

const securityLogger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'security.log' }),
  ],
});

// Logger les tentatives de connexion
app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await authenticate(email, password);

    securityLogger.info('Login success', {
      userId: user.id,
      ip: req.ip,
      userAgent: req.get('User-Agent'),
    });

    res.json({ token: generateToken(user) });
  } catch (error) {
    securityLogger.warn('Login failed', {
      email,
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      reason: error.message,
    });

    res.status(401).json({ error: 'Invalid credentials' });
  }
});
```

## Étape 7 : Vérifier les corrections

Relancez l'audit :

```bash
/qa-security
```

Le rapport devrait maintenant montrer :

```markdown
## Audit de Sécurité OWASP

### ✅ Résumé
- Critiques: 0 (↓ de 2)
- Élevés: 1 (↓ de 3)
- Moyens: 0 (↓ de 2)

### 🟠 Élevés (1)

#### A06 - Dépendance vulnérable restante
**Détail**: axios@0.21.0 nécessite une mise à jour manuelle
**Action**: `npm install axios@latest`
```

## Étape 8 : Commiter

```bash
/work-commit
```

**Message suggéré :**

```
fix(security): address OWASP vulnerabilities

- Fix SQL injection with parameterized queries
- Fix XSS by escaping user input
- Update vulnerable dependencies
- Add security headers with helmet
- Add security event logging
```

## Checklist de sécurité

Utilisez cette checklist pour vos projets :

### Entrées utilisateur
- [ ] Toutes les entrées sont validées
- [ ] Requêtes SQL paramétrées
- [ ] HTML échappé dans les vues
- [ ] Fichiers uploadés validés (type, taille)

### Authentification
- [ ] Mots de passe hashés (bcrypt, argon2)
- [ ] Tokens JWT avec expiration courte
- [ ] Rate limiting sur login
- [ ] Logout invalide le token

### Configuration
- [ ] Variables d'environnement pour les secrets
- [ ] HTTPS activé en production
- [ ] Headers de sécurité configurés
- [ ] CORS configuré strictement

### Dépendances
- [ ] `npm audit` sans vulnérabilités critiques
- [ ] Dépendances à jour
- [ ] Lockfile committé

### Logging
- [ ] Événements de sécurité loggés
- [ ] Pas de données sensibles dans les logs
- [ ] Logs centralisés en production

## Prochaines étapes

- [Tutoriel 06 : Pipeline CI/CD](/docs/tutorials/cicd-github) - Automatiser les audits
- [Guide API](/docs/guides/api-development) - Sécurité des APIs
- [Commande /qa-audit](/docs/commands/qa/qa-audit) - Audit complet

---

:::tip Automatisation
Ajoutez `/qa-security` dans votre pipeline CI/CD pour détecter les vulnérabilités avant le déploiement.
:::
