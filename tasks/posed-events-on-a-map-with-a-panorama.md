---
name: "Still events into the background on a map with a panorama"
description: "posed_events skips every map whose panorama is seen —baked, mode 3, flattened, mode 1—; in A Blurred Line that alone keeps 62 candidate events on 13 maps objects, Linkage Block's fading screens among them"
type: feature
status: draft
assignee: taro
author: cardon
agents: [Cardón]
links:
  found-in: [abl-still-events-painted-into-the-background]
---

Seen by Cardón on 2026-11-16, with the-advocate 7fa94195 plus
`cardon-abl-posed`, the ports 4e3bfac, A Blurred Line's `release` with
`posed_events = true`, while doing
[`abl-still-events-painted-into-the-background`](abl-still-events-painted-into-the-background.md).
taro asked, through Hornero, whether events on a map with a (flattened)
panorama could go in when they never share screen space with the
panorama that shows.

**Why a map with a panorama is kept out today**: `posed_events` in
Wally's `map.rs` returns early for any map with a panorama but a hidden
one (`cardon-abl-posed` let the hidden one in). It is not the screen —no
HDMA, no window mask—: it is how the background is converted per way, in
`convert_ways` in `layers.rs`:

* the poses' blocks are built from rows drawn below the map
  (`Drawn::extended`), converted with it and cut off in `blocks`. Mode 3
  and mode 1 convert those rows only when a substitution needs them
  (`extra_needed`); flattened always does. Without them the poses have no
  blocks;
* **baked** draws the panorama into the background, and the rows below
  the map are drawn over the panorama at *their* place, not at the
  event's cell: a pose's block would carry the wrong stretch of panorama
  wherever the cell lets it through;
* **mode 1** puts the map at 4 bits: a pose has to fit the cell's 4-bit
  palettes, which the colour check would have to keep in step;
* the way is decided before the poses and on the tiles the layouts leave:
  more background tiles can change it, so a trial whose way changes has
  to be refused (`cardon-abl-posed` already does).

What it would take, in that order: convert the extension in mode 3, mode 1
and flattened whenever there are poses, as `extra_needed` does; skip a
pose cell where the cell is not opaque in baked (or leave baked out);
and in mode 1 let the colour check speak for the 4-bit palettes. The
runtime's `posed.s` writes the block's own tilemap words, so priority and
palette bits come with the block; that still has to be checked on a
mode 1 map, which no test runs.

**Measured** with a throwaway Wally that ran the choice on those maps and
kept nothing (not committed): 62 events on 13 maps pass every other rule
and stay objects only because of the panorama, before any tile or colour
trial —flattened 4 maps and 20 events, baked 4 and 19, mode 1 2 and 13,
mode 3 3 and 10—: map 1 (1), 2 (13), 3 (6), 13 (2), 16 (1), 19 (6), 32
(7), 45 (6), 82 (2), 95 (5), 228 (5), 268 (1), 313 (7). The log line was
`map N: PROBE …`; rebuilding it is a dozen lines at the top of
`posed_events`.

**Careful with map 2**, Linkage Block: its candidates include events
11–14, the screens that events 15–16 fade with `IncreaseTransparency`.
They pass because the event compiler drops route transparency today
(`ROUTE_TRANSPARENCY` in `route.rs`), so the fade route looks like one that
only turns. Painted into the background they would lose the fade. Once
transparency compiles into the route, `in_place` in `pages.rs` does not
count codes 40/41 and those four stay objects as "a route moves it"; that
has to land before any panorama map is let in.

And in A Blurred Line none of it can go in until `release` has room:
see the task above.

## Comments

### 2026-11-24, Cardón: a question for taro

**What to decide**: whether to let still events go into the background on
maps with a panorama —62 events on 13 of ABL's maps, measured—, which
costs background tiles in a `release` that, per
[`abl-still-events-painted-into-the-background`](abl-still-events-painted-into-the-background.md),
has no room for them yet, and work in Wally's ways (the extension
converted in mode 3/1/flattened, baked's non-opaque cells, mode 1's 4-bit
palettes, a path no test runs). taro asked whether it could be done; this
answers it. Route transparency reaches the ROM since `67668cab`, and
`in_place` (`rm2k-snes/events/src/pages.rs:857`) does not count 40/41, so
Linkage Block's fading screens stay objects as the draft asks.

**Options**: (a) `todo` for flattened and mode 3 only (24 events on 7
maps), leaving baked and mode 1 out; (b) all four ways; (c) `wishlist`
until a game's crowded lines need it.

**Recommendation**: (c): it is what the crowded-lines and slot drafts
would reach for, so it is worth doing when one of them asks for it, with
(a)'s scope.

### 2026-11-28, taro: a comment

> “has no room” -> rom, wram, vram?

### 2026-11-28, Hornero: ROM

ROM: the cartridge's data banks. With `posed_events = true`, ABL's
`release` already fails to link —"a piece of 65536 bytes needs a new
bank, and the 126 banks the cartridge has for data are taken"—: the
still events painted into the background grow the data by some 38 KB
(map tiles +32 KB, the posed tables +16 KB, blocks +4.7 KB, against
sprite tiles −8.5 KB and poses −5 KB), with 302 B of gaps left
([`abl-still-events-painted-into-the-background`](abl-still-events-painted-into-the-background.md),
its log). Doing it on panorama maps too adds to that. VRAM is not the
limit here: a still event in the background saves sprite tiles.

### 2026-11-28, taro: a comment

> oki. is there more stuff we can move to the msu, while keeping it optional?
>
> hmm regarding this task specifically, we should have it as a feature either way, and figure out the rest later.
>
> I think, for this task, we can make it an option in the advocate.toml for now. 
>
> But we’ll need to test it either way, so we have to figure out how to free some rom in abl. 
>
> I guess the quick snd easy thing to do would be to go back to compressing more maps?

## Log
