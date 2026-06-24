# homelab-ansible

Ansible config for all homelab machines. Everything is driven from the Mac
(the "control node"); the servers only need SSH and an `ansible` user.

## Repo layout

```
ansible.cfg                     # ansible settings (inventory path, vault password file)
site.yaml                       # the main playbook — plays per host group
.vault-password                 # vault password (gitignored — back it up somewhere safe!)
inventory/
  hosts.yaml                    # all hosts + which functional groups they belong to
  group_vars/
    all/
      main.yaml                 # vars for every host (ssh user, tailscale on, ...)
      vault.yaml                # secrets, ansible-vault ENCRYPTED (safe to commit)
    k3s.yaml                    # vars for the `k3s` group (argocd)
    vpn.yaml                    # vars for the `vpn` group (cloudflared, wireguard)
  host_vars/
    xps13-9350.yaml             # per-host overrides
    ...
roles/                          # reusable roles; defaults/ contain safe defaults only
```

How variables work (low → high precedence): role `defaults/` → `group_vars/all` →
`group_vars/<group>` → `host_vars/<host>`. Real site config lives in `inventory/`,
never in role defaults.

## Usage

```bash
ansible-playbook site.yaml                          # everything, all hosts
ansible-playbook site.yaml --limit xps13-9350       # one host
ansible-playbook site.yaml --tags tailscale         # one thing
ansible-playbook site.yaml --check --diff           # dry run
ansible all -m ping                                 # connectivity test
```


## Onboarding a new host

### 1. On the Mac (first host ever: also `brew install ansible` and generate the key)

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ansible_key -N ""   # once, if you don't have it yet
ssh kwm@<server-ip>                                     # your personal user, to bootstrap
```

### 2. On the server (inside that SSH session)

```bash
sudo adduser ansible  # password: !bWX6Lb2jrjWSr
sudo usermod -aG sudo ansible

sudo apt update && sudo apt install openssh-server -y
sudo systemctl enable ssh
sudo systemctl start ssh

sudo systemctl set-default multi-user.target  # boot to console, no GUI
# sudo systemctl start graphical.target  # one time gui start
# sudo systemctl set-default graphical.target  # set gui as default

sudo visudo
# add line at bottom:
# ansible ALL=(ALL) NOPASSWD: ALL

sudo reboot
```

### 3. Back on the Mac

```bash
ssh-copy-id -i ~/.ssh/ansible_key ansible@<server-ip>
```

Then add the host to `inventory/hosts.yaml` (under `all.hosts` plus whichever
groups it serves in: `k3s`, `nas`, `vpn`), optionally create
`inventory/host_vars/<hostname>.yaml`, and run:

```bash
ansible-playbook site.yaml --limit <hostname>
```

The host joins Tailscale automatically using the shared auth key from the vault
(if the key expired, generate a new reusable+tagged one and update the vault).
