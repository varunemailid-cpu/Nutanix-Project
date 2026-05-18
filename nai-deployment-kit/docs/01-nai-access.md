# NAI Access

NAI runs on the workload cluster. Load the NAI cluster kubeconfig before checking NAI resources.

## Load Kubeconfig

```sh
source config/env_nai.sh
export KUBECONFIG
kubectl cluster-info
```

## Validate NAI Namespace

```sh
kubectl get ns | grep -i nai
kubectl -n nai-admin get pods -o wide
kubectl -n nai-admin get svc
kubectl -n nai-admin get ingress
```

## Open NAI UI

NAI uses NKP / Kommander authentication.

- Open Kommander / NKP UI.
- Go to Applications.
- Open Nutanix AI.
- Use the same Kommander credentials.

There is no separate NAI username or password.

## Direct URL Pattern

Common URL pattern:

```text
https://<ingress-host-or-ip>/nai
```

The exact path can vary by version. The Kommander Open button is the safest source of truth.
