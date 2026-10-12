---
name: "The title that doesn't fit in VRAM"
description: "Desert Nightmare, The Frozen World and Vampires Dawn start without their title screen: the picture goes past the 544 tiles that title.s leaves it"
type: feature
status: doing
assignee: Carpintero
agents: [Carpintero]
---

Carpintero declared it on 2026-10-06 as a degradation
(`degrade-instead-of-failing.md`, point 5): the converter checks the
title against the limits that `title.s` asserts —544 picture tiles, 704
for the menu— and, if it doesn't fit, the game starts without a title, with
a WARNING. No task follows it.

**Checked today** (the-advocate `fc6f7456`, ports `a85b7e3`, built in a
worktree of their own), from each release's `conversor.log`:

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

**How to see it**: `just cartuchos release` in the game's directory and
`grep "title screen" build/release/conversor.log`.

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
  [Large pictures in mode 1](https://github.com/lautarodragan/the-advocate-docs/blob/main/src/decisions/las-imagenes-grandes-en-modo-1.md)
  already does with the map covered—, with Adeleine choosing the eight
  palettes of sixteen, as it does for the maps.
* The WARNING that today drops the title goes away; whatever is lost is
  what Adeleine decides, and stays as images in the build like the rest.
* Cropping or scaling the picture down to stay in 8bpp is not automatic:
  if a game wants it, it is a patch.

Done when Desert Nightmare, The Frozen World and Vampires Dawn start on
their title screen, with its menu, and the ones that fit today don't move a
byte.
