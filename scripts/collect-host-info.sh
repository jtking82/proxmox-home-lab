#!/usr/bin/env bash
# Collect basic Proxmox host facts for a lab report.
# Review output before sharing; redact details you do not want public.

set -u

echo "=== Date ==="
date

echo
echo "=== Proxmox version ==="
if command -v pveversion >/dev/null 2>&1; then
    pveversion -v
else
    echo "pveversion command not found; this may not be a Proxmox host."
fi

echo
echo "=== Operating system ==="
cat /etc/os-release 2>/dev/null || true

echo
echo "=== Kernel ==="
uname -r

echo
echo "=== Hostname ==="
hostnamectl 2>/dev/null || hostname

echo
echo "=== Network interfaces ==="
ip -br addr

echo
echo "=== Routing table ==="
ip route

echo
echo "=== Network configuration ==="
if [ -r /etc/network/interfaces ]; then
    cat /etc/network/interfaces
else
    echo "/etc/network/interfaces is not readable."
fi

echo
echo "=== Storage overview ==="
df -hT

echo
echo "Collection complete. Review and sanitize output before publishing."
