# Start from official Ubuntu base image
FROM ubuntu:22.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt update && apt install -y \
    python3 python3-venv python3-pip \
    git curl build-essential

# Set working directory
WORKDIR /app

# Copy all files from your local repo into the container
COPY . /app

# Run your install script inside the container
RUN bash install_docker.sh

# Default command (just stay open)
CMD ["/bin/bash"]

RUN ln -s /usr/bin/python3 /usr/bin/python
ENV PATH="$PATH:/root/.local/bin"