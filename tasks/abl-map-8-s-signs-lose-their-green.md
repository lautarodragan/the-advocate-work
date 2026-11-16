---
name: "ABL: map 8's signs lose their green"
description: "On Lashe City's map 8 the monitor signs drawn with BLchp1's tile 53 borrow an orange palette and their green screen comes out grey"
type: bug
status: draft
agents: [Carpintero]
---

Seen by taro, 2026-11-16; measured by Carpintero at the-advocate
`705d24f5` and the ports `299088c`, A Blurred Line's `release`.

Map 8, Lashe City 34,35: the events EV0006, EV0007, EV0018, EV0027 and
EV0031 are drawn with the upper-layer tile 53 of `BLchp1` (pose 7), a
monitor with a green screen. The map has 28 characters for 8 object
palettes, and the converter says it: "map 8: 6 graphic(s) without a
palette of their own, drawn with someone else's: ..., @tile:BLchp1:53,
...". The palette it is lent (6) is orange and brown; the screen's greens
`[5,27,18]` (12 px) and `[5,24,17]` (8 px) are drawn `[18,18,18]` and
`[7,13,14]`, 30 and 36 dE2000, and the light teal `[10,18,18]` a darker
one. Side by side: `/shared/captures/2026-11-16-palette-grouping/map008-sign-tile53-original-vs-lent.png`.

To reproduce: build `release`, read `map 8:` in `converter.log`, and the
`place` and `palettes` of `sprite` in wally's `map.json` for map 8.

On map 9 the same tiles (EV0024 tile 52, EV0026 tile 53) get palettes of
their own and are drawn exact; whatever looks off there is not the
palette. See the research "Is there a better palette grouping?" in the
book, under A Blurred Line.

**What would fix it, and why it is not on** (Cardón, 2026-11-16, see
[`abl-still-events-painted-into-the-background`](abl-still-events-painted-into-the-background.md)):
`posed_events = [8]` draws the five monitors and the two doors into the
background with the ChipSet's colours —seen on a test cartridge with only
map 8, `/shared/captures/2026-11-16-abl-posed-events/`—, but `release`
does not link with it: map 8 alone adds more data than the cartridge has
left (`just space release`). It needs room first.
