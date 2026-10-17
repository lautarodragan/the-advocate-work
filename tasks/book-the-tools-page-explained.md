---
name: "The tools page, explained"
description: "The book's tools.html says little: what each tool does, in which order they run, and examples of input and output —an RTP image through Adeleine, test-game cases that show the lossy optimizations from nothing lost to too much merged—, in phases"
type: docs
status: done
assignee: taro
agents: [Cardón]
---

taro, on 2026-10-15: "add more and better info to tools.html. I'd like it
to make it quite evident and friendly what each tool does, in which order
they run, and ideally examples of input and output (where it can be done
simply, we take a chipset or charset from the EasyRPG RTP and pass it
through Adeleine or whatever, and show how it changes. Since the choice of
colours etc. depends on other data, like the map, maybe we could add cases
to the test game that show these lossy optimizations, and show screenshots
of the game in those cases, compared with the original, in different
cases: when nothing is lost, when a 'reasonable' amount is lost, when it
merges too much and looks ugly... etc)". In phases, each with its commit:
adding prose is one thing, adding things to the demo game and capturing it
another.

At the start: `src/tools.md` in the-advocate-docs is 24 lines, a table of
the three layers and two paragraphs.

## The plan, in phases

Each phase its own commit, in the book's branch `cardon-tools-page` —and
in the-advocate's of the same name for what phase 3 adds to the test game—,
from docs `2361a94` and the-advocate `94f79d72`.

1. **Prose only.** `src/tools.md` rewritten: the road from the game to the
   ROM in the order the converter really runs the stages —read from
   `rm2k-snes/convert/src/convert.rs`, not from memory—, a table of what
   goes in and what comes out at each step, and one short section per
   tool: what it reads, what it writes, what it decides and what it
   refuses, with links to the internals and optimizations pages instead
   of repeating them.
2. **Standalone examples.** Real input and output pictures for the tools
   that run alone on an RTP picture —the EasyRPG RTP, CC BY 4.0 / CC0,
   the same the test game uses—: Adeleine on a ChipSet's colours, Voodoo
   cutting it into tiles and rendering it back, LZ2's sizes, Gunter on a
   sample, `rm2k-sketch` and `rm2k-render`. The pictures go in the book's
   `src/tools/`, small, each with the command that made it.
3. **Test-game cases for the lossy optimizations**, with goldens and
   side-by-side pictures —console against the original— graded from
   nothing lost to too much merged.

## Log

* 2026-10-15: task taken. Worktrees made; `--help` of every installed tool
  read; the converter's order checked in `convert.rs`: `scan` (with the
  boxes), `window`, `wally map` per map in parallel, `battle tables`,
  `compile`, then screens, images and `battle model`, `mapdata emit`,
  `patches`, and `rm2k-snes-audio cartridge` last. The book builds with
  `mdbook v0.5.4`; the link checker's baseline on docs `main` is 18
  problems, all known.
* Phase 1 committed in the book's `cardon-tools-page`: `src/tools.md`
  rewritten, with the road in order, the table of what goes in and comes
  out, one section per tool and the links. The checker stays at 18.
* Phase 2 starts: the pictures. The EasyRPG RTP's `Exterior` ChipSet has
  194 distinct colours at 15 bits and `People1` 125 (counted with a
  script, `colours.py`, over the RTP's files); a character gets fifteen
  on the console, and the layer above at most seven palettes, so both make
  the loss visible without a map.
* Phase 2 done: nine pictures in the book's `src/tools/`, all made by
  `figures/tools/make.py` at the root of the book's repository —outside
  `src/`, so mdBook does not copy it—, which takes the RTP, a SoundFont
  and the test game's `build/` as flags and runs only installed tools:
  `adeleine merge` on the elder (People1's character 6, 21 colours at 15
  bits into 15), `adeleine pack` and `reduce` on the whole Exterior
  ChipSet into 8, 4, 2 and 1 palettes, `voodoo convert` on the meadow's
  background (and refused on the reduced ChipSet, which needs more than
  1024 tiles), `voodoo render` back identical, `lz2` on the meadow's tiles
  and tilemap, `gunter` on FluidR3's piano, `rm2k-render layers`,
  `rm2k-snes-screens window` (the RTP System's 30 colours into 15) and
  `wally layers` on the meadow, which came out identical to the render at
  15 bits —checked pixel by pixel with a throwaway script—. The numbers
  quoted on the page are what the commands printed; the page says so and
  how to run them again. The script lives in the book and not in
  the-advocate because it only makes the book's pictures and knows no
  game; if a tool changes what it answers, the pictures are made again
  with it.
* Phase 3, the graded maps, in the-advocate's `cardon-tools-page` (merged
  with `main` at `299c51fd`): two maps in the test game, sketched. What
  was measured on the way, with `wally layers` and the converter's
  report:
  * only ★ tiles reach the 4-bit layer above the hero, and everything
    else goes in the 8-bit background, whose merges are the least
    visible: a first garden with every many-coloured piece behind the
    hero lost nothing (65 colours of a budget of 96), and a map drawing
    all 288 plain tiles behind the hero lost 76 of 172 colours and was
    hard to tell from the original. So the garden puts two roofs, a dome
    and a tent above the hero —★ on those entries of ChipSet 1, which
    the meadow does not use— and loses 16 colours of the layer above in
    3 palettes; the showcase draws 96 lower tiles and the 40 most
    coloured upper tiles, every one above the hero —a second ChipSet
    entry, all ★—, and loses 21 of 117 behind and 49 of 64 in front, in
    one palette. The first showcase with all 144 upper tiles above did
    not fit any VRAM layout (495 tiles in front against 256 at most).
  * **a map with no events wipes WRAM when entered**: the first garden
    and showcase had none, and the ROM went to `$FF` fifteen frames after
    `map_current` changed; with one still villager each they load. A
    draft: `a-map-with-no-events-wipes-wram-when-entered.md`.
  * the original under Wine, with the recipe for ABL: RPG_RT 2015 starts
    the test game but stops at "Invalid Terrain was specified": the
    database had no terrains, which RPG_RT needs and the console does
    not. With one terrain it runs, and the three maps were captured
    from it at 320x240 —the window is drawn at 2x, checked exact—.
* Phase 3 done. In the-advocate's `cardon-tools-page`: the two maps,
  their ChipSet entries, the terrain, the cases, the test and the README
  in one commit, and the two goldens in their own; `just test-game` is
  green —15 passed, 1 skipped, the skip from before— and `just test` too
  —29 passed—. No Rust was touched, so nothing has to be reinstalled when
  merging, and ABL's suite was not run: the runtime and the converter are
  as `main` has them. In the book's `cardon-tools-page`: the graded
  section with the three-way pictures, `figures/tools/grades.py` and the
  originals; the link checker stays at 18. The captures for taro are in
  `/shared/captures/2026-10-15-tools-page/`, with a README.

## What is left

* The draft above: a map with no events wipes WRAM when entered. Until
  it is fixed, a test-game map needs at least one event.
* The showcase is the worst the engine allows for this ChipSet, and it
  does not look as bad as "ugly": Adeleine's merges are least-visible
  first, and the only thing that shows is the 4-bit layer in front of
  the hero left with one palette. A map that looks truly broken would
  need a ChipSet with more colours per tile than the RTP's.
* The originals under RPG_RT are captured by hand; if a map changes, its
  `rm2k-<map>.png` in the book's `figures/tools/originals/` has to be
  captured again. The book says so.
* `rm2k-sketch` cannot choose an autotile's pattern from its neighbours,
  so the sketches use the plain middle pattern everywhere; a map with
  autotile edges would need the editor.

## To merge

* the-advocate: `cardon-tools-page`, two commits over `299c51fd`; nothing
  to reinstall.
* the-advocate-docs: `cardon-tools-page`, three commits plus a merge of
  `main`; check links with `mdbook build` and the checker (18 known).
* this repo: the task and the draft.
