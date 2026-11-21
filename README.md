# Proxmox Home Lab

A documented home-lab project demonstrating the installation and initial configuration of **Proxmox VE 9.2.2**, followed by deployment of a Debian virtual machine and a Docker-based application stack.

The goal of this repository is to show practical infrastructure skills through repeatable documentation, command-line evidence, troubleshooting notes, and incremental lab expansion. It also demonstrates self-directed learning, initiative, resourcefulness, and the ability to investigate problems, verify results, and communicate technical work clearly.

> **Project status:** Proxmox VE is installed and its wired network is working. A Debian 13 virtual machine is installed, reachable over SSH, and integrated with Proxmox through the QEMU Guest Agent. Docker Engine and Docker Compose are installed. Portainer Community Edition is deployed for container management, and Uptime Kuma is monitoring the Proxmox host, Debian guest, and Portainer endpoint. Pi-hole is now deployed for DNS filtering and DHCP. DNS blocking has been verified with direct queries, and a test phone has received a Pi-hole DHCP lease and generated queries visible in the Pi-hole Query Log. DNS verification for a second client remains in progress. Pi-hole web and DNS-port availability checks have also been added to Uptime Kuma. A DHCP-related Proxmox address change was troubleshot and the management host restored to its intended static address; guest services were brought back online.

## Skills demonstrated

- Installing and identifying a bare-metal hypervisor
- Working with a Debian-based Linux host and guest
- Inspecting network interfaces and routing
- Understanding Linux bridges and physical NICs
- Configuring and validating APT repositories
- Troubleshooting a missing default route
- Provisioning a virtual machine and allocating compute/storage resources
- Installing a minimal, headless Linux server
- Configuring and using SSH for remote administration
- Troubleshooting QEMU Guest Agent device and service activation
- Installing Docker Engine from Docker's official APT repository
- Managing Docker permissions and validating container execution
- Deploying and managing containers through Portainer Community Edition
- Using Docker Compose / Portainer Stacks
- Configuring persistent Docker volumes and published ports
- Deploying Uptime Kuma and configuring infrastructure monitors
- Inspecting Docker containers, images, volumes, and networks
- Reading container logs and using them to investigate monitoring failures
- Understanding Docker bridge networking and container-to-host port publishing
- Practicing container lifecycle management with a controlled restart
- Verifying persistent application data after a container restart
- Reading and explaining an existing Docker Compose configuration
- Troubleshooting DNS, container connectivity, and incorrect monitoring targets
- Configuring a stable IPv4 address with NetworkManager
- Deploying Pi-hole in Docker using host networking
- Configuring upstream DNS resolvers and persistent application data
- Testing DNS resolution and domain blocking with `nslookup`
- Configuring DHCP service and verifying the DHCP listener on UDP port 67
- Coordinating a DHCP handoff from a router to a self-hosted service
- Verifying client DHCP leases and DNS activity in Pi-hole
- Verifying service state and documenting results
- Configuring systemd-logind to ignore lid-close events on a laptop-based Proxmox host
- Testing headless host operation and VM reachability with the lid closed
- Monitoring Pi-hole web-interface and DNS-port availability with Uptime Kuma
- Troubleshooting monitor targets and correcting a web-monitor port mismatch

## Environment

| Item | Observed configuration |
|---|---|
| Hypervisor | Proxmox VE 9.2.2 |
| Proxmox kernel | `7.0.2-6-pve` |
| Hypervisor base OS | Debian GNU/Linux 13 (Trixie) |
| Management bridge | `vmbr0` |
| Physical Ethernet interface | `nic0` |
| Host addressing | Static IPv4 on `vmbr0` (DHCP exclusion/reservation follow-up pending) |
| Management interface | Proxmox web UI, TCP port `8006` |
| First guest | Debian GNU/Linux 13 (Trixie), VM ID 101 |
| Guest hostname | `debian-services` |
| Guest resources | 2 vCPU, 2 GiB RAM, 32 GiB virtual disk |
| Guest networking | VirtIO network adapter attached to `vmbr0`; stable IPv4 configuration |
| Remote administration | SSH |
| Proxmox integration | QEMU Guest Agent running |
| Container runtime | Docker Engine, Docker Compose plugin |
| Container management | Portainer Community Edition |
| Monitoring | Uptime Kuma with SQLite |
| DNS filtering / DHCP | Pi-hole FTL |

Actual home-network addresses, account names, and other identifying details are intentionally omitted from this public documentation.

## Repository map

```text
proxmox-home-lab/
├── README.md
├── .gitignore
├── docs/
│   ├── 01-installation-and-initial-setup.md
│   ├── 02-network-configuration.md
│   ├── 03-apt-repositories.md
│   ├── 04-validation-and-troubleshooting.md
│   ├── 05-next-steps.md
│   ├── 06-first-debian-vm.md
│   ├── 07-docker-portainer-and-monitoring.md
│   ├── 08-docker-administration-and-compose.md
│   ├── 09-pihole-dns-and-dhcp.md
│   └── 10-headless-host-and-pihole-monitoring.md
├── evidence/
│   ├── README.md
│   ├── command-output-template.md
│   └── initial-validation.md
└── scripts/
    └── collect-host-info.sh
```

## Documentation

- [Installation and initial setup](docs/01-installation-and-initial-setup.md)
- [Network configuration](docs/02-network-configuration.md)
- [APT repository configuration](docs/03-apt-repositories.md)
- [Validation and troubleshooting](docs/04-validation-and-troubleshooting.md)
- [Next steps](docs/05-next-steps.md)
- [First Debian virtual machine](docs/06-first-debian-vm.md)
- [Docker, Portainer, and monitoring deployment](docs/07-docker-portainer-and-monitoring.md)
- [Docker administration and Compose fundamentals](docs/08-docker-administration-and-compose.md)
- [Pi-hole DNS filtering and DHCP deployment](docs/09-pihole-dns-and-dhcp.md)
- [Headless host operation and Pi-hole monitoring](docs/10-headless-host-and-pihole-monitoring.md)\n- [Proxmox address recovery and service restoration](docs/11-proxmox-address-recovery-and-service-restoration.md)
- [Evidence guidance](evidence/README.md)
- [Sanitized initial validation record](evidence/initial-validation.md)

## Key troubleshooting examples

### Proxmox host default route

During network configuration, the host had an address on the LAN but initially did not show a default route. The route table later showed a default route through the LAN gateway and a connected route for the host's local subnet. Exact home-network addresses are intentionally omitted from this public repository. A sanitized example is provided in [initial validation evidence](evidence/initial-validation.md).

### Proxmox management address recovery and guest service restoration\n\nThe Proxmox host's management bridge was found configured for DHCP and had acquired an unexpected address during DHCP changes. The bridge was changed to a static address through the Proxmox GUI, and connectivity was verified with ping. The Debian services VM was found stopped and started. Docker status confirmed Pi-hole and Uptime Kuma healthy and Portainer running; Portainer access was restored using its HTTPS published port 9443. DHCP pool protection and automatic guest startup remain follow-up tasks. See [address recovery and service restoration](docs/11-proxmox-address-recovery-and-service-restoration.md).\n\n### QEMU Guest Agent communication device

The Debian guest initially did not contain `/dev/virtio-ports/`, so the QEMU Guest Agent service could not start because its required device dependency was unavailable. The VM's QEMU Guest Agent option was enabled in Proxmox and the VM was rebooted to apply the virtual hardware change.

After reboot, the guest exposed `/dev/virtio-ports/org.qemu.guest_agent.0`. Starting `qemu-guest-agent.service` then succeeded and systemd reported it as `active (running)`.

See [First Debian virtual machine](docs/06-first-debian-vm.md) for the procedure and verification commands.

### Docker image download and DNS resolution

The first `hello-world` image pull failed while resolving Docker's CloudFront download hostname. General IPv4 connectivity was available, and a later DNS lookup succeeded. Retrying `docker run hello-world` completed successfully. The incident was recorded as a transient name-resolution/download-path issue; no unverified permanent network fix is claimed.

### Uptime Kuma monitor target

The Debian host monitor initially remained pending because its configured target address was incorrect. Correcting the target to the Debian VM's actual LAN address resolved the issue. This reinforced the importance of verifying monitor targets before changing host networking or firewall settings.

### Pi-hole DNS and DHCP deployment

Pi-hole was deployed in the Debian services VM using Docker Compose and host networking. DNS filtering was verified with direct queries: a normal domain resolved successfully, while a known advertising/tracking domain returned sinkhole addresses. The Debian guest was assigned a stable IPv4 configuration, and Pi-hole's DHCP listener was verified on UDP port 67.

The router's DHCP service was disabled before Pi-hole DHCP was enabled. A test phone received a lease from Pi-hole and generated DNS requests visible in the Query Log. A second client received a lease but its DNS activity was not yet visible during the initial test; that verification remains open. See [Pi-hole DNS filtering and DHCP deployment](docs/09-pihole-dns-and-dhcp.md).

## Repository configuration

The Proxmox host was configured to use the Proxmox `pve-no-subscription` repository and Debian Trixie repositories. The enterprise Proxmox repository was disabled. An APT metadata update completed successfully.

See [APT repository configuration](docs/03-apt-repositories.md).

## Safety and security notes

- Do not publish passwords, API tokens, private keys, backup archives, or full unredacted configuration files.
- Redact public IP addresses, serial numbers, MAC addresses, hostnames, account names, and other details you do not want public.
- Do not expose Proxmox management port `8006`, Portainer's management interface, or other administrative services directly to the public internet.
- Access to the Docker socket grants powerful control over the host; restrict Portainer and Docker group membership to trusted administrators.
- Use strong unique passwords and keep the host and guests updated.
- Review screenshots and command output before committing them.
- Use SSH keys for routine administration when key-based access has been configured and tested.
- Keep only one DHCP server active on a LAN broadcast domain.
- Keep Pi-hole's administrative interface restricted to trusted users and the private network.

## Current completion checklist

- [x] Proxmox VE installed
- [x] Proxmox version identified
- [x] Wired bridge configured on `vmbr0`
- [x] Host obtained a LAN address
- [x] Default gateway appeared in the route table after network reload
- [x] APT repositories configured
- [x] APT metadata update completed successfully
- [x] First Debian 13 virtual machine created and installed
- [x] Debian guest attached to `vmbr0`
- [x] SSH access from a second computer verified
- [x] QEMU Guest Agent virtual device exposed and service verified running
- [x] Docker Engine and Docker Compose plugin installed
- [x] Docker daemon verified running
- [x] `hello-world` container executed successfully
- [x] Portainer Community Edition deployed and connected to the local Docker environment
- [x] Uptime Kuma deployed with persistent storage
- [x] Monitoring configured for the Proxmox host, Debian guest, and Portainer
- [x] All three Uptime Kuma monitors verified UP
- [x] Inspected Docker containers, images, volumes, and networks
- [x] Reviewed Uptime Kuma logs and diagnosed an incorrect monitor target
- [x] Verified Uptime Kuma's persistent volume mount
- [x] Restarted Uptime Kuma and verified it returned healthy
- [x] Confirmed all three monitors remained configured and UP after restart
- [x] Reviewed the deployed Portainer Stack Compose configuration
- [x] Configured a stable IPv4 address for the Debian services VM
- [x] Deployed Pi-hole with Docker Compose and persistent configuration
- [x] Verified normal DNS resolution through Pi-hole
- [x] Verified a known advertising/tracking domain was blocked
- [x] Added the Docker capability required for Pi-hole DHCP
- [x] Verified Pi-hole FTL listening on UDP port 67
- [x] Disabled router DHCP before enabling Pi-hole DHCP
- [x] Verified a test phone received a Pi-hole DHCP lease and generated DNS queries
- [x] Verified a second client received a DHCP lease from Pi-hole
- [ ] Confirm DNS queries from the second client appear in Pi-hole Query Log
- [ ] Verify additional clients use Pi-hole for DNS
- [ ] Review IPv6 DNS behavior
- [ ] Practice a safe command-line Compose workflow for the existing stack
- [ ] Back up and restore persistent application volumes
- [x] Configure Proxmox host to ignore lid-close events and verify headless reachability
- [x] Add Pi-hole web-interface and DNS-port availability monitors in Uptime Kuma\n- [x] Restore Proxmox host management address after DHCP address change\n- [x] Configure Proxmox bridge with a static management address\n- [x] Restore Debian services VM and verify Docker container states\n- [ ] Exclude the Proxmox static address from Pi-hole DHCP pool or create a suitable reservation\n- [ ] Configure and verify automatic startup for the Debian services VM
- [ ] Verify host and guest network configuration after a controlled reboot
- [ ] Add backup and restore exercises

## Why this project matters

This repository records hands-on work with a real hypervisor host and a virtual Linux server. It is intended as a practical learning log and portfolio artifact that demonstrates initiative, resourcefulness, systematic troubleshooting, and clear technical documentation. Each milestone documents what was configured, how it was verified, what troubleshooting was required, and what remains to be tested.
