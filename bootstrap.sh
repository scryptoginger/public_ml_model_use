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
mkdir -p tools tools/tar
RESPONSE=$(curl -s https://api.github.com/repos/kitops-ml/kitops/releases/latest)
ASSET_URL=$(printf '%s\n' "$RESPONSE" \
  | grep '"browser_download_url":' \
  | grep 'linux.*tar.gz' \
  | head -n1 \
  | cut -d '"' -f4 \
  | tr -d ' \r\n')

# Download tarball
curl -fsSL "$ASSET_URL" -o tools/kitops.tar.gz
# tar -xzf tools/kitops.tar.gz --strip-components=1 -C tools
tar -xzf tools/kitops.tar.gz -C tools
chmod +x tools/kit
mv tools/kitops.tar.gz tools/tar/
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

export TIMESTAMP=$(date +%s)
echo "Using Jenkins 'container_name': jenkins_${TIMESTAMP}"

$COMPOSE_CMD up -d --build

docker exec -u root jenkins chmod a+r /jenkins_home/secrets/initialAdminPassword

echo "Charging the Flux Capacitor to 1.21gw..."
sleep 3
echo "(actually, we're just waiting for Jenkins to initialize...)"
sleep 7

IAP=$(
    cat ./jenkins_home/secrets/initialAdminPassword || \
    cat /jenkins_home/secrets/initialAdminPassword
)

echo
echo "✔ Jenkins is starting at http://localhost:8080"
echo ""
echo "  To unlock Jenkins, you need the initialAdminPassword." 
echo -e "  Your initialAdminPassword: >>>> \033[1;33m  $IAP \033[0m <<<<"
echo ""
echo "  You can get your password again by running this command:"
echo "    'cat ./jenkins_home/secrets/initialAdminPassword'"
