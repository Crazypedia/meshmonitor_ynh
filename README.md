# MeshMonitor for YunoHost

[![Integration level](https://dash.yunohost.org/integration/meshmonitor.svg)](https://dash.yunohost.org/appci/app/meshmonitor)
[![Install MeshMonitor with YunoHost](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=meshmonitor)

*[Lire ce readme en français.](./README_fr.md)*

> *This package lets you install MeshMonitor quickly and simply on a YunoHost server.*
> *If you don't have YunoHost, please consult [the guide](https://yunohost.org/install) to learn how to install it.*

## Overview

MeshMonitor is a self-hosted web dashboard for monitoring and managing a [Meshtastic](https://meshtastic.org/) mesh network. It connects to a Meshtastic node over TCP and shows a live node map, message history, telemetry, traceroutes and network statistics.

This package builds and runs MeshMonitor directly on Node.js (no Docker), following the upstream **bare-metal** deployment, behind YunoHost's nginx with HTTPS.

**Shipped version:** 4.12.1~ynh1

## Important notes

- **Meshtastic node reachability** — MeshMonitor needs network access to your node's TCP port (default 4403). The node must be reachable from the YunoHost server. BLE/serial connections are not supported by this deployment.
- **Authentication (YunoHost SSO)** — installs with the permission set to `all_users`, so MeshMonitor is wired into the YunoHost single sign-on: anyone logged into the portal is **authenticated automatically** (no separate MeshMonitor password). nginx forwards SSOwat's `YNH_USER_EMAIL` as a `Remote-User` header, which MeshMonitor's reverse-proxy auth consumes to auto-provision the account. Users whose email is listed in the **administrator email(s)** install question get admin rights; everyone else gets read-only access. Roles can be adjusted later with:
  ```bash
  yunohost app setting meshmonitor admin_email -v "alice@example.com,bob@example.com"
  yunohost app upgrade meshmonitor   # re-renders .env from the saved settings
  ```
  - **Break-glass login** — the built-in `admin` / `changeme` account stays usable for emergencies; **change that password** after first login if you rely on it.
  - **Disabling SSO** — choosing the `visitors` permission makes the dashboard public and turns SSO off (the app then falls back to its own login). For a tighter setup you may also set `DISABLE_LOCAL_AUTH=true` / `DISABLE_ANONYMOUS=true` in `__INSTALL_DIR__/.env` to require SSO-only access.
- **Build resources** — the app compiles native modules (`bcrypt`, `better-sqlite3`, `re2`) and a React frontend at install time. Allow ~2 GB RAM and a few minutes for the build.
- **Subpath installs** — supported via the app's `BASE_URL`; both root (`/`) and subpath (`/meshmonitor`) work.

## Packaging notes

- Source is fetched with `git clone --recurse-submodules`; the `protobufs` submodule is required **at runtime** (loaded from the working directory), so a release tarball is not sufficient.
- The app source repo/ref is configured in [`scripts/_common.sh`](./scripts/_common.sh) (`source_repo` / `source_ref`).

## Documentation and resources

- Upstream app website: <https://meshmonitor.org>
- Upstream code repository: <https://github.com/yeraze/meshmonitor>
- Upstream deployment guide: <https://github.com/yeraze/meshmonitor/blob/main/docs/deployment/DEPLOYMENT_GUIDE.md>
- YunoHost documentation for this app: <https://yunohost.org/app_meshmonitor>

## Developer info

To try the testing branch:

```bash
sudo yunohost app install https://github.com/Crazypedia/meshmonitor_ynh/tree/testing --debug
# or
sudo yunohost app upgrade meshmonitor -u https://github.com/Crazypedia/meshmonitor_ynh/tree/testing --debug
```

**More info regarding app packaging:** <https://yunohost.org/packaging_apps>
