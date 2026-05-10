#!/bin/sh
# Build and run the riot Linux installation test.
# Usage: ./docker/test-linux.sh [--no-cache]
set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMAGE="riot-linux-test"

echo "==> Building Docker image (this may take a few minutes the first time)..."
docker build "$@" -t "$IMAGE" -f "$REPO_ROOT/docker/Dockerfile" "$REPO_ROOT"

echo ""
echo "==> Image built successfully. riot installs cleanly on Linux."
