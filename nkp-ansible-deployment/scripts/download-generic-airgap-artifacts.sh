set -euo pipefail

# Run this script on an Internet-connected Ubuntu 24.04 AMD64 staging host.
# It intentionally downloads only generic Ubuntu, Docker and Kubernetes files.
# Nutanix NKP archives and the Nutanix Ubuntu QCOW2 image are not downloaded.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
ARTIFACT_ROOT="${REPO_ROOT}/artifacts/nkp-2.18"
BASE_DEB_DIR="${ARTIFACT_ROOT}/base-debs"
DOCKER_DEB_DIR="${ARTIFACT_ROOT}/docker-debs"
TOOLS_DIR="${ARTIFACT_ROOT}/tools"
KUBECTL_VERSION="${KUBECTL_VERSION:-}"

if [[ "$(dpkg --print-architecture)" != "amd64" ]]; then
  echo "ERROR: run on an AMD64 Ubuntu staging host." >&2
  exit 1
fi

ubuntu_version="$(awk -F= '$1 == "VERSION_ID" {gsub(/\"/, "", $2); print $2}' /etc/os-release)"
if [[ "${ubuntu_version}" != "24.04" ]]; then
  echo "ERROR: run on Ubuntu 24.04 so downloaded dependencies match the NKP bastion." >&2
  exit 1
fi

mkdir -p "${BASE_DEB_DIR}" "${DOCKER_DEB_DIR}" "${TOOLS_DIR}"

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  ca-certificates curl gnupg apt-rdepends

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
sudo chmod 0644 /etc/apt/keyrings/docker.asc

docker_arch="$(dpkg --print-architecture)"
ubuntu_codename="$(awk -F= '$1 == "VERSION_CODENAME" {gsub(/\"/, "", $2); print $2}' /etc/os-release)"
printf '%s\n' \
  "Types: deb" \
  "URIs: https://download.docker.com/linux/ubuntu" \
  "Suites: ${ubuntu_codename}" \
  "Components: stable" \
  "Architectures: ${docker_arch}" \
  "Signed-By: /etc/apt/keyrings/docker.asc" |
  sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null
sudo apt-get update

base_packages=(
  python3
  python3-apt
  openssh-server
  sudo
  acl
  ca-certificates
  curl
  gnupg
  tar
  unzip
)

docker_packages=(
  docker-ce
  docker-ce-cli
  containerd.io
  docker-buildx-plugin
)

download_dependency_closure() {
  local destination="$1"
  shift
  local -a requested=("$@")
  local package candidate
  local dependency_file
  dependency_file="$(mktemp)"

  {
    printf '%s\n' "${requested[@]}"
    apt-rdepends "${requested[@]}" 2>/dev/null |
      sed -n -E 's/^[[:space:]]*(Pre)?Depends:[[:space:]]*//p'
  } |
    sed -E 's/[[:space:]]*\([^)]*\)//g; s/^<([^>]+)>$/\1/' |
    awk 'NF == 1 && $1 !~ /^\|/ {print $1}' |
    sort -u >"${dependency_file}"

  while IFS= read -r package; do
    candidate="$(apt-cache policy "${package}" | awk '/Candidate:/ {print $2; exit}')"
    if [[ -z "${candidate}" || "${candidate}" == "(none)" ]]; then
      echo "Skipping virtual or unavailable dependency: ${package}"
      continue
    fi
    echo "Downloading ${package}=${candidate}"
    (
      cd "${destination}"
      apt-get download "${package}=${candidate}"
    )
  done <"${dependency_file}"

  rm -f "${dependency_file}"
}

download_dependency_closure "${BASE_DEB_DIR}" "${base_packages[@]}"
download_dependency_closure "${DOCKER_DEB_DIR}" "${docker_packages[@]}"

docker_version="$(
  dpkg-deb -f "$(find "${DOCKER_DEB_DIR}" -maxdepth 1 -type f -name 'docker-ce_*_amd64.deb' | head -n 1)" Version
)"
if ! dpkg --compare-versions "${docker_version#*:}" ge 27.4.0; then
  echo "ERROR: downloaded Docker ${docker_version}, but NKP requires Docker 27.4.0 or newer." >&2
  exit 1
fi

if [[ -z "${KUBECTL_VERSION}" ]]; then
  KUBECTL_VERSION="$(curl -fsSL https://dl.k8s.io/release/stable-1.35.txt)"
fi
if [[ ! "${KUBECTL_VERSION}" =~ ^v1\.35\.[0-9]+$ ]]; then
  echo "ERROR: KUBECTL_VERSION must be a v1.35.x release; got ${KUBECTL_VERSION}." >&2
  exit 1
fi

curl -fL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
  -o "${TOOLS_DIR}/kubectl-linux-amd64"
curl -fL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256" \
  -o "${TOOLS_DIR}/kubectl-linux-amd64.sha256"
(
  cd "${TOOLS_DIR}"
  printf '%s  %s\n' "$(<kubectl-linux-amd64.sha256)" kubectl-linux-amd64 |
    sha256sum --check
)
chmod 0755 "${TOOLS_DIR}/kubectl-linux-amd64"

manifest="${ARTIFACT_ROOT}/generic-artifacts.sha256"
(
  cd "${ARTIFACT_ROOT}"
  find base-debs docker-debs tools -maxdepth 1 -type f \
    ! -name '.gitkeep' ! -name '*.sha256' -print0 |
    sort -z |
    xargs -0 sha256sum >"${manifest}"
)

echo
echo "Generic air-gapped artifacts downloaded successfully."
echo "Docker version: ${docker_version}"
echo "kubectl version: ${KUBECTL_VERSION}"
echo "Checksum manifest: ${manifest}"
echo
echo "You must still supply the Nutanix files under nkp-cli/, os-images/, and air-gapped-bundle/."
