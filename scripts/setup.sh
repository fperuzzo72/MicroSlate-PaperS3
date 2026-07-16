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

# Near-term launcher: CrossPoint's own, actively-maintained PaperS3 touch
# port. Used instead of a from-scratch CrossInk port for now — see
# docs/crosspoint-papers3-sync-plan.md for why. Pinned to its current
# release tag (1.3.2); syncing it to upstream CrossPoint 1.4.1 is tracked
# separately, not done as part of this setup.
git submodule add https://github.com/juicecultus/crosspoint-reader-papers3.git firmware/crosspoint
( cd firmware/crosspoint && git checkout v1.3.2 )

# Reference only — same repo as firmware/crosspoint above, but left on its
# default branch (latest, not pinned) so it can be diffed against
# reference/crosspoint-reader to track the upstream-sync gap. Also the
# source of truth when porting CrossInk's input layer later (see
# docs/crosspoint-papers3-sync-plan.md and patches/crossink/PORTING.md).
git submodule add https://github.com/juicecultus/crosspoint-reader-papers3.git reference/crosspoint-reader-papers3
git submodule add https://github.com/crosspoint-reader/crosspoint-reader.git reference/crosspoint-reader

git submodule update --init --recursive

echo "== Pinning firmware/microslate to the commit our patch was built against =="
( cd firmware/microslate && git checkout d5236ed77677bf4596dce3d69169602a98cf0e13 )

echo
echo "Done. Submodules are under firmware/ (build targets) and reference/ (read-only, for porting work)."
echo "Next: run scripts/apply-patches.sh"
