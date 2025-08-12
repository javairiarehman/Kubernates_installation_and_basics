#!/usr/bin/env bash
set -euo pipefail

# Re-run as root if needed
if [[ "${EUID}" -ne 0 ]]; then
  exec sudo bash "$0" "$@"
fi

echo "[1/5] Installing prerequisites…"
apt-get update -y
apt-get install -y ca-certificates curl apt-transport-https gnupg

echo "[2/5] Adding Kubernetes apt repo (stable)…"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key \
  | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
chmod a+r /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" \
  > /etc/apt/sources.list.d/kubernetes.list

echo "[3/5] Installing kubectl…"
apt-get update -y
apt-get install -y kubectl

echo "[4/5] (Optional) Enable bash completion for kubectl…"
if command -v kubectl >/dev/null 2>&1; then
  KUBE_COMPLETION="/etc/bash_completion.d/kubectl"
  kubectl completion bash > "${KUBE_COMPLETION}" || true
fi

echo "[5/5] Verifying kubectl…"
echo "kubectl version --client=true --output=yaml:"
kubectl version --client=true --output=yaml || true

echo
echo "✅ kubectl installed."
echo "Tip: If you just created a KIND cluster, test with:  kubectl get nodes"
