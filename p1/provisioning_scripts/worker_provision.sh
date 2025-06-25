#!/bin/bash
set -e

# Define constants
SHARED_TOKEN_PATH="/vagrant_shared/node-token"

# Wait for node-token to be available
for i in {1..20}; do
  if [ -f "$SHARED_TOKEN_PATH" ]; then
    echo "[INFO] node-token found."
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

TOKEN=$(cat "$SHARED_TOKEN_PATH")
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 K3S_TOKEN=$TOKEN sh -s - --node-ip=192.168.56.111 || { echo "Failed to install K3s"; exit 1; }