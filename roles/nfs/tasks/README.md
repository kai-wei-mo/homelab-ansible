# NFS exports

Opt in per host in `inventory/host_vars/<hostname>.yaml`:

```yaml
nfs_storage_root: /mnt/seagate
```

Hosts without `nfs_storage_root` skip export configuration.

## Layout

```
/mnt/seagate/          ← physical disk (server admin only)
├── jellyfin/
└── audiobookshelf/

/srv/nfs/              ← stable NFS namespace (what clients mount)
├── jellyfin/          → bind mount
└── audiobookshelf/    → bind mount
```

Top-level directories under `nfs_storage_root` are discovered and bind-mounted
into `nfs_export_root`. Re-run the nfs role after adding a new top-level folder.

## Multiple disks (future)

This role currently supports one storage root. To present several physical
disks as a single path (e.g. both have `immich2/` and you want one unified tree),
use a **union filesystem** such as [MergerFS](https://github.com/trapexit/mergerfs)
to merge mount points into one directory, then point `nfs_storage_root` at that
merged path. Pool-based namespacing (`/srv/nfs/seagate/...`, `/srv/nfs/sandisk/...`)
is the simpler alternative if you do not need a unified view.
