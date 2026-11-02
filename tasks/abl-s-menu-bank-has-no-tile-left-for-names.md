---
name: "ABL's menu bank has no tile left for names"
description: "ABL release's slot and menu bank leaves the menu 120 tiles for what it composes, and since the party's conditions the names ask for exactly 120: one more long name or one more condition that outlives a battle and the converter starts leaving faces out"
type: bug
status: draft
---

Seen by Tijereta on 2026-11-02, measuring
[`the-menu-shows-the-partys-conditions`](the-menu-shows-the-partys-conditions.md),
with the-advocate `f05ccf2b` and the ports `014974a`.

**What was seen**: the converter's log of ABL `release`
(`build/release/converter.log`) says

    menu bank: 404 tiles of 448, each screen's text apart; the composed
    names ask for 120 of the 120 the menu leaves and 72 of the 156 the
    slot screen does

The 120 are the four longest actor names, the longest medicine in the
actor choice and, since that task, the four longest condition names the
party can hold on the map (ABL's dead one and Poison, twenty tiles). With
none to spare, the next thing that grows any of them —an actor with a
longer name joining the cartridge, a condition that outlives a battle,
`[text] letter_spacing`— makes `slots_with_room` in `rm2k-snes-screens`
leave faces out, the last actor's first, and say so in that log.

How to see it: `just cartridges release` in `abl/` and the line above.
