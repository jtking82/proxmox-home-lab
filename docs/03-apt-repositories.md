# 3. APT Repository Configuration

## Objective

Configure working Debian and Proxmox package repositories without relying on the paid enterprise repository.

## Platform

- Proxmox VE `9.2.2`
- Debian `13` (Trixie)

## Repository configuration used

The Debian source file was configured with the Debian Trixie base, updates, and security repositories.

The Proxmox no-subscription source was created at:

```text
/etc/apt/sources.list.d/pve-no-subscription.sources
```

Its contents:

```text
Types: deb
URIs: http://download.proxmox.com/debian/pve
Suites: trixie
Components: pve-no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
```

The Proxmox enterprise repository was already disabled. The Ceph enterprise source was also disabled during setup.

## Update verification

The following command completed successfully:

```bash
apt -o Acquire::ForceIPv4=true update
```

The update output showed successful access to:

- Debian Trixie
- Debian Trixie security
- Debian Trixie updates
- Proxmox Trixie `pve-no-subscription`

The update retrieved package metadata and reported that 212 packages could be upgraded at the time.

**Important:** Updating package indexes is not the same as upgrading installed packages. A full system upgrade was intentionally not included in this setup step.

## Useful inspection commands

```bash
apt update
apt list --upgradable
```

Review proposed package changes before upgrading a hypervisor. Ensure backups and a recovery plan are in place before major updates.

## Notes

The no-subscription repository is intended for non-enterprise use and may not provide the same package testing and support assurances as the enterprise repository. Consult current Proxmox documentation before changing repositories or performing upgrades.
