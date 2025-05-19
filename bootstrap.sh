#!/usr/bin/env bash
set -euo pipefail

TOOLS_DIR=tools

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
mkdir -p "$TOOLS_DIR" #"$TOOLS_DIR"/kit 
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
curl -fsSL "$ASSET_URL" -o "$TOOLS_DIR/kitops.tar.gz"
# tar -xzf "$TOOLS_DIR/kitops.tar.gz" -C "$TOOLS_DIR"

# Flatten kit binary
tar -xzf "$TOOLS_DIR/kitops.tar.gz" --strip-components=2 -C "$TOOLS_DIR/kit"
chmod +x "$TOOLS_DIR/kit"
rm "$TOOLS_DIR/kitops.tar.gz"
echo "✔ KitOps CLI available at tools/kit"
echo "Done..."
# 3. Move the 'kit' binary to a known path
# mv "$TOOLS_DIR/kit" "$TOOLS_DIR/kit"
# chmod +x "$TOOLS_DIR/kit"
# rm -rf "$TOOLS_DIR"/kitops-* "$TOOLS_DIR/kitops.tar.gz"
# echo "  KitOps CLI available at $TOOLS_DIR/kit"



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
echo "  Your initialAdminPassword: `docker exec -it jenkins bash -lc 'cat /var/jenkins_home/secrets/initialAdminPassword'`"
echo "  You can get your password again by running this command:"
echo "    docker exec -it jenkins bash -lc 'cat /var/jenkins_home/secrets/initialAdminPassword'"
