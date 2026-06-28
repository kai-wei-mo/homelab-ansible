# wireguard-host

Sets up a WireGuard client (Proton VPN) on hosts in the `vpn` group.

Config lives in `inventory/group_vars/vpn.yaml`; keys/endpoints live in the
vault (`ansible-vault edit inventory/group_vars/all/vault.yaml`).

## NAT-PMP port forwarding (Proton)

```bash
sudo natpmpc -g 10.2.0.1 -a 6861 6861 tcp 60
sudo natpmpc -g 10.2.0.1 -a 6861 6861 udp 60
```
