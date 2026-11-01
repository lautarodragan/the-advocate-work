---
name: "Zounds: tile substitutions that do not compile"
description: "The Switch event on map 59, Centro (START), does nothing: its pages swap lower tiles 94, 95 and 1 in a ring, and the event compiler refuses the substitution, so the whole page is left out —switch, sound and all—; ten pages on six maps the same"
type: bug
status: doing
assignee: Calandria
agents: [Calandria]
---

taro, on 2026-11-01, in their words, translated —it blocks them in Zounds—:

> The Switch event, on the map `Centro (START)`, does nothing. Its
> commands are a switch, a sound effect, and 3 tile substitutions.

**What Hornero saw**, with `just culprits` on Zounds' `release` (ports
cd41913, the-advocate 422f904d): map 59 is `Centro (START)`, its event 22
"Switch" at (6,12), action button, same layer as the hero. Page 1:
`ControlSwitches` 132 on, `PlaySound` Door2, then `TileSubstitution`
lower 95→1, 94→95, 1→94; page 2 (switch 132 on) the reverse. The compiler
refuses the substitution and the page is left out whole, so nothing
happens. The same culprit, on every page of Zounds that has one:

    map 17  event 26 page 2   [0, 0, 132]  and  [0, 6, 138]
    map 59  event 22 pages 1, 2   (95/94/1 ring)
    map 75  event 1  page 1       (95/94/1)
    map 96  events 6, 7, 8, 9     (95 or 94 → 1)
    map 102 event 56 page 1       (95/94/1)

The compiler side is `TILE_SUBSTITUTION` in
`rm2k-snes/events/src/compile.rs` and the converter's `Substitutions`
(wally's `substitutions.rs`); RM2k's own is easyrpg's
`Game_Map::SubstituteDown`/`SubstituteUp` —a table indexed by the
original tile, which matters for a ring like this one—.

**Done**: every one of those pages compiles and does what RPG_RT does
—a ring swap included—; map 59's switch opens what it opens, seen in a
capture; a test red before.
