#!/bin/bash
# =============================================================================
# Build script for hierarchical DiffDock image (three layers)
#
#   Layer 1 – Hardware Geometric Base  (pre‑built, NEVER changes)
#   Layer 2 – Molecular Biology        (occasional changes)
#   Layer 3 – Diffdock Application     (constant changes)
#
# Usage:
#   ./build_diffdock.sh                    – builds full app image
#   ./build_diffdock.sh --target biology   – builds only up to biology layer
#   ./build_diffdock.sh --push             – builds then pushes to GitHub
# =============================================================================

set -euo pipefail

# ----- Configuration -----
USER="faisalmemon"
REPO="diffdock"
IMAGE_NAME="diffdock-app"
TAG="gb10-v2"                  # bump this when biology or base changes
FULL_IMAGE_NAME="ghcr.io/$USER/$REPO/$IMAGE_NAME:$TAG"
DOCKERFILE="Dockerfile"        # new hierarchical Dockerfile in repo root

# ----- Parse optional arguments -----
TARGET=""
PUSH=false

for arg in "$@"; do
  case $arg in
    --target)
      shift
      TARGET="--target $1"
      ;;
    --push)
      PUSH=true
      ;;
  esac
  shift
done

# ----- Build -----
echo "🚀 Building $FULL_IMAGE_NAME ..."
echo "    Dockerfile : $DOCKERFILE"
echo "    Target     : ${TARGET:-full image}"
echo ""

docker build $TARGET -t "$FULL_IMAGE_NAME" -f "$DOCKERFILE" --progress=plain .

if [ $? -eq 0 ]; then
  echo ""
  echo "✅ Build successful!"

  # ----- Push (optional) -----
  if [ "$PUSH" = true ]; then
    echo "📦 Pushing to GitHub Container Registry ..."
    docker push "$FULL_IMAGE_NAME"
    echo "✅ Push complete: $FULL_IMAGE_NAME"
  else
    echo "🔗 To push later, run: docker push $FULL_IMAGE_NAME"
  fi
else
  echo "❌ Build failed."
  exit 1
fi
