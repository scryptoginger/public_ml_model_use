#!/usr/bin/env bash
set -e

if [ "$#" -lt 3 ]; then
	echo "Usage: $0 <model-dir> <policy-file> --output <output-json>"
	exit 1
fi

MODEL_DIR=$1
POLICY_FILE=$2

# parse --output <file>
shift 2
if [ "$1" != "--output" ] || [ -z "${2-}" ]; then
	echo "Error: expected --output <output-json>"
	exit 1
fi
OUTPUT_JSON=$2

# run modelscan
modelscan scan \
	-p "$MODEL_DIR" \
	--settings-file "$POLICY_FILE" \
	-r json \
	-o "$OUTPUT_JSON"

echo "Scan complete. Report written to '$OUTPUT_JSON'."