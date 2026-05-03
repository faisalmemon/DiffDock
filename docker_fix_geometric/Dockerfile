# Use the latest NVIDIA PyTorch image (25.01+ contains CUDA 13.0+, required for Blackwell)
FROM nvcr.io/nvidia/pytorch:25.01-py3

# TEACH PYTORCH ABOUT BLACKWELL (Backporting from GitHub main)
# We use sed to add 10.0, 12.0, and 12.1 to the validation list inside the container.
RUN sed -i 's/"9.0", "9.0a"/"9.0", "9.0a", "10.0", "10.0a", "12.0", "12.0a", "12.1", "12.1a"/g' \
    /usr/local/lib/python3.12/dist-packages/torch/utils/cpp_extension.py

# Now that the 'gatekeeper' code is patched to match GitHub main, 
# your environment will accept 12.1 as a valid architecture.
ENV TORCH_CUDA_ARCH_LIST="12.1"
ENV FORCE_CUDA="1"

# Force the source build of the geometric libraries
RUN pip install --no-cache-dir --no-binary :all: torch-cluster torch-scatter torch-sparse

WORKDIR /test
COPY test_geometric.py .

CMD ["python", "test_geometric.py"]

