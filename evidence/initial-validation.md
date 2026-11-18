# Initial Validation Evidence (Sanitized)

**Purpose:** Record the initial Proxmox installation and network validation without publishing personal or home-network details.

## Platform identification

The following platform details were verified during setup:

| Item | Verified value |
|---|---|
| Hypervisor | Proxmox VE 9.2.2 |
| Kernel | 7.0.2-6-pve |
| Base operating system | Debian GNU/Linux 13 (Trixie) |
| Management bridge | `vmbr0` |
| Physical Ethernet interface | `nic0` |
| Address assignment | DHCP |

The Proxmox VE release and kernel release are separate version identifiers.

## Network validation

The host was configured with a physical Ethernet interface attached to the Linux bridge `vmbr0`. The bridge obtained its address through DHCP.

The route table was checked after applying the network configuration. It showed:

- A default route through `vmbr0`.
- A directly connected route for the local subnet.
- The host's source address associated with the bridge.

The actual addresses are intentionally not reproduced here.

### Sanitized example route table

The following uses the documentation-only TEST-NET-1 address range. These are illustrative replacements, not the actual home-network addresses:

```text
default via 192.0.2.1 dev vmbr0
192.0.2.0/24 dev vmbr0 proto kernel scope link src 192.0.2.10
```

### Connectivity checks

The following checks were completed successfully during troubleshooting:

- Reachability to the local router/gateway.
- External IPv4 connectivity using public test destinations.
- DNS resolution and connectivity using a hostname.

Exact private addresses and full raw command output are omitted.

## APT repository validation

The Debian Trixie repositories and the Proxmox `pve-no-subscription` repository were configured. The enterprise Proxmox and Ceph repositories were disabled.

The following command completed successfully:

```bash
apt -o Acquire::ForceIPv4=true update
```

Package metadata was retrieved successfully. The output reported 212 packages available for upgrade at that time. A full system upgrade was not part of this validation and is not claimed as completed.

## Remaining verification

- [ ] Confirm the network configuration after a controlled reboot.
- [ ] Verify access to the Proxmox web interface from another computer.
- [ ] Capture a redacted screenshot of the dashboard.
- [ ] Create and validate the first virtual machine.

## Privacy and evidence notes

- No personal name, account identifier, password, public IP, MAC address, serial number, or actual home-network address is included in this record.
- The TEST-NET-1 addresses above are reserved for documentation examples.
- This record summarizes checks observed during setup; it is not a substitute for raw logs or screenshots.
