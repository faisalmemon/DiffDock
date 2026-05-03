#!/bin/bash

docker run --rm --gpus all \
  --ipc=host \
  --ulimit memlock=-1 \
  --ulimit stack=67108864 \
  diffdock:gb10 \
  python -m inference --config default_inference_args.yaml \
  --protein_path data/sample_data/6o0i_protein.pdb \
  --ligand_description "CC1=CC2=C(C=C1C)N(C=N2)C3C(C(C(O3)CO)O)O" \
  --out_dir results/smoke_test

