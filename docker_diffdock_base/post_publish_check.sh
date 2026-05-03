#!/bin/bash
 
docker run --rm --gpus all ghcr.io/faisalmemon/diffdock/diffdock-base:gb10-v1 \
python3 -c "import torch; import prody; import openfold; print(f'GPU Detected: {torch.cuda.get_device_name(0)}'); print('🧬 ProDy and OpenFold are ready for docking!')"
