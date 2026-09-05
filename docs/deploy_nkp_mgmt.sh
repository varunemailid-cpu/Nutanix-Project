#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/env_nkp_mgmt.sh"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "ERROR: Environment file not found: ${ENV_FILE}" >&2
  exit 1
fi

# shellcheck source=/dev/null
source "${ENV_FILE}"

required_vars=(
  NKP_BOOTSTRAP_IMAGE
  NKP_KONVOY_BUNDLE
  NKP_KOMMANDER_BUNDLE
  CLUSTER_NAME
  CLUSTER_HOSTNAME
  NUTANIX_PC_FQDN_ENDPOINT_WITH_PORT
  NUTANIX_USER
  NUTANIX_PASSWORD
  PRISM_ELEMENT_CLUSTER_NAME
  SUBNET_NAME
  STORAGE_CONTAINER
  IMAGE_NAME
  CONTROL_PLANE_REPLICAS
  WORKER_REPLICAS
  POD_CIDR
  SERVICE_CIDR
  CONTROL_PLANE_IP
  LB_IP_RANGE
  SSH_USERNAME
  SSH_KEY_FILE
)

for variable_name in "${required_vars[@]}"; do
  variable_value="${!variable_name:-}"
  if [[ -z "${variable_value}" || "${variable_value}" == *CHANGE_ME* ]]; then
    echo "ERROR: Set ${variable_name} in ${ENV_FILE} before deployment." >&2
    exit 1
  fi
done

if [[ ! "${CLUSTER_NAME}" =~ ^[a-z0-9]([a-z0-9.-]*[a-z0-9])?$ ]]; then
  echo "ERROR: CLUSTER_NAME must be lowercase and RFC 1123 compliant: ${CLUSTER_NAME}" >&2
  exit 1
fi

for artifact in \
  "${NKP_BOOTSTRAP_IMAGE}" \
  "${NKP_KONVOY_BUNDLE}" \
  "${NKP_KOMMANDER_BUNDLE}" \
  "${SSH_KEY_FILE}"; do
  if [[ ! -f "${artifact}" ]]; then
    echo "ERROR: Required file not found: ${artifact}" >&2
    exit 1
  fi
done

command -v nkp >/dev/null 2>&1 || {
  echo "ERROR: nkp CLI is not installed or not in PATH." >&2
  exit 1
}

echo "Creating air-gapped NKP management cluster: ${CLUSTER_NAME}"
echo "Prism Central: ${NUTANIX_PC_FQDN_ENDPOINT_WITH_PORT}"
echo "Prism Element: ${PRISM_ELEMENT_CLUSTER_NAME}"
echo "Subnet: ${SUBNET_NAME}"
echo "Control-plane VIP: ${CONTROL_PLANE_IP}"
echo "Service LoadBalancer range: ${LB_IP_RANGE}"
echo "Cluster hostname: ${CLUSTER_HOSTNAME}"

# Local bundle deployment only:
# - No Harbor URL
# - No registry mirror credentials
# - No --registry-mirror-* flags
# - No custom ingress certificate flags
nkp create cluster nutanix \
  --cluster-name "${CLUSTER_NAME}" \
  --cluster-hostname "${CLUSTER_HOSTNAME}" \
  --self-managed \
  --airgapped \
  --bootstrap-cluster-image "${NKP_BOOTSTRAP_IMAGE}" \
  --bundle "${NKP_KONVOY_BUNDLE}" \
  --bundle "${NKP_KOMMANDER_BUNDLE}" \
  --endpoint "${NUTANIX_PC_FQDN_ENDPOINT_WITH_PORT}" \
  --insecure \
  --control-plane-endpoint-ip "${CONTROL_PLANE_IP}" \
  --control-plane-vm-image "${IMAGE_NAME}" \
  --control-plane-prism-element-cluster "${PRISM_ELEMENT_CLUSTER_NAME}" \
  --control-plane-subnets "${SUBNET_NAME}" \
  --control-plane-replicas "${CONTROL_PLANE_REPLICAS}" \
  --worker-vm-image "${IMAGE_NAME}" \
  --worker-prism-element-cluster "${PRISM_ELEMENT_CLUSTER_NAME}" \
  --worker-subnets "${SUBNET_NAME}" \
  --worker-replicas "${WORKER_REPLICAS}" \
  --csi-storage-container "${STORAGE_CONTAINER}" \
  --kubernetes-pod-network-cidr "${POD_CIDR}" \
  --kubernetes-service-cidr "${SERVICE_CIDR}" \
  --kubernetes-service-load-balancer-ip-range "${LB_IP_RANGE}" \
  --ssh-username "${SSH_USERNAME}" \
  --ssh-public-key-file "${SSH_KEY_FILE}" \
  --verbose 5
