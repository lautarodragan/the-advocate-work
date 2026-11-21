---
name: "ABL: Core's blood turns brown"
description: "On map 3, Emitter Room, the Future1 tile Lysander used as Core's blood on the floor (46,19) comes out brown on the console, from how the colours are grouped into palettes; give the map a tile of its own in Core's blood colours"
type: bug
status: done
assignee: taro
author: taro
agents: [Calandria]
---

taro, on 2026-11-16, with captures from Mesen:

> Core's blood on the floor changes colour, because of the palette
> distribution, and turns brown. It looks very ugly, and doesn't look like
> blood... The original tile isn't really blood-coloured either. It seems
> Lysander used a tile that was available in the tileset to simulate
> blood. The tile is from `Future1`. Position (46,19) on map 3, Emitter
> Room.

> Probably the best is a fix specific to this map. Since we can, and the
> original isn't particularly pretty, we could create a tile that is a
> copy-paste of the existing tile but with the colours of Core's blood.

In parallel, [`abl-is-there-a-better-palette-grouping`](abl-is-there-a-better-palette-grouping.md)
asks whether Adeleine could group the colours better in general; this one
is the targeted fix regardless.

Done means: map 3 draws that cell (and any other cell of the same pool, if
the map has more) with a tile in the red of Core's blood —taken from
Core's own sprite/CharSet colours as the console shows them—, through the
manual patches (a ChipSet added with its recipe, the map forked), with
nothing else on the map getting worse (the map's other colours, its
degradations), captures before/after for taro.

## Log

### 2026-11-16, Calandria

Started from the-advocate 705d24f5 and the ports 299088c, branches
`calandria-core-blood` in both.

What the cell is: map 3 uses ChipSet 7, `Future1` (image `ChipSet1`, of the
RTP). (46,19) is lower 4166 with **upper tile 123** on top, the only cell of
either layer with that tile. But there is a second use: **event 22,
`CoreBlood`, at (64,45)**, a tile event of a single page with no
conditions, drawn with upper tile 123 too —it is Core's blood in the
earlier scene, by the broken consoles—. And over (46,19) stands event 43,
`DeadCore`, `Future3` character 3, whose pose carries its own pool of
blood at the feet in four reds: (100,20,10), (150,50,20), (192,50,20),
(250,50,20). Those are "Core's blood colours".

Tile 123 is a salmon-pink splash: (203,85,85) ×37, (138,50,35) ×17,
(245,100,100) ×15, (245,135,105) ×15, (158,66,48) ×8, (100,50,50) ×8,
(60,30,20) ×4, (196,96,73) ×3, (141,64,64) ×2, and three dark greys of one
pixel each. On the console (release's Adeleine output, `0003-fondo.png`)
the cell is baked into the background and comes out in two browns,
(160,120,80) and (120,80,56). And the event's copy, as a sprite, is in
`degradations.json` as `palette-lent`: "4 graphic(s) without a palette of
their own, drawn with someone else's: @tile:ChipSet1:123:0, …" —it is
drawn with another sprite's palette—.

The recipe had no operation that keeps a tile's drawing and changes its
colours —copies keep them, `from_image` would mean a drawn PNG the repo
cannot version—, so I added the smallest one, **`recolor`**, to
`rm2k-snes/convert/src/chipsets.rs` (the-advocate `a9ace784`): upper tiles
and `[from, to]` pairs, painted **by colour, not by index** —the index is
shared with every other tile of that colour—, the `to` at 15 bits in the
same palette `from_charset`/`from_image` use, and a `from` the tiles do not
draw stops the build. Test `a_recolor_paints_its_tiles_by_colour_and_only_them`,
shown red with the call removed. The release built with this convert and
**without** the fork is byte for byte 705d24f5's: `5e0db182…`.

The patch, in the ports: ChipSet **56**, `ChipSet1_3` (`Future1`'s record,
new id and name) with `recolor` of upper tile 123 —recolored in place,
which changes both uses, the cell and event 22—, and map 3 forked: the
dump's JSON with `chipset_id` 56 and the `id`, `.tiles` byte for byte.
The nine colours go by lightness onto the four reds: the two highlights to
(250,50,20), (203,85,85) and (196,96,73) to (192,50,20), the three mid ones
to (150,50,20), (100,50,50) and (60,30,20) to (100,20,10); the three
one-pixel greys stay. No `prune`: the palette had room.

Measured, release before (`5e0db182…`) and after:

* RM2k's drawing (`rm2k-render layers`, original vs. with `ChipSet1_3`):
  only cell (46,19) changes, 109 px.
* Adeleine: the blood cell goes from two browns, (160,120,80) and
  (120,80,56), to **a single red, (192,48,16)**: the map has room for one
  red, not four. The map regroups —18,222 px of map 3's background differ
  in 340 cells— but towards RM2k: outside the blood cell, mean |RGB| error
  against RM2k's drawing at 15 bits **0.368 → 0.303**, exact pixels
  97.84% → 98.26%, worst 128 → 120. The converter log: 75 → 71 distinct
  colours, 36 → 34 in CGRAM, 108 → 93 merged. No other map changes.
* Tried and dropped: two reds instead of four (body and dark). Adeleine
  keeps the body red and turns the dark one **grey** (32,32,32): worse.
* `degradations.json`: the same entries, but `palette-lent` names
  `ChipSet1_3:123` instead of `ChipSet1:123` (event 22 still borrows a
  sprite palette; on the console it went from dark brown-red to red).
* Captures before/after, the console and RM2k's drawing, in
  `/shared/captures/2026-11-16-core-blood/`. The original under Wine was
  not taken: reaching that scene needs playing up to it; RM2k's drawing of
  the layers is from `rm2k-render`.

Merged main into both code branches (the-advocate 63555c31, the ports
5b6956e) and ran it all again on the merged trees:

* the-advocate: `just crate-test convert`, 65 green.
* ABL, with the local `rm2k-snes-convert`: `just patches` rewrote only
  `patches/auto/maps/0003.toml` (its own commit). Fourteen goldens of map
  3 moved —3-down-54…60, door-sender-10/40, talan-40…1200,
  panorama-3-arrival—, 960 to 3,442 px each, eight rounds until no new
  red; none frames the blood, they are the map regrouping. Looked at side
  by side and, where it moved most, against RM2k's drawing: the table at
  (43,53) loses a darker right panel the old grouping made up and RM2k
  does not draw. In their own commit; side by side in
  `/shared/captures/2026-11-16-core-blood/goldens/`. Then the whole suite:
  1660 passed, 2 skipped. `abl.sfc` `659d15d6…`.
* A first run before merging had the linter and `test_space` red in every
  cartridge (`msg_layer_ink`'s `phy`): main's runtime moved under it while
  it ran; they were green after the merge.

The book: "Core's blood is red", a decision of ABL, in
`ports/abl/decisions/`. The suite does not look at the blood cell itself:
no golden frames (46,19) or (64,45). What shows it are the captures.

**To install on merging**: `just install convert` (rm2k-snes-convert
only). Branches: `calandria-core-blood` in the-advocate, the ports and
the book.

**2026-11-16, taro**: declared done.
