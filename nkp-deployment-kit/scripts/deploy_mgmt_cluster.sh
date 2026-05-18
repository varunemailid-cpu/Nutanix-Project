#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${ENV_FILE:-${KIT_DIR}/config/env_variables.sh}"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing env file: ${ENV_FILE}"
  echo "Copy config/env_variables.example.sh to config/env_variables.sh and edit it first."
  exit 1
fi

# shellcheck source=/dev/null
source "${ENV_FILE}"

required_vars=(
  NUTANIX_ENDPOINT NUTANIX_USER NUTANIX_PASSWORD NUTANIX_CLUSTER SUBNET
  STORAGE_CONTAINER CLUSTER_NAME IMAGE CONTROLPLANE_VIP SERVICE_LB_IP_RANGE
  KUBERNETES_PODS_NETWORK KUBERNETES_SERVICES_NETWORK SSH_USERNAME SSH_PUBLIC_KEY
  BOOTSTRAP_IMAGE KONVOY_BUNDLE KOMMANDER_BUNDLE
  CONTROL_PLANE_MEMORY CONTROL_PLANE_VCPUS CONTROL_PLANE_REPLICAS
  WORKER_MEMORY WORKER_VCPUS WORKER_REPLICAS
)

for var in "${required_vars[@]}"; do
  if [[ -z "${!var:-}" || "${!var}" == CHANGE_ME* ]]; then
    echo "Required variable ${var} is not set correctly."
    exit 1
  fi
done

for file in "${SSH_PUBLIC_KEY}" "${BOOTSTRAP_IMAGE}" "${KONVOY_BUNDLE}" "${KOMMANDER_BUNDLE}"; do
  if [[ ! -r "${file}" ]]; then
    echo "Required file is not readable: ${file}"
    exit 1
  fi
done

cmd=(
  nkp create cluster nutanix
  --cluster-name "${CLUSTER_NAME}"
  --self-managed
  --bootstrap-cluster-image "${BOOTSTRAP_IMAGE}"
  --bundle "${KONVOY_BUNDLE}"
  --bundle "${KOMMANDER_BUNDLE}"
  --verbose 5
  --endpoint "${NUTANIX_ENDPOINT}"
  --insecure "${INSECURE:-true}"
  --control-plane-endpoint-ip "${CONTROLPLANE_VIP}"
  --csi-storage-container "${STORAGE_CONTAINER}"
  --kubernetes-pod-network-cidr "${KUBERNETES_PODS_NETWORK}"
  --kubernetes-service-cidr "${KUBERNETES_SERVICES_NETWORK}"
  --kubernetes-service-load-balancer-ip-range "${SERVICE_LB_IP_RANGE}"
  --control-plane-prism-element-cluster "${NUTANIX_CLUSTER}"
  --control-plane-subnets "${SUBNET}"
  --control-plane-vm-image "${IMAGE}"
  --worker-prism-element-cluster "${NUTANIX_CLUSTER}"
  --worker-subnets "${SUBNET}"
  --worker-vm-image "${IMAGE}"
  --control-plane-memory "${CONTROL_PLANE_MEMORY}"
  --control-plane-vcpus "${CONTROL_PLANE_VCPUS}"
  --control-plane-replicas "${CONTROL_PLANE_REPLICAS}"
  --worker-memory "${WORKER_MEMORY}"
  --worker-vcpus "${WORKER_VCPUS}"
  --worker-replicas "${WORKER_REPLICAS}"
  --ssh-username "${SSH_USERNAME}"
  --ssh-public-key-file "${SSH_PUBLIC_KEY}"
)

if [[ -n "${REGISTRY_MIRROR_URL:-}" ]]; then
  cmd+=(--registry-mirror-url "${REGISTRY_MIRROR_URL}")
fi

if [[ -n "${REGISTRY_MIRROR_CA:-}" ]]; then
  cmd+=(--registry-mirror-cacert "${REGISTRY_MIRROR_CA}")
fi

cert_values=("${CLUSTER_HOSTNAME:-}" "${INGRESS_CERT:-}" "${INGRESS_PRIVATE_KEY:-}" "${INGRESS_CA:-}")
cert_count=0
for value in "${cert_values[@]}"; do
  [[ -n "${value}" ]] && cert_count=$((cert_count + 1))
done

if (( cert_count > 0 && cert_count < 4 )); then
  echo "Custom ingress TLS requires CLUSTER_HOSTNAME, INGRESS_CERT, INGRESS_PRIVATE_KEY, and INGRESS_CA."
  exit 1
fi

if (( cert_count == 4 )); then
  for file in "${INGRESS_CERT}" "${INGRESS_PRIVATE_KEY}" "${INGRESS_CA}"; do
    if [[ ! -r "${file}" ]]; then
      echo "Certificate file is not readable: ${file}"
      exit 1
    fi
  done
  cmd+=(
    --cluster-hostname "${CLUSTER_HOSTNAME}"
    --ingress-certificate "${INGRESS_CERT}"
    --ingress-private-key "${INGRESS_PRIVATE_KEY}"
    --ingress-ca "${INGRESS_CA}"
  )
fi

echo "Creating NKP management cluster: ${CLUSTER_NAME}"
"${cmd[@]}"

if [[ -n "${KUBECONFIG_DIR:-}" ]]; then
  mkdir -p "${KUBECONFIG_DIR}"
  nkp get kubeconfig "${CLUSTER_NAME}" > "${KUBECONFIG_DIR}/${CLUSTER_NAME}-kubeconfig.yaml"
  echo "Wrote kubeconfig: ${KUBECONFIG_DIR}/${CLUSTER_NAME}-kubeconfig.yaml"
fi
