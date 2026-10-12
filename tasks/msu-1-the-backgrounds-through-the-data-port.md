---
name: "MSU-1: the backgrounds through the data port"
description: "Pilot: the battle backgrounds also in the .msu, and with MSU-1 the ROM reads them from there; without it, from itself"
type: feature
status: done
---

taro's idea, on 2026-09-25: use MSU-1's **data port** to store things outside
the ROM, starting with the battle backgrounds. It's a pilot: **test the
mechanism, not save space yet**. The non-negotiable condition is that without
MSU-1 the game work the same, because taro plays in Mednafen.

## What worked

The converter writes into each cartridge's `.msu` the same backgrounds the ROM
carries, with a signature of the contents in front —format and mechanism in
`internals/the-msu-file.md`, reference in `tools/port/msu_datos.py`—. When a
battle with a background starts, the ROM checks whether there's MSU-1 and
whether the `.msu` has its signature; if so, it brings the 32 KB by DMA from
`$2001` into the two WRAM buffers and the colors into CGRAM, and leaves
`ESC_MSU` at 1. If not —without MSU-1, with another `.msu`, an empty one, or
if MSU-1 doesn't finish seeking—, everything comes from the ROM as before.

## What it's verified on

* **Without MSU-1**: the whole suite. In the pilot, with no golden changed;
  with the lightweight fallback, with the ten battle ones changed.
* **With MSU-1, in snes9x and in bsnes**: `pruebas/abl/test_msu_datos.py`. The
  Sector 27 battle, each path against its golden and the clean WRAM
  background against the converter's bytes; a control with the `.msu`'s tiles
  changed looks different —which is what proves the image came from the
  `.msu`—, and a `.msu` from another build or an empty one falls back to the
  ROM.
* **mesen-s**: the same three cases, by hand, with the same result —in the
  pilot; with the lightweight fallback it wasn't looked at again—. It isn't
  in the suite because of the state carry-over between consoles of the same
  process that `test_cores.py` documents.
* **Not verified: the FX Pak Pro.** That's what's left for taro to test: with
  `abl.sfc`, `abl.msu` and the tracks in the same folder, enter a battle with
  a background —the droid one, or a random encounter in Sector 27 or 30— and
  see that the background is the usual one. With the lightweight fallback
  it's easier: with MSU-1 the quality one has to show, and in Mednafen the
  16-color one. If the background comes out fine but the entry takes longer
  than in an emulator, it's the seek on the SD card.
* **The wait on the data-busy bit: in Mednafen, by hand.** It's the only
  emulator that sets it —400,000 master cycles per seek, see
  `docs/snes/emulators.md`—, and on 2026-09-26 the droid battle read the
  background from the `.msu` there, playing from the title. What nobody runs
  is the cutoff by limit.
* **Not covered by the signature**: a `.msu` with the header intact and the
  data damaged. The ROM doesn't hash the backgrounds at the start of each
  battle.

## How long it takes

In snes9x, bsnes and mesen-s seeking is instant, and the DMA goes at 8 master
cycles per byte wherever it comes from. In Mednafen each of the four seeks per
battle —the signature, the tiles twice (one per buffer) and the colors— costs
one or two frames: about seven in total, measured. On the FX Pak they aren't
measured. See "Cuánto tarda" in `internals/the-msu-file.md`.

## How it travels to taro

`just entregar` copies the `abl.msu` into the build, next to the `abl.sfc`,
and **always** to `/shared/msu/`, because it belongs to the build and not to
the tracks. With another build's `abl.sfc` nothing breaks: the ROM doesn't
find its signature and reads the backgrounds from itself.

## The lightweight fallback (on its branch, not merged)

taro's request the same day: *"I want to be able to confirm it's actually
loading via MSU, by being able to compare and see it loads a different
background in Mednafen"*. With both backgrounds the same there was no way.

* **What it is**: the ROM carries each background in **4bpp and 16 colors**;
  the `.msu` keeps the 8bpp, 96-color one, byte for byte the earlier one —the
  signature didn't change—. The layer is still 8bpp: `esc_llenar` widens the
  fallback when copying it to WRAM, two DMAs per tile (the tile through
  channel 0, the fixed planes 4 to 7 through channel 7). The why of this shape
  and not another, in "El respaldo liviano" of `tools/port/escena.py`.
* **How much it saves**: the converter prints it in `conversor.log` ("fondo de
  batalla …: en la ROM … B, en el .msu … B"). It's a property of the format:
  16,384 B of tiles and 160 of colors per background, minus 32 B of pattern
  for all of them.
* **How long it takes**: the fallback one frame more than the `.msu` in the
  droid battle (`ESC_CUADROS`, in snes9x and in bsnes): copying one tile at a
  time re-sets the registers 512 times per buffer.
* **It changes what the suite sees**: the ten battle goldens, only in the
  scene. Old and new side by side in
  `/shared/goldens/2026-09-25-fondo-liviano/`. **taro decides** whether it
  stays.
* **Build to look at**: `/shared/builds/2026-09-25-demo-fondo-liviano/`, with
  its `LEEME.txt` and two screenshots of the same battle through both paths.
* **What looks odd**: in Sector 27 the green sign shows **in the lightweight
  one and not in the quality one**. It isn't the fallback's fault:
  `titulo.reducir`, which builds the 96, keeps the most used colors and the
  sign's green isn't among them; `merge_least_visible`, which builds the 16,
  keeps it. Changing the 96's reducer changes the `.msu` and its signature,
  and is left for later.
* **No test runs it**: an MSU-1 seek not arriving in time halfway through.
  With different backgrounds that would leave colors from one and tiles from
  the other, so `escena_subir` redoes the whole background from the ROM; no
  emulator seeks with a delay.

## The next step

* **The other backgrounds.** The game names about fifteen; in the `.msu` they
  cost no cartridge, so the fallback for those not in `FONDOS` can stay the
  plain background.
* **Measure on the FX Pak** how long seeking takes, before moving something
  that is read every frame and not once per battle.
* If other things are added to the `.msu`, the signature still covers the
  whole file: any change in any entry invalidates the whole `.msu`, which is
  the simple and correct thing while the `.msu` travels with the build.

**What taro said looking at the goldens side by side, on 2026-09-25**: "on the
phone it shows, but it isn't that bad. I suspect on the CRT it'll barely be
noticeable." It remains for him to see it on the console.

## "In Mednafen and in ares I don't see any difference" (2026-09-26)

taro played the droid battle in Mednafen (`snes_faust`) and in ares, with and
without the `.msu`, and saw the same thing. The suspicion was the wait: that
Mednafen takes time to seek and the suite's cores don't. **It didn't
reproduce**:

* Mednafen does take time —`MSU1_WriteDataSeek` sets bit 7 for 400,000 master
  cycles—, and the ROM's wait is long enough: its limit is about ten times
  that.
* With the build taro played (`d7056b6`) and with `main`, playing from the
  title up to the droid in the Mednafen here (1.32.1, the same Arch package),
  the battle comes out with `ESC_MSU` at 1 and the `.msu`'s background: read
  from the state saved with F5 and compared against the screenshots of both
  paths. Without the `.msu`, `ESC_MSU` at 0 and the lightweight one.
* ares seeks instantly (`dataBusy` never gets set), so it runs the same path
  as bsnes, which the suite tests.

The most likely thing is that **the difference doesn't show at game size**: on
the violet wall, the quality one is a gradient with the face and the
lightweight one the same face posterized into two or three violets. Side by
side and enlarged it shows; while playing, not so much. The screenshots, in
`/shared/capturas/2026-09-26-msu-mednafen/`.

**What taro has to look at**, if he wants to confirm it without looking at the
background: in Mednafen, Alt+D opens the debugger and Alt+3 its memory editor;
with the battle open, byte `$664A` of the `wram` space —`$7E664A`— is
`ESC_MSU`: 1 if the background came from the `.msu`, 0 if it came from the
ROM.

**Confirmed by taro on 2026-09-26, in Mednafen with `snes_faust`**: the `.msu`'s background loads and the difference from the ROM's exists, but he had to take screenshots to see it: while playing it isn't obvious, and on the CRT it will be even less so. The FX Pak Pro remains untested (the risk of the 32 KB read in a single DMA).
