#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

# Ensure critical variables are set
: "${IMAGE_REGISTRY:?IMAGE_REGISTRY is required}"
: "${IMAGE_NAME:?IMAGE_NAME is required}"
: "${MODULE_DIRECTORY:-"/tmp/modules"}"

CONTAINER_DIR="/usr/etc/containers"
IMAGE_NAME_FILE="${IMAGE_NAME//\//_}"
IMAGE_REGISTRY_TITLE=$(echo "$IMAGE_REGISTRY" | cut -d'/' -f2-)

echo "Setting up container signing in policy.json and cosign.yaml for $IMAGE_NAME"
echo "Registry to write: $IMAGE_REGISTRY"

# Create directories if not exist
mkdir -p "$CONTAINER_DIR/registries.d"
mkdir -p "/usr/etc/pki/containers"
mkdir -p "/etc/pki/containers"

# Copy policy.json if it does not exist
if ! [ -f "$CONTAINER_DIR/policy.json" ]; then
    cp "$MODULE_DIRECTORY/signing/policy.json" "$CONTAINER_DIR/policy.json"
fi

# Copy public key files
cp "/usr/etc/pki/containers/$IMAGE_NAME.pub" "/usr/etc/pki/containers/$IMAGE_REGISTRY_TITLE.pub"
cp "/usr/etc/pki/containers/$IMAGE_NAME.pub" "/etc/pki/containers/$IMAGE_REGISTRY_TITLE.pub"
rm "/usr/etc/pki/containers/$IMAGE_NAME.pub"

# Move registry config and update with IMAGE_REGISTRY
mv "$MODULE_DIRECTORY/signing/registry-config.yaml" "$CONTAINER_DIR/registries.d/$IMAGE_REGISTRY_TITLE.yaml"
sed -i "s ghcr.io/IMAGENAME $IMAGE_REGISTRY g" "$CONTAINER_DIR/registries.d/$IMAGE_REGISTRY_TITLE.yaml"
