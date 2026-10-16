---
name: "The picture system"
description: "ShowPicture in full, beyond the sign"
type: feature
status: done
---

# What

The picture system beyond the sign: have the ROM draw more than one
`ShowPicture` per cartridge.

# Status

Noted, not started. The commands that don't fit are still accepted without
being carried out.

# Why

The ROM draws **one** `ShowPicture` per cartridge, which is the easy case: see
`showpicture-phase-1.md`, which also says how.

What the rest would cost is measured, and the detail is in "Lo que costaría el
sistema de imágenes entero", in that same task: **34 `ShowPicture` in the game,
20 different signs**, and 7 of those 34 commands are of the kind today's model
knows how to do.

And the sub-fact that decides the shape of the solution: **five of those signs
are exactly 320x240, and they can't be done with objects** —they would be 56 of
the 128 in OAM and 32 of the 34 tiles per line—. Those call for lending a layer
to the sign, and with that the map gets reloaded when it is erased.

## Done by the phased picture system, checked on 2026-10-16 at the-advocate 759aa0ba (Carpintero)

The premise —"the ROM draws one `ShowPicture` per cartridge"— no longer
holds. The book's `research/2026-10-01-the-picture-system.md` planned it in
phases and they were done: Label/JumpToLabel
([`label-and-jumptolabel`](label-and-jumptolabel.md)), several pictures in
sprites ([`several-pictures-in-sprites`](several-pictures-in-sprites.md)),
the large ones on BG1 in mode 1
([`large-pictures-on-bg1-in-mode-1`](large-pictures-on-bg1-in-mode-1.md)),
the automatic common events
([`automatic-common-events-the-shared-callevent-and-v-n`](automatic-common-events-the-shared-callevent-and-v-n.md)),
the zoom in mode 7 ([`picture-zoom-in-mode-7`](picture-zoom-in-mode-7.md)),
and pictures drawn into the map
([`pictures-that-go-over-the-map-outside-sunset`](pictures-that-go-over-the-map-outside-sunset.md), in testing).
Not everything RM2k does: the console keeps two pictures at a time,
and a page whose pictures the console cannot do is still warned about in
the build (Desert Nightmare's `TextboxInnen` and `TextboxRahmen`,
[`desert-nightmare-own-message-frame`](desert-nightmare-own-message-frame.md)).
What each game still lacks is its own task or draft —e.g.
[`zounds-pictures-and-the-picture-made-screens`](zounds-pictures-and-the-picture-made-screens.md)—
and what the console does differently is in the book's divergences.
