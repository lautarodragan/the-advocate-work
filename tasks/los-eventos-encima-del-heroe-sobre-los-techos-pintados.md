---
name: "Events above the hero, over the painted roofs"
description: "In a painted map (mode 1), an event with 'above the hero' priority is drawn over the roofs; in RM2k the roofs are pictures and go above everything"
type: bug
status: draft
---

Seen by Cardón on 2026-10-11 (`los-otros-juegos-arman-y-arrancan.md`),
tools `fc6f7456`, ports `a85b7e3`, the same in snes9x and bsnes.

**What is seen**: Sunset Over Imdahl, map 2 (the square), the DummyGuard at
(13,23): it is drawn over the roof that should cover it.

**Why, as far as is known**: in mode 1 objects go up one priority
step (`oam.s`), so "above the hero" ends up at priority 3, above
high BG1, which is where the roofs go. In RM2k Sunset's roofs are
pictures, and a picture goes above all events (EasyRPG:
`Priority_PictureNew` > `Priority_EventsFlying`). It was not compared with the
original in Wine.

**How to see it**: `just arrancan -k sunset` at the root of the ports builds the
release; go to map 2 and look at the guard. The walks of the goldens of
`test_pintados.py` were chosen so they do not show it.

Nearby, without checking whether it is the same thing: a normal-layer guard at (36,13)
on the same map has its legs over the edge of a roof; it may be one
of the edges that do not fit in the 127 (the debt in
`sunset-en-modo-1-con-color-math.md`, now
`los-bordes-de-techo-que-no-entran.md`).
