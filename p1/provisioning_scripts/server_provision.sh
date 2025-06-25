#!/bin/bash
set -e

# Constants for token paths
K3S_TOKEN_PATH="/var/lib/rancher/k3s/server/node-token"
SHARED_TOKEN_PATH="/vagrant_shared/node-token"

# Install K3s
curl -sfL https://get.k3s.io | sh -s - --node-ip=192.168.56.110 --write-kubeconfig-mode 644 || { echo "Failed to install K3s"; exit 1; }

# Wait for node-token to be created
for i in {1..20}; do
  if [ -f "$K3S_TOKEN_PATH" ]; then
    echo "[INFO] node-token found."
    sudo cp "$K3S_TOKEN_PATH" "$SHARED_TOKEN_PATH"
    break
  else
    echo "[INFO] Waiting for node-token..."
    sleep 3
  fi
done

if [ ! -f "$SHARED_TOKEN_PATH" ]; then
  echo "[ERROR] node-token not found after waiting."
  exit 1
fi
