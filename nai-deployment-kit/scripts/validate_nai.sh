#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${ENV_FILE:-${KIT_DIR}/config/env_nai.sh}"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing env file: ${ENV_FILE}"
  echo "Copy config/env_nai.example.sh to config/env_nai.sh and edit it first."
  exit 1
fi

# shellcheck source=/dev/null
source "${ENV_FILE}"
export KUBECONFIG

echo "KUBECONFIG=${KUBECONFIG}"
kubectl cluster-info
kubectl get nodes -o wide
kubectl get ns | grep -i nai || true
kubectl -n "${NAI_NAMESPACE}" get pods -o wide
kubectl -n "${NAI_NAMESPACE}" get svc
kubectl -n "${NAI_NAMESPACE}" get ingress || true
kubectl -n "${NAI_NAMESPACE}" get inferenceservice 2>/dev/null || true

echo
echo "Non-running NAI pods:"
kubectl -n "${NAI_NAMESPACE}" get pods | awk 'NR == 1 || ($3 != "Running" && $3 != "Completed")'

echo
echo "GPU-related nodes:"
kubectl get nodes -L nvidia.com/gpu.product 2>/dev/null || true
