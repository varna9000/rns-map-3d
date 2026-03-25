#!/bin/bash
# install.sh  -  Set up rns-map on Ubuntu 22.04
#
# Prerequisites:
#   - rnsd must already be installed and running as a systemd service.
#     rns-map attaches to rnsd as a shared-instance client.
#   - Place rns_map.py in ~/rns-map/
#   - Place static/index.html in ~/rns-map/static/
#   - Place rns-map.service in ~/rns-map/
#   - Edit reticulum-config/config to match your interface (see config.example)
#
# Run as the user who will own the service (not root).
set -e

echo "==> Creating directories"
mkdir -p ~/rns-map/static

echo "==> Creating Python venv"
python3 -m venv ~/rns-map/venv

echo "==> Installing Python packages"
~/rns-map/venv/bin/pip install --upgrade pip --quiet
~/rns-map/venv/bin/pip install \
    "rns==1.1.3" \
    "aiohttp==3.9.5" \
    "msgpack==1.1.2" \
    --quiet

echo "==> Installing systemd service"
sudo cp ~/rns-map/rns-map.service /etc/systemd/system/rns-map.service
sudo systemctl daemon-reload
sudo systemctl enable rns-map.service

echo ""
echo "Done. Start with:"
echo "  sudo systemctl start rns-map"
echo "  journalctl -u rns-map -f"
echo ""
echo "Then open http://$(hostname -I | awk '{print $1}'):8085 in your browser."
