# Agent SECURITY

Audit de sécurité basé sur OWASP Top 10.

## Cible de l'audit
$ARGUMENTS

## Checklist OWASP Top 10

### A01 - Broken Access Control
- [ ] Vérification des autorisations sur chaque endpoint
- [ ] Principe du moindre privilège appliqué
- [ ] Pas d'accès direct aux objets via ID prévisibles (IDOR)
- [ ] CORS correctement configuré

### A02 - Cryptographic Failures
- [ ] Données sensibles chiffrées au repos et en transit
- [ ] Pas de secrets hardcodés dans le code
- [ ] Algorithmes de hash sécurisés (bcrypt, argon2)
- [ ] TLS/HTTPS forcé

### A03 - Injection
- [ ] SQL: Requêtes paramétrées / ORM
- [ ] NoSQL: Validation des entrées
- [ ] Command injection: Pas de shell avec input utilisateur
- [ ] XSS: Échappement des outputs HTML

### A04 - Insecure Design
- [ ] Validation côté serveur (pas seulement client)
- [ ] Rate limiting sur les endpoints sensibles
- [ ] Séparation des environnements (dev/prod)

### A05 - Security Misconfiguration
- [ ] Headers de sécurité (CSP, X-Frame-Options, etc.)
- [ ] Pas de stack traces en production
- [ ] Dépendances à jour
- [ ] Permissions fichiers correctes

### A06 - Vulnerable Components
- [ ] `npm audit` sans vulnérabilités critiques
- [ ] Dépendances maintenues et à jour
- [ ] Pas de packages abandonnés

### A07 - Authentication Failures
- [ ] Mots de passe hashés correctement
- [ ] Protection contre brute force
- [ ] Sessions sécurisées (httpOnly, secure, sameSite)
- [ ] Logout invalide les tokens

### A08 - Data Integrity Failures
- [ ] Validation des données entrantes
- [ ] Intégrité des mises à jour (CI/CD sécurisé)
- [ ] Désérialisation sécurisée

### A09 - Logging Failures
- [ ] Logs des événements de sécurité
- [ ] Pas de données sensibles dans les logs
- [ ] Alertes sur activités suspectes

### A10 - SSRF
- [ ] Validation des URLs fournies par l'utilisateur
- [ ] Whitelist des domaines autorisés
- [ ] Pas de requêtes vers réseau interne

## Outils d'analyse automatisée

```bash
# Audit des dépendances npm
npm audit
npm audit --audit-level=moderate

# Audit avec Snyk (plus complet)
npx snyk test
npx snyk monitor

# Recherche de secrets dans le code
npx secretlint "**/*"

# Analyse statique de sécurité
npx eslint --plugin security src/

# Scan des conteneurs Docker
docker scan myimage:latest
```

## Headers de sécurité HTTP

```typescript
// Headers recommandés (Express.js)
const helmet = require('helmet');
app.use(helmet());

// Configuration manuelle
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
  res.setHeader('Content-Security-Policy', "default-src 'self'");
  next();
});
```

## Exemples de vulnérabilités courantes

### SQL Injection (A03)
```typescript
// ❌ VULNÉRABLE
const query = `SELECT * FROM users WHERE id = ${userId}`;

// ✅ SÉCURISÉ
const query = 'SELECT * FROM users WHERE id = ?';
db.query(query, [userId]);
```

### XSS (A03)
```typescript
// ❌ VULNÉRABLE
element.innerHTML = userInput;

// ✅ SÉCURISÉ
element.textContent = userInput;
// ou avec sanitization
element.innerHTML = DOMPurify.sanitize(userInput);
```

### Secrets exposés (A02)
```typescript
// ❌ VULNÉRABLE
const API_KEY = "sk-1234567890abcdef";

// ✅ SÉCURISÉ
const API_KEY = process.env.API_KEY;
```

## Output attendu

### Résumé
- **Niveau de risque global**: [Critique/Élevé/Moyen/Faible]
- **Vulnérabilités trouvées**: [nombre]

### Vulnérabilités détaillées
| Sévérité | Catégorie | Fichier:Ligne | Description | Remediation |
|----------|-----------|---------------|-------------|-------------|
| CRITIQUE | A03       | auth.ts:45    | SQL injection | Utiliser requête paramétrée |

### Recommandations prioritaires
1. [Action immédiate]
2. [Action court terme]
3. [Action moyen terme]

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/audit` | Audit complet (inclut sécu) |
| `/rgpd` | Conformité données personnelles |
| `/deps` | Vérifier les vulnérabilités deps |
| `/secrets` | Gestion sécurisée des secrets |

---

IMPORTANT: La sécurité n'est pas optionnelle - traiter les vulnérabilités critiques immédiatement.

YOU MUST vérifier les 10 catégories OWASP sans exception.

NEVER exposer de secrets, tokens ou credentials dans le code.

Think hard sur chaque vecteur d'attaque. Sois exhaustif.
