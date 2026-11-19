# Docker Administration and Compose Fundamentals

## Overview

This milestone builds on the Docker, Portainer, and Uptime Kuma deployment documented in [07-docker-portainer-and-monitoring.md](07-docker-portainer-and-monitoring.md).

The goal was to inspect and understand the running environment, practice safe container administration, and examine the Compose configuration behind the Uptime Kuma stack. All exercises were performed against the existing lab deployment; no application data or containers were deleted.

## Environment

| Component | Observed configuration |
|---|---|
| Guest OS | Debian GNU/Linux 13 (Trixie) |
| Container runtime | Docker Engine |
| Container management | Portainer Community Edition |
| Monitoring application | Uptime Kuma |
| Uptime Kuma deployment | Portainer-managed Compose Stack |
| Persistent storage | Named Docker volume |
| Docker network | Compose-created bridge network |

Private LAN addresses, account names, container MAC addresses, and other environment-specific identifiers are intentionally omitted.

## 1. Inspect containers

List running containers:

```bash
docker ps
```

List all containers, including stopped containers:

```bash
docker ps -a
```

At the time of validation, both application containers were running:

- `uptime-kuma` — reported `healthy` by Docker's configured health check.
- `portainer` — running.

No stopped containers were present in the all-containers listing.

Useful fields in `docker ps` include:

- **CONTAINER ID:** identifier for a specific container instance.
- **IMAGE:** image used to create the container.
- **STATUS:** runtime state and, when configured, health-check state.
- **PORTS:** published host-to-container port mappings.
- **NAMES:** human-readable container name.

A running status alone does not guarantee application health. Where a health check is configured, inspect its reported state as well.

## 2. Inspect persistent volumes

List Docker volumes:

```bash
docker volume ls
```

The lab contained named volumes for Portainer and Uptime Kuma. The Uptime Kuma container's mount was inspected with:

```bash
docker inspect uptime-kuma --format '{{range .Mounts}}{{println .Name "->" .Destination}}{{end}}'
```

Observed mapping:

```text
uptime_kuma_uptime-kuma-data -> /app/data
```

This confirms that Docker mounts a named volume into Uptime Kuma's application data directory. Keeping application data in a volume allows it to outlive an individual container instance, provided the volume is retained and reattached when a replacement container is created.

**Important:** A persistent volume is not a backup. It can still be lost through deletion, disk failure, or corruption. A separate backup and restore exercise remains a future task.

## 3. Inspect container logs and troubleshoot

Read the most recent log entries:

```bash
docker logs --tail 20 uptime-kuma
```

The inspected log excerpt contained failed ping attempts to an incorrect monitoring target, including `Destination Host Unreachable`, `No route to host`, and 100% packet loss.

The underlying issue was an incorrect IP address in the Debian guest monitor configuration. The configured target was corrected to the guest's actual address, and all three monitors were subsequently observed in the **UP** state.

This incident illustrates a practical troubleshooting sequence:

1. Read the relevant application logs.
2. Identify the failing check and configured target.
3. Verify the target against the host's actual network configuration.
4. Correct the configuration.
5. Recheck service status in the monitoring application.

Do not assume that a ping failure automatically means the application or Docker daemon is broken. Verify addressing, routing, and the specific monitor configuration before making broader network changes.

## 4. Inspect local images

List locally available images:

```bash
docker image ls
```

The guest had images for:

- `hello-world:latest` — used to validate the Docker installation.
- `louislam/uptime-kuma:2` — used by the monitoring container.
- `portainer/portainer-ce:lts` — used by the Portainer container.

An image is the packaged template used to create a container. A container is an instance created from an image. Images can be shared by multiple containers; containers also have a writable layer, while named volumes are used for data that should persist independently.

Image tags such as `:2` and `:lts` identify the selected image tag. Tags can be updated by publishers, so production-style maintenance should include a deliberate update and rollback plan rather than assuming a tag always refers to an unchanged image.

## 5. Inspect Docker networks

List Docker networks:

```bash
docker network ls
```

The observed networks included Docker's built-in `bridge`, `host`, and `none` networks, plus the Compose-created `uptime_kuma_default` bridge network.

Inspect the Compose network:

```bash
docker network inspect uptime_kuma_default
```

The inspected network showed:

- Driver: `bridge`
- IPv4 subnet: `172.18.0.0/16`
- Gateway: `172.18.0.1`
- Uptime Kuma container address: `172.18.0.2`

These are Docker-internal network details, not the Debian guest's LAN address. The container has its own address on the Docker bridge. Docker publishes the application's configured host port and forwards traffic to the container port.

The network's `Containers` section showed Uptime Kuma connected to this network. The Portainer container was not listed as a member of this particular Compose network.

### Network concepts

- **bridge:** provides a private virtual network for connected containers.
- **host:** uses the host's network namespace rather than a separate container network namespace.
- **none:** disables normal container networking.
- **Compose default network:** Compose creates a project network for services unless the configuration specifies otherwise.

Do not remove Docker networks simply because they are unfamiliar. First identify which containers and Compose projects depend on them.

## 6. Practice a controlled container restart

Restart only Uptime Kuma:

```bash
docker restart uptime-kuma
```

Verify the resulting state:

```bash
docker ps
```

The container returned to a running, healthy state shortly after the restart. Portainer remained running.

The Uptime Kuma web interface was then checked. All three configured monitors remained present and showed **UP**.

This exercise verified that:

- A specific container can be restarted by name.
- The application returned to a healthy state.
- The other application container was not restarted.
- The monitoring configuration remained available after restart.

Useful lifecycle commands:

```bash
# Stop an existing container
docker stop uptime-kuma

# Start an existing stopped container
docker start uptime-kuma

# Restart an existing container
docker restart uptime-kuma

# Review all containers, including stopped ones
docker ps -a
```

These commands were documented for reference; the completed hands-on exercise was the controlled restart. A restart is different from removing a container. Do not use `docker rm` or remove a named volume as part of a routine restart.

## 7. Review the Uptime Kuma Compose configuration

The existing Portainer Stack used this Compose configuration:

```yaml
services:
  uptime-kuma:
    image: louislam/uptime-kuma:2
    container_name: uptime-kuma
    volumes:
      - uptime-kuma-data:/app/data
    ports:
      - "3001:3001"
    restart: unless-stopped

volumes:
  uptime-kuma-data:
```

### Configuration explained

| Directive | Purpose |
|---|---|
| `services` | Declares the application services Compose manages. |
| `uptime-kuma` | Name of the service in this Compose project. |
| `image` | Image repository and tag used to create the container. |
| `container_name` | Assigns the explicit container name. |
| `volumes` | Mounts persistent storage into the container. |
| `uptime-kuma-data:/app/data` | Maps the named volume to the application's data directory. |
| `ports` | Publishes the host port and forwards it to the container port. |
| `3001:3001` | Host port 3001 forwards to container port 3001. |
| `restart` | Defines the container's automatic restart policy. |
| `unless-stopped` | Restarts the container unless it has been explicitly stopped. |
| Top-level `volumes` | Declares the named volume used by the service. |

The port mapping format is `HOST_PORT:CONTAINER_PORT`. The volume mapping format is `VOLUME_NAME:CONTAINER_PATH`.

### Portainer-managed stack note

The stack was created and edited through Portainer's Web editor. Container labels identified its Compose project working directory as `/data/compose/1`. This is a path reported by the container's Compose metadata and should not be assumed to be a directly accessible path on the Debian guest.

Before attempting command-line Compose operations against a Portainer-managed stack, identify where Portainer stores and manages the stack file and how that storage is mounted. Do not create a second Compose project or run a duplicate deployment simply to practice the CLI. A future exercise can establish a safe, deliberate workflow for managing this existing stack from the command line.

## 8. Useful administration commands

```bash
# Running containers
docker ps

# All containers
docker ps -a

# Local images
docker image ls

# Named volumes
docker volume ls

# Networks
docker network ls

# Recent application logs
docker logs --tail 20 uptime-kuma

# Inspect a container's mounts
docker inspect uptime-kuma --format '{{range .Mounts}}{{println .Name "->" .Destination}}{{end}}'

# Inspect a Docker network
docker network inspect uptime_kuma_default

# Restart one container
docker restart uptime-kuma

# Compose plugin version
docker compose version
```

## 9. Skills demonstrated and verification

- [x] Inspected running containers and all container states.
- [x] Identified images used by the deployed applications.
- [x] Listed named Docker volumes.
- [x] Verified Uptime Kuma's persistent volume mount.
- [x] Read recent application logs and identified a prior monitor-target error.
- [x] Listed Docker networks and inspected the Compose bridge network.
- [x] Distinguished Docker-internal container addressing from guest LAN addressing.
- [x] Restarted Uptime Kuma without removing the container or its volume.
- [x] Verified Uptime Kuma returned to a healthy state.
- [x] Verified Portainer remained running.
- [x] Verified all three Uptime Kuma monitors remained configured and UP after restart.
- [x] Reviewed the actual Portainer Stack Compose configuration.
- [ ] Validate and operate the existing stack through a deliberate CLI Compose workflow.
- [ ] Back up the Uptime Kuma named volume.
- [ ] Perform and document a restore test.
- [ ] Practice a controlled application update and rollback procedure.

## Outcome

This session moved the lab beyond initial deployment into routine container administration. The exercises covered inspection, log-based troubleshooting, Docker networking, persistent storage, container lifecycle management, and Compose configuration literacy. The successful restart and subsequent monitoring check provided direct verification that the existing Uptime Kuma configuration survived a container restart.
