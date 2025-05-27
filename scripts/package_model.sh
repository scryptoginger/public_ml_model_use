#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <model-dir> <output-dir>"
  exit 1
fi

MODEL_DIR=$1
OUTPUT_DIR=$2
mkdir -p "$OUTPUT_DIR"

# Ensure KitOps CLI is on PATH
if ! command -v kit &>/dev/null; then
  echo "ERROR: KitOps CLI not found on PATH" >&2
  exit 1
else
	echo "KitOps CLI found!"
fi

ROOT_DIR="$(git rev-parse --show-toplevel)"
KITFILE_PATH="$ROOT_DIR/Kitfile"
OUTFILE="$OUTPUT_DIR/model.kit"

# remove any stale Kitfile
rm -f "$MODEL_DIR/Kitfile"

echo "Packing model via KitOps…"
kit pack "$MODEL_DIR" -f "$KITFILE_PATH"


# Grab the first .kit produced
SOURCE_KIT=$(ls "$MODEL_DIR"/*.kit | head -n 1)

if [ -z "$SOURCE_KIT" ]; then
  echo "ERROR: no .kit file found in $MODEL_DIR" >&2
  exit 1
fi

# Move it where the Jenkins archive stage expects it
mv "$SOURCE_KIT" "$OUTFILE"

echo "Model packaged via KitOps at: $OUTFILE."