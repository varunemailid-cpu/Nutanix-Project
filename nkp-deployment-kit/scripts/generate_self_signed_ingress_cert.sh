#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${ENV_FILE:-${KIT_DIR}/config/env_variables.sh}"
CERT_DIR="${CERT_DIR:-${KIT_DIR}/certs}"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing env file: ${ENV_FILE}"
  exit 1
fi

# shellcheck source=/dev/null
source "${ENV_FILE}"

if [[ -z "${CLUSTER_HOSTNAME:-}" || -z "${CONTROLPLANE_VIP:-}" || "${CLUSTER_HOSTNAME}" == CHANGE_ME* ]]; then
  echo "Set CLUSTER_HOSTNAME and CONTROLPLANE_VIP in ${ENV_FILE} first."
  exit 1
fi

mkdir -p "${CERT_DIR}"

key="${CERT_DIR}/NKPAI.key"
cert="${CERT_DIR}/NKPAI.crt"
conf="${CERT_DIR}/NKPAI-openssl.cnf"
ca="${CERT_DIR}/ca-chain.crt"

if [[ "${OVERWRITE:-false}" != "true" ]]; then
  for file in "${key}" "${cert}" "${conf}" "${ca}"; do
    if [[ -e "${file}" ]]; then
      echo "Refusing to overwrite ${file}. Set OVERWRITE=true to replace generated certs."
      exit 1
    fi
  done
fi

cat > "${conf}" <<EOF
[req]
default_bits = 4096
prompt = no
default_md = sha256
x509_extensions = v3_req
distinguished_name = dn

[dn]
CN = ${CLUSTER_HOSTNAME}

[v3_req]
subjectAltName = @alt_names
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[alt_names]
DNS.1 = ${CLUSTER_HOSTNAME}
IP.1 = ${CONTROLPLANE_VIP}
EOF

openssl req -x509 -nodes -days "${CERT_DAYS:-825}" -newkey rsa:4096 \
  -keyout "${key}" \
  -out "${cert}" \
  -config "${conf}"

cp "${cert}" "${ca}"
chmod 600 "${key}"

openssl x509 -in "${cert}" -noout -subject -issuer -dates -ext subjectAltName

echo
echo "Generated:"
echo "  INGRESS_CERT=${cert}"
echo "  INGRESS_PRIVATE_KEY=${key}"
echo "  INGRESS_CA=${ca}"
