#!/usr/bin/env bash
set -euo pipefail

# Re-run as root if needed
if [[ "${EUID}" -ne 0 ]]; then
  exec sudo bash "$0" "$@"
fi

echo "[1/3] Checking Docker is installed and running…"
if ! command -v docker >/dev/null 2>&1; then
  echo "❌ Docker not found. Please run install_docker.sh first."
  exit 1
fi
if ! systemctl is-active --quiet docker; then
  echo "⚠️  Docker service is not active. Starting…"
  systemctl start docker || true
fi

echo "[2/3] Downloading latest KIND binary…"
TMP_FILE="$(mktemp)"
# The 'latest' URL is maintained by the KIND project and resolves to the current release
curl -fsSL -o "${TMP_FILE}" "https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64"

echo "[3/3] Installing KIND to /usr/local/bin …"
install -m 0755 "${TMP_FILE}" /usr/local/bin/kind
rm -f "${TMP_FILE}"

echo
echo "✅ KIND installed: $(kind --version)"
echo
echo "Quick start:"
echo "  kind create cluster --name dev"
echo "  kubectl get nodes"
