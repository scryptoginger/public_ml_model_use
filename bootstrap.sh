#!/bin/bash
set -e

echo "[1/3] Checking Docker Desktop..."

if ! command -v docker &> /dev/null; then
    echo "Docker not found --> Install Docker Desktop for your operating system..."
    exit 1
fi

echo "[1.5/3] Verifying Docker daemon..."
if ! docker info &>/dev/null; then
    echo "Error: Docker daemon is not runnong. Please start Docker."
    exit 1
fi
echo "Good news! Docker is available and running!"

echo "[2/3] Locating Docker Compose..."
if command -v docker-compose &>/dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &>/dev/null; then
    COMPOSE_CMD="docker compose"
else
    echo "Error: Neither 'docker-compose' nor 'docker compose' is available."
    exit 1
fi


echo "[3/3] Checking Jenkins..."
$COMPOSE_CMD up -d --build

echo "Jenkins is started and running at http://localhost:8080"
echo "  You need the default admin password, which can be found"
echo "  by running this: `docker exec -it jenkins bash -lc 'cat /var/jenkins_home/secrets/initialAdminPassword'`"
echo "  open this link in your browser and complete the setup wizard. (See README for more details)."