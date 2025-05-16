#!/usr/bin/env python3
import argparse
import os
import shutil

def main():
	parser = argparse.ArgumentParser(description="Package model directory into an archive")
	parser.add_argument(
		"--model-dir",
		default="model",
		help="Directory containing model files to package"
	)
	parser.add_argument(
		"--output-dir",
		default="output",
		help="Directory to write the archive to"
	)
	args = parser.parse_args()

	os.makedirs(args.output_dir, exist_ok=True)
	base_name = os.path.join(args.output_dir, "model_package")
	archive_path = shutil.make_archive(base_name, 'zip', args.model_dir)
	print(f"Model packaged into '{archive_path}'.")

if __name__ == "__main__":
	main()