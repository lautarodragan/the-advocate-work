---
name: "A Blurred Line: the sixty-one torches of map 148 stand still"
description: "Map 148's Crown7 flames animate in RM2k and stand still in the port: with its ground already fused to fit, the converter gives up their two slots before fusing more"
type: bug
status: wishlist
---

Seen by Calandria on 2026-10-15, measuring
[`book-of-three-the-intros-torches-stand-still`](book-of-three-the-intros-torches-stand-still.md),
with the-advocate `7aa66900` and the ports `66a83f3`.

**What the build says**: `still-animation-dropped` in `release`'s
`degradations.json`, "map 148: 61 still events animate in RM2k and stand
still here: their slots don't fit in the sprite bank (0 of 1 looks
animate)". They are 61 `Crown7` index 3 flames, 57 at speed 6 and 4 at
speed 5: two VRAM slots. The same map has `background-tiles-fused` (74
tiles).

**Why**: the converter gives up still animations before fusing the
ground, and here the map does not fit even with none animating, so the
fusion runs with the animation already given up. Before 2026-10-15 they
stood still too, by the cap of four.

Also left standing still, by the same rule or by a cache that would make
events wait: Sunset Over Imdahl's maps 1, 2, 3, 12, 13, 14, 15 and 46, and
Vampires Dawn's 201, 222, 236 and 240 (102 animates one of its three
looks).

**How to see it**: build `release` and look for `still-animation-dropped`
in `abl/build/release/degradations.json`; in the game, map 148.

## Defined (2026-10-16, Carpintero)

Still open at the-advocate `f4709d0b`. A fidelity detail: nothing stops
and the map plays. **Done** is map 148's flames animating in `release`
—no `still-animation-dropped` for it in `degradations.json`—, with the
map's background fused as much as that takes and the fusion's loss looked
at side by side. Two ways, the agent picks and measures: fuse the ground
further to free the two slots, or let the animation take its slots before
the fusion is decided. **First step**: how many more tiles the fusion has
to merge for the two slots, on 148 and on the Sunset and Vampires Dawn
maps listed above.
