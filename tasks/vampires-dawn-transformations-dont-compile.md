---
name: "Vampires Dawn's transformations don't compile"
description: "The wolf and bat transformations (parallel common events 10, 11 and 18) stop at their ChangeSpriteAssociation: the CharSet is past the eight graphics every map reserves"
type: bug
status: todo
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

**How to see it**: `just cartridges release` in `vampires-dawn/`, and the
line "parallel common events" of `build/release/converter.log`.

**Mulita, 2026-10-16**: once the bat compiles, it will still walk with the
ground's passability: the maps' parallel pages that open every cell for it
swap the ChipSet with `ChangeMapTileset`, which is dropped since that day.
See `changemaptileset-is-not-done.md`.

## Defined

**2026-10-16, Hurón**, checked against the-advocate `f4709d0b` and the ports `66ed09c`.
Turning into a wolf or a bat is one of the game's mechanics, so todo.
**Done** is common events 10, 11 and 18 out of the "do not compile" line,
and a test game case where a `ChangeSpriteAssociation` from a common event,
to a graphic no map page names, shows it. Two ways are open and the agent
picks and measures: a bigger table (`ROUTE_GFX_MAX` is 8, two bytes a
graphic in bank 0, whose BSS is tight), or the graphics the common events
name reserved first in every map's table and the map's own after them. The
bat walking over water also needs `ChangeMapTileset`, which is
[`changemaptileset-is-not-done`](changemaptileset-is-not-done.md) and not
this. First step: count the distinct (CharSet, index) pairs the common
events and each map of the game name.

**Carpintero, 2026-10-19**: the table is no longer eight. Since
`carpintero-cursor-graphic` (the-advocate) `ROUTE_GFX_MAX` is the
compiler's cap, 255, and the console's table is sized by the cartridge's
map that asks for most, in far RAM; and a common event's body can number a
route's graphic (command 34) at the same index in every map that may run
it (`landings.rs`). Common events 10, 11 and 18 still do not compile:
their `ChangeSpriteAssociation`s name graphics `indices::associations`
does not gather —it walks the maps' pages, not the common events—, and a
parallel common event gets no landings. Measured on Vampires Dawn's
release with that branch: "parallel common events: 23 run, 12 do not
compile [1, 2, 5, 6, 8, 9, 10, 11, 18, 30, 48, 49]", the same as main.
