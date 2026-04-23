---
sidebar_position: 4
title: "/git-rename"
description: "Renomme la branche courante (typiquement une branche `feature/auto-*` creee par le hook PreToolUse)."
tags:
  - "other"
  - "command"
---


import CommandCard from '@site/src/components/CommandCard';

<span className="badge badge--other">Autres</span>


# Commande GIT-RENAME

Renomme la branche courante (typiquement une branche `feature/auto-*` creee par le hook PreToolUse).

## Contexte
`&lt;arguments&gt;`

## Objectif

Donner un nom descriptif a une branche generee automatiquement (ou simplement renommer la branche courante), localement et sur le remote si elle a deja ete pushee.

## Utilisation

```
/git-rename <nouveau-nom>
```

Exemples :

```
/git-rename feature/git-rename-command
/git-rename fix/login-redirect
/git-rename refactor/api-client
```

Le prefixe (`feature/`, `fix/`, `refactor/`...) est optionnel : si absent, `feature/` est ajoute par defaut.

## Workflow

1. **Verifier l'etat**
    - Lire la branche courante (`git rev-parse --abbrev-ref HEAD`)
    - Refuser si la branche est `main` ou `master` (impossible a renommer en place sans confusion)
    - Verifier que le nouveau nom est valide (pas d'espaces, pas de caracteres speciaux git)
2. **Renommer en local**
    - `git branch -m &lt;nouveau-nom&gt;`
3. **Synchroniser le remote (si la branche a ete pushee)**
    - Detecter l'upstream (`git rev-parse --abbrev-ref --symbolic-full-name @\{u\}`)
    - Si upstream existe : `git push origin :&lt;ancien-nom&gt; &lt;nouveau-nom&gt;` puis `git push origin -u &lt;nouveau-nom&gt;`
    - Sinon : pas de push, juste un message indiquant que la branche est locale
4. **Confirmer**
    - Afficher la nouvelle branche et son tracking remote

## Output attendu

- Branche renommee localement (et sur le remote si applicable)
- Confirmation `git status` + `git branch -vv` pour verifier le tracking
- Si une PR existe deja sur l'ancienne branche, avertir l'utilisateur qu'il doit la mettre a jour manuellement (GitHub ne suit pas un rename de branche)

## Cas particuliers

| Situation | Action |
|-----------|--------|
| Branche `main`/`master` | REFUSER, expliquer pourquoi |
| Nouveau nom == nom actuel | Ne rien faire, message informatif |
| Nouveau nom existe deja en local | REFUSER, suggerer un autre nom |
| Pas d'upstream | Renommer en local seulement |
| PR ouverte sur l'ancienne branche | Renommer + WARN : la PR pointe vers une branche qui n'existe plus, action manuelle requise |

---

IMPORTANT: Ne JAMAIS supprimer l'ancienne branche distante avant d'avoir push la nouvelle (utiliser `git push origin :ancien nouveau` en une seule commande pour rester atomique cote remote).

NEVER renommer `main` ou `master`.

YOU MUST verifier la presence d'un upstream avant de tenter un push.


---

## Voir aussi

- [Retour aux commandes Autres](/docs/commands/other)
- [Toutes les commandes](/docs/commands)
