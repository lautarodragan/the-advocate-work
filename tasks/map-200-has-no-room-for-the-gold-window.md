---
name: "The inn of ABL's map 200 shows no gold window"
description: "The gold window goes in objects past the sprite bank and in a free sprite palette, and map 200 has its eight palettes taken"
type: bug
status: draft
agents: [Hurón]
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
