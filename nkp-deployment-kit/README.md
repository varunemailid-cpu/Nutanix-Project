# NKP Deployment Kit

Sanitized deployment kit for Nutanix Kubernetes Platform (NKP) on AHV using a bastion host and Prism Central.

This kit is based on the MEWA NKP deployment notes exported from ChatGPT, but secrets and site-specific values have been replaced with placeholders.

## Folder Layout

```text
nkp-deployment-kit
├── checklists
│   └── preflight-checklist.md
├── config
│   └── env_variables.example.sh
├── docs
│   ├── 01-bastion-prep.md
│   ├── 02-ahv-management-cluster.md
│   └── 03-validation-runbook.md
├── scripts
│   ├── deploy_mgmt_cluster.sh
│   ├── deploy_workload_cluster.sh
│   ├── destroy_cluster.sh
│   ├── generate_self_signed_ingress_cert.sh
│   ├── validate_bastion.sh
│   └── validate_nkp_cluster.sh
└── templates
    └── cloud-init-ubuntu-22.04.yaml
```

## Quick Start

1. Prepare the bastion using [docs/01-bastion-prep.md](docs/01-bastion-prep.md).
2. Copy the environment template:

```sh
cp config/env_variables.example.sh config/env_variables.sh
chmod 600 config/env_variables.sh
```

3. Edit `config/env_variables.sh` with the customer values.
4. Validate the bastion:

```sh
./scripts/validate_bastion.sh
```

5. Deploy the management cluster:

```sh
./scripts/deploy_mgmt_cluster.sh
```

6. Validate the cluster:

```sh
./scripts/validate_nkp_cluster.sh
```

## Notes

- Do not commit `config/env_variables.sh`, generated certificates, kubeconfigs, or logs.
- Memory values in NKP CLI flags are MiB, not GiB. Example: `8192` means 8 GiB.
- For self-signed ingress certificates, NKP requires certificate, private key, CA, and cluster hostname values together.
