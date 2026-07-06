#!/usr/bin/env bash
#
# Rebuild, repackage, and reinstall the extension into your local VS Code.
# Run this between iterations: it compiles, produces a fresh .vsix, removes any
# previously installed copy, then installs the new one. Reload VS Code yourself
# afterwards ('Developer: Reload Window') to pick up the change.
#
# Override the editor CLI with CODE_BIN=/path/to/code if 'code' isn't on PATH.
set -euo pipefail

# Resolve repo root (this script's dir) so it works from anywhere.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

# Read name/version/publisher from package.json without extra tooling.
NAME="$(node -p "require('./package.json').name")"
VERSION="$(node -p "require('./package.json').version")"
PUBLISHER="$(node -p "require('./package.json').publisher")"
EXT_ID="${PUBLISHER}.${NAME}"
VSIX="${NAME}-${VERSION}.vsix"

echo "==> Extension: ${EXT_ID} (v${VERSION})"

CODE_BIN="${CODE_BIN:-code}"
if ! command -v "${CODE_BIN}" >/dev/null 2>&1; then
  echo "ERROR: '${CODE_BIN}' CLI not on PATH." >&2
  echo "  In VS Code: Cmd+Shift+P -> 'Shell Command: Install code command in PATH'." >&2
  echo "  Or set CODE_BIN=/path/to/code and re-run." >&2
  exit 1
fi

# Ensure the packaging tool is available (prefer a local devDep, else npx).
if [[ -x "node_modules/.bin/vsce" ]]; then
  VSCE="node_modules/.bin/vsce"
elif command -v vsce >/dev/null 2>&1; then
  VSCE="vsce"
else
  echo "==> vsce not found; using 'npx @vscode/vsce'"
  VSCE="npx --yes @vscode/vsce"
fi

echo "==> Compiling"
npm run compile

echo "==> Packaging ${VSIX}"
rm -f "${VSIX}"
# Skip the repository/license prompts so local packaging never blocks on
# publishing requirements.
${VSCE} package --allow-missing-repository --skip-license

echo "==> Uninstalling previous ${EXT_ID} (ignored if not installed)"
"${CODE_BIN}" --uninstall-extension "${EXT_ID}" >/dev/null 2>&1 || true

echo "==> Installing ${VSIX}"
"${CODE_BIN}" --install-extension "${VSIX}" --force

echo "==> Done. Run 'Developer: Reload Window' in VS Code to pick up the change."
