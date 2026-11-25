#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ISO_NAME="${1:-KKRIT-OS-2026.iso}"
VERSION="${VERSION:-45}"
BUILD_DIR="$REPO_DIR/.build-tmp"
IMG_DIR="$BUILD_DIR/img"

command -v bluebuild >/dev/null 2>&1 || { echo "bluebuild: command not found" >&2; exit 1; }
command -v podman >/dev/null 2>&1 || { echo "podman: command not found" >&2; exit 1; }

mkdir -p "$IMG_DIR"

cd "$REPO_DIR/src"
sudo env "PATH=$PATH" bluebuild build recipes/recipe.yml --archive "$IMG_DIR"

ARCHIVE="$(find "$IMG_DIR" -maxdepth 1 -type f \( -name '*.tar.gz' -o -name '*.gz' \) -printf '%T@ %p\n' | sort -n | tail -1 | cut -d' ' -f2-)"
[ -n "$ARCHIVE" ] || { echo "build archive not found in $IMG_DIR" >&2; exit 1; }

sudo podman run --rm --privileged --platform linux/amd64 \
  --volume "$IMG_DIR:/img_src/" \
  --volume "$REPO_DIR:/build-container-installer/build" \
  --volume dnf-cache:/cache/dnf/ \
  --env VARIANT=Kinoite \
  --env ISO_NAME="build/$ISO_NAME" \
  --env DNF_CACHE=/cache/dnf \
  --env SECURE_BOOT_KEY_URL=https://github.com/ublue-os/bazzite/raw/main/secure_boot.der \
  --env ENROLLMENT_PASSWORD=universalblue \
  --env WEB_UI=false \
  --env "IMAGE_SRC=oci-archive:/img_src/$(basename "$ARCHIVE")" \
  --env "VERSION=$VERSION" \
  ghcr.io/jasonn3/build-container-installer:v1.5.0

echo "ISO: $REPO_DIR/$ISO_NAME"
