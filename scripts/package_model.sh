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
pushd "$OUTPUT_DIR" >/dev/null   # change working dir
kit pack "$MODEL_DIR" -f "$KITFILE_PATH"
KIT_ARCHIVE=$(ls *.kit | head -n 1)
popd >/dev/null

if [ -z "$KIT_ARCHIVE" ]; then
  echo "ERROR: kit pack produced no .kit file" >&2
  exit 1
fi

echo "Model packaged via KitOps at: $OUTFILE."