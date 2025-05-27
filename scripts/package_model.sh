#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
	echo "Usage: $0 <model-dir> <output-dir>"
	exit 1
fi

MODEL_DIR=$1
OUTPUT_DIR=$2
echo "MODEL_DIR: $MODEL_DIR\n\n"
mkdir -p "$OUTPUT_DIR"

if ! command -v kit &>/dev/null; then
	echo "ERROR: KitOps CLI not found on PATH" >&2
	exit 1
fi

# create Kitfile if it isn't present
if [ ! -f "$MODEL_DIR/Kitfile" ]; then
  cat <<-'EOF' > "$MODEL_DIR/Kitfile"
schemaVersion: "v1"
name: "model"
version: "0.1.0"
model:
  path: .
EOF
fi

OUTFILE="$OUTPUT_DIR/model.kit"
echo "Packing '$MODEL_DIR' -> '$OUTFILE' via KitOps…"
kit pack "$MODEL_DIR"

echo "Model packaged via KitOps at: $OUTFILE"