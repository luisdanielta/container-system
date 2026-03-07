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
}

locals {
  user_list = [for u in var.usernames : trimspace(u) if trimspace(u) != ""]

  volumes = [
    "user_data", "dind", "etc", "user_tmp",
    "user_log", "user_cache", "user_shared", "user_opt"
  ]
}

resource "docker_image" "ubuntu_local" {
  name         = "ubuntu:local"
  keep_locally = true
}

resource "docker_volume" "vols" {
  for_each = toset(local.volumes)
  name     = "ubuntu_${each.value}"
}

resource "docker_volume" "user_data" {
  for_each = toset(local.user_list)
  name     = "ubuntu_data_${each.value}"
}

# --- Service Definition ---
resource "docker_container" "ubuntu_os" {

  for_each = toset(local.user_list)
  name     = "ubuntu_os_${each.value}"

  image      = docker_image.ubuntu_local.image_id
  restart    = "unless-stopped"
  privileged = true

  ports {
    internal = 22
    external = 2220 + index(local.user_list, each.value)
  }

  # System Mappings
  dynamic "volumes" {
    for_each = {
      "/home/shared"    = docker_volume.vols["user_shared"].name
      "/tmp"            = docker_volume.vols["user_tmp"].name
      "/var/log"        = docker_volume.vols["user_log"].name
      "/var/cache"      = docker_volume.vols["user_cache"].name
      "/opt"            = docker_volume.vols["user_opt"].name
      "/var/lib/docker" = docker_volume.vols["dind"].name
      "/etc"            = docker_volume.vols["etc"].name
      # User specific mappings
      "/home/${each.value}"        = docker_volume.user_data[each.value].name
      "/home/${each.value}/.cache" = docker_volume.vols["user_cache"].name
    }
    content {
      container_path = volumes.key
      volume_name    = volumes.value
    }
  }

  # Network stack
  networks_advanced { name = "network_service" }
}
