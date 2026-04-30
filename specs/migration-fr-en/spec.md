# Spec — Migration FR → EN du socle claude-socle

> Statut : DRAFT
> Cree le : 2026-04-30
> Phase : SPECIFY (avant PLAN)
> Fenetre cible : jeudi 2026-04-30 soir → dimanche 2026-05-03 soir

## 1. Resume

Le socle claude-socle vient d'etre rendu public. Pour ouvrir la contribution a un public international (>90% des devs Claude Code potentiels), tout le contenu utilisateur du repo doit passer du francais a l'anglais : README, agents, commandes, skills, regles, guides, site Docusaurus. Le chantier vise un repo coherent en EN d'ici lundi matin, en exploitant l'abonnement Claude Max en mode autonome la nuit + le week-end, sans casser les references internes ni l'experience des utilisateurs actuels.

**Valeur** : ouvrir la base de contributeurs potentiels (FR-only ≈ 1% des devs ; EN ≈ couverture globale), reduire la dette de traduction qui croit chaque jour avec les nouveaux ajouts, eviter la situation toxique d'un repo bilingue mal entretenu pendant 3+ mois.

## 2. User Stories

### P1 — MVP (bloquant pour merger quoi que ce soit)

#### US1 — Glossaire terminologique fige avant la premiere nuit
**En tant que** mainteneur du socle
**Je veux** un glossaire des 50+ termes recurrents avec une traduction canonique unique chacun
**Afin de** garantir la coherence terminologique sur les 746 fichiers traduits par lots successifs

- **Given** le socle contient des termes recurrents (boucle, agent, regle, etape, audit, dette, socle, atelier, etape, etat...)
- **When** un terme apparait dans plusieurs fichiers traduits dans des lots differents
- **Then** il est traduit de maniere identique dans tous les fichiers
- **And** le glossaire est figee avant le lancement du premier lot
- **And** un controle automatise detecte une derive (ex : "loop" devenu "cycle" dans 3 fichiers)

#### US2 — Tier 1 livre coherent en EN avec revue humaine
**En tant que** visiteur du repo public
**Je veux** que la vitrine du projet (README, page d'accueil, guides principaux) soit en anglais propre
**Afin de** comprendre la valeur du socle sans bloquer sur la langue

- **Given** un visiteur EN arrive sur le repo GitHub ou le site
- **When** il lit le README, le CLAUDE.md, les guides du dossier docs/guides/
- **Then** le contenu est en anglais coherent (zero phrase FR residuelle dans ces fichiers)
- **And** un humain a relu chaque fichier de la vitrine avant le merge
- **And** la qualite est equivalente ou superieure a la version FR

#### US3 — Aucune reference interne cassee
**En tant que** utilisateur du socle
**Je veux** que les liens, chemins, et noms de commandes continuent de fonctionner apres la migration
**Afin de** ne pas voir mes workflows actuels casses

- **Given** un fichier traduit contient des references vers d'autres fichiers, slash commands, ou ancres
- **When** la traduction est appliquee
- **Then** les noms de slash commands restent identiques (`/work:work-explore` ne devient pas `/work:work-explorer`)
- **And** les chemins de fichiers ne sont pas traduits
- **And** les ancres markdown internes pointent vers des sections existantes
- **And** un test automatise detecte chaque reference cassee avant le merge

#### US4 — Anti-drift adapte a la phase bilingue temporaire
**En tant que** mainteneur
**Je veux** que les controles existants (compteurs, validations) continuent a passer pendant la migration
**Afin de** ne pas casser la CI au milieu du chantier

- **Given** le repo passe par une phase bilingue (certains tiers traduits, d'autres pas)
- **When** la CI s'execute sur une PR de tier
- **Then** les controles anti-drift passent malgre le mix FR/EN
- **And** apres le merge des 4 tiers, les controles passent en mode full-EN
- **And** aucun controle n'est desactive de maniere permanente

#### US5 — Livraison en 4 PRs separees mergeables independamment
**En tant que** mainteneur
**Je veux** que la migration arrive sous forme de 4 PRs (une par tier)
**Afin de** pouvoir reviewer, tester et rollback chaque tier independamment

- **Given** la migration produit ~410k mots traduits sur 746 fichiers
- **When** le travail est livre
- **Then** il existe 4 PRs distinctes (Tier 1 / Tier 2 / Tier 3 / Tier 4)
- **And** chaque PR peut etre mergee meme si une autre est en review
- **And** chaque PR a un scope clair et un checklist de revue dedie
- **And** aucune PR ne fait plus de 200 fichiers ou 100k mots

#### US6 — Checkpoint humain vendredi matin
**En tant que** mainteneur
**Je veux** valider manuellement le tier 1 traduit + le glossaire avant que les autres tiers se lancent
**Afin de** detecter et corriger une derive avant qu'elle infecte les 600+ fichiers restants

- **Given** la nuit du jeudi a produit le tier 1 en draft
- **When** le mainteneur fait sa revue le vendredi matin
- **Then** il peut bloquer / corriger / valider le glossaire
- **And** les nuits suivantes ne se lancent qu'apres validation explicite
- **And** un script permet de figer le glossaire et empecher toute modification ulterieure

### P2 — Important (week-end)

#### US7 — Tiers 2, 3, 4 traduits en draft
**En tant que** mainteneur
**Je veux** que les 286 fichiers d'agents et commandes (tier 2), les skills/regles/hooks (tier 3), et le site Docusaurus (tier 4) soient traduits avant lundi
**Afin de** boucler le chantier sur la fenetre choisie

- **Given** le tier 1 a ete valide vendredi matin et le glossaire est lock
- **When** les nuits du vendredi, samedi et dimanche tournent en mode autonome
- **Then** ≥80% des fichiers des tiers 2-4 sont en draft EN d'ici dimanche soir
- **And** chaque tier a sa PR ouverte (meme si en draft)

#### US8 — Regle "english-first" appliquee immediatement pour tout nouveau contenu
**En tant que** mainteneur
**Je veux** que tout nouveau fichier ou modification ajoutee a partir de maintenant soit en anglais
**Afin de** ne pas continuer a creuser la dette de traduction pendant que la migration tourne

- **Given** la migration est en cours
- **When** un nouvel agent, une nouvelle commande, ou une nouvelle section de doc est ajoutee
- **Then** elle est ecrite directement en anglais
- **And** les commits/PRs sont rediges en anglais
- **And** une regle ou un hook documente cette consigne pour les contributeurs

#### US9 — Cap Claude Max respecte
**En tant que** mainteneur (utilisateur de l'abonnement Max)
**Je veux** que la consommation reste sous la limite hebdo
**Afin de** ne pas se retrouver bloque dimanche apres-midi avec 30% du chantier non traduit et plus de quota

- **Given** l'abonnement Claude Max a une limite hebdomadaire
- **When** les nuits headless tournent
- **Then** la consommation est monitoree
- **And** un mecanisme de pause / priorisation s'active si on approche du cap
- **And** les tiers les plus critiques sont termines en priorite

### P3 — Nice-to-have

#### US10 — Recovery d'une nuit interrompue
**En tant que** mainteneur
**Je veux** pouvoir reprendre une nuit qui a plante au milieu sans retraduire les fichiers deja faits
**Afin de** ne pas perdre une nuit entiere a cause d'un bug ou d'une coupure reseau

- **Given** une nuit headless est en cours et plante (rate limit, bug, coupure)
- **When** le mainteneur la relance
- **Then** elle reprend la ou elle s'est arretee (checkpoint par fichier)
- **And** les fichiers deja traduits ne sont pas refaits

#### US11 — Documentation du processus de migration
**En tant que** futur mainteneur (ou meme moi dans 6 mois)
**Je veux** une trace de comment la migration a ete faite (glossaire, prompts, decisions)
**Afin de** pouvoir refaire l'exercice sur un autre projet ou en arriere

- **Given** la migration est terminee
- **When** je relis le repo dans 6 mois
- **Then** un document explique la methode, le glossaire, les decisions cle, ce qui a marche et ce qui n'a pas marche

## 3. Exigences Fonctionnelles

| ID | Exigence | Mesurable par |
|----|----------|---------------|
| EF-001 | Le glossaire contient au minimum les 50 termes les plus frequents, chacun avec une traduction canonique unique | Compte des entrees + grep frequence |
| EF-002 | Zero reference interne cassee apres traduction (slash commands, chemins, ancres) | Test automatise de validation des refs |
| EF-003 | Les controles anti-drift existants passent en mode bilingue temporaire et en mode full-EN | CI verte sur chaque PR |
| EF-004 | Livraison en 4 PRs distinctes, chacune mergeable independamment, < 200 fichiers et < 100k mots | Compte des PRs et leurs metriques |
| EF-005 | Un checkpoint humain vendredi matin valide ou bloque le glossaire avant la suite | Trace dans le journal de migration |
| EF-006 | La structure des fichiers est preservee (frontmatter YAML, hierarchie des titres, blocs de code intacts) | Diff structurel automatise |
| EF-007 | Les identifiants techniques (noms de slash commands, chemins, frontmatter `name:`) ne sont pas traduits | Liste blanche des termes intraduisibles + check |
| EF-008 | Tous les nouveaux commits/PRs/contenus a partir du lancement sont en anglais | Inspection des commits |
| EF-009 | La consommation Max reste sous le cap hebdo jusqu'a dimanche soir | Monitoring de l'usage |
| EF-010 | Un mecanisme de recovery permet de reprendre une nuit interrompue sans retraduire les fichiers deja faits | Test : kill milieu de nuit puis relance |
| EF-011 | Le tier 1 a ete valide selon la methode hybride D : (a) controles automatises 100% (refs, structure, glossaire, frontmatter) + (b) revue humaine integrale sur README+CLAUDE.md+1 guide majeur + scan rapide autres guides + spot-checks 10% rules | Trace de revue + approbation explicite + rapport de tests automatises |
| EF-012 | Les exemples de code dans les fichiers traduits restent fonctionnels (commandes, snippets) | Test : les exemples runnent |

## 4. Cas Limites

- **Nuit headless qui plante a mi-parcours** : recovery checkpoint par fichier, pas par tier
- **Glossaire qui derive sur un sous-ensemble** : detection automatique avant merge (grep des termes glossaire dans EN files)
- **Reference cross-tier** : un fichier tier 2 reference un fichier tier 4 pas encore traduit → la ref doit pointer vers le futur nom EN, ou rester FR temporairement avec marqueur
- **Contribution externe FR pendant la migration** : politique d'accueil claire (commenter, demander EN, ne pas merger FR)
- **Cap Max atteint avant fin** : priorisation tier 1 > 2 > 3 > 4 ; si epuisement, tier 4 peut glisser sur la semaine suivante
- **Exemples de code en FR dans la doc** (variables `prenom`, `nomUtilisateur`) : a anglicicer ou pas ? cf clarification 3
- **LinkedIn deja publie en FR** : pas de retro-action, mais futurs posts en EN
- **Issues/PRs ouvertes en FR** : politique de transition (laisser ouvertes, repondre en EN, merger meme si description FR)
- **Captures d'ecran avec UI FR** : hors scope (pas de regen)
- **Fichier dont la traduction casse une ancre depuis l'exterieur du repo** (lien LinkedIn, post de blog, awesome-list) : redirects ou conservation des ancres clefs

## 5. Entites cles

| Entite | Attributs cles | Role |
|--------|----------------|------|
| **Glossaire** | terme FR (unique), terme EN canonique, alternatives interdites, contexte/notes, lock status | Garantir la coherence terminologique |
| **Tier** | numero (1-4), liste fichiers, criticite, cible date, statut | Decoupage du chantier en lots livrables |
| **Fichier traduit** | chemin, tier, statut (todo/in-progress/draft/reviewed/merged), checksum source, lot d'origine | Suivi de l'avancement et recovery |
| **Reference interne** | type (slash-cmd / path / anchor), source, target, fichier ou elle apparait | Detection de refs cassees |
| **PR de tier** | tier, statut (draft/review/merged), nb fichiers, nb mots, checklist de revue | Livraison incrementale |
| **Liste blanche intraduisibles** | termes a ne JAMAIS traduire (slash commands, identifiants, chemins) | Protection des refs techniques |
| **Journal de migration** | timestamp, tier, lot, decisions, anomalies | Tracabilite et apprentissage |

## 6. Criteres de Succes

| ID | Critere | Cible | Mesure |
|----|---------|-------|--------|
| CS-001 | Tier 1 traduit, revu, et merge | 100% des fichiers tier 1 | Compte fichiers EN sur tier 1 |
| CS-002 | Tiers 2-4 traduits en draft | ≥80% des fichiers | Compte fichiers EN par tier |
| CS-003 | References internes cassees | 0 | Test automatise |
| CS-004 | Incoherences terminologiques sur les 50 termes du glossaire | 0 | Grep multi-fichiers |
| CS-005 | PRs livrees | 4 PRs separees mergeables | Compte des PRs |
| CS-006 | Cap Claude Max | Non epuise avant dim 23h59 | Monitoring usage |
| CS-007 | Anti-drift apres merge des 4 PRs | 100% vert | CI sur main |
| CS-008 | Qualite tier 1 (relecture humaine) | Approuve par mainteneur | Approbation explicite |
| CS-009 | Temps total de relecture humaine | < 8h cumulees sur le week-end | Mesure tracking |
| CS-010 | Fichiers structure preservee (frontmatter, headings) | 100% | Diff structurel |

## 7. Hors Scope

- **Internationalisation full multi-langues** (FR + EN + ES + ...) : juste FR → EN
- **Reformulation / amelioration du contenu** : juste traduction fidele, pas de refactor editorial
- **Traduction de l'historique git** : commits passes restent en FR
- **Traduction du post LinkedIn deja publie**
- **Traduction des issues/PRs deja ouvertes**
- **Regeneration de captures d'ecran avec UI FR**
- **Traduction des messages utilisateur dans les hooks shell** (sauf ceux orientes contributeurs)
- **Refactoring de la structure de fichiers** (just-in-time renommage hors scope)
- **Migration vers un autre framework de doc** (Docusaurus reste)
- **Mise en place d'une integration de traduction continue automatique** post-migration
- **Glossaire au-dela des termes du socle** (pas un dictionnaire general)

## 8. Points de Clarification

### Resolus

1. **Strategie de branche** — RESOLU 2026-04-30 : **Option A retenue**. 4 PRs successives partant de `main`, chacune sur une branche `migration-en/tier-N`, mergees independamment des leur validation. Tier 1 mergeable des vendredi soir, tier 2 samedi, tiers 3-4 dimanche. Permet rollback granulaire et capture rapide du benefice vitrine EN.

2. **Switch FR/EN dans Docusaurus** — RESOLU 2026-04-30 : **Option A retenue**. Coupe nette : le contenu FR est remplace par EN, pas de cohabitation i18n. Justification : audience FR actuelle limitee au reseau LinkedIn personnel, eviter la double-maintenance, le tag `v1.30.0` preserve la version FR pour reference historique.

3. **Exemples de code dans la doc** — RESOLU 2026-04-30 : **Option C retenue**. Hybride pragmatique : commentaires inline FR (`//`, `#`) traduits ; identifiants de variables/fonctions/classes laisses intacts ; noms de fichiers purement illustratifs (`Bouton.tsx` exemple isole) traduits si pas de dependance externe. Regle pour le harness : ne pas toucher aux identifiants pour eviter de casser des references vers du code reel ; un chantier "rename identifiers" pourra etre fait separement plus tard si besoin.

4. **Politique contributions externes en FR pendant la migration** — RESOLU 2026-04-30 : **Option A retenue**. Tolerance zero immediate. Toute PR ou issue en FR sera repondue poliment avec demande de re-soumission en EN. Justification : aligner le signal externe avec la direction "english-first" du projet ; un CONTRIBUTING.md sera mis a jour en consequence ; volume de contribs externes encore tres faible (repo public depuis 24h) donc friction minimale.

5. **Definition of done qualite tier 1** — RESOLU 2026-04-30 : **Option D retenue**. Hybride : (a) criteres automatises sur 100% du tier 1 (refs internes preservees, structure preservee, glossaire respecte, frontmatter intact) + (b) revue humaine narrative sur README + CLAUDE.md + 1 guide majeur en lecture integrale, scan rapide (titres + intro + conclusions) sur les autres guides, spot-checks aleatoires sur ~10% des rules. Budget vendredi matin : 1.5-2h. Compatible avec un lancement nuit 2 vendredi soir.

### Toutes les ambiguites prioritaires sont resolues. Les decisions sont reflectees dans les sections concernees ci-dessus. Pret pour `/work:work-plan`.

---

## Prochaine etape

`/work:work-plan "specs/migration-fr-en/spec.md"` — produire le plan d'implementation (architecture du harness, ordre des fichiers, prompts, anti-drift, decoupage PR).
