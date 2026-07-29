MeshMonitor is installed and starting up.

**First login:** open the app and sign in with `admin` / `changeme`, then change the password immediately under the admin settings.

**Meshtastic connection:** the node IP/port you entered are written to `__INSTALL_DIR__/.env`. Do not hand-edit that file — it is regenerated from your app settings on every upgrade, so edits are reverted. To point MeshMonitor at a different node:

```bash
sudo yunohost app setting meshmonitor node_ip -v 192.168.1.123
sudo yunohost app setting meshmonitor node_port -v 4403
sudo yunohost app upgrade meshmonitor -F
```

It can take a minute or two after install for MeshMonitor to establish the connection to your node.

**MQTT bridge (outbound):** works with no extra setup. The bridge is an MQTT *client* — it dials out to an upstream broker such as `mqtt://mqtt.meshtastic.org:1883`, so no inbound firewall port is involved. Configure it in the dashboard.

**MQTT broker (inbound):** MeshMonitor can also *host* an embedded MQTT broker for your own devices to connect into. That one listens on a TCP port (1883 by default) which YunoHost's firewall blocks. After enabling it in the dashboard, open the port:

```bash
sudo yunohost firewall allow TCP/1883
```

**ATAK / CoT feed (inbound):** likewise off by default and, once enabled, listens on TCP 8088 and needs `sudo yunohost firewall allow TCP/8088`.

Only open these if you actually enable the corresponding feature.
