---
name: "Maps that wrap around"
description: "A map with Wrap (scroll_type) is a torus in RM2k —hero, events, camera—; the console stops everything at its edges. Twelve maps of Zounds, Vampires Dawn and Sunset use it; on Zounds 70 it hides a room"
type: feature
status: testing
assignee: taro
agents: [Hurón]
---

Opened by Hurón on 2026-10-19, from the research
[`zounds-a-map-that-wraps`](zounds-a-map-that-wraps.md); everything
measured is in the book, `research/2026-10-19-maps-that-wrap.md`. At
the-advocate `2c350d8f`, the ports `1182513`.

**What is seen**: on Zounds' map 70, Passage 1, the corridors that go on
across the map's edges end at them, and the door at (86,13) to map 103
cannot be reached walking. Vampires Dawn's free fall (254) and Sunset's
bats over the town wall at night (63) pile up at the edge instead of
coming back in from the other side.

## Proposed scope

**Step 0, on its own** (the converter, a few lines): a
`map-does-not-wrap` entry in `degradations.json` for each map with
`scroll_type` other than none, so the build says it until step 1 lands.

**Step 1**, the cheapest that covers the ports' twelve maps:

* the map record says which axes wrap —a sentinel in `M_CAM_MAX_X`/`_Y`
  costs no byte—; the converter emits it;
* the camera does not clamp on a wrapping axis, and the scroll and the
  window follow a **continuous view** that moves by the camera's change
  folded the short way round, so the window's slots (x mod 64, y mod 32)
  stay continuous across the seam;
* `build_column`/`build_row` read the map modulo its size —a second
  stretch from the first row or column instead of the empty fill—, with
  the map column and row the window is at advanced one at a time next to
  `win_col`/`win_row` (no division: `map_cw` passes 255);
* steps: `cell_neighbor_exists` says yes across a wrapping edge, the cell
  pointer is recomputed when a step crosses the seam, the target
  coordinates wrap (`add_a_to_dest_*`, `add_a_to_pass_*`), the hero's four
  `try_*`, and `can_fall` for jumps;
* every "position minus camera" folds into the map's width: characters
  and hero in `oam.s`, `in_sight`, battle animations over a character;
  distances to the hero (`turn_toward_hero.s`, toward/away in
  `walk_by_type.s`) fold the same way;
* assembled only in cartridges with a wrapping map (an `.ifdef` like
  `paint_table`), in a far bank with `jsl` hooks: bank 0 had 108 to 218
  bytes left in the release cartridges on 2026-10-19, and the change is
  estimated at 500 to 700 bytes. Its RAM, about a dozen bytes, in `FARBSS`.

**Out of the scope**, because no port's map needs it (see the research):
clones of a character on both sides of a seam, the panorama's rule on a
looping axis (Sunset 63's is screen-sized), pictures tied to the map, the
Y order of characters across a vertical seam.

**Next to it**: Zounds 150's endless corridor also needs
`a-forced-routes-repeat-flag-is-dropped` —its hero's walk is a repeating
`MoveEvent`, run once today—.

**Done** means the hero and the events cross the seams of a wrapping map
as in RM2k, with the camera following; test-game cases for a horizontal
and a vertical seam (hero, an event by route, the camera), and Zounds 70's
door to 103 reached walking in the ports' tests; the three ports' "Known
issues" lines gone.

## The implementation (Hurón, 2026-10-19)

Taken on 2026-10-19 from the-advocate `2c350d8f`, the ports `1182513`,
the book `7f2ba37`; branches `huron-wrap-maps` in each. The scope is the
proposed one, with these choices made while writing it:

* **Where the record says it**: the fourth byte of the last pointer, the
  ChipSet animation's, which nobody reads (`M_WRAP`, bit 0 across, bit 1
  down), and not a sentinel in `M_CAM_MAX_X`, which `pic_on_map` and the
  clamp of the axis that does not loop still read. Zero in a map that does
  not loop, so ABL's record is the same bytes.
* **The view**: `camera_x`/`camera_y` stay what the window and the scroll
  registers follow, and on a looping axis they become a continuous view
  kept between 2048 and 10240, moved by the camera's change folded the
  short way; when it leaves that range it jumps 4096 —a multiple of the
  window's 512— and `win_col`/`win_row` with it. `WRAP_OX`/`WRAP_OY` are the
  view minus the camera on the map, and every "position minus camera"
  adds it and folds into one lap of the map centred on the screen.
* **The strips** of a map that loops are built by `wrap.s`'s own
  `build_column`/`build_row`, which read the map column of a window
  column from the view and go back to the first row or column at the seam
  with a pointer computed again, instead of the anchor `cells`.
* **Steps**: `cell_neighbor_exists` says yes across a looping edge; the
  target cell, the pointer and `dest_*` of `cell_allowed` are folded into
  the map, and so are the elbow of a diagonal and an event's cell after
  its step; the hero's straight step **across the seam** goes through
  `cell_allowed` as his diagonal already did, and every other step of his
  keeps its `try_*`.
* The far code is called with `jsl` from bank 0, and calls bank 0 back
  through a `rtl` of its own there (`CALL0` in `wrap.s`).
* **Bank 0**: the hooks that do the whole of a routine —the camera, the
  two strips, the neighbour— return from it through a `rts` of wrap.s's
  own in bank 0 (`RTS0`), so each is a bare `jsl`; the hero's drawing folds
  both axes in one call, because two pushed `place_hero`'s `beq no_draw` out
  of reach. Both `CALL0` and `RTS0` jump through a pointer in BSS,
  `WRAP_JUMP`: goombario does not follow one, and the annotations that
  would allow a plain `jml` cannot go there —in ABL's cartridges wrap.s
  assembles nothing, and an annotation that allows nothing is red; that is
  how ABL's linter went red on the first round—.
* **Step 0** went in only for what cannot loop: `map-does-not-wrap` in
  `degradations.json` for an axis of a map narrower than 20x15 cells or
  painted (`wrap_axes` in the converter). No map of the ports is.

**Left out**, as proposed, and written at the top of `wrap.s` and in the
book's `internals/maps.md`: clones of a character on both sides of a seam,
the panorama's rule on a looping axis, a jump across a seam (`can_fall`
refuses it, as before), the action key and an event's bump on the hero
across a seam, and the Y order of characters across a horizontal seam.

### Measured

`just space`, release, bank 0 (before → after): Zounds 218 → 138,
Vampires Dawn 128 → 48, Sunset over Imdahl 108 → 28; BSS 81 → 77 in the
three (`WRAP_JUMP`). Sunset's 28 is the tightest of all now: the next thing
that grows bank 0 will meet it first. A Blurred Line, The Book of Three
and the rest do not change.

### Verified

* **A Blurred Line's nine cartridges**, built with main's tools and with
  the branch's in the same ports worktree: byte for byte the same, twice
  (before and after the last change to the runtime). Its suite with the
  branch's tools, after merging main (the-advocate `f15cca10`, the ports
  `0bf3b43`): 1573 passed, no golden moved. The round before had nine
  reds, all ABL's linter over an annotation in wrap.s that ABL's
  cartridges do not assemble: that is why there is none.
* **The test game's ring** (map 8, `test_wrap.py`): the hero across the left
  and the top edge, with a golden each, and two walkers by repeating page
  routes going more than a lap, one through `cell_allowed`'s faces and one
  walking through everything. Red with main's tools, green with these in
  snes9x and bsnes; the test game's linter, which now sees wrap.s, green.
* **Zounds' map 70** (`test_zounds_wrap.py` in the ports): from map 67's
  entrance (5, 4) to the door at (86, 13) across row 24's seam, and the
  door takes him to 103; and column 65 down across row 49 to row 0. Red
  with main's tools (the hero stops at (0, 24) and (65, 49)), green with
  these. Its four goldens, looked at next to the map's own render tiled
  three by three and cropped where the camera is: the same cells.
* **Not played**: Sunset's bats on map 63 and Vampires Dawn's free fall on
  254 —a jump to either from the boot does not reach the scene: 63 goes to
  map 22 by its own pages, and 254 needs the story's switches (with 743 on
  it goes to 253)—. What they need is what the test game's walkers do.
* After merging main, with the merge's tools (`mapdata`, `convert`,
  `cartridge` and `events`, main's change, installed locally): `just boot`
  from the ports' root, 94 passed, Zounds' two included; the test game's
  suite, 51 passed; `just test`, 29; `crate-test` of mapdata and convert,
  and clippy on both, green. `mapdata`'s Python-comparison test got
  `without_wrap_and_grid_narrow`: the offsets have one more line.
* Captures, with before and after and the check against the map's render:
  `/shared/captures/2026-10-20-maps-that-wrap/`.

### When merging

Reinstall `mapdata` and `convert` (`just install mapdata convert`): the
record's `M_WRAP` and `wrap_maps` come from them. The runtime goes in with
the checkout. Zounds, Vampires Dawn and Sunset over Imdahl change their
ROM. A Blurred Line does not —measured, byte for byte—, and the other
four games carry no map that loops, so they assemble none of it; their
ROMs were not compared.
