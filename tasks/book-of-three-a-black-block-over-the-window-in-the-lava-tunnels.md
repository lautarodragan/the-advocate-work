---
name: "Book of Three: a black block over the window in the lava tunnels"
description: "On map 46 the message window carries a black block over its lower right corner, about 32 by 8 pixels with a ragged top"
type: bug
status: draft
agents: [Calandria]
---

Seen by Calandria on 2026-10-19 in snes9x captures of the `lava` and
`rescue` milestones of `tests/test_book_of_three_milestones.py`, with the
release built by the-advocate `9592b88b` and the ports `c420032` —before
any change of `calandria-route-graphics`— and the same after it. Not
compared with the original.

**What is seen**: on map 46 ("Lava Tunnels"), while a message is open —
Taran's "Aaaaaaaagggggggghhhhhhhh!!", Fflewddur's "Look! It's Taran... he's
in trouble!"— a black block about 32 by 8 pixels sits over the window's
lower right corner, with a ragged top edge, as if something were drawn
over the window there. The message windows seen on maps 21 and 32 do not
have it.

**How to see it**: the frame some 140 ticks after the action of the `rescue`
milestone (or of `lava`), with
`/shared/captures/2026-10-19-book-of-three-route-graphics/map46-window-block.png`
as the capture.
