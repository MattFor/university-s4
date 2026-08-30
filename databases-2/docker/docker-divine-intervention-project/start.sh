#!/bin/bash

set -e

echo "[INFO] Checking required packages..."

if ! xbps-query -l docker-compose >/dev/null 2>&1; then
    echo "[INFO] Installing docker-compose..."
    sudo xbps-install -Sy docker-compose
fi

if ! xbps-query -l docker-buildx >/dev/null 2>&1; then
    echo "[INFO] Installing docker-buildx..."
    sudo xbps-install -Sy docker-buildx
fi

echo "[INFO] Stopping existing containers (if any)..."
docker compose down -v || true

echo "[INFO] Building and starting project..."
docker compose up --build
