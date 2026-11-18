# Evidence

Place redacted screenshots and sanitized command output in this folder.

Suggested evidence:

1. `proxmox-dashboard.png` — Proxmox web interface dashboard.
2. `proxmox-version.png` — output of `pveversion -v`.
3. `network-interfaces.png` — output of `ip -br addr).
4. `routing-table.png` — output of `ip route` showing the default gateway, with addresses sanitized.
5. `apt-update.png` — successful APT repository update.
6. `vm-101-summary.png` — VM 101 summary showing allocated resources, with identifying details redacted.
7. `qemu-guest-agent-status.png` — sanitized output showing the QEMU Guest Agent as `active (running)`.
8. `ssh-session.png` — optional screenshot showing a successful SSH session without exposing account names or IP addresses.

Before committing evidence, review it for:

- Passwords, tokens, private keys, or recovery codes
- Public IP addresses or personally identifying details
- MAC addresses or serial numbers you do not want public
- Internal hostnames, usernames, or network details you prefer to keep private
- Browser tabs, bookmarks, notifications, or other unrelated personal information

Do not publish your actual home subnet, gateway, or device addresses unless you have deliberately decided to make them public. Use placeholders such as `<host-ip>` and `<gateway-ip>`, or clearly labeled documentation-only example addresses. The `initial-validation.md` file uses documentation-only example values, not the actual home-network addresses.

Screenshots are optional. A concise, accurate written record with verification commands is better than publishing screenshots that reveal private information.
