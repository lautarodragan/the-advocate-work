---
name: "The converter's stages and what each spends"
description: "A book page in internals/: the order in which the converter's optimisations run, lossless and lossy, which budget each spends or frees, and which ones compete, so whoever adds one knows where it goes"
type: docs
status: testing
assignee: taro
author: taro
agents: [Carpintero, Hurón]
---

taro, on 2026-11-19, translated:

> Lossless optimisations are commutative, but lossy ones are not, right?

Hornero's answer: lossy ones are not (the RAM's 120-row trim ran before
the bake and lost the roofs Desert Nightmare's painting could have kept);
lossless ones give the same picture in any order but compete for the same
budgets (painting a map leaves it 256 sprite tiles, and maps 18, 33 and
71 then waited for slots). The order is implicit in how `convert` asks its
stages. taro, to writing it down: "dale".

**Done means**: a page in the book's `internals/` (and SUMMARY.md) with,
in the converter's real order —read from the code, not from memory—:
each stage that decides something (baked, posed, decorative, painted
events; the trim; Adeleine's colours; map pictures; the layer above;
VRAM layouts; the packing into banks and the `.msu`…), whether it is
lossless or lossy, which budgets it spends or frees (BG tiles and blocks,
sprite tiles and slots, CGRAM, VRAM, WRAM rows, ROM banks, vblank time),
which degradations it reports, and the pairs known to compete, with the
cases that showed it. A "where a new optimisation goes" paragraph. No code
change; if the order is found wrong somewhere, a draft.

## Log

### 2026-11-19, Carpintero: the work

**2026-11-19, Carpintero.** From the-advocate `4f38ea03` and the book's
`2a7d52a`, branch `carpintero-converter-stages` of the-advocate-docs. The
order read from `convert::run` (`convert.rs` in rm2k-snes-convert),
`Game::trim` and `trim.rs`, `maps.rs` (the request), Wally's `map.rs`
(`convert`, `convert_fitting`, `convert_with`), the emission's
`lib.rs`/`vram.rs`/`animation.rs`, and the cartridge's `banks.rs`
(`pack_with_msu`) and `msu.rs`. The catalogue of each optimisation already
exists in the book's `optimizations/`: the new page links to it and
says only the order, the budgets and the competing pairs.

**Done (Carpintero).** The book's `carpintero-converter-stages`
`87b63c2`: `internals/the-converters-stages.md`, in SUMMARY after the
pipeline, linked from `pipeline.md`, `vram.md` (the turns ladder and the
painted pieces' trim), `maps.md` (`map-left-out`), `wram.md` (`EV_MAX`),
the internals index and the optimizations' README. `mdbook build` clean;
the relative links and anchors of every touched page checked against the
built HTML. No code change; nothing to install when merging.

Two corrections to what the assignment remembered, from the code: the
Hover-Tram's 46 → 32 panorama colours came from the posed events drawn
past their cells moving the split (`only_the_split_moved`), not from a
bake; and `title-menu-not-drawn` exists only in a test of
`degradations.rs`, the converter writes `title-screen-not-drawn`.

Draft: [`the-trim-guesses-which-maps-go-painted`](the-trim-guesses-which-maps-go-painted.md)
—the trim reads the `painted_events` knob, not whether Wally can paint
the map; harmless with Desert Nightmare's measured list, wrong with
`painted_events = true`—.

### 2026-11-22, Hurón: no capture

A book page, with no code change: nothing on any screen. How to check it:
read "The converter's stages" in the book's internals
(`src/internals/the-converters-stages.md` in the-advocate-docs), which is
published, and see whether it answers your question about which lossy
step runs before which.
