#!/usr/bin/env bash
set -euo pipefail

echo "[1/5] Checking Docker CLI..."
if ! command -v docker &>/dev/null; then
    echo "ERROR: Docker CLI not found. Please install Docker (Docker Desktop on macOS/Windows) and rerun."
    echo "For Linux, we'll install via package manager now." >&2
else
    echo "Docker already installed. Continuing..."
fi

if command -v docker &>/dev/null; then
    echo "Docker CLI found."
else
    OS="$(uname -s)"
    case "$OS" in
        Linux)
            echo "Docker not found on Linux - installing via package manager..."
            if command -v apt &>/dev/null; then
                sudo apt update
                sudo apt-get install -y docker.io docker-compose-plugin
            elif command -v dnf &>/dev/null; then
                sudo dnf install -y docker docker-compose-plugin
            else
                echo "ERROR: Unsupported Linux distro. Install Docker manually and rerun." >&2
                exit 1
            fi
            ;;
        Darwin)
            echo "ERROR: Docker not installed. Please install Docker Desktop for Mac:" \
            "https://www.docker.com/products/docker-desktop" >&2
            exit 1
            ;;
        MINGW*|CYGWIN*|MSYS*|Windows_NT)
            echo "ERROR: Docker not installed. Please install Docker Desktop for Windows:" \
            "https://www.docker.com/products/docker-desktop" >&2
            exit 1
            ;;
        *)
            echo "ERROR: Unrecognized OS ($OS). Please install Docker manually." >&2
            exit 1
            ;;
    esac
echo "Done..."



echo "[2/5] Verifying Docker daemon..."
if docker info &>/dev/null; then
    echo "Docker is running"
else
    #check if you're on a system with 'systemd' and try to start it
    if command -v systemctl &>/dev/null; then
        echo "Docker not running -- attempting to start via systemctl..."
        sudo systemctl start docker
        sudo systemctl enable docker

        if docker info &>/dev/null; then
            echo "Docker started successfully."
        else
            echo "Docker still is not responding after systemctlstart." >&2
            exit 1
        fi
else
    echo "ERROR: Docker daemon is not running. Please start Docker Desktop (macOS/Windows) or run 'sudo systemctl start docker' (Linux) and rerun bootstrap." >&2
    exit 1
fi
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

echo "Charging the Flux Capacitor to 1.21gw..."
sleep 3
echo "(actually, we're just waiting for Jenkins to initialize...)"
sleep 7

IAP=$(
    $COMPOSE_CMD exec -T jenkins cat /var/jenkins_home/secrets/initialAdminPassword \
   || $COMPOSE_CMD exec -T jenkins cat ./jenkins_home/secrets/initialAdminPassword
)
echo
echo "✔ Jenkins is starting at http://localhost:8080"
echo ""
echo "  To unlock Jenkins, you need the initialAdminPassword." 
echo -e "  Your initialAdminPassword: >>>> \033[1;33m  $IAP \033[0m <<<<"
echo ""
echo "  You should copy/save this password locally for easy reference."
echo "  You can get your password again by running this command:"
echo "    'sudo cat ./jenkins_home/secrets/initialAdminPassword'"
