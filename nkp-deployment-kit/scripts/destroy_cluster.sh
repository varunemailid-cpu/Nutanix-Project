#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${ENV_FILE:-${KIT_DIR}/config/env_variables.sh}"
TARGET_CLUSTER="${1:-${CLUSTER_NAME:-}}"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing env file: ${ENV_FILE}"
  exit 1
fi

# shellcheck source=/dev/null
source "${ENV_FILE}"

TARGET_CLUSTER="${1:-${CLUSTER_NAME:-}}"
if [[ -z "${TARGET_CLUSTER}" || "${TARGET_CLUSTER}" == CHANGE_ME* ]]; then
  echo "Usage: $0 <cluster-name>"
  echo "Or set CLUSTER_NAME in ${ENV_FILE}."
  exit 1
fi

echo "This will destroy NKP cluster: ${TARGET_CLUSTER}"
read -r -p "Type the cluster name to confirm: " confirmation
if [[ "${confirmation}" != "${TARGET_CLUSTER}" ]]; then
  echo "Confirmation did not match. Aborting."
  exit 1
fi

nkp delete cluster "${TARGET_CLUSTER}"
