# User Maintainer
## Modular Maintenance Environment
This system defines a reproducible and isolated maintenance environment using Docker containers. Its purpose is to enable technical operations on volumes, host sockets, or mounted disks without directly relying on the host operating system. It is designed to ensure traceability, and a clear separation of privileges—essential aspects in distributed workflows.

### Overview
The `maintainer:local` container is built on an intermediate image called `ubuntu:local`, which serves as a reusable base for structured user management. From this base, an enriched environment is created with an interactive shell and a custom user with controlled privileges. Additionally, the maintainer has access to critical host system interfaces such as the Docker socket and physical disks. This approach supports a modular architecture where each container represents a controlled environment for maintenance tasks, automated scripting, or secure resource inspection.

## 1. Building the Maintainer Image
The main image `maintainer:local` is built. It includes maintenance tools and access to the Docker group:

```bash
docker build -t maintainer:local .
```

A direct interactive session can be launched:

```bash
docker run -it --rm \
  -v maintainer:/home/maintainer \
  -v ubuntu_user_shared:/home/shared \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /mnt:/mnt \
  maintainer:local
```

## 2. Running the Container
The container can be run using Docker Compose:

```bash
docker-compose up --build
```

### Technical Components
**1. maintainer**
This container creates a non-root user defined via environment variables (UID/GID) and mounts the following volumes:

* Persistent user environment (`/home/maintainer`)
* Shared space with other services or containers (`/home/shared`)
* Communication with the Docker daemon via its socket (`/var/run/docker.sock`)
* Access to host-mounted directories or physical disks (`/mnt`)

3. Configuración del servidor SSH

En el servidor / contenedor, edita:

/etc/ssh/sshd_config

Asegúrate de tener:
AllowAgentForwarding yes
PubkeyAuthentication yes


Reinicia SSH:
service ssh restart

sudo nano /etc/docker/daemon.json

sudo systemctl restart docker