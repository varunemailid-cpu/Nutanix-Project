# GPT-OSS / NVIDIA NIM Troubleshooting

This runbook captures the GPT-OSS lessons from the deployment notes.

## Key Finding

NVIDIA NIM model `nvcr.io/nim/openai/gpt-oss-20b` (GPT-OSS-20B) is not fully air-gapped by default. It may need outbound access to:

```text
openaipublic.blob.core.windows.net:443
```

The runtime uses OpenAI Harmony tokenizer assets such as `o200k_base.tiktoken` unless those files are already pre-staged in the model cache.

## Symptoms

- Predictor pod starts but does not become Ready.
- Container restarts before port 8000 opens.
- Logs include `openai_harmony.HarmonyError`.
- Readiness/startup probes fail during long initialization.
- Image pulls fail with `401 Unauthorized` or `ImagePullBackOff`.

## Fix Pattern

1. Prove GPU node egress to required hosts.
2. Attach NGC image pull secret to the ServiceAccount used by endpoint pods.
3. Relax startup/readiness probes for large models.
4. Confirm tokenizer dependency is reachable or pre-staged.
5. Recreate/restart endpoint pod and monitor logs.

## Probe Guidance

Large NIM models can take several minutes to initialize because of model load, `torch.compile`, and CUDA graph capture. Default probes can be too aggressive.

Use [templates/inferenceservice-probe-patch.example.json](../templates/inferenceservice-probe-patch.example.json) as a starting point and adapt paths to the actual InferenceService spec in your NAI version.

## Endpoint Test

Once Ready, test through the NAI API gateway with a bearer endpoint API key:

```sh
./scripts/test_endpoint.sh
```
