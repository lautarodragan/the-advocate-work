---
name: "Large pictures, on BG1 in mode 1"
description: "Phase 3 of the picture system: the ones that cover the screen with the map hidden (the Diff photos, the instructions on 49 and 285, GTest4 with waves, the ending on 309) on BG1 switched to mode 1 while they are shown"
type: feature
status: done
assignee: taro
---

Phase 3 of [`research/2026-10-01-the-picture-system.md`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-01-the-picture-system.html) (Jilguero),
option E. taro decided it on 2026-10-01:
`decisions/large-pictures-in-mode-1.md`. The Diff photos (212 to 216),
which in RM2k shrink with a zoom, are shown with a fade: the SNES does not
scale without mode 7. What happens in those scenes, with captures from the original:
`/shared/captures/2026-10-01-escenas-diff/` (Bandurria).

Done by Aguilucho, from `main` at `83c7e3ee`, with `main` merged at
`635c3704` (the automatic common events and the shared `CallEvent`, by
Picaflor). **It awaits taro's approval of the goldens** —a commit with only
goldens— and of the choice for the montage on 217, and for him to play it: the
race card on 49 is in `release`.

## The design

**The converter chooses the plane** (`tools/port/picture.py`): a picture
that does not fit in the objects goes to BG1 if it goes with the screen, or if it goes with the
map and covers the whole screen —the photos from 212 to 216—. The hovertram on
32, stuck to the map with the scene around it, is still not drawn: on BG1 it would
take the whole map while they talk. The large ones **belong to the cartridge and
not to each map**: they go in a table, `big_table`, and the same picture on two
maps is one.

**The conversion** is `rm2k-snes-images background`: the picture drawn
where its `ShowPicture` puts it, on a canvas as wide as the screen —taller
if it goes past the top or the bottom and the tiles are enough, so that
`MovePicture` can raise it: the instructions on 285—; Adeleine allocates
the colours into seven palettes of fifteen (0 belongs to the window) and Voodoo
cuts the 4-bit tiles. The tiles go **raw** in the cartridge, and the
tilemap in LZ2: see below.

**The runtime** (`tools/runtime/big_picture.s`, bank 1): showing it turns off the
screen, sends the tiles by DMA from the cartridge to `$0000`-`$3FFF` and the
tilemap to `$4000` —the same place in the six allocations, see
`docs/port/vram.md`—, moves the window's tilemap to `$4800`, empties that of
the upper layer and switches to mode 1 with BG1 and BG2, without sprites. The message
window, which is BG2, stays the same, on top. Erasing it goes back to mode 3 with the
same reload as the return from battle (`big_back_far`, in `picture.s`).
While it is there, the vblank does not upload poses, map strips, the ChipSet
animation or the tint.

* **Tone and transparency** are the palette, with the tint's tables; the
  transparency **darkens**, because underneath there is only black. Saturation
  comes free from `build_palette`: that of 288 and 208 is there.
* **The zoom that shrinks is a fade** to black, over the zoom's duration.
* **`MovePicture` raises or lowers it** with BG1's scroll: the console
  computes the corner like RM2k, with half the height of the picture that is there.
  It does not move sideways.
* **The waves**: an HDMA channel (4) on `BG1HOFS`, with two tables in
  bank `$7F` that take turns so as not to write the one being read.
  Exact with easyrpg-player's `WaverBlit`: depth, phase of 8 per
  frame, RM2k's period of 32 lines. What a wave brings in from beyond
  the side, for a picture wider than the screen (`GTest4`), is
  its mirrored edges; for one that is not (`ShipFlash`), black, like RM2k.

**What it costs**, measured: showing one, two or three frames of screen in
black; erasing it, fourteen. The tiles were in LZ2 at first, and decompressing
thirty kilobytes —and then the bytecode brought from another map, which lives in
the same buffer— was ten: that is why they go raw (some 200 KB for the nine; the
cartridge has 43 free banks).

## Which scenes are drawn

    49    EscapeInst         release: 49's fork was deleted, see below
    212   PhoneCallDiff      test case, with the fade
    213   SurlBroDiff        test case
    214   SurlGravesDiff     test case
    216   ThreeRubbleDiff    test case
    285   AdvoInstr          test case: goes up 93 lines in 4 s
    309   ABLEndBox8         test case: goes up and comes down from black
    208   GTest4             test case: waves 6 -> 1 -> 4, and 8 saturated
    267   GTest4             it is 208's second, with another message
    288   ShipFlash, GTest4  test case: saturated, waves 2
    217   the montage        test case: the two options, below

Maps 207 to 217, 285, 288 and 309 are not in the cartridge;
each case in `rom/pruebas/casos/imagen-grande-*.json` copies its scene's commands
into a page that jumps to map 12. 32 (`hovertram2`) is still
out, on purpose: see the design.

**49's fork was deleted** —`rom/parches/manual/mapas/Map0049.*`—, as
its README said: it changed the card for two messages because the ROM had
nowhere to draw it. Now the game's page runs, with its `KeyInputProc`. The
race walkthrough photographs the card once (`01-el-cartel`) instead
of twice, and its pending photos were renumbered.

## The montage on 217

Four photos at 50 % every six frames, with a white flash. The two
options, captured frame by frame in
`/shared/captures/2026-10-02-imagenes-grandes/montaje-217/`:

* **The photos**, which is what the converter does today: each one is loaded with
  the screen off, so it is **five frames of photo and three of
  black**, without the white —the flash does not show over the picture—. At 50 %
  over black it is the photo at half colour, which is what RM2k shows over the
  map in black.
* **Only the flashes**, without the photos: 217 in black with a white that
  fades every six frames. To choose this one the converter would have to
  leave out that map's pictures.

What was not tried: the four photos **at once** in VRAM, at half
size (128x112, some 224 tiles each, 896 the four), changing only
the scroll from one to the next: they would fit without turning off the screen, but it requires the
converter to know they are shown together.

## The tests

`rom/pruebas/rpgmaker/test_imagenes_grandes_golden.py`, against goldens:
each scene at two or three moments, the card on 49 with the game's
page, and **the return**: a picture shown and erased over Sorbe Village —the
allocation that overwrites the most, with the background's tilemap below the picture—, which
has to stay identical pixel by pixel, at 15 bits, to the same case without the
picture at the same tick. **Seen red** by removing `fill_window` from
`big_back_far`: 9,727 pixels.

`test_cores.py` adds three: a photo halfway through the fade, the waves and the
return, in snes9x and bsnes.

`cargo test`: the compiler (`a_big_picture_goes_up_scrolls_fades_and_comes_down`),
the conversion (`background::tests`) and the tilemap with its mirrored edges
(`rm2k-snes-mapdata/tests/big_pictures.rs`).

**The two hashes of `rm2k-snes-mapdata/tests/python.rs` change on purpose**:
the `.inc` carries the large pictures section, seven extra lines
even when there are none.

## The goldens

In their own commit, only goldens: twenty-three new ones, none moved. Side
by side with the original RPG_RT under Wine —and for the photos, with
Bandurria's captures— in `/shared/captures/2026-10-02-imagenes-grandes/`.
**The merge awaits taro's approval.**

What looks different from the original, noted in
`divergences/what-large-pictures-do-not-model.md`: the fade instead
of the zoom, the black frame of the instructions on 285, the mirrored edges
of `GTest4`'s waves, the 105 colours, and the black frames when
showing and erasing.

## For merging

* **Reinstall in the global**: `just -f tools/justfile install images events
  mapdata cartridge`. The Python side added or renamed no script.
* **The opcodes**: `OP_BIG_SHOW` (`0x3D`) and `OP_BIG_MOVE` (`0x3E`), which
  replaced Picaflor's `OP_RESERVED_3D` and `_3E` when merging `main`;
  `0x39` to `0x3C` are still reserved.
* **Today's numbers**, on the merged tree: `just tests` gives **1000**
  (988 from `main` plus 12 new), `just -f tools/justfile test` **39**,
  `cargo test` of events, images and mapdata green. `NO_CACHE=1 just
  cartuchos` and the cached build give the same three cartridges; `abl.sfc`
  is `6643d2c1…`. `test_music_ceilings.py` stayed green.
* **Space**, `just space` on `release`: bank 0 with 1,063 B free,
  **bank 1 with 131 B** —the large pictures' code is there, and
  Picaflor's common events too—, 43 free data banks.
* **Far RAM**: the one assigned to me, `$2570`-`$257F`, is the end of
  `FAR_PAIR_LIST`. I use `$25E0`-`$25EF`, between the music and
  `FAR_SPEED_BONUS`. And in bank `$7F`, while there is a large picture,
  `BIG_PAL` and the two wave tables at `$7F6000`-`$7F64FF`, over the
  ChipSet animation's drawings, which the map load restores:
  `test_wram_reservations.py` names them.
* **HDMA channel 4** belongs to the waves: no other code used it.
