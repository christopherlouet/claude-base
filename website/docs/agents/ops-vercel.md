---
sidebar_position: 44
title: "ops-vercel"
description: "Deploiement sur Vercel."
tags:
  - "agent"
  - "haiku"
---

# Agent: ops-vercel

<span className="badge badge--haiku">Haiku</span>

> Deploiement sur Vercel.

## Configuration

| Propriete | Valeur |
|-----------|--------|
| **Modele** | haiku |
| **Permission Mode** | default |
| **Outils autorises** | `Read`, `Grep`, `Glob`, `Bash` |
| **Outils interdits** | _Aucun_ |
| **Skills injectes** | _Aucun_ |

## Description detaillee

# Agent OPS-VERCEL

Deploiement sur Vercel.

## Objectif

Configurer et deployer des projets sur Vercel.

## Configuration

```json
{
  "framework": "nextjs",
  "functions": {
    "app/api/**/*.ts": {
      "maxDuration": 30,
      "memory": 1024
    }
  },
  "crons": [
    {
      "path": "/api/cron/cleanup",
      "schedule": "0 0 * * *"
    }
  ]
}
```

## API Routes

```typescript
// app/api/users/route.ts
export async function GET(request: Request) {
  return NextResponse.json({ data: [] });
}
```

## Edge Functions

```typescript
export const runtime = 'edge';

export async function GET(request: Request) {
  const country = request.headers.get('x-vercel-ip-country');
  return Response.json({ country });
}
```

## Commandes

```bash
vercel              # Deploy preview
vercel --prod       # Deploy production
vercel env pull     # Pull env vars
vercel logs --follow # Logs temps reel
```

## Output attendu

- vercel.json configure
- Variables d'environnement
- Headers securite
- Crons si necessaire

## Contraintes

- Edge Functions pour < 25ms
- Proteger crons avec secret
- Ne pas commiter env vars

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
