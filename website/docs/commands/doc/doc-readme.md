---
sidebar_position: 10
title: "/doc:doc-readme"
description: "Génère ou améliore le README d'un projet pour maximiser son adoption et sa compréhension."
tags:
  - "doc"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--doc">DOC</span>


# Agent README

Génère ou améliore le README d'un projet pour maximiser son adoption et sa compréhension.

## Projet
`&lt;arguments&gt;`

## Objectif

Créer un README professionnel et complet qui permet aux nouveaux utilisateurs
de comprendre, installer et utiliser le projet rapidement.

## Structure du README

```
┌─────────────────────────────────────────────────────────────┐
│                    README STRUCTURE                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. HEADER        → Nom, badges, description courte        │
│  ══════════                                                 │
│                                                             │
│  2. PRÉSENTATION  → Ce que fait le projet                  │
│  ══════════════                                             │
│                                                             │
│  3. QUICK START   → Installation rapide                    │
│  ═════════════                                              │
│                                                             │
│  4. UTILISATION   → Exemples et documentation              │
│  ═════════════                                              │
│                                                             │
│  5. API/CONFIG    → Référence détaillée                    │
│  ═══════════                                                │
│                                                             │
│  6. CONTRIBUTION  → Comment contribuer                     │
│  ══════════════                                             │
│                                                             │
│  7. LICENCE       → Informations légales                   │
│  ══════════                                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Template README complet

### Header

```markdown
# 📦 Nom du Projet

[![npm version](https://badge.fury.io/js/package-name.svg)](https://www.npmjs.com/package/package-name)
[![Build Status](https://github.com/org/repo/workflows/CI/badge.svg)](https://github.com/org/repo/actions)
[![Coverage](https://codecov.io/gh/org/repo/branch/main/graph/badge.svg)](https://codecov.io/gh/org/repo)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Une phrase qui décrit ce que fait le projet et pourquoi c'est utile.**

[Documentation](https://docs.example.com) • [Demo](https://demo.example.com) • [Report Bug](https://github.com/org/repo/issues)

---
```

### Table des matières

```markdown
## 📑 Table des matières

- [Fonctionnalités](#-fonctionnalités)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Utilisation](#-utilisation)
- [Configuration](#️-configuration)
- [API Reference](#-api-reference)
- [Exemples](#-exemples)
- [FAQ](#-faq)
- [Contribution](#-contribution)
- [Licence](#-licence)
```

### Fonctionnalités

```markdown
## ✨ Fonctionnalités

- 🚀 **Fonctionnalité 1** - Description courte du bénéfice
- 🔒 **Fonctionnalité 2** - Description courte du bénéfice
- ⚡ **Fonctionnalité 3** - Description courte du bénéfice
- 🎨 **Fonctionnalité 4** - Description courte du bénéfice

### Pourquoi ce projet ?

[Contexte du problème que le projet résout et pourquoi les solutions
existantes ne sont pas satisfaisantes]

### Comparaison

| Fonctionnalité | Ce projet | Alternative A | Alternative B |
|----------------|-----------|---------------|---------------|
| Feature 1 | ✅ | ❌ | ✅ |
| Feature 2 | ✅ | ✅ | ❌ |
| Feature 3 | ✅ | ❌ | ❌ |
```

### Installation

```markdown
## 📥 Installation

### Prérequis

- Node.js >= 18.0.0
- npm >= 9.0.0 (ou yarn >= 1.22, pnpm >= 8.0)

### Via npm

\`\`\`bash
npm install package-name
\`\`\`

### Via yarn

\`\`\`bash
yarn add package-name
\`\`\`

### Via pnpm

\`\`\`bash
pnpm add package-name
\`\`\`

### Installation globale (CLI)

\`\`\`bash
npm install -g package-name
\`\`\`

### Depuis les sources

\`\`\`bash
git clone https://github.com/org/repo.git
cd repo
npm install
npm run build
\`\`\`
```

### Quick Start

```markdown
## 🚀 Quick Start

### 1. Installation

\`\`\`bash
npm install package-name
\`\`\`

### 2. Utilisation basique

\`\`\`typescript
import { MainFeature } from 'package-name';

// Exemple minimal qui fonctionne
const result = MainFeature.doSomething({
  option: 'value',
});

console.log(result);
// Output: { success: true, data: ... }
\`\`\`

### 3. Vérifier que ça marche

\`\`\`bash
# Exécuter l'exemple
npx ts-node example.ts
\`\`\`

**🎉 C'est tout ! Vous êtes prêt à utiliser [Nom du projet].**

Pour aller plus loin, consultez la section [Utilisation](#-utilisation).
```

### Utilisation détaillée

```markdown
## 📖 Utilisation

### Cas d'usage 1 : [Titre]

\`\`\`typescript
import { Feature } from 'package-name';

// Description de ce que fait cet exemple
const feature = new Feature({
  config: 'value',
});

// Utilisation
const result = await feature.execute();
\`\`\`

### Cas d'usage 2 : [Titre]

\`\`\`typescript
// Exemple plus avancé
import { AdvancedFeature, helpers } from 'package-name';

const advanced = new AdvancedFeature();

// Avec des options avancées
const result = await advanced.process({
  input: data,
  options: {
    mode: 'advanced',
    debug: true,
  },
});
\`\`\`

### Intégration avec [Framework]

\`\`\`typescript
// Exemple d'intégration avec React/Express/etc.
\`\`\`
```

### Configuration

```markdown
## ⚙️ Configuration

### Options disponibles

| Option | Type | Défaut | Description |
|--------|------|--------|-------------|
| `option1` | `string` | `'default'` | Description de l'option |
| `option2` | `number` | `100` | Description de l'option |
| `option3` | `boolean` | `false` | Description de l'option |

### Fichier de configuration

Créez un fichier `config.json` ou `.configrc` :

\`\`\`json
{
  "option1": "custom-value",
  "option2": 200,
  "option3": true
}
\`\`\`

### Variables d'environnement

| Variable | Description | Obligatoire |
|----------|-------------|-------------|
| `API_KEY` | Clé d'API pour le service | Oui |
| `DEBUG` | Active le mode debug | Non |

\`\`\`bash
# .env
API_KEY=your-api-key
DEBUG=true
\`\`\`
```

### API Reference

```markdown
## 📚 API Reference

### `MainClass`

#### Constructor

\`\`\`typescript
new MainClass(options?: MainClassOptions)
\`\`\`

**Parameters:**

| Param | Type | Description |
|-------|------|-------------|
| `options` | `MainClassOptions` | Configuration options |

#### Methods

##### `method1(param: string): Promise<Result>`

Description de la méthode.

**Parameters:**
- `param` (string): Description du paramètre

**Returns:** `Promise<Result>` - Description du retour

**Example:**

\`\`\`typescript
const result = await instance.method1('value');
\`\`\`

##### `method2(options: Options): void`

Description de la méthode.

### Types

\`\`\`typescript
interface MainClassOptions {
  option1: string;
  option2?: number;
}

interface Result {
  success: boolean;
  data: unknown;
}
\`\`\`
```

### Exemples

```markdown
## 💡 Exemples

### Exemple complet

Voir le dossier [`/examples`](./examples) pour des exemples complets :

- [`basic-usage`](./examples/basic-usage) - Utilisation de base
- [`advanced-config`](./examples/advanced-config) - Configuration avancée
- [`integration-react`](./examples/integration-react) - Intégration React

### Exécuter les exemples

\`\`\`bash
# Cloner le repo
git clone https://github.com/org/repo.git
cd repo

# Installer les dépendances
npm install

# Exécuter un exemple
cd examples/basic-usage
npm start
\`\`\`

### Codesandbox

[![Edit on CodeSandbox](https://codesandbox.io/static/img/play-codesandbox.svg)](https://codesandbox.io/s/example)
```

### FAQ

```markdown
## ❓ FAQ

<details>
<summary><strong>Comment faire X ?</strong></summary>

Réponse détaillée avec exemple de code si nécessaire.

\`\`\`typescript
// Exemple
\`\`\`

</details>

<details>
<summary><strong>Pourquoi l'erreur Y apparaît ?</strong></summary>

Explication de l'erreur et solution.

</details>

<details>
<summary><strong>Est-ce compatible avec Z ?</strong></summary>

Oui/Non, avec explication.

</details>
```

### Contribution

```markdown
## 🤝 Contribution

Les contributions sont les bienvenues ! Consultez notre [guide de contribution](CONTRIBUTING.md).

### Quick contribution guide

1. **Fork** le projet
2. **Clone** votre fork
   \`\`\`bash
   git clone https://github.com/votre-username/repo.git
   \`\`\`
3. **Créez** une branche
   \`\`\`bash
   git checkout -b feature/ma-feature
   \`\`\`
4. **Commitez** vos changements
   \`\`\`bash
   git commit -m "feat: ajout de ma feature"
   \`\`\`
5. **Push** et créez une **Pull Request**

### Development setup

\`\`\`bash
# Installer les dépendances de dev
npm install

# Lancer les tests
npm test

# Lancer le linter
npm run lint

# Build
npm run build
\`\`\`

### Contributors

Merci à tous les contributeurs ! 🙏

<a href="https://github.com/org/repo/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=org/repo" />
</a>
```

### Footer

```markdown
## 📄 Licence

Distribué sous la licence MIT. Voir [`LICENSE`](LICENSE) pour plus d'informations.

## 🙏 Remerciements

- [Dépendance 1](link) - Description
- [Inspiration](link) - Description

---

<p align="center">
  Fait avec ❤️ par <a href="https://github.com/org">Organisation</a>
</p>

<p align="center">
  <a href="#-nom-du-projet">⬆️ Retour en haut</a>
</p>
```

## Variantes par type de projet

### Librairie npm

```markdown
## Installation

\`\`\`bash
npm install package-name
\`\`\`

## Bundle size

[![Bundle size](https://img.shields.io/bundlephobia/minzip/package-name)](https://bundlephobia.com/package/package-name)

- Minified: X KB
- Gzipped: X KB
- No dependencies
```

### CLI Tool

```markdown
## Installation

\`\`\`bash
npm install -g cli-name
\`\`\`

## Usage

\`\`\`bash
cli-name [command] [options]
\`\`\`

### Commands

| Command | Description |
|---------|-------------|
| `init` | Initialize a new project |
| `build` | Build the project |
| `deploy` | Deploy to production |

### Options

| Option | Alias | Description |
|--------|-------|-------------|
| `--help` | `-h` | Show help |
| `--version` | `-v` | Show version |
| `--config` | `-c` | Config file path |
```

### API / Backend

```markdown
## Endpoints

### Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/login` | Login |
| POST | `/auth/register` | Register |
| POST | `/auth/logout` | Logout |

### Example Request

\`\`\`bash
curl -X POST https://api.example.com/auth/login \\
  -H "Content-Type: application/json" \\
  -d '{"email": "user@example.com", "password": "***"}'
\`\`\`
```

## Checklist qualité

```markdown
## Checklist README

### Essentiel
- [ ] Nom et description claire
- [ ] Installation (copy-paste friendly)
- [ ] Quick start fonctionnel
- [ ] Au moins un exemple
- [ ] Licence

### Recommandé
- [ ] Badges (npm, CI, coverage)
- [ ] Table des matières
- [ ] Fonctionnalités listées
- [ ] Configuration documentée
- [ ] FAQ

### Bonus
- [ ] GIF/Screenshot du produit
- [ ] Comparaison avec alternatives
- [ ] Codesandbox/StackBlitz
- [ ] Contributors
- [ ] Changelog
```

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/doc:doc-generate` | Documentation détaillée |
| `/doc:doc-changelog` | Changelog du projet |
| `/doc:doc-api-spec` | Documentation API |
| `/doc:doc-onboard` | Onboarding développeurs |

---

IMPORTANT: Le README est souvent le premier contact avec le projet. Il doit convaincre en 30 secondes.

YOU MUST inclure une installation copy-paste friendly.

YOU MUST avoir au moins un exemple qui fonctionne.

NEVER avoir un README sans Quick Start.

Think hard sur ce que le lecteur veut savoir en premier.


---

## Voir aussi

- [Retour aux commandes DOC](/docs/commands/doc)
- [Toutes les commandes](/docs/commands)
