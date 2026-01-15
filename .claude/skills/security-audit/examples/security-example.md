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
