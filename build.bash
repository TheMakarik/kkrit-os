#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ISO_NAME="${1:-KKRIT-OS-2026.iso}"

command -v bluebuild >/dev/null 2>&1 || { echo "bluebuild: command not found" >&2; exit 1; }

cd "$REPO_DIR/src"

sudo env "PATH=$PATH" bluebuild generate-iso \
  --iso-name "$ISO_NAME" \
  --output-dir "$REPO_DIR" \
  recipe recipes/recipe.yml

echo "ISO: $REPO_DIR/$ISO_NAME"
