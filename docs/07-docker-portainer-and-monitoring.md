# Docker, Portainer, and Monitoring Deployment

## Overview

This milestone extends the Debian 13 virtual machine hosted on Proxmox with a Docker application environment.

The deployment includes:

- Docker Engine installed from Docker's official Debian APT repository
- Docker Compose plugin
- Portainer Community Edition for browser-based container management
- Uptime Kuma for service and host availability monitoring
- SQLite as Uptime Kuma's database
- Persistent Docker volumes for application data

Home-network addresses and account names are intentionally represented with placeholders in this public documentation.

## Environment

| Component | Configuration |
|---|---|
| Hypervisor | Proxmox VE |
| Guest OS | Debian GNU/Linux 13 (Trixie) |
| Guest hostname | `debian-services` |
| Guest resources | 2 vCPU, 2 GiB RAM, 32 GiB virtual disk |
| Container runtime | Docker Engine |
| Management UI | Portainer Community Edition |
| Monitoring | Uptime Kuma |
| Uptime Kuma database | SQLite |

Replace `<DEBIAN_VM_IP>` and `<PROXMOX_HOST_IP>` with the appropriate addresses in a private lab. Do not commit private network details unless intentionally approved for publication.

## 1. Prepare Debian

Update package metadata and installed packages:

```bash
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
```

Install repository prerequisites:

```bash
sudo apt install ca-certificates curl -y
```

Create the APT keyring directory, install Docker's official signing key, and make it readable by APT:

```bash
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

Add the Docker repository for the Debian release:

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Refresh package metadata and install Docker Engine, the CLI, container runtime, Buildx, and Compose plugin:

```bash
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

## 2. Verify Docker

Check the daemon:

```bash
sudo systemctl is-active docker
```

Expected result:

```text
active
```

Run the official test container:

```bash
sudo docker run hello-world
```

Expected result includes:

```text
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

The test verifies that the Docker client can contact the daemon, retrieve an image, create a container, and execute it.

### Optional non-root Docker access

The administrative account was added to the `docker` group:

```bash
sudo usermod -aG docker <ADMIN_USER>
```

The user then logged out and back in before testing Docker without `sudo`.

**Security note:** Membership in the Docker group grants privileges that can be used to obtain root-level control of the host. Only trusted administrators should be members.

## 3. Deploy Portainer Community Edition

Create a persistent volume:

```bash
docker volume create portainer_data
```

Deploy Portainer:

```bash
docker run -d \
  -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:lts
```

Verify the container:

```bash
docker ps
```

The Portainer web interface is available on the private lab network at:

```text
https://<DEBIAN_VM_IP>:9443
```

The initial setup flow requested a setup token, which was retrieved from the container logs:

```bash
docker logs portainer
```

The initial administrator account was then created, and the local Docker environment was confirmed as **Up**. Edge Compute setup was skipped because this lab uses a local Docker environment rather than remote edge agents.

### Portainer security considerations

- The initial HTTPS endpoint uses a self-signed certificate unless a trusted certificate is configured.
- The Portainer container mounts the Docker socket, which gives it broad control over the Docker host.
- Keep Portainer restricted to trusted users and the private lab network. Do not expose the management interface directly to the public internet.

## 4. Deploy Uptime Kuma with a Portainer Stack

A Portainer Stack was created with the name `uptime-kuma`.

The following Compose configuration was entered in Portainer's Web editor:

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

The named volume `uptime-kuma-data` preserves application data if the container is recreated. The web interface is available on the private lab network at:

```text
http://<DEBIAN_VM_IP>:3001
```

SQLite was selected during the initial Uptime Kuma setup to avoid the overhead of a separate database server on this small VM.

The deployed Uptime Kuma container reported a **Healthy** status in Docker/Portainer.

## 5. Configure availability monitors

Three monitors were configured in Uptime Kuma:

| Monitor | Type | Target |
|---|---|---|
| Debian Services | Ping | `<DEBIAN_VM_IP>` |
| Proxmox Host | Ping | `<PROXMOX_HOST_IP>` |
| Portainer | HTTP(s) | `https://<DEBIAN_VM_IP>:9443` |
| Pi-hole Web Interface | HTTP(s) | `http://<DEBIAN_VM_IP>:8081/admin/` |
| Pi-hole DNS Port | TCP Port | `<DEBIAN_VM_IP>:53` |

The Portainer HTTPS monitor may require the **Ignore TLS/SSL error** option when using the initial self-signed certificate.

The original three monitors were observed in the **UP** state after correcting the Debian monitor's target address. Pi-hole web and DNS-port checks were subsequently added and verified UP; see [Headless host operation and Pi-hole monitoring](10-headless-host-and-pihole-monitoring.md).

### Troubleshooting: Debian monitor remained pending

The Debian monitor was initially configured with an incorrect IP address. The Debian VM's actual address was confirmed using:

```bash
ip addr
ip route
```

The monitor target was corrected to the actual Debian VM address. The monitor then reported **UP**.

This is a useful troubleshooting lesson: verify the configured hostname or IP address before changing firewall, routing, or host network settings.

### Troubleshooting: Docker image download and DNS

The first `docker run hello-world` attempt reached the registry but failed while resolving a Docker CloudFront download hostname. The Docker service was active and general IPv4 connectivity was available. A subsequent DNS lookup succeeded, and retrying the same Docker command downloaded and ran the image successfully.

This is documented as a transient DNS/download-path issue; no permanent network configuration change is claimed.

## 6. Verification commands

Useful commands for ongoing administration:

```bash
# Docker service state
sudo systemctl is-active docker

# Running containers
docker ps

# All containers, including stopped ones
docker ps -a

# Local images
docker images

# Docker volumes
docker volume ls

# Portainer logs
docker logs portainer

# Uptime Kuma logs
docker logs uptime-kuma

# Compose plugin version
docker compose version

# Memory and disk capacity
free -h
df -h /
```

## 7. Outcome and next steps

### Completed

- [x] Debian package updates checked and applied
- [x] Docker official APT repository configured
- [x] Docker Engine and Compose plugin installed
- [x] Docker daemon verified active
- [x] `hello-world` image downloaded and container executed
- [x] Non-root Docker access configured for the administrative account
- [x] Portainer deployed with persistent data storage
- [x] Portainer local Docker environment verified Up
- [x] Uptime Kuma deployed through a Portainer Stack
- [x] SQLite selected for Uptime Kuma
- [x] Persistent storage configured for Uptime Kuma
- [x] Debian, Proxmox, and Portainer monitors configured
- [x] Original Debian, Proxmox, and Portainer monitors verified UP
- [x] Pi-hole web-interface and DNS-port monitors added and verified UP

### Next steps

- Add additional application containers and document their purpose and resource requirements.
- Review container logs, restart behavior, and update procedures.
- Plan and test backups of persistent application volumes.
- Perform a restore exercise and document the outcome.
- Review memory use before deploying additional services.
