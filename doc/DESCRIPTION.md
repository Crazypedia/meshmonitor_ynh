MeshMonitor is a self-hosted web dashboard for monitoring and managing a [Meshtastic](https://meshtastic.org/) mesh network. It connects to a Meshtastic node over TCP and provides:

- Live map of nodes, positions and signal quality
- Message history and channel activity
- Node telemetry, neighbour info and traceroutes
- Network statistics and charts
- Firmware OTA helpers and device configuration

This package runs MeshMonitor directly on Node.js (no Docker), following the upstream bare-metal deployment, behind YunoHost's nginx with HTTPS.

**Note:** MeshMonitor needs network access to your Meshtastic node's TCP port (default 4403). The node must be reachable from the YunoHost server.
