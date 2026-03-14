# Spécification : Support IaC complet pour OPNsense

**Branche**: `feature/opnsense-iac`
**Date**: 2026-01-22
**Statut**: Validé

## Résumé

Ajouter au socle Claude Code la capacité de gérer un pare-feu OPNsense de manière déclarative et reproductible. L'utilisateur pourra configurer son OPNsense (interfaces réseau, règles de pare-feu, NAT, services DHCP/DNS, VPN) via du code versionné, facilitant les sauvegardes, restaurations et changements d'opérateur Internet.

## Contexte métier

Un utilisateur possédant une box opérateur (Orange, Free, etc.) souhaite :
1. Placer OPNsense derrière sa box pour un contrôle réseau avancé
2. Gérer sa configuration de manière déclarative et versionnée
3. Pouvoir changer d'opérateur sans perdre sa configuration réseau
4. Sauvegarder et restaurer sa configuration facilement

## User Stories (prioritisées)

### US1 - Provisionner une VM OPNsense sur Proxmox (Priorité: P1) MVP

**En tant qu'** administrateur réseau
**Je veux** créer une machine virtuelle OPNsense sur mon serveur Proxmox
**Afin de** déployer mon pare-feu de manière automatisée et reproductible

**Pourquoi P1**: Sans la VM, aucune autre fonctionnalité n'est possible. C'est le socle de l'infrastructure.

**Prérequis**: OPNsense doit être installé manuellement une première fois (ou cloné depuis un template existant). Le socle gère la configuration post-installation, pas l'installation initiale depuis l'ISO.

**Test indépendant**: Lancer la commande de provisioning et vérifier qu'OPNsense démarre avec accès à l'interface web.

**Critères d'acceptation**:

1. **Étant donné** un serveur Proxmox accessible avec un template OPNsense pré-installé, **Quand** j'exécute la commande de provisioning, **Alors** une VM OPNsense est créée avec les ressources spécifiées (CPU, RAM, disques, interfaces réseau).

2. **Étant donné** une VM OPNsense provisionnée, **Quand** je démarre la VM, **Alors** l'interface web d'administration est accessible sur l'IP LAN configurée.

3. **Étant donné** une configuration existante, **Quand** je modifie les paramètres de la VM (RAM, CPU), **Alors** les changements sont appliqués sans recréer la VM.

---

### US2 - Configurer les interfaces réseau OPNsense (Priorité: P1) MVP

**En tant qu'** administrateur réseau
**Je veux** définir les interfaces WAN et LAN de mon OPNsense via du code
**Afin de** configurer la connectivité réseau de base (box opérateur → OPNsense → réseau local)

**Pourquoi P1**: Les interfaces sont la base de toute configuration réseau. Sans WAN/LAN configurés, le pare-feu n'est pas fonctionnel.

**Test indépendant**: Appliquer la configuration d'interface et vérifier la connectivité WAN (ping vers Internet) et LAN (accès depuis le réseau local).

**Critères d'acceptation**:

1. **Étant donné** une VM OPNsense vierge, **Quand** j'applique une configuration d'interfaces (WAN sur le réseau de la box, LAN sur le réseau interne), **Alors** les interfaces sont configurées avec les bonnes adresses IP.

2. **Étant donné** une interface WAN configurée en DMZ derrière la box, **Quand** un appareil du LAN tente d'accéder à Internet, **Alors** le trafic est routé correctement via OPNsense puis la box.

3. **Étant donné** un changement d'opérateur (nouvelle box), **Quand** je modifie uniquement la configuration WAN, **Alors** le reste de la configuration (LAN, règles, services) reste intact.

---

### US3 - Gérer les règles de pare-feu (Priorité: P1) MVP

**En tant qu'** administrateur réseau
**Je veux** définir mes règles de filtrage réseau via du code
**Afin de** contrôler le trafic entrant et sortant de manière versionnée et auditable

**Pourquoi P1**: Les règles de pare-feu sont la fonction principale d'OPNsense. Sans elles, c'est juste un routeur.

**Test indépendant**: Créer une règle bloquant un port, puis tester que le trafic est bien bloqué.

**Critères d'acceptation**:

1. **Étant donné** un OPNsense configuré, **Quand** j'ajoute une règle autorisant le trafic HTTPS entrant vers un serveur interne, **Alors** la règle apparaît dans OPNsense et le trafic est autorisé.

2. **Étant donné** des règles existantes, **Quand** je modifie l'ordre ou le contenu d'une règle, **Alors** le changement est appliqué sans affecter les autres règles.

3. **Étant donné** une règle à supprimer, **Quand** je la retire de la configuration, **Alors** elle est supprimée d'OPNsense.

---

### US4 - Configurer le NAT et la redirection de ports (Priorité: P1) MVP

**En tant qu'** administrateur réseau
**Je veux** définir mes règles de NAT (masquerading, port forwarding) via du code
**Afin de** exposer des services internes vers l'extérieur de manière contrôlée

**Pourquoi P1**: Le NAT est essentiel pour permettre aux services internes d'être accessibles depuis Internet.

**Test indépendant**: Configurer une redirection de port et vérifier l'accès depuis l'extérieur.

**Critères d'acceptation**:

1. **Étant donné** un serveur web interne sur le port 443, **Quand** je configure une redirection du port WAN vers ce serveur, **Alors** le serveur est accessible depuis Internet via l'IP WAN.

2. **Étant donné** le NAT sortant par défaut, **Quand** un appareil du LAN accède à Internet, **Alors** son IP source est masquée par l'IP WAN d'OPNsense.

---

### US5 - Configurer les services DHCP et DNS (Priorité: P2)

**En tant qu'** administrateur réseau
**Je veux** gérer le serveur DHCP et le résolveur DNS via du code
**Afin d'** attribuer automatiquement les adresses IP et résoudre les noms sur mon réseau local

**Pourquoi P2**: Important mais pas bloquant - on peut assigner des IPs manuellement au début.

**Test indépendant**: Connecter un nouvel appareil au réseau et vérifier qu'il reçoit une IP et peut résoudre les noms.

**Critères d'acceptation**:

1. **Étant donné** un serveur DHCP configuré avec une plage d'adresses, **Quand** un nouvel appareil se connecte au LAN, **Alors** il reçoit automatiquement une IP dans la plage définie.

2. **Étant donné** des réservations DHCP définies (IP fixes par MAC), **Quand** l'appareil correspondant se connecte, **Alors** il reçoit toujours la même IP.

3. **Étant donné** un résolveur DNS configuré avec des entrées locales, **Quand** je résous un nom local, **Alors** l'IP correcte est retournée.

---

### US6 - Gérer les alias (groupes d'adresses/ports) (Priorité: P2)

**En tant qu'** administrateur réseau
**Je veux** définir des alias pour regrouper des adresses IP, réseaux ou ports
**Afin de** simplifier et rendre lisibles mes règles de pare-feu

**Pourquoi P2**: Améliore la maintenabilité mais les règles fonctionnent sans.

**Test indépendant**: Créer un alias contenant plusieurs IPs et l'utiliser dans une règle.

**Critères d'acceptation**:

1. **Étant donné** un alias de type "host" contenant plusieurs serveurs, **Quand** je l'utilise dans une règle, **Alors** la règle s'applique à tous les serveurs de l'alias.

2. **Étant donné** un alias de type "port" (ex: services web = 80, 443, 8080), **Quand** je l'utilise dans une règle, **Alors** tous les ports sont couverts.

---

### US7 - Sauvegarder et restaurer la configuration (Priorité: P2)

**En tant qu'** administrateur réseau
**Je veux** exporter et importer la configuration complète d'OPNsense
**Afin de** pouvoir restaurer rapidement en cas de problème ou migrer vers une nouvelle installation

**Pourquoi P2**: La sauvegarde est importante mais pas critique pour le fonctionnement quotidien.

**Test indépendant**: Exporter la config, modifier OPNsense manuellement, restaurer et vérifier le retour à l'état initial.

**Critères d'acceptation**:

1. **Étant donné** une configuration OPNsense complète, **Quand** je lance l'export, **Alors** un fichier de sauvegarde est généré contenant toute la configuration.

2. **Étant donné** une sauvegarde et un OPNsense vierge, **Quand** j'importe la sauvegarde, **Alors** toute la configuration est restaurée.

---

### US8 - Configurer un VPN WireGuard (Priorité: P3)

**En tant qu'** administrateur réseau
**Je veux** configurer un serveur VPN WireGuard via du code
**Afin de** permettre l'accès sécurisé à mon réseau depuis l'extérieur

**Pourquoi P3**: Fonctionnalité avancée, pas nécessaire pour le fonctionnement de base.

**Test indépendant**: Configurer le serveur WireGuard et se connecter depuis un client externe.

**Critères d'acceptation**:

1. **Étant donné** une configuration WireGuard (interface, peers), **Quand** j'applique la configuration, **Alors** le serveur VPN est actif et écoute sur le port configuré.

2. **Étant donné** un peer configuré, **Quand** le client se connecte, **Alors** il peut accéder aux ressources du LAN.

---

### US9 - Surveiller OPNsense via Prometheus (Priorité: P3)

**En tant qu'** administrateur réseau
**Je veux** collecter des métriques de mon OPNsense (trafic, CPU, connexions)
**Afin de** surveiller la santé de mon pare-feu et détecter les anomalies

**Pourquoi P3**: Le monitoring est une amélioration, pas une nécessité pour le fonctionnement.

**Test indépendant**: Configurer l'exporter et vérifier que les métriques apparaissent dans Prometheus/Grafana.

**Critères d'acceptation**:

1. **Étant donné** un exporter Prometheus configuré, **Quand** Prometheus scrape OPNsense, **Alors** les métriques (trafic interfaces, connexions actives, CPU/RAM) sont disponibles.

2. **Étant donné** des métriques collectées, **Quand** je consulte le dashboard Grafana, **Alors** je visualise l'état du pare-feu en temps réel.

---

## Exigences Fonctionnelles

### Commande `/ops-opnsense`

- **EF-001**: La commande DOIT permettre de configurer les interfaces réseau (WAN, LAN, VLANs)
- **EF-002**: La commande DOIT permettre de gérer les règles de pare-feu (création, modification, suppression)
- **EF-003**: La commande DOIT permettre de configurer le NAT (outbound, port forwarding)
- **EF-004**: La commande DOIT permettre de gérer les alias (hosts, networks, ports)
- **EF-005**: La commande DOIT permettre de configurer les services DHCP et DNS
- **EF-006**: La commande DOIT fournir des templates réutilisables pour les configurations courantes

### Agent `ops-opnsense`

- **EF-007**: L'agent DOIT être déclenché automatiquement quand l'utilisateur mentionne "OPNsense", "pare-feu", "firewall IaC"
- **EF-008**: L'agent DOIT avoir accès aux outils Read, Write, Edit, Bash, Glob, Grep
- **EF-009**: L'agent DOIT utiliser le modèle Sonnet pour les tâches complexes
- **EF-010**: L'agent DOIT inclure les skills `infrastructure-as-code` et `opnsense-configuration`

### Skill `opnsense-configuration`

- **EF-011**: Le skill DOIT être activé automatiquement sur les mots-clés : "OPNsense", "firewall", "règles pare-feu", "NAT OPNsense"
- **EF-012**: Le skill DOIT documenter les patterns de configuration courants
- **EF-013**: Le skill DOIT inclure les bonnes pratiques de sécurité

### Templates

- **EF-014**: Un template Terraform pour le provider `browningluke/opnsense` DOIT être fourni
- **EF-015**: Un module pour la configuration des interfaces DOIT être fourni
- **EF-016**: Un module pour les règles de pare-feu DOIT être fourni
- **EF-017**: Un module pour le NAT DOIT être fourni
- **EF-018**: Un exemple d'infrastructure complète "Box Orange + OPNsense + LAN" DOIT être fourni

### Intégration Proxmox

- **EF-019**: Le workflow DOIT s'intégrer avec `/ops-proxmox` pour le provisioning de la VM
- **EF-020**: La VM OPNsense DOIT supporter au minimum 2 interfaces réseau (WAN, LAN)

## Cas Limites (Edge Cases)

- **Que se passe-t-il si l'API OPNsense n'est pas accessible ?**
  → Message d'erreur clair avec instructions de diagnostic (vérifier IP, port, credentials)

- **Que se passe-t-il si on applique une règle qui coupe l'accès à OPNsense ?**
  → Recommander l'ajout d'une règle "anti-lockout" en priorité haute

- **Comment gérer les mises à jour d'OPNsense qui modifient le schéma de configuration ?**
  → Documenter les versions supportées et les breaking changes du provider Terraform

- **Que se passe-t-il si le provider Terraform échoue à mi-parcours ?**
  → Le state Terraform permet de reprendre là où on s'est arrêté (idempotence)

- **Comment gérer plusieurs OPNsense (multi-sites) ?**
  → Utiliser des workspaces Terraform ou des répertoires séparés par site

## Entités Clés

| Entité | Description | Attributs clés |
|--------|-------------|----------------|
| **Interface** | Connexion réseau physique ou virtuelle | nom, type (WAN/LAN/VLAN), IP, gateway |
| **Alias** | Groupe d'adresses, réseaux ou ports | nom, type (host/network/port), contenu |
| **Règle Firewall** | Politique de filtrage du trafic | interface, direction, action, source, destination, port |
| **Règle NAT** | Redirection ou masquage d'adresses | type (outbound/port forward), interface, cible |
| **Service DHCP** | Attribution dynamique d'adresses IP | interface, range, réservations |
| **Service DNS** | Résolution de noms | forwarders, overrides locaux |
| **VPN WireGuard** | Tunnel VPN moderne | interface, port, peers |

## Critères de Succès (mesurables)

- **CS-001**: Provisioning d'une VM OPNsense fonctionnelle en moins de 5 commandes utilisateur
- **CS-002**: Configuration complète (interfaces + firewall + NAT) reproductible depuis le code
- **CS-003**: Changement de configuration d'interface WAN sans impact sur le reste (< 2 minutes de downtime)
- **CS-004**: Restauration complète depuis une sauvegarde en moins de 15 minutes
- **CS-005**: Documentation et exemples suffisants pour qu'un utilisateur débutant puisse déployer en 1 heure

## Hors Scope (explicitement exclus)

- **Support pfSense** - OPNsense uniquement comme spécifié
- **Clustering/HA OPNsense** - Fonctionnalité avancée pour une future itération
- **Plugins OPNsense autres que WireGuard** - HAProxy, Suricata, etc. seront ajoutés plus tard
- **Configuration de la box opérateur** - Uniquement documentée, pas automatisée
- **Migration depuis pfSense** - Pas de convertisseur de configuration
- **Interface graphique/wizard** - Le socle reste CLI-first

## Hypothèses et Dépendances

### Hypothèses

- L'utilisateur dispose d'un serveur Proxmox fonctionnel (ou peut installer OPNsense autrement)
- L'utilisateur a une box opérateur avec fonction DMZ ou bridge
- L'utilisateur a des connaissances réseau de base (IP, masque, gateway)
- OPNsense version 24.1+ avec API activée

### Dépendances

- **Provider Terraform `browningluke/opnsense`** - Version stable requise
- **Provider Terraform `bpg/proxmox`** - Pour le provisioning VM (existant dans le socle)
- **API OPNsense** - Doit être activée dans System > Settings > Administration
- **Accès réseau** - La machine exécutant Terraform doit pouvoir joindre l'API OPNsense

## Clarifications

### Session 2026-01-22

- **Q: Quel outil IaC utiliser pour configurer OPNsense ?**
  → **R: Terraform uniquement** avec le provider `browningluke/opnsense`. Cohérence avec le socle existant (skills `infrastructure-as-code`, `proxmox-infrastructure`), un seul outil à maîtriser, state management intégré.

- **Q: Le socle doit-il gérer l'installation initiale d'OPNsense (ISO) ou uniquement la configuration post-installation ?**
  → **R: Post-installation uniquement**. OPNsense doit être installé manuellement une première fois (ou cloné depuis un template), puis toute la configuration est automatisée via Terraform. Documentation fournie pour créer un template Proxmox OPNsense.

- **Q: Quel niveau de granularité pour les templates de règles firewall ?**
  → **R: Basique** - Règles allow/deny par port/IP, NAT standard. Couvre les cas courants (web, SSH, VPN), facile à comprendre. Les utilisateurs avancés peuvent étendre les templates selon leurs besoins.
