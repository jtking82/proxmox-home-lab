# Proxmox Home Lab

A documented home-lab project demonstrating the installation and initial configuration of **Proxmox VE 9.2.2**, followed by deployment of a Debian virtual machine.

The goal of this repository is to show practical infrastructure skills through repeatable documentation, command-line evidence, troubleshooting notes, and incremental lab expansion.

> **Project status:** Proxmox VE is installed and its wired network is working. The first Debian 13 virtual machine is installed, reachable over SSH, and integrated with Proxmox through the QEMU Guest Agent. Docker and application services are planned next steps and are not yet claimed as completed.

## Skills demonstrated

- Installing and identifying a bare-metal hypervisor
- Working with a Debian-based Linux host
- Inspecting network interfaces and routing
- Understanding Linux bridges and physical NICs
- Configuring and validating APT repositories
- Troubleshooting a missing default route
- Provisioning a virtual machine and allocating compute/storage resources
- Installing a minimal, headless Linux server
- Configuring and using SSH for remote administration
- Troubleshooting QEMU Guest Agent device and service activation
- Verifying service state with systemd and inspecting Linux device nodes
- Documenting infrastructure changes and validation evidence

## Environment

| Item | Observed configuration |
|---|---|
| Hypervisor | Proxmox VE 9.2.2 |
| Proxmox kernel | `7.0.2-6-pve` |
| Hypervisor base OS | Debian GNU/Linux 13 (Trixie) |
| Management bridge | `vmbr0` |
| Physical Ethernet interface | `nic0` |
| Host addressing | DHCP |
| Management interface | Proxmox web UI, TCP port `8006` |
| First guest | Debian GNU/Linux 13 (Trixie), VM ID 101 |
| Guest hostname | `debian-services` |
| Guest resources | 2 vCPU, 2 GiB RAM, 32 GiB virtual disk |
| Guest networking | VirtIO network adapter attached to `vmbr0`; DHCP |
| Remote administration | SSH |
| Proxmox integration | QEMU Guest Agent running |

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
│   └── 06-first-debian-vm.md
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
- [Evidence guidance](evidence/README.md)
- [Sanitized initial validation record](evidence/initial-validation.md)

## Key troubleshooting examples

### Proxmox host default route

During network configuration, the host had an address on the LAN but initially did not show a default route. The route table later showed a default route through the LAN gateway and a connected route for the host's local subnet. Exact home-network addresses are intentionally omitted from this public repository. A sanitized example is provided in [initial validation evidence](evidence/initial-validation.md).

### QEMU Guest Agent communication device

The Debian guest initially did not contain `/dev/virtio-ports/`, so the QEMU Guest Agent service could not start because its required device dependency was unavailable. The VM's QEMU Guest Agent option was enabled in Proxmox and the VM was rebooted to apply the virtual hardware change.

After reboot, the guest exposed `/dev/virtio-ports/org.qemu.guest_agent.0`. Starting `qemu-guest-agent.service` then succeeded and systemd reported it as `active (running)`.

See [First Debian virtual machine](docs/06-first-debian-vm.md) for the procedure and verification commands.

## Repository configuration

The Proxmox host was configured to use the Proxmox `pve-no-subscription` repository and Debian Trixie repositories. The enterprise Proxmox repository was disabled. An APT metadata update completed successfully.

See [APT repository configuration](docs/03-apt-repositories.md).

## Safety and security notes

- Do not publish passwords, API tokens, private keys, backup archives, or full unredacted configuration files.
- Redact public IP addresses, serial numbers, MAC addresses, hostnames, account names, and other details you do not want public.
- Do not expose Proxmox management port `8006` directly to the public internet.
- Use strong unique passwords and keep the host and guests updated.
- Review screenshots and command output before committing them.
- Use SSH keys for routine administration when key-based access has been configured and tested.

## Current completion checklist

- [x] Proxmox VE installed
- [x] Proxmox version identified
- [x] Wired bridge configured on `vmbr0`
- [x] Host obtained a LAN address
- [x] Default gateway appeared in the route table after network reload
- [x] APT repositories configured
- [x] APT metadata update completed successfully
- [x] First Debian 13 virtual machine created and installed
- [x] Debian guest attached to `vmbr0)
- [x] SSH access from a second computer verified
- [x] QEMU Guest Agent virtual device exposed and service verified running
- [ ] Verify host network configuration after a controlled reboot
- [ ] Verify guest network configuration after a controlled reboot
- [ ] Configure Docker Engine and Docker Compose
- [ ] Deploy and document the first network service
- [ ] Add monitoring, backup, and restore exercises

## Why this project matters

This repository records hands-on work with a real hypervisor host and a virtual Linux server. It is intended as a learning log and a practical portfolio artifact—not as a claim of production data-center experience. Each milestone documents what was configured, how it was verified, what troubleshooting was required, and what remains to be tested.
