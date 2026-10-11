---
name: "Several pictures in sprites"
description: "The object plane of the picture system: ShowPicture, MovePicture and ErasePicture with several pictures at once, for the girls over the map, hiding the events if there's no room"
type: feature
status: done
assignee: taro
---

Phase 2 of `docs/research/2026-10-01-el-sistema-de-imagenes.md` (Jilguero),
from taro on 2026-10-01. The BG1 plane in mode 1 for large pictures
is phase 3, separately: taro approved mode 1 only while a large picture
covers the map (`decisiones/las-imagenes-grandes-en-modo-1.md`).

Done by Gallareta, from `main` at `71782626`, with `main` merged at
`7d4c1c7b` (Label and JumpToLabel, by Pitogüé). **It awaits taro's approval
of the goldens** —two goldens-only commits— and for him to play it.

## For merging

* **Reinstall in the global**: `just -f tools/justfile install events images
  wally mapdata cartridge` —`map-sprites` is a library of `wally`—. The
  Python side didn't add or rename any script.
* **`rom/parches/manual/mapas/Map0081.*` was deleted**: the fork of 81 replaced
  the sign with a message "until the ROM carries more than one picture".
* **The translucency experiment is its own commit**, `Imágenes: el
  experimento de la translucidez…`, with its goldens in the one that follows:
  to remove it both are reverted, and the divergence's text goes back on its own
  to the opaque version.
* Today's numbers, on the merged tree: `just pruebas` gives **981** (969
  from `main` plus 12 new), `just -f tools/justfile test` **39**, `cargo
  test` of events, images, wally, map-sprites and mapdata green.
  `NO_CACHE=1 just cartuchos` and the cached build give the same `abl.sfc`,
  `57ce2e2a…`. `test_musica_techos.py` stayed green.
* Far RAM: `$30EC` to `$30FA` —the previous picture's— and `$2580` to
  `$258F`, the one allotted to me. No new opcode: `OP_PICTURE`,
  `OP_PICTURE_MOVE` and `OP_PICTURE_ERASE` changed operands.
* Space, `just espacio` on `release`: bank 0 from 1,053 to 1,340 B
  free (the code moved out to bank 1), bank 1 from 3,204 to 2,000 B.

## The design

**Each map carries in its sprite bank the pictures its pages can show
and the test pages that run in it**, after its
characters, and they're uploaded with the bank: showing a picture uploads only its
palette, and returning from the battle or the menu finds them where they were. The
path:

1. The compiler's scan gathers per map the keys of each `ShowPicture`
   the console can do —`PictureKey`: number, name, zoom, transparent
   colour, with the map, by variables, and the position only if it changes
   the pixels—. It compiles each page with everything a real
   compilation has: with the scan's, without songs, the sign in 81 was left
   behind a `PlayBGM`. And with the counters, so that Fortitude's digits
   remain the counter's.
2. `picture.py` converts each one with `rm2k-snes-images picture`, which now
   knows about zoom, the transparent colour —index 0— and the ones that go with the
   map, which **aren't scaled** to 256x224 because the map isn't either; it gives them a
   slot per number —the first two— and cuts them into 32x32 objects,
   without the empty ones.
3. `wally` puts them at the end of the bank, with **one palette per slot from
   7 down** —they're the ones the console can blend—. If the battle animation's
   box leaves no palettes, or if with them the map doesn't fit
   in any VRAM layout, it removes them and says so; their commands are accepted
   without being carried out.
4. The compiler receives each map's table; `rm2k-snes-mapdata` emits
   `picture_maps` and `picture_data`; the runtime (`picture_far.s`, bank 1)
   computes the corner when showing it —four fifths and fourteen fifteenths,
   rounding down with negatives, like `Screens::place`; for the map ones, RM2k's
   view centred on the console's camera— and draws after the
   counter.

**Two slots.** That's what the scenes over the map ask for: the maximum at the same
time is the counter's label and its two digits, which belong to the counter. The
phase 6 console asks for nine; the RAM there was is thirty-one bytes, and
with two slots `MovePicture`'s ramp is a single one for all —a new one
ends another slot's—.

**Option B (hiding the events) isn't there.** In the cartridge only the
hovertram of 32 would ask for it —165x151, it doesn't fit in any layout with the
characters—, and its scene is Talan, Arden and the guards talking around
the tram: hiding them is hiding the scene. ABLEndBox8 (309) goes over the
map in black: it's phase 3's.

## What's done with each option

    position by constant              yes
    position by variables             yes (two variables, read when shown)
    with the map (fixed_to_map)       yes, unscaled: the map isn't scaled
    transparent colour                yes, index 0
    zoom                              yes, shrinking; enlarging doesn't compile
    tone, and its ramp in MovePicture yes, like the sign before
    transparency                      three steps: ≥76 % not visible; 25-75 %
                                      at 50 % with the experiment, opaque without it;
                                      <25 % opaque
    MovePicture of place or of zoom   no: doesn't compile, accepted without being done
    rotate, wave, saturation          doesn't compile
    erase on changing map             yes (`pic_clear`)
    return from battle and menu       yes: the menu covers them, and they come back as
                                      they were

The debts, in `divergencias/lo-que-las-imagenes-en-sprites-no-modelan.md`.

## The scenes

The ones drawn now in `release`, against the study:

    4    Oneyearprev     already there
    81   MeanwhileLashe  new; the map's fork was deleted
    95   Fortitude       new, above the counter
    311  hovershadow     new; with the experiment, at 50 % like the original

The ones that still don't fit, with their why:

    45   ABLrec          seven character palettes and the animation's box:
                         there's none left for the picture
    32   hovertram2      165x151: doesn't fit with the characters, and B covers it
    98, 207, 285, 295    their maps aren't in the cartridge; the converter would
                         do them anyway (207 is the by-variables case, with
                         the map and at 40 %)
    309, 49, 285 Advo…   large: phase 3

Of the 11 of 21 that the study gave to A and B together, 5 are in the cartridge and
4 are drawn.

## The tests

`rom/pruebas/rpgmaker/test_imagenes_golden.py`, against goldens, in map
12 —4 runs the opening on top of the test pages—. Each command
seen red with a mutation of the runtime, measured: the two slots in the
same palette (325 pixels), the ramp's transparency not saved (674),
the x variable read for the y (1,172), and the map one drawn as a
screen one (349). The return from battle **doesn't cover** the restoring of
the palettes: troop 82 doesn't reach palettes 6 and 7 —cutting the
restore before those leaves it green—; it covers the pictures
coming back. The `pic_restore` I had written for that was removed: the battle already
restores the high palettes from `cgram_shadow`, where `pic_palette` leaves them,
and the menu doesn't touch them.

The scenes are called with `CallEvent` on the map's page
(`escena-81`, `-95`, `-311`). Compared against the 2015 RPG_RT under Wine,
with a copy of the game that starts in the map with the autorun page and
no conditions —built with `ditto`, see Gallareta's scratchpad—: the
shadow falls in the same place on the map, (39,59)-(140,179) there and
(40,60)-(138,178) here.

`test_cores.py` adds three: two slots, the ramp and the map one with the
camera shifted, in snes9x and bsnes.

And `test_recorrido_sorbe_golden.py` takes the photo of the sign when it's
up and still, instead of when the fork's message is composed.

## The goldens

Two goldens-only commits. Side by side —before, after and RPG_RT— in
`/shared/capturas/2026-10-01-imagenes-en-sprites/`, and the two for
translucency —opaque, blended, original— in `…/translucidez/`. No
existing golden moved.

## What's missing

* More slots, for the console: it's RAM.
* Moving and enlarging with `MovePicture`: the position ramp is RAM too.
* Letting a picture share a character palette that has room, for
  `ABLrec` in 45.
* The pictures above the message window: in RM2k the window covers
  them.
