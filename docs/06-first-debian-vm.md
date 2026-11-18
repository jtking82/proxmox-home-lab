# 6. First Debian Virtual Machine

## Objective

Provision a minimal Debian server as the first guest on the Proxmox hypervisor, establish remote administration over SSH, and enable communication between the guest and Proxmox using the QEMU Guest Agent.

This is a home-lab exercise focused on practical infrastructure skills. It demonstrates VM provisioning and Linux administration while providing a record of independent learning, troubleshooting, and verification.

## Guest configuration

| Setting | Configuration |
|---|---|
| VM ID | 101 |
| VM name / guest hostname | `debian-services` |
| Operating system | Debian GNU/Linux 13 (Trixie), amd64 |
| Installation media | Debian netinst ISO |
| Firmware | SeaBIOS |
| CPU | 2 virtual cores |
| Memory | 2 GiB |
| Virtual disk | 32 GiB on Proxmox `local-lvm` |
| Network model | VirtIO |
| Network bridge | `vmbr0` |
| Address assignment | DHCP |
| Guest software selection | SSH server and standard system utilities; no desktop environment |

The guest's actual IP address and the home network's addressing details are intentionally excluded from this public record.

## Installation procedure

1. Confirm available Proxmox storage before creating the VM.
2. Download the Debian amd64 netinst ISO to Proxmox ISO storage.
3. Create VM 101 with the resource allocation listed above.
4. Attach its virtual network adapter to `vmbr0`.
5. Install Debian using guided partitioning on the VM's virtual disk.
6. Configure the package manager to use the Debian network mirror; leave the HTTP proxy blank when no proxy is used.
7. Select only **SSH server** and **standard system utilities** in software selection. Do not install a desktop environment.
8. Install GRUB to the VM's primary virtual disk and reboot.
9. Log in with the regular administrative account created during installation.

**Disk safety:** Guided partitioning was performed only on the virtual disk assigned to VM 101, not on the physical Proxmox host disk.

## Initial guest administration

Refresh package metadata:

```bash
sudo apt update
```

The package metadata update completed successfully.

A package upgrade was attempted during initial setup. This record does not claim that the full upgrade completed; confirm package state separately before treating the guest as fully updated.

## Remote administration with SSH

The Debian installer was configured to install the SSH server. From a separate Linux computer on the same network, connect using the guest's DHCP address:

```bash
ssh <guest-user>@<guest-ip>
```

On the first connection, SSH displays the server's host-key fingerprint and asks whether to trust it. Verify the fingerprint through a trusted channel when practical, then accept the key. Authenticate with the guest account password.

Successful login to the `debian-services` shell confirmed remote SSH access. The actual username and IP address are omitted from this public document.

## QEMU Guest Agent integration

### Initial symptom

The QEMU Guest Agent package was installed in Debian, but the service did not start. The journal reported a dependency failure:

```text
Dependency failed for qemu-guest-agent.service
qemu-guest-agent.service: Job ... failed with result 'dependency'
```

The guest did not initially have the expected VirtIO port directory:

```bash
ls -l /dev/virtio-ports/
```

The command reported that `/dev/virtio-ports/` did not exist.

### Root cause and corrective action

The QEMU Guest Agent communication device had not yet been exposed to the guest.

1. In the Proxmox web interface, select VM 101.
2. Open **Options** and edit **QEMU Guest Agent**.
3. Enable **Use QEMU Guest Agent** and save the setting.
4. Reboot the VM so the virtual hardware change is applied.
5. Reconnect to Debian over SSH.

### Verification

After reboot, the following device appeared:

```text
/dev/virtio-ports/org.qemu.guest_agent.0
```

The service was then started:

```bash
sudo systemctl start qemu-guest-agent
systemctl status qemu-guest-agent --no-pager
```

The observed service state was:

```text
Active: active (running)
```

The unit is reported by systemd as **static**. That is expected for this packaged service; it does not need to be enabled with `systemctl enable` in this setup. Starting it after the virtual device became available succeeded.

## Useful verification commands

Run these from the Debian guest:

```bash
hostname
ip -br addr
ip route
systemctl --failed
systemctl status ssh --no-pager
systemctl status qemu-guest-agent --no-pager
ls -l /dev/virtio-ports/
```

These checks identify the guest, inspect network addressing and routes, show failed systemd units, and verify SSH and guest-agent status.

## Outcome

Completed and verified:

- Debian 13 guest installed without a desktop environment.
- VM network adapter attached to the Proxmox bridge.
- Remote SSH login from another computer.
- QEMU Guest Agent communication device appeared after enabling the Proxmox option and rebooting.
- QEMU Guest Agent service reached `active (running)`.

Not yet completed:

- Docker Engine and Docker Compose installation.
- Deployment of application or network services.
- Guest backup and restore testing.
- Long-term reboot and service-persistence validation.

## Skills practiced

- Virtual machine provisioning and resource allocation
- Debian installation and package management
- Headless Linux server administration
- SSH remote access
- systemd service inspection and troubleshooting
- VirtIO device verification
- Proxmox-to-guest integration
- Change validation and technical documentation

## Home-lab limitations

This exercise uses a single home hypervisor and a single guest. It does not demonstrate redundant infrastructure, enterprise change control, production incident response, or physical hardware replacement procedures. It does provide repeatable practice with virtualization, Linux administration, remote access, systematic troubleshooting, and documenting technical work.
