# 1. Installation and Initial Setup

## Objective

Install Proxmox VE on a dedicated home-lab computer and verify the installed platform.

## Installed platform

The installed system reported:

- Proxmox VE: `9.2.2`
- Proxmox kernel: `7.0.2-6-pve`
- Base operating system: Debian GNU/Linux 13 (Trixie)

The kernel version and Proxmox VE version are different identifiers. Use `pveversion -v` to identify the Proxmox release.

## Verification commands

Run these commands from the Proxmox host console:

```bash
pveversion -v
hostnamectl
uname -r
```

What they show:

- `pveversion -v`: installed Proxmox packages and release information.
- `hostnamectl`: hostname, operating system, and machine information.
- `uname -r`: currently running kernel release.

## Management interface

Proxmox is managed through a web browser from another computer on the network:

```text
https://<proxmox-host-ip>:8006
```

The actual management address is intentionally omitted from this public guide. From a trusted computer on the same management network, open `https://<proxmox-host-ip>:8006` using the address assigned to your host.

The browser may warn that the certificate is not trusted because a default/self-signed certificate is commonly used in a new lab installation. Confirm that the address is the intended local Proxmox host before proceeding.

## Evidence to add

Add redacted screenshots showing:

1. The Proxmox login page or dashboard.
2. The node summary showing the Proxmox version.
3. The host console showing `pveversion -v`.

Do not include passwords, recovery codes, tokens, or other secrets.
