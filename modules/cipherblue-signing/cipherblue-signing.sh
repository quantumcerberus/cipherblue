#!/usr/bin/env bash

set -euo pipefail

CONTAINER_DIR="/usr/etc/containers"
ETC_CONTAINER_DIR="/etc/containers"
MODULE_DIRECTORY="${MODULE_DIRECTORY:-"/tmp/modules"}"
IMAGE_NAME_FILE="${IMAGE_NAME//\//_}"
IMAGE_REGISTRY_TITLE=$(echo "$IMAGE_REGISTRY" | cut -d'/' -f2-)

echo "Setting up container signing in cosign.yaml for $IMAGE_NAME"
echo "Registry to write: $IMAGE_REGISTRY"

cp "/etc/pki/containers/$IMAGE_NAME.pub" "/usr/etc/pki/containers/$IMAGE_REGISTRY_TITLE.pub"
cp "/etc/pki/containers/$IMAGE_NAME.pub" "/etc/pki/containers/$IMAGE_REGISTRY_TITLE.pub"
rm "/etc/pki/containers/$IMAGE_NAME.pub"

sed -i "s ghcr.io/IMAGENAME $IMAGE_REGISTRY g" "$MODULE_DIRECTORY/cipherblue-signing/registry-config.yaml"
cp "$MODULE_DIRECTORY/cipherblue-signing/registry-config.yaml" "$CONTAINER_DIR/registries.d/$IMAGE_REGISTRY_TITLE.yaml"
cp "$MODULE_DIRECTORY/cipherblue-signing/registry-config.yaml" "$ETC_CONTAINER_DIR/registries.d/$IMAGE_REGISTRY_TITLE.yaml"
rm "$MODULE_DIRECTORY/cipherblue-signing/registry-config.yaml"
