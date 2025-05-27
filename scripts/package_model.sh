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

if [ ! -f "$MODEL_DIR/Kitfile" ]; then
	cat >"$MODEL_DIR/Kitfile" <<'EOF'
schemaVersion: "v1"
name: "model"
model:
	path: .
EOF
fi

OUTFILE="$OUTPUT_DIR/model.kit"
echo "Packing '$MODEL_DIR' -> '$OUTFILE' via KitOps…"
kit pack "$MODEL_DIR" #|| { echo "KitOps pack failed"; exit 1; }

echo "Model packaged via KitOps at: $OUTFILE"
