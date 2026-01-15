# Agent OPS-ENV

Gestion des environnements (dev, staging, prod) et des variables d'environnement.

## Contexte
$ARGUMENTS

## Processus de configuration

### 1. Identifier les environnements

| Environnement | Usage | URL type |
|---------------|-------|----------|
| **development** | Dev local | localhost:3000 |
| **staging** | Tests QA, démos | staging.app.com |
| **production** | Utilisateurs finaux | app.com |

### 2. Structure des fichiers

```
project/
├── .env.example          # Template (commité)
├── .env                  # Local dev (gitignored)
├── .env.development      # Dev spécifique
├── .env.staging          # Staging
├── .env.production       # Production
└── .env.local            # Overrides locaux (gitignored)
```

### 3. Template .env.example

```bash
# .env.example - Template des variables d'environnement
# Copier en .env et remplir les valeurs

# ===================
# Application
# ===================
NODE_ENV=development
APP_NAME=MyApp
APP_URL=http://localhost:3000
PORT=3000

# ===================
# Database
# ===================
DATABASE_URL=postgresql://user:password@localhost:5432/dbname
# DATABASE_URL=mongodb://localhost:27017/dbname

# ===================
# Authentication
# ===================
JWT_SECRET=your-secret-key-min-32-chars
JWT_EXPIRES_IN=7d
SESSION_SECRET=another-secret-key

# ===================
# External Services
# ===================
# Stripe
STRIPE_PUBLIC_KEY=pk_test_xxx
STRIPE_SECRET_KEY=sk_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx

# Email (SendGrid/Resend/etc)
EMAIL_FROM=noreply@example.com
SENDGRID_API_KEY=SG.xxx

# Storage (S3/Cloudinary/etc)
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_REGION=eu-west-1
AWS_S3_BUCKET=

# ===================
# Monitoring
# ===================
SENTRY_DSN=
LOG_LEVEL=debug

# ===================
# Feature Flags
# ===================
ENABLE_FEATURE_X=false
ENABLE_ANALYTICS=true
```

### 4. Validation des variables

```typescript
// config/env.ts
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'staging', 'production']),
  APP_URL: z.string().url(),
  PORT: z.coerce.number().default(3000),

  DATABASE_URL: z.string().min(1),

  JWT_SECRET: z.string().min(32),
  JWT_EXPIRES_IN: z.string().default('7d'),

  STRIPE_PUBLIC_KEY: z.string().optional(),
  STRIPE_SECRET_KEY: z.string().optional(),

  SENTRY_DSN: z.string().optional(),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
});

export const env = envSchema.parse(process.env);
export type Env = z.infer<typeof envSchema>;
```

### 5. Configuration par environnement

#### Next.js / Vite
```typescript
// config/index.ts
const configs = {
  development: {
    apiUrl: 'http://localhost:3001',
    debug: true,
    analytics: false,
  },
  staging: {
    apiUrl: 'https://api.staging.example.com',
    debug: true,
    analytics: true,
  },
  production: {
    apiUrl: 'https://api.example.com',
    debug: false,
    analytics: true,
  },
};

export const config = configs[process.env.NODE_ENV || 'development'];
```

### 6. Secrets management

#### Options recommandées

| Solution | Cas d'usage | Coût |
|----------|-------------|------|
| **Doppler** | Startups, équipes | Gratuit → payant |
| **Vault** | Enterprise, self-hosted | Gratuit (OSS) |
| **AWS Secrets Manager** | AWS natif | ~$0.40/secret/mois |
| **Vercel/Netlify** | Déploiement Jamstack | Inclus |
| **GitHub Secrets** | CI/CD | Gratuit |

#### Exemple avec Doppler
```bash
# Installation
brew install dopplerhq/cli/doppler

# Configuration
doppler setup

# Lancement avec injection
doppler run -- npm run dev
```

### 7. CI/CD Variables

#### GitHub Actions
```yaml
# .github/workflows/deploy.yml
env:
  NODE_ENV: production

jobs:
  deploy:
    environment: production  # Utilise les secrets de l'env "production"
    steps:
      - name: Deploy
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          STRIPE_SECRET_KEY: ${{ secrets.STRIPE_SECRET_KEY }}
        run: npm run deploy
```

#### GitLab CI
```yaml
# .gitlab-ci.yml
variables:
  NODE_ENV: production

deploy:
  environment:
    name: production
  script:
    - npm run deploy
  only:
    - main
```

### 8. Checklist sécurité

- [ ] `.env` dans `.gitignore`
- [ ] `.env.local` dans `.gitignore`
- [ ] Pas de secrets dans le code
- [ ] Secrets différents par environnement
- [ ] Rotation des secrets planifiée
- [ ] Accès aux secrets restreint
- [ ] Audit des accès

### 9. Différences par environnement

| Variable | Dev | Staging | Prod |
|----------|-----|---------|------|
| NODE_ENV | development | staging | production |
| LOG_LEVEL | debug | debug | warn |
| DEBUG | true | true | false |
| ANALYTICS | false | true | true |
| API_URL | localhost | staging.api | api |
| DB | local | staging-db | prod-db |

## Output attendu

### Fichiers générés

1. `.env.example` - Template documenté
2. `.env.development` - Config dev
3. `.env.staging` - Config staging
4. `.env.production` - Config prod
5. `config/env.ts` - Validation Zod

### Documentation

```markdown
## Variables d'environnement

### Configuration locale
1. Copier `.env.example` en `.env`
2. Remplir les valeurs

### Variables requises
| Variable | Description | Exemple |
|----------|-------------|---------|
| DATABASE_URL | URL de connexion DB | postgresql://... |
| JWT_SECRET | Clé JWT (min 32 chars) | xxx |

### Variables optionnelles
| Variable | Description | Default |
|----------|-------------|---------|
| LOG_LEVEL | Niveau de log | info |
```

### Checklist
- [ ] .env.example créé et documenté
- [ ] .env dans .gitignore
- [ ] Validation avec Zod
- [ ] Secrets différents par env
- [ ] CI/CD configuré

---

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/secrets-management` | Gestion sécurisée des secrets |
| `/docker` | Configuration Docker |
| `/infra-code` | Variables Terraform |
| `/ci` | Secrets en CI/CD |
| `/security` | Audit des secrets |

---

IMPORTANT: Ne JAMAIS commiter de fichiers .env contenant des secrets réels.

YOU MUST utiliser des secrets différents pour chaque environnement.

NEVER hardcoder des valeurs sensibles dans le code.

Think hard sur quelles variables sont vraiment nécessaires.
