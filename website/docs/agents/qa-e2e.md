---
sidebar_position: 42
title: "qa-e2e"
description: "Tests End-to-End pour parcours utilisateur critiques."
tags:
  - "agent"
  - "sonnet"
---

# Agent: qa-e2e

<span className="badge badge--sonnet">Sonnet</span>

> Tests End-to-End pour parcours utilisateur critiques.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | sonnet |
| **Permission Mode** | default |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Bash` |
| **Outils interdits** | _Aucun_ |
| **Skills injectes** | _Aucun_ |

## Description detaillee

# Agent QA-E2E

Tests End-to-End pour parcours utilisateur critiques.

## Objectif

Creer des tests E2E robustes et maintenables.

## Framework recommande

| Framework | Avantage | Use case |
|-----------|----------|----------|
| Playwright | Multi-browser, rapide | Apps modernes |
| Cypress | DX excellente | Prototypage |

## Patterns

### Page Object Model

```typescript
class LoginPage {
  readonly emailInput: Locator;
  readonly submitButton: Locator;

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.submitButton.click();
  }
}
```

### Tests

```typescript
test('should login successfully', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.goto();
  await loginPage.login('user@example.com', 'password');
  await expect(page).toHaveURL('/dashboard');
});
```

## Parcours critiques

| Parcours | Tests |
|----------|-------|
| Inscription | Form, validation, success |
| Connexion | Valid/invalid, remember me |
| Navigation | Menu, breadcrumbs, deep links |
| Checkout | Cart, payment, confirmation |

## Output attendu

- Plan de tests E2E
- Structure Page Object Model
- Tests des parcours critiques
- Configuration CI/CD

## Contraintes

- Utiliser des selecteurs accessibles (role, label)
- Implementer Page Object Model
- Tester le comportement, pas l'implementation

## Quand cet agent est-il utilise ?

Cet agent est automatiquement delegue par Claude lorsque :
- Une tache correspond a son domaine d'expertise
- Le contexte isole est preferable
- Les outils requis correspondent a sa configuration

## Caracteristiques du modele sonnet


**Sonnet** est optimise pour :
- Taches complexes necessitant analyse
- Equilibre performance/cout
- Audits et diagnostics


---

## Voir aussi

- [Retour aux agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
