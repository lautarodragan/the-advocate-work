---
name: "ABL: map 11 back to the original"
description: "The stones and lights minigame plays well with the game's own map 11 now: drop the redesign's fork, its ChipSet if nobody else uses it, and what tests and docs say about it"
type: tooling
status: testing
assignee: taro
agents: [Mulita]
---

taro, on 2026-10-20, after playing a build of A Blurred Line without the
redesign of map 11 (ports `4749a8c`, the-advocate `796b4dc9`, map 11's
override removed; delivered apart in
`/shared/captures/2026-10-20-abl-original-stones/`):

> now it runs perfectly without the patch! We can remove it

The redesign was
[`map-11-redesigned`](map-11-redesigned.md): the original lagged, so its
light events became tiles of a custom ChipSet with terrains marking the
areas. The engine's optimisations since —among them baking still events
into the map: 22 of map 11's are baked today— made it unnecessary.

**Done**: `abl/patches/manual/maps/Map0011.*` gone; the ChipSet record
it used, if no other patch uses it; the tests and goldens that covered
the redesign either moved to the original map —the minigame still
played and won by the suite, if it was— or removed with a reason;
patches README, `rm2k-snes.toml` comments and the book updated; ABL's
suite green.

# Log

**2026-10-20, Mulita.** Started from the-advocate `8715b90e`, ports
`c333ab6` and docs `5959e14`, on branches `mulita-map-11-original`.

What the fork carried, and what goes with it: `Map0011.json` and
`.tiles` in `abl/patches/manual/maps/`, and `ChipSet/0053.json`
(`lasheint11`), which only map 11's fork names —18 uses 54, 32 uses 55,
the debug map 1000 uses 10—. The ChipSets are a `BTreeMap` by id in
`fork.rs`, so a gap at 53 is allowed and 54/55 keep their ids.

What relied on the redesign, found by grep over the ports, the-advocate
and the book:

* `tests/abl/test_lights.py`: written for the redesign —`sub_n`, the
  upper tile 10080 of cone B—. Rewritten over the original's events.
* `tests/harness/stones.py`: its docstring says the map read is the fork.
* `tests/tooling/test_pages.py`: the four variable slots above 204 were
  the redesign's parallel; without it they go.
* `tests/UNTESTED.md`: "the day the fork of map 11 brings its own
  ChipSet…".
* `patches/manual/README.md`: "Map 11…" and the contact-vs-parallel note.
* The book has nothing on the redesign outside research snapshots, which
  are not edited.
* the-advocate: comments on map 11 talk about the original's lights and
  the stones engine, which are back; nothing to change.

## What the original map costs per frame

Measured on 2026-10-20 over `release`, built from the ports worktree with
the fork removed and again with it, with the global tools (the-advocate
`8715b90e`) and snes9x. The instrument is the harness's: `lost_frames`
—read and reset every 50 frames, since it saturates at 255— and the loop
laps in `ticks` against hardware frames. The script was thrown away; it
walked the hero back and forth along each lane for 1200 frames, holding
the direction to the far end and turning, the lanes stopping one cell
short of the light events so nothing catches him; "engine on" is after
talking to `Grate1`, with `EV0017`'s parallel running.

    lane, 1200 frames                       engine   original    redesign
                                                     lost laps   lost laps
    row 48, x 8-16 (cones B, C, D on screen)  off      0  1200     0  1200
                                              on       0  1200     0  1200
    row 45, x 5-11 (cones B, C)               off      0  1200     0  1200
                                              on       0  1200     0  1200
    row 54, x 3-11 (cone E)                   off      0  1200     0  1200
                                              on       0  1200     0  1200
    column 23, y 48-52 (cone A)               off      0  1200     0  1200
                                              on       0  1200     0  1200
    still at (14,48), between the cones       both     0  1200     0  1200
    still at (50,50), nothing on screen       both     0  1200     0  1200

The cells of the 2026-09-21 table —(50,50), (26,47), (18,50), (19,46),
(5,50)— give the same: 0 lost out of 1200 standing and walking, with both
maps. (At (19,46), which is a cell of cone B, the original's touch
trigger catches him on the first step and the teleport back loses 2.)
That is, **walking and standing, the original fits in the frame
everywhere the minigame is played**, where on 2026-09-21 it was at 30 fps
flat in three of those cells.

What does cost something is the moments the minigame moves events, 300
frames after each, frame by frame:

    moment                                   original           redesign
    stone thrown up at the PC from (19,52)   6 lost, single     1 lost
    stone thrown left from (26,52)           3 lost, single     0 lost
    stone on Light5, cone A turned off       6 lost, single     1 lost

"Single": each one is one frame alone —at frames 1, 35, 38, 62, 65 and
82 of the throw at the PC—, never two in a row, so it is a missed vblank
here and there and not a drop to 30 fps. It is the price of the
original's 84 events against the redesign's 34, and taro played it
without noticing.

## What changed in the ports

* The fork and ChipSet 53, deleted, alone in their commit.
* `test_lights.py`, rewritten: it was red on the original —it looked for
  cone B's upper tile and for `sub_n`—. Now a step onto a lit cell of
  cone B, and onto `A1`, runs its touch page and opens "they caught me"
  (82 ticks after the step, the guard walks first); and the stone on
  `Light5` breaks the lamp —switch 44— and sends cone A's ten events to
  (54,82) and the stone to (98,98). **It does not step into the cone after
  it is off**: the hero is boxed in on the lamp's cell, and `go_to_map`
  reloads the map, which brings the cone back, as a `Teleport` to the
  same map does in RM2k. The new version was not shown red: the old one
  was, on the original, and the new one cannot run on the redesign, whose
  map has no `A1`.
* `test_parallels.py`'s frame test walked nowhere: it stood at (50,50),
  where `in-11` leaves the hero and no light is on screen. It now walks
  row 48 from x 8 to 16, cones B, C and D on screen: 180 laps out of 180.
* `test_pages.py`: the four slots above 204 were the redesign's parallel;
  now it checks there are none.
* `UNTESTED.md` and `patches/manual/README.md`: map 11's fork, in the
  past.
* `patches-check` against `release`: map 11's automatic patch did not
  move.
* The book: nothing to change. It names map 11 only in research
  snapshots, and `TileSubstitution` and `StoreTerrainID` in general
  terms. ABL no longer uses either command anywhere; the test cases
  `tile-sub*` and `terrain` still cover them.

## Verified, and what to install

On the ports branch `mulita-map-11-original` (`f3f686b`), with the global
tools (the-advocate `8715b90e`):

* ABL's whole suite, `just tests` —which builds every cartridge first—:
  1574 passed, 2 skipped (the two of `test_paradise.py` that say 108 no
  longer takes turns in release). Twice, the second with `-rs`. **No
  golden moved**: map 11's goldens are the empty area at (50,50), and the
  shots taken at six cells of the minigame came out pixel for pixel equal
  with and without the fork —the redesign was made to look the same, and
  22 of the original's light events are baked into the map anyway—.
* `just space`: bank 0 as before, `test-change-system` the tightest at
  56 B; `release` 111 B.
* `just boot`, from the ports' root: 96 passed.
* `abl.sfc` of `release`: sha256 `5b8aa3ad39ed…`.

**Nothing to install**: no Rust or runtime changed. The book has no
change either, and there is no branch of it.

What the suite does not cover: stepping into cone A after it is turned
off —see above—, `ResetPuzzle` bringing the cones back, and winning the
minigame to the end. Neither did the redesign's tests.
