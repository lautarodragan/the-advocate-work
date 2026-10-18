---
name: "The runtime's optimizations the book does not tell"
description: "Audit runtime/ for optimizations missing from the book's Optimizations section, and write them in"
type: docs
status: testing
assignee: taro
agents: [Hurón]
---

taro, on 2026-10-18: are there optimizations we make that the book does
not tell, above all the runtime's? Found the same day: the twins (copies of
an event sharing a row) were only in a divergence, not in "Lossless:
events" (added in the book's `7633a4d`).

## Log

2026-10-18, Hurón. From the-advocate `df9a0f9c` and the book `7633a4d`, on
the book's branch `huron-optimizations`. Read the whole Optimizations
section, then `runtime/*.s` by its comments ("cost", "cycles", "cache",
"only when", "instead of", "every frame"…), the long commit messages of
the race at 60 frames (`da466bbe`), the flashes (`1ac04770`), LZ2
(`b1223af1`) and the still events (`1a2df48e`), and `internals/`,
`divergences/` and `decisions/` for what is told only there.

Found on the way: the index `lossless.md` did not list two entries that
`lossless/events.md` already had (the twins and "a refresh only when
something changes"). Both are in the index now.

### What went into the book

The book's `12cb7cc`, on `huron-optimizations`: twenty-nine entries,
twenty-five lossless and four lossy, each with its line in `lossless.md`
or `lossy.md`. Nothing was added to `SUMMARY.md`: no new page.

* The map: the tilemap is a window the camera fills at its edges; the
  ChipSet animation is one DMA, on the tick it changes.
* Characters and sprites: a battle animation's frame without its empty
  tiles, one at a time; still events that animate are walked only when a
  column changes; the timer and the raindrops fill the last row's free
  columns (told only in `internals/vram.md`); a small picture's sparse
  blocks in 8x8 and its repeated tiles once (same).
* Events: the refresh leaves its answers —the parallels' list with their
  page, each event's active page, no autorun sweep without autoruns—;
  `OP_CELL_TEST`; the parallels that stop at their cell test run without
  their interpreter; the short way for what parallel pages run every
  frame. And a sentence in "a refresh only when something changes": the
  `VAR_REFRESH` bit the compiler answers.
* Text and windows: a face borrows the window's text cells and palette 1
  (told only in a divergence and `internals/`); the screens' text takes
  tiles only where it has ink, shared by rows that say the same; it is
  typeset while the frame waits for the vblank; the window's arrow and the
  shop's windows go up only when they change.
* Audio: a package's effects lie in the `.msu` in upload order (told only
  in `internals/the-msu-file.md`).
* CPU time: the FastROM mirror; LZ2 with block moves; one vblank budget,
  counted in poses; the tint as a table per channel; the screen flash
  walks its table; a moving event's row and slot remembered; the events'
  passability only when some row imposes it; the NPC table copied to RAM;
  a picture's palette only when its tone changed; the timer counts
  seconds.
* Lossy: the screen flash every other frame; the ChipSet animation's
  clocks from the game tick; the choice bar's one drawing; still events
  that animate share one phase (the last three told only in divergences).

taro's assumption that the tools' optimizations are all told almost
holds: what was missing from the tools' side is `OP_CELL_TEST`'s fusion,
`VAR_REFRESH`, the battle animation frames without their empty tiles, and
three told only in `internals/` (the timer's strip, the small pictures,
the effects in the `.msu`).

### Left out, as questions for taro

* **`[events] counters`** → `OP_COUNTER`: a common event a project
  declares as a counter becomes one opcode drawing the timer's glyphs. Is
  it an optimization or the way around pictures?
* **Pictures drawn into the map** (`[graphics] map_pictures`): is it
  something the section should carry, or a fit for a missing layer?
* **An enemy that dies redraws only its cells**, one per frame and over
  several vblanks (`scene_tick` in `runtime/battle_scene.s`), without
  RM2k's fade: is the fade missing for the cost, or just not done?
* **A save slot per SRAM bank** so its offset needs no multiply, at 32 KB
  of SRAM (`runtime/save_game.s`); and the micro ones —the bit-mask table
  of the switches, the panned camera kept in whole pixels, `PAIR_BYTES`
  at eight so the index is three shifts, attribute sets sharing a row in
  `attr_sets`—: does the section want that level?
* **`routes_moved`** is written and never read, since it was born: a
  draft, [`routes-moved-is-written-and-never-read`](routes-moved-is-written-and-never-read.md).

Nothing to install: only the book changed.

### taro's answers, written in

Same day, the book's `d16012a` on `huron-optimizations-2`, from its main
`041f3e9`: four more entries.

* Pictures drawn into the map: an optimization, in `lossless/the-map.md`,
  with a line on when it stops being lossless.
* A dead enemy redraws only its cells: in `lossless/battle.md`. The
  missing fade is a divergence the book does not tell, not an
  optimization, and no reason of cost is written for it: a draft,
  [`a-dead-enemy-does-not-fade-out`](a-dead-enemy-does-not-fade-out.md).
* `OP_COUNTER`: in `lossy/events.md`.
* A save slot per SRAM bank: in `lossless/the-cartridge.md`. Left out, as
  taro said, the obvious small ones; and `attr_sets`, whose shared rows
  save a few bytes of ROM per repeated set and nothing measured.
