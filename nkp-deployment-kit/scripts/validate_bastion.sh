#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${ENV_FILE:-${KIT_DIR}/config/env_variables.sh}"

pass() { printf 'PASS: %s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*"; }
fail() { printf 'FAIL: %s\n' "$*"; exit_code=1; }

exit_code=0

for bin in curl jq openssl ssh; do
  if command -v "${bin}" >/dev/null 2>&1; then
    pass "${bin} installed"
  else
    fail "${bin} missing"
  fi
done

for bin in docker kubectl helm nkp; do
  if command -v "${bin}" >/dev/null 2>&1; then
    pass "${bin} installed"
    "${bin}" version >/dev/null 2>&1 || warn "${bin} version command returned non-zero"
  else
    fail "${bin} missing"
  fi
done

if [[ ! -f "${ENV_FILE}" ]]; then
  warn "Env file not found: ${ENV_FILE}"
  warn "Copy config/env_variables.example.sh to config/env_variables.sh before deployment."
  exit "${exit_code}"
fi

# shellcheck source=/dev/null
source "${ENV_FILE}"

for var in NUTANIX_ENDPOINT NUTANIX_CLUSTER SUBNET STORAGE_CONTAINER CLUSTER_NAME IMAGE CONTROLPLANE_VIP; do
  if [[ -z "${!var:-}" || "${!var}" == CHANGE_ME* ]]; then
    fail "${var} is not set"
  else
    pass "${var} set"
  fi
done

for file in "${SSH_PUBLIC_KEY:-}" "${BOOTSTRAP_IMAGE:-}" "${KONVOY_BUNDLE:-}" "${KOMMANDER_BUNDLE:-}"; do
  if [[ -n "${file}" && -r "${file}" ]]; then
    pass "Readable file: ${file}"
  else
    fail "Missing or unreadable file: ${file:-unset}"
  fi
done

if [[ -n "${NUTANIX_ENDPOINT:-}" && "${NUTANIX_ENDPOINT}" != CHANGE_ME* ]]; then
  if curl -kfsS --connect-timeout 5 "${NUTANIX_ENDPOINT}" >/dev/null 2>&1; then
    pass "Prism endpoint reachable: ${NUTANIX_ENDPOINT}"
  else
    warn "Prism endpoint did not return a successful HTTP response: ${NUTANIX_ENDPOINT}"
  fi
fi

exit "${exit_code}"
