#!/usr/bin/env bash
# Registers the upstream firmware projects as git submodules and checks out
# the MicroSlate commit our patches were built against.
#
# Run this once, from anywhere inside the repo, after the repo has at least
# one commit (a bare/empty repo can't take submodules).
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "== Adding submodules =="
git submodule add https://github.com/Josh-writes/microslate-firmware.git firmware/microslate
git submodule add https://github.com/uxjulia/CrossInk.git firmware/crossink
git submodule add https://gitlab.com/zephray/paperboy.git firmware/paperboy

# Reference only — upstream CrossPoint's own PaperS3 touch port. Not built,
# not part of firmware/. Kept so we can re-diff it while working out the
# CrossInk touch port (see patches/crossink/PORTING.md).
git submodule add https://github.com/juicecultus/crosspoint-reader-papers3.git reference/crosspoint-reader-papers3
git submodule add https://github.com/crosspoint-reader/crosspoint-reader.git reference/crosspoint-reader

git submodule update --init --recursive

echo "== Pinning firmware/microslate to the commit our patch was built against =="
( cd firmware/microslate && git checkout d5236ed77677bf4596dce3d69169602a98cf0e13 )

echo
echo "Done. Submodules are under firmware/ (build targets) and reference/ (read-only, for porting work)."
echo "Next: run scripts/apply-patches.sh"
