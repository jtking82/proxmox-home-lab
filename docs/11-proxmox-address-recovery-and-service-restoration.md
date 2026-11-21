# Proxmox Host Address Recovery and Guest Service Restoration

## Incident summary

During DHCP transition and troubleshooting, the Proxmox management host's address changed from the expected infrastructure address to a dynamically assigned address. The management host became unreachable at its previously used address. Investigation identified that the bridge interface `vmbr0` was configured for DHCP.

The host was restored to its intended address and the Debian services VM and Docker services were brought back online.

## Environment and symptoms

- Proxmox VE version: 9.2.2
- Management bridge: `vmbr0`
- Physical bridge port: `nic0`
- Gateway: `<LAN_GATEWAY>`
- Proxmox intended address: `<PROXMOX_STATIC_IP>/24`
- Debian services VM address: `<DEBIAN_SERVICES_IP>`

Initial symptoms included failed ping and browser access to the previously expected Proxmox address, with the client reporting destination host unreachable and ARP neighbor resolution failing. The host was subsequently located at a DHCP-assigned address.

## Diagnosis

From the Proxmox shell, these commands were used to inspect addressing and routing:

```bash
ip -br addr
ip route
cat /etc/network/interfaces
```

The output showed `vmbr0` using DHCP and the bridge connected to `nic0`. The route table showed the LAN default gateway.

## Remediation

The Proxmox management bridge was changed from DHCP to a static IPv4 configuration through the Proxmox GUI (Node → System → Network → select `vmbr0` → Edit).

Sanitized settings:

| Setting | Value |
|---|---|
| Bridge | `vmbr0` |
| IPv4/CIDR | `<PROXMOX_STATIC_IP>/24` |
| Gateway | `<LAN_GATEWAY>` |
| Bridge ports | `nic0` |
| IPv4 method | Static |

The network configuration was applied through the GUI's **Apply Configuration** action. Connectivity initially recovered gradually; subsequent ping verification returned four responses with zero packet loss and approximately 3 ms latency.

## Guest and service recovery

After restoring Proxmox management connectivity, the Debian services VM was found stopped and was started through the Proxmox interface.

The VM's Docker containers were inspected:

```bash
docker ps -a
```

The output showed Pi-hole and Uptime Kuma running and healthy, and Portainer running. Portainer's published management port was **9443** (HTTPS), not 9000 in this deployment. Access was restored using:

```
https://<DEBIAN_SERVICES_IP>:9443
```

Uptime Kuma was published on port 3001 and Pi-hole's web interface was configured on port 8081.

## Verification

- [x] Proxmox management host reachable at its restored address.
- [x] Ping verification completed with 0% packet loss after network recovery.
- [x] Debian services VM manually started.
- [x] Docker container status inspected.
- [x] Pi-hole container confirmed healthy.
- [x] Uptime Kuma container confirmed healthy.
- [x] Portainer container confirmed running.
- [x] Portainer access restored using HTTPS port 9443.

## Follow-up actions

- [ ] Ensure the Proxmox static address is excluded from the Pi-hole DHCP pool or otherwise protected from conflicting leases.
- [ ] Configure Debian services VM to start automatically with Proxmox (and confirm startup order/delay as appropriate).
- [ ] Perform a controlled reboot test and verify the host and services recover.
- [ ] Review DHCP pool boundaries and infrastructure address allocation.
- [ ] Record a sanitized network inventory and recovery procedure.

## Lessons learned

- A host using DHCP can unexpectedly change its management address when DHCP service changes.
- For infrastructure hosts, stable addressing must be planned across both the host configuration and the DHCP server's allocation range.
- DHCP should not lease infrastructure addresses that are configured statically.
- A running Docker container does not guarantee that its application was initially reachable; verify the actual published port and scheme.
- After host recovery, verify guest power state separately from host network connectivity.
- Confirm service health before recreating containers or changing configurations; in this incident, Portainer was already running once Debian was started.

Private addresses and identifiers are intentionally omitted from this public record.
