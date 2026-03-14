# Plan d'implémentation : Support IaC complet pour OPNsense

**Branche**: `feature/opnsense-iac`
**Date**: 2026-01-22
**Spec**: [specs/opnsense-iac/spec.md](spec.md)
**Statut**: Validé

---

## Résumé

Ajouter au socle Claude Code une commande `/ops-opnsense`, un agent `ops-opnsense`, un skill `opnsense-configuration`, et des templates Terraform pour gérer OPNsense en Infrastructure as Code. L'approche utilise Terraform avec le provider `browningluke/opnsense` pour la configuration post-installation.

---

## Contexte Technique

| Aspect | Choix | Notes |
|--------|-------|-------|
| **Outil IaC** | Terraform | Cohérence avec le socle (skills existants) |
| **Provider OPNsense** | `browningluke/opnsense` | Seul provider Terraform mature |
| **Provider Proxmox** | `bpg/proxmox` | Déjà dans le socle |
| **Version OPNsense** | 24.1+ | API requise |
| **Scope** | Post-installation | Installation manuelle ou template |

### Contraintes

- OPNsense doit être installé manuellement avant la configuration IaC
- L'API OPNsense doit être activée (System > Settings > Administration)
- La machine exécutant Terraform doit pouvoir joindre l'API OPNsense
- Templates de règles firewall de niveau basique (allow/deny, NAT standard)

### Performance attendue

| Métrique | Cible |
|----------|-------|
| Provisioning VM + config de base | < 10 min |
| Application changement config | < 2 min |
| Restauration depuis backup | < 15 min |

---

## Vérification Constitution/Conventions

*GATE: Doit être validé avant de commencer l'implémentation.*

- [x] Respecte les conventions du projet (voir CLAUDE.md)
- [x] Cohérent avec l'architecture existante (structure commands/agents/skills)
- [x] Pas d'over-engineering (MVP basique, extensions futures)
- [x] Tests planifiés (validation terraform validate/plan)

---

## Structure du Projet

### Documentation (cette feature)

```
specs/opnsense-iac/
├── spec.md           # Spécification fonctionnelle ✅
├── plan.md           # Ce fichier
├── tasks.md          # Découpage en tâches
└── research.md       # Notes techniques (optionnel)
```

### Code Source

```
.claude/
├── commands/ops/
│   └── ops-opnsense.md           # Commande /ops-opnsense
├── agents/
│   └── ops-opnsense.md           # Agent ops-opnsense
├── skills/
│   └── opnsense-configuration/
│       └── SKILL.md              # Skill opnsense-configuration
└── templates/opnsense/
    ├── provider-template.tf      # Configuration provider
    ├── interfaces-module.tf      # Module interfaces WAN/LAN
    ├── firewall-module.tf        # Module règles firewall
    ├── nat-module.tf             # Module NAT/port forwarding
    ├── services-module.tf        # Module DHCP/DNS
    ├── aliases-module.tf         # Module aliases
    └── examples/
        └── orange-box-dmz/       # Exemple complet Box Orange + OPNsense
            ├── main.tf
            ├── variables.tf
            ├── outputs.tf
            └── README.md
```

---

## Fichiers Impactés

### À créer

| Fichier | Responsabilité |
|---------|----------------|
| `.claude/commands/ops/ops-opnsense.md` | Commande principale OPNsense IaC |
| `.claude/agents/ops-opnsense.md` | Agent délégué pour tâches OPNsense |
| `.claude/skills/opnsense-configuration/SKILL.md` | Skill avec patterns et bonnes pratiques |
| `.claude/templates/opnsense/provider-template.tf` | Template provider browningluke/opnsense |
| `.claude/templates/opnsense/interfaces-module.tf` | Module interfaces réseau |
| `.claude/templates/opnsense/firewall-module.tf` | Module règles firewall basiques |
| `.claude/templates/opnsense/nat-module.tf` | Module NAT outbound/port forward |
| `.claude/templates/opnsense/services-module.tf` | Module DHCP/DNS |
| `.claude/templates/opnsense/aliases-module.tf` | Module aliases |
| `.claude/templates/opnsense/examples/orange-box-dmz/main.tf` | Exemple infrastructure complète |
| `.claude/templates/opnsense/examples/orange-box-dmz/variables.tf` | Variables de l'exemple |
| `.claude/templates/opnsense/examples/orange-box-dmz/outputs.tf` | Outputs de l'exemple |
| `.claude/templates/opnsense/examples/orange-box-dmz/README.md` | Documentation de l'exemple |

### À modifier

| Fichier | Modification |
|---------|--------------|
| `CLAUDE.md` | Ajouter `/ops-opnsense` dans la liste des commandes OPS |
| `.claude/settings.json` | Ajouter le skill opnsense-configuration |

### Tests à ajouter

| Fichier | Couverture |
|---------|------------|
| Templates Terraform | `terraform validate` sur tous les templates |
| Exemple complet | `terraform plan` avec mock values |

---

## Approche Choisie

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   Utilisateur                                                   │
│        │                                                        │
│        ▼                                                        │
│   /ops-opnsense (Commande)                                      │
│        │                                                        │
│        ├──▶ Agent ops-opnsense (délégation)                     │
│        │         │                                              │
│        │         ├──▶ Skill opnsense-configuration              │
│        │         │         (patterns, bonnes pratiques)         │
│        │         │                                              │
│        │         └──▶ Skill infrastructure-as-code              │
│        │                   (Terraform best practices)           │
│        │                                                        │
│        └──▶ Templates Terraform                                 │
│                  │                                              │
│                  ├──▶ provider browningluke/opnsense            │
│                  │                                              │
│                  └──▶ provider bpg/proxmox (VM)                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Justification

1. **Terraform uniquement** - Cohérence avec le socle existant, un seul outil à maîtriser
2. **Post-installation** - Simplifie considérablement le scope, l'installation ISO est rarement automatisable proprement
3. **Templates modulaires** - Réutilisables et composables selon les besoins
4. **Intégration Proxmox** - Réutilise `/ops-proxmox` existant pour le provisioning VM

### Alternatives considérées

| Alternative | Pourquoi rejetée |
|-------------|------------------|
| Ansible | Complexité supplémentaire, incohérence avec le socle |
| Terraform + Ansible hybride | Over-engineering, un seul outil suffit |
| Automatisation ISO | Trop complexe, peu de valeur ajoutée vs template manuel |
| Règles firewall avancées | Scope MVP, à ajouter en itération future |

---

## Phases d'Implémentation

### Phase 1 : Fondation (bloquant)

**Objectif**: Infrastructure de base du socle pour OPNsense

- [ ] T001 - [P] Créer la structure des dossiers templates/opnsense
- [ ] T002 - [P] Créer le provider template avec configuration de base
- [ ] T003 - Documenter les prérequis OPNsense (API, template VM)

**Checkpoint**: Structure prête, les modules peuvent être créés.

### Phase 2 : US1 - VM Proxmox (P1 - MVP) 🎯

**Objectif**: Provisionner une VM OPNsense sur Proxmox

- [ ] T004 - [P] [US1] Documenter création template VM OPNsense dans README
- [ ] T005 - [P] [US1] Créer exemple de configuration Proxmox VM dans l'exemple complet

**Checkpoint**: Documentation claire pour créer une VM OPNsense.

### Phase 3 : US2 - Interfaces Réseau (P1 - MVP) 🎯

**Objectif**: Configurer WAN/LAN via Terraform

- [ ] T006 - [P] [US2] Créer le module interfaces-module.tf
- [ ] T007 - [US2] Intégrer le module dans l'exemple orange-box-dmz

**Checkpoint**: Interfaces WAN/LAN configurables via Terraform.

### Phase 4 : US3 - Règles Firewall (P1 - MVP) 🎯

**Objectif**: Gérer les règles de pare-feu via code

- [ ] T008 - [P] [US3] Créer le module firewall-module.tf (règles basiques)
- [ ] T009 - [US3] Ajouter exemples de règles courantes dans l'exemple

**Checkpoint**: Règles firewall gérées par Terraform.

### Phase 5 : US4 - NAT (P1 - MVP) 🎯

**Objectif**: Configurer NAT et port forwarding

- [ ] T010 - [P] [US4] Créer le module nat-module.tf
- [ ] T011 - [US4] Ajouter exemples NAT dans l'exemple orange-box-dmz

**Checkpoint**: NAT outbound et port forwarding fonctionnels.

### Phase 6 : US5 & US6 - Services et Aliases (P2)

**Objectif**: DHCP, DNS, et aliases

- [ ] T012 - [P] [US5] Créer le module services-module.tf (DHCP/DNS)
- [ ] T013 - [P] [US6] Créer le module aliases-module.tf
- [ ] T014 - Intégrer services et aliases dans l'exemple

**Checkpoint**: Services réseau complets.

### Phase 7 : Command, Agent, Skill

**Objectif**: Intégration dans le socle Claude Code

- [ ] T015 - [P] Créer la commande /ops-opnsense
- [ ] T016 - [P] Créer l'agent ops-opnsense
- [ ] T017 - [P] Créer le skill opnsense-configuration
- [ ] T018 - Mettre à jour CLAUDE.md avec la nouvelle commande
- [ ] T019 - Mettre à jour settings.json avec le nouveau skill

**Checkpoint**: Commande `/ops-opnsense` fonctionnelle.

### Phase 8 : US7 - Backup/Restore (P2)

**Objectif**: Export/import configuration

- [ ] T020 - [US7] Documenter la procédure de backup via API OPNsense
- [ ] T021 - [US7] Ajouter scripts helper dans l'exemple (optionnel)

**Checkpoint**: Procédure de backup documentée.

### Phase 9 : US8 & US9 - VPN et Monitoring (P3)

**Objectif**: WireGuard et Prometheus

- [ ] T022 - [P] [US8] Ajouter section WireGuard au skill (documentation)
- [ ] T023 - [P] [US9] Ajouter section Prometheus au skill (documentation)

**Checkpoint**: Documentation avancée complète.

### Phase 10 : Polish & Documentation

**Objectif**: Finalisation

- [ ] T024 - [P] README complet pour templates/opnsense
- [ ] T025 - [P] Validation terraform validate sur tous les templates
- [ ] T026 - Tests terraform plan avec mock values
- [ ] T027 - Review finale et ajustements

**Checkpoint**: Feature prête pour merge.

---

## Risques et Mitigations

| Risque | Impact | Probabilité | Mitigation |
|--------|--------|-------------|------------|
| Provider browningluke/opnsense instable | Élevé | Faible | Tester sur version stable, documenter versions supportées |
| API OPNsense change entre versions | Moyen | Moyenne | Documenter version OPNsense testée, suivre changelog |
| Règle firewall coupe l'accès | Élevé | Moyenne | Documenter règle anti-lockout obligatoire |
| Complexité configuration réseau | Moyen | Moyenne | Exemples clairs, documentation détaillée |

---

## Dépendances et Ordre d'Exécution

### Dépendances entre phases

```
Phase 1 (Fondation) ──┬──▶ Phase 2 (US1 - VM)
                      │
                      ├──▶ Phase 3 (US2 - Interfaces)
                      │
                      ├──▶ Phase 4 (US3 - Firewall)
                      │
                      └──▶ Phase 5 (US4 - NAT)

Phases 3, 4, 5 ────────▶ Phase 6 (US5, US6 - Services, Aliases)

Phases 2-6 ────────────▶ Phase 7 (Command, Agent, Skill)

Phase 7 ───────────────▶ Phase 8 (US7 - Backup)
                      │
                      └──▶ Phase 9 (US8, US9 - VPN, Monitoring)

Toutes les phases ────▶ Phase 10 (Polish)
```

### Tâches parallélisables

- **[P]** indique qu'une tâche peut être exécutée en parallèle
- Les modules Terraform (T006, T008, T010, T012, T013) sont indépendants
- La commande, l'agent et le skill (T015, T016, T017) peuvent être créés en parallèle

---

## Critères de Validation

### Avant de commencer (Gate 1)
- [x] Spec approuvée
- [x] Plan reviewé
- [ ] Provider browningluke/opnsense testé manuellement

### Avant chaque merge (Gate 2)
- [ ] `terraform validate` passe sur tous les templates
- [ ] Documentation à jour
- [ ] Exemples fonctionnels

### Avant déploiement (Gate 3)
- [ ] Tous les critères de succès de la spec vérifiés (CS-001 à CS-005)
- [ ] Documentation utilisateur complète
- [ ] Exemple orange-box-dmz testé en conditions réelles

---

## Notes

### Provider browningluke/opnsense

- GitHub: https://github.com/browningluke/terraform-provider-opnsense
- Documentation: https://registry.terraform.io/providers/browningluke/opnsense/latest/docs
- Ressources supportées: interfaces, firewall rules, NAT, aliases, DHCP, DNS, WireGuard

### Configuration API OPNsense

1. Se connecter à OPNsense (https://<ip>/ui/)
2. System > Settings > Administration
3. Activer "Enable API"
4. System > Access > Users > Créer user API avec clés

### Box Orange en DMZ

1. Accéder à la Livebox (192.168.1.1)
2. Réseau > NAT/PAT > DMZ
3. Activer DMZ vers l'IP WAN d'OPNsense
4. OPNsense reçoit tout le trafic entrant

---

**Version**: 1.0 | **Créé**: 2026-01-22 | **Dernière modification**: 2026-01-22
