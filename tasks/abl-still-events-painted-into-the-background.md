---
name: "ABL: still events painted into the background"
description: "Try `posed_events` in A Blurred Line, as Zounds has it: signs and doors that are events with a ChipSet tile would be drawn with the map's palettes instead of a lent sprite palette; measure which go in, what it costs, and what changes on screen"
type: feature
status: doing
assignee: Cardón
agents: [Cardón]
---

taro, on 2026-11-16, looking at Lashe City (map 8) on Mesen: the sign at
(31,19), part of the map, and the one at (26,21), an event with the same
`BLChip1` tile, are drawn completely differently. With the background off
the event's sign is still there: it is an object, and map 8 lends it a
sprite palette that loses its green
([`abl-map-8-s-signs-lose-their-green`](abl-map-8-s-signs-lose-their-green.md),
from [`abl-is-there-a-better-palette-grouping`](abl-is-there-a-better-palette-grouping.md)).
The event's page asks for switch 24, `LateForWork1`; turned off with the
debug screen, the map loses the door of Talan's Pad too (half of it stays
a black hole). Screenshots in the shared folder,
`captures/2026-11-06-taro-screenshots-palettes-layers/` (the date in the
name is taro's).

> That means we could "fix" ABL in that case, in a couple of different
> ways: remove that condition from the events; draw all the signs on the
> map, and use the event _without a graphic_, only for the ShowMessage.

Hornero pointed at what already does the second one without editing the
game: `[graphics] posed_events`, on only in Zounds (the book's "Still
events drawn into the background"). The event stays whole —pages,
conditions, triggers—; only its drawing moves to BG1, and a page change
rewrites the cell.

Done means: `posed_events` tried in ABL, measured: which events and maps
go in (the converter's log says, map by map, which did and why the rest
did not), map 8's sign and Talan's Pad door among them or why not; tiles,
merged colours, sprite palettes freed, lag; every golden that moves looked
at side by side; and on if it comes out right, with its why in
`advocate.toml`.

## Log

Cardón, from the-advocate 63555c31 (the global tools, installed from it)
and the-advocate-ports 5b6956e, branch `cardon-abl-posed`.

* Talan's Pad door on map 8 is `TalDoorBottom`, event 1 at (11,55),
  upper tile 117 on the hero's layer, its only page on switch 24; taro's
  `door-1.png` is map 8 by the save point (event 67 at (9,56)) beside it.
  The sign at (26,21) is `EV0031`, upper tile 53, same layer, same switch.
  None of BLChip1's tiles 53, 111, 112, 117 is a star tile, so neither is
  kept out for going above the hero.
* Map 8 has a panorama, `Planet1`, that the converter hides ("its
  panorama goes hidden"); `posed_events` skips a map whose drawn layers
  keep a panorama, so whether map 8 goes in depends on that.
* Before turning it on, `release` takes 126 data banks of 126, with 302 B
  of gaps (`just space release`).
