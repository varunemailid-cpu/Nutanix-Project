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

check_block='
set +e
for host in "$@"; do
  echo "== ${host} =="
  getent hosts "${host}" || true
  timeout 5 bash -lc "</dev/tcp/${host}/443" && echo "TCP_443_OK" || echo "TCP_443_FAIL"
  curl -sk --max-time 15 "https://${host}/" -o /dev/null -w "curl_exit=%{exitcode} http_code=%{http_code}\n" || true
done
'

echo "Checking from current host:"
bash -lc "${check_block}" -- "${EGRESS_HOSTS[@]}"

if (( ${#GPU_NODE_SSH_TARGETS[@]} == 0 )); then
  echo
  echo "No GPU_NODE_SSH_TARGETS configured. Add targets to config/env_nai.sh to check GPU nodes."
  exit 0
fi

for target in "${GPU_NODE_SSH_TARGETS[@]}"; do
  echo
  echo "Checking from GPU node: ${target}"
  ssh -o BatchMode=yes -o ConnectTimeout=10 "${target}" "bash -s" -- "${EGRESS_HOSTS[@]}" <<< "${check_block}"
done
