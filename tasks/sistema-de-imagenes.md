---
name: "The picture system"
description: "ShowPicture in full, beyond the sign"
type: feature
status: wishlist
---

# What

The picture system beyond the sign: have the ROM draw more than one
`ShowPicture` per cartridge.

# Status

Noted, not started. The commands that don't fit are still accepted without
being carried out.

# Why

The ROM draws **one** `ShowPicture` per cartridge, which is the easy case: see
`show-picture-phase-1.md`, which also says how.

What the rest would cost is measured, and the detail is in "Lo que costaría el
sistema de imágenes entero", in that same task: **34 `ShowPicture` in the game,
20 different signs**, and 7 of those 34 commands are of the kind today's model
knows how to do.

And the sub-fact that decides the shape of the solution: **five of those signs
are exactly 320x240, and they can't be done with objects** —they would be 56 of
the 128 in OAM and 32 of the 34 tiles per line—. Those call for lending a layer
to the sign, and with that the map gets reloaded when it is erased.
