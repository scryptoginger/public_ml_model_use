# Safe Public Model Use: A Hugging Face Example
## Overview
This repository contains a reproducible, relatively plug-and-play pipeline to safely download, scan, modify, and package models from public sources (e.g., Hugging Face). It uses Jenkins and Docker to provide an automated, isolated, OS-agnostic workflow that meets secure usage and packaging standards.

Note: it is imperative that you do your own research and be cautious. Public models can be very dangerous. This example attempts to be an example of how you can do such a process in an automated way with important and powerful tools. 

This README will serve as a guide and explain the steps and processes happening. This example pipeline:
1. Downloads a lightweight, pre-determined, publicly available Hugging Face model (distilbert-base-uncased)
2. Runs a pre-use/modification scan using [ModelScan](https://pypi.org/project/modelscan/)
3. Modifies the model to simulate fine-tuning
4. Runs a post-use/modification scan
5. Packages the model using [KitOps](https://kitops.org)
6. Archives the packaged model for use in downstream systems

This pipeline is orchestrated using Jenkins and runs inside a Docker container to ensure environment consistency across platforms.

## Prerequisites
- Docker installed and running: Docker Desktop recommended for Mac/Windows; Linux: `apt install docker.io` (or similar for your distro) 
- This will use port **8080** by default (or next available port) - edit this in 'docker-compose.yaml' if necessary

## Quickstart
### 1. Clone the Repository
```bash
git clone https://github.com/<insert your git repo link>
cd new_dir_from_git_clone
```
### 2. Run Bootstrap.sh
This script will verify that Docker is present and running and brings up Jenkins within Docker. The Jenkins UI will be available at localhost:8080 (unless you changed it)
```bash
./bootstrap.sh
```
### 3. Unlock and Complete Jenkins Setup
```bash
docker exec -it jenkins bash -lc \
'cat /var/jenkins_home/secrets/initialAdminPassword'
```
This command will display the default admin password required to access Jenkins' UI
- Paste the password into the web UI
- Follow the setup wizard (you can skip if you want). 
- Opt to accept recommended plugins. 


You need to make sure you have the Docker plugins:
- Search Available Plugins (left hand menu) for "Docker".
- At minimum, install **Docker Pipeline** and **Docker Plugin**

Ensure your Jenkins agent has Docker installed and permissions to run containers.

## Jenkins Pipeline Stages 
The `Jenkinsfile` includes the following stages:

#### 1. Download Model
- Downloads the Hugging Face model to a local `./model/` directory.

#### 2. Pre-use/modification Scan
- Uses `modelscan` to scan the downloaded model directory before modification.

#### 3. Modify Model
- Runs a simple modification script (`modify_model.py`) to simulate user fine-tuning.

#### 4. Post-use/modification Scan
- Re-runs `modelscan` after modification to detect any changes and ensure there are no vulnerabilities.

#### 5. Package Model
- Uses `kit pack` to package the model folder into a `.kit` artifact.

#### 6. Archive Artifact
- Archives the `.kit` file as a build artifact for downstream use.

#### 7. Copies Results
- Copies the Jenkins job results into `/job_results`, a folder in the project root directory for easier access.

## ModelScan and KitOps Notes
- [ModelScan](https://pypi.org/project/modelscan/) is a security scanning tool for ML models.
- [KitOps](https://kitops.org) is used to securely package and distribute ML assets.
- KitOps is installed in the Docker container using the latest Linux binary from their official site.

## Output
At the end of a successful run, you will have:
- `scan_pre_modify.json` and `scan_post_modify.json` (optional scan result outputs)
- `my_model_package.kit`: a securely packaged, modified model artifact ready for distribution or deployment

## Optional: Kubernetes Integration
If Jenkins is deployed in Kubernetes, or if the `.kit` package must be deployed downstream:
- Use Kubernetes plugin for Jenkins to run builds in pods

- Define a persistent volume or container registry for sharing packaged artifacts