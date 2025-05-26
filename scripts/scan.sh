#!/usr/bin/env bash
set -e

# 1. validate args: expect exactly 3: <model-dir> --output <output-json>
if [ "$#" -ne 3 ]; then
	echo "Usage: $0 <model-dir> <policy-file> --output <output-json>"
	exit 1
fi

# 2. extract params
MODEL_DIR=$1
if [ "$2" != "--output" ]; then # || [ -z "${2-}" ]; then
	echo "Usage: $(basename "$0") <model-dir> --output <output-json>"
	echo "also...Error: expected --output <output-json>"
	exit 1
fi
OUTPUT_JSON=$3

# run modelscan
modelscan scan -p "$MODEL_DIR" -r json --output "$OUTPUT_JSON"

echo "Scan complete. Report written to '$OUTPUT_JSON'."