# 5. Next Steps

This roadmap distinguishes completed work from planned exercises. Mark an item complete only after performing and verifying it.

## Completed milestones

- [x] Review Proxmox CPU, memory, and storage capacity.
- [x] Install the Debian amd64 netinst ISO in Proxmox storage.
- [x] Create VM 101, `debian-services`.
- [x] Allocate 2 vCPU, 2 GiB RAM, and a 32 GiB virtual disk.
- [x] Connect the guest's VirtIO network adapter to `vmbr0`.
- [x] Install Debian 13 without a desktop environment.
- [x] Install the SSH server and connect remotely from another computer.
- [x] Enable the Proxmox QEMU Guest Agent option and reboot the VM.
- [x] Verify the VirtIO guest-agent port and running service.

See [First Debian Virtual Machine](06-first-debian-vm.md) for configuration details and troubleshooting evidence. For later work (Docker, Portainer, Uptime Kuma, Pi-hole, backups, and monitoring), see the [project README](../README.md#current-completion-checklist).

## Immediate priorities

- [ ] Confirm the guest's address and default route after a controlled reboot.
- [ ] Complete and verify Debian package upgrades.
- [x] Install Docker Engine from the official Docker Debian repository.
- [x] Install the Docker Compose plugin.
- [x] Deploy Portainer Community Edition and verify browser access.
- [ ] Record the first application deployment and its network access.

## Network services

Potential services to evaluate and deploy one at a time:

- [x] Uptime Kuma for service and host availability monitoring.
- [ ] AdGuard Home for DNS filtering (after planning DNS and recovery to avoid disrupting household connectivity).
- [ ] Samba for controlled file sharing.
- [ ] A self-hosted homepage/dashboard for lab services.

Before changing network-wide DNS, document the current router DNS settings and a rollback procedure. Keep a reliable alternative DNS path available.

## Infrastructure operations practice

- [ ] Create a VM inventory.
- [ ] Document the physical host and virtual network topology.
- [ ] Review Proxmox task history and system logs.
- [ ] Configure a backup job and test a restore.
- [ ] Review storage utilization and monitoring.
- [ ] Practice a change record and incident report.
- [ ] Test recovery after a guest reboot and a host maintenance window.

## Portfolio evidence

For each exercise, capture:

- Objective
- Environment and change made
- Commands or GUI steps
- Expected result
- Actual result
- Troubleshooting performed
- What the exercise demonstrates
- Limitations of a home-lab simulation

Do not claim production experience based solely on a home lab. Explain the skills practiced and the limits of the environment.

## Safety and security

- Do not publish passwords, tokens, private keys, or unredacted configuration files.
- Sanitize screenshots and command output before committing them.
- Avoid exposing Proxmox management or application ports directly to the public internet.
- Plan and test a rollback before changing network-wide services such as DNS.
