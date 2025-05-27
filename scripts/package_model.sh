#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <model-dir> <output-dir>"
  exit 1
fi

MODEL_DIR=$1
OUTPUT_DIR=$2

mkdir -p "$OUTPUT_DIR"

if ! command -v kit &>/dev/null; then
  echo "ERROR: KitOps CLI not found on PATH" >&2
  exit 1
fi

ROOT_DIR="$(git rev-parse --show-toplevel)"
KITFILE_PATH="$ROOT_DIR/Kitfile"
OUTFILE="$OUTPUT_DIR/model.kit"

rm -f "$MODEL_DIR/Kitfile"

echo "Packing '$MODEL_DIR' -> '$OUTFILE' via KitOps…"
kit pack "$MODEL_DIR" -f "$KITFILE_PATH"

# ── Locate the file KitOps just created ──────────────────────────────
# It uses the Kitfile metadata.name, with .kit extension.
KIT_NAME=$(yq '.metadata.name' < "$KITFILE_PATH")  # needs yq (already in many python images)
SOURCE_KIT="$MODEL_DIR/${KIT_NAME}.kit"

if [ ! -f "$SOURCE_KIT" ]; then
  echo "ERROR: Expected Kit archive '$SOURCE_KIT' not found" >&2
  exit 1
fi

# Move it where the Jenkins archive stage expects it
mkdir -p "$OUTPUT_DIR"
mv "$SOURCE_KIT" "$OUTFILE"

echo "Model packaged via KitOps at: $OUTFILE."