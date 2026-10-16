---
name: "Pictures that go over the map, outside Sunset"
description: "In the station bathroom of Desert Nightmare (map 7) a 35% light mask comes out as a large picture and covers the room for about 8 seconds; the map_pictures knob that solves it in Sunset isn't turned on in other games"
type: bug
status: testing
assignee: taro
agents: [Tijereta]
---

Seen by Hurón on 2026-10-06 (`eraseevent-for-real.md`): in the
WC scene of Desert Nightmare (map 7), event 4 is a parallel one
that shows `Lichteffekt_Tankstelle_WC` and erases itself. In RM2k it is a
dark 35% mask over the room; in the ROM "it comes out opaque and covers the
room for ~480 frames: it looks like it hangs, but it continues. It is the
pictures' transparency, not the erasing". Captures from that day in
`/shared/captures/2026-10-06-eraseevent/`.

What is known of the cause: it is a large picture, and a large picture
takes the map off the screen; its transparency darkens towards the black
behind (`divergences/what-large-pictures-do-not-model.md` in the book).
It is the same thing Sunset had with its roofs and fogs, which since
2026-10-11 are drawn inside the map with `[graphics] map_pictures`
(`sunset-the-pictures-over-the-map.md`); that knob is turned
on only in Sunset.

**Not checked today on the console.** Built today (the-advocate `fc6f7456`,
ports `a85b7e3`), Desert's release carries 304 large pictures and doesn't
name this one among those it doesn't draw, so the expected thing is that it
stays the same. How many other pictures in the other games go over the map
wasn't counted.

**How to see it**: `just cartridges release` in `desert-nightmare/`, play
up to the station bathroom (map 7) and compare with the original in Wine.

taro, on 2026-10-16: Desert Nightmare's toilet (map 7) is practically
invisible under the darkness the original lays at 35 %; "I'd try rendering
it at 50 %, if possible".

## Tijereta, 2026-10-16

Starting from the-advocate `30ab0ca6`, ports `f8aca68`, docs `3f105f2`.
Branches `tijereta-translucent-pictures` in the three.

### What the mask is

`Lichteffekt_Tankstelle_WC` is 320x240, 169 colours, 88 % its transparent
colour: the room's rectangle in near-black (`#080805`) with a cone of light
under the lamp. The `ShowPicture` is `[1, 0, 160, 120, 1, 100, 35, 1, …]`:
**fixed to the map**, centred, transparency 35 —opacity 65 %—, no effect.
Nothing erases it: event 4 erases itself, the autostart scene teleports to
map 6 six seconds later, and RM2k erases every picture on the jump. So it
is a mask that stays put on the map for the whole visit, which is exactly
what `map_pictures` draws into the map in Sunset.

### The count, in the eight games

`ShowPicture`s with `0 < transparency < 100` whose file is bigger than
what the objects take (256x128), by the dumps and the games' `Picture/`
(`survey.py`, thrown away):

    game                total shows   translucent   big and translucent
    abl                     348           23             7
    book-of-three            11            0             0
    desert-nightmare       1249          353           353
    dooms2                   27            0             0
    el-dorado               113            0             0
    frozen-world             18            0             0
    sunset-over-imdahl     1143          693           689
    vampires-dawn          4274           73            73
    zounds                 not dumped on the branch

Desert's 353 are **its lighting**: ~150 `Lichteffekt_*` files, one per
interior or night map, fixed to the map, at transparency 20 to 65 —most 35
to 45—, never erased in their page, plus `GO_Text` and `Intro_Text*` fading
over the screen (150 of the shows, at 25/50/75, on the game-over and intro
maps). ABL's seven are 217's montage and 311's hovershadow, which
have their divergence already; Vampires Dawn's 73 are not looked at here.

### What the console has free: no layer

In mode 3 a map takes BG1 (the ChipSet, 8bpp) and BG2 (the layer above the
hero, the message window and, when it has one, the panorama); the objects
are the characters and the small pictures. **No layout leaves a background
free** for a mask that colour math would blend: every one of the twelve in
`vram.rs` gives BG2 to the layer above and the window, and colour math is
per layer —flagging BG2 would make the roofs translucent too—. The objects
cannot cover the screen (a 256x224 unique texture is 896 tiles against the
512 the PPU names, and 32 slivers a line leave the characters out). What
the hardware can do without a layer is the colour window —two spans a
line, by HDMA, with the fixed colour—: a spotlight, no gradient, and only
for masks of that shape. Mode 1 for a ChipSet map would need its tiles at
4bpp, which is the decision "mode 3 by default" was made against.

So the mask is **drawn into the map at its RM2k opacity**, the way Sunset's
are —`[graphics] map_pictures = true` in Desert's project—, which is exact
for a mask that stays put and loses that the characters are not shaded.
Not colour math at 50 %: see the measurement.

### Measured against RPG_RT 2015 under Wine (15 bits)

Map 7 of the original, started on it with Sandra in the party (a copy
edited with ditto), captured on `:91`, against rm2k-render's layers of the
map with the mask laid over four ways, over the mask's pixels and without
Sandra's cells (`measure/compare.py`, thrown away; error in 5-bit levels):

    blend                        mean |err|   RMS    mean luma (orig 4.75)
    no mask                        7.21      7.61     11.93
    baked at 65 % (map_pictures)   0.35      0.59      5.10
    half, (map + pic) / 2          1.76      1.90      6.50
    half with black, map / 2       1.71      2.07      5.73
    subtract a constant (best 8)   1.73      2.45      4.06
    subtract 0.5 x the mask        1.82      2.31      3.19

Baked is five times closer than any colour math; among those, 50 % and a
subtract are the same error, each about two levels off in the opposite
direction. The 0.35 that is left in "baked" is rounding and the capture.

### Done

* `wally`'s `map_pictures::compose` blends a translucent map picture into
  the **layer above the hero** too, where it has pixels: with only the
  lower one, the WC's top wall edge stayed lit under the mask (seen in
  Adeleine's `0007-encima.png`). Opaque ones go into it as before.
* Desert's project: `map_pictures = true`; a case `wc` —Sandra in the
  party, teleport to 7 (8,8)— to see the scene in the harness.
* Built with the knob and the global tools first: "pictures drawn into
  their map: 162 in 127 of the 189 maps"; map 7 keeps 133 unique tiles of
  1200 cells and 94 colours of 96; degradations 6072 -> 6079 (two more
  `picture-move-not-done`, two `events-wait-for-a-slot`), 410 -> 427
  warnings; the whole release builds.

* On the console, with the case `wc`: the room is visible under the
  darkness with the lamp's cone, the scene plays and jumps to map 6. The
  capture against the original's, over the mask and without Sandra:
  **0.35 of 31 levels**, the same as the software blend (`rom_vs_orig.py`).
  Sandra is lit on the console and shaded in the original: the divergence
  already declared for Sunset.
* The converter lists, map by map, what it drew in ("map 7: drawn into the
  map: 'Lichteffekt_Tankstelle_WC' at 65 %"), and the translucent big
  pictures the rule cannot take —placed by a variable, zoomed, moved by a
  `MovePicture`— go to `degradations.json` as
  `translucent-picture-hides-the-map`: Desert's release has 171, 132 of
  them `GO_Text` —eight copies the death scenes bring in from off the
  screen—, and the flashlight on 82.
* **A bug of the rule, found by Desert and fixed**: a screen-fixed
  translucent picture on a map that scrolls was repeated over the map
  without looking at whether a `MovePicture` moves it, so map 137 —20x19—
  got `GO_Text` drawn in six times over. Now that branch refuses a moved
  one too; Sunset has no moved mist (`moved_mists.py`: 0 of 13), so it
  loses nothing. Three unit tests on `placed`. With it, Desert's release
  draws in **155 pictures in 126 of the 189 maps**, and lists 191
  `translucent-picture-hides-the-map` (158 moved, 32 by a variable, 1
  zoomed). Map 172 still gets `Sandsturm` at 50 % drawn in —one of its two
  shows stays put— and the moved one as a big picture over it: not looked
  at in an emulator.
* The test game: map 5, the lantern, with `Picture/Night.png` —ours, a
  near-black mask with a cone, 64 indices— laid over it by a parallel
  event like Desert's; `[graphics] map_pictures` in its project; the case
  `lantern` and `test_map_picture.py` with two goldens, in the dark and
  under the lamp with the camera scrolled. Red with the tools before the
  change: the crowns stay lit under the mask. Against RPG_RT 2015 under
  Wine, started on map 5: the same mask, the hero shaded there and not
  here.
* The book: the divergence "Pictures drawn into the map" (the ChipSet
  side, why not colour math, the measurement), "What large pictures do not
  model" (Desert, the degradation), Desert's page (the Known issue out, a
  dated section, the unshaded characters as a known issue), the test
  game's page.
* Captures, with a README: `/shared/captures/2026-10-16-translucent-pictures/`.

### What was run

With the branch's tools (`just install-local .local-tools wally convert`):

* `just test`: 29 passed (after tracking the new files: the assets test
  reads `git ls-files`); `just rust-test`: green; the converter's three
  new unit tests.
* `just test-game`: 28 passed, 1 skipped; the two new goldens in snes9x
  and bsnes. **Red with the global tools** (30ab0ca6): `lantern-dark`
  differs in 366 of 57,344 pixels, the crowns.
* ABL, in the ports worktree: `just cartridges` and `just tests`, **1,555
  passed, 2 skipped**, no golden moved; `abl.sfc` 92bacc160263d34b (first
  sixteen of its sha256). ABL has `map_pictures` off, so its ROM does not
  go through the changed code.
* `just boot` at the ports' root: **45 passed** —the eight games' boots,
  Sunset's painted maps, The Book of Three's playthrough—, no golden moved.
* Not covered by any suite: Desert's own maps other than 7 with their
  masks drawn in —126 of them— were not looked at; map 172's `Sandsturm`
  (above) in particular.

### Branches

`tijereta-translucent-pictures` in the-advocate (two commits: the code
and the test game, then its goldens), the ports (Desert's project and the
case) and the docs (the book, with `main` merged); this task here.

### To install when merging

`just install wally convert` from `~/the-advocate`. Sunset converts the
same (the panorama branch of `compose` is untouched, and no mist of its is
moved); ABL has the knob off.
