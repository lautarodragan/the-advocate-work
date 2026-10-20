---
name: "Merge similar tiles when the background doesn't fit"
description: "If a map's background has more distinct tiles than fit in VRAM, the most similar ones are merged until it fits, with a warning: an algorithmic playable floor, without intervening by hand"
type: feature
status: done
agents: [Cardón]
assignee: taro
---

18 Vampires Dawn maps go past the ceiling of about 544 background tiles (the
largest, Uruya, 817; the world, 597): measured by Hornero on 2026-10-06 with
`wally layers` over the 440 maps, in `/extras/scratch/hornero/vd-tiles/`.

taro, on 2026-10-06, in their words, translated:

> maybe merging tiles is a good feature to have, in general. even if it
> looks ugly, it lets us have a playable lower bound algorithmically

## Done (Cardón, 2026-10-06)

It goes in `wally`, not in Adeleine or Voodoo: the decision of what resembles
what is Adeleine's (`group_tiles`, the k-means of the mode 7 backgrounds) and
it is used as is; what is in `wally/src/background/fuse.rs` is the
wiring —counting tiles the way Voodoo counts them, with the mirrors, and rewriting
the chosen cells in the floor image before anyone reads it—.

It is the **last step** of `map::convert`, after the pictures, the
shared slots, the cache and the animation box: it is only requested if the
map doesn't fit in any layout, and only if some layout holds its sprites
and its upper layer (if what's in excess is sprites, merging doesn't help). The ceiling
is the background of the largest layout that holds them; the water animations
add tiles afterwards, so if it goes over it is retried with fewer (up to 4 times).
A map that already fits doesn't go through here: byte for byte the same.

## Measured on Vampires Dawn (2026-10-06)

With the merging, **it doesn't build**: it stops on something else before reaching
the maps that need it, and it isn't of the same kind.

* The background is no longer what blocks any of the 18 large maps: with the
  ceiling of 544 each one goes down to 544 (53 fewer on map 1, 273 on Uruya, 260 on
  338; 249 only 9). Captures in `/shared/captures/2026-10-06-fusionar-tiles/`.
  In the whole conversion only map 1 (68 tiles, to the ceiling of the
  layout its sprites leave) and 118 (134, to 480) were merged.
* What stops it is **the sprite bank and the upper layer**: map 15
  (436 sprites with 576 of background), 57 (768), 95 (4096), 99 (832), 150 (436 with
  609 and 130 upper), 165 Uruya (768 with 817), 225 (832), 399 (512 with 136
  upper): no layout holds those sprites, and merging background doesn't
  fix it. The mode 1 panels of maps 28 (3411 sprites), 402 and 403
  don't fit either. And with those out, `rm2k-snes-battle` stops on something
  global: the encounters don't fit in one-byte tables (121 records, 136
  zones, 779 troops).
* The next step, if wanted, is to degrade the sprites with the same
  criterion (another kind of merging, more expensive: they are poses and palettes).

Install when merging: `wally` (`just -f tools/justfile install wally`).
A Blurred Line's suite with local `wally`: 1150 green, `abl.sfc` `8bb36b99…` unchanged.
