# Tâches : Support IaC complet pour OPNsense

**Input**: Documents de conception depuis `specs/opnsense-iac/`
**Prérequis**: plan.md (requis), spec.md (requis pour user stories)

---

## Format des tâches : `[ID] [P?] [US?] Description`

- **[P]** : Peut être exécutée en parallèle (fichiers différents, pas de dépendances)
- **[US1-US9]** : User story associée (pour traçabilité)
- Inclure les chemins de fichiers exacts dans les descriptions

---

## Phase 1 : Fondation (Infrastructure de base)

**Objectif** : Structure de fichiers et configuration provider Terraform

**⚠️ CRITIQUE** : Aucun module ne peut être créé avant la fin de cette phase

- [ ] T001 - [P] Créer le dossier `.claude/templates/opnsense/`
- [ ] T002 - [P] Créer le dossier `.claude/templates/opnsense/examples/orange-box-dmz/`
- [ ] T003 - Créer le template provider dans `.claude/templates/opnsense/provider-template.tf`
- [ ] T004 - [P] Créer `.claude/templates/opnsense/README.md` avec prérequis OPNsense (API, template VM)

**Checkpoint** : Structure prête - les modules peuvent être créés.

---

## Phase 2 : US1 - Provisionner VM OPNsense (P1) 🎯 MVP

**Objectif** : Documenter le provisioning d'une VM OPNsense sur Proxmox

**Test indépendant** : Suivre la doc pour créer un template VM OPNsense sur Proxmox

- [ ] T005 - [P] [US1] Ajouter section "Création template VM OPNsense" dans `.claude/templates/opnsense/README.md`
- [ ] T006 - [P] [US1] Créer `.claude/templates/opnsense/examples/orange-box-dmz/proxmox-vm.tf` avec configuration VM

**Checkpoint** : Documentation claire pour créer une VM OPNsense sur Proxmox.

---

## Phase 3 : US2 - Interfaces Réseau (P1) 🎯 MVP

**Objectif** : Configurer WAN et LAN via Terraform

**Test indépendant** : Appliquer la config et vérifier ping vers Internet depuis le LAN

- [ ] T007 - [P] [US2] Créer le module `.claude/templates/opnsense/interfaces-module.tf`
  - Interface WAN (DHCP ou statique)
  - Interface LAN (IP statique)
  - Variables: wan_interface, lan_interface, lan_ip, lan_subnet
- [ ] T008 - [US2] Ajouter utilisation du module interfaces dans `.claude/templates/opnsense/examples/orange-box-dmz/main.tf`

**Checkpoint** : Interfaces WAN/LAN configurables via Terraform.

---

## Phase 4 : US3 - Règles Firewall (P1) 🎯 MVP

**Objectif** : Gérer les règles de pare-feu basiques (allow/deny par port/IP)

**Test indépendant** : Créer une règle bloquant un port, vérifier que le trafic est bloqué

- [ ] T009 - [P] [US3] Créer le module `.claude/templates/opnsense/firewall-module.tf`
  - Règle anti-lockout (obligatoire)
  - Règles allow/deny par interface
  - Variables: rules (list of objects avec action, interface, source, destination, port)
- [ ] T010 - [US3] Ajouter exemples de règles courantes dans `.claude/templates/opnsense/examples/orange-box-dmz/firewall.tf`
  - Autoriser HTTP/HTTPS sortant
  - Autoriser DNS sortant
  - Bloquer tout le reste par défaut

**Checkpoint** : Règles firewall gérées par Terraform.

---

## Phase 5 : US4 - NAT et Port Forwarding (P1) 🎯 MVP

**Objectif** : Configurer NAT outbound et redirection de ports

**Test indépendant** : Configurer port forward et accéder au service depuis l'extérieur

- [ ] T011 - [P] [US4] Créer le module `.claude/templates/opnsense/nat-module.tf`
  - NAT outbound automatique
  - Port forwarding configurable
  - Variables: port_forwards (list avec external_port, internal_ip, internal_port, protocol)
- [ ] T012 - [US4] Ajouter exemples NAT dans `.claude/templates/opnsense/examples/orange-box-dmz/nat.tf`
  - Port forward SSH vers serveur interne
  - Port forward HTTP/HTTPS vers serveur web

**Checkpoint** : NAT outbound et port forwarding fonctionnels.

---

## Phase 6 : US5 & US6 - Services DHCP/DNS et Aliases (P2)

**Objectif** : Configurer DHCP, DNS, et groupes d'adresses

**Test indépendant** : Connecter un appareil, vérifier IP automatique et résolution DNS

### US5 - DHCP/DNS

- [ ] T013 - [P] [US5] Créer le module `.claude/templates/opnsense/services-module.tf`
  - Serveur DHCP avec range
  - Réservations DHCP (MAC → IP)
  - DNS resolver avec overrides locaux
  - Variables: dhcp_range_start, dhcp_range_end, dhcp_reservations, dns_overrides

### US6 - Aliases

- [ ] T014 - [P] [US6] Créer le module `.claude/templates/opnsense/aliases-module.tf`
  - Aliases type host (liste d'IPs)
  - Aliases type network (CIDR)
  - Aliases type port (liste de ports)
  - Variables: aliases (list avec name, type, content)

### Intégration

- [ ] T015 - Ajouter services et aliases dans `.claude/templates/opnsense/examples/orange-box-dmz/services.tf`

**Checkpoint** : Services réseau complets (DHCP, DNS, Aliases).

---

## Phase 7 : Intégration Socle (Command, Agent, Skill)

**Objectif** : Créer les composants d'intégration dans Claude Code

**Test indépendant** : Exécuter `/ops-opnsense` et vérifier que l'aide s'affiche

### Création des composants

- [ ] T016 - [P] Créer la commande `.claude/commands/ops/ops-opnsense.md`
  - Workflow: configurer interfaces, firewall, NAT, services
  - Référence aux templates
  - Exemples d'utilisation
- [ ] T017 - [P] Créer l'agent `.claude/agents/ops-opnsense.md`
  - Modèle: sonnet
  - Outils: Read, Write, Edit, Bash, Glob, Grep
  - Skills: infrastructure-as-code, opnsense-configuration
- [ ] T018 - [P] Créer le skill `.claude/skills/opnsense-configuration/SKILL.md`
  - Patterns de configuration courants
  - Bonnes pratiques sécurité
  - Référence provider browningluke/opnsense
  - Troubleshooting API OPNsense

### Mise à jour configuration

- [ ] T019 - Mettre à jour `CLAUDE.md` section OPS avec `/ops-opnsense`
- [ ] T020 - Mettre à jour `.claude/settings.json` avec skill opnsense-configuration

**Checkpoint** : Commande `/ops-opnsense` fonctionnelle dans le socle.

---

## Phase 8 : US7 - Backup/Restore (P2)

**Objectif** : Documenter l'export et l'import de configuration

**Test indépendant** : Exporter config, modifier manuellement, restaurer, vérifier retour état initial

- [ ] T021 - [US7] Ajouter section "Backup et Restore" dans `.claude/templates/opnsense/README.md`
  - Export via API OPNsense (curl)
  - Import via API
  - Stockage sécurisé des backups
- [ ] T022 - [US7] Créer script helper `.claude/templates/opnsense/scripts/backup.sh` (optionnel)

**Checkpoint** : Procédure de backup/restore documentée.

---

## Phase 9 : US8 & US9 - VPN WireGuard et Monitoring (P3)

**Objectif** : Documenter les fonctionnalités avancées

**Test indépendant** : Configurer WireGuard et se connecter depuis l'extérieur

### US8 - WireGuard

- [ ] T023 - [P] [US8] Ajouter section "WireGuard VPN" dans le skill `.claude/skills/opnsense-configuration/SKILL.md`
  - Configuration serveur WireGuard
  - Gestion des peers
  - Exemple Terraform (si supporté par provider)

### US9 - Monitoring Prometheus

- [ ] T024 - [P] [US9] Ajouter section "Monitoring Prometheus" dans le skill `.claude/skills/opnsense-configuration/SKILL.md`
  - Installation exporter (node_exporter ou opnsense_exporter)
  - Configuration scrape Prometheus
  - Dashboard Grafana recommandé

**Checkpoint** : Documentation avancée VPN et Monitoring.

---

## Phase 10 : Polish & Documentation Finale

**Objectif** : Finalisation et validation

- [ ] T025 - [P] Compléter `.claude/templates/opnsense/README.md` avec table des matières
- [ ] T026 - [P] Créer `.claude/templates/opnsense/examples/orange-box-dmz/README.md` avec guide pas-à-pas
- [ ] T027 - Exécuter `terraform validate` sur tous les fichiers `.tf`
- [ ] T028 - Exécuter `terraform plan` avec des mock values sur l'exemple orange-box-dmz
- [ ] T029 - Review finale du skill opnsense-configuration
- [ ] T030 - Review finale de la commande et de l'agent

**Checkpoint** : Feature prête pour merge.

---

## Dépendances et Ordre d'Exécution

### Dépendances entre phases

```
Phase 1 (Fondation)
     │
     ▼
Phase 2 (US1 - VM) ────────────────────────────────────────┐
     │                                                     │
     ▼                                                     │
Phase 3 (US2 - Interfaces) ──┬─────────────────────────────┤
     │                       │                             │
     ▼                       ▼                             │
Phase 4 (US3 - Firewall)   Phase 5 (US4 - NAT)            │
     │                       │                             │
     └───────────┬───────────┘                             │
                 │                                         │
                 ▼                                         │
          Phase 6 (US5, US6)                               │
                 │                                         │
                 └─────────────────────────────────────────┤
                                                           │
                                                           ▼
                                                    Phase 7 (Socle)
                                                           │
                                                           ├──▶ Phase 8 (US7 - Backup)
                                                           │
                                                           └──▶ Phase 9 (US8, US9)

Toutes les phases ──────────────────────────────────────▶ Phase 10 (Polish)
```

### Dépendances entre user stories

| Story | Peut commencer après | Dépendances |
|-------|---------------------|-------------|
| US1 (P1) | Phase 1 | Aucune |
| US2 (P1) | Phase 1 | Aucune (module indépendant) |
| US3 (P1) | Phase 1 | Aucune (module indépendant) |
| US4 (P1) | Phase 1 | Aucune (module indépendant) |
| US5 (P2) | Phase 1 | Peut utiliser aliases (US6) |
| US6 (P2) | Phase 1 | Aucune |
| US7 (P2) | Phase 7 | Socle intégré |
| US8 (P3) | Phase 7 | Skill créé |
| US9 (P3) | Phase 7 | Skill créé |

### Opportunités de parallélisation

**Après Phase 1**, ces tâches peuvent être exécutées en parallèle :
- T005, T006 (US1 - VM)
- T007 (US2 - Interfaces)
- T009 (US3 - Firewall)
- T011 (US4 - NAT)
- T013 (US5 - Services)
- T014 (US6 - Aliases)

**Après Phase 6**, ces tâches peuvent être exécutées en parallèle :
- T016 (Commande)
- T017 (Agent)
- T018 (Skill)

---

## Stratégie d'Implémentation

### MVP First (Phases 1-5)

1. Phase 1: Setup structure
2. Phases 2-5 en parallèle: US1, US2, US3, US4
3. **STOP et VALIDER**: Tester l'exemple orange-box-dmz minimal
4. Livrer MVP fonctionnel

### Livraison Incrémentale

```
MVP (P1)          P2                P3              Final
   │               │                 │                │
   ▼               ▼                 ▼                ▼
[VM+Interfaces] → [Services/       → [VPN/         → [Polish]
[Firewall+NAT]    Aliases/Backup]    Monitoring]
```

---

## Résumé des fichiers à créer

| Phase | Fichier | Type |
|-------|---------|------|
| 1 | `.claude/templates/opnsense/README.md` | Documentation |
| 1 | `.claude/templates/opnsense/provider-template.tf` | Template |
| 2 | `.claude/templates/opnsense/examples/orange-box-dmz/proxmox-vm.tf` | Exemple |
| 3 | `.claude/templates/opnsense/interfaces-module.tf` | Module |
| 4 | `.claude/templates/opnsense/firewall-module.tf` | Module |
| 5 | `.claude/templates/opnsense/nat-module.tf` | Module |
| 6 | `.claude/templates/opnsense/services-module.tf` | Module |
| 6 | `.claude/templates/opnsense/aliases-module.tf` | Module |
| 7 | `.claude/commands/ops/ops-opnsense.md` | Commande |
| 7 | `.claude/agents/ops-opnsense.md` | Agent |
| 7 | `.claude/skills/opnsense-configuration/SKILL.md` | Skill |
| 8 | `.claude/templates/opnsense/scripts/backup.sh` | Script |
| 10 | `.claude/templates/opnsense/examples/orange-box-dmz/README.md` | Documentation |

**Total** : 14 fichiers à créer, 2 fichiers à modifier (CLAUDE.md, settings.json)

---

## Notes

- **[P]** tâches = fichiers différents, pas de dépendances
- **[US?]** label = traçabilité vers la user story
- Chaque module Terraform doit être autonome et réutilisable
- L'exemple orange-box-dmz sert de documentation vivante
- Commit après chaque phase complète

**À éviter**:
- Modules Terraform avec dépendances circulaires
- Hardcoder des valeurs dans les modules
- Oublier la règle anti-lockout dans le firewall

---

**Version**: 1.0 | **Créé**: 2026-01-22
