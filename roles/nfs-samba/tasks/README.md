# Samba shares

Opt in per host in `inventory/host_vars/<hostname>.yaml`:

```yaml
samba_storage_root: /mnt/seagate
```

Hosts without `samba_storage_root` skip share configuration.

## Layout

```
/mnt/seagate/          ← physical disk (server admin only)
├── jellyfin/
└── audiobookshelf/

/srv/samba/            ← stable Samba namespace (what clients mount)
├── jellyfin/          → bind mount
└── audiobookshelf/    → bind mount
```

Top-level directories under `samba_storage_root` are discovered and bind-mounted
into `samba_export_root`. Re-run the samba role after adding a new top-level folder.

## Multiple disks (future)

This role currently supports one storage root. To present several physical
disks as a single path, use a **union filesystem** such as
[MergerFS](https://github.com/trapexit/mergerfs) to merge mount points into one
directory, then point `samba_storage_root` at that merged path.
