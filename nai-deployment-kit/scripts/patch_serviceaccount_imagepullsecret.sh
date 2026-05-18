#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${ENV_FILE:-${KIT_DIR}/config/env_nai.sh}"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing env file: ${ENV_FILE}"
  exit 1
fi

# shellcheck source=/dev/null
source "${ENV_FILE}"
export KUBECONFIG

if [[ -z "${NGC_IMAGE_PULL_SECRET:-}" || "${NGC_IMAGE_PULL_SECRET}" == CHANGE_ME* ]]; then
  echo "Set NGC_IMAGE_PULL_SECRET in ${ENV_FILE}."
  exit 1
fi

kubectl -n "${NAI_NAMESPACE}" get secret "${NGC_IMAGE_PULL_SECRET}" >/dev/null

kubectl -n "${NAI_NAMESPACE}" patch serviceaccount "${IMAGE_PULL_SERVICEACCOUNT:-default}" \
  --type merge \
  -p "{\"imagePullSecrets\":[{\"name\":\"${NGC_IMAGE_PULL_SECRET}\"}]}"

kubectl -n "${NAI_NAMESPACE}" get serviceaccount "${IMAGE_PULL_SERVICEACCOUNT:-default}" -o yaml
