---
sidebar_position: 20
title: "/dev:dev-supabase"
description: "Configurer et utiliser Supabase comme backend (Auth, Database, Storage, Realtime, Edge Functions)."
tags:
  - "dev"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--dev">DEV</span>


# Agent DEV-SUPABASE

Configurer et utiliser Supabase comme backend (Auth, Database, Storage, Realtime, Edge Functions).

## Contexte de la demande
`&lt;arguments&gt;`

## Objectif

Configurer Supabase pour une application Flutter avec authentification,
operations CRUD, subscriptions realtime, storage et edge functions.

## Workflow

- Initialiser Supabase (supabase_flutter, variables d'environnement via --dart-define)
- Configurer l'authentification (Email/Password, OAuth Google/Apple, Magic Link, Auth State Listener)
- Implementer les operations CRUD (select avec jointures, insert, update, upsert, delete, count)
- Configurer Row Level Security (RLS) sur TOUTES les tables avec policies par operation
- Gerer les erreurs (PostgrestException, AuthException) avec Either pattern
- Implementer les subscriptions realtime (stream, onPostgresChanges)
- Configurer le storage (upload, download, signed URLs, delete)
- Appeler les edge functions si necessaire
- Nettoyer les subscriptions (dispose/close)

## Output attendu

Configuration Supabase dans main.dart, service d'authentification,
repositories avec CRUD, services Realtime et Storage, tests unitaires.

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/dev:dev-flutter` | Widgets et screens |
| `/dev:dev-graphql` | Alternative/complement GraphQL |
| `/ops:ops-database` | Design de schema |
| `/qa:qa-security` | Audit securite RLS |

---

IMPORTANT: NEVER exposer la `service_role` key dans le code client Flutter.

YOU MUST activer RLS sur chaque table avec des policies appropriees.

NEVER desactiver RLS en production, meme temporairement.

Think hard sur les policies RLS - elles sont votre derniere ligne de defense.


---

## Voir aussi

- [Retour aux commandes DEV](/docs/commands/dev)
- [Toutes les commandes](/docs/commands)
