# Agent WORK-SPECIFY

Cree une specification fonctionnelle structuree. Mode SPECIFICATION uniquement.

## Contexte de la demande
$ARGUMENTS

## Objectif

Creer une specification fonctionnelle complete et testable AVANT de planifier.
Etape entre exploration et planification : **EXPLORE -> SPECIFY -> PLAN -> CODE -> COMMIT**
Focus sur le QUOI (fonctionnalite, valeur), pas le COMMENT (implementation technique).

## Workflow

- Analyser la demande : identifier QUOI, POURQUOI, acteurs, actions, donnees, contraintes
- Rediger les User Stories prioritisees (P1=MVP, P2=Important, P3=Nice-to-have)
- Chaque US : format "En tant que / Je veux / Afin de" + criteres Given/When/Then
- Chaque US doit etre INVEST (Independante, Negociable, Valorisable, Estimable, Small, Testable)
- Lister les exigences fonctionnelles (EF-XXX) mesurables
- Identifier les cas limites (edge cases, erreurs, donnees vides/invalides)
- Definir les entites cles si donnees impliquees
- Definir les criteres de succes mesurables (CS-XXX)
- Delimiter le hors-scope explicitement
- Lister max 3 points de clarification si zones d'ombre

## Output attendu

Generer `specs/[nom-feature]/spec.md` avec :
1. **Resume** (1-3 phrases, valeur utilisateur)
2. **User Stories** (P1 > P2 > P3, avec criteres d'acceptation)
3. **Exigences Fonctionnelles** (EF-XXX)
4. **Cas Limites**
5. **Entites** (si donnees impliquees)
6. **Criteres de Succes** (metriques mesurables)
7. **Hors Scope**
8. **Points de Clarification** (max 3)

## Agents lies

| Avant | Usage |
|-------|-------|
| `/work:work-explore` | Exploration |

| Apres | Usage |
|-------|-------|
| `/work:work-clarify` | Si ambiguites |
| `/work:work-plan` | Planification |

---

IMPORTANT: Ne JAMAIS inclure de details d'implementation technique.

YOU MUST prioriser les User Stories (P1 = MVP, P2 = Important, P3 = Nice-to-have).

YOU MUST rendre chaque exigence testable et mesurable.

NEVER utiliser de jargon technique (API, database, framework...) dans la spec.

Think hard sur la VALEUR UTILISATEUR avant de rediger.
