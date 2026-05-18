# NKP Validation Runbook

Use this after cluster creation or when returning to an existing project.

## Load Kubeconfig

```sh
source config/env_variables.sh
export KUBECONFIG="${KUBECONFIG_DIR}/${CLUSTER_NAME}-kubeconfig.yaml"
```

## Cluster Health

```sh
kubectl cluster-info
kubectl get nodes -o wide
kubectl get pods -A | grep -v Running | grep -v Completed || true
kubectl get svc -A
kubectl get ingress -A
```

## NKP CLI Health

```sh
nkp get clusters
nkp describe cluster "$CLUSTER_NAME"
nkp get dashboard
```

## Ingress / UI Check

If using a self-signed certificate:

```sh
curl -kI "https://${CLUSTER_HOSTNAME}/"
```

If validating by ingress IP:

```sh
curl -kI "https://CHANGE_ME_INGRESS_IP/"
```

## Common Checks

- Node `Ready` status
- CNI pods running
- CSI pods running
- LoadBalancer service has expected external IP
- Ingress responds on TCP 443
- Browser trusts the certificate or user accepts self-signed warning
