nfs://192.168.1.90/srv/nfs

sudo mkdir -p /Volumes/nfs-xps-13
sudo mount -t nfs -o resvport,nolocks 192.168.1.90:/srv/nfs /Volumes/nfs-xps-13
ls /Volumes/nfs-xps-13
