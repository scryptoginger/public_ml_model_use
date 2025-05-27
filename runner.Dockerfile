# Use a slim Python base to minimize image size
FROM python:3.11-slim

# Install OS packages req'd by ModelScan and huggingface_hub
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
	apt-get install -y --no-install-recommends \
	curl tar git unzip python3-distutils

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir "modelscan[tensorflow,h5py]"
# RUN pip install --no-cache-dir "kitops-cli>=1.6.0"
RUN pip install setuptools

# Install KitOps CLI binary
COPY tools/kit /usr/local/bin/kit
RUN chmod +x /usr/local/bin/kit

# Copy pipeline scripts into the image
COPY scripts/ ./scripts/