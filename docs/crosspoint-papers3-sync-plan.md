# CrossPoint-PaperS3: near-term launcher, and syncing it to 1.4.1

## Why CrossPoint instead of CrossInk, for now

CrossInk's touch port needs a real merge of its `MappedInputManager`
features (reader-mode button suppression, simulator support, power-as-
confirm fallback — see `patches/crossink/PORTING.md`), not a mechanical
patch. That's still the plan for later — nothing about it is cancelled or
deleted.

In the meantime, `juicecultus/crosspoint-reader-papers3` is an
already-working, actively-maintained PaperS3 touch port of *base* CrossPoint
(the project CrossInk itself forked from). Using it as the launcher gets a
real, working main menu on the device now, and doesn't block the CrossInk
work — CrossInk can still be ported and swapped in as the launcher later,
using this same fork as the touch-input reference it already is.

## How the port is actually built (important — different from our MicroSlate approach)

Unlike what we did for MicroSlate (fork the HAL files wholesale, replace
button-reading entirely), this fork keeps a **single shared codebase** for
X4/X3 and PaperS3, using `#if CROSSPOINT_PAPERS3` / `#else` conditional
blocks scattered through the normally-shared files
(`src/components/themes/*`, `lib/JpegToBmpConverter/*`, etc.), alongside
full-replacement HAL files for the parts that have nothing in common
(`lib/hal/HalDisplay.*`, `HalGPIO.*`, `HalPowerManager.*`, `HalStorage.*`,
`HalSystem.*`) and a rewritten `src/MappedInputManager.*` mapping touch
zones to the same virtual-button interface the rest of the app already
uses. Full detail — hardware pin maps, touch zone layout, phase-by-phase
implementation notes — lives in `PORTING_PLAN.md` at the root of
`firmware/crosspoint` (and `reference/crosspoint-reader-papers3`); it's the
fork maintainer's own document, worth reading before touching that
codebase.

## Current version gap

| | Version | Commit |
|---|---|---|
| `firmware/crosspoint` (pinned) | 1.3.2 | `d9792a5` |
| `reference/crosspoint-reader` (upstream) | 1.4.1 | tag `1.4.1` |

**362 commits** separate them. That's roughly four months of upstream
CrossPoint development — real reader features, not busywork: EPUB
bookmarks, RTL text support, KOReader sync improvements, themed reader
menus, a live font-preview pane, several new hyphenation/localization
packs, seamless sleep/wake screens, and more.

## How the fork maintainer syncs upstream (and why we should follow the same discipline)

The fork's own `PORTING_PLAN.md` documents a cherry-pick-based sync process
(`git cherry-pick -x <hash>` per upstream commit, not a bulk merge), with
one hard rule worth internalizing before attempting this: **never resolve a
conflict with `git checkout --theirs`**. Blanket-accepting upstream's side
of a conflicted file silently deletes whatever `#if CROSSPOINT_PAPERS3`
block was in that file — the build usually still succeeds, and the
regression only surfaces later (sometimes as a runtime bug, sometimes as a
linker error several commits down the line, once documented in their own
1.3.0 sync). Their plan documents a real regression list from exactly this
mistake, plus a shell snippet that audits `CROSSPOINT_PAPERS3` occurrence
counts before/after a sync batch to catch dropped blocks before they ship.

We should use the same discipline if we take on this sync ourselves, rather
than reinvent a weaker process.

## Plan

This is not a one-session job — 362 commits, each needing a real look before
resolving conflicts, is a multi-week effort for the fork's own maintainer.
Realistic options, not mutually exclusive:

1. **Ship on 1.3.2 now.** It's a complete, working reader — missing four
   months of upstream features, not missing core functionality. Nothing
   about the MicroSlate/PaperBoy integration depends on being current.
2. **Sync incrementally, in dated batches**, each as its own reviewed commit
   range against `reference/crosspoint-reader`, following the cherry-pick
   discipline above. Natural batch boundaries: by upstream release tag
   (1.3.2 → 1.4.0 first, then 1.4.0 → 1.4.1) rather than one 362-commit push.
3. **Wait and let upstream's own sync branches catch up** —
   `crosspoint-reader-papers3` already has in-progress sync branches
   (`sync-upstream-1.3.0`, `sync/upstream-1.3.0`) from the maintainer; worth
   checking their status before duplicating the work ourselves.

Not decided yet — flagging the tradeoff rather than picking one.
