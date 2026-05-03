# Use the NVIDIA PyTorch 25.01 base (Grace-ARM + Blackwell support)
FROM nvcr.io/nvidia/pytorch:25.01-py3

# 1. THE GATEKEEPER PATCH
# We manually inject sm_120/121 into the PyTorch validation lists.
# This unblocks the 'ValueError: Unknown CUDA arch' during the build.
RUN sed -i "1994s/'10.0,12.0+PTX'/'10.0;12.0;12.1+PTX'/" /usr/local/lib/python3.12/dist-packages/torch/utils/cpp_extension.py && \
    sed -i "2000s/'12.0'/'12.0', '12.1', '12.1a'/" /usr/local/lib/python3.12/dist-packages/torch/utils/cpp_extension.py

# 2. THE COMPILER WORKAROUND
# We target sm_120 because NVCC 12.8 understands it as the Blackwell baseline.
# This bypasses the 'fatal: Unsupported gpu architecture compute_121' error.
ENV TORCH_CUDA_ARCH_LIST="12.0"
ENV FORCE_CUDA="1"

# 3. BUILD OPTIMIZATION
# Ninja allows us to use all the Grace CPU cores for a faster parallel build.
RUN pip install --no-cache-dir ninja

# 4. NATIVE GEOMETRIC STACK COMPILATION
# We build from source to ensure the kernels are baked for Blackwell.
RUN pip install --no-cache-dir --no-binary :all: torch-cluster && \
    pip install --no-cache-dir --no-binary :all: torch-scatter && \
    pip install --no-cache-dir --no-binary :all: torch-sparse

# 5. WORKSPACE SETUP
WORKDIR /workspace
# Copy your verified test script to ensure sovereignty on the next boot
COPY pre_flight_checks/test_geometric.py .

# Recommended runtime settings for DGX Spark (Grace-Blackwell)
# Use --ipc=host and --gpus all when running this image
CMD ["python", "test_geometric.py"]

