# mac-mini-i5 — Ubuntu install notes

Ubuntu on this Mac Mini had broken wireless until the Broadcom proprietary
driver was installed. Wi-Fi did not work out of the box.

## Identify the chip

```bash
lspci -nn | grep -Ei 'network|wireless|broadcom'
```

This machine shows **`14e4:43a0`** (Broadcom BCM4360).

## Fix

```bash
sudo apt update
sudo apt install bcmwl-kernel-source
sudo reboot
```

After reboot, the `wl` module should bind and wireless should come up.
