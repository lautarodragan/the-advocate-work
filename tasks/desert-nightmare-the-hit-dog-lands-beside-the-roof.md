---
name: "Desert Nightmare: the hit dog lands beside the roof"
description: "In the dog scene on map 11 the hit dog shows on the sand left of the warehouse's roof, a little lower, slides behind it and leaves a sliver at its edge; RM2k hides it behind the roof: it goes with the screen, and the console scales those"
type: bug
status: testing
assignee: taro
agents: [Aguará, Hornero]
author: aguara
game: desert-nightmare
links:
  found-in: [desert-nightmare-the-dog-runs-over-the-building]
---

Seen by Aguará on 2026-11-21, at the-advocate `b18e4d4f` with the fix of
[`desert-nightmare-the-dog-runs-over-the-building`](desert-nightmare-the-dog-runs-over-the-building.md)
(branch `aguara-dn-dog`), playing map 11 from map 4's door, (8, 12): the
scene starts on its own.

Event 80 runs the dog as picture 1 by variables 14 and 15, its event's
screen place, **with the map** (`Hund_Animation1` to `3`), and then shows
the hit one, `Hund_Animation4`, at the same variables **with the screen**
(`ShowPicture`'s `p[4]` at 0) and moves it 32 pixels right. Map 11 is
RM2k's one screen, so RPG_RT puts both at the same place —the camera never
moves—, and the hit one is behind the roof, picture 2, but for its tail on
the sand for a moment.

The console scales a picture that goes with the screen —four fifths across,
fourteen fifteenths down; its map is not scaled—, so the hit dog shows some
sixteen pixels left of the running one and a few lower, whole on the sand,
slides right behind the roof and leaves a sliver of itself at the roof's
edge until the scene leaves the map.

Making it go with the map is not enough: a picture that goes with the map
does not move on the console, as in RM2k 2000 (`PIC_MAP_FIXED` in
`pic_move`, runtime/picture_far.s), and this one is moved. Nor can every
picture placed by variables on a one-screen map go with the map: Zounds'
menu selectors (maps 83, 190) are placed by variables over pictures that go
with the screen. What would do it: the same number shown by the same
variables with the map and with the screen on a map RM2k never scrolls,
both with the map, and the move done for it. Measured over the eight games:
only map 11 does that.

## Log

### 2026-11-23, Hornero: taken for Aguará

> I would start this one as soon as possible —in parallel or when it
> doesn't cause troublesome conflicts

(taro.) Taken after Carpintero's `carpintero-dn-thoughts` was merged, which
touched how big pictures are split between texture and still layers.

### 2026-11-23, Aguará: RPG_RT under Wine, the measure, and the red test

From the-advocate `ccf14154`, the ports `c3d9418`.

* **RPG_RT slides the hit dog out of sight.** The original under Wine,
  with its start moved to map 11 at (8, 12) in a copy of its LMT: the
  running dog ends its run with its tail at the roof's left edge; the hit
  one, `Hund_Animation4`, starts there —the same variables— and slides 32
  pixels right behind the roof in half a second (`MovePicture`'s 5
  tenths, with its wait), and from then on nothing of it shows.
* **Only map 11, over the nine directories of the ports** (ABL and the
  eight games): a number shown by variables both with the map and with the
  screen, at the same two variables. Counting the maps RM2k scrolls too,
  still only map 11.
* A second test in `test_desert_nightmare_dog_behind_the_warehouse.py`:
  the sand along the roof's left edge —one cell wide, down past the roof—
  at the message after the hit is as the map showed it on arriving, before
  the scene. Red with the global tools at `ccf14154`: 45 of its 1280 pixels
  changed.

#### The fix

The rule the draft proposed: on a map RM2k never scrolls (its one screen
or less, not looping), a screen picture shown by the same two variables as
one under its number that goes with the map, and by no others, **goes with
the map** —`screen_on_map` in the converter's `pictures.rs`; its image not
scaled— and **still moves**: the compiler gives its `ShowPicture`
`PICTURE_SCREEN` (`$04`) with `PICTURE_MAP_FIXED`, and the runtime's
`pic_move` keeps still only a slot with the map and without `PIC_SCREEN`.

The scene tick by tick after the fix: the hit dog starts where the running
one ended, its head at the roof's edge, and is gone some ten ticks later,
as under Wine. Side by side in `/shared/captures/2026-11-23-dn-hit-dog/`;
no golden moved.

Every ROM changes by the two bytes `pic_move` grew; only Desert Nightmare's
map 11 changes what it shows.

Branches `aguara-dn-hit-dog`: the-advocate `bfe6922d`, the ports `cb8ce4f`
(the test), the book `3ab3893` (the divergence on `MovePicture`, and DN's
Known issues line out). To install when merging: `convert` and `events`;
the runtime goes in with `~/the-advocate`'s checkout.

#### Verified

With `cartridge`, `convert` and `events` installed from the branch: the
crate tests of `events` and `convert`; the-advocate's `just test` (29
passed) and `just test-game` (226 passed, 6 skipped); the ports' `just
boot` (207 passed); ABL's `just tests` (1692 passed, 2 skipped). No golden
moved. `abl.sfc` `b4f04fb979d6d0bf`, `desert-nightmare.sfc`
`9bb5889ebb33d74b` (sha256, first 16).

No test plays the case where the slide is not by variables or the map is
smaller than RM2k's screen: the rule takes them, and no game has one.
