#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "== MicroSlate =="
if [ ! -d firmware/microslate/.git ]; then
  echo "firmware/microslate submodule not found — run scripts/setup.sh first." >&2
  exit 1
fi
( cd firmware/microslate && \
  git apply --check ../../patches/microslate/microslate-papers3-combined.patch && \
  git apply ../../patches/microslate/microslate-papers3-combined.patch )
echo "MicroSlate: applied US-International accents + PaperS3 touch input HAL"
echo "  + permanent header/footer chrome + Bluetooth Scan/Disconnect remap."

echo
echo "== CrossInk =="
echo "No patch yet. CrossInk's input layer (MappedInputManager) has diverged"
echo "substantially from upstream CrossPoint (reader-mode button suppression,"
echo "simulator support, power-as-confirm fallback), so the PaperS3 touch port"
echo "needs a deliberate merge rather than a straight patch."
echo "See patches/crossink/PORTING.md for the plan and reference material."
