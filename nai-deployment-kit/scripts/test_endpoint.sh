#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${ENV_FILE:-${KIT_DIR}/config/env_nai.sh}"
REQUEST_FILE="${REQUEST_FILE:-${KIT_DIR}/templates/openai-chat-request.json}"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing env file: ${ENV_FILE}"
  exit 1
fi

# shellcheck source=/dev/null
source "${ENV_FILE}"

if [[ -z "${NAI_API_BASE:-}" || -z "${NAI_API_KEY:-}" || "${NAI_API_KEY}" == CHANGE_ME* ]]; then
  echo "Set NAI_API_BASE and NAI_API_KEY in ${ENV_FILE}."
  exit 1
fi

curl_flags=(-sS)
if [[ "${NAI_CURL_INSECURE:-false}" == "true" ]]; then
  curl_flags+=(-k)
fi

payload="$(sed \
  -e "s/CHANGE_ME_MODEL/${MODEL_NAME:-CHANGE_ME_MODEL}/g" \
  -e "s/CHANGE_ME_PROMPT/${TEST_PROMPT:-Give one short sentence.}/g" \
  "${REQUEST_FILE}")"

curl "${curl_flags[@]}" \
  -H "Authorization: Bearer ${NAI_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "${payload}" \
  "${NAI_API_BASE}/chat/completions"
