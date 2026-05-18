#!/usr/bin/env bash

# Copy this file to config/env_nai.sh and replace all CHANGE_ME values.
# Never commit config/env_nai.sh.

# Cluster access
export KUBECONFIG="/data/nkp-2.16.1/kubeconfigs/CHANGE_ME_NAI_CLUSTER-kubeconfig.yaml"
export NAI_NAMESPACE="nai-admin"

# NAI UI and API
export NAI_UI_URL="https://CHANGE_ME_NAI_INGRESS/nai"
export NAI_API_BASE="https://CHANGE_ME_NAI_INGRESS/enterpriseai/v1"
export NAI_API_KEY="CHANGE_ME_ENDPOINT_API_KEY"
export NAI_CURL_INSECURE="true"

# Endpoint test defaults
export MODEL_ENDPOINT_NAME="CHANGE_ME_ENDPOINT_NAME"
export MODEL_NAME="CHANGE_ME_MODEL_NAME"
export TEST_PROMPT="Give one short sentence."

# Registry / image pull
export NGC_IMAGE_PULL_SECRET="CHANGE_ME_NGC_SECRET"
export IMAGE_PULL_SERVICEACCOUNT="default"

# In-cluster curl image. Use an image mirrored into Harbor/NAI registry for air-gapped clusters.
export CURL_IMAGE="curlimages/curl:8.14.1"

# GPU node SSH targets for egress checks.
# Example: GPU_NODE_SSH_TARGETS=("konvoy@10.0.0.11" "konvoy@10.0.0.12")
# shellcheck disable=SC2034
GPU_NODE_SSH_TARGETS=()

# Network targets often needed by NAI / NIM / Hugging Face workflows.
# shellcheck disable=SC2034
EGRESS_HOSTS=(
  "huggingface.co"
  "cdn-lfs.huggingface.co"
  "cas-bridge.xethub.hf.co"
  "transfer.xethub.hf.co"
  "nvcr.io"
  "layers.nvcr.io"
  "openaipublic.blob.core.windows.net"
)
