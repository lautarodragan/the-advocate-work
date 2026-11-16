---
name: "A window line cannot wait forever"
description: "Put a ceiling on how many vblanks a message line may wait for room, uploading it under forced blank past it; and stress it with ABL's map 1, its self-scrolling panorama and a transparent box in the middle of the screen"
type: feature
status: testing
assignee: taro
agents: [Aguará]
---

Follows [`frozen-world-the-intro-stays-black-after-the-tint`](frozen-world-the-intro-stays-black-after-the-tint.md),
whose fix gives a line that missed a vblank the next one's room, and
whose "not covered" says a line could still find no room: what still goes
before it —the tint, the flash, the strips, the panorama, a painted map's
slots— has no ceiling, and a cost present on every frame would hang the
game as before. Hornero proposed a ceiling: past a few vblanks of waiting,
the line goes up under forced blank, so VRAM takes it wherever the beam
is, at the price of a few black lines on one frame.

taro, on 2026-11-16, asking whether ABL's map 1 —"Introduction", the first
map where Kersh, Manta and Core can move, with a panorama that scrolls on
its own— could hang with `EV0002`'s message options changed from
`Normal, Bottom` to `Transp`:

> Maybe use the message in the middle of the screen instead of the bottom
> edge, so we make sure letters appear over the moving panorama. It's a
> pretty cool stress test.

Done means: the ceiling, with a test that forces a line to wait past it;
and the stress case measured —ABL's map 1 with `EV0002` transparent and
in the middle, on the accurate core—: on which vblank line each of its
lines goes up, how close to the limit, and whether any waits. The game is
not edited: the case goes through a copy (`GAME_DIR`) or a test case.

## Log

**Aguará, 2026-11-16.** From the-advocate `705d24f5` and the ports
`299088c`, branches `aguara-wait-ceiling`; scratch in
`~/scratch/aguara/wait-ceiling/`.

**What else waits the same way.** Besides `upload_line`, the layer above
under a bare window: its steps 1, 3 and 5 run in the vblank only up to
`LAYER_ROWS_LATEST` (250) and hold the composer —`msg_layer_wait`— until
they are done, so a vblank whose work before the window always ends past
250 holds the box forever just the same. The rest of the window's vblank
writes that wait —the typed cells, the arrow's cells and colours, the
HDMA tables— do not hold the box: the line's 1920 bytes cover the typed
cells, and the others are a frame late on screen. So the ceiling covers
the two that hold: a line (`msg_waited`, now a count) and a layer step
that went nowhere (`LAYER_LATE`, counted in `msg_layer_steps`).

**The mechanism.** Past `WAIT_CEILING` vblanks, `flush_video` sets
INIDISP's bit 7 before the window's work and `vb_forced`, which makes
`vblank_line` (and the layer's per-tile clock) answer "fits"; brightness
goes back right after `msg_arrow` (`ceiling_off`), or at the end of
`flush_video` when the box is not open yet. `upload_line` and the typed
cells now ask `vblank_line` instead of reading the counters inline. The
HDMA tables are not built past the vblank even in forced blank: they are
RAM the HDMA reads while it draws, which the blank does not protect.

**N = 2**: the first miss is a full vblank; the second comes after the
second chance cleared what can wait (poses, ChipSet step), so what is
left is a cost of every frame and a third try would not differ; and while
a line waits past its first miss the characters stand still, which is
worse than a few black lines once.

**The stress case, how it is built.** The converter reads ABL's `data/`,
not the game's `.lmu`, so a `GAME_DIR` copy alone changes nothing: the
copy is a scratch ports worktree (`~/scratch/aguara/wait-ceiling/stress-ports`)
whose `data/maps/Map0001.json` has `EV0002`'s only `MessageOptions` (page 0)
changed from `[0, 2, 1, 0]` (Normal, Bottom, dodging the hero) to
`[1, 1, 1, 0]` (transparent, middle; the dodge kept), and a `.lmu` copy
with the same change through `ditto pack` for `GAME_DIR` (the assets).
Measured on a probe cartridge of its own, `test-stress` (start map 4,
maps [1], `--vblank-probe`), from the boot, A whenever a box is up, until
switch 3 and control. **Map 1 has no layer above for the text**
(`layer_text_on` is not in that ROM): the layer's handling is not in play
there, only the line's limits.

**The stress case, measured** (the-advocate `d1ad3fa4`, the same with the
ceiling jumped over: it never fired). 15 boxes, 111 calls of
`upload_line` —the lines and the box's blanked ones—, the same on snes9x,
bsnes and bsnes with the accurate PPU (the audit core):

| line `upload_line` read | calls (snes9x) | (accurate bsnes) | went up |
|---|---|---|---|
| 235 | 99 | 99 | that vblank |
| 236 | 1 | 1 | that vblank |
| 237 | 2 | 2 | that vblank |
| 239 | 8 | 4 | the next, on 235 |
| 240 | 1 | 5 | the next, on 235 |

The window is bare (`MSG_PLACE` 5), so the first try's limit is
`LINE_LATEST_BARE`, 238: margin 3 at best, and 9 lines missed it by one
or two (boxes 0-5, the second line mostly), each up on the next vblank
with the second chance's room, on line 235 —11 before the framed 246—.
**No line waited two vblanks**; the ceiling never fired. `flush_video`
ended at worst on line 258, the window's writes on 252, never past the
vblank; **display accesses 0** on the audit core over the whole opening.

**What it looks like** (captures in the shared folder,
`captures/2026-11-16-wait-ceiling/`): the boxes in the middle, letters and
shadow right. On the text's lines the panorama's night sky goes black
—the known divergence: in mode 3 the panorama is BG2, which the window
takes on its lines— and the characters go over the letters —known too—.
**Not known**: a red-and-white striped column at both screen edges on the
text's lines, where the panorama or black is with the window closed. A
draft:
[`a-transparent-window-over-a-flattened-panorama-shows-striped-edges`](a-transparent-window-over-a-flattened-panorama-shows-striped-edges.md).
Map 1 carries no layer above for the text, so the layer's handling is not
in play there.

**Not kept as a suite test**: the change is to the game's data, so a
case would have to copy EV0002's whole page into `tests/cases/` and go
into `release` (`cases = "all"`), moving the text block and every golden
behind it; and it waited at most one vblank, so as a regression test it
would only say what the budget tests already ask. The ceiling's own test
is the one that fails if a box can hang.

**The ceiling, its test** —`tests/rpgmaker/test_window_wait_ceiling.py`
in the ports—: `test-vblank`'s probe gets `VBLANK_STALL`, a line up to
which `flush_video` waits before the window's work; the test sets it to
251 (`LAYER_ROWS_LATEST` + 1, the first line where both a box's line and
the layer's steps find no room) and plays CORE and MANTA's memory to map
6, A whenever a box is up. A probe and not a scene: no scene of ABL fills
the vblank that much, and the probe makes it every frame. Red with the
ceiling jumped over (both tests: the memory's first box never opens,
`msg_waited` 255); green with it, 237 vblanks in forced blank, the memory
on map 6 at tick 3017 instead of 2731, `msg_waited` and `LAYER_LATE` never
past 2, and 0 display accesses on the audit core.

**What it costs on screen**, on the accurate core (captures): the blank
ended on line 263 to 286 —the screen's lines 1 to 24—: 3 black lines for
a line's 1920 bytes alone, 11 to 17 —up to some 23— when the layer above's
tiles go up in the same vblank. On one frame each. **What frames that do
not wait pay**: in `flush_video`, `msg_upload`'s load and branch (and with
a box open on a map with the layer, `msg_open` and `LAYER_LATE`'s), two
`jsr ceiling_off` that load `vb_forced` and return; in `vblank_line`, a
load and a branch; `upload_line` and the typed cells a `jsl` more.

**Verified** (the-advocate `d1ad3fa4`, the ports `47b0d18`, tools of the
branch installed locally: `project`, `cartridge`, `convert`,
`rm2k-snes-audio`):

* ABL's `just tests`: 1660 passed, 2 skipped —the index test red until the
  new test went into `tests/README.md`, in the same commit—, no golden
  moved; it includes `test_display_accesses.py` and
  `test_vblank_budget.py` with the audit core, and the two new tests.
  `release`'s `abl.sfc`: sha256 `0bb515b5…`;
* the ports' `just boot`, 153 passed; `just test` in the-advocate, 29
  passed;
* taro's stress case on snes9x, bsnes and the audit core, above.

**What the suite does not cover**: the console and the FX Pak —a forced
blank turned off in the middle of the frame is measured on bsnes's
accurate PPU only—; a vblank full **after** the window's writes (the
probe fills it before them); a real scene that reaches the ceiling, none
known; the black lines' look, measured here and not asserted.

**For taro to play**: a build of the stress case, from `d1ad3fa4` and the
ports `299088c` plus the uncommitted data change, in the shared folder's
`builds/abl-stress-transparent-middle/`, with its README.

**To merge**: the-advocate `aguara-wait-ceiling` (`d1ad3fa4`, runtime
only) and the ports `aguara-wait-ceiling` (`47b0d18`, the test and the
index), both on today's main, which did not move. Nothing to install: the
runtime is the checkout's.
