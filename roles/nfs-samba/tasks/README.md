nfs://192.168.1.90/srv/nfs

sudo mkdir -p /Volumes/nfs-xps-13
sudo mount -t nfs -o resvport,nolocks 192.168.1.90:/srv/nfs /Volumes/nfs-xps-13
ls /Volumes/nfs-xps-13



----


Method 1 — Group Policy (Pro / Enterprise)

Press Win + R

Run:

gpedit.msc

Navigate:

Computer Configuration
  → Administrative Templates
    → Network
      → Lanman Workstation

Open:

Enable insecure guest logons

Set to:

Enabled

Click Apply → OK

Restart your computer.

Method 2 — Registry (works on all editions, including Home)

Open PowerShell as Administrator:

reg add HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters `
 /v AllowInsecureGuestAuth /t REG_DWORD /d 1 /f

Restart:

Restart-Computer
Then mount the share
net use N: \\192.168.1.90\storage

or

net use N: \\192.168.1.90\samba-storage

(no username/password needed if guest ok = yes)

Verify
N:
dir

If it still fails, run:

net view \\192.168.1.90

to confirm Windows sees the share.
