# Commande LESSONS

Liste les `feedback` memories capturees pour le projet courant (et globalement) — les "lecons" apprises a partir des corrections utilisateur.

## Contexte
$ARGUMENTS

## Objectif

Donner une vue d'ensemble du systeme self-improvement : quelles regles, contre-exemples ou preferences ont deja ete enregistres pour eviter de refaire les memes erreurs.

## Utilisation

```
/lessons              # Liste toutes les feedback memories du projet
/lessons <keyword>    # Filtre par mot-cle (ex: /lessons test, /lessons git)
```

## Workflow

1. **Localiser le repertoire memoire**
    - Per-project : `~/.claude/projects/<project-slug>/memory/`
    - Global : `~/.claude/memory/` (si existant)
2. **Filtrer les feedback memories**
    - Lire `MEMORY.md` et chaque fichier `feedback_*.md`
    - Extraire le frontmatter `type: feedback` pour tri
3. **Synthese**
    - Pour chaque memoire, afficher :
      - Titre + description courte
      - **Why** (raison initiale)
      - **How to apply** (quand appliquer la regle)
4. **Filtrage optionnel**
    - Si un keyword est passe, ne garder que les memoires dont le titre, description ou contenu matche

## Output attendu

```
=== Feedback memories pour ce projet ===

1. Manual review of infra PRs
   user reviews and merges infra PRs himself, no auto-merge even when CI is green
   Why: prior incidents with auto-merge missing context
   How to apply: never enable Dependabot auto-merge for infra repos

2. Claude Max works headless on user VMs
   `claude setup-token` is the official path for cron/CI on Max
   Why: Max plan supports headless via setup-token
   How to apply: do not default to Routines for automation projects

=== Feedback memories globales (cross-projet) ===
(aucune si ~/.claude/memory/ vide)
```

## Cas particuliers

| Situation | Action |
|-----------|--------|
| Aucune memoire | Message informatif + lien vers la doc auto-memory |
| Memoire sans `type: feedback` | Ignorer (ne lister que les feedback) |
| Filtre keyword sans match | Message "Aucune memoire matche '<keyword>'" |
| Memoire orpheline (fichier sans entree dans MEMORY.md) | WARN, suggerer de re-indexer |

---

IMPORTANT: Cette commande est en lecture seule. Pour ajouter une lecon, le system prompt s'en charge automatiquement quand l'utilisateur fait une correction (signal detecte par `prompt-context.sh`).

NEVER modifier ou supprimer une feedback memory sans confirmation explicite de l'utilisateur.
