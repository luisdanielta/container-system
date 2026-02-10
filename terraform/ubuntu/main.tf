terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

# --- Image Build Implementation ---
resource "docker_image" "os" {
  name = "ubuntu:local"
  build {
    context    = "${path.module}/../../os/ubuntu/base" # Path to Dockerfile
    dockerfile = "Dockerfile"
    build_args = {
      ubuntu_ver     = "20.04"
      gui            = "false"
      app_essentials = "true"
      docker_app     = "true"
    }
  }
}

# --- Volumes (DRY via Locals) ---
locals {
  # Volumes requiring standard creation
  volumes = [
    "user_data", "dind", "etc", "user_tmp", 
    "user_log", "user_cache", "user_shared", "user_opt"
  ]
}

resource "docker_volume" "vols" {
  for_each = toset(local.volumes)
  name     = each.value
}

# --- Service Definition ---
resource "docker_container" "ubuntu_os" {
  name       = "ubuntu-os"
  image      = docker_image.os.image_id
  restart    = "unless-stopped"
  privileged = true
  dns        = ["10.10.4.200"]

  ports {
    internal = 22
    external = 2220
  }

  env = [
    "USERNAME=${var.username}",
    "PSWD=${var.password}"
  ]

  # System Mappings (Replacing YAML Anchors)
  dynamic "volumes" {
    for_each = {
      "/home/shared"             = docker_volume.vols["user_shared"].name
      "/tmp"                     = docker_volume.vols["user_tmp"].name
      "/var/log"                 = docker_volume.vols["user_log"].name
      "/var/cache"               = docker_volume.vols["user_cache"].name
      "/opt"                     = docker_volume.vols["user_opt"].name
      "/home/${var.username}"    = docker_volume.vols["user_data"].name
      "/home/${var.username}/.cache" = docker_volume.vols["user_cache"].name
      "/var/lib/docker"          = docker_volume.vols["dind"].name
      "/etc"                     = docker_volume.vols["etc"].name
    }
    content {
      container_path = volumes.key
      volume_name    = volumes.value
    }
  }

  # Network stack
  networks_advanced {
    name         = "network_user"
    ipv4_address = "10.10.4.10"
  }
  networks_advanced { name = "network_shared" }
  networks_advanced { name = "network_service" }
}