---
name: "A box before any face command is laid out for a face"
description: "In a game that shows faces, a foreground page's boxes before its first ChangeFaceGraphic are compiled for the 168 pixels a face leaves, and since 2026-10-19 the console shows no face there: narrower lines and more boxes than RM2k"
type: bug
status: draft
agents: [Carpintero]
---

Seen by Carpintero on 2026-10-19, at the-advocate `148d2fe2` (the branch
`carpintero-faces`), while fixing
`zounds-a-message-shows-a-face-it-should-not`.

Since that change the console clears the message face when a foreground
page starts and ends, as RM2k does: a page the player starts by talking or
touching, or an autostart, shows no face until it names one. The event
compiler still lays out a box at a page's start, before any
`ChangeFaceGraphic` of its own, for a face whenever the game names faces
at all —`Ctx::box_faced` with `Ctx::face` at `None`, in
`rm2k-snes/events/src/compile.rs`—, a guess that was right while the
console kept the face past the page's end. So in Zounds, Desert Nightmare,
Dooms 2 and Vampires Dawn those boxes come out with the text at the border
and no face, but wrapped at 168 pixels instead of 240: a box RM2k shows in
one window can take two. Nothing is lost.

To see it: Zounds, map 17, the chest at (7, 4), "Has encontrado: / Poción
Roja x2 / Poción Verde x1", whose lines are short enough not to show it;
a longer box of a page with no face command shows it. The pages that run
inside another —a called common event, a page another page calls— and the
parallel ones do inherit a face, so for them the guess still holds, and a
map event's page can be both started by the player and called.
