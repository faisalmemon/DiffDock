#!/bin/bash
#
docker run --rm diffdock:gb10 micromamba run -n diffdock python -c "import torch; import rdkit; import prody; import e3nn; import torch_geometric; print('All key libraries imported successfully!')"
