# MicroSlate + CrossInk + PaperBoy on M5Stack PaperS3

Integrated firmware for the M5Stack PaperS3: CrossInk as the main-menu
launcher, with MicroSlate (notes) and PaperBoy (Game Boy emulator) as
selectable apps, boot-switched via OTA partitions rather than merged into
one binary. See `docs/partition-table.md` for why (PaperBoy's display driver
is incompatible with CrossInk/MicroSlate's shared one).

## Structure

```
firmware/
  microslate/     — submodule, github.com/Josh-writes/microslate-firmware
  crossink/       — submodule, github.com/uxjulia/CrossInk
  paperboy/       — submodule, gitlab.com/zephray/paperboy
reference/
  crosspoint-reader/            — base CrossPoint, for diffing CrossInk's divergence
  crosspoint-reader-papers3/    — upstream's own PaperS3 touch port, our porting reference
patches/
  microslate/     — patches to turn plain MicroSlate into the PaperS3 build
  crossink/       — CrossInk's PaperS3 touch port (not done yet — see PORTING.md)
docs/
  partition-table.md — 16MB flash layout, boot-switch design
scripts/
  setup.sh          — registers all submodules, pins MicroSlate to the tested commit
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

`firmware/crossink` is untouched — its touch port is real work, not a
mechanical patch (see `patches/crossink/PORTING.md` for exactly why and
what's left).

`firmware/paperboy` is untouched — it already runs standalone on PaperS3;
integrating it means adding the boot-switch-back-to-CrossInk affordance
(same pattern as MicroSlate's Home header zone), not yet done.

## Status

- [x] MicroSlate: US-International accent support
- [x] MicroSlate: PaperS3 touch input HAL (header/footer chrome)
- [x] MicroSlate: Bluetooth screen Scan/Disconnect zone remap
- [ ] MicroSlate: PaperS3 power HAL (battery %, deep sleep wake source)
- [ ] MicroSlate: Home header zone → boot-switch to CrossInk (currently just
      returns to MicroSlate's own main menu)
- [ ] CrossInk: PaperS3 touch port (plan in `patches/crossink/PORTING.md`)
- [ ] CrossInk: main-menu entries for MicroSlate / PaperBoy + boot-switch
- [ ] PaperBoy: way back to CrossInk (currently standalone-only)
- [ ] 3-partition `OtaBootSwitch` (currently 2-partition, X4/X3-only)
- [ ] Verify whether the X4/X3 `esp_ota_set_boot_partition()` bug exists on S3
