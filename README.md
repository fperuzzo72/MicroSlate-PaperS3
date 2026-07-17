# MicroSlate + CrossPoint + PaperBoy on M5Stack PaperS3

This is the practical validation layer for [PaperOS](https://github.com/fperuzzo72/PaperOS)
— a philosophy of calm, deliberate computing. The manifesto explains *why*;
this repo is *how*, on real hardware.

Integrated firmware for the M5Stack PaperS3: **CrossPoint's own PaperS3
touch port** as the main-menu launcher (near-term — see
`docs/crosspoint-papers3-sync-plan.md` for why CrossPoint instead of
CrossInk for now), with MicroSlate (notes) built directly as a new
`Activity` inside that same app — not a separate firmware. CrossPoint and
MicroSlate share the same display/touch HAL once MicroSlate's `HalDisplay`
is ported, so there's no technical reason to keep them in separate OTA
partitions; one flash, one running process, grouped visually in the main
menu under "CrossPoint" / "MicroSlate" section labels.

PaperBoy (Game Boy emulator) stays a separate OTA partition — it bypasses
the shared display driver for its 60fps trick, a real hardware
incompatibility, not a structural choice. See `docs/partition-table.md`.

CrossInk remains the longer-term goal for the launcher itself (see
`patches/crossink/PORTING.md`) — nothing about that plan is dropped, it's
just not blocking a working device today.

## Structure

```
firmware/
  microslate/     — submodule, github.com/Josh-writes/microslate-firmware — reference only now (see below)
  crosspoint/     — submodule, github.com/juicecultus/crosspoint-reader-papers3 — the launcher AND where MicroSlate's Notes Activity lives
  crossink/       — submodule, github.com/uxjulia/CrossInk — future launcher, not yet ported
  paperboy/       — submodule, gitlab.com/zephray/paperboy
reference/
  crosspoint-reader/            — base CrossPoint at 1.4.1, for diffing CrossInk's divergence and tracking the sync gap
  crosspoint-reader-papers3/    — upstream's own PaperS3 touch port, latest (unpinned), porting reference
patches/
  microslate/     — accent + touch-input patches; MicroSlate's own HAL work, useful reference for the Notes Activity port even though it won't ship as a standalone firmware
  crosspoint/     — patches to firmware/crosspoint: 180° rotation, Notes menu entry
  crossink/       — CrossInk's PaperS3 touch port (not done yet — see PORTING.md)
docs/
  partition-table.md               — 16MB flash layout, boot-switch design
  crosspoint-papers3-sync-plan.md  — why CrossPoint over CrossInk, the unification decision, and the 1.3.2 → 1.4.1 upstream sync gap
  hardware-orientation.md          — this unit's fixed 180° mount, and the convention for future firmware
scripts/
  setup.sh          — registers all submodules, pins MicroSlate/CrossPoint to the tested commits
  apply-patches.sh  — applies the MicroSlate patch
```

## Getting started

```bash
git clone --recurse-submodules <this repo>
cd <this repo>
./scripts/apply-patches.sh
```

`firmware/crosspoint` is the one that matters for a working device: the
180°-rotation patch, and the "Notes" menu entry (`src/activities/notes/`,
currently a scaffold — see the TODO in `NotesActivity.cpp`) grouped under
CrossPoint/MicroSlate section labels in the main menu.

`firmware/microslate` no longer heads toward a standalone PaperS3 build —
its accent-support and touch-input HAL patches (`patches/microslate/`) stay
as reference material for porting the real MicroSlate editor logic into
`NotesActivity`, but MicroSlate itself won't ship as its own firmware image
on this device.

`firmware/crossink` is untouched — its touch port is real work, not a
mechanical patch (see `patches/crossink/PORTING.md`). It stays in the repo
for when we're ready to make it the launcher instead of CrossPoint.

`firmware/paperboy` is untouched — it already runs standalone on PaperS3;
integrating it means adding the boot-switch-back-to-launcher affordance
(same pattern as MicroSlate's Home header zone), not yet done.

## Status

- [x] Launcher: CrossPoint's PaperS3 port added, pinned at 1.3.2, flashed and confirmed working
- [x] Launcher: 180° rotation for this unit's fixed mount (see `docs/hardware-orientation.md`)
- [x] Launcher: "Notes" menu entry added, grouped under CrossPoint/MicroSlate section labels
- [ ] Launcher: sync CrossPoint-PaperS3 from 1.3.2 to 1.4.1 (362 commits —
      see `docs/crosspoint-papers3-sync-plan.md`, not started)
- [ ] MicroSlate: port the real note editor into `NotesActivity` (currently
      a placeholder) — text buffer, note file browser, keyboard input,
      reusing the logic already built in `patches/microslate/` but adapted
      to the Activity/EPD_Painter model instead of a standalone HAL
- [ ] CrossInk: PaperS3 touch port (plan in `patches/crossink/PORTING.md`) —
      future replacement for the CrossPoint launcher
- [ ] PaperBoy: way back to the launcher (currently standalone-only)
- [ ] PaperBoy: own OTA partition + boot-switch from the launcher
- [ ] Verify whether the X4/X3 `esp_ota_set_boot_partition()` bug exists on S3
