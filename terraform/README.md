https://developer.hashicorp.com/terraform/install#linux

- precompliled_binary

/usr/local/bin/

nano ~/.bashrc
alias tf='terraform'
source ~/.bashrc

# Ubuntu Development Environment via Terraform

This project automates the deployment of a customized **Ubuntu-based development environment** using Terraform and Docker. It replaces traditional Docker Compose setups with a more robust **Infrastructure as Code (IaC)** approach, featuring automated builds and dynamic volume management.

## Architecture Overview

The setup consists of:

* **Custom Ubuntu Image**: Built from a local `Dockerfile` with support for SSH, Sudo, Docker-in-Docker (DinD), and essential development tools.
* **Persistent Storage**: 8 managed Docker volumes for logs, cache, and user data.
* **Network Integration**: Connects to three pre-existing external networks (`network_user`, `network_shared`, `network_service`).
* **Dynamic Configuration**: Uses Terraform `dynamic` blocks to map volumes and environment variables without repeating code (DRY).

---

## Project Structure

```text
.
├── os/
│   └── ubuntu/
│       ├── Dockerfile          # System definition (SSH, Docker, Tools)
│       └── supervisord.conf    # Process manager configuration
├── terraform/
│   └── ubuntu/
│       ├── main.tf             # Primary logic (Image, Volumes, Container)
│       ├── variables.tf        # Input definitions
│       └── terraform.tfvars    # Local secrets (ignored by git)
└── README.md

```

---

## Getting Started

### 1. Prerequisites

* [Terraform](https://developer.hashicorp.com/terraform/downloads) (v1.0+)
* [Docker Engine](https://docs.docker.com/get-docker/) installed and running.
* The following external networks created in Docker:
```bash
docker network create network_user
docker network create network_shared
docker network create network_service

```

### 2. Configuration

Create a `terraform.tfvars` file in the `terraform/ubuntu/` directory to store your credentials:

```hcl
username = "your_user"
password = "your_secure_password"

```

### 3. Deployment

Navigate to the terraform directory and run:

```bash
# Initialize Terraform and download providers
terraform init

# Preview the infrastructure changes
terraform plan

# Apply the configuration
terraform apply

```

---

## Technical Details

### Image Customization

The image is built with several `build_args` defined in Terraform:

* `ubuntu_ver`: 20.04 (Default)
* `app_essentials`: Installs `curl`, `git`, `nano`, `htop`, etc.
* `docker_app`: Installs the Docker CLI and Engine inside the container.

### Volume Mapping (DRY)

Instead of manual mapping, this project uses a `for_each` map to handle system volumes. This ensures that adding a new mount point only requires adding a single line to the `locals` block.

| Host Volume | Container Path | Purpose |
| --- | --- | --- |
| `user_shared` | `/home/shared` | Shared files between environments |
| `user_data` | `/home/${var.username}` | Persistent user home directory |
| `dind` | `/var/lib/docker` | Docker-in-Docker storage |

### Security Note

The `password` variable is marked as `sensitive`. This prevents the password from being displayed in clear text in the terminal output or stored in plain text within the `terraform.tfstate` logs where possible.

---

## Maintenance

* **Update Image**: If you modify the `Dockerfile`, running `terraform apply` will automatically detect the change, rebuild the image, and recreate the container.
* **Destroy**: To remove the container and volumes, run `terraform destroy`.

terraform apply -target=docker_image.os