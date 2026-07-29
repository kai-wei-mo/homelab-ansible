#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <github_pat>" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

cd "$ROOT"
ansible-vault decrypt inventory/group_vars/all/vault.yaml --output "$TMP"

NEW_PAT="$1" python3 - "$TMP" <<'PY'
import os, re, sys
path = sys.argv[1]
new_pat = os.environ["NEW_PAT"]
with open(path) as f:
    content = f.read()
if "vault_argocd_repo_github_pat:" not in content:
    raise SystemExit("vault_argocd_repo_github_pat key not found")
content = re.sub(
    r"^vault_argocd_repo_github_pat:.*$",
    f'vault_argocd_repo_github_pat: "{new_pat}"',
    content,
    count=1,
    flags=re.MULTILINE,
)
with open(path, "w") as f:
    f.write(content)
print("updated vault_argocd_repo_github_pat")
PY

ansible-vault encrypt "$TMP" --output inventory/group_vars/all/vault.yaml
echo "vault re-encrypted"
