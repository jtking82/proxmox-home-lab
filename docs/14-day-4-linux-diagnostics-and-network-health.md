# Day 4 — Linux Server Diagnostics and Service/Network Health Assessment

## Scope

Performed read-only diagnostic checks on a Debian 13 virtual server hosted in a home lab. The exercises focused on logs, thermal visibility, storage utilization, service health, listening sockets, firewall policy, IPv6 connectivity, and application-level HTTP tests.

> **Privacy:** Specific home-network addresses and other identifying network details are intentionally omitted.

## Environment and limitations

- Debian Linux guest running under QEMU/KVM virtualization.
- Docker workloads include Pi-hole, Uptime Kuma, and Portainer.
- Netdata is installed for monitoring.
- Virtualized hardware limits physical sensor visibility; this exercise does not establish physical rack, server, HVAC, or BMC telemetry capability.

## Investigation and findings

### 1. Kernel and system logs

Reviewed system journal warnings and kernel errors.

- Observed repeated systemd SSH-generator AF_VSOCK CID errors in the VM.
- Based on the virtualized environment and lack of evidence of a relevant host service failure, these were assessed as likely environment-related rather than proof of hardware failure.
- Reviewed a disk reset message in the boot log; the subsequent device enumeration and attachment sequence did not provide evidence of disk failure by itself.
- Journal warnings were interpreted in context rather than treated automatically as faults.

### 2. Thermal sensor visibility

- Installed `lm-sensors` and ran `sensors`.
- No sensors were detected.
- Inspected `/sys/class/thermal`; only virtual cooling devices were exposed, without usable temperature zones.
- Conclusion: this VM cannot demonstrate physical temperature/fan monitoring. Lack of sensor data here is a virtualization limitation, not evidence of a physical server overheating.

### 3. Storage capacity and consumption

Commands used:

```bash
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL
df -h
sudo du -xhd1 / 2>/dev/null | sort -h
sudo du -xhd1 /var 2>/dev/null | sort -h
sudo du -xhd1 /var/cache 2>/dev/null | sort -h
sudo du -xhd1 /var/cache/apt 2>/dev/null | sort -h
sudo du -xhd1 /var/lib 2>/dev/null | sort -h
sudo du -xhd1 /var/lib/containerd 2>/dev/null | sort -h
```

Findings:

- Root filesystem was approximately 39% utilized at the time of inspection.
- Identified large consumers under `/var`, including APT package archives, Netdata metric-history/cache storage, and containerd content/snapshot storage.
- APT archives contained accumulated downloaded package files.
- Netdata cache included metric-history storage; it was not assumed to be disposable.
- containerd content and overlay snapshots were associated with container runtime storage; internal files were not manually removed.

Docker accounting:

```bash
sudo docker system df
sudo docker ps -a
```

- Four images, three active; image storage approximately 2.885 GB.
- Three containers active; writable container storage approximately 115.8 MB.
- Two active local volumes; approximately 6.552 MB.
- No build cache.
- Docker reported negligible reclaimable storage; no cleanup was performed.

### 4. Service health

```bash
sudo systemctl --failed
systemctl status ssh --no-pager
sudo systemctl -l status ssh --no-pager
```

- No systemd units were reported failed.
- SSH was enabled and active (running).
- SSH logs showed successful authentications and sessions from the home-lab client. Addresses are omitted from this public report.
- A permission-related journal warning from the non-privileged status command was resolved by viewing the status with elevated privileges; it was not an SSH service failure.

### 5. Listening sockets

```bash
sudo ss -tulpn
```

Identified listeners associated with SSH, Pi-hole DNS and related services, Uptime Kuma, Portainer, Netdata, local monitoring plugins, and other system services.

- Reviewed bind addresses such as loopback (`127.0.0.1` / `::1`) versus broad bind addresses (`0.0.0.0` / `[::]`).
- Identified that several service sockets were bound broadly, requiring consideration of network and firewall controls.
- A listening socket alone does not prove external reachability.

### 6. Firewall inspection

UFW was not installed. This was not treated as proof that no firewall rules existed.

Read-only inspection:

```bash
sudo nft list ruleset
sudo iptables -S
sudo ip6tables -S
```

Findings:

- nftables showed Docker-managed NAT and forwarding rules through the iptables-nft integration.
- IPv4 forwarding policy was DROP, with Docker-managed exceptions.
- IPv4 INPUT default policy was ACCEPT.
- IPv6 INPUT, FORWARD, and OUTPUT default policies were ACCEPT in the inspected ip6tables rules.
- Docker's DOCKER-USER chain had no custom rules in the inspected ruleset.
- The host INPUT policy is distinct from Docker's FORWARD handling for container traffic.

**Security observation:** The host's inbound filtering policies were permissive by default in the inspected rules. This does not alone prove internet reachability; upstream router/firewall controls, network isolation, and routing must also be assessed. No firewall changes were made because this server runs services and any change should be planned, validated, and performed with appropriate access safeguards.

### 7. IPv6 configuration and connectivity

```bash
ip -br addr
ip -6 route
ping -6 -c 3 <external IPv6 destination>
```

- The primary interface had global IPv6 addresses in addition to link-local addressing.
- An IPv6 default route was present, learned through Router Advertisement.
- An outbound IPv6 ping test succeeded.

**Security observation:** Global IPv6 addressing, a default route, and a permissive IPv6 host INPUT policy make upstream IPv6 firewall policy important to verify. Unsolicited inbound external reachability was not tested and is not claimed.

### 8. Application-level HTTP tests

Netdata:

```bash
curl -I http://127.0.0.1:19999
curl -sS -o /dev/null -w "HTTP status: %{http_code}\n" http://127.0.0.1:19999/
```

- The HEAD request returned HTTP 400.
- A subsequent GET request returned HTTP 200.
- The 400 response was not interpreted as service failure; the request method mattered.

Uptime Kuma:

```bash
curl -sS -o /dev/null -w "HTTP status: %{http_code}\n" http://127.0.0.1:3001/
```

- Returned HTTP 302, indicating a redirect response rather than a connection failure.

## Troubleshooting method practiced

1. Gather evidence using read-only commands.
2. Identify the layer involved (hardware/virtual hardware, storage, service, network socket, routing, firewall, or application).
3. Interpret results in context; distinguish warnings and unusual output from confirmed faults.
4. Verify the next hypothesis with a targeted test.
5. Avoid cleanup or configuration changes until the impact and risk are understood.
6. Record limitations and unverified conditions explicitly.

## Commands practiced

```bash
sudo journalctl -k -p err --no-pager
sudo journalctl -b -p warning --no-pager
lsblk
df -h
sudo du -xhd1 / 2>/dev/null | sort -h
sudo docker system df
sudo docker ps -a
sudo systemctl --failed
systemctl status ssh --no-pager
sudo ss -tulpn
sudo nft list ruleset
sudo iptables -S
sudo ip6tables -S
ip -br addr
ip -6 route
curl -I http://127.0.0.1:19999
curl -sS -o /dev/null -w "HTTP status: %{http_code}\n" http://127.0.0.1:19999/
curl -sS -o /dev/null -w "HTTP status: %{http_code}\n" http://127.0.0.1:3001/
```

## Home-lab versus production

This lab demonstrates Linux command-line diagnostics, service checks, storage analysis, container inventory, socket inspection, firewall-rule interpretation, IPv6 routing awareness, and HTTP validation.

It does **not** demonstrate physical server hardware replacement, rack operations, BMC telemetry, calibrated temperature measurements, data-center HVAC, production change control, or verified external IPv6 ingress testing.

## Outcome

The inspected server had no failed systemd units, SSH was running, Docker workloads were active, local HTTP GET tests responded, and storage usage did not indicate a need for cleanup. Firewall and IPv6 observations were documented as areas requiring deliberate verification; no risky changes were made.
