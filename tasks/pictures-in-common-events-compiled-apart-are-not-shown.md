---
name: "The pictures of the common events compiled apart from the maps are not shown"
description: "An automatic or parallel common event, or one a page calls as a shared body, is compiled once without a map, so without pictures: Zounds' pick-axe and notebook, A Blurred Line's portable console and Vampires Dawn's menus show nothing"
type: bug
status: draft
---

Seen by Tijereta on 2026-10-16, with the-advocate `9407d385` plus the
branch `tijereta-more-pictures`, while measuring
[`zounds-pictures-and-the-picture-made-screens`](zounds-pictures-and-the-picture-made-screens.md).
Measured with a throwaway script over the dumps, not played.

**What it is**: the shared bodies of `commons.rs` in the event compiler
—the automatic and parallel common events, and the ones an `OP_CALL`
reaches— are compiled with `pictures: None`: a picture belongs to a map,
its tiles to the map's sprite bank and its entry to the map's table, and a
body compiled once has no map. So their `ShowPicture`, `MovePicture` and
`ErasePicture` are accepted without being done. A map page that calls a
common event with pictures gets them only if the call is pasted in place.

**Where it shows**, most small pictures up at once along the event:
Zounds' `PickAxe` (common 21, automatic on switch 64) 14, `Show Mining
EXP` (27) 10, `Cuaderno de Notas` (29) 9, `Notes- Show Notes` (41) 6;
A Blurred Line's `NewMenuActivated` (39) 11 —the portable console, which
nobody needs to finish the game—; Vampires Dawn's menus (25 to 28, 43, 44)
7; Sunset Over Imdahl's `Menu` (5) 4.

How to see it: build Zounds' `release` and look at
`build/release/degradations.json`: the `picture-not-shown` losses under
`"common"`. The book's research "More pictures at once" weighs what it
would cost.

## 2026-10-17, Mulita: the automatic ones, copied into the maps

Since the-advocate `939a8bd7` (branch `mulita-fw-b-menu`, for
[`frozen-world-the-b-menu-on-the-map-is-not-drawn`](frozen-world-the-b-menu-on-the-map-is-not-drawn.md))
an **automatic** common event with a `ShowPicture` of its own is copied
into each map with room for one more event, as an automatic page of an
added event 0, and its pictures are the map's when they fit beside the
map's own: see `common_pages.rs` in rm2k-snes-convert. What is still as
this draft says: the **parallel** common events, the bodies an automatic
or a page **calls** (an `OP_CALL` to a body without pictures), and the
maps where the copy's pictures do not fit. Zounds' `PickAxe` (21),
Vampires Dawn's and Sunset's menus were not looked at with the change.
