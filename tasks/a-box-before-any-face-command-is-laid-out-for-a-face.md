---
name: "A box before any face command is laid out for a face"
description: "In a game that shows faces, a foreground page's boxes before its first ChangeFaceGraphic are compiled for the 168 pixels a face leaves, and since 2026-10-19 the console shows no face there: narrower lines and more boxes than RM2k"
type: bug
status: todo
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

## Defined (2026-10-20, Tijereta)

Checked against the-advocate `8f290c39`: still so —`Ctx::box_faced` in
`rm2k-snes/events/src/compile.rs` answers "a face" for `face: None`
whenever the game names faces—. The draft leaves one doubt, a page that
is both started by the player and called; that one keeps today's guess,
since laying it out for 240 pixels would put the text under a face it
inherits. **Done**: a map page that only starts in the foreground —talk,
touch or autostart— and that no other page or common event calls lays
out its boxes before its first `ChangeFaceGraphic` for no face, as wide
as RPG_RT's; a compiler test for each side (that page, and a called one
that keeps the face's width); Zounds' boxes of such pages wrap as in the
original. **First step**: whether the compiler knows, when it compiles a
map page, that something calls it (`CallEvent` to a map event, from the
map or a common event), and where.
