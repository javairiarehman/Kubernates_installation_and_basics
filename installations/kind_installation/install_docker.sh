#!/usr/bin/env bash
set -euo pipefail

# Re-run as root if needed
if [[ "${EUID}" -ne 0 ]]; then
  exec sudo bash "$0" "$@"
fi

echo "[1/6] Removing old Docker versions (if any)…"
apt-get remove -y docker docker-engine docker.io containerd runc || true

echo "[2/6] Updating apt and installing prerequisites…"
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release apt-transport-https

echo "[3/6] Setting up Docker’s official GPG key…"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo "[4/6] Adding Docker apt repository…"
ARCH="$(dpkg --print-architecture)"
CODENAME="$(lsb_release -cs)"
echo \
  "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${CODENAME} stable" \
  > /etc/apt/sources.list.d/docker.list

echo "[5/6] Installing Docker Engine, CLI, containerd, Buildx & Compose plugin…"
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "[6/6] Enabling and starting Docker…"
systemctl enable docker
systemctl start docker

# Add invoking user to docker group
TARGET_USER="${SUDO_USER:-${USER}}"
if ! getent group docker >/dev/null; then
  groupadd docker
fi
usermod -aG docker "${TARGET_USER}"

echo
echo "✅ Docker installed."
echo "👤 Added user '${TARGET_USER}' to 'docker' group."
echo "ℹ️  You must open a NEW terminal (or log out/in) for group changes to apply."
echo "   (Optional) In this shell, you can run: newgrp docker"
echo
echo "Quick test (after new session):  docker run --rm hello-world"
