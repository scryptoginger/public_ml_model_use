#!/usr/bin/env python3
import argparse
import os
from huggingface_hub import snapshot_download

def main():
	parser = argparse.ArgumentParser(description="Download Hugging Face model to local directory.")
	parser.add_argument(
		"--repo-id",
		default="distilbert-base-uncased",
		help="Hugging Face model repo ID"
	)
	parser.add_argument(
		"--output-dir",
		default="model",
		help="Directory to store downloaded model files"
	)
	args = parser.parse_args()

	os.makedirs(args.output_dir, exist_ok=True)
	snapshot_download(
		repo_id=args.repo_id,
		local_dir=args.output_dir,
		local_dir_use_symlinks=False
	)
	print(f"Model '{args.repo_id}' downloaded to '{args.output_dir}'.")

if __name__ == "__main__":
	main()
