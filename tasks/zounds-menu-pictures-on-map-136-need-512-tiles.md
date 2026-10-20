---
name: "Zounds: the menu's pictures on map 136 need 512 object tiles"
description: "Two faces of 180x59, a bar as wide as the screen and an HP picture are 512 tiles of 32x32 objects, and with the hero's the map fits no VRAM layout: the whole set is left out"
type: bug
status: draft
---

Seen by Tijereta on 2026-10-16, with the-advocate `9407d385` plus the
branch `tijereta-more-pictures`, while doing
[`zounds-pictures-and-the-picture-made-screens`](zounds-pictures-and-the-picture-made-screens.md).
Read from the converter's log, not played.

**What it is**: map 136, "Menu", shows a bar of 320x15 that slides in, the
faces `Zounds_Menu_Faces_Unamë` and `_Kazar` (180x59, 255 colours each, ten
32x32 objects on the console) and one of three HP pictures under one
number. Four numbers at once go in since the branch above, and the bar's
slide is done; but the pictures take 512 tiles —the faces 160 each, the
bar 128, the HP pictures 16 each— and the hero 64 more, and no layout has
that many sprite tiles: "map 136: WARNING, the pictures ... aren't drawn
here: with their 512 tiles the map fits no VRAM layout". Wally leaves all
of them out, not the last one.

The bar's blocks have half their cells drawn (eight of sixteen), so as 8x8
objects it would be 64 tiles instead of 128, but 32 objects on each of its
lines, the most the console draws on a line. The map shows the menu for ten
frames and goes back where the player was.

How to see it: build Zounds' `release` and look for "map 136" in
`build/release/converter.log`.

**And even fitting, they would not frame its panels** (Calandria,
2026-10-20, while doing
[`small-pictures-under-a-big-one-are-hidden`](small-pictures-under-a-big-one-are-hidden.md)):
map 136 is one RM2k screen whose panorama is the menu's background, and
the console does not scale a map —it shows a 256x224 window of it, from
the hero's camera— while it scales the pictures that go with the screen
to four fifths. So the faces and the bar would land at four fifths of
their place over panels drawn at full size. Map 190 solved it by drawing
its big picture over the panorama, which scales the two together; map 136
has no big picture, so that rule does not take it. What would: on a map of
one screen whose pictures are the screen, show its still panorama as a big
picture —scaled, with the small ones over it, as `BIG_KEEPS` does— and
not as the map's background.
