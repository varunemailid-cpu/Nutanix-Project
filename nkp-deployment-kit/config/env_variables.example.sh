#!/usr/bin/env bash

# Copy this file to config/env_variables.sh and replace all CHANGE_ME values.
# Never commit config/env_variables.sh.

# Prism Central / AHV
export NUTANIX_ENDPOINT="https://CHANGE_ME_PRISM_CENTRAL:9440"
export NUTANIX_USER="CHANGE_ME"
export NUTANIX_PASSWORD="CHANGE_ME"
export NUTANIX_CLUSTER="CHANGE_ME_PRISM_ELEMENT_CLUSTER"
export SUBNET="CHANGE_ME_AHV_SUBNET"
export STORAGE_CONTAINER="CHANGE_ME_STORAGE_CONTAINER"
export INSECURE="true"

# NKP management cluster
export CLUSTER_NAME="CHANGE_ME_NKP_MGMT_CLUSTER"
export IMAGE="CHANGE_ME_NKP_VM_IMAGE.qcow2"
export CONTROLPLANE_VIP="CHANGE_ME_CONTROL_PLANE_VIP"
export SERVICE_LB_IP_RANGE="CHANGE_ME_LB_START-CHANGE_ME_LB_END"
export KUBERNETES_PODS_NETWORK="10.94.0.0/16"
export KUBERNETES_SERVICES_NETWORK="10.96.0.0/16"

# Optional workload cluster
export WORKLOAD_CLUSTER_NAME="CHANGE_ME_NKP_WORKLOAD_CLUSTER"
export WORKLOAD_CONTROLPLANE_VIP="CHANGE_ME_WORKLOAD_CONTROL_PLANE_VIP"
export WORKLOAD_SERVICE_LB_IP_RANGE="CHANGE_ME_WORKLOAD_LB_START-CHANGE_ME_WORKLOAD_LB_END"

# VM sizing. NKP expects memory in MiB.
export CONTROL_PLANE_REPLICAS="3"
export CONTROL_PLANE_VCPUS="4"
export CONTROL_PLANE_MEMORY="8192"
export WORKER_REPLICAS="3"
export WORKER_VCPUS="4"
export WORKER_MEMORY="4096"

# SSH access to NKP nodes
export SSH_USERNAME="nutanix"
export SSH_PUBLIC_KEY="${HOME}/.ssh/id_rsa.pub"

# NKP bundle paths
export NKP_BUNDLE_DIR="/data/nkp-v2.16.1"
export BOOTSTRAP_IMAGE="${NKP_BUNDLE_DIR}/konvoy-bootstrap-image-v2.16.1.tar"
export KONVOY_BUNDLE="${NKP_BUNDLE_DIR}/container-images/konvoy-image-bundle-v2.16.1.tar"
export KOMMANDER_BUNDLE="${NKP_BUNDLE_DIR}/container-images/kommander-image-bundle-v2.16.1.tar"

# Optional registry mirror for air-gapped deployments.
# Leave empty for connected deployments.
export REGISTRY_MIRROR_URL=""
export REGISTRY_MIRROR_CA=""

# Optional custom ingress certificate.
# If any of these are set, set all of them and CLUSTER_HOSTNAME.
export CLUSTER_HOSTNAME=""
export INGRESS_CERT=""
export INGRESS_PRIVATE_KEY=""
export INGRESS_CA=""

# Kubeconfig output
export KUBECONFIG_DIR="${NKP_BUNDLE_DIR}/kubeconfigs"
