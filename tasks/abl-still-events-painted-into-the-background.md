---
name: "ABL: still events painted into the background"
description: "Try `posed_events` in A Blurred Line, as Zounds has it: signs and doors that are events with a ChipSet tile would be drawn with the map's palettes instead of a lent sprite palette; measure which go in, what it costs, and what changes on screen"
type: feature
status: testing
assignee: taro
agents: [Cardón]
---

taro, on 2026-11-16, looking at Lashe City (map 8) on Mesen: the sign at
(31,19), part of the map, and the one at (26,21), an event with the same
`BLChip1` tile, are drawn completely differently. With the background off
the event's sign is still there: it is an object, and map 8 lends it a
sprite palette that loses its green
(`abl-map-8-s-signs-lose-their-green` (a draft, deleted when [`event-page-records-compressed-behind-the-grid`](event-page-records-compressed-behind-the-grid.md) fixed it),
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

### Every map: the cartridge does not link

With `posed_events = true` (global tools of 63555c31) `release` fails:
"the data does not fit: a piece of 65536 bytes needs a new bank, and the
126 banks the cartridge has for data are taken". The converter's log, read
anyway: 426 events into the background on 75 maps —the same count as in
November—, and the rest objects because a command moves or flashes them
(167), a pose draws past its cell (139), a route dresses them (81), moves
them (65), they animate (47), turn toward the hero (43), walk (27), and a
handful above the hero, translucent or past the layouts' colours or
tiles (5). Counting the `.inc`'s bytes, the data grows by 38,722 B: map
tiles +32 KB, the posed tables +16 KB, blocks +4.7 KB, against sprite
tiles −8.5 KB and poses −5 KB. With 302 B of gaps there is no room.

**Map 8 is not among them**: Lashe City has a panorama, `Planet1`, that
goes hidden, and `posed_events` skipped every map with a panorama. A
hidden one is drawn as a map without it, so that is no reason; but the
hidden way converted the map without the extension's rows, so the poses'
blocks would not exist. Fixed in Wally —hidden converts with the
extension, as a map without a panorama does; a trial whose way changes is
refused—, with a test in `whole_map.rs`, red before.

And since the whole game does not fit, `posed_events` takes a list of
maps besides `true` (rm2k-snes-convert's `Posed`, with a test): a game
pays for the maps where it buys something. Branch `cardon-abl-posed` in
the-advocate.

### Map 8 goes in, and not even it fits

With the branch's tools and the key on every map, map 8 takes 8 events:
1 (Talan's Pad door), 11 and 12 (the pawn shop's door), and the five
monitors 6, 7, 18, 27 and 31 —the sign at (26,21) among them—. The rest of
map 8 stays objects: a command moves them (cars, the shop's people), a
pose draws past its cell, they turn toward the hero. Its lent graphics go
from six to three (Chara2, People1, People4 are still lent: characters,
not tiles), its sprite tiles in VRAM from 414 to 350. Map 76, the other
hidden panorama, takes none.

Twelve maps free a lent palette with it: 8, 11, 17, 37, 83, 108, 114,
128, 264, 278, 288 and 321. `posed_events` on those twelve: release does
not link. On `[8]` alone: it does not link either; counted in the `.inc`,
map 8 adds 619 B (map tiles +417, the posed record +337, sprite tiles
−229), and `just space release` left 302 B of gaps and no bank.

**So it stays off in ABL**, with the why as a comment in `advocate.toml`
(ports `cardon-abl-posed`). The palette of the signs is not fixed:
`abl-map-8-s-signs-lose-their-green` (a draft, deleted when [`event-page-records-compressed-behind-the-grid`](event-page-records-compressed-behind-the-grid.md) fixed it)
stays, with a note, and its Known issues line in the book too.

**What it does on screen**, on a test cartridge with only map 8 (not
committed: a `[cartridges.probe-lashe]` and two cases, removed), key off
and on `[8]`, switch 24 on: the monitor at (26,21) goes from grey (the
lent orange palette) to its green, like the one the map draws, 86 pixels;
Talan's Pad door's lower half takes the ChipSet's shades, 115 pixels.
`/shared/captures/2026-11-16-abl-posed-events/`.

Not measured, since nothing is on: lag on busy maps, the race, the
display audit. The runtime is Zounds' `posed.s`, unchanged.

**On a map with a panorama** (taro's question, through Hornero): the
reasons, and the 62 events on 13 maps that only the panorama keeps out,
are in the draft
[`posed-events-on-a-map-with-a-panorama`](posed-events-on-a-map-with-a-panorama.md).
Map 2's fading screens (11–14) are among them, because the compiler drops
route transparency today.

## Verified, and what to install

Merged with main (the-advocate 9074039c, ports 4e3bfac, book 690d794).
With the branch's wally and convert and the key off: release byte for
byte equal to the global tools' build; ABL's `just tests` 1660 passed, 2
skipped; `just test` 29 passed; `crate-test` wally (the new `whole_map`
test red before the fix) and convert (66, with the new `Posed` test)
green. No golden moves.

Not covered by any test: a hidden-panorama map with posed events in a
ROM —the only one, map 8, was looked at in a scratch cartridge—, and a
posed list in a cartridge that links.

To install when merging: `just install wally convert`.
