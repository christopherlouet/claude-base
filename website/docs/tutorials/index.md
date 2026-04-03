---
sidebar_position: 1
title: Tutoriels
description: Apprenez à utiliser claude-socle avec des tutoriels progressifs pas-à-pas
---

import TutorialCard, { TutorialGrid } from '@site/src/components/TutorialCard';

# Tutoriels

Bienvenue dans les tutoriels claude-socle ! Ces guides pratiques vous accompagnent pas-à-pas pour maîtriser le workflow **Explore → Specify → Plan → TDD → Commit**.

## Parcours recommandé

Suivez ces tutoriels dans l'ordre pour une progression optimale :

<TutorialGrid>
  <TutorialCard
    title="Premier projet"
    description="Découvrez le workflow de base en créant votre première feature avec claude-socle."
    duration="15 min"
    difficulty="beginner"
    href="/docs/tutorials/premier-projet"
  />
  <TutorialCard
    title="Feature React"
    description="Créez un composant et un hook React complets avec tests et documentation."
    duration="30 min"
    difficulty="beginner"
    href="/docs/tutorials/feature-react"
    prerequisites={['Tutoriel 01', 'React']}
  />
  <TutorialCard
    title="API REST Node.js"
    description="Développez une API REST complète avec TDD, validation et documentation OpenAPI."
    duration="45 min"
    difficulty="intermediate"
    href="/docs/tutorials/api-rest-node"
    prerequisites={['Node.js', 'Express/Fastify']}
  />
  <TutorialCard
    title="Flutter + Supabase"
    description="Construisez une app mobile Flutter avec authentification et backend Supabase."
    duration="60 min"
    difficulty="intermediate"
    href="/docs/tutorials/flutter-supabase"
    prerequisites={['Flutter SDK', 'Compte Supabase']}
  />
  <TutorialCard
    title="Audit de sécurité"
    description="Réalisez un audit de sécurité OWASP complet et corrigez les vulnérabilités."
    duration="30 min"
    difficulty="intermediate"
    href="/docs/tutorials/audit-securite"
    prerequisites={['Projet web existant']}
  />
  <TutorialCard
    title="Pipeline CI/CD"
    description="Configurez un pipeline GitHub Actions complet avec tests, build et déploiement."
    duration="45 min"
    difficulty="intermediate"
    href="/docs/tutorials/cicd-github"
    prerequisites={['Repository GitHub']}
  />
  <TutorialCard
    title="Refactoring Legacy"
    description="Refactorez un projet legacy en utilisant TDD et une approche méthodique."
    duration="60 min"
    difficulty="advanced"
    href="/docs/tutorials/refactoring-legacy"
    prerequisites={['Projet à refactorer']}
  />
  <TutorialCard
    title="Infrastructure Proxmox"
    description="Déployez une infrastructure Proxmox avec Terraform et monitoring."
    duration="60 min"
    difficulty="advanced"
    href="/docs/tutorials/proxmox-infra"
    prerequisites={['Proxmox', 'Terraform']}
  />
  <TutorialCard
    title="Firewall OPNsense"
    description="Configurez OPNsense comme firewall derrière une box opérateur avec Terraform."
    duration="45 min"
    difficulty="intermediate"
    href="/docs/tutorials/opnsense-firewall"
    prerequisites={['OPNsense', 'Terraform']}
  />
  <TutorialCard
    title="API Python FastAPI"
    description="Developpez une API REST FastAPI avec TDD pytest, validation Pydantic et documentation OpenAPI."
    duration="45 min"
    difficulty="intermediate"
    href="/docs/tutorials/api-python"
    prerequisites={['Python 3.11+', 'uv ou pip']}
  />
  <TutorialCard
    title="API Go"
    description="Developpez une API REST Go avec Chi, TDD table-driven et documentation OpenAPI."
    duration="45 min"
    difficulty="intermediate"
    href="/docs/tutorials/api-go"
    prerequisites={['Go 1.22+']}
  />
</TutorialGrid>

## Projet fil rouge

<TutorialGrid>
  <TutorialCard
    title="Projet complet : TaskFlow"
    description="Construisez un mini-SaaS de A a Z en utilisant tout le workflow du socle : Specify, Plan, TDD, Audit, CI/CD, Deploy."
    duration="3-4h"
    difficulty="advanced"
    href="/docs/tutorials/projet-complet"
    prerequisites={['Tutoriels 01-06', 'Node.js', 'React']}
  />
</TutorialGrid>

## Prérequis généraux

Avant de commencer, assurez-vous d'avoir :

- **Claude Code** installé et fonctionnel
- **claude-socle** configuré dans votre projet (voir [Installation](/docs/intro/installation))
- Des connaissances de base en ligne de commande

## Comment utiliser ces tutoriels

1. **Suivez l'ordre suggéré** - Les tutoriels sont conçus pour être progressifs
2. **Pratiquez** - Exécutez chaque commande vous-même
3. **Comparez vos résultats** - Chaque étape montre le résultat attendu
4. **Expérimentez** - Une fois le tutoriel terminé, adaptez à vos projets

## Besoin d'aide ?

- Consultez la [FAQ](/docs/guides/faq) pour les questions courantes
- Consultez le [Troubleshooting](/docs/guides/troubleshooting) en cas de problème
- Ouvrez une [issue GitHub](https://github.com/christopherlouet/claude-socle/issues) si vous êtes bloqué
