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
    # For Linux hosts
    if command -v systemctl &>/dev/null; then
        echo "→ Docker daemon not running—attempting to start via systemctl..."
        sudo systemctl start docker
        sudo systemctl enable docker
        sleep 5
    fi

    if docker info &>/dev/null; then    
        echo "✔ Docker service started successfully."
    else
        if sudo docker info &>/dev/null; then
            echo "  Docker is running under SUDO, but '$USER' isn't in the docker group."
            echo "  Adding '$USER' to group 'docker' so you can run w/o SUDO."
            sudo usermod -aG docker "$USER"
            echo
            echo "  You've been added to group 'docker'. Hooray!"
            echo "  Please restart your computer (or run 'newgrp docker') then re-run ./bootstrap.sh"
            exit 0
        else
            echo "ERROR: Docker daemon still not responding even under SUDO." >&2
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

export DOCKER_BUILDKIT=1
docker builder prune --all --force || true
docker image prune --all --force || true
docker build --no-cache -t secure-model-env:latest -f runner.Dockerfile .

if [[ "$OS" == "Linux" ]]; then
    if ! docker buildx version &>/dev/null; then
        if command -v apt &>/dev/null; then
            sudo apt update
            sudo apt install -y docker-buildx-plugin
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y docker-buildx-plugin
        else
            echo "Unable to auto-install BuildX on this Linux machine. BuildX may fail."
        fi
    fi
fi
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

echo "  Sending our Labrador Retriever to fetch the 'secret' Jenkins Initial Admin Password..."
if IAP=$(
    $COMPOSE_CMD exec -T jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null); then
    exit 0
elif IAP=$(
    $COMPOSE_CMD exec -T jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null); then
    exit 0
else
    echo 
    echo "  Permission is denied to access the password file within Jenkins' secrets folder."
    echo "  We need SUDO privileges to read './jenkins_home/secrets/initialAdminPassword'."
    echo "  You may be prompted to enter your password now..."
    IAP=$(sudo cat ./jenkins_home/secrets/initialAdminPassword)
fi

# At this point $IAP holds the password (or is empty if all attempts failed)
if [[ -z "$IAP" ]]; then
  echo "ERROR: Could not retrieve the Jenkins initialAdminPassword from any location." >&2
  exit 1
fi

echo
echo "✔ Jenkins is starting at http://localhost:8080"
echo ""
echo "  To unlock Jenkins, you need the initialAdminPassword." 
echo -e "  Your initialAdminPassword: >>>> \033[1;33m  $IAP \033[0m <<<<"
echo ""
echo "  You should copy/save this password locally for easy reference."
echo "  You can get your password again by running this command:"
echo "    'sudo cat ./jenkins_home/secrets/initialAdminPassword'"
