MeshMonitor is installed and starting up.

**Single sign-on:** if you installed with the `all_users` permission (the default), just open the app while logged into your YunoHost portal — you are signed in automatically, no MeshMonitor password needed. Users whose email you listed as administrator get admin rights; everyone else starts read-only.

**Break-glass login:** a built-in `admin` / `changeme` account also exists for emergencies. If you rely on it, sign in once and change the password under the admin settings.

**Meshtastic connection:** the node IP/port you entered are written to `__INSTALL_DIR__/.env`. If the node moves or is unreachable, edit that file (or reinstall) and restart the service.

It can take a minute or two after install for MeshMonitor to establish the connection to your node.
