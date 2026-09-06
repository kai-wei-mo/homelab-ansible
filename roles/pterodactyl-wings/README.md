# pterodactyl-wings

Installs [Pterodactyl Wings](https://pterodactyl.io/wings/1.0/installing.html) on a
Docker host. Wings manages game server containers via the Docker Engine API — it
cannot run inside k3s/containerd.

Requires the `docker-tools` role (Docker Engine) on the same host.

## One-time panel setup

1. Open `https://pterodactyl.chaewon.io/admin` and create a **Location** (e.g.
   `homelab`).
2. **Nodes → Create New**
   - Name: `mac-mini-i5`
   - FQDN: `wings.chaewon.io`
   - Communicate over SSL: yes
   - Behind Proxy: **yes** (Traefik terminates TLS)
   - Daemon port: `443` (Traefik forwards to Wings `:8080`)
   - Daemon SFTP port: `2022`
   - Total memory / disk: match the host (7 GiB RAM, ~850 GiB disk)
   - Daemon base: `/var/lib/pterodactyl`
3. On the node **Configuration** tab, run the generated `wings configure` command
   on the Mac Mini (SSH or Ansible ad hoc):

   ```bash
   sudo wings configure \
     --panel-url https://pterodactyl.home.chaewon.io \
     --token '<token from panel>' \
     --node 1
   ```

   Use the `.home.` URL so Panel ↔ Wings traffic stays on the tailnet.

4. Edit `/etc/pterodactyl/config.yml` if needed:
   - `api.host` should be `0.0.0.0`
   - `api.port` should be `8080` (Traefik handles `:443` externally)
   - `api.ssl.enabled` should be `false` (TLS is at Traefik)

5. Re-run the playbook or `sudo systemctl enable --now wings`.

## Allocations

After Wings is online, add allocations on the node for each port game servers need.
For Project Zomboid B42: `192.168.86.91:16261` (and optionally `16262`).

Players connect to `games.chaewon.io:16261` once router UDP forwarding and DDNS
are configured (see `homelab-core-infra/pterodactyl/README.md`).

## Upgrade

Bump `pterodactyl_wings_version` in `defaults/main.yaml` and re-run:

```bash
ansible-playbook site.yaml --limit mac-mini-i5 --tags wings
```
