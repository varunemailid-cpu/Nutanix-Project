# NAI Preflight Checklist

## Cluster Access

- NAI workload cluster kubeconfig is available on the bastion.
- `kubectl cluster-info` works with the NAI workload cluster.
- `nai-admin` namespace exists.
- NAI pods are running or explainable.
- NAI services and ingress are present.

## GPU

- GPU worker nodes are visible.
- NVIDIA device plugin / GPU operator components are healthy.
- NAI endpoint pods can schedule to GPU nodes.
- GPU node taints and selectors match endpoint requirements.

## Registry / Images

- NAI images are available in the configured registry or mirror.
- NVIDIA NIM images can be pulled from `nvcr.io` / `layers.nvcr.io` or mirrored internally.
- Image pull secrets exist in `nai-admin`.
- Required image pull secret is attached to the ServiceAccount used by endpoint pods.

## Model Downloads

- Hugging Face token is available where required.
- GPU/model processor pods can reach `huggingface.co` and related CAS/XET endpoints when connected downloads are used.
- Corporate TLS inspection CA is trusted inside model processor containers if TLS is intercepted.
- Shared model storage / PVC provisioning works.

## GPT-OSS / NIM

- `openaipublic.blob.core.windows.net:443` is reachable from GPU nodes if tokenizer files are not pre-staged.
- Startup/readiness probes allow enough time for large model initialization.
- NGC API key is stored in Kubernetes Secret, not in Git or shell history.
- Endpoint API key is known for inference tests.
