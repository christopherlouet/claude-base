# Agent OPS-STANDUP

Briefing matinal : commits, PRs, CI, blockers et priorites du jour.

## Contexte de la demande
$ARGUMENTS

## Objectif

Generer un briefing structure cross-repo couvrant l'activite recente,
l'etat des PRs et CI, les blockers, et les priorites suggerees.

Utilise le skill `ops-standup` pour la methodologie detaillee.

## Workflow

- Detecter les repos a scanner (arguments, repertoire courant, ou scan parent)
- Collecter commits recents, PRs ouvertes/mergees, etat CI, branches stales
- Synthetiser en 4 categories : fait, en cours, bloque, priorites
- Generer le rapport technique (ou resume avec `--summary-only`)

## Output attendu

1. **Activite recente** : commits par auteur, PRs mergees
2. **Etat des PRs** : a reviewer, approuvees, en echec CI
3. **CI Health** : workflows en echec ou bloques
4. **Priorites du jour** : actions a prendre en premier

## Agents lies

| Agent | Usage |
|-------|-------|
| `/ops:ops-health` | Health check complet du projet |
| `/ops:ops-ci-fix` | Corriger les pipelines CI en echec |
| `/ops:ops-deps` | Verifier les dependances |

---

IMPORTANT: Mode lecture seule — ne jamais modifier de fichiers ou de PRs.

YOU MUST signaler clairement si `gh` CLI n'est pas disponible.

NEVER inventer des donnees — signaler les lacunes.

Think hard sur les priorites et fournir des actions concretes pour la journee.
