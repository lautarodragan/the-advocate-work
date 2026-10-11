---
name: "The panoramas"
description: "RM2k's parallax backgrounds on the SNES: the study, the prototype on the bridge, and every map with the path the converter picks on its own"
type: research
status: done
agents: [Cardón]
assignee: taro
---

From taro, on 2026-10-05: the panoramas show up black. Some can be solved with
creative patches —the emitter room as an animated tile or CharSet, the window
of the director's office and Talan as a ChipSet—, but others "are pretty
important … above all when they do have a parallax effect and move at a
different speed from the map". The ones he named:

* the bridge, above —"it only has events drawn over the sky… two layers should
  be enough", and "the same applies to the whole upper part"— and below —"it
  needs 3 layers no matter what, because the floor is like a grate, with
  transparent portions, and talan and the chests are there … the background
  moves differently … and it scrolls constantly"—;
* the Lashe City rooftop, escaping from the agents;
* the intro with Kersh: the night sky with clouds, and rain.

# What was done (Cardón, 2026-10-05)

The study is in `docs/research/2026-10-05-los-panoramas.md`: the 45 maps with
a panorama measured —how much of it shows, how it moves, what they have above
the hero, what they lose on each path—, the rooftop and the intro, and the
cost.

The prototype works on the two bridge maps, which in ABL are turned on with
`[maps] panoramas = [259, 255]` in `rm2k-snes.toml`:

* **259, above, in mode 3**: the panorama on BG2 at 4 bits, with the palettes
  the background leaves. It lands on the same pixel as in RPG_RT.
* **255, below, in mode 1**: the map at 4 bits on BG1, the overlay layer and
  the window on BG2, and the panorama on BG3 at 2 bits, moving on its own
  diagonally.

What came out, in short:

* B as requested works for 255 and not for the RTP ones: at 2 bits the clouds
  end up in 4 colors. **It almost always pays to use mode 3 with what's above
  drawn below**: on the Lashe rooftop (33) it's two cells. It's in `wally`
  for measuring (`"mode": 3`), not in the project;
* one-screen maps that don't move —the director's office, among others— can
  be **baked** into the background without a layer: that's also the window's
  patch;
* **the rain already coexists** with the panorama: it's made of objects. In
  mode 1 it goes up one priority, like all objects.

RAM: `$7E7E00` to `$7E7EDF` of the far one, between the growth and
`CARRY_MAP`. Opcodes: none (`0x46` wasn't needed).

## To play

On 259 and 255: walk the bridge end to end looking at the sky and the sea, and
below stand still to watch the water slide. What most needs testing by hand,
because no test in the suite does it: **opening the menu, saving and fighting
from 255** —mode 1 has to go back to 3 for the screens and to 1 when closing
them—. I tested the menu and a battle with a throwaway case and they work;
saving and loading, no.

## The goldens and the patches

Five goldens change, all from these two maps —`capitulo-259-llegada`,
`capitulo-255-llegada` and the three of `texto`—, and each one's versioned
patch (`parches/auto/mapas/0255.toml` and `0259.toml`: the grate at 4 bits
merges 17 colors). **The goldens aren't blessed**: they go side by side with
the original in `/shared/capturas/2026-10-05-panoramas/`. The patches are
regenerated, in their commit on ABL's branch.

## When merging

Reinstall the Rust that changed and what compiles it in: `voodoo`, `adeleine`,
`rm2k-render`, `wally`, `images`, `screens`, `mapdata` and `convert` —`just -f
tools/justfile install voodoo adeleine rm2k-render wally images screens
mapdata convert`—. The runtime is built by `rm2k-snes-cartridges` from the
checkout.

# All of them

taro, on 2026-10-05, after the prototype: "let's go for all of them". The 45
maps with a panorama, each with the path the study assigned it, and what the
study left pending.

## What was done (Cardón, 2026-10-05, second round)

**Wally picks the path, map by map**, with what the map and its panorama say
and nothing else: `Way` in `background/panorama.rs` and `convert` in
`wally/src/layers.rs`. In order: hidden if the lower layer covers it entirely;
baked into the background if it doesn't move relative to the map —one RM2k
screen, without its own scrolling or `ChangePBG`—; mode 3 if the map draws
nothing above the hero; **flattened** if it draws little —what's above goes to
the background, and the 8x8 cells it covers more than half of go to BG1's
priority 1, in front of the hero—; mode 1 if it draws more; black if nothing
fits. "Little" is `ABOVE_LOST_MAX`: at most four RM2k cells' worth of pixels on
the wrong side of the hero. `conversor.log` says each map's path and why not
the previous ones; `parches/auto/mapas/` writes it in `[panorama]`.

**`[maps] panoramas` is gone.** What remains is `[maps] panorama_ways`,
optional, which forces a map's path by its name: it was useful for measuring
—forcing 6 flattened, 255 in black— and ABL doesn't use it. Why not the list:
taro asked for the choice to be the converter's, and a list of maps is exactly
what doesn't generalize to another game.

What it picked for the `release` ones —see `conversor.log`—: hidden 8 and 76;
baked the director's office and its own (19, 34, 43, 45, 82) and those of
Pierson's memory (175, 176); mode 3 for 13, 16, 51, 64, 94, 99, 259 and 313;
flattened the intro (1), 2, **the rooftop (33)**, 95, 109 and 126; mode 1 for
3, 6, **the Hover-Tram terrace (32)**, 105 and 255. The 17 that aren't in any
cartridge get decided the same way when they go in.

None ended up black. Map 64 doesn't fit baked —611 tiles— and goes in mode 3.

What the study left pending:

* **The save** stores how far the panorama has scrolled on its own and how a
  `ChangePBG` left it, and loading keeps it (`PANO_KEEP`).
* **`ChangePBG`** is `OP_PANORAMA` (0x46): it changes the loops and the speed;
  not the image. In the game there's only one, the Hover-Tram trip, always
  with the same image.
* **The tint in mode 1** reaches the screen's backdrop (`pano_backdrop`).
* **255's dropped frames aren't the panorama's**: walking a square, one is
  dropped every time you go down to (66,8), and with the panorama in black
  too. I didn't fix it; I note it here.
* **`adeleine::try_pack`**: in its own commit, separately. Measured over the
  328 maps of the dump, a cell with more colors than a palette appears only in
  the overlay layer of 159, which isn't in any cartridge.
* **`parches/`**: the path, the tiles left over from the distinct ones, the
  colors and the merges of each panorama.

What had to be added along the way: three VRAM layouts for mode 3 with more
background (the flattened intro asks for 395 tiles), HDMA channel 6 to cover
BG1 under the window on a flattened map, the `TileSubstitution` rows drawn
under a flattened map (the intro has one in the overlay layer), and
`load_above` not uploading anything to BG2's base with the panorama in mode 3.

**The space**, with `just espacio` in ABL: `release` goes from 29 free banks
to 23. It fits entirely in the ROM; the `.msu` wasn't needed.

**RAM**: `$7E7EE0` to `$7E7EE6` of the far one, besides the prototype's.
**Opcode**: `0x46`.

## The tests

In ABL, `pruebas/rpgmaker/test_panorama_golden.py`: the arrival on each map
that shows its panorama (24 goldens), two snapshots at different times on 94
(mode 3) and 255 (mode 1) with `PANO_AX` advancing, the four `ChangePBG`s of
the Hover-Tram in order, and saving and loading on 255 —red without
`PANO_KEEP`—.

Some 340 goldens change: those of 6, the suite's test bench, which goes in
mode 1; those of the maps with a panorama; and those of the walkthroughs that
go through one, which load on different frames and shift a bit later. Two
tests depended on the exact frame and were fixed in ABL: the battle's long
list —it wrote the party before the case built it— and the decompressed load,
which didn't know about the slots cache nor the panorama on BG2. Everything
side by side, with the original, in
`/shared/capturas/2026-10-05-panoramas-todos/`.

## To play

The intro, the terrace and the depot's rooftop (32, 33), the Hover-Tram trip,
under the bridge, and saving on any of those and loading.

## When merging

Reinstall `adeleine` —and what compiles it: `wally`, `screens`, `images`—,
`wally`, `mapdata`, `convert`, `events`, `bytecode` —`events`, `convert` and
`cartridge` compile it—, `cartridge` and `patches`: `just -f tools/justfile
install adeleine wally screens images mapdata convert events cartridge
patches`.

# Tested on the SNES

taro, on 2026-10-05, on the console: the intro, the rooftop where the
Hover-Tram lands and Kersh appears, and the two bridge maps. "they're all
incredible. I thought it'd be impossible to achieve this much!"
