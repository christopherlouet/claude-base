# =============================================================================
# Template: Infrastructure Proxmox complète
# Usage: Exemple d'infrastructure type avec VMs, LXC, réseau
# Adapter selon vos besoins
# =============================================================================

# -----------------------------------------------------------------------------
# Variables globales
# -----------------------------------------------------------------------------

variable "environment" {
  description = "Environnement (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "default_node" {
  description = "Node Proxmox par défaut"
  type        = string
  default     = "pve1"
}

variable "vm_template_id" {
  description = "ID du template VM cloud-init"
  type        = number
  default     = 9000
}

variable "lxc_template" {
  description = "Template LXC"
  type        = string
  default     = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
}

variable "ssh_public_keys" {
  description = "Clés SSH publiques autorisées"
  type        = list(string)
}

variable "network_gateway" {
  description = "Passerelle réseau"
  type        = string
  default     = "10.0.1.1"
}

variable "network_cidr" {
  description = "CIDR du réseau"
  type        = string
  default     = "10.0.1.0/24"
}

# -----------------------------------------------------------------------------
# Locals
# -----------------------------------------------------------------------------

locals {
  common_tags = [var.environment, "terraform", "managed"]

  # Configuration des VMs web
  web_servers = {
    "01" = { ip = "10.0.1.11", cores = 2, memory = 2048 }
    "02" = { ip = "10.0.1.12", cores = 2, memory = 2048 }
  }

  # Configuration des VMs API
  api_servers = {
    "01" = { ip = "10.0.1.21", cores = 4, memory = 4096 }
  }

  # Configuration des conteneurs services
  service_containers = {
    redis = { ip = "10.0.1.50", cores = 1, memory = 1024, nesting = false }
    nginx = { ip = "10.0.1.51", cores = 1, memory = 512, nesting = false }
  }
}

# -----------------------------------------------------------------------------
# VMs Web Servers
# -----------------------------------------------------------------------------

module "web_servers" {
  source   = "./modules/vm"
  for_each = local.web_servers

  name           = "${var.environment}-web-${each.key}"
  description    = "Web server ${each.key} - ${var.environment}"
  target_node    = var.default_node
  template_id    = var.vm_template_id

  cpu_cores      = each.value.cores
  memory_mb      = each.value.memory
  disk_size_gb   = 30

  network_bridge = "vmbr0"
  ip_address     = "${each.value.ip}/24"
  gateway        = var.network_gateway

  ssh_keys       = var.ssh_public_keys
  tags           = concat(local.common_tags, ["web", "frontend"])
}

# -----------------------------------------------------------------------------
# VMs API Servers
# -----------------------------------------------------------------------------

module "api_servers" {
  source   = "./modules/vm"
  for_each = local.api_servers

  name           = "${var.environment}-api-${each.key}"
  description    = "API server ${each.key} - ${var.environment}"
  target_node    = var.default_node
  template_id    = var.vm_template_id

  cpu_cores      = each.value.cores
  memory_mb      = each.value.memory
  disk_size_gb   = 50

  network_bridge = "vmbr0"
  ip_address     = "${each.value.ip}/24"
  gateway        = var.network_gateway

  ssh_keys       = var.ssh_public_keys
  tags           = concat(local.common_tags, ["api", "backend"])
}

# -----------------------------------------------------------------------------
# Conteneurs LXC Services
# -----------------------------------------------------------------------------

module "service_containers" {
  source   = "./modules/lxc"
  for_each = local.service_containers

  hostname         = "${var.environment}-${each.key}-01"
  description      = "${each.key} service - ${var.environment}"
  target_node      = var.default_node
  template_file_id = var.lxc_template
  os_type          = "ubuntu"

  cpu_cores        = each.value.cores
  memory_mb        = each.value.memory
  disk_size_gb     = 10

  network_bridge   = "vmbr0"
  ip_address       = "${each.value.ip}/24"
  gateway          = var.network_gateway

  ssh_keys         = var.ssh_public_keys
  unprivileged     = true
  nesting          = each.value.nesting

  tags             = concat(local.common_tags, ["service", each.key])
}

# -----------------------------------------------------------------------------
# VM Database (exemple avec disque additionnel)
# -----------------------------------------------------------------------------

module "database" {
  source = "./modules/vm"

  name           = "${var.environment}-db-01"
  description    = "PostgreSQL database - ${var.environment}"
  target_node    = var.default_node
  template_id    = var.vm_template_id

  cpu_cores      = 4
  memory_mb      = 8192
  disk_size_gb   = 30

  # Disque data séparé
  additional_disks = [
    {
      size         = 100
      datastore_id = "local-lvm"
      interface    = "scsi"
    }
  ]

  network_bridge = "vmbr0"
  ip_address     = "10.0.1.30/24"
  gateway        = var.network_gateway

  ssh_keys       = var.ssh_public_keys
  tags           = concat(local.common_tags, ["database", "postgresql"])
}

# -----------------------------------------------------------------------------
# Conteneur Docker Host (avec nesting)
# -----------------------------------------------------------------------------

module "docker_host" {
  source = "./modules/lxc"

  hostname         = "${var.environment}-docker-01"
  description      = "Docker host - ${var.environment}"
  target_node      = var.default_node
  template_file_id = var.lxc_template
  os_type          = "ubuntu"

  cpu_cores        = 4
  memory_mb        = 4096
  disk_size_gb     = 50

  network_bridge   = "vmbr0"
  ip_address       = "10.0.1.40/24"
  gateway          = var.network_gateway

  ssh_keys         = var.ssh_public_keys
  unprivileged     = true

  # Features pour Docker
  nesting          = true
  keyctl           = true

  tags             = concat(local.common_tags, ["docker", "container-host"])
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------

output "web_servers" {
  description = "Web servers créés"
  value = {
    for k, v in module.web_servers : k => {
      id   = v.vm_id
      name = v.name
      ip   = v.ipv4_address
    }
  }
}

output "api_servers" {
  description = "API servers créés"
  value = {
    for k, v in module.api_servers : k => {
      id   = v.vm_id
      name = v.name
      ip   = v.ipv4_address
    }
  }
}

output "service_containers" {
  description = "Conteneurs de services créés"
  value = {
    for k, v in module.service_containers : k => {
      id       = v.container_id
      hostname = v.hostname
      ip       = v.ipv4_address
    }
  }
}

output "database" {
  description = "Serveur de base de données"
  value = {
    id   = module.database.vm_id
    name = module.database.name
    ip   = module.database.ipv4_address
  }
}

output "docker_host" {
  description = "Docker host"
  value = {
    id       = module.docker_host.container_id
    hostname = module.docker_host.hostname
    ip       = module.docker_host.ipv4_address
  }
}

# -----------------------------------------------------------------------------
# Exemple de fichier terraform.tfvars pour cet environnement
# -----------------------------------------------------------------------------

# environment = "dev"
# default_node = "pve1"
# vm_template_id = 9000
# lxc_template = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
#
# ssh_public_keys = [
#   "ssh-ed25519 AAAAC3... user@workstation"
# ]
#
# network_gateway = "10.0.1.1"
# network_cidr = "10.0.1.0/24"
