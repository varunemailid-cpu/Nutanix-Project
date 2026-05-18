# AHV Management Cluster Deployment

This kit uses the `nkp create cluster nutanix` flow for an AHV-backed NKP management cluster through Prism Central.

## 1. Prepare Environment Variables

```sh
cp config/env_variables.example.sh config/env_variables.sh
chmod 600 config/env_variables.sh
vi config/env_variables.sh
```

Important fields:

- `NUTANIX_ENDPOINT`
- `NUTANIX_USER`
- `NUTANIX_PASSWORD`
- `NUTANIX_CLUSTER`
- `SUBNET`
- `STORAGE_CONTAINER`
- `IMAGE`
- `CLUSTER_NAME`
- `CONTROLPLANE_VIP`
- `SERVICE_LB_IP_RANGE`
- `KUBERNETES_PODS_NETWORK`
- `KUBERNETES_SERVICES_NETWORK`
- `BOOTSTRAP_IMAGE`
- `KONVOY_BUNDLE`
- `KOMMANDER_BUNDLE`

## 2. Validate Bastion and Inputs

```sh
./scripts/validate_bastion.sh
```

Fix any missing binaries, unreadable bundle files, or Prism connectivity failures before continuing.

## 3. Optional Self-Signed Ingress Certificate

Set these in `config/env_variables.sh`:

```sh
export CLUSTER_HOSTNAME="nkp.example.local"
export CONTROLPLANE_VIP="10.0.0.10"
```

Generate certificate material:

```sh
./scripts/generate_self_signed_ingress_cert.sh
```

Then update:

```sh
export INGRESS_CERT="/absolute/path/to/nkp-deployment-kit/certs/NKPAI.crt"
export INGRESS_PRIVATE_KEY="/absolute/path/to/nkp-deployment-kit/certs/NKPAI.key"
export INGRESS_CA="/absolute/path/to/nkp-deployment-kit/certs/ca-chain.crt"
```

For self-signed certificates, `INGRESS_CA` should point to the self-signed certificate or CA chain file.

## 4. Deploy Management Cluster

```sh
./scripts/deploy_mgmt_cluster.sh
```

The script uses MiB for memory values:

- `CONTROL_PLANE_MEMORY=8192` means 8 GiB.
- `WORKER_MEMORY=4096` means 4 GiB.

## 5. Fetch Kubeconfig

The deployment script attempts to fetch kubeconfig after creation. If needed, run manually:

```sh
source config/env_variables.sh
mkdir -p "$KUBECONFIG_DIR"
nkp get kubeconfig "$CLUSTER_NAME" > "${KUBECONFIG_DIR}/${CLUSTER_NAME}-kubeconfig.yaml"
```
