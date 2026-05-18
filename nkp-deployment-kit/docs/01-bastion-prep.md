# Bastion Preparation

This runbook prepares an Ubuntu 22.04 bastion for NKP deployments on AHV.

## Recommended Bastion Sizing

- vCPU: 4 to 8
- RAM: 16 to 32 GiB
- Disk: 200 GiB or more
- Network: access to Prism Central, AHV networks, registry mirror, DNS, and NTP

## Base Packages

```sh
sudo apt update
sudo apt upgrade -y
sudo apt install -y vim curl wget git jq unzip tar net-tools tcpdump ca-certificates gnupg lsb-release bash-completion openssl
```

## Time Sync

```sh
sudo timedatectl set-ntp true
timedatectl status
```

## Docker

```sh
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker "$USER"
```

Log out and back in, then validate:

```sh
docker version
```

## kubectl

Install a `kubectl` version compatible with the Kubernetes version supported by the NKP bundle.

```sh
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client
```

## Helm

```sh
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
```

## NKP CLI

Extract the NKP CLI from the approved NKP bundle and place it on the path:

```sh
tar -xvf nkp-linux-amd64-vCHANGE_ME.tar.gz
sudo mv nkp /usr/local/bin/
nkp version
```

## SSH Key

```sh
ssh-keygen -t ed25519 -C "nkp-bastion" -f ~/.ssh/id_ed25519
```

Set `SSH_PUBLIC_KEY` in `config/env_variables.sh` to the generated public key path.
