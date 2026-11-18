# Evidence

Place redacted screenshots and sanitized command output in this folder.

Suggested evidence:

1. `proxmox-dashboard.png` — Proxmox web interface dashboard.
2. `proxmox-version.png` — output of `pveversion -v`.
3. `network-interfaces.png` — output of `ip -br addr`.
4. `routing-table.png` — output of `ip route` showing the default gateway.
5. `apt-update.png` — successful APT repository update.

Before committing evidence, review it for:

- Passwords, tokens, private keys, or recovery codes
- Public IP addresses or personally identifying details
- MAC addresses or serial numbers you do not want public
- Internal hostnames or network details you prefer to keep private

A home-lab private subnet is often useful evidence, but you are not required to publish every infrastructure detail. Redact anything you are uncomfortable sharing.
