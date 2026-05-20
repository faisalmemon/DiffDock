#!/bin/bash

docker run --gpus all --ipc=host \
  -v /home/faisalm/.cache/torch:/home/ubuntu/.cache/torch \
  -v /home/faisalm/dev/DiffDock/results:/home/ubuntu/DiffDock/results \
  ghcr.io/faisalmemon/diffdock/diffdock-app:gb10-v2
