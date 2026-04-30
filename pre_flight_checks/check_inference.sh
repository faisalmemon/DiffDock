#!/bin/bash

# Define absolute paths for the container to make the script readable
CONTAINER_DATA="/home/appuser/DiffDock/data"
CONTAINER_CACHE="/home/appuser/.cache"
INNER_COMMAND="pip install --force-reinstall --no-cache-dir --no-binary :all: torch-scatter torch-sparse torch-cluster torch-spline-conv && python inference.py --protein_path $CONTAINER_DATA/1a0q/1a0q_protein_processed.pdb --ligand_description $CONTAINER_DATA/1a0q/1a0q_ligand.sdf --out_dir $CONTAINER_DATA/1a0q/output --samples_per_complex 10"

docker run --rm -it --gpus all \
  -v $(pwd)/../data:$CONTAINER_DATA \
  -v $(pwd)/../cache/torch:$CONTAINER_CACHE/torch \
  diffdock:gb10 \
  micromamba run -n diffdock /bin/bash -c "$INNER_COMMAND"
