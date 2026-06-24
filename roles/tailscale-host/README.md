# tailscale-host

Installs [Tailscale](https://tailscale.com/) on every host so you can reach your
boxes (and optionally your LAN) from anywhere on your tailnet.

All hosts share **one reusable, tagged auth key** stored in the vault. Per-host
revocation isn't needed — remove a machine from the
[admin console](https://login.tailscale.com/admin/machines) instead.

## One-time setup

1. Create an auth key at [Settings → Keys](https://login.tailscale.com/admin/settings/keys):
   - **Reusable**: on (all hosts join with the same key).
   - **Tags**: e.g. `tag:homelab` (tagged machines have no node-key expiry, so
     servers never need re-auth). Define the tag in your tailnet ACLs first.
   - Note: the auth key itself expires after ≤90 days. Already-joined machines
     are unaffected; just generate a new key when onboarding later hosts.
2. Put the key in the vault:

   ```bash
   ansible-vault edit inventory/group_vars/all/vault.yaml
   # set: vault_tailscale_auth_key: "tskey-auth-..."
   ```

3. Run it:

   ```bash
   ansible-playbook site.yaml --tags tailscale
   ```

## Configuration

Enabled for all hosts in `inventory/group_vars/all/main.yaml`. Per-host options
go in `inventory/host_vars/<hostname>.yaml`, e.g. advertise the LAN from one box:

```yaml
tailscale_advertise_routes:
  - "192.168.86.0/24"
```

Then approve the route in **Tailscale admin → Machines → … → Edit route settings**.

The machine name on the tailnet defaults to the Ansible inventory hostname.

## Remote access

After the role succeeds, the machine appears in the [Machines](https://login.tailscale.com/admin/machines) list with a `100.x.y.z` address.

```bash
# SSH over Tailscale (MagicDNS name follows the inventory hostname)
ssh ansible@xps13-9350

# Or use the Tailscale IP shown in the admin console
ssh ansible@100.x.y.z
```

With `tailscale_ssh: true` (the default here), you can also use
[Tailscale SSH](https://tailscale.com/kb/1193/tailscale-ssh) without managing
host keys on every client.

## Verify on the server

```bash
sudo tailscale status
sudo tailscale ip -4
```
