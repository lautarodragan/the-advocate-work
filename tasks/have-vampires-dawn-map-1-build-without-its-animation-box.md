---
name: "Have Vampires Dawn's map 1 build without its animation box"
description: "If the box for a map's battle animations doesn't fit in the sprite bank, the map is left without them with a warning, instead of aborting the build"
type: feature
status: testing
agents: [Carpintero]
assignee: taro
---

Vampires Dawn doesn't build: with ABL's System through the knob (b8224c3 in the
game's repo) it aborts at "map 1: shows battle animations and the 64
tiles of its box don't fit in the sprite bank: it spends 320 of 0. See
`animacion_de_mapa`." It is the same line of "degrade instead of failing":
the map is left without those animations, with a WARNING. Whatever shows up
behind it, of the same kind, too.

taro, on 2026-10-06: "let's do those two in parallel", with Sonnet.

## What was done (Carpintero, 2026-10-06)

* Wally: if a map doesn't fit in any VRAM layout with the animation
  box (64 sprite tiles, which can't be shrunk), it is converted
  again without it and says WARNING; the ROM draws no animations there.
  Test in `wally/tests/whole_map.rs`, seen red before.
* **But that wasn't what was cutting off map 1.** VD's map 1 is
  300x300 and its background has 597 unique 8x8 tiles; the biggest layout
  gives 544. It doesn't fit with or without the box, with or without frames: it is the background. Have it
  say so properly: the converter's message now says "fits no VRAM layout" with
  the three numbers, instead of the sprite bank's "spends 320 of 0".
* What's missing for VD to build is deciding what to do with a background that doesn't
  fit (merging similar tiles, lowering the map's resolution, splitting it):
  that changes what is seen, and it doesn't degrade by itself.

ABL's suite with these tools: 1147 green and `abl.sfc` identical
(`602b60e0...`). The box is dropped only as a last resort, after the
shared slots and the cache: the first version dropped it earlier and
changed ABL's ROM. On merging: reinstall `wally` and `convert`.
Not verified on a real game: VD doesn't get to that path, it aborts earlier.
