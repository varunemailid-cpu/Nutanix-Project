#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${ENV_FILE:-${KIT_DIR}/config/env_variables.sh}"

if [[ -f "${ENV_FILE}" ]]; then
  # shellcheck source=/dev/null
  source "${ENV_FILE}"
fi

if [[ -n "${KUBECONFIG_DIR:-}" && -n "${CLUSTER_NAME:-}" && -z "${KUBECONFIG:-}" ]]; then
  export KUBECONFIG="${KUBECONFIG_DIR}/${CLUSTER_NAME}-kubeconfig.yaml"
fi

echo "KUBECONFIG=${KUBECONFIG:-not-set}"
kubectl cluster-info
kubectl get nodes -o wide
kubectl get pods -A
kubectl get svc -A
kubectl get ingress -A || true

if command -v nkp >/dev/null 2>&1; then
  nkp get clusters || true
  if [[ -n "${CLUSTER_NAME:-}" ]]; then
    nkp describe cluster "${CLUSTER_NAME}" || true
  fi
  nkp get dashboard || true
fi
