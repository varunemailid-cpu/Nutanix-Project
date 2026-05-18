# NAI Deployment Kit

Sanitized operational kit for Nutanix AI (NAI) deployment, validation, model download monitoring, and NVIDIA NIM / GPT-OSS troubleshooting.

This kit is based on the MEWA NAI deployment notes exported from ChatGPT, but secrets, tokens, and customer-specific values have been replaced with placeholders.

## Folder Layout

```text
nai-deployment-kit
├── checklists
│   └── nai-preflight-checklist.md
├── config
│   └── env_nai.example.sh
├── docs
│   ├── 01-nai-access.md
│   ├── 02-model-download-monitoring.md
│   ├── 03-gpt-oss-nim-troubleshooting.md
│   └── 04-network-and-tls-checks.md
├── scripts
│   ├── check_gpu_node_egress.sh
│   ├── collect_nai_diagnostics.sh
│   ├── monitor_model_download.sh
│   ├── patch_serviceaccount_imagepullsecret.sh
│   ├── test_endpoint.sh
│   └── validate_nai.sh
└── templates
    ├── inferenceservice-probe-patch.example.json
    └── openai-chat-request.json
```

## Quick Start

1. Copy and edit the environment file:

```sh
cp config/env_nai.example.sh config/env_nai.sh
chmod 600 config/env_nai.sh
vi config/env_nai.sh
```

2. Validate NAI:

```sh
./scripts/validate_nai.sh
```

3. Monitor a model download/import:

```sh
./scripts/monitor_model_download.sh
```

4. Collect diagnostics:

```sh
./scripts/collect_nai_diagnostics.sh
```

## Notes

- NAI UI uses Kommander/NKP authentication. There is no separate NAI password.
- NAI model downloads use Hugging Face SDK behavior. CAS/XET-backed models may fail even when `git clone` works.
- GPT-OSS NIM models may require outbound access to tokenizer assets unless those assets are pre-staged.
- Do not commit `config/env_nai.sh`, API keys, downloaded logs, or kubeconfigs.
