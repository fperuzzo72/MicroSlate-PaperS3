# MicroSlate + CrossPoint + PaperBoy on M5Stack PaperS3

Integrated firmware for the M5Stack PaperS3: **CrossPoint's own PaperS3
touch port** as the main-menu launcher (near-term — see
`docs/crosspoint-papers3-sync-plan.md` for why CrossPoint instead of
CrossInk for now), with MicroSlate (notes) and PaperBoy (Game Boy emulator)
as selectable apps, boot-switched via OTA partitions rather than merged into
one binary. See `docs/partition-table.md` for why (PaperBoy's display driver
is incompatible with a shared one).

CrossInk remains the longer-term goal for the launcher (see
`patches/crossink/PORTING.md`) — nothing about that plan is dropped, it's
just not blocking a working device today.

## Structure

```
firmware/
  microslate/     — submodule, github.com/Josh-writes/microslate-firmware
  crosspoint/     — submodule, github.com/juicecultus/crosspoint-reader-papers3 (pinned 1.3.2) — launcher
  crossink/       — submodule, github.com/uxjulia/CrossInk — future launcher, not yet ported
  paperboy/       — submodule, gitlab.com/zephray/paperboy
reference/
  crosspoint-reader/            — base CrossPoint at 1.4.1, for diffing CrossInk's divergence and tracking the sync gap
  crosspoint-reader-papers3/    — upstream's own PaperS3 touch port, latest (unpinned), porting reference
patches/
  microslate/     — patches to turn plain MicroSlate into the PaperS3 build
  crossink/       — CrossInk's PaperS3 touch port (not done yet — see PORTING.md)
docs/
  partition-table.md               — 16MB flash layout, boot-switch design
  crosspoint-papers3-sync-plan.md  — why CrossPoint over CrossInk for now, and the 1.3.2 → 1.4.1 upstream sync gap
scripts/
  setup.sh          — registers all submodules, pins MicroSlate/CrossPoint to the tested commits
  apply-patches.sh  — applies the MicroSlate patch
```

## Getting started

```bash
git clone <this repo>
cd <this repo>
./scripts/setup.sh
./scripts/apply-patches.sh
```

After that, `firmware/microslate` has US-International keyboard accents,
the PaperS3 touch input HAL (header/footer chrome, Home/Sleep substituting
for the missing physical power button, Bluetooth screen's Scan/Disconnect
zone remap) applied and ready to build for the `papers3` target.

`firmware/crosspoint` builds as-is for PaperS3 (it's already a working
port) — this is the near-term launcher.

`firmware/crossink` is untouched — its touch port is real work, not a
mechanical patch (see `patches/crossink/PORTING.md` for exactly why and
what's left). It stays in the repo for when we're ready to make it the
launcher instead of CrossPoint.

`firmware/paperboy` is untouched — it already runs standalone on PaperS3;
integrating it means adding the boot-switch-back-to-launcher affordance
(same pattern as MicroSlate's Home header zone), not yet done.

## Status

- [x] MicroSlate: US-International accent support
- [x] MicroSlate: PaperS3 touch input HAL (header/footer chrome)
- [x] MicroSlate: Bluetooth screen Scan/Disconnect zone remap
- [ ] MicroSlate: PaperS3 power HAL (battery %, deep sleep wake source)
- [ ] MicroSlate: Home header zone → boot-switch to the launcher (currently
      just returns to MicroSlate's own main menu)
- [x] Launcher: CrossPoint's PaperS3 port added, pinned at 1.3.2
- [ ] Launcher: sync CrossPoint-PaperS3 from 1.3.2 to 1.4.1 (362 commits —
      see `docs/crosspoint-papers3-sync-plan.md`, not started)
- [ ] Launcher: main-menu entries for MicroSlate / PaperBoy + boot-switch
- [ ] CrossInk: PaperS3 touch port (plan in `patches/crossink/PORTING.md`) —
      future replacement for the CrossPoint launcher
- [ ] PaperBoy: way back to the launcher (currently standalone-only)
- [ ] 3-partition `OtaBootSwitch` (currently 2-partition, X4/X3-only)
- [ ] Verify whether the X4/X3 `esp_ota_set_boot_partition()` bug exists on S3
