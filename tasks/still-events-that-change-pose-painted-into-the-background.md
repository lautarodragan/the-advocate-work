---
name: "Still events that change pose, painted into the background"
description: "A map that lines many still CharSet events up —Zounds' map 96, fifty-six floor switches— draws each as a 32x32 object: past eight and a half on a line the console drops slivers, and sixty objects cost the frame two; painted into the background, with their cell written again when their pose changes, they would cost neither"
type: feature
status: doing
assignee: Cardón
agents: [Cardón]
---

Seen by Cardón on 2026-11-02, with the-advocate `0ba09da4` plus the
branch `cardon-map-96`, on Zounds' map 96 *Arriba del Cuartito*, while
doing
[`zounds-map-96-has-too-many-switches-for-the-sprites`](zounds-map-96-has-too-many-switches-for-the-sprites.md),
which made the switches share their poses in the slot cache and left
these two things.

**What is seen**: jump to map 96 at (8, 16), on the switch column. The
switches are all drawn now —each has its object in the OAM—, but

* **the line limit**: two rows of seventeen switches, one 32x32 object
  each, four slivers on each of its 32 lines. Up to 84 slivers on one
  line there, 128 with the camera on the two rows; the console keeps 34,
  and drops the frontmost objects': the lower row is not seen on the
  lines it shares with the upper one, the ninth switch of a row is cut in
  half, and a character beside them loses lines. The book's divergence
  "Too many characters on one line".
* **the frame**: 240 frames per 120 ticks at every place of the map
  measured, before the switches were drawn and after —(8, 16), (12, 17),
  (20, 17), (9, 12), with 32 to 60 objects in the OAM—. Measured with a probe of the V
  counter after each step of the main loop: `build_oam` costs about four
  lines per drawn row —`place_npc`, `cache_want`, `emit_object`—, and with
  sixty on screen it takes 130 to 240 lines; the rest of the loop and the
  music's IRQ take about 90. The cache's fast path was already the one
  taken: each switch finds its slot by `CACHE_EV` at the first look.

**What would fix both**: not drawing them as objects. The [decorative
events](https://lautarodragan.github.io/the-advocate-docs/divergences/baked-decorative-events.html)
are painted into the background, but only the ones nobody names and with
no commands; the switches have a touch page and two poses —unpressed, and
the one their route turns them to—. That needs:

* in Wally, a block per (cell's blocks, pose) for each such event, built
  as `Substitutions` builds blocks, and the event's row hidden as
  `baking::bakeable` hides it;
* in the runtime, a per-cell override in `build_row`/`build_column`
  —`cell_replaced` replaces a block everywhere, not one cell— and writing
  the cell's four tilemap entries when a page or a route changes the
  row's pose, if it is on screen;
* a measure of what it costs the background's tiles: map 96 fits no
  layout with its pictures already.

Only for the ones below the hero, as the decorative ones, so the order
with the characters does not change.

## taro's pick (2026-11-02)

After Cardón's experiment without the decoys
([`zounds-map-96-without-its-decoy-switches`](zounds-map-96-without-its-decoy-switches.md):
the decoys were all the lag) Hornero offered three paths —skipping the
rows off screen by Y, this one, and caching a still event's object—.
taro, in their words, translated:

> hmm no, let's try 2. It would be a smarter version of the baking
> system we already have. If the chests, switches etc. can be on BG2, we
> don't even need to bake them.

So: still events —one pose at a time, never walking— go into BG2's
cells, with the tile priority bit putting them under or over the
characters as their layer asks, and their cells rewritten when a page or
a pose changes; no baking into BG1. Where BG2 already holds a tile in a
cell the event covers, or its palette or tiles do not fit, the event
stays an object, measured and said.

taro, later the same day, through Hornero, translated:

> one thing that worries me in particular: the sprite change has to be
> just as fast. Today the commands that change the map's tiles lag a
> bit. We'll have to look at that eventually, but for now I care about
> not making the experience of chests, doors, etc. worse.

So a chest opening, a door, a switch pressed has to show its new pose on
the same frame it does today as an object —measured from the trigger to
the pose on screen, before and after—; the cell is not rewritten through
the `TileSubstitution` path, and an event whose pose change cannot land
on the same frame stays an object.

## Cardón's notes

Worked from the-advocate 244f4013, the-advocate-ports 6436a39 and the
book at 9a90e38, on branches `cardon-still-events-bg`; measured against
the real map 96, with its 55 decoys —the experiment without them stays
on `cardon-map-96-no-decoys`—.

### BG2 cannot hold an event below the hero

Mode 3's order, front to back, is objects 3 / BG1 1 / objects 2 / BG2 1
/ objects 1 / BG1 0 / objects 0 / BG2 0 (`runtime/far_ram.s` says it
where the priorities are chosen). The map is BG1 at priority 0 and the
hero and every event below or beside him are objects at priority 1. BG2
has **no place between them**: at priority 1 it is in front of the hero
—that is why the layer above lives there—, and at priority 0 it is
behind BG1, under the floor. So a switch painted into BG2 would be drawn
over the hero standing on it, and a chest over the hero standing below
it; the tile priority bit cannot put them under the characters.

The only way to keep BG2 is to **lift the characters**: a character
whose drawing overlaps a painted event goes to objects priority 2, in
front of BG2 1. That is right only where no tile of the layer above is
within that character's drawing at the same time —he would come out in
front of the roof too—. Measured on map 96 (the-advocate 244f4013, the
ports 6436a39), with the layer above as Wally converts it, the switch's
drawing (x 1–15, y 2–16 of its cell), the hero's (x −1 to 17, y −10 to
16 of his cell, from Zounds_Hero_01's twelve poses) and a character only
on the lines between two cells he can stand on (a cell is out if BG2
covers it whole):

* the 16 switches of row 21 have the layer above **in their own cell**:
  the room's bottom edge is drawn over their lower half;
* the 16 of the two columns stand in a corridor two cells wide between
  ceilings that stay above —the whole ceiling of map 96 stays above
  because of the statue, as the book's "Maps" says—, and the hero's
  outer column of pixels reaches them;
* **15 of 56** pass: row 20 but its two ends. Ignoring the hero's outer
  pixel, 32; with a character the size of his cell, 38.

Fifteen switches out of fifty-six take neither the frame nor the line
limit out of map 96: rows 20 and 21 are on the same screen lines, and
row 21 stays objects.

So, following "experimenting if the plan fails", what this task does
instead is **the background, BG1, with a block per pose**: the event's
cell gets one block per pose it can show —the floor with the switch up,
the floor with it down—, and the runtime writes the grid's cell and its
four tilemap words when the pose changes. BG1 at priority 0 is under
every character, which is where RM2k puts an event below the hero; and
one on the hero's layer whose drawing stays in its cell is only ever
overlapped by someone in front of it, as decorative events already
assume. The star tiles over row 21 stay on BG2, over it, as in RM2k.
taro's "smarter version of the baking" holds; "we don't even need to
bake them" does not, and that is the reason.

## What was done

`[graphics] posed_events = true` in a game's `advocate.toml` —Zounds
turns it on— draws its still events that change pose into the
background's cells (`posed` in Wally, `posed.rs` in rm2k-snes-mapdata,
`runtime/posed.s`; the book's divergence "Still events drawn into the
background" and its section in "Maps"):

* **Wally** picks them (`posed::select`): every page that draws draws a
  CharSet, or a ChipSet tile that does not go above the hero; no page
  walks, animates still or goes above the hero; nothing moves, flashes or
  dresses it, and it does not turn toward the hero; routes that only turn
  it are fine; every pose stays inside its cell; no substitution swaps its
  cell; not translucent. Not on a map with a panorama, pictures drawn
  into it, or one that loops. Each pose is a cell in rows drawn below the
  map, the cell's own tiles with the pose painted over the lower layer,
  cut off once the blocks exist —the substitutions' extension—; they go
  in only if the layer above stays as it was, the ground merges no more
  than decoration may and the background's tiles fit the layouts (all, or
  CharSet by CharSet). The row stays in the table; the grid starts with
  its start pose. The log says map by map who went in and why the rest
  did not.
* **The row** carries priority 3 in its attributes —no character's
  object has it—, its character in the palette bits and its number in the
  tile byte; `page_oam` writes the same for its pages.
* **The runtime**: `build_oam` sends such a row to `posed_row`, which,
  when the row's key —character, pose, or hidden— is not the cell's,
  writes the pose's block into the grid through the WRAM port and the
  cell's four tilemap words into two runs (top rows, bottom rows; cells
  side by side join), which `posed_drain` uploads by DMA in the next
  vblank, after the strips. `still_turn` only stores the pose for such a
  row. `posed_find` at `enter_map`, `posed_sync` before `fill_window`
  after a battle. Sixteen runs a region a vblank; a cell that does not
  fit waits, whole. All of it only in a cartridge with such an event.

### Measured

Map 96 with its 55 decoys, Zounds' release in snes9x, the same spots and
probe as the previous tasks (before: the global tools of 244f4013; after:
the branch):

| spot | frames / 120 ticks | max slivers on a line | loop lines | `build_oam` |
|---|---|---|---|---|
| (8, 16) | 240 → 120 | 84 → 12 | 305 → 194 | 213 → 102 |
| (12, 17) | 240 → 120 | 110 → 16 | 333 → 196 | 241 → 104 |
| (20, 17) | 240 → 120 | 92 → 12 | 295 → 187 | 203 → 95 |
| (9, 12) | 240 → 120 | 50 → 16 | 291 → 196 | 199 → 104 |
| (15, 19) | 240 → 120 | 128 → 12 | 337 → 186 | 245 → 94 |
| (14, 12) | 240 → 120 | 70 → 12 | 284 → 187 | 192 → 95 |
| (4, 5) | 120 → 120 | 28 → 12 | 244 → 195 | 152 → 103 |

68 of map 96's events go in; the 84 rows are still walked, a posed one
for about a line. `flush_video` takes 7 lines standing.

**Frames from the trigger to the new pose on screen** (taro's
constraint), first frame whose pixels change, before → after:

* rubble that switch 206 takes away on map 114 (posed: a page with no
  graphic): 2 → 2;
* a door that switch 226 takes away on map 114 (an object before and
  after: its drawing stands above its cell): 2 → 2;
* switch 139 turning map 96's decoys, 17 of them on screen looked at: 7
  → 7 for 16, 8 for one (8, 14). Fifty-five at once are 38 runs; with
  sixteen a region a vblank the last cells go a frame later. Word by word
  —the first version— eight cells cost seven lines of the vblank and the
  map's switches went over six frames; with 32 runs a region a vblank they
  went in one but `flush_video` reached line 258 of 262.
* chests: none of Zounds' goes in —each turns toward the hero when opened
  or draws past its cell—, so a chest is an object as before (the one on
  map 96, 8 frames before and after).
* a single switch pressed by its route: not measured on the pixels (the
  hero stands on it); it is the same path as the page change, the pose in
  the row and the cell from the same `build_oam`.

**Across the nine games**, with the key on in each and Zounds' release
cartridge as every game builds it (2026-11-02, the branch's tools):

| game | events into the background | maps |
|---|---|---|
| A Blurred Line | 422 | 71 (and the cartridge no longer fits: 126 banks taken) |
| The Book of Three | 52 | 12 |
| Desert Nightmare | 27 | 3 |
| Dooms 2 | 14 | 6 |
| El Dorado | 35 | 5 |
| The Frozen World | 117 | 28 |
| Sunset over Imdahl | 0 | 0 (its maps are painted or draw pictures) |
| Vampires Dawn | 2727 | 148 |
| Zounds | 426 | 48 |

What keeps the rest objects, most to least in every game: a pose past
its cell, animating still, turning toward the hero, a command that moves
or flashes it, a route that moves it or dresses it. Vampires Dawn's is
mostly still decoration, which its project does not take as decorative.
Only Zounds turns the key on in this branch: the rest is taro's call
—A Blurred Line does not fit with it—.
