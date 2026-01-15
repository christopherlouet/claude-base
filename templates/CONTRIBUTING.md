# Contributing to [Project Name]

Merci de votre intérêt pour contribuer à ce projet !

## Table des matières

- [Code de conduite](#code-de-conduite)
- [Workflow de contribution](#workflow-de-contribution)
- [Configuration de l'environnement](#configuration-de-lenvironnement)
- [Standards de code](#standards-de-code)
- [Process de Pull Request](#process-de-pull-request)
- [Signaler un bug](#signaler-un-bug)
- [Proposer une fonctionnalité](#proposer-une-fonctionnalité)

## Code de conduite

En participant à ce projet, vous acceptez de respecter notre code de conduite :

- **Respect** : Traitez tous les participants avec respect
- **Constructif** : Les critiques doivent être constructives
- **Inclusif** : Accueillez les contributeurs de tous horizons
- **Professionnel** : Maintenez un environnement professionnel

## Workflow de contribution

```
┌─────────────────────────────────────────────────────────────┐
│                    CONTRIBUTION WORKFLOW                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Fork          → Créer votre copie du repo              │
│  2. Branch        → Créer une branche pour votre travail   │
│  3. Code          → Implémenter vos changements            │
│  4. Test          → S'assurer que tous les tests passent   │
│  5. Commit        → Commits atomiques et bien formatés     │
│  6. Push          → Pousser vers votre fork                │
│  7. PR            → Ouvrir une Pull Request                │
│  8. Review        → Répondre aux commentaires              │
│  9. Merge         → Célébrer ! 🎉                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 1. Fork et Clone

```bash
# Fork via GitHub, puis clone
git clone https://github.com/YOUR_USERNAME/PROJECT_NAME.git
cd PROJECT_NAME

# Ajouter le repo original comme remote
git remote add upstream https://github.com/ORIGINAL_OWNER/PROJECT_NAME.git
```

### 2. Créer une branche

```bash
# Synchroniser avec upstream
git fetch upstream
git checkout main
git merge upstream/main

# Créer votre branche
git checkout -b feature/ma-fonctionnalite
# ou
git checkout -b fix/mon-bugfix
```

### Conventions de nommage des branches

| Préfixe | Usage | Exemple |
|---------|-------|---------|
| `feature/` | Nouvelle fonctionnalité | `feature/user-authentication` |
| `fix/` | Correction de bug | `fix/login-redirect` |
| `refactor/` | Refactoring | `refactor/user-service` |
| `docs/` | Documentation | `docs/api-guide` |
| `test/` | Ajout de tests | `test/user-validation` |

## Configuration de l'environnement

### Prérequis

- Node.js >= 18
- npm >= 9
- Git >= 2.30

### Installation

```bash
# Installer les dépendances
npm install

# Copier la configuration
cp .env.example .env

# Vérifier l'installation
npm run check
```

### Scripts disponibles

| Script | Description |
|--------|-------------|
| `npm run dev` | Serveur de développement |
| `npm test` | Lancer les tests |
| `npm run lint` | Vérifier le style de code |
| `npm run lint:fix` | Corriger automatiquement le style |
| `npm run typecheck` | Vérifier les types TypeScript |
| `npm run build` | Build de production |

## Standards de code

### TypeScript

- Mode strict activé (`"strict": true`)
- Pas de `any` sauf cas exceptionnels documentés
- Interfaces pour les objets complexes
- Types explicites pour les fonctions publiques

```typescript
// ✅ Bon
interface UserData {
  id: string;
  name: string;
  email: string;
}

function createUser(data: UserData): Promise<User> {
  // ...
}

// ❌ Mauvais
function createUser(data: any): any {
  // ...
}
```

### Conventions de nommage

| Type | Convention | Exemple |
|------|------------|---------|
| Variables/Fonctions | camelCase | `getUserById` |
| Classes/Interfaces | PascalCase | `UserService` |
| Constantes | SCREAMING_SNAKE | `MAX_RETRY_COUNT` |
| Fichiers composants | PascalCase | `UserCard.tsx` |
| Fichiers autres | kebab-case | `user-service.ts` |

### Structure des fichiers

```
src/
├── components/       # Composants UI
├── services/         # Logique métier
├── hooks/            # Custom hooks
├── utils/            # Fonctions utilitaires
├── types/            # Types et interfaces
└── tests/            # Tests
```

## Process de Pull Request

### Avant de créer une PR

- [ ] Le code compile sans erreur (`npm run build`)
- [ ] Les tests passent (`npm test`)
- [ ] Le linting passe (`npm run lint`)
- [ ] Les types sont valides (`npm run typecheck`)
- [ ] La couverture de code est maintenue (> 80%)

### Format du message de commit

Nous utilisons [Conventional Commits](https://www.conventionalcommits.org/) :

```
type(scope): description courte

[corps optionnel]

[footer optionnel]
```

#### Types de commit

| Type | Description |
|------|-------------|
| `feat` | Nouvelle fonctionnalité |
| `fix` | Correction de bug |
| `docs` | Documentation |
| `style` | Formatage (pas de changement fonctionnel) |
| `refactor` | Refactoring |
| `test` | Ajout ou modification de tests |
| `chore` | Maintenance |
| `perf` | Amélioration de performance |

#### Exemples

```bash
feat(auth): add password reset functionality

fix(api): handle null response in user endpoint

docs(readme): update installation instructions

refactor(user-service): extract validation logic
```

### Template de PR

```markdown
## Description

[Décrivez vos changements]

## Type de changement

- [ ] Bug fix
- [ ] Nouvelle fonctionnalité
- [ ] Breaking change
- [ ] Documentation

## Comment tester

1. [Étape 1]
2. [Étape 2]
3. [Résultat attendu]

## Checklist

- [ ] J'ai lu le guide de contribution
- [ ] J'ai ajouté des tests
- [ ] J'ai mis à jour la documentation
- [ ] Les tests passent localement
```

### Process de review

1. **Automated checks** : CI doit passer
2. **Review** : Au moins 1 approbation requise
3. **Feedback** : Répondez aux commentaires
4. **Merge** : Squash and merge vers main

## Signaler un bug

### Avant de signaler

1. Vérifiez que le bug n'est pas déjà signalé
2. Testez avec la dernière version
3. Isolez le problème

### Template d'issue bug

```markdown
## Description du bug

[Description claire du problème]

## Reproduction

1. Aller à '...'
2. Cliquer sur '...'
3. Voir l'erreur

## Comportement attendu

[Ce qui devrait se passer]

## Screenshots

[Si applicable]

## Environnement

- OS: [e.g. macOS 14.0]
- Browser: [e.g. Chrome 120]
- Version: [e.g. 1.2.3]
```

## Proposer une fonctionnalité

### Template d'issue feature

```markdown
## Problème

[Quel problème cette fonctionnalité résout-elle ?]

## Solution proposée

[Décrivez la solution que vous envisagez]

## Alternatives considérées

[Autres approches envisagées]

## Contexte additionnel

[Tout autre contexte utile]
```

## Questions ?

- Ouvrez une [Discussion GitHub](../../discussions)
- Consultez la [Documentation](./docs/)
- Rejoignez notre [Discord/Slack] (si applicable)

---

Merci pour vos contributions ! 🙏
