# Use the latest NVIDIA PyTorch image (25.01+ contains CUDA 13.0+, required for Blackwell)
FROM nvcr.io/nvidia/pytorch:25.01-py3

# Explicitly target the Spark GB10 hardware
# sm_121 is the native arch; sm_120 provides the forward-compatible PTX
ENV TORCH_CUDA_ARCH_LIST="12.0;12.1"
ENV FORCE_CUDA="1"

# Install only the system essentials for C++ compilation
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# THE CORE FIX: Install from source
# We use --no-binary to force 'pip' to compile the C++ kernels locally
# instead of downloading a wheel built for older GPUs.
RUN pip install --no-cache-dir --no-binary :all: torch-cluster

# Add your test script
WORKDIR /test
COPY ../pre_flight_checks/test_geometric.py .

CMD ["python", "test_geometric.py"]
