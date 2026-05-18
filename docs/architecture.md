# Architecture

This repository is organized around two related delivery workflows: NKP platform deployment and NAI operations on top of a Kubernetes workload environment.

## High-Level Flow

```mermaid
flowchart LR
  A["Engineer"] --> B["Bastion Host"]
  B --> C["Prism Central"]
  C --> D["AHV Cluster"]
  B --> E["NKP Management Cluster"]
  E --> F["NKP Workload Cluster"]
  F --> G["NAI Platform"]
  G --> H["Model Endpoints"]
  F --> I["GPU Worker Nodes"]
  I --> H
```

## NKP Deployment Flow

```mermaid
flowchart TD
  A["Prepare Bastion"] --> B["Validate Prism and Bundle Inputs"]
  B --> C["Generate or Provide Ingress Certificates"]
  C --> D["Create NKP Management Cluster"]
  D --> E["Fetch Kubeconfig"]
  E --> F["Validate Nodes, Pods, Services, and Ingress"]
  F --> G["Create Workload Clusters"]
```

## NAI Operations Flow

```mermaid
flowchart TD
  A["Load NAI Workload Kubeconfig"] --> B["Validate nai-admin Namespace"]
  B --> C["Open NAI UI Through Kommander"]
  C --> D["Import or Register Model"]
  D --> E["Monitor Model Job Logs"]
  E --> F["Create Endpoint"]
  F --> G["Validate GPU Scheduling and Probe Health"]
  G --> H["Test Inference API"]
```

## Security Boundary

The repository contains reusable templates and examples only. Real deployment values must stay in local ignored files:

- `nkp-deployment-kit/config/env_variables.sh`
- `nai-deployment-kit/config/env_nai.sh`
- `certs/`
- `kubeconfigs/`
- `logs/`

These paths are intentionally ignored by Git.
