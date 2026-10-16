---
name: "The roof edges that don't fit in the 127"
description: "On painted maps, the exact roof edges go in BG2 and 127 fit; in Sunset's plazas and streets there are more, and the rest go by whole cell: the roof covers too much or too little"
type: bug
status: wishlist
---

Measured by Mulita on 2026-10-11 (`sunset-in-mode-1-with-colour-math.md`):
on a painted map, the cells the roof partly covers go in BG2 with
only the roof's pixels; 127 tiles fit (`roofs(…, 127)` in
`rm2k-snes/wally/src/background/painted.rs`, the-advocate `fc6f7456`), and
"the edges that don't fit go by whole cell". Over the 60 painted
maps, 34,895 of 1,586,793 roof pixels end up on the wrong side
(2.2 %); in the spring plaza, 2,250 of 84,145. She left written
which way it could go: "256 could be given by moving the base of BG2 and
the window to index 256".

Cardón saw it while playing on 2026-10-11 (`other-games-build-and-boot.md`):
a normal-layer guard, event 8 at (36,13) on map 2, with its
legs over the edge of the orange roof; "probably one of the edges
that don't fit in the 127", not checked. The walks of the goldens in
`test_painted.py` were chosen so as not to show it.

**What you see while playing**: in the plazas and streets of Sunset Over Imdahl,
near the edge of a roof, a character is covered too much or peeks out above
where the original covers them.

**How to see it**: `just boot -k sunset` at the root of the ports builds the
release; go to map 2 and look at the guard at (36,13).

## Defined (2026-10-16, Carpintero)

Cosmetic and measured (2.2% of the roof pixels): nothing stops. **Done**:
Sunset's painted maps carry every roof edge exactly, with the goldens of
`test_painted.py` moved on purpose to show the guard at (36,13) on map
2. **First step**: Mulita's suggestion —BG2's base and the window at
index 256, for 256 edges— and how many edges each painted map needs.
