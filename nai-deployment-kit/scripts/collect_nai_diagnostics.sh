#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${ENV_FILE:-${KIT_DIR}/config/env_nai.sh}"
LOG_DIR="${LOG_DIR:-${KIT_DIR}/logs/nai-diag-$(date +%Y%m%d-%H%M%S)}"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing env file: ${ENV_FILE}"
  exit 1
fi

# shellcheck source=/dev/null
source "${ENV_FILE}"
export KUBECONFIG

mkdir -p "${LOG_DIR}"

kubectl cluster-info > "${LOG_DIR}/cluster-info.txt" 2>&1 || true
kubectl get nodes -o wide > "${LOG_DIR}/nodes.txt" 2>&1 || true
kubectl -n "${NAI_NAMESPACE}" get all -o wide > "${LOG_DIR}/nai-all.txt" 2>&1 || true
kubectl -n "${NAI_NAMESPACE}" get pods -o yaml > "${LOG_DIR}/nai-pods.yaml" 2>&1 || true
kubectl -n "${NAI_NAMESPACE}" get events --sort-by=.lastTimestamp > "${LOG_DIR}/nai-events.txt" 2>&1 || true
kubectl -n "${NAI_NAMESPACE}" get ingress -o yaml > "${LOG_DIR}/nai-ingress.yaml" 2>&1 || true
kubectl -n "${NAI_NAMESPACE}" get inferenceservice -o yaml > "${LOG_DIR}/inferenceservices.yaml" 2>&1 || true

while read -r pod; do
  [[ -z "${pod}" ]] && continue
  kubectl -n "${NAI_NAMESPACE}" logs "${pod}" --all-containers --tail="${LOG_TAIL:-300}" > "${LOG_DIR}/${pod}.log" 2>&1 || true
  kubectl -n "${NAI_NAMESPACE}" describe pod "${pod}" > "${LOG_DIR}/${pod}.describe.txt" 2>&1 || true
done < <(kubectl -n "${NAI_NAMESPACE}" get pods -o name | sed 's#pod/##')

echo "Diagnostics written to ${LOG_DIR}"
