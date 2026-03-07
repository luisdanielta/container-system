#!/usr/bin/env bash
set -e

# Prevent docker daemon from starting if not found
if ! command -v dockerd &>/dev/null; then
  echo "[INFO] dockerd not found. Skipping Docker daemon startup."
  exit 0
fi

# Start docker daemon
echo "[INFO] Starting Docker daemon..."
dockerd > /var/log/dockerd.log 2>&1 &

while ! docker info > /dev/null 2>&1; do
    sleep 1
done

echo "[INFO] Docker daemon is up"

if ! docker info > /dev/null 2>&1; then
  echo "[ERROR] Docker daemon failed to start. Exiting."
  exit 1
fi

CONFIG_MARKER="/.docker_configured"
if [ ! -f "$CONFIG_MARKER" ]; then
  echo "[INFO] Applying one-time Docker group configuration..."
  groupadd docker || true
  usermod -aG docker "${USERNAME}" || true
  touch "$CONFIG_MARKER"
else
  echo "[INFO] Docker group already configured. Skipping."
fi

exec "$@"