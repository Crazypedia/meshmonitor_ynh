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
- **Authentication** — installs with the YunoHost permission set to `visitors`; MeshMonitor enforces its own login. Default credentials are `admin` / `changeme` — **change them immediately** after first login.
- **Build resources** — the app compiles native modules (`bcrypt`, `better-sqlite3`, `re2`) and a React frontend at install time. Allow ~2 GB RAM and a few minutes for the build.
- **Subpath installs** — supported via the app's `BASE_URL`; both root (`/`) and subpath (`/meshmonitor`) work. The frontend is always built for `/` and the server rewrites asset paths at runtime, so no rebuild is needed to change the path.

## Networking: which features need a firewall port

Only the main web UI is reachable through YunoHost's nginx. MeshMonitor's other listeners are opt-in and bind their own TCP ports, which the YunoHost firewall blocks by default:

| Feature | Direction | Port | Needs firewall change |
|---|---|---|---|
| Web UI | inbound via nginx | — | No (handled by YunoHost) |
| Meshtastic node connection | outbound | 4403 | No |
| **MQTT bridge** (client → upstream broker) | outbound | — | **No** |
| **MQTT broker** (embedded, devices → MeshMonitor) | inbound | 1883 (configurable) | **Yes** — `yunohost firewall allow TCP/1883` |
| ATAK / CoT feed | inbound | 8088 (configurable) | **Yes** — `yunohost firewall allow TCP/8088` |

The MQTT *bridge* and the embedded MQTT *broker* are different features. The bridge — the common case, for uplinking to `mqtt.meshtastic.org` — needs no firewall change at all.

## Known limitations of this package

- **Apprise notifications are not available.** The Docker image and the upstream LXC template provision a Python virtualenv at `/opt/apprise-venv` plus a sidecar Apprise API service; this package does not. Notification targets that route through Apprise will not work.
- **User scripts do not run.** Upstream resolves script interpreters as `/usr/local/bin/node` and `/opt/apprise-venv/bin/python3` whenever `NODE_ENV=production` and `IS_DESKTOP` is unset — paths that only exist inside the Docker image. Neither exists on a YunoHost install, so the scripting feature fails until this is fixed upstream.
- **Firmware OTA** shells out to a `meshtastic` CLI that this package does not install.

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
