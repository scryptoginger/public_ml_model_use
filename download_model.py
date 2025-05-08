import os
from huggingface_hub import snapshot_download

## Ensure ./model directory exists
directory = "model"
try:
	os.mkdir(directory)
	print(f"Directory '{directory}' created successfully.")
except FileExistsError:
	print(f"Directory '{directory}' already exists...")
except OSError as error:
	print(f"Error creating directory: '{directory}': {str(error)}")

## Safely download model files *without executing* them.
## Best practice is to scan files before opening them 
## in effort to prevent potential malicious code / attacks.
snapshot_download(
	repo_id="distilbert-base-uncased",
	local_dir="./model",
	local_dir_use_symlinks=False  # Important for packaging/scanning later
)
print("Model files downloaded to ./model directory")