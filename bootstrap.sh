#!/usr/bin/env bash
set -euo pipefail

echo "[1/5] Checking Docker CLI..."
if ! command -v docker &>/dev/null; then
    # Docker CLI missing → try auto-install on Linux, else prompt Mac/Win
    OS="$(uname -s)"
    case "$OS" in
        Linux)
            echo "→ Docker CLI not found on Linux—installing via package manager..."
            if command -v apt &>/dev/null; then
                sudo apt update
                sudo apt install -y docker.io 

                if apt-cache show docker-compose-plugin &>/dev/null; then
                sudo apt install -y docker-compose-plugin
                else
                    echo "Installing 'docker-compose'"
                    sudo apt install -y docker-compose
                fi

            elif command -v dnf &>/dev/null; then
                sudo dnf install -y docker docker-compose-plugin
            else
                echo "ERROR: Unsupported Linux distro. Install Docker manually and rerun." >&2
                exit 1
            fi
            ;;
        Darwin)
            echo "ERROR: Docker CLI not found. Please install Docker Desktop for macOS:" \
                 "https://www.docker.com/products/docker-desktop" >&2
            exit 1
            ;;
        MINGW*|CYGWIN*|MSYS*|Windows_NT)
            echo "ERROR: Docker CLI not found. Please install Docker Desktop for Windows:" \
                 "https://www.docker.com/products/docker-desktop" >&2
            exit 1
            ;;
        *)
            echo "ERROR: Unrecognized OS ($OS). Please install Docker manually." >&2
            exit 1
            ;;
    esac
else
    echo "✔ Docker CLI already installed."
fi
echo "Done."



echo "[2/5] Verifying Docker daemon..."
if docker info &>/dev/null; then
    echo "✔ Docker daemon is running."
else
    # only attempt systemctl on Linux hosts
    if command -v systemctl &>/dev/null; then
        echo "→ Docker daemon not running—attempting to start via systemctl..."
        sudo systemctl start docker
        sudo systemctl enable docker
        sleep 5

        # re-check
        if docker info &>/dev/null; then
        
            echo "✔ Docker service started successfully."
        else
            echo "ERROR: Docker service still not responding after systemctl start." >&2
            echo "On linux distro, run 'sudo systemctl start docker' and rerun this bootstrap script."
            exit 1
        fi
    else
        echo "ERROR: Docker daemon is not running. Start Docker Desktop (macOS/Windows) or run 'sudo systemctl start docker' (Linux) and rerun bootstrap." >&2
        exit 1
    fi

    if docker info &>/dev/null; then
        echo "✔ Docker daemon is now running and accessible."
    else
        echo "⚠️ Docker daemon is running, but your user can’t access it (socket permission)."
        # Add you to the docker group if not already
        if ! groups "$USER" | grep -qw docker; then
          echo "→ Adding '$USER' to the docker group so you can run without sudo."
          sudo usermod -aG docker "$USER"
          echo "   Please log out and back in (or run 'newgrp docker') to apply the new group membership."
        fi

        # Final check via sudo
        if sudo docker info &>/dev/null; then
            echo "✔ Docker daemon is reachable via sudo. Once your group membership is applied, you’ll be able to run it unprivileged."
        else
            echo "ERROR: Even sudo can’t reach the daemon. Something’s wrong with your Docker install." >&2
            exit 1
        fi
    fi
fi
echo "Done."



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
