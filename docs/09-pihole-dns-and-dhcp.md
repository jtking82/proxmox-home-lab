# Pi-hole DNS and DHCP Deployment

## Overview

This milestone extends the Debian services VM with Pi-hole for network-level DNS filtering and DHCP service. The deployment was performed in the existing Docker environment and integrated with the home router's LAN.

The work covered:

- Deploying Pi-hole as a Docker container.
- Configuring host networking for LAN DNS and DHCP traffic.
- Persisting Pi-hole configuration.
- Configuring upstream DNS resolvers.
- Assigning a stable address to the Debian services VM.
- Transitioning DHCP service from the router to Pi-hole.
- Verifying DNS filtering and the DHCP service.
- Testing client address assignment.

Private LAN addresses, device identifiers, and credentials are intentionally represented by placeholders. No passwords, API tokens, MAC addresses, or personal network identifiers belong in this repository.

## Architecture

| Component | Role |
|---|---|
| Proxmox VE | Hosts the Debian services VM |
| Debian GNU/Linux 13 guest | Runs Docker and the Pi-hole container |
| Docker Engine / Compose | Container runtime and deployment |
| Pi-hole FTL | DNS filtering and DHCP service |
| LAN router | Default gateway and upstream internet routing |
| Client devices | Receive DHCP leases and use Pi-hole for DNS |

The Debian VM uses a static LAN address so clients can consistently reach Pi-hole. Substitute `<PIHOLE_LAN_IP>` and `<LAN_GATEWAY>` for the actual values in a private deployment.

## 1. Deploy Pi-hole with Docker Compose

The Pi-hole Compose project is stored in a dedicated directory with persistent configuration:

```bash
mkdir -p ~/docker/pihole
cd ~/docker/pihole
```

The deployment uses host networking. This allows Pi-hole to bind directly to the Debian guest's network interfaces and is important for receiving LAN DHCP broadcasts.

Sanitized Compose example:

```yaml
services:
  pihole:
    container_name: pihole
    image: pihole/pihole:latest
    network_mode: host
    cap_add:
      - NET_ADMIN
    environment:
      TZ: 'America/New_York'
      FTLCONF_webserver_api_password: '<SET_A_PRIVATE_PASSWORD>'
      FTLCONF_dns_listeningMode: 'ALL'
      FTLCONF_dns_upstreams: '1.1.1.1;1.0.0.1'
      FTLCONF_webserver_port: '8081'
    volumes:
      - './etc-pihole:/etc/pihole'
    restart: unless-stopped
```

Security and configuration notes:

- Replace the password placeholder locally. Never commit the actual password.
- The Pi-hole web interface is exposed on the configured web port on the private LAN.
- The persistent bind mount keeps Pi-hole configuration in the project directory.
- Host networking means Docker does not publish individual container ports; Pi-hole listens directly on the host network.
- `NET_ADMIN` is included for DHCP functionality.
- Restrict the administration interface to trusted users and the private network.

Apply and inspect the deployment:

```bash
docker compose up -d
docker ps
docker logs pihole --tail 50
```

## 2. Verify DNS filtering

The upstream resolvers were configured as Cloudflare DNS:

- `1.1.1.1`
- `1.0.0.1`

Test a known advertising/tracking domain against Pi-hole:

```bash
nslookup doubleclick.net <PIHOLE_LAN_IP>
```

The observed test returned sinkhole addresses (`0.0.0.0` and `::`) for the blocked domain.

A normal DNS lookup was also tested:

```bash
nslookup google.com <PIHOLE_LAN_IP>
```

The normal lookup succeeded. Pi-hole's Query Log showed the test requests and their client address.

These checks demonstrate that Pi-hole was answering DNS queries and applying its block lists. They do not guarantee that every application or device will use Pi-hole: manually configured DNS, encrypted DNS, VPNs, and privacy relay services can bypass network-provided DNS.

## 3. Give the Debian guest a stable address

The Debian guest was initially using DHCP for its IPv4 configuration. A static NetworkManager profile was configured so Pi-hole would remain reachable at a predictable address.

Example command (replace placeholders with the values for the local network):

```bash
sudo nmcli connection modify "Wired connection 1" \
  ipv4.method manual \
  ipv4.addresses <PIHOLE_LAN_IP>/<PREFIX> \
  ipv4.gateway <LAN_GATEWAY> \
  ipv4.dns "<UPSTREAM_DNS_1> <UPSTREAM_DNS_2>"
```

The profile was activated:

```bash
sudo nmcli connection up "Wired connection 1"
```

Verification commands:

```bash
ip -br addr
ip route
```

The interface retained the configured static IPv4 address, and the route table showed the expected default gateway. Connectivity to the gateway was tested successfully with zero packet loss.

The Debian host's DNS configuration intentionally uses upstream resolvers rather than depending on Pi-hole itself. This avoids making host administration dependent on the DNS service running inside the same guest.

## 4. Prepare DHCP service

Pi-hole was configured with a DHCP pool that excludes the infrastructure address assigned to the Debian guest. The router remains the default gateway for clients.

Sanitized example values:

| DHCP setting | Example |
|---|---|
| Start address | `<DHCP_POOL_START>` |
| End address | `<DHCP_POOL_END>` |
| Router / gateway | `<LAN_GATEWAY>` |
| DNS server offered to clients | `<PIHOLE_LAN_IP>` |
| Subnet | `<LAN_SUBNET>/<PREFIX>` |

Before enabling Pi-hole DHCP, the router's DHCP server was disabled. Only one DHCP server should be active on a broadcast domain; running both simultaneously can result in clients receiving inconsistent network configuration.

The Pi-hole Compose service was updated with the `NET_ADMIN` capability and recreated:

```bash
docker compose up -d
```

Pi-hole's DHCP listener was verified on UDP port 67:

```bash
sudo ss -lunp | grep ':67'
```

Observed output identified `pihole-FTL` listening on `0.0.0.0:67`.

After confirming the router's DHCP service was off, DHCP was enabled in Pi-hole's web interface and the configured pool was saved.

## 5. Verify DHCP and client DNS

A test phone disconnected and reconnected to Wi-Fi. It received an address within the configured Pi-hole DHCP pool. The address appeared in Pi-hole's active DHCP leases, and DNS requests from that client appeared in the Query Log.

A second client (an iPad) also reconnected and received an address within the pool. However, its DNS activity did not visibly update in the Query Log during the initial test. This remains an open troubleshooting item; DHCP address assignment alone does not prove that a client is sending DNS queries to Pi-hole.

Useful checks:

- Confirm the client appears in Pi-hole's active DHCP leases.
- Confirm the client's DNS server is the Pi-hole address.
- Generate fresh DNS requests from the client and inspect Query Log activity.
- Check for manually configured DNS, VPN profiles, iCloud Private Relay, or encrypted DNS features if queries do not appear.
- Do not assume a browser page load proves a DNS request was sent to Pi-hole; cached results and alternate DNS paths can affect the test.

## 6. Troubleshooting and operational safety

- Keep a known-good administrative path to the Debian guest and router.
- Do not enable two DHCP servers on the same LAN at the same time.
- Keep the Pi-hole guest address outside the dynamic DHCP pool.
- Verify the gateway and subnet values before saving DHCP configuration.
- If a client cannot reconnect after a DHCP change, check the router, Pi-hole service, lease state, and client network configuration before making additional changes.
- A DHCP lease table may initially be empty because existing clients can retain leases until they renew.
- A listener on UDP port 67 proves the DHCP process is listening; a client lease is stronger end-to-end evidence.
- DNS-over-HTTPS, VPNs, Private Relay, and manually configured DNS can bypass ordinary DHCP-provided DNS settings.

## 7. Verification and current status

- [x] Pi-hole container deployed with Docker Compose.
- [x] Persistent Pi-hole configuration directory configured.
- [x] Host networking configured.
- [x] Upstream DNS resolvers configured.
- [x] Normal DNS resolution tested successfully through Pi-hole.
- [x] A known advertising/tracking domain returned sinkhole addresses.
- [x] Debian guest assigned a static IPv4 address.
- [x] Default route and gateway connectivity verified.
- [x] `NET_ADMIN` capability added for DHCP operation.
- [x] Pi-hole FTL confirmed listening on UDP port 67.
- [x] Router DHCP disabled before Pi-hole DHCP was enabled.
- [x] Pi-hole DHCP enabled with a defined address pool.
- [x] Test phone received an address from the Pi-hole pool.
- [x] Test phone DNS requests observed in Pi-hole Query Log.
- [x] Second client reconnected and received an address in the Pi-hole pool.
- [ ] Confirm DNS queries from the second client appear in Pi-hole Query Log.
- [ ] Verify additional clients renew leases and use Pi-hole for DNS.
- [ ] Review IPv6 DNS behavior and determine whether additional configuration is needed.
- [ ] Test Pi-hole backup and restore.
- [ ] Document a recovery procedure for DHCP service interruption.

## Outcome

The lab now includes a self-hosted DNS filtering service and a DHCP server running in a Docker container on the Debian services VM. DNS filtering was verified with direct lookup tests, and DHCP operation was verified through the listening socket and a client receiving a lease. Client-level DNS verification is complete for the test phone but remains unresolved for the iPad. This distinction is recorded rather than treating DHCP assignment as proof of DNS usage.
