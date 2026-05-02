#!/bin/bash
 
# Configuration
USER="faisalm"
REPO="protein-docking"
IMAGE_NAME="diffdock-base"
TAG="gb10-v1"
FULL_IMAGE_NAME="ghcr.io/$USER/$REPO/$IMAGE_NAME:$TAG"

echo "🚀 Building $FULL_IMAGE_NAME..."

# Build the image
docker build -t "$FULL_IMAGE_NAME" -f Dockerfile.gb10 --progress=plain .

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "🔗 To push to GitHub, run: docker push $FULL_IMAGE_NAME"
else
    echo "❌ Build failed."
    exit 1
fi
