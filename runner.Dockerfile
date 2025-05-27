# Use a slim Python base to minimize image size
FROM python:3.11-slim

# Install OS packages req'd by ModelScan and huggingface_hub
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
	curl tar git unzip python3-distutils && \
	rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir "modelscan[tensorflow,h5py]"
RUN pip install setuptools

# ── Install Kit CLI 1.6.0 matching the build platform ──────────────
ARG KIT_VERSION=1.6.0
ARG KIT_ARCH=Linux_x86_64   # buildx swaps this to Linux_arm64 on ARM
RUN curl -sSL https://github.com/kitops-ml/kitops/releases/download/v${KIT_VERSION}/kit_${KIT_ARCH}.tar.gz | tar -xz -C /usr/local/bin kit && chmod +x /usr/local/bin/kit

# Install KitOps CLI binary
COPY tools/kit /usr/local/bin/kit
RUN chmod +x /usr/local/bin/kit

# Copy pipeline scripts into the image
COPY scripts/ ./scripts/