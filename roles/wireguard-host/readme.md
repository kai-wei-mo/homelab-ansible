# wireguard-host

Sets up a WireGuard client (Proton VPN) on hosts in the `vpn` group, plus a
**fail-closed killswitch** so public internet egress only leaves via `wg0`.

Config lives in `inventory/group_vars/vpn.yaml`; keys/endpoints live in the
vault (`ansible-vault edit inventory/group_vars/all/vault.yaml`).

## Killswitch

`wireguard-killswitch.service` installs iptables/ip6tables chains that:

- allow egress via `wg0`, Tailscale, CNI/docker bridges, and listed LAN/cluster CIDRs
- allow UDP to the WireGuard endpoint (and packets with the WG fwmark)
- **REJECT** everything else (including binds to the Wi-Fi/Ethernet NIC)

If WireGuard drops, public traffic fails instead of falling back to the ISP
default route. Ansible also asserts `ip route get 1.1.1.1` uses `wg0` and that
`curl --interface <physical>` cannot reach the internet.

```bash
sudo /etc/wireguard/killswitch.sh status
sudo /etc/wireguard/killswitch.sh stop   # intentional disable only
```

## NAT-PMP port forwarding (Proton)

```bash
sudo natpmpc -g 10.2.0.1 -a 6861 6861 tcp 60
sudo natpmpc -g 10.2.0.1 -a 6861 6861 udp 60
```
