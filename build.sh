#!/usr/bin/env bash
#
# Build the extension locally by compiling the TypeScript into ./out.
#
# Usage:
#   ./build.sh          # compile once
#   ./build.sh --watch  # recompile on changes
#
# To try the extension, open this folder in VS Code and press F5 to launch it
# in an Extension Development Host window.
set -euo pipefail

# Resolve repo root (this script's dir) so it works from anywhere.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

if [[ "${1:-}" == "--watch" ]]; then
  echo "==> Watching and compiling"
  npm run watch
else
  echo "==> Compiling"
  npm run compile
  echo "==> Done. Output in ./out"
fi
