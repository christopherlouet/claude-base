---
sidebar_position: 37
title: "ops-serverless"
description: "Deploiement d'applications serverless."
tags:
  - "agent"
  - "haiku"
---

# Agent: ops-serverless

<span className="badge badge--haiku">Haiku</span>

> Deploiement d'applications serverless.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | haiku |
| **Permission Mode** | default |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Bash` |
| **Outils interdits** | _Aucun_ |
| **Skills injectes** | _Aucun_ |

## Description detaillee

# Agent SERVERLESS

Deploiement d'applications serverless.

## Objectif

Configurer et deployer des fonctions serverless.

## Plateformes

| Plateforme | Cold start | Use case |
|------------|------------|----------|
| AWS Lambda | 100-500ms | Backend complet |
| Vercel | ~50ms | Frontend + API |
| Cloudflare Workers | ~5ms | Edge computing |

## AWS Lambda (Serverless Framework)

```yaml
service: my-api
provider:
  name: aws
  runtime: nodejs20.x
  region: eu-west-1

functions:
  getUsers:
    handler: src/handlers/users.list
    events:
      - http:
          path: /users
          method: get
```

## Handler

```typescript
export const list: APIGatewayProxyHandler = async (event) => {
  const users = await prisma.user.findMany();
  return {
    statusCode: 200,
    body: JSON.stringify({ data: users }),
  };
};
```

## Commandes

```bash
npx serverless offline      # Dev local
npx serverless deploy       # Deploy
npx serverless logs -f name # Logs
```

## Output attendu

- Configuration serverless.yml
- Handlers optimises
- Configuration CI/CD
- Estimation couts

## Contraintes

- Optimiser pour cold starts
- Utiliser connexions poolees
- Configurer timeouts adequats
- Pas d'etat en memoire

## Quand cet agent est-il utilise ?

Cet agent est automatiquement delegue par Claude lorsque :
- Une tache correspond a son domaine d'expertise
- Le contexte isole est preferable
- Les outils requis correspondent a sa configuration

## Caracteristiques du modele haiku


**Haiku** est optimise pour :
- Taches rapides et simples
- Economie de tokens
- Exploration et lecture seule


---

## Voir aussi

- [Retour aux agents](/docs/agents)
- [Architecture](/docs/intro/architecture)
