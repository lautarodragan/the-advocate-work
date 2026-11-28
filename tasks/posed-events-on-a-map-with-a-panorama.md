---
name: "Still events into the background on a map with a panorama"
description: "posed_events skips every map whose panorama is seen —baked, mode 3, flattened, mode 1—; in A Blurred Line that alone keeps 62 candidate events on 13 maps objects, Linkage Block's fading screens among them"
type: feature
status: doing
assignee: aguara
author: cardon
agents: [Cardón, Aguará]
links:
  found-in: [abl-still-events-painted-into-the-background]
  found: [posed-event-takes-a-merge-the-map-already-made]
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

### 2026-11-28, Hornero: room in ABL, the .msu and compressing; to todo

First a correction to my "ROM" answer: it quoted the log of
`abl-still-events-painted-into-the-background` from before the room was
made. Since 2026-11-16 ABL has `baked_events = true` on every map without
a panorama, and it fits. `just space` on ABL's `release`, today (tools
`71ccb4eb`): 108 of 126 data banks used, **no whole 64 KB bank free but
18 halves of 32 KB**, and 9,847 B of gaps. So there is still room, some
590 KB, but not as whole banks; what the panorama maps would add is not
measured.

On the questions:

- **More to the `.msu`, keeping it optional**: by its rule the `.msu` only
  replaces what the ROM already has, so it frees ROM only where the ROM
  keeps a lighter copy, as the battle backdrops do (an eighth of their
  `.msu` weight). Other things that could go that way —the title and Game
  Over images, the pictures, the battlers— are not measured.
- **Compressing more**: the grid, the blocks, the map tiles, the panorama
  tiles, the bytecode and the page tables already travel as LZ2. What
  does not is not measured by kind; nothing measures ABL's ROM by kind
  today.

So, as taro says: to `todo`, as a feature behind a knob.

1. The still events on panorama maps, behind their own key in
   `advocate.toml`, off by default; flattened and mode 3 first (option
   (a)'s scope), baked and mode 1 after or as drafts.
2. Turned on in ABL. If it does not link, the first thing to look at is
   whether what asks for a whole bank can go in the 18 free halves, before
   compressing or moving anything to the `.msu`. If more room is needed
   after that, measure ABL's ROM by kind and bring taro the options with
   their numbers.

Not started.

## Log

### 2026-11-28, Aguará: what is already done, and what is left

Started from the-advocate `b4654a3a` and the ports `aaa51a7c`.

**Flattened and mode 3 already take them**, under `baked_events` alone,
since the-advocate `9f0e21d0` (Cardón, 2026-11-18, "a map with a panorama
that shows takes them too, on the ways that draw the extension's rows"):
`posed_events` in Wally's `map.rs` lets a seen panorama through when its
way is mode 3 or flattened and every cell the bake writes is opaque in
every drawing. ABL's `release` already does it: in its converter log
(ports `build/release/converter.log`, built today on main) map 2, Linkage
Block, flattened, has 8 still events in the background —1, 10, 30–35—, and
its fading screens 11–14 stay objects, "a command moves or flashes it".
Zounds does it too: maps 20, 21 and 176, flattened, and 32, mode 3. The
62-on-13 count above is from before that commit.

So what is left of the task is **baked and mode 1** —the 2026-11-16 count
had 4 baked maps (19, 45, 82, 228) and 2 mode-1 ones (3, 32)—, and the key
taro asked for. The key: `[graphics] baked_events_over_panoramas`, off by
default, gating every map whose panorama is seen —mode 3 and flattened
too, not only the new ways—, so the option is the one taro described; ABL
and Zounds, which already bake over a panorama, turn it on and their ROMs
stay as they were for those ways.


### 2026-11-28, Aguará: baked and mode 1, and the key

the-advocate `aguara-panorama-events` 5ae4b600. `posed_events` lets a seen
panorama through when the request says `posed_over_panoramas` (from the
new key) and the way is mode 3, flattened, mode 1, or baked with no
substitution rows. Mode 1 needed nothing more: it already converted the
map with the poses' rows, and the colour check (`same_split` and the
merges' victims) refuses a pose that merges a colour more or changes the
palettes' budget. Baked converted the map without its extension, so its
poses had no blocks; `convert_ways` now bakes the extension when there
are poses and no substitution rows —the panorama under the pose rows
falls at their own place, which an opaque cell never lets through; a
substitution's rows would carry the wrong stretch of it, so those maps
keep them objects—. Wally's `whole_map.rs` has a test for the four ways
and the key, red before the change (the baked case: no event in the
background).

#### ABL's `release`, measured

`just space release` in ABL, before (main's tools, ports `aaa51a7c`) and
after (this branch's, with `baked_events_over_panoramas = true`):

| | before | after |
|---|---|---|
| data banks used | 108 of 126 | 109 of 126 |
| whole banks free | 0 | 0 |
| halves of 32 KB free | 18 | 17 |
| gaps | 9 B | 32,021 B |

Free in all: 589,833 B before, 589,077 after: **756 B more data**. It
links without touching `banks.rs`.

**Two events go in**, on two maps: map 3, Emitter Room, mode 1, event 42;
map 175, baked, event 4. The rest of the candidates stay objects, each
with its reason in the converter's log:

* "they move its colours or its tiles past the layouts": map 3 (5, 6, 7,
  45, 46), 19 (4, 10), 32 (1, 3, 4, 5, 24), 45 (7, 8, 11, 12), 82 (4, 5),
  175 (1, 3, 6), 228 (4, 5, 6, 7) —26 events: the baked maps are at their
  colour memory (map 19, 99 of 99 entries, 32 merged), and mode 1's
  palettes of fifteen are full—;
* "the panorama shows through a cell it is drawn on": map 19 (8, 9), 32
  (23, 25), 45 (4), 228 (3), 255 (66–72) —13 events—.

Mode 3 and flattened are as they were: the same lines in the log.

### 2026-11-28, Aguará: Zounds, the goldens, what is seen

**Zounds lists its four maps**, `baked_events_over_panoramas = [20, 21,
32, 176]`: with `true` its mode-1 map 65 takes ten more events (1, 2, 5,
6, 9, 10, 13, 14, 17, 18), which changes what is seen there without anyone
having looked at it. With the list its `release` is byte for byte the same
built with main's tools and the old toml as with this branch's and the new
one (sha256 `ec48d33a…`). Turning it on for map 65 is Zounds' own choice.

**One golden moved**: `panorama-175-arrival`, of `test_panorama_golden.py`
—map 175's event 4, a figure on the wall, is in the baked background now:
same place and shape, 12 pixels change shade; the map keeps its 88
colours with none merged—. Committed alone in the ports. `--write-patches`
rewrote the patches of maps 3 and 175: mode 1's merges move more pixels on
map 3, and map 175 keeps 24 more colours.

**Map 3's event 42**, the mode-1 one, is in no golden: a throwaway capture
(hero at (70, 21), switches 1 and 4 off, 19 turned on and off) shows it at
the same place and shape as the sprite, and gone again when 19 goes off;
its tilemap words carry their palette bits right in mode 1. But 46 of its
pixels are one 5-bit step lighter: the map's mode-1 palettes already merge
that grey, and the colour check only compares which colours merge. Draft
[`posed-event-takes-a-merge-the-map-already-made`](posed-event-takes-a-merge-the-map-already-made.md),
and a line in ABL's Known issues in the book.

Captures, before and after, in
`/shared/captures/2026-11-28-panorama-still-events/`, with a README.

**What no test covers**: the pose change of a baked or mode-1 event in the
ROM —the golden of 175 is a single pose, and map 3's capture is not in
the suite—, and the baked path with substitution rows, which refuses on
purpose and no game reaches.
