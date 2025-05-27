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

rm -f "$MODEL_DIR/Kitfile"  # remove any stale Kitfile

# Grab 'name: …' even if it’s indented; default to 'model'
NAME=$(grep -E '^[[:space:]]*name:' "$KITFILE_PATH" | awk '{print $2}') || true
NAME=${NAME:-model}
TAG="local://${NAME}:local"

echo "Packing model via KitOps…"
kit pack "$MODEL_DIR" -f "$KITFILE_PATH" -t "$TAG"

# Export to a portable file
mkdir -p "$OUTPUT_DIR"
kit save "$TAG" "$OUTPUT_DIR/model.kit"

echo "Model packaged via KitOps at: $OUTPUT_DIR/model.kit"