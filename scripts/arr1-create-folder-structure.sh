#!/usr/bin/env bash

set -e

ENV_FILE="../.env"

if [[ -f "$ENV_FILE" ]]; then
  source "$ENV_FILE"
else
  echo "can't find .env file"
fi

echo "Using data path: $ARRPATH"

# Create directories
mkdir -p "$ARRPATH"/{torrents,media}/{movies,tv,books}

# Config directories
mkdir -p config/{radarr,sonarr,readarr,prowlarr,qbittorrent,bazarr,jellyfin,jellyseerr,homarr,recyclarr,maintainerr}

# Ownership
chown -R "${PUID:-1000}:${PGID:-1000}" "$ARRPATH" config

echo "Folder structure created and permissions applied"
