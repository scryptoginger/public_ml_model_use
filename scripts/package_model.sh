#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
	echo "Usage: $0 <model-dir> <output-dir>"
	exit 1
fi

MODEL_DIR=$1
OUTPUT_DIR=$2
TOOLS_DIR="$(dirname "$0")../tools"
KIT="$TOOLS_DIR/kit"

mkdir -p "$OUTPUT_DIR"

if [[ ! -x "$KIT" ]]; then
	echo "ERROR: KitOps CLI not found at $KIT" >&2
	exit 1
fi

OUTFILE="$OUTPUT_DIR/model.kit"
echo "Packing '$MODEL_DIR' -> '$OUTFILE' via KitOps…"
"$KIT" pack \
	--source "$MODEL_DIR" \
	--output "$OUTFILE" \
	|| { echo "KitOps pack failed"; exit 1; }

echo "Model packaged via KitOps at: $OUTFILE"