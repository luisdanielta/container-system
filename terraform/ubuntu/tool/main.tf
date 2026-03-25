terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

variable "usernames" {
  type        = list(string)
  description = "List of usernames to create in the container"
  default     = ["dev"]
}

variable "passwords" {
  type      = list(string)
  sensitive = true
  default   = ["dev"]
}

locals {
  user_list     = [for u in var.usernames : trimspace(u) if trimspace(u) != ""]
  password_list = [for i, u in var.usernames : trimspace(element(var.passwords, i)) if trimspace(u) != ""]
}

resource "docker_image" "ubuntu_tool" {
  name         = "ubuntu:tool"
  keep_locally = true
}

# --- User Volumes ---
resource "docker_volume" "user_home" {
  for_each = toset(local.user_list)
  name     = "ubuntu_home_${each.value}"
}

resource "docker_volume" "user_dind" {
  for_each = toset(local.user_list)
  name     = "ubuntu_dind_${each.value}"
}

resource "docker_volume" "user_etc" {
  for_each = toset(local.user_list)
  name     = "ubuntu_etc_${each.value}"
}

# --- Service Definition ---
resource "docker_container" "ubuntu_os" {

  for_each = toset(local.user_list)
  name     = "ubuntu_os_${each.value}_${index(local.user_list, each.value)}"

  image   = docker_image.ubuntu_tool.image_id
  restart = "unless-stopped"
  # privileged = true # Docker daemon

  # Supervisor entrypoint
  entrypoint = ["supervisord"]
  command    = ["-c", "/etc/supervisord.conf"]

  env = [
    "USERNAME=${each.value}",
    "PASSWORD=${element(local.password_list, index(local.user_list, each.value))}"
  ]

  # System
  dynamic "volumes" {
    for_each = {
      # User specific mappings
      "/home/${each.value}"       = docker_volume.user_home[each.value].name
      "/var/lib/docker"           = docker_volume.user_dind[each.value].name
      "/etc"                      = docker_volume.user_etc[each.value].name
      "/etc/ssh/user-ca-keys.pem" = abspath("${path.module}/user-ca-keys.pem")
    }

    content {
      container_path = volumes.key
      volume_name    = volumes.value
    }
  }

  # Network stack
  networks_advanced { name = "network_service" }
  dns = ["10.10.3.200"]

  # Etiquetas de Traefik dinámicas
  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.tcp.routers.${each.value}-ssh.rule"
    value = "HostSNI(`${each.value}.docker.local`)"
  }

  labels {
    label = "traefik.tcp.routers.${each.value}-ssh.entrypoints"
    value = "ssh-tls"
  }

  labels {
    label = "traefik.tcp.routers.${each.value}-ssh.tls"
    value = "true"
  }

  labels {
    label = "traefik.tcp.routers.${each.value}-ssh.tls.certresolver"
    value = "step-ca-resolver"
  }

  labels {
    label = "traefik.tcp.services.${each.value}-ssh.loadbalancer.server.port"
    value = "22"
  }
}
