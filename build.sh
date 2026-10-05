#!/usr/bin/env bash
# Compile, package, and reinstall into local VS Code. Then run 'Developer: Reload Window'.
set -euo pipefail
cd "$(dirname "$0")"

NAME="$(node -p "require('./package.json').name")"
EXT_ID="$(node -p "require('./package.json').publisher").${NAME}"
VSIX="${NAME}.vsix"

npm run compile
npx vsce package --allow-missing-repository --skip-license --out "${VSIX}"
code --uninstall-extension "${EXT_ID}" >/dev/null 2>&1 || true
code --install-extension "${VSIX}" --force
