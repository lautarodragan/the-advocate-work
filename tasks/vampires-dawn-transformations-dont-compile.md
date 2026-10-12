---
name: "Vampires Dawn's transformations don't compile"
description: "The wolf and bat transformations (parallel common events 10, 11 and 18) stop at their ChangeSpriteAssociation: the CharSet is past the eight graphics every map reserves"
type: bug
status: draft
---

Seen by Aguará on 2026-10-12, with the-advocate `6ed7c4a0` and the ports
`0e1d9ba` (`parallel-common-events-dont-run.md`), in Vampires Dawn.

**What is seen**: since the ROM runs parallel common events, 22 of the
game's 35 do; `Wolfsverwandlung` (10), `Fledermausverwandlun` (11) and
`Wolfsverwandlung Asg` (18) are not among them —the converter's report
lists them under "do not compile"—, so turning into a wolf or a bat does
nothing.

**Where they stop**: at their `ChangeSpriteAssociation` —`rs3monst` 3 for
the wolves, `F04` 1 for the bat—. A body without a map can only name a
graphic that has a reserved slot in every map's table (`associations` in
the event compiler), and that table holds eight (`ROUTE_GFX_MAX`): the
game's map pages already name eleven pairs, and `rs3monst` 3 is not among
them. The `Loop`s these bodies have compile since `f0fd7e18`.

**How to see it**: `just cartuchos release` in `vampires-dawn/`, and the
line "parallel common events" of `build/release/conversor.log`.
