#!/usr/bin/env bash
set -euo pipefail

echo "[1/5] Checking Docker CLI..."
if ! command -v docker &>/dev/null; then
  echo "Error: Docker is not installed or not in PATH."
  exit 1
fi
echo "Done..."



echo "[2/5] Verifying Docker daemon..."
if ! docker info &>/dev/null; then
  echo "Error: Docker daemon is not running. Please start Docker."
  exit 1
fi
echo "✔ Docker is available and running."
echo "Done..."



echo "[3/5] Checking KitOps..."
mkdir -p tools
RESPONSE=$(curl -s https://api.github.com/repos/kitops-ml/kitops/releases/latest)
ASSET_URL=$(printf '%s\n' "$RESPONSE" \
  | grep '"browser_download_url":' \
  | grep 'linux.*tar.gz' \
  | head -n1 \
  | cut -d '"' -f4)

ASSET_URL=$(printf '%s' "$ASSET_URL" | tr -d ' \r\n')

if [[ -z "$ASSET_URL" ]]; then
  echo "Error: could not find KitOps asset URL."
  exit 1
fi

# 2. Download, flatten, and extract
curl -fsSL "$ASSET_URL" -o tools/kitops.tar.gz

# Flatten kit binary
tar -xzf tools/kitops.tar.gz --strip-components=1 -C tools "kitops-*/kit"
chmod +x tools/kit
rm tools/kitops.tar.gz
echo "✔ KitOps CLI available at tools/kit"
echo "Done..."



echo "[4/5] Building pipeline runner image…"
docker build -t secure-model-env:latest -f runner.Dockerfile .
echo "Done..."



echo "[5/5] Launching Jenkins via Docker Compose…"
# detect whether to use `docker-compose` or `docker compose`
if command -v docker-compose &>/dev/null; then
  COMPOSE_CMD="docker-compose"
elif docker compose version &>/dev/null; then
  COMPOSE_CMD="docker compose"
else
  echo "Error: Docker Compose not found."
  exit 1
fi

$COMPOSE_CMD up -d --build

echo
echo "✔ Jenkins is starting at http://localhost:8080"
echo "  To unlock Jenkins, you need the initialAdminPassword." 
echo "  Your initialAdminPassword: $(docker exec -it jenkins bash -lc 'cat /var/jenkins_home/secrets/initialAdminPassword')"
echo "  You can get your password again by running this command:"
echo "    docker exec -it jenkins bash -lc 'cat /var/jenkins_home/secrets/initialAdminPassword'"
