#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${ENV_FILE:-${KIT_DIR}/config/env_variables.sh}"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing env file: ${ENV_FILE}"
  exit 1
fi

# shellcheck source=/dev/null
source "${ENV_FILE}"

required_vars=(
  NUTANIX_ENDPOINT NUTANIX_CLUSTER SUBNET STORAGE_CONTAINER WORKLOAD_CLUSTER_NAME
  IMAGE WORKLOAD_CONTROLPLANE_VIP WORKLOAD_SERVICE_LB_IP_RANGE
  KUBERNETES_PODS_NETWORK KUBERNETES_SERVICES_NETWORK SSH_USERNAME SSH_PUBLIC_KEY
  BOOTSTRAP_IMAGE KONVOY_BUNDLE
)

for var in "${required_vars[@]}"; do
  if [[ -z "${!var:-}" || "${!var}" == CHANGE_ME* ]]; then
    echo "Required variable ${var} is not set correctly."
    exit 1
  fi
done

cmd=(
  nkp create cluster nutanix
  --cluster-name "${WORKLOAD_CLUSTER_NAME}"
  --bootstrap-cluster-image "${BOOTSTRAP_IMAGE}"
  --bundle "${KONVOY_BUNDLE}"
  --verbose 5
  --endpoint "${NUTANIX_ENDPOINT}"
  --insecure "${INSECURE:-true}"
  --control-plane-endpoint-ip "${WORKLOAD_CONTROLPLANE_VIP}"
  --csi-storage-container "${STORAGE_CONTAINER}"
  --kubernetes-pod-network-cidr "${KUBERNETES_PODS_NETWORK}"
  --kubernetes-service-cidr "${KUBERNETES_SERVICES_NETWORK}"
  --kubernetes-service-load-balancer-ip-range "${WORKLOAD_SERVICE_LB_IP_RANGE}"
  --control-plane-prism-element-cluster "${NUTANIX_CLUSTER}"
  --control-plane-subnets "${SUBNET}"
  --control-plane-vm-image "${IMAGE}"
  --worker-prism-element-cluster "${NUTANIX_CLUSTER}"
  --worker-subnets "${SUBNET}"
  --worker-vm-image "${IMAGE}"
  --control-plane-memory "${CONTROL_PLANE_MEMORY:-8192}"
  --control-plane-vcpus "${CONTROL_PLANE_VCPUS:-4}"
  --control-plane-replicas "${CONTROL_PLANE_REPLICAS:-3}"
  --worker-memory "${WORKER_MEMORY:-4096}"
  --worker-vcpus "${WORKER_VCPUS:-4}"
  --worker-replicas "${WORKER_REPLICAS:-3}"
  --ssh-username "${SSH_USERNAME}"
  --ssh-public-key-file "${SSH_PUBLIC_KEY}"
)

if [[ -n "${REGISTRY_MIRROR_URL:-}" ]]; then
  cmd+=(--registry-mirror-url "${REGISTRY_MIRROR_URL}")
fi

if [[ -n "${REGISTRY_MIRROR_CA:-}" ]]; then
  cmd+=(--registry-mirror-cacert "${REGISTRY_MIRROR_CA}")
fi

echo "Creating NKP workload cluster: ${WORKLOAD_CLUSTER_NAME}"
"${cmd[@]}"

if [[ -n "${KUBECONFIG_DIR:-}" ]]; then
  mkdir -p "${KUBECONFIG_DIR}"
  nkp get kubeconfig "${WORKLOAD_CLUSTER_NAME}" > "${KUBECONFIG_DIR}/${WORKLOAD_CLUSTER_NAME}-kubeconfig.yaml"
  echo "Wrote kubeconfig: ${KUBECONFIG_DIR}/${WORKLOAD_CLUSTER_NAME}-kubeconfig.yaml"
fi
