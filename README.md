# Proxmox Home Lab

A documented home-lab project demonstrating the installation and initial configuration of **Proxmox VE 9.2.2** on a dedicated host.

The goal of this repository is to show practical infrastructure skills through repeatable documentation, command-line evidence, troubleshooting notes, and future lab expansion.

> **Project status:** Proxmox VE is installed and the host's wired network connectivity is working. Reboot-persistence testing and virtual-machine deployment are planned next steps, not yet claimed as completed.

## Skills demonstrated

- Installing and identifying a bare-metal hypervisor
- Working with a Debian-based Linux host
- Inspecting network interfaces and routing
- Understanding Linux bridges and physical NICs
- Configuring and validating APT repositories
- Troubleshooting a missing default route
- Verifying local-network, internet, and DNS connectivity
- Documenting infrastructure changes and validation evidence

## Environment

| Item | Observed configuration |
|---|---|
| Hypervisor | Proxmox VE 9.2.2 |
| Proxmox kernel | `7.0.2-6-pve` |
| Base operating system | Debian GNU/Linux 13 (Trixie) |
| Management bridge | `vmbr0` |
| Physical Ethernet interface | `nic0` |
| Bridge addressing | DHCP |
| Host IPv4 address | Redacted from public documentation |
| Default gateway | Redacted from public documentation |
| LAN subnet | Redacted from public documentation |
| Management interface | Proxmox web UI, TCP port `8006` |

The address above is the address observed during configuration. If DHCP is still in use, it may change unless a reservation or static address is configured.

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
│   └── 05-next-steps.md
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
- [Evidence guidance](evidence/README.md)
- [Sanitized initial validation record](evidence/initial-validation.md)

## Key troubleshooting example: default route

During network configuration, the host had an address on the LAN but initially did not show a default route. The route table later showed a default route through the LAN gateway and a connected route for the host's local subnet. Exact home-network addresses are intentionally omitted from this public repository. A sanitized example is provided in [initial validation evidence](evidence/initial-validation.md).

This demonstrates an important troubleshooting distinction:

- A connected route allows communication with devices on the local subnet.
- A default route tells the host where to send traffic destined for other networks.

The route table was checked after applying the network configuration with:

```bash
ifreload -a
ip route
```

A reboot test is still required before treating route persistence as fully verified. See the [network notes](docs/02-network-configuration.md).

## Repository configuration

The host was configured to use the Proxmox `pve-no-subscription` repository and Debian Trixie repositories. The enterprise Proxmox repository was disabled. An APT update completed successfully.

See [APT repository configuration](docs/03-apt-repositories.md).

## Safety and security notes

- Do not publish passwords, API tokens, private keys, backup archives, or full unredacted configuration files.
- Redact public IP addresses, serial numbers, MAC addresses, hostnames, and other details you do not want public.
- Do not expose Proxmox management port `8006` directly to the public internet.
- Use a strong unique password and keep the host updated.
- Review screenshots and command output before committing them.

## Current completion checklist

- [x] Proxmox VE installed
- [x] Proxmox version identified
- [x] Wired bridge configured on `vmbr0`
- [x] Host obtained a LAN address
- [x] Default gateway appeared in the route table after network reload
- [x] APT repositories configured
- [x] APT metadata update completed successfully
- [ ] Verify network configuration after a controlled reboot
- [ ] Access the web interface from another computer
- [ ] Create and document the first virtual machine
- [ ] Add monitoring, backup, and troubleshooting exercises

## Why this project matters

This repository records hands-on work with a real hypervisor host. It is intended as a learning log and a practical portfolio artifact—not as a claim of production data-center experience.
