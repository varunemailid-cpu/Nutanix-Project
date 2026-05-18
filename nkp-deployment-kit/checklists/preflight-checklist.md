# NKP Preflight Checklist

## Bastion

- Ubuntu 22.04 or approved Linux bastion is deployed.
- Bastion can reach Prism Central on TCP 9440.
- Bastion can reach registry mirror or required external repositories.
- `nkp`, `kubectl`, `docker`, `helm`, `jq`, `curl`, and `openssl` are installed.
- Docker service is running and the deployment user can run Docker.
- SSH public key exists and is readable.
- NKP bundle files exist on disk.

## Prism Central / AHV

- Prism Central endpoint, username, and password are confirmed.
- Prism Element cluster name is confirmed.
- AHV subnet exists and is routable for NKP nodes.
- Storage container exists and has enough capacity.
- NKP VM image is uploaded to Prism image service.
- Management control plane VIP is reserved and unused.
- Service LoadBalancer range is reserved and unused.

## Networking

- Pod CIDR does not overlap with customer routed networks.
- Service CIDR does not overlap with customer routed networks.
- DNS entry is planned for NKP UI / ingress hostname.
- Firewall allows required east-west cluster traffic.
- Firewall allows required outbound registry and model sources if connected or semi-connected.

## Air-Gapped / Registry Mirror

- Registry mirror URL is reachable from bastion and NKP nodes.
- Registry certificate chain is trusted by Docker/containerd where required.
- NKP images and required add-on images are mirrored.
- Registry credentials are stored outside Git.

## Certificates

- Ingress certificate includes DNS SAN for the cluster hostname.
- Ingress certificate includes IP SAN for the ingress/load balancer IP when users access by IP.
- Certificate, key, and CA paths are readable on the bastion.
- For self-signed certificates, use the certificate itself as the CA file.
