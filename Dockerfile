# =============================================================================
# DIFFDOCK HIERARCHICAL BUILD (Three‑Layer Dockerfile)
#
#   Layer 1 – Hardware Geometric Base (gb10‑v2)
#     NEVER changes. Published as ghcr.io/faisalmemon/diffdock/diffdock-base:gb10-v2.
#     Contains PyTorch 2.6.0 + torch_scatter + torch_sparse + torch_cluster.
#     Build time: 30+ min, but fully cached.
#
#   Layer 2 – Molecular Biology Layer
#     Changes occasionally. OpenFold, ProDy, biopython, tkinter.
#     Build time: ~3–5 min.
#
#   Layer 3 – Diffdock Application Layer
#     Changes constantly. Application code, requirements, precompute_series.
#     Build time: seconds.
# =============================================================================

# ----- LAYER 1 : HARDWARE GEOMETRIC BASE -----
FROM ghcr.io/faisalmemon/diffdock/diffdock-base:gb10-v2 AS base

# ----- LAYER 2 : MOLECULAR BIOLOGY -----
FROM base AS biology

# Create the app user and set up workspace
ENV APPUSER="appuser"
RUN useradd -m -u 1000 $APPUSER
WORKDIR /home/$APPUSER/DiffDock

# Environment: PYTHONPATH includes local code and OpenFold
ENV PYTHONPATH="/home/$APPUSER/DiffDock:/opt/openfold:${PYTHONPATH}"
ENV NVIDIA_DISABLE_REQUIRE=true

# Install packages that change occasionally
# 1. ProDy – built from source to ensure Blackwell compatibility
RUN git clone https://github.com/prody/ProDy.git /tmp/prody && \
    cd /tmp/prody && \
    pip install . --no-build-isolation && \
    rm -rf /tmp/prody

# 2. Core Python biology tools
RUN pip install --no-cache-dir cython biopython setuptools numpy

# 3. OpenFold – built from source with Blackwell arch patches
RUN git clone https://github.com/aqlaboratory/openfold.git /opt/openfold && \
    cd /opt/openfold && \
    sed -i 's/arch=compute_37,code=sm_37//g' setup.py && \
    sed -i 's/arch=compute_52,code=sm_52//g' setup.py && \
    sed -i 's/arch=compute_61,code=sm_61//g' setup.py && \
    sed -i 's/arch=compute_80,code=sm_80/arch=compute_90,code=sm_90/g' setup.py && \
    pip install .

# 4. Tkinter for ProDy’s drugui (avoids crash)
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3-tk \
    tcl-dev \
    tk-dev \
    && rm -rf /var/lib/apt/lists/*

# ----- LAYER 3 : DIFFDOCK APPLICATION -----
FROM biology AS app

# Copy application requirements and install (changes constantly)
COPY --chown=1000:1000 requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy full application code
COPY --chown=1000:1000 . .

# Create runtime directories and precompute series
RUN mkdir -p /home/$APPUSER/DiffDock/results \
             /home/$APPUSER/.cache/torch/hub/checkpoints && \
    python utils/precompute_series.py && \
    chown -R 1000:1000 /home/$APPUSER/DiffDock /home/$APPUSER/.cache

# Switch to non‑root user
USER $APPUSER
# Default command
CMD ["python", "inference.py"]

