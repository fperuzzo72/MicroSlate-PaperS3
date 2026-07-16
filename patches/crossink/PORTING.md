# CrossInk → PaperS3 touch port — status

> **Update:** the near-term launcher is CrossPoint's own PaperS3 port
> (`firmware/crosspoint`), not CrossInk — see
> `docs/crosspoint-papers3-sync-plan.md`. Everything below is unchanged and
> still the plan for when CrossInk becomes the launcher; it isn't blocking
> anything right now.

**Not done yet.** This is a plan, not a patch, because CrossInk's input layer
has diverged too much from upstream CrossPoint to auto-apply the reference
port cleanly. Doing it blind risks landing something that looks applied but
doesn't compile or silently breaks a feature — worse than not doing it.

## What upstream CrossPoint's PaperS3 port actually touches

Diffing `reference/crosspoint-reader` (base) against
`reference/crosspoint-reader-papers3` (the official PaperS3 port), the touch
port isn't confined to one or two files — it's most of the hardware
abstraction layer:

- `lib/hal/HalGPIO.cpp` / `.h` — buttons, full rewrite (touch zones, same as
  what we did for MicroSlate)
- `lib/hal/HalTouch.cpp` / `.h` — new, GT911 driver (this one **is**
  self-contained and reusable as-is — same file we already copied into
  MicroSlate)
- `lib/hal/HalDisplay.cpp` / `.h` — PaperS3's row/column display controller
  is different hardware from the X4's, full rewrite
- `lib/hal/HalClock.cpp` / `.h`, `HalStorage.cpp` / `.h`, `HalSystem.cpp`,
  `HalPowerManager.cpp` / `.h` — PaperS3-specific (M5Unified/PMIC), rewritten
- `HalTiltSensor.*` — removed entirely (X4-only hardware, PaperS3 has none)
- `src/MappedInputManager.cpp` / `.h` — button-to-action mapping, rewritten
  around touch zones instead of physical buttons
- `platformio.ini` — new `[env:papers3]` board target (M5GFX/M5Unified deps,
  ESP32-S3 partition table, build flags)

A full reference diff of all of this is at
`patches/crossink/reference/crosspoint-base-to-papers3-hal-reference.diff`.
**It's a reference, not something to apply directly** — the paths in it
won't match this repo, and even if they did, it would blow away CrossInk's
own changes to some of those same files (see below).

## Where CrossInk actually diverges from base CrossPoint

Checked file-by-file (`reference/crosspoint-reader` vs `firmware/crossink`):

| File | Diff size | What CrossInk added |
|---|---|---|
| `lib/hal/HalGPIO.h` | 18 lines | X3 force-override build flag, `startDeepSleep()` split out |
| `lib/hal/HalGPIO.cpp` | 78 lines | Same, plus more robust power-button wake verification |
| `src/MappedInputManager.h` | 82 lines | Reader-mode button suppression, simulator support, power-as-confirm fallback |
| `src/MappedInputManager.cpp` | 451 lines | Same — this is a real feature set, not a tweak |

`HalGPIO.*` divergence is small and X4-power-specific — same situation as
MicroSlate's HalGPIO, it gets replaced wholesale by the touch version and the
X4-specific bits are simply lost (already flagged as a PaperS3-power TODO
for MicroSlate; same applies here).

`MappedInputManager.*` is the real work: 451 lines isn't a simple offset
patch, it's CrossInk's own button-mapping features layered on top of
CrossPoint's. Porting to touch means re-implementing *those* features
against the touch-based `HalGPIO`/`MappedInputManager`, not just copying
the PaperS3 version over CrossInk's.

## Plan for next session

1. Read CrossInk's actual `MappedInputManager.cpp` reader-mode/suppression/
   power-as-confirm logic in full (not just the diff) to understand what
   each piece is for.
2. Take PaperS3's touch-based `MappedInputManager` as the button-reading
   substrate (same `Button` enum, same `wasPressed`/`isPressed` interface).
3. Re-attach CrossInk's three features on top of it:
   - reader-mode front-button suppression
   - simulator injection (`#ifdef SIMULATOR` — useful to keep, CrossInk's
     SDL2 simulator is a real testing tool)
   - power-as-confirm fallback → needs a touch equivalent decision, similar
     to the Home/Sleep header-zone substitution we did for MicroSlate's
     missing power button
4. Same treatment for `HalDisplay`/`HalStorage`/`HalSystem`/`HalPowerManager`
   — check CrossInk divergence per file before blindly taking PaperS3's
   version, the same way we checked `HalGPIO` here.
5. Add the `[env:papers3]` block to CrossInk's `platformio.ini` (can likely
   be copied close to verbatim from the reference — build flags aren't
   something CrossInk has touched).

Once that's done, generate the patch the same way as the MicroSlate one:
build it as commits against a pinned CrossInk commit, verify `git apply
--check` on a fresh clone before shipping it.
