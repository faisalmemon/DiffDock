#!/bin/bash
set -e

# Create cache directory if it doesn't exist (mounted volume may be empty)
mkdir -p /home/ubuntu/.cache/torch/hub/checkpoints

# Run precompute series if the cache is missing (first run)
if [ ! -f /home/ubuntu/.cache/torch/hub/checkpoints/esm2_t33_650M_UR50D.pt ]; then
    echo "Precomputing series (downloading ESM models)..."
    python utils/precompute_series.py
fi

# Execute the CMD (inference.py)
exec "$@"