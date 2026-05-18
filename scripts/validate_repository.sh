#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

echo "Checking shell syntax"
while IFS= read -r file; do
  bash -n "${file}"
done < <(find . -path ./.git -prune -o -name '*.sh' -type f -print)

echo "Checking JSON syntax"
node <<'NODE'
const fs = require('fs');
const path = require('path');

function walk(dir, files = []) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (entry.name === '.git' || entry.name === 'node_modules') continue;
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      walk(fullPath, files);
    } else if (entry.isFile() && entry.name.endsWith('.json')) {
      files.push(fullPath);
    }
  }
  return files;
}

for (const file of walk('.')) {
  JSON.parse(fs.readFileSync(file, 'utf8'));
}
NODE

echo "Checking YAML syntax"
ruby <<'RUBY'
require 'yaml'

Dir.glob('**/*.{yml,yaml}', File::FNM_DOTMATCH).each do |file|
  next if file.start_with?('.git/')
  YAML.load_file(file)
end
RUBY

echo "Checking for obvious secret patterns"
secret_matches="$(grep -R -I -n -E \
  'nx2Tech|BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9_]{36,}|hf_[A-Za-z0-9]{20,}' \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude=validate_repository.sh \
  . || true)"

if [[ -n "${secret_matches}" ]]; then
  echo "${secret_matches}"
  echo "Potential secret pattern detected. Review before publishing."
  exit 1
fi

echo "Repository validation passed"
