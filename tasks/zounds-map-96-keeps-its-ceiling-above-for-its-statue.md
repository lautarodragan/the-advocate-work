---
name: "Zounds' map 96 keeps its ceiling above for its statue"
description: "On Zounds' map 96 the sign's message still blacks out the cave's ceiling on its lines: the analysis of where characters can be does not follow variables, and the statue the hero pushes walks through walls when its own coordinates, copied into two variables, say so"
type: feature
status: draft
---

Seen by Aguará on 2026-11-02, doing
[`above-tiles-no-character-can-reach-go-below`](above-tiles-no-character-can-reach-go-below.md),
with the-advocate's `aguara-above-tiles` (from `0ba09da4`), in Zounds'
map 96, in snes9x.

**What is seen**: on map 96, with the sign "Cartel Fijado: Para abrir la
puerta, deben dañar la estatua…" open —a message without its background—,
the map's left column, a block in the middle-left and the right edge go
black on the text's lines, as before the task: none of the map's 880
cells with a tile above the hero went into the background. On map 86 the
same message now leaves only the column of the cave's edge by the floor.

**Why**: `rm2k_rules::reach::covered` cannot prove any ceiling of the map
out of a sprite's reach, because of event 83, the statue. Its page, by the
action key, pushes it away from the hero with "walk through walls" on
—`MoveEvent [10005, 8, 0, 1, 36, 10, 37]`— inside conditional branches on
variables 52 and 53, which the same page sets at its end to the statue's
own x and y (`ControlVariables [0, 52, 52, 0, 6, 10005, 1]` and `… 2]`):
the push goes through a wall only from the cells the puzzle means. The
analysis does not follow variables, so it lets the statue be pushed
through any wall the hero can stand beside, and from there through the
next: every ceiling. Without the statue it would free 187 of the 880
cells; the rest the hero's jump keeps (common event 7, "Saltar", lifts him
a row over every cell he stands on).

**What would fix it**, either:

* following a conditional branch on a variable that only ever holds an
  event's own coordinate —`ControlVariables` with operand 6 on that
  event—, so the route inside runs only from the cells the branch names;
* or a project's word for it, by map and event, that the converter passes
  on —"the statue's routes stay where its pages say"—, which taro would
  have to want.

**To reproduce**: a case in `zounds/cases/` with `Teleport [96, 14, 14, 1]`,
`Wait [10]`, `MessageOptions [1, 1, 0, 0]` and the sign's `ShowMessage`
lines; the converter's log has no line `map 96: N cells draw their tiles
above the hero below`.
