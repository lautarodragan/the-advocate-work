---
name: "The inn of ABL's map 200 shows no gold window"
description: "The gold window goes in objects past the sprite bank and in a free sprite palette, and map 200 has its eight palettes taken"
type: bug
status: doing
assignee: huron
author: huron
agents: [Hurón, cardon]
links:
  found-in: [an-inn-has-no-gold-window]
---

Seen by Hurón on 2026-10-19, building the inn's gold window
—[`an-inn-has-no-gold-window`](an-inn-has-no-gold-window.md)—, with
the-advocate's branch `huron-inn-gold` (`d76bb565`, merged with
`tijereta-inns` at `dec72ff8`) and the ports' `huron-inn-gold`.

The gold window is 44 8x8 objects after the message arrow's two tiles
past the sprite bank, in the sprite palette nobody takes —`arrow_obj` in
rm2k-snes-mapdata—. Of ABL's six maps with a paid inn (20, 72, 78, 112,
200, 348), map 200 has its eight sprite palettes taken by the characters,
so its inns (events 16 and 17) greet without the gold window; "Yes" is
still greyed without the price. The build lists it as
`inn-no-gold-window` in `degradations.json`; the converter's log already
says the same map keeps its message arrow in the window's cells.

How to see it: talk to either inn of map 200 in the release ROM.

What it would take: a palette for the window on the maps that ask for
it —the layout choice in `vram.rs` reserving one when a map's pages open
a gold window, or the window borrowing a character palette on the lines
it covers—. Either changes how the map's characters are packed.

## Comments

### 2026-11-24, Cardón: a question for taro

Still so at the-advocate `8b069fc2`: the build still reports
`inn-no-gold-window` (`rm2k-snes/mapdata/src/main.rs:262`), and ABL's page
in the book lists it in "Known issues".

**What to decide**: what map 200 gives up for its inn's gold window, since
its eight sprite palettes are its characters'. Either way changes how the
map's characters are packed: what is lost for lack of room.

**Options**: (a) the layout in `vram.rs` reserves a palette on maps whose
pages open a gold window, and two characters on map 200 share one (some
colours lost); (b) the window borrows a character palette on the lines it
covers (HDMA; no colour lost, more runtime); (c) leave it: "Yes" is greyed
without the price on one map.

**Recommendation**: (a): the general rule is small and the colours a
shared palette loses are measurable in the build; if map 200's loss shows,
(c).

### 2026-11-28, taro: an answer: (a)

> (a)

### 2026-11-28, Hornero: (a), to todo

To `todo` with (a): the VRAM layout reserves a palette on maps whose
pages open a gold window, and two of map 200's characters share one,
the colours they lose measured in the build. If the loss shows on
screen, (c) is still open.

## Log
