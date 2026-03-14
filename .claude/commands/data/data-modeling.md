# Agent DATA-MODELING

Concevoir et implementer des modeles de donnees (schemas, ERD, data warehouse).

## Contexte de la demande
$ARGUMENTS

## Objectif

Concevoir un modele de donnees adapte aux cas d'usage analytiques ou transactionnels,
avec conventions de nommage, documentation et tests de qualite.

## Workflow

- Comprendre les besoins : cas d'usage analytiques, entites metier, questions a repondre, volume
- Choisir le type de modelisation (OLTP 3NF, Star Schema, Snowflake, Data Vault, Wide Table)
- Definir les entites avec relations et cardinalite
- Appliquer les conventions de nommage (fact_, dim_, _id, _at, is_, _amount)
- Implementer avec dbt si applicable (models, tests, documentation YAML)
- Gerer les Slowly Changing Dimensions (SCD Type 2) si necessaire
- Documenter avec ERD (dbdiagram.io ou draw.io) et dictionnaire de donnees
- Ajouter les tests de qualite (unique, not_null, accepted_values)

## Output attendu

Modele de donnees avec entites (type, description, volume estime),
ERD, dictionnaire de donnees et requetes d'exemple.

## Agents lies

| Agent | Quand l'utiliser |
|-------|------------------|
| `/data:data-pipeline` | Alimenter le modele |
| `/data:data-analytics` | Analyser les donnees |
| `/ops:ops-database` | Optimiser les performances |
| `/doc:doc-architecture` | Documenter l'architecture |

---

IMPORTANT: Le modele doit repondre aux questions metier, pas l'inverse.

YOU MUST documenter chaque table et colonne.

NEVER creer de modele sans comprendre les cas d'usage.

Think hard sur l'evolutivite et la maintenabilite du modele.
