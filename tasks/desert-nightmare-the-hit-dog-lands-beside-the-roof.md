---
name: "Desert Nightmare: the hit dog lands beside the roof"
description: "In the dog scene on map 11 the hit dog shows on the sand left of the warehouse's roof, a little lower, slides behind it and leaves a sliver at its edge; RM2k hides it behind the roof: it goes with the screen, and the console scales those"
type: bug
status: draft
author: aguara
game: desert-nightmare
---

Seen by Aguará on 2026-11-21, at the-advocate `b18e4d4f` with the fix of
[`desert-nightmare-the-dog-runs-over-the-building`](desert-nightmare-the-dog-runs-over-the-building.md)
(branch `aguara-dn-dog`), playing map 11 from map 4's door, (8, 12): the
scene starts on its own.

Event 80 runs the dog as picture 1 by variables 14 and 15, its event's
screen place, **with the map** (`Hund_Animation1` to `3`), and then shows
the hit one, `Hund_Animation4`, at the same variables **with the screen**
(`ShowPicture`'s `p[4]` at 0) and moves it 32 pixels right. Map 11 is
RM2k's one screen, so RPG_RT puts both at the same place —the camera never
moves—, and the hit one is behind the roof, picture 2, but for its tail on
the sand for a moment.

The console scales a picture that goes with the screen —four fifths across,
fourteen fifteenths down; its map is not scaled—, so the hit dog shows some
sixteen pixels left of the running one and a few lower, whole on the sand,
slides right behind the roof and leaves a sliver of itself at the roof's
edge until the scene leaves the map.

Making it go with the map is not enough: a picture that goes with the map
does not move on the console, as in RM2k 2000 (`PIC_MAP_FIXED` in
`pic_move`, runtime/picture_far.s), and this one is moved. Nor can every
picture placed by variables on a one-screen map go with the map: Zounds'
menu selectors (maps 83, 190) are placed by variables over pictures that go
with the screen. What would do it: the same number shown by the same
variables with the map and with the screen on a map RM2k never scrolls,
both with the map, and the move done for it. Measured over the eight games:
only map 11 does that.
