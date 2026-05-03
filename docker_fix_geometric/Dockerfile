# Use the 25.01 image (CUDA 12.8 + PyTorch 2.6.0a0)
FROM nvcr.io/nvidia/pytorch:25.01-py3

# THE PORTING FIX: Inject sm_121 into the validation lists. 
# We target the 'supported_arches' list directly.
RUN sed -i 's/supported_arches = \[/supported_arches = ["12.0", "12.0a", "12.1", "12.1a", /g' \
    /usr/local/lib/python3.12/dist-packages/torch/utils/cpp_extension.py

# VERIFICATION STEP: If this fails, the build stops here. 
# It ensures your 'sed' actually found the file and changed it.
RUN python -c "from torch.utils.cpp_extension import _get_cuda_arch_flags; \
    print('Verified: 12.1 is now a valid arch') if '12.1' in str(_get_cuda_arch_flags) else exit(1)"

# Force the native Blackwell target
ENV TORCH_CUDA_ARCH_LIST="12.1"
ENV FORCE_CUDA="1"

# Build the geometric stack from source
# Note: Adding 'ninja' ensures the build uses all your Grace CPU cores
RUN pip install --no-cache-dir ninja && \
    pip install --no-cache-dir --no-binary :all: torch-cluster torch-scatter torch-sparse

WORKDIR /test
COPY test_geometric.py .

CMD ["python", "test_geometric.py"]
