#!/usr/bin/env bash
#
# Rebuild, repackage, and reinstall the extension into your local VS Code.
# Run this between iterations: it compiles, produces a fresh .vsix, removes any
# previously installed copy, then installs the new one.
#
# Usage:
#   ./scripts/reinstall.sh          # build + reinstall
#   ./scripts/reinstall.sh --reload # also reopen the workspace window when done
#
set -euo pipefail

# Resolve repo root (parent of this script's dir) so it works from anywhere.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Read name/version/publisher from package.json without extra tooling.
NAME="$(node -p "require('./package.json').name")"
VERSION="$(node -p "require('./package.json').version")"
PUBLISHER="$(node -p "require('./package.json').publisher")"
EXT_ID="${PUBLISHER}.${NAME}"
VSIX="${NAME}-${VERSION}.vsix"

echo "==> Extension: ${EXT_ID} (v${VERSION})"

# Pick a VS Code CLI: prefer 'code', fall back to 'cursor'. Override with CODE_BIN.
CODE_BIN="${CODE_BIN:-}"
if [[ -z "${CODE_BIN}" ]]; then
  if command -v code >/dev/null 2>&1; then
    CODE_BIN="code"
  elif command -v cursor >/dev/null 2>&1; then
    CODE_BIN="cursor"
  else
    echo "ERROR: no 'code' or 'cursor' CLI on PATH." >&2
    echo "  In VS Code: Cmd+Shift+P -> 'Shell Command: Install code command in PATH'." >&2
    echo "  Or set CODE_BIN=/path/to/code and re-run." >&2
    exit 1
  fi
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
# --allow-missing-repository keeps packaging from failing on this minimal manifest.
${VSCE} package --allow-missing-repository

echo "==> Uninstalling previous ${EXT_ID} (ignored if not installed)"
"${CODE_BIN}" --uninstall-extension "${EXT_ID}" >/dev/null 2>&1 || true

echo "==> Installing ${VSIX}"
"${CODE_BIN}" --install-extension "${VSIX}" --force

if [[ "${1:-}" == "--reload" ]]; then
  echo "==> Reopening ${ROOT} in the current ${CODE_BIN} window"
  "${CODE_BIN}" --reuse-window "${ROOT}" >/dev/null 2>&1 || true
fi

echo "==> Done. If the change isn't live, run 'Developer: Reload Window' in VS Code."
