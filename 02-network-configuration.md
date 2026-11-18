# 2. Network Configuration

## Objective

Configure the Proxmox host to use a Linux bridge connected to the physical Ethernet interface and verify local and routed connectivity.

## Network design

```text
Home router
192.168.1.254
      |
      | Ethernet
      |
   nic0 (physical NIC)
      |
   vmbr0 (Linux bridge)
      |
Proxmox host
192.168.1.159/24 (observed)
```

`vmbr0` is the bridge used by the Proxmox host. Virtual machines can later connect to this bridge to reach the physical LAN, subject to the network and VM configuration.

## Interfaces configuration observed during setup

The configuration shown during troubleshooting included:

```text
auto lo
iface lo inet loopback

iface nic0 inet manual

auto vmbr0
iface vmbr0 inet dhcp
        bridge-ports nic0
        bridge-stp off
        bridge-fd 0

iface nic1 inet manual

source /etc/network/interfaces.d/*
```

This is a record of the configuration displayed during the troubleshooting session. The final file should be checked on the host before treating this as an exact current configuration. Do not copy it blindly onto another machine: interface names and network requirements vary.

## Important concepts

- **Physical NIC (`nic0`):** the Ethernet network interface connected to the router or switch.
- **Linux bridge (`vmbr0`):** a virtual Layer 2 switch. The Proxmox host and virtual machines can use it to connect to the LAN.
- **DHCP:** automatically obtains network settings such as an IP address and, when supplied by the DHCP server, a default gateway.
- **Default route:** tells the host where to send traffic for destinations outside directly connected networks.

## Commands used for inspection

```bash
ip -br addr
ip route
cat /etc/network/interfaces
```

`ip -br addr` gives a compact interface/address view. `ip route` displays the routing table. `cat` displays the network configuration file.

## Applying network configuration

The following command was used to apply the configuration:

```bash
ifreload -a
```

Then the route table was checked:

```bash
ip route
```

The observed result was:

```text
default via 192.168.1.254 dev vmbr0
192.168.1.0/24 dev vmbr0 proto kernel scope link src 192.168.1.159
```

This confirmed that the host had a default route through the home router at that time.

## Verification

The following tests were used or recommended:

```bash
ping -c 4 192.168.1.254
ping -c 4 1.1.1.1
ping -c 4 google.com
```

Interpretation:

1. Router ping tests local network reachability.
2. Public IP ping tests routed internet reachability without depending on DNS.
3. Domain ping tests name resolution as well as network reachability.

A failed ping does not always prove a network is down because some systems block ICMP. Use the route table and additional tests when needed.

## Persistence test still required

A successful `ifreload -a` confirms that the current configuration can be applied. It does not, by itself, prove that the default route will remain correct after reboot.

Before marking this complete:

1. Confirm that the current `/etc/network/interfaces` contains the intended final configuration.
2. Ensure you have local console access before testing, in case remote management connectivity is interrupted.
3. Reboot during a convenient maintenance window.
4. After reboot, run `ip -br addr` and `ip route`.
5. Confirm that the host has the expected address and a default route through `192.168.1.254`.

For a stable home-lab management address, consider a DHCP reservation on the router or a carefully planned static address outside the router's dynamic pool. Avoid assigning an address that could conflict with another device.
