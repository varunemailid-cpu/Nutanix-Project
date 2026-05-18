# Nutanix Project

[![Repository Checks](https://github.com/varunemailid-cpu/Nutanix-Project/actions/workflows/test.yml/badge.svg)](https://github.com/varunemailid-cpu/Nutanix-Project/actions/workflows/test.yml)
[![Quality](https://github.com/varunemailid-cpu/Nutanix-Project/actions/workflows/quality.yml/badge.svg)](https://github.com/varunemailid-cpu/Nutanix-Project/actions/workflows/quality.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Professional deployment and operations toolkit for Nutanix Kubernetes Platform (NKP) and Nutanix AI (NAI) projects.

This repository turns field deployment notes into reusable runbooks, scripts, templates, and checklists for repeatable customer delivery. It is designed for bastion-led NKP deployments on AHV, NAI workload operations, GPU endpoint validation, and model download troubleshooting.

## What Is Included

- [NKP Deployment Kit](nkp-deployment-kit/README.md): Bastion preparation, AHV management/workload cluster scripts, certificate generation, validation, and preflight checklists.
- [NAI Deployment Kit](nai-deployment-kit/README.md): NAI access, model download monitoring, GPT-OSS/NVIDIA NIM troubleshooting, GPU node egress checks, endpoint testing, and diagnostics.
- [Documentation Hub](docs/index.md): Architecture, operating model, roadmap, release process, and GitHub profile guidance.
- [GitHub Templates](.github): Issue templates, pull request checklist, CODEOWNERS, Dependabot, and CI workflows.

## Repository Structure

```text
.
|-- docs/
|-- nai-deployment-kit/
|-- nkp-deployment-kit/
|-- scripts/
|-- .github/
|-- CHANGELOG.md
|-- CONTRIBUTING.md
|-- LICENSE
|-- SECURITY.md
`-- README.md
```

## Quick Start

1. Read the [documentation hub](docs/index.md).
2. Choose the kit you need:
   - NKP: [nkp-deployment-kit/README.md](nkp-deployment-kit/README.md)
   - NAI: [nai-deployment-kit/README.md](nai-deployment-kit/README.md)
3. Copy the example environment file in the selected kit.
4. Replace all `CHANGE_ME_*` placeholders with project-specific values.
5. Run the kit validation script before any deployment action.

## Local Validation

Run repository checks before committing:

```sh
./scripts/validate_repository.sh
```

The validation checks shell syntax, JSON syntax, YAML syntax, and obvious secret patterns.

## Safety Rules

- Never commit real credentials, API keys, kubeconfigs, certificates, or customer IP plans.
- Keep generated files in ignored paths such as `config/env_variables.sh`, `config/env_nai.sh`, `certs/`, `kubeconfigs/`, and `logs/`.
- Use placeholders in examples and document the expected value format.
- Treat deployment scripts as production-impacting automation. Review every variable before running.

## Status

This repository is maintained as a field toolkit. The current baseline is `v0.2.0`, focused on NKP on AHV and NAI operations.
