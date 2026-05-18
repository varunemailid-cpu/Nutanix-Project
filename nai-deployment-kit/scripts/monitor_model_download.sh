#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${ENV_FILE:-${KIT_DIR}/config/env_nai.sh}"
POD="${1:-}"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing env file: ${ENV_FILE}"
  exit 1
fi

# shellcheck source=/dev/null
source "${ENV_FILE}"
export KUBECONFIG

if [[ -z "${POD}" ]]; then
  POD="$(kubectl -n "${NAI_NAMESPACE}" get pods --sort-by=.metadata.creationTimestamp \
    | awk '/model-job/ {pod=$1} END {print pod}')"
fi

if [[ -z "${POD}" ]]; then
  echo "No model-job pod found in namespace ${NAI_NAMESPACE}."
  kubectl -n "${NAI_NAMESPACE}" get pods
  exit 1
fi

echo "Monitoring model job pod: ${POD}"
echo
kubectl -n "${NAI_NAMESPACE}" get pod "${POD}" -o wide
echo
kubectl -n "${NAI_NAMESPACE}" describe pod "${POD}" | tail -n 120
echo
kubectl -n "${NAI_NAMESPACE}" get events --sort-by=.lastTimestamp | tail -n 40
echo
echo "Recent logs:"
kubectl -n "${NAI_NAMESPACE}" logs "${POD}" --tail="${LOG_TAIL:-200}" || true

if [[ "${FOLLOW:-false}" == "true" ]]; then
  echo
  echo "Following logs. Press Ctrl+C to stop."
  kubectl -n "${NAI_NAMESPACE}" logs "${POD}" -f
fi
