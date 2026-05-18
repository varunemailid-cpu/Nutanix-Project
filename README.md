# Nutanix Project

Deployment and operations runbooks for NKP and NAI work.

## Kits

- [NKP Deployment Kit](nkp-deployment-kit/README.md): Bastion prep, AHV management/workload cluster scripts, certificate generation, validation, and preflight checklists.
- [NAI Deployment Kit](nai-deployment-kit/README.md): NAI access, model download monitoring, GPT-OSS/NVIDIA NIM troubleshooting, GPU egress checks, endpoint testing, and diagnostics.

## Safety Notes

- Copy example environment files before use and keep real values out of Git.
- Do not commit generated certificates, kubeconfigs, logs, API keys, or customer credentials.
- The deployment kit scripts use placeholders such as `CHANGE_ME_*` until a project-specific environment file is created.

## Local Demo App

This repo also contains the existing browser Snake demo and its tests from the original workspace. It has been left untouched.
