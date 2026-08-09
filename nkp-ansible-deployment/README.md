# Reusable NKP 2.18 deployment on Nutanix AHV

This Ansible repository deploys an NKP 2.18 self-managed management cluster on Nutanix AHV using the Nutanix-provided Ubuntu 24.04 image. It supports connected and air-gapped environments from the same playbook.

The workflow follows the NKP 2.18 administration guide:

- x86_64 Ubuntu operator/bastion host with cgroups v2
- Docker 27.4.0 or newer
- kubectl 1.35.x
- unchanged Nutanix Ubuntu image filename containing Kubernetes 1.35.x
- NKP CLI 2.18.x
- NKP preflight checks remain enabled
- three control-plane and four worker nodes by default
- bundle-backed internal registry mode for air-gapped deployments

## Repository layout

```text
artifacts/nkp-2.18/
├── nkp-cli/             # Required in both modes
├── os-images/           # Required in both modes
├── air-gapped-bundle/   # Required in airgapped mode
├── docker-debs/         # Required in airgapped mode if Docker is not baked in
└── tools/               # kubectl-linux-amd64 1.35.x for airgapped mode
config/
├── vars.yml
└── secrets.yml
inventory/hosts.yml
playbooks/site.yml
templates/cloud-init-ubuntu.yml.j2
```

## Required artifact names

Connected mode:

```text
artifacts/nkp-2.18/nkp-cli/nkp_v2.18.0_linux_amd64.tar.gz
artifacts/nkp-2.18/os-images/nkp-ubuntu-24.04-...-1.35.x-....qcow2
```

Air-gapped mode additionally requires:

```text
artifacts/nkp-2.18/air-gapped-bundle/nkp-air-gapped-bundle_v2.18.0_linux_amd64.tar.gz
artifacts/nkp-2.18/docker-debs/*.deb
artifacts/nkp-2.18/tools/kubectl-linux-amd64
```

Do not rename the downloaded QCOW2 image. NKP checks the Kubernetes version encoded in its filename.

## Controller requirements

- Linux or macOS x86_64 controller
- Python 3.12+
- ansible-core 2.16+
- Network access from the controller to Prism Central TCP 9440
- Network access from the controller to the bastion SSH port
- DHCP or Nutanix IPAM enabled on the selected subnet

Install the collections:

```bash
ansible-galaxy collection install -r requirements.yml
```

Check the Nutanix Ansible collection compatibility table against your exact AOS and Prism Central versions before installation. The repository uses the legacy v3 VM/image modules because they support direct local QCOW2 upload; Nutanix has announced their future deprecation, so test collection upgrades before changing the pinned range.

## Configuration

1. Edit `config/vars.yml`.
2. Set `deployment_mode` to `connected` or `airgapped`.
3. Reserve the control-plane VIP and service load-balancer range outside DHCP/IPAM.
4. Ensure the pod, service and node networks do not overlap.
5. Create the secrets file from the example, edit it, then encrypt it:

```bash
cp config/secrets.example.yml config/secrets.yml
ansible-vault encrypt config/secrets.yml
```

For production, provide a Base64-encoded Prism Central self-signed CA certificate in `pc_additional_trust_bundle_b64`, set `validate_certs: true`, and set `allow_insecure_prism: false`.

## Connected deployment

Connected mode installs Docker and kubectl from their upstream Ubuntu repositories. Cluster nodes pull container images from public registries. Docker Hub credentials are recommended because rate limiting can prevent management-cluster creation.

```bash
ansible-playbook playbooks/site.yml --ask-vault-pass
```

## Air-gapped deployment

Air-gapped mode never configures Internet repositories. It installs the supplied Docker DEBs when Docker is absent, installs the supplied kubectl binary, copies and extracts the complete NKP bundle, and passes the Konvoy and Kommander bundles to `nkp create cluster nutanix --airgapped=true`.

Before execution, ensure:

- The controller can reach Prism Central and the bastion network.
- The bastion and all cluster nodes can reach Prism Central.
- All required local files are present.
- The Docker DEB directory includes Docker and every package dependency.
- If using an external local registry, every node can resolve and reach it.

Run the same command:

```bash
ansible-playbook playbooks/site.yml --ask-vault-pass
```

## Important operational behavior

- The playbook generates a dedicated controller-to-bastion Ed25519 key under ignored `state/ssh/`.
- Root SSH and password SSH are disabled.
- The Docker socket retains its normal permissions; the bastion user is added to the `docker` group.
- Local QCOW2 upload uses `nutanix.ncp.ntnx_images.source_path`.
- Existing images and bastion VMs are reused by name.
- NKP credentials are passed as task environment variables and credential-bearing tasks use `no_log`.
- NKP preflight checks are not skipped.

Cluster creation is intentionally not treated as safely repeatable after a partial NKP failure. Inspect and clean up failed NKP resources before rerunning the final creation step.
