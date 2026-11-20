---
name: "Desert Nightmare: nights with a tint of their own"
description: "The night maps (59, 61, 62, 66…) show as day on the console: their night is two full-map pictures. Patches that make the night an RM2k tint, and a study of how to light it within the console's limits"
type: feature
status: testing
assignee: taro
agents: [Hurón]
game: desert-nightmare
---

taro, on 2026-11-19, looking at the captures of
[`still-pieces-painted-into-a-painted-map`](still-pieces-painted-into-a-painted-map.md)
(`/shared/captures/2026-11-19-dn-painted-pieces/`), translated:

> The map002 screenshot, for example: the before and after are much
> brighter than EasyRPG's. I see the same in 59, 61, 62, 66. In the map002
> capture in particular there is no light source.
>
> Anyway, if it is not a tint per se but an image, I prefer using map
> patches to use a normal RPG Maker tint, and analyse how we can solve the
> lights creatively, with their acceptable limitations.

**What Hornero saw** (the dump at the ports `aa850b4`): maps 59, 61, 62 and
66 are the night versions of the town. A parallel page (`EV0136` on 59,
`EV0143` on 62, `EV0166` on 66, `EV0188`/`EV0191` on 61) shows two
full-map pictures: `Lichteffekt_*_Nacht` at transparency 20 and
`Nacht_*` at transparency 0. On the console those maps look like day:
EasyRPG's 59 is the night street with lamps lit, ours the day street. That
was so before the painting too. Map 2 has no night pictures: its autostart
does a `TintScreen` to black and back to 100 in 3 s; EasyRPG's capture is
darker and greyer, and the harness's jump clears the tint (Hurón's study),
so map 2 may be a capture artefact or a tint from a common event: measure
it.

**What**:
1. Why the night pictures are not drawn (map pictures on a painted map,
   pages behind conditions, the "one shown most" rule…), and map 2's
   difference.
2. Patches of the night maps (`patches/manual/`, like ABL's map 13 and
   105 forks) that replace the night pictures with an RM2k `TintScreen`
   matching `Nacht_*` as closely as a tint can (measure it at 15 bits),
   kept as a patch of the game's data, not a converter rule.
3. A study of the lights, creatively and within the console's limits:
   lamps' cones and lit windows over a tinted night —baked into the
   painting as lit cells that the tint does not reach, sprites, colour
   math on BG2, per-map or per-cell character shading—, each measured
   against RPG_RT/EasyRPG, with what it costs. Then a recommendation.

## Log

**2026-11-19, Hurón.** Worktrees: the ports `huron-dn-nights` from
`aa850b4` in `~/scratch/huron/the-advocate-ports`; the tools are the global
ones (the-advocate `4f38ea03`), nothing installed.

### 1. Why the night is not drawn

Swept every `ShowPicture` of a `*Nacht*` picture in the dump (48 maps
name one). The night is never a tint: it is `Lichteffekt_*_Nacht`, a
near-black mask (9,9,9 with the cones in a gradient) at transparency 20
—35/45 indoors—, and on the towns `Nacht_*` over it at 0, a transparent
canvas with only the lit windows and bulbs. The night panoramas
(`Nacht_Eingangsbereich`…) are the day ones with a few lamps changed.

* **Drawn into the map already, lights and all**: every one-screen map
  (60, 63, 64, 65, 67, 72, 121, and the 30-odd interiors with a mask
  only): their `ShowPicture` gives the place as constants, and
  `map_pictures` takes them ("drawn into the map: … at 80 %, 'Nacht_…' at
  100 %" in `converter.log`).
* **Not drawn at all**: the eight maps that scroll —32, 59, 61, 62, 66,
  68, 69, 70—. There the page reads an anchor event's screen position
  into variables 14 and 15 (`ControlVars`, operand 6, fields 4 and 5),
  adds or subtracts a few pixels and shows the picture at those
  variables. `placed()` in `map_pictures.rs` refuses a place "by a
  variable", and the picture falls back to a big one that does not fit:
  "the picture 'Nacht_Eingang' is 369x272 on the console: bigger than the
  plane of objects". So the map is the day panorama, untinted.
* Nothing erases those pictures and no page tints: RM2k 2000 erases a
  picture on a map change (easyrpg's default `flags = 1|32|64`,
  `erase_on_map_change`), and each night map shows its own again.
* 25 maps in all lose a light mask that way ("its place is by a
  variable" in `degradations.json`); the other 17 are day interiors and
  the mines. Not this task: draft
  [`desert-nightmare-light-masks-placed-by-an-anchor`](desert-nightmare-light-masks-placed-by-an-anchor.md).
* **Map 2** is the capture's timing: its autostart tints to black, waits a
  second and tints back to 100 in 3 s. EasyRPG at 6 s from launch is
  halfway (mean 51 against 125 over the map's part of the screen), from
  8 s as bright as the console, at 10 s the first message box. And its
  lamp is off in the original too: it is day.

### 2. The patches

The fit: RM2k's night composed over the panorama in software (the mask at
its opacity as easyrpg blends it, the windows' picture with its
transparent colour, placed at the anchor's screen position less the
page's subtractions) against `apply_tint`'s computation over the same
panorama, at 15 bits, without the panorama's holes and the windows.
(25, 25, 25, 85) on the streets (59, 62, 66, 68: 0.21 to 0.78 of 31 over
the map, 0.12 to 0.21 over the dark), (29, 29, 29, 60) on 61 (1.5),
(43, 39, 40, 100) for the motel's masks at 35 (69, 70) and (50, 50, 50,
100) at 45 (32). Cones 3.7 to 4.8 and windows 19 to 23: what a tint
cannot do.

The forks: `desert-nightmare/patches/manual/maps/` in the ports, with a
README. The mask's `ShowPicture` → that `TintScreen` (time 0, no wait),
the `Nacht_*` one removed, and a neutral `TintScreen` before every
`Teleport` —RM2k keeps a tint across maps, easyrpg's
`Game_Screen::OnMapChange`—; every one of those pages has its
`EraseScreen` before already (the doors erase, wait, teleport, show), so
no `EraseScreen` was needed. The JSON is written in the dump's own style
(a value on one line if it is 84 characters or fewer): `diff` against
`data/maps/` shows only the changes. The same edit on the game's `.lmu`
(`ditto read`/`write`) into a copy for EasyRPG; `ditto unpack` of that
copy gives the same commands as the forks.

Measured, the console against EasyRPG at 15 bits, aligned:

    against                        59    61    62    66    68    69    70
    the original, before          12.4   8.6  11.6  10.3   9.8   2.5   2.7
    the original, with the forks  0.90  1.36  0.87  1.08  1.37  0.69  0.58
    EasyRPG with the same forks   0.10  0.26  0.10  0.08  0.10  0.07  0.05

EasyRPG through the door 59 → 60: identical with and without the forks.
The build: 25 degradations fewer (1,108 → 1,083), the pages all compile.
New test `tests/test_desert_nightmare_nights.py` (map 59 tinted and
dark): red on `aa850b4`'s build, "the tint is [100, 100, 100, 100]",
green with the forks. It covers 59 only.

### 3. The lights

Measured in software over the panoramas (scripts `night.py` and
`lights.py` in `~/scratch/huron/nights/`), not on a console; the numbers
and the costs in the book's study. In short, over the cones, of 31: the
tint 4.0 to 4.8; lit cells in palettes the tint skips (L1) 0.12 to 0.24;
the light added by colour math on a 2-bit BG3 (b) 0.50 to 0.60; HDMA
windows with a fixed colour (c) 0.74 to 1.03 (61 has 38 lines with three
cones or more, 69 14); the darkness subtracted (a) 1.3 to 5, and 1.4 to
3.3 over the whole map. Sandra in a cone: 6 to 8 off with the tint or
L1, 0.3 to 1.2 with (b). (b)'s costs: 70 to 222 2-bit tiles and a 2 KB
tilemap where the painted layout has 1,024 words free at $5C00 and 528 at
$4DF0; BG3's palettes are CGRAM 0 to 31, the window's and the painting's
palette 1; the night maps' characters use 1 to 6 object palettes (5 or 6
on 32, 59, 61, 69). Every HDMA channel has a use (0/7 DMA, 1/2 the
window, 3/6 its swaps, 4 big pictures, 5 a face). A cone as sprites: 64
tiles each, and 59 and 61 already use 252 of 256.

Recommended: L1, which needs the converter to resolve the anchor (as the
draft does) and a per-map number in the runtime; then (b) if the
characters matter. Neither is small: task
[`desert-nightmare-lit-cells-over-a-tinted-night`](desert-nightmare-lit-cells-over-a-tinted-night.md).

### Delivered

* the ports `huron-dn-nights`: `b61ee79` the forks, `6d16d18` the test.
* the book `huron-dn-nights`: `b90dde7`, the study
  (`ports/desert-nightmare/research/2026-11-19-nights-with-a-tint-of-their-own.md`),
  SUMMARY, the port's page (a section and two Known issues).
* captures: `/shared/captures/2026-11-19-dn-nights/`, with a README.
* `just boot` in the ports, on the branch: 169 passed (18 min).
* Nothing of the-advocate changed: nothing to install. ABL's suite not
  run (no tools or runtime touched).

**To look at, playing**: the night town dark and evenly tinted, without its
lamps and windows (the Known issue), and the maps behind its doors —the
bar at night (60), the store (74), the alleys (63 to 65, 67)— exactly as
before: lit by their own pictures, not doubly dark.
