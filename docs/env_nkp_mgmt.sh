#!/usr/bin/env bash
# Reusable NKP management-cluster environment template.
# Method: air-gapped local bundle deployment on Nutanix AHV.
# Harbor / external registry mirror: not used.
# Replace every CHANGE_ME value before running the deployment script.

# -----------------------------------------------------------------------------
# NKP release and extracted air-gapped bundle paths
# Expected layout:
#   /data/nkp-<version>/bundles/airgapped/nkp-v<version>/
# -----------------------------------------------------------------------------
export NKP_VERSION="2.16.1"
export NKP_BASE_DIR="/data/nkp-${NKP_VERSION}"
export NKP_BUNDLE_DIR="${NKP_BASE_DIR}/bundles/airgapped/nkp-v${NKP_VERSION}"

export NKP_BOOTSTRAP_IMAGE="${NKP_BUNDLE_DIR}/konvoy-bootstrap-image-v${NKP_VERSION}.tar"
export NKP_KONVOY_BUNDLE="${NKP_BUNDLE_DIR}/container-images/konvoy-image-bundle-v${NKP_VERSION}.tar"
export NKP_KOMMANDER_BUNDLE="${NKP_BUNDLE_DIR}/container-images/kommander-image-bundle-v${NKP_VERSION}.tar"

# -----------------------------------------------------------------------------
# NKP management cluster
# CLUSTER_NAME must be lowercase and RFC 1123 compliant.
# For the no-custom-certificate method used in the source project,
# set CLUSTER_HOSTNAME to the single NKP ingress/LoadBalancer IP.
# -----------------------------------------------------------------------------
export CLUSTER_NAME="CHANGE_ME_LOWERCASE_CLUSTER_NAME"
export CLUSTER_HOSTNAME="CHANGE_ME_LB_IP"

# -----------------------------------------------------------------------------
# Prism Central and AHV resources
# NKP reads NUTANIX_USER and NUTANIX_PASSWORD from the environment.
# Set the password securely before deployment, for example:
#   read -rsp 'Prism Central password: ' NUTANIX_PASSWORD; export NUTANIX_PASSWORD; echo
# -----------------------------------------------------------------------------
export NUTANIX_PC_FQDN_ENDPOINT_WITH_PORT="https://CHANGE_ME_PC_IP_OR_FQDN:9440"
export NUTANIX_USER="CHANGE_ME_PC_USERNAME"
export NUTANIX_PASSWORD="${NUTANIX_PASSWORD:-}"

export PRISM_ELEMENT_CLUSTER_NAME="CHANGE_ME_PE_CLUSTER_NAME"
export SUBNET_NAME="CHANGE_ME_AHV_SUBNET_NAME"
export STORAGE_CONTAINER="CHANGE_ME_STORAGE_CONTAINER"
export IMAGE_NAME="CHANGE_ME_NKP_NODE_IMAGE.qcow2"

# -----------------------------------------------------------------------------
# Node counts
# -----------------------------------------------------------------------------
export CONTROL_PLANE_REPLICAS="3"
export WORKER_REPLICAS="4"

# -----------------------------------------------------------------------------
# Kubernetes networking
# Ensure these CIDRs do not overlap with physical, VPN, Docker, or other
# Kubernetes networks used by the project.
# -----------------------------------------------------------------------------
export POD_CIDR="CHANGE_ME_POD_CIDR"
export SERVICE_CIDR="CHANGE_ME_SERVICE_CIDR"

export CONTROL_PLANE_IP="CHANGE_ME_CONTROL_PLANE_VIP"
export LB_IP_RANGE="CHANGE_ME_LB_IP-CHANGE_ME_LB_IP"

# -----------------------------------------------------------------------------
# SSH access injected into the NKP-created VMs
# -----------------------------------------------------------------------------
export SSH_USERNAME="nutanix"
export SSH_KEY_FILE="${HOME}/.ssh/id_rsa.pub"
