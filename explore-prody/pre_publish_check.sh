#!/bin/bash
 
docker run --rm --gpus all \
  -e NVIDIA_DISABLE_REQUIRE=true \
  -e NVIDIA_VISIBLE_DEVICES=all \
  explore_prody:gb10 \
  python -c "
  
import torch;
import torch_scatter;
import torch_cluster;
import prody;
print(f'CUDA Available: {torch.cuda.is_available()}');
print(f'GPU Device: {torch.cuda.get_device_name(0)}');
print('Success: All libraries loaded and linked!');
"

