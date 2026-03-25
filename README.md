# rns-map

A live Reticulum network visualiser. Listens for announces on a Reticulum mesh
network and displays nodes in real time on an interactive dartboard-style map,
colour-coded by application type (LXMF, Nomadnet, Propagation, Audio).

Built for Ubuntu 22.04 with an RNode LoRa interface. The web UI is
mobile-responsive and served locally — no internet connection required after
installation.

![rns-map screenshot](https://raw.githubusercontent.com/fotografm/rns-map/main/screenshot.png)

---

## Architecture

```
RNode (LoRa hardware)
        |
      rnsd  <-- systemd service, owns the RNode interface
        |       uses reticulum-config/config
        |
   rns_map.py  <-- attaches as a shared-instance client (RNS.Reticulum())
        |           does NOT own its own interfaces
        |
   aiohttp HTTP/WS server on port 8085
        |
   browser  <--  static/index.html (SVG dartboard, live WebSocket feed)
```

**rns-map is a client of rnsd, not a standalone RNS node.**
rnsd must be running before rns-map starts. If you already run rnsd for
MeshChat or Nomadnet, rns-map shares that same RNS instance at no extra cost.

---

## Requirements

- Ubuntu 22.04 (tested; other Debian-based distros likely work)
- Python 3.10+
- `rnsd` running as a systemd service with an active interface
- An RNode LoRa device on `/dev/ttyUSB0` (or edit config accordingly)
- The installing user must have permission to copy a systemd unit file

---

## Installation

**1. Clone the repo:**

```bash
git clone https://github.com/fotografm/rns-map.git ~/rns-map
```

**2. Configure Reticulum:**

```bash
cp ~/rns-map/reticulum-config/config.example ~/rns-map/reticulum-config/config
```

Edit `reticulum-config/config` to match your hardware (port, frequency, region).

**3. Ensure rnsd is installed and running.**

rns-map connects to rnsd as a shared-instance client. If rnsd is not already
set up, install it first via the Reticulum package:

```bash
pip install rns
```

Then create a systemd service for rnsd that uses `~/rns-map/reticulum-config`
as its config directory.

**4. Run the install script:**

```bash
bash ~/rns-map/install.sh
```

This creates a Python venv, installs dependencies, and installs the systemd service.

**5. Start the service:**

```bash
sudo systemctl start rns-map
journalctl -u rns-map -f
```

**6. Open in browser:**

```
http://<your-vm-ip>:8085
```

---

## Dependencies (pinned)

| Package     | Version |
|-------------|---------|
| rns         | 1.1.3   |
| aiohttp     | 3.9.5   |
| msgpack     | 1.1.2   |

---

## Service management

```bash
sudo systemctl status rns-map
sudo systemctl restart rns-map
sudo systemctl stop rns-map
journalctl -u rns-map -f
```

---

## API endpoints

| Method | Path        | Description                          |
|--------|-------------|--------------------------------------|
| GET    | `/`         | Serves the web UI (index.html)       |
| GET    | `/ws`       | WebSocket — live announce events     |
| GET    | `/activity` | JSON: per-minute announce counts     |
| POST   | `/reset`    | Wipe node database, reset the map    |

---

## WebSocket message types

All messages are JSON.

**`state`** — sent once on connect, full node list:
```json
{"type": "state", "nodes": [...]}
```

**`announce`** — new or updated node:
```json
{"type": "announce", "node": {"hash": "...", "name": "...", "app_type": "lxmf", "hops": 2, "first_seen": 1234567890.0, "last_seen": 1234567890.0}, "ts": 1234567890.0}
```

**`reset`** — node DB has been wiped:
```json
{"type": "reset"}
```

---

## Node types

| Colour | Type          | Aspect filter          |
|--------|---------------|------------------------|
| Cyan   | LXMF          | `lxmf.delivery`        |
| Green  | Nomadnet      | `nomadnetwork.node`    |
| Orange | Propagation   | `lxmf.propagation`     |
| Purple | Audio         | `call.audio`           |

---

## Hop rings

The dartboard rings represent hop distance from this node:

- **Centre** — Direct (0 hops)
- **Ring 1** — 1 hop
- **Ring 2** — 2 hops
- **Ring 3** — 3+ hops

---

## Licence

MIT
