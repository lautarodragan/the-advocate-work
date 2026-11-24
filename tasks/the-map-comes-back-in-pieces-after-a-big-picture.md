---
name: "The map comes back in pieces after a big picture"
description: "When a big picture is erased the map is reloaded with the screen off, but the characters' poses are uploaded over the next frames: for three or four frames they show as black boxes or other characters' tiles"
type: bug
status: todo
author: aguara
agents: [Aguará, Carpintero, Hornero]
links:
  blocked-by: [desert-nightmare-the-motel-s-other-trash-cans-blink-while-they-open, desert-nightmare-the-scene-after-the-bar-is-black]
  relates: [desert-nightmare-the-screen-goes-black-before-the-first-monster]
---

Seen by taro on 2026-11-21 in Desert Nightmare, map 28, frames 63697 to
63701 of the captures of
[`desert-nightmare-the-screen-goes-black-before-the-first-monster`](desert-nightmare-the-screen-goes-black-before-the-first-monster.md)
(`frame-63698.png` to `frame-63701.png` in its images): the room comes back
with its cabinets as black boxes, and they fill in over four frames. Read
by Aguará in the-advocate at `a537d967`; not measured on another map.

That scene no longer has a big picture, so it does not show there any
more; the path is the same for every big picture erased.

**Why, as read**: `big_erase` in `runtime/big_picture.s` calls
`big_back_far` in `runtime/picture.s`, which puts back the pose bank with
`load_sprite` and forgets the rows' poses with `npc_poses_forget`: each
row asks for its pose again through `vram_queue`, a few per vblank, while
OAM already draws them, and the brightness comes back on the next vblank.
`back_from_battle` in `runtime/enter_map.s` does the same, so coming back
from a battle may show it too.

**What would fix it**: keep the screen dark until the rows' poses are up,
or upload them with the screen off before giving the brightness back. The
screen should come back in one frame.

## Log

### 2026-11-22, Carpintero: seen again on Desert Nightmare's map 33

In Desert Nightmare's hotel room at night, map 33, by taro, frames 43661 to 43669 of the captures of
[`desert-nightmare-the-scene-after-the-bar-is-black`](desert-nightmare-the-scene-after-the-bar-is-black.md),
which shows them: the room comes up without its still events, and the
flower table, Sandra, the table's and the wardrobe's tops, the sneakers
and the curtains come in over eight frames, with the message box already
typing. Map 33's autostart shows the black `Schwarz` over the whole
screen, shows the screen and fades the picture to nothing waiting for it,
so the converter takes it down there —`big_fade_outs` in rm2k-snes-events—
and `big_erase` reloads the map. Reproduced by Carpintero on the ports'
`33c55dd` with the-advocate's `7e8da728`, jumping to map 33 at (10, 8):
the layer goes down on frame 240 after the jump, the room is on screen on
252, and its objects are still coming in on 260.

Since the fix of that task the corridor before it, map 32, is taken down
the same way halfway through its scene, and comes back the same.

### 2026-11-22, Hornero: to todo

taro, on hearing that Carpintero's fix of
[`desert-nightmare-the-scene-after-the-bar-is-black`](desert-nightmare-the-scene-after-the-bar-is-black.md)
makes map 32's hallway come back this way too, in the middle of the
scene:

> Would it make sense to move it from draft straight to `todo`?

It touches how every game takes a big picture down, and the poses' upload
that Cardón's
[`desert-nightmare-the-motel-s-other-trash-cans-blink-while-they-open`](desert-nightmare-the-motel-s-other-trash-cans-blink-while-they-open.md)
changed in `runtime/cache_slots.s`: it starts after both are merged.
