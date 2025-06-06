#!/usr/bin/env bash
set -euo pipefail

echo "[1/5] Checking Docker CLI..."
if ! command -v docker &>/dev/null; then
    cat <<-EOF >&2
    ERROR: Docker CLI not found.
    • On macOS/Windows: Install Docker Desktop -- docker.com/products/docker-desktop
    • On Linux: Install Docker Engine via your distro's pkg manager and ensure 'docker' 
    service is enabled.

    Then re-run this script.
EOF
    exit 1
else
    echo "Docker CLI found."
fi
echo "Done."



echo "[2/5] Verifying Docker daemon..."
if docker info &>/dev/null; then
    echo "✔ Docker daemon is running."
else
    cat <<-EOF >&2
    ERROR: Docker daemon is not running.
        • On macOS/Windows: Launch Docker Desktop
        • On Linux: Run these commands
            'sudo systemctl start docker' and
            'sudo usermod -aG docker \$USER' (to ensure your user is in the "docker" group)
    Then re-run this script.
EOF
exit 1
fi
echo "Done."



echo "[3/5] Checking KitOps..."
mkdir -p tools tools/tar

# fetch latest kitops release metadata
ARCH=$(uname -m)
case "$ARCH" in
  arm64|aarch64) FILTER='linux-arm64.*\.tar\.gz' ;;
  x86_64|amd64) FILTER='linux-x86_64.*\.tar\.gz' ;;
  *) echo "ERROR: unsupported arch $ARCH"; exit 1 ;;
esac

ASSET_URL=$(curl -fsSL https://api.github.com/repos/kitops-ml/kitops/releases/latest \
  | grep '"browser_download_url":' \
  | grep -E "$FILTER" \
  | head -n1 \
  | cut -d '"' -f4)

if [[ -z "$ASSET_URL" ]]; then
    echo "ERROR: Could not find KitOps download URL."
    exit 1
fi

# Download tarball
curl -fsSL "$ASSET_URL" -o tools/kitops.tar.gz

ENTRY="$(tar -tzf tools/kitops.tar.gz | grep -E '(^|/)(kit|kitops)$' | head -n1)"

if [[ -z "$ENTRY" ]]; then
    echo "ERROR: 'kit' binary not found inside the KitOps tarball. Contents:"
    tar -tzf tools/kitops.tar.gz
    exit 1
fi


DIRLEVEL=$(echo "$ENTRY" | awk -F'/' '{print NF-1}')
tar -xzf tools/kitops.tar.gz --strip-components="$DIRLEVEL" -C tools "$ENTRY"
mv tools/"$(basename "$ENTRY")" tools/kit
chmod +x tools/kit
mv tools/kitops.tar.gz tools/tar/

echo "✔ KitOps CLI available at tools/kit"
echo "Done..."



echo "[4/5] Building pipeline runner image…"
docker buildx build \
    --load \
    -t secure-model-env:latest \
    -f runner.Dockerfile \
    .
echo "Runner image built."
echo "Done..."



echo "[5/5] Launching Jenkins via Docker Compose…"
# detect open port
for p in {8080..8100}; do
    if ! lsof -Pi :$p -sTCP:LISTEN -t >/dev/null; then
        export JENKINS_HTTP_PORT=$p
        break
    fi
done

if [[ -z "${JENKINS_HTTP_PORT-}" ]]; then
    echo "ERROR: couldn't find a free port in 8080-8100 range. Please free one or set JENKINS_HTTP_PORT manually."
    exit 1
fi
echo "  Open port found: binding host port $JENKINS_HTTP_PORT to container 8080."

# detect whether to use `docker-compose` or `docker compose`
if command -v docker-compose &>/dev/null; then
  COMPOSE_CMD="docker-compose"
else
  COMPOSE_CMD="docker compose"
fi
$COMPOSE_CMD up -d --build
echo "Done..."



echo "Charging the Flux Capacitor to 1.21gw..."
sleep 3
echo "(actually, we're just waiting for Jenkins to initialize...)"
sleep 7

echo "  Sending our Labrador Retriever to fetch the 'secret' Jenkins Initial Admin Password..."
if IAP=$($COMPOSE_CMD exec -T jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null); then
    echo "Retrieved password"
elif IAP=$(cat ./jenkins_home/secrets/initialAdminPassword 2>/dev/null); then
    echo "Retrieved password"
else
    echo 
    echo "  Permission denied. We need SUDO privileges to read './jenkins_home/secrets/initialAdminPassword'."
    echo "  You may be prompted to enter your password now..."
    IAP=$(sudo cat ./jenkins_home/secrets/initialAdminPassword)
fi

echo
echo "✔ Jenkins is starting at http://localhost:$JENKINS_HTTP_PORT"
echo "=============================================================="
echo "  To unlock Jenkins, you need the initialAdminPassword." 

echo -e "  Your password is: >>>> \033[1;33m  $IAP \033[0m <<<<"
echo 
echo "  Copy that and paste it into the Jenkins unlock screen."
echo ""
echo "  You should copy/save this password locally for easy reference."
echo
echo "  You can retrieve your password again by running this command:"
echo
echo "    'sudo cat ./jenkins_home/secrets/initialAdminPassword'"
echo "=============================================================="
