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

rm -f "$MODEL_DIR/Kitfile"  # remove any stale Kitfile

# Grab 'name: …' even if it’s indented; default to 'model'
NAME=$(grep -E '^[[:space:]]*name:' "$KITFILE_PATH" | awk '{print $2}') || true
NAME=${NAME:-model}
TAG="models/${NAME}:local"

echo "Packing model via KitOps…"
# build into the local Kit Ops registry and capture the digest
DIGEST=$(kit pack "$MODEL_DIR" \
                   -f "$KITFILE_PATH" \
                   -t "$TAG" \
        | awk '/Model saved:/ {print $3}')

# write the digest as the build artifact
echo "$DIGEST" > "$OUTPUT_DIR/model.digest"

echo "ModelKit stored locally with digest $DIGEST"