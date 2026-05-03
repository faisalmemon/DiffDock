#!/bin/bash

# Create a local cache dir on the Spark host so we don't lose the downloads
mkdir -p $(pwd)/.cache/torch_extensions
mkdir -p $(pwd)/.cache/torch/hub
mkdir -p $(pwd)/results
chmod -R 777 $(pwd)/results $(pwd)/.cache

docker run --rm --gpus all \
  --ipc=host \
  --ulimit memlock=-1 \
  --ulimit stack=67108864 \
  -e NVIDIA_DISABLE_REQUIRE=true \
  -e CUDA_MODULE_LOADING=LAZY \
  -e CUDA_FORWARD_COMPAT_RELEASE=580 \
  -e TORCH_CUDA_ARCH_LIST="9.0" \
  -v $(pwd)/.cache:/home/appuser/.cache \
  -v $(pwd)/results:/home/appuser/DiffDock/results \
  diffdock:gb10 \
  python -m inference --config default_inference_args.yaml \
  --protein_path data/1a0q/1a0q_protein_processed.pdb \
  --ligand_description "CC1=CC2=C(C=C1C)N(C=N2)C3C(C(C(O3)CO)O)O" \
  --out_dir results/smoke_test

