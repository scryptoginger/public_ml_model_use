# Load model directly
from transformers import AutoTokenizer, AutoModelForMaskedLM

tokenizer = AutoTokenizer.from_pretrained("distilbert/distilbert-base-uncased")
model = AutoModelForMaskedLM.from_pretrained("distilbert/distilbert-base-uncased")


## Safely download model files *without executing* them.
## Best practice is to scan files before opening them 
## in effort to prevent potential malicious code / attacks.
# snapshot_download(
# 	repo_id="distilbert-base-uncased",
# 	local_dir="./model",
# 	local_dir_use_symlinks=False  # Important for packaging/scanning later
# )
# print("Model files downloaded to ./model directory")