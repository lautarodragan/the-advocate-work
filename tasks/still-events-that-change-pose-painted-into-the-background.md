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
