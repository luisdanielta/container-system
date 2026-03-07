# Ubuntu Variants — Terraform

This directory contains Terraform modules for Ubuntu-based containers. Each subdirectory is an independent Terraform workspace.

## Directory Structure

```text
terraform/ubuntu/
├── ubuntu-local/       # Base Ubuntu container (ubuntu:local image)
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
├── go-lang/            # Go development container (go-lang:local image)
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars.example
└── python/             # Python development container (python:local image)
    ├── main.tf
    ├── variables.tf
    └── terraform.tfvars.example
```

Image dependency order: **`ubuntu:local` must exist before building `go-lang:local` or `python:local`.**

---

## Usage

### 1. Build the base image first (`ubuntu-local`)

```bash
cd ubuntu-local
terraform init
terraform apply
```

### 2. Deploy a language variant

```bash
cd go-lang
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your username, password, go_version
terraform init
terraform apply
```

---

## Port / IP Assignments

| Module        | SSH Port | Container IP  |
| ------------- | -------- | ------------- |
| `ubuntu-local` | `2220`  | `10.10.4.10`  |
| `go-lang`      | `2221`  | `10.10.4.11`  |
| `python`       | `2222`  | `10.10.4.12`  |

---

## `/etc` Volume Persistence

`VOLUME ["/etc"]` is declared in the base Dockerfile and the `etc` Docker volume is mounted at runtime.

**How it works:**
- **First boot**: Docker copies the full image `/etc` into the new volume. SSH host keys, `sshd_config`, `passwd`, `sudoers` etc. are all seeded from the image.
- **Subsequent boots**: The volume is mounted as-is. `/etc` state (user accounts, SSH config) **persists across container restarts and rebuilds**.

**User creation via `create-user.sh`** writes to `/etc/passwd`, `/etc/group`, and `/etc/sudoers.d/` — since these are inside the `/etc` volume, the user survives restarts without needing `docker exec`.

**Important caveat:** SSH config changes made in the `Dockerfile` (`RUN echo "..." >> /etc/ssh/sshd_config`) apply only at image build time and are seeded into the volume only on the **first boot** of a new volume. If you need to update SSH config after volume creation, patch it with:

```bash
docker exec ubuntu-os bash -c 'echo "AllowAgentForwarding yes" >> /etc/ssh/sshd_config && kill -HUP $(pgrep sshd)'
```

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) (v1.0+)
- Docker Engine
- External Docker networks:

```bash
docker network create network_user
docker network create network_shared
docker network create network_service
```