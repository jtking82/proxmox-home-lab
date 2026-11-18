# 4. Validation and Troubleshooting

This page records the network issue encountered during initial setup and the checks used to isolate it.

## Symptom

The Proxmox host had an IPv4 address on the home LAN, but the routing table initially did not show a default route.

A host can communicate with devices on its directly connected subnet while still being unable to reach destinations outside that subnet if it has no default route.

## Network facts established

| Item | Value |
|---|---|
| LAN subnet | `192.168.1.0/24` |
| Router/default gateway | `192.168.1.254` |
| Proxmox address observed | `192.168.1.159/24` |
| Proxmox bridge | `vmbr0` |

## Diagnostic commands

```bash
ip -br addr
ip route
cat /etc/network/interfaces
```

The key distinction in the route table was the presence or absence of a line similar to:

```text
default via 192.168.1.254 dev vmbr0
```

## Resolution status

After editing the network configuration and applying it with:

```bash
ifreload -a
```

the route table showed:

```text
default via 192.168.1.254 dev vmbr0
192.168.1.0/24 dev vmbr0 proto kernel scope link src 192.168.1.159
```

The user confirmed that connectivity was working.

The precise final configuration change should be verified from the host before documenting a specific permanent route mechanism. A post-reboot test is still outstanding.

## Troubleshooting workflow learned

1. Inspect interfaces and addresses before changing configuration.
2. Identify the physical NIC and the bridge used by Proxmox.
3. Check the route table for a default gateway.
4. Verify the router's LAN address rather than guessing it.
5. Apply one controlled configuration change.
6. Re-check the route table.
7. Test the router, an external IP, and DNS separately.
8. Confirm persistence after reboot.

## Operational caution

Network changes can disconnect the Proxmox web interface. Keep local console access available when changing bridge or management network settings. Avoid unplugging cables or restarting networking without understanding the impact.
