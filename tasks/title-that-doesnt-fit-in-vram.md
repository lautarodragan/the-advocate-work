---
name: "The title that doesn't fit in VRAM"
description: "Desert Nightmare, The Frozen World and Vampires Dawn start without their title screen: the picture goes past the 544 tiles that title.s leaves it"
type: feature
status: done
assignee: taro
agents: [Carpintero]
---

Carpintero declared it on 2026-10-06 as a degradation
(`degrade-instead-of-failing.md`, point 5): the converter checks the
title against the limits that `title.s` asserts —544 picture tiles, 704
for the menu— and, if it doesn't fit, the game starts without a title, with
a WARNING. No task follows it.

**Checked today** (the-advocate `fc6f7456`, ports `a85b7e3`, built in a
worktree of their own), from each release's `converter.log`:

| game | picture | picture tiles |
|---|---|---|
| Desert Nightmare | `Titelbild` | 872 of 544 |
| The Frozen World | `FrozenWorldTitle` | 736 of 544 |
| Vampires Dawn | (its title) | 896 of 544 |

Book of Three (425), El Dorado (206) and Dooms 2 (282) fit. Sunset wasn't
built today.

**What you see while playing**: the game starts straight on its first map,
without the title screen or its New Game / Continue / Quit menu. How a saved
game is loaded in those cartridges wasn't looked at.

**How to see it**: `just cartridges release` in the game's directory and
`grep "title screen" build/release/converter.log`.

## The plan

taro, on 2026-10-11: **the title screen in 4bpp when it doesn't fit in
8bpp**. No research first: the scope is closed.

Why 4bpp always fits: in 8bpp a tile weighs 64 bytes, so a full screen
without a repeated tile —32x28 = 896 tiles— is 56 KB of the 64 KB of VRAM,
and the menu doesn't fit next to it; that is why `title.s` leaves the
picture 544. In 4bpp a tile weighs 32 bytes and the same worst case is
28 KB. Fewer colours alone saves nothing in 8bpp: the tile weighs the same.

* The converter keeps trying 8bpp first, in mode 3, as today.
* If it doesn't fit, the same picture in 4bpp, on BG1 in mode 1 —as
  [Large pictures in mode 1](https://github.com/lautarodragan/the-advocate-docs/blob/main/src/decisions/large-pictures-in-mode-1.md)
  already does with the map covered—, with Adeleine choosing the eight
  palettes of sixteen, as it does for the maps.
* The WARNING that today drops the title goes away; whatever is lost is
  what Adeleine decides, and stays as images in the build like the rest.
* Cropping or scaling the picture down to stay in 8bpp is not automatic:
  if a game wants it, it is a patch.

Done when Desert Nightmare, The Frozen World and Vampires Dawn start on
their title screen, with its menu, and the ones that fit today don't move a
byte.

## Carpintero, 2026-10-12

Starting from the-advocate `a2b58945`, ports `6d7beed`; branches
`carpintero-titulo-4bpp` in both.

**The VRAM layout doesn't move.** At 4bpp a tile is 16 words, so the
worst case —every cell distinct plus the blank one, 897 tiles— ends at
$3810, below the menu's tilemap at $4400; the menu's tiles stay at $5000
and the picture's tilemap at $7C00. What changes is the mode (1 instead of
3, set right after `screen_upload` and only in a cartridge whose title is
4bpp: `.if TITLE_BPP = 4`), the bytes of tiles in the `screens_table` row,
and the tilemap entries, which carry palette and flips.

**Seven palettes for the picture, not eight**: the menu stays on BG2 with
palette 0, and in mode 1 BG2 shares the eight palettes with BG1. The
picture goes through `rm2k-snes-images background` —the same layer a big
`ShowPicture` gets—, with Adeleine choosing seven palettes from palette 1,
and its corner at the screen's, where RM2k draws the title.

`--title-4bpp` forces the path in a game whose title fits: it is how ABL's
suite gets a case for it.

**Measured** (the-advocate `be098254`):

| game | 8bpp tiles | 4bpp tiles | palettes | colours left, of the 15-bit scaled picture's |
|---|---|---|---|---|
| Desert Nightmare | 872 | 870 | 7 | 83 of 1065 |
| The Frozen World | 736 | 731 | 7 | 79 of 512 |
| Vampires Dawn | 896 | 896 | 7 | 78 of 1073 |

What Adeleine left is in each release's `adeleine/title.png`.

**The others don't move a byte**: ABL, Book of Three, El Dorado, Dooms 2
and Sunset, built before and after with the same tools but this change,
give the same sha256. `TITLE_BPP = 8` is an equate the 8bpp path doesn't
assemble anything with.

**Loading a game in those three**: before, without a title, the save in
slot 1 loaded by itself at boot. Now it goes through "Load" on the title,
like ABL: saved from the pause menu (access forced from outside), reset,
"Load", slot 1, and the three come back to the same map and cell.

**ABL's suite gets a case**: the cartridge `test-title-4bpp` (map 6,
`--title-4bpp`) and four goldens in `test_title_golden.py` —the title,
the cursor down, back from the slots with B, and map 6 after "Begin the
Story", which is pixel for pixel the same as on the same cartridge
without the flag—. Without the line that sets mode 1 the three of the
title go red.

**What the suite doesn't cover**: none of the three games has a golden
of its title —`just boot` only passes it with A—, so how each one
looks at 4bpp was looked at by hand (captures, next to the picture), not
frozen; saving and loading through the title in those three was run by
hand once, not by a test; and the 4bpp path with a title that isn't
320x240 was not tried (none of the eight games has one).

**To merge**: the-advocate `carpintero-titulo-4bpp` (reinstall `convert`,
`mapdata` and `cartridge`), the-advocate-ports `carpintero-titulo-4bpp`
(four goldens in their own commit, and a fix to
`test_msu_the_rom_knows_where_each_backdrop_is`, which the new cartridge
turned red), the-advocate-docs `carpintero-titulo-4bpp`.
