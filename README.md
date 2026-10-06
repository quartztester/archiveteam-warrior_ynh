# archiveteam-warrior_ynh — ArchiveTeam Warrior for YunoHost

A [YunoHost](https://yunohost.org) (v2.1 helpers) package for the
[ArchiveTeam Warrior](https://wiki.archiveteam.org/index.php/ArchiveTeam_Warrior):
a small appliance that volunteers bandwidth to archive dying websites and
uploads the results to the Internet Archive.

## What it does

- Runs the official `atdr.meo.ws/archiveteam/warrior-dockerfile` image in
  Docker via docker compose + a systemd oneshot unit (same pattern as other
  container-based YunoHost apps).
- **Outbound-only.** No firewall ports are opened and no router port-forward
  is needed. The container's dashboard binds `127.0.0.1:8001` only.
- Installs an SSO-gated nginx vhost on a domain you pick, so the Warrior
  dashboard appears as a tile (custom logo included) in the YunoHost portal —
  one login, no separate credentials.
- Registers with the ArchiveTeam tracker using the **fullname of the first
  YunoHost admin** as leaderboard nickname (no account or email needed; it is
  purely cosmetic).
- Selects the tracker-recommended project set (`auto`) on first boot.

## Requirements

- YunoHost ≥ 12.1, Docker (`docker.io` + `docker-compose-v2`) installed and
  running (this package does not install Docker).
- amd64 or arm64.

## Install

```
yunohost app install https://github.com/<you>/archiveteam-warrior_ynh \
    -a "domain=warrior.example.com"
```

The dashboard **must live at the root of a domain** (the Warrior UI uses
absolute asset paths). `yunohost app change-url archiveteam-warrior -d <other.domain>
-p /` is supported to move the app between domains.

## Notes / package gotchas (learned the hard way)

- The container's `warrior` user is uid/gid 1000; the bind mounts under
  `$install_dir` are chowned accordingly by the installer.
- The image's HEALTHCHECK (and downloader) expect `wget-at*` binaries inside
  `/data`; an empty bind mount would shadow them, so the installer seeds
  them from the image before first start.
- A fresh Warrior with an empty `selected_project` **never** starts work (the
  tracker only sends its weighted recommendation when explicitly asked for
  `auto`). The installer POSTs `select-project=auto` after boot.
- `main.auth_header = false` is essential: the Warrior has no user concept and
  returns 401 on any Basic auth header, so ssowat must gate the URL without
  injecting credentials (the nginx snippet also strips `Authorization` as a
  belt-and-suspenders).
- Tile logo: `$app.png` in `/usr/share/yunohost/applogos/` is the supported
  override for non-catalog apps; the installer also pins the permission's
  `logo_hash`.

## Ops

- Project selection, pausing, and live stats: the app's dashboard (portal
  tile, or `http://127.0.0.1:8001` on the server).
- Upgrade: `yunohost app upgrade archiveteam-warrior` (pulls the latest image; identity
  and in-progress data survive).
- Uninstall: `yunohost app remove archiveteam-warrior` (also removes nginx config and
  container; unfinished tracker items simply expire and get re-queued).

## License

Package scripts: GPL-3.0 (matching upstream Warrior). Upstream:
https://github.com/ArchiveTeam/warrior-dockerfile
