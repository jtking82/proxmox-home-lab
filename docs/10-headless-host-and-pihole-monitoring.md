# Home-Lab Availability Monitoring and Headless Host Operation

## Overview

This maintenance milestone extended the lab's monitoring coverage and configured the Proxmox laptop host to remain operational with its lid closed.

Work completed and verified:

- Configured the physical Proxmox host to ignore lid-close events using systemd-logind.
- Verified Proxmox and the Debian services VM remained reachable with the host lid closed.
- Added Uptime Kuma checks for Pi-hole's web interface and DNS port.
- Corrected the Pi-hole web-monitor target to use its configured web port (8081).

## 1. Configure Proxmox host lid behavior

On the Proxmox host, the lid-close behavior was configured in `/etc/systemd/logind.conf`:

```ini
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
```

The settings were verified in the configuration file and applied by restarting `systemd-logind`:

```bash
systemctl restart systemd-logind
```

A practical test was performed: the host initially suspended when the lid was closed, and network connectivity returned immediately when the lid was opened. After ensuring the settings were uncommented and set to `ignore`, applying them, and testing again, the Proxmox host remained reachable with the lid closed. The Debian VM was also reachable over SSH.

This demonstrates a headless operating configuration for the host. Keep the machine connected to power and ensure airflow is not obstructed when operating with the lid closed.

## 2. Pi-hole monitoring in Uptime Kuma

Two monitors were added for Pi-hole:

| Monitor | Type | Target / purpose |
|---|---|---|
| Pi-hole Web Interface | HTTP(s) | Checks the web interface at the configured web port |
| Pi-hole DNS Port | TCP Port | Checks reachability of TCP port 53 |

The web monitor target was corrected to:

```text
http://<DEBIAN_VM_IP>:8081/admin/
```

The DNS port monitor checks:

- Host: `<DEBIAN_VM_IP>`
- Port: `53`

The web interface uses port 8081 in this lab. Port 80 was not listening on the Debian host, and a test against port 80 returned connection refused. The corrected port-8081 target subsequently reported UP in Uptime Kuma.

The DNS monitor also reported UP. Additional direct checks confirmed the Pi-hole container was healthy and Pi-hole FTL was listening on TCP and UDP port 53.

## 3. Troubleshooting evidence

Commands used during verification:

```bash
docker ps
sudo ss -tulpn | grep ':53'
curl -I http://<DEBIAN_VM_IP>/admin/
nc -vz <DEBIAN_VM_IP> 53
```

Observed findings:

- The Pi-hole container was running and marked healthy.
- Pi-hole FTL was listening on TCP and UDP port 53.
- A TCP connectivity test to port 53 succeeded.
- Port 80 was not listening, so a web-monitor test on port 80 failed.
- The web-monitor target was corrected to the configured port 8081 and then reported UP.

A container health status and a monitor status measure different things. The container can be healthy while a monitor is misconfigured to check the wrong port or URL. Confirm monitor targets before changing service configuration.

## 4. Verification status

- [x] Lid-close settings configured on the Proxmox host.
- [x] systemd-logind restarted to apply the settings.
- [x] Proxmox host tested with lid closed and remained reachable.
- [x] Debian VM tested with lid closed and remained reachable over SSH.
- [x] Pi-hole container observed healthy.
- [x] Pi-hole FTL observed listening on TCP and UDP port 53.
- [x] Pi-hole DNS-port monitor reported UP.
- [x] Pi-hole web monitor corrected to port 8081 and reported UP.

## Safety and operational notes

- Closed-lid operation can increase heat depending on the hardware design; maintain adequate ventilation.
- These monitors provide availability checks, not comprehensive validation of DNS filtering or DHCP behavior.
- A TCP-port check confirms TCP reachability only; DNS primarily uses UDP and also supports TCP.
- Do not publish private network addresses, credentials, or unredacted configuration files.
