# Model Download Monitoring

NAI model import/download jobs usually run in the `nai-admin` namespace as model processor jobs.

## Watch NAI Pods

```sh
source config/env_nai.sh
watch -n 2 "kubectl -n ${NAI_NAMESPACE} get pods"
```

Look for pods with names similar to:

```text
nai-<uuid>-model-job-<suffix>
```

## Follow Logs

```sh
kubectl -n "${NAI_NAMESPACE}" logs <model-job-pod> -f
```

The logs may show lines like:

```text
NAI Monitor: Downloaded directory size: 20542.94MB
```

NAI does not expose a true download percentage for Hugging Face models. Progress is inferred from directory size growth and model job events.

## If Size Stops Increasing

Check recent logs and events:

```sh
kubectl -n "${NAI_NAMESPACE}" logs <model-job-pod> --tail=300
kubectl -n "${NAI_NAMESPACE}" get events --sort-by=.lastTimestamp | tail -n 40
kubectl -n "${NAI_NAMESPACE}" describe pod <model-job-pod> | tail -n 120
```

Common causes:

- Hugging Face CAS/XET retry failures.
- TLS inspection CA is not trusted in the model processor container.
- Proxy variables are missing.
- PVC/storage issue.
- Network egress is blocked from the GPU or model processor node.

## CAS/XET Note

NAI uses the Hugging Face SDK for model downloads. Large Hugging Face models can use CAS/XET paths, which are more sensitive to chunk failures than `git clone`. This is why a model can download with `git clone` from the same node but fail through the NAI UI.

Operational workarounds:

- Retry from NAI UI.
- Pre-download with Git or Hugging Face CLI using a local directory.
- Import/register from a local model path if supported by the workflow.
- Ensure `huggingface.co` and CAS/XET hosts are allowed and trusted.
