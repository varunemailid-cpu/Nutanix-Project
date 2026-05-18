# Network and TLS Checks

Run checks from the same place the workload runs. For model downloads and NIM startup, that usually means GPU worker nodes or model processor pods, not only the bastion.

## Common Egress Hosts

```text
huggingface.co
cdn-lfs.huggingface.co
cas-bridge.xethub.hf.co
transfer.xethub.hf.co
nvcr.io
layers.nvcr.io
openaipublic.blob.core.windows.net
```

## From Bastion

```sh
getent hosts huggingface.co
timeout 5 bash -lc '</dev/tcp/huggingface.co/443' && echo OK || echo FAIL
curl -vk --max-time 15 https://huggingface.co/ -o /dev/null
```

## From GPU Nodes

Configure `GPU_NODE_SSH_TARGETS` in `config/env_nai.sh`, then run:

```sh
./scripts/check_gpu_node_egress.sh
```

## From a Pod

```sh
kubectl -n "${NAI_NAMESPACE}" exec -it <pod> -- sh -lc '
getent hosts huggingface.co || true
timeout 5 sh -lc "</dev/tcp/huggingface.co/443" && echo TCP_443_OK || echo TCP_443_FAIL
curl -vk --max-time 15 https://huggingface.co/ -o /dev/null 2>&1 | tail -n 40
'
```

## TLS Inspection

If downloads fail with `CERTIFICATE_VERIFY_FAILED`, the pod may be seeing a corporate TLS inspection certificate that the container does not trust.

Validation:

```sh
kubectl -n "${NAI_NAMESPACE}" exec -it <pod> -- sh -lc '
echo | openssl s_client -connect huggingface.co:443 -servername huggingface.co -showcerts 2>/dev/null | openssl x509 -noout -issuer -subject
'
```

Fix pattern:

- Get the corporate CA certificate.
- Create a Kubernetes secret in `nai-admin`.
- Mount it into the model processor or endpoint pod.
- Set trust variables such as `SSL_CERT_FILE` and `REQUESTS_CA_BUNDLE` when supported.
