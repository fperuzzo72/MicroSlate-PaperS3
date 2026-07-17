# Hardware orientation: this device is mounted 180° from panel default

The panel's native/stock orientation puts the power button somewhere
inconvenient for how this specific PaperS3 is held day to day. Every
firmware we build for it boots and runs rotated 180° from the panel's
factory-default orientation, permanently — this isn't a runtime toggle, it's
how this unit is used.

## What "180° from default" means concretely

The panel's raw driver only has two hardware-level scan directions
(`ROTATION_0` and `ROTATION_CW` in `EPD_Painter`); the 4-way orientation
(Portrait / LandscapeCW / PortraitInverted / LandscapeCCW) is a software
coordinate transform on top of that, applied identically in both the display
renderer and the touch-zone mapping so they stay in sync — this is the same
pattern in both CrossPoint's `GfxRenderer`/`MappedInputManager` and our own
MicroSlate `HalGPIO`/`GfxRenderer`.

**Whatever a given firmware's stock default orientation is, use its 180°
counterpart instead:**

| Firmware | Panel stock default | Use this instead |
|---|---|---|
| CrossPoint-PaperS3 | `Portrait` (0) | `PortraitInverted` (2) |
| MicroSlate (once ported) | not yet set — pick whichever is 180° from whatever ends up being the panel-facing default | — |
| PaperBoy | unknown — not yet checked | — |

If a firmware only exposes 2 of the 4 orientations as "supported" (as
CrossPoint-PaperS3's `CrossPointSettings::isPaperS3OrientationSupported()`
does — originally `PORTRAIT`/`LANDSCAPE_CCW`), that restriction needs to
move with the swap: don't just change the default and leave the old
supported-set unchanged, or a settings-normalize pass will silently revert
it back on next boot. See the CrossPoint patch
(`patches/crosspoint/rotate-180.patch`) for exactly which functions that
touches — `isPaperS3OrientationSupported`, `normalizePaperS3Orientation`,
`nextPaperS3Orientation`, plus every hardcoded fallback default, not just
the struct's initial value.

## Caution flag — worth verifying on hardware, not just in code

Before this change, CrossPoint-PaperS3 explicitly *excluded* `INVERTED` from
`isPaperS3OrientationSupported()`, keeping only `PORTRAIT`/`LANDSCAPE_CCW`.
The coordinate-transform code for `INVERTED`/`PortraitInverted` looks
complete and symmetric in both the renderer and the touch mapping, and nothing
in the diff between it and the two "supported" orientations suggests a
missing case — but the restriction was deliberate, by the fork maintainer,
specifically for this hardware. It might have been caution/scope-limiting
rather than a known bug, but it's not been proven out address here — worth
paying extra attention to touch-zone accuracy (does the footer land at the
bottom, is Back on the correct side) the first time this boots, rather than
assuming it's fine because the code compiles.

## Checklist for the next firmware we port (MicroSlate, PaperBoy)

- [ ] Find every place the firmware hardcodes its "default"/"reset" screen
      orientation (search for the orientation enum's zero-value / whatever
      the panel considers "native")
- [ ] Swap each to its 180° counterpart
- [ ] If there's a "supported orientations" allow-list gating a settings
      menu or a persisted-settings normalize pass, update that too — not
      just the default value, or it'll get silently reset
- [ ] Sync the touch-zone coordinate transform to the same orientation (same
      thing we did for MicroSlate's `HalGPIO::setTouchOrientation()` /
      CrossPoint's `mappedInput.setTouchOrientation()`) — display and touch
      must rotate together or taps land on the wrong thing
- [ ] Test on hardware specifically for zones that were previously
      "unsupported"/untested in that orientation, not just trust that the
      code compiles
