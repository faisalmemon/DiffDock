#!/bin/bash
 
docker run --rm --gpus all diffdock:gb10 micromamba run -n diffdock python -c 'import torch; print(f"CUDA Available: {torch.cuda.is_available()}"); print(f"Device Name: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else '\''None'\''}")'
