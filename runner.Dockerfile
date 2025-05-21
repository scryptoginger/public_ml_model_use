# Use a slim Python base to minimize image size
FROM python:3.11-slim

# Install OS packages req'd by ModelScan and huggingface_hub
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
	apt-get install -y --no-install-recommends \
	curl git unzip

WORKDIR /app

# Copy Python dependency list
COPY requirements.txt .

# Install Python packages (transformers, huggingface_hub, etc.)
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Install ModelScan (with TensorFlow support) via pip
RUN pip install --no-cache-dir "modelscan[tensorflow,h5py]"

# Install KitOps CLI binary
COPY tools/kit /usr/local/bin/kit
RUN chmod +x /usr/local/bin/kit

# Copy pipeline scripts into the image
COPY scripts/ ./scripts/

# Install distutils
RUN apt-get update && apt-get install -y python3-distutils && \
	rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip setuptools kitops modelscan