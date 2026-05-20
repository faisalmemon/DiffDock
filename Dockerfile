# =============================================================================
# DIFFDOCK HIERARCHICAL BUILD (Three‑Layer Dockerfile)
#
#   Layer 1 – Hardware Geometric Base (gb10‑v2)
#     NEVER changes. Published as ghcr.io/faisalmemon/diffdock/diffdock-base:gb10-v2.
#
#   Layer 2 – Molecular Biology Layer
#     Changes occasionally. OpenFold, ProDy, biopython, tkinter.
#
#   Layer 3 – Diffdock Application Layer
#     Changes constantly. Application code, requirements, precompute_series.
# =============================================================================

# ----- LAYER 1 : HARDWARE GEOMETRIC BASE -----
FROM ghcr.io/faisalmemon/diffdock/diffdock-base:gb10-v2 AS base

# ----- LAYER 2 : MOLECULAR BIOLOGY -----
FROM base AS biology

# Create the appuser (UID 1000) since the base image doesn't include it
RUN useradd -m -u 1000 -s /bin/bash appuser && \
    passwd -d appuser
ENV APPUSER="appuser"
WORKDIR /home/$APPUSER/DiffDock

# PYTHONPATH: local code first, then OpenFold
ENV PYTHONPATH="/home/$APPUSER/DiffDock:/opt/openfold"
ENV NVIDIA_DISABLE_REQUIRE=true

# Install packages that change occasionally
# 1. ProDy – built from source for Blackwell compatibility
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
COPY --chown=$APPUSER:$APPUSER requirements.txt .

# Ensure setuptools is installed (required by pandas==1.5.1 for pkg_resources)
RUN pip install --no-cache-dir --upgrade pip setuptools

RUN pip install --no-cache-dir -r requirements.txt

# Copy full application code
COPY --chown=$APPUSER:$APPUSER . .

# Create runtime directories and precompute series
RUN mkdir -p /home/$APPUSER/DiffDock/results \
             /home/$APPUSER/.cache/torch/hub/checkpoints && \
    python utils/precompute_series.py && \
    chown -R $APPUSER:$APPUSER /home/$APPUSER/DiffDock /home/$APPUSER/.cache

# Switch to non-root user (already exists)
USER $APPUSER

# Default command
CMD ["python", "inference.py"]