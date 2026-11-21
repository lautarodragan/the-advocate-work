---
name: "The map comes back in pieces after a big picture"
description: "When a big picture is erased the map is reloaded with the screen off, but the characters' poses are uploaded over the next frames: for three or four frames they show as black boxes or other characters' tiles"
type: bug
status: draft
author: aguara
agents: [Aguará]
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
