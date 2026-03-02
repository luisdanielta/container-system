## Network System

This document provides an overview of the network configuration managed by the `docker-compose.yml` file, detailing its structure, functionality, and intended use cases.

### Overview

The `docker-compose.yml` file orchestrates the creation and management of multiple isolated Docker networks. These networks are designed to segment different tiers or types of services within an application, enhancing security, organization, and manageability. A central `network-system` container is maintained to ensure these networks are active and configured.

### Key Components

#### Services

*   **`network-system`**:
    *   **Image**: `router:v0.1` (or built from the local `Dockerfile`).
    *   **Purpose**: This service acts as a placeholder to keep the defined Docker networks active. The `command: tail -f /dev/null` ensures the container runs indefinitely without consuming significant resources, effectively triggering the network setup.
    *   **Capabilities**: `NET_ADMIN` is added to allow the container to perform network-related operations.
    *   **Network Connections**: This service is explicitly connected to all defined networks (`file-system`, `db`, `service`, `user`, `security`, `shared`) with static IP addresses assigned to each.

#### Networks

The `docker-compose.yml` defines six distinct Docker networks, each with its own subnet, gateway, and specific bridge interface. These networks leverage a common configuration (`x-net-common`) for base settings.

*   **`file-system` Network**:
    *   **Docker Compose Network Name**: `file-system`
    *   **Bridge Name**: `br-fs`
    *   **Subnet**: `10.10.1.0/24`
    *   **Gateway**: `10.10.1.1`
    *   **Purpose**: Likely intended for services that handle file storage or access.

*   **`db` Network**:
    *   **Docker Compose Network Name**: `db`
    *   **Bridge Name**: `br-db`
    *   **Subnet**: `10.10.2.0/24`
    *   **Gateway**: `10.10.2.1`
    *   **Purpose**: Designed for database services, isolating them from other parts of the application.

*   **`service` Network**:
    *   **Docker Compose Network Name**: `service`
    *   **Bridge Name**: `br-svc`
    *   **Subnet**: `10.10.3.0/24`
    *   **Gateway**: `10.10.3.1`
    *   **Purpose**: Typically for application services or microservices that need to communicate with each other.

*   **`user` Network**:
    *   **Docker Compose Network Name**: `user`
    *   **Bridge Name**: `br-user`
    *   **Subnet**: `10.10.4.0/24`
    *   **Gateway**: `10.10.4.1`
    *   **Purpose**: Potentially for services related to user management or authentication.

*   **`security` Network**:
    *   **Docker Compose Network Name**: `security`
    *   **Bridge Name**: `br-sec`
    *   **Subnet**: `10.10.5.0/24`
    *   **Gateway**: `10.10.5.1`
    *   **Purpose**: Segregates security-sensitive components or services.

*   **`shared` Network**:
    *   **Docker Compose Network Name**: `shared`
    *   **Bridge Name**: `br-shared`
    *   **Subnet**: `10.10.6.0/24`
    *   **Gateway**: `10.10.6.1`
    *   **Purpose**: For components or services that need to be accessible across multiple segments or by multiple other services.

#### Common Network Configuration (`x-net-common`)

The `x-net-common` anchor defines a set of default configurations applied to most networks:
*   **Driver**: `bridge`
*   **MTU**: `1500`
*   **Inter-Container Communication (ICC)**: Enabled (`true`), allowing containers on the *same* bridge network to communicate by default.
*   **IP Masquerade**: Disabled (`false`), meaning containers on these networks will not automatically perform NAT for outbound traffic.
*   **IPv6 Support**: Disabled (`false`).
*   **Owner Label**: `com.example.owner: "platform"`

### Functionality

When `docker-compose up` is run, Docker processes the `docker-compose.yml` file:
1.  It creates the defined networks (`file-system`, `db`, etc.) with their specified subnets and gateways.
2.  It builds the `network-system` container from the `Dockerfile`.
3.  It starts the `network-system` container and attaches it to all defined networks with the static IP addresses specified.
4.  The `tail -f /dev/null` command keeps the `network-system` container running, which in turn keeps the networks alive.

This setup allows other services, when defined in this compose file or added manually, to be attached to these specific, segmented networks, enabling controlled communication patterns.

### Use Cases

This network configuration is well-suited for:

*   **Microservice Architectures**: Isolating different microservices into their own networks or tiers (e.g., API gateways, backend services, databases) for better security and scalability.
*   **Multi-Tiered Applications**: Clearly defining network segments for presentation, application, and data layers.
*   **Network Isolation for Security**: Restricting communication pathways between containers to only necessary connections, reducing the attack surface.
*   **Development and Testing**: Providing a consistent and reproducible network environment for development teams and automated testing.
*   **Custom Network Topologies**: Building complex network topologies within Docker that go beyond simple default bridge networks.

---

### Operational Notes

The following commands and configurations are relevant for managing and inspecting the network system:

*   **List Network Interfaces**: To view the network interfaces on the host system:
    ```bash
    ip link show
    ```
*   **Enable IP Forwarding**: To allow the host to forward IP packets, which is crucial for routing between networks (especially if this container system is acting as a gateway or router):
    ```bash
    # Edit sysctl configuration file
    sudo nano /etc/sysctl.conf

    # Add or uncomment the following line:
    # net.ipv4.ip_forward = 1

    # Apply the changes
    sudo sysctl -p
    ```
*   **Example Manual Network Creation**: This shows how a similar network could be created manually, often used for specific host-level integrations:
    ```bash
    docker network create --driver=ipvlan --subnet=192.168.1.0/24 --gateway=192.168.1.1 -o parent=enp1s0 network_lan
    ```
*   **Inspect Container IPs on a Network**: To view the IP addresses assigned to containers within a specific network (e.g., `network_service`):
    ```bash
    docker network inspect -f '{{range .Containers}}{{.Name}} {{.IPv4Address}}{{""}}{{end}}' network_service
    ```
