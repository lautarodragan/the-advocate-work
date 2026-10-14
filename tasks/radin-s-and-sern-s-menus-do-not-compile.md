---
name: "Radin's and Sern's menus do not compile"
description: "ABL's common events 42 and 44, which Mix Formula and Weapon Forging open, are left out by the converter: their MoveEvent changes the hero's graphic, which a shared body cannot"
type: bug
status: testing
assignee: taro
agents: [Mulita]
---

Seen by Mulita on 2026-10-12, at the-advocate's `mulita-skills-screen`
(phase 3.1 of [`the-skills-menu`](the-skills-menu.md)), on A Blurred Line.

Choosing Radin's Mix Formula or Sern's Weapon Forging from Tech Skill turns
on switch 734 or 859 and closes the menu, and nothing happens: in the
original, common event 42 or 44 takes the party to Radin's map (298,
"Radin Chemistry") or Sern's (321, "Sern Forging"). The converter's log
says it, for `release`: `shared common events: … left out, not compiling:
16, 42, 44`.

What was measured:

* Both maps are outside `release` (`[maps]` in ABL's `rm2k-snes.toml`).
  Adding them to `added` puts them in the cartridge and the two common
  events are **still** left out; it was undone.
* The commands of common event 42 compile as a test page on map 5 with map
  298 in the cartridge (`rm2k-snes-convert compile`), and with any one of
  them removed, too.
* So what fails is compiling them as a **shared body**: `body_of` in
  `commons.rs` of `rm2k-snes-events` compiles with `graphics: None`, and
  their `MoveEvent` on the hero carries route command 34, a graphic change
  to `extra2(1)`, which `compile_route` refuses without a map's graphics
  table (`let Some(graphics) = ctx.graphics… else { return cannot() }`).

To reproduce: build `release`, read `converter.log`; or play: Radin in the
party, Tech Skill, Radin, Mix Formula.

### Hornero, 2026-10-14: the graphic change is dropped, the menus compile

taro: "can we drop the graphic change command instead of the whole
page?" `compile_route` now skips a route's graphic change when there is no
map's table to resolve it in (a shared body), and the rest compiles:
common events 42 and 44 run (the converter's log: "left out, not
compiling: none"). What is lost: the hero keeps its graphic where the
original changed it. Not played: choose Mix Formula and Weapon Forging
from Tech Skill and see that the party goes to Radin's and Sern's maps.
