# kwm-pc

Ansible manages only the Ubuntu 24.04 WSL2 guest. Installing and configuring
WSL and its Windows integration is a manual prerequisite; this repo does not
configure the Windows host.

## Windows setup

Do steps 2–6 in **Windows PowerShell as Administrator**. Click Start, type
`powershell`, right-click **Windows PowerShell** → **Run as administrator**.

1. Install WSL2 and Ubuntu 24.04.

2. Install the current NVIDIA Windows driver with WSL CUDA support. Do not
   install a Linux NVIDIA display driver inside WSL; WSL supplies the CUDA
   driver through `/usr/lib/wsl/lib`.

   Check the Windows driver (495+ is enough):

   ```powershell
   nvidia-smi
   ```

   If that command is missing, download the GeForce/Studio driver for this GPU:

   ```powershell
   start https://www.nvidia.com/Download/index.aspx
   ```

   Install it on Windows, never inside WSL.

3. Disable Windows OpenSSH Server so WSL can listen on mirrored port 22.

   ```powershell
   Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'
   ```

   `State : NotPresent` means Windows OpenSSH Server is already gone. That is
   the desired result; skip the rest of this step.

   Only if State is `Installed`:

   ```powershell
   Stop-Service sshd -ErrorAction SilentlyContinue
   Set-Service -Name sshd -StartupType Disabled -ErrorAction SilentlyContinue
   Remove-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
   if (Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -ErrorAction SilentlyContinue) {
     Disable-NetFirewallRule -Name 'OpenSSH-Server-In-TCP'
   }
   ```

4. Add mirrored networking to `%UserProfile%\.wslconfig`.

   ```powershell
   $path = "$env:USERPROFILE\.wslconfig"
   if (-not (Test-Path $path)) {
     Set-Content -Path $path -Value "[wsl2]`r`nnetworkingMode=mirrored`r`n" -Encoding ascii
   } else {
     $text = Get-Content $path -Raw
     if ($text -match 'networkingMode\s*=') {
       $text = $text -replace 'networkingMode\s*=\s*\S+', 'networkingMode=mirrored'
     } elseif ($text -match '\[wsl2\]') {
       $text = $text -replace '\[wsl2\]', "[wsl2]`r`nnetworkingMode=mirrored"
     } else {
       $text = $text.TrimEnd() + "`r`n`r`n[wsl2]`r`nnetworkingMode=mirrored`r`n"
     }
     Set-Content -Path $path -Value $text.TrimEnd() -Encoding ascii
   }
   Get-Content $path
   ```

   The file should contain:

   ```ini
   [wsl2]
   networkingMode=mirrored
   ```


6. Permit inbound traffic to mirrored WSL:

   ```powershell
   Set-NetFirewallHyperVVMSetting `
     -Name '{40E0AC32-46A5-438A-A0B2-2B479E8F2E90}' `
     -DefaultInboundAction Allow
   Get-NetFirewallHyperVVMSetting `
     -Name '{40E0AC32-46A5-438A-A0B2-2B479E8F2E90}'
   ```

   `DefaultInboundAction` should be `Allow`.

   This GUID is Microsoft's WSL VM creator ID for Hyper-V firewall.
   Traffic to the WSL VM hits this firewall which tags traffic with this ID.

Then restart WSL so steps 5–6 take effect:

```powershell
wsl --shutdown
```

## WSL setup

In WSL/Ubuntu, enable systemd in `/etc/wsl.conf`.

```bash
if [ ! -f /etc/wsl.conf ]; then
  printf '%s\n' '[boot]' 'systemd=true' | sudo tee /etc/wsl.conf
elif grep -q '^\s*systemd\s*=' /etc/wsl.conf; then
  sudo sed -i 's/^\s*systemd\s*=.*/systemd=true/' /etc/wsl.conf
elif grep -q '^\[boot\]' /etc/wsl.conf; then
  sudo sed -i '/^\[boot\]/a systemd=true' /etc/wsl.conf
else
  printf '\n[boot]\nsystemd=true\n' | sudo tee -a /etc/wsl.conf
fi
cat /etc/wsl.conf
```

The file should contain:

```ini
[boot]
systemd=true
```

Close the Ubuntu window. In the Administrator PowerShell window:

```powershell
wsl --shutdown
```

Reopen Ubuntu, then confirm PID 1 is systemd:

```bash
ps -p 1 -o comm=
```

That should print `systemd`. Then create the Ansible user:

```bash
sudo adduser ansible
sudo usermod -aG sudo ansible
sudo apt update
sudo apt install -y openssh-server
sudo systemctl enable --now ssh
sudo visudo
# Add: ansible ALL=(ALL) NOPASSWD: ALL
```

```bash
ssh-copy-id -i ~/.ssh/ansible_key ansible@192.168.86.100
ansible kwm-pc -m ping
```

## Optional: Keep WSL online

WSL stops its VM when no process remains. Create a Windows Task Scheduler task
at logon that runs the following command, replacing `<DistroName>` with the
name shown by `wsl --list --verbose`:

```powershell
wsl.exe -d <DistroName> --exec sleep infinity
```

This keeps sshd, Docker, and the WSL-only Tailscale node online.

The Windows client is not a member of the tailnet.
