---
name: "Maps that wrap around"
description: "A map with Wrap (scroll_type) is a torus in RM2k —hero, events, camera—; the console stops everything at its edges. Twelve maps of Zounds, Vampires Dawn and Sunset use it; on Zounds 70 it hides a room"
type: feature
status: todo
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
