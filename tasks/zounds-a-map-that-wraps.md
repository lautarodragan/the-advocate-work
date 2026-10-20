---
name: "Zounds: a map that wraps around"
description: "Map 70, Subsuelo / Passage 1, has Wrap: Both; the runtime does not wrap maps: what it would cost"
type: research
status: done
assignee: taro
agents: [Hurón]
---

Seen by taro on 2026-10-19, playing Zounds' delivery of that day (the ports `1182513`, the-advocate `2c350d8f`).

taro:

> `Subsuelo / Passage 1` has `Wrap: Both` on. We do not have that
> implemented, do we? How complicated would it be to implement?

Map 70 of Zounds. To answer: what RM2k does with a map that wraps (the hero, the
events, the panorama, the camera), what the runtime does today with one,
which maps of the ports use it, and what implementing it would cost on
the console, measured where it can be.

## The answer (Hurón, 2026-10-19)

Written in the book:
[Maps that wrap around](https://github.com/lautarodragan/the-advocate-docs/blob/main/src/research/2026-10-19-maps-that-wrap.md)
(branch `huron-wrap` of the-advocate-docs until it is merged). Measured
at the-advocate `2c350d8f` and the ports `1182513`; RM2k read in
easyrpg-player `9e67927`.

* **No, it is not implemented, and nothing says so.** Ditto reads
  `scroll_type`, nothing after it looks at it; neither the converter's log
  nor `degradations.json` mention it. Every edge is a wall on the console
  and the camera clamps. Played on Zounds' release ROM with the ports'
  harness: the hero walking into each of map 70's four seams stops at x
  99, x 0, y 0 and y 49.
* **Twelve maps wrap**, in Zounds (26, 27, 30, 70, 103, 137, 150),
  Vampires Dawn (1, 91, 249, 254) and Sunset Over Imdahl (63). What it
  costs today: on Zounds 70 the door to map 103 —Cuarto 2, with the chest
  of the Silver Key— is reached only through a seam, so nobody gets there
  walking; Vampires Dawn 254 (a free fall), Sunset 63 (bats flying across
  the wall) and Zounds 150 (an endless corridor) have things walking
  forever that pile up at the edge. The rest are cutscenes or mazes that
  are whole without the seams, where only the camera differs. Zounds 150
  and Vampires Dawn 254 also hang on
  `a-forced-routes-repeat-flag-is-dropped`: their hero's walk is a
  repeating `MoveEvent`.
* **The cost**: the VRAM window is already a torus; what has to change is
  a continuous view for the scroll and the window, the strips reading the
  map modulo its size, the steps, jumps and distances wrapping, and every
  "position minus camera" folded into the map's width. Estimated, not
  measured, at 500 to 700 bytes of code: bank 0 had 108 to 218 bytes left
  in the release cartridges that day, so it goes to a far bank behind a
  flag that only cartridges with a wrapping map assemble (as
  `paint_table`), and ABL does not change. About a dozen bytes of
  `FARBSS`. No clones of a character on both sides of a seam are needed
  by any port's map.

How the maps were measured —throwaway scripts, in the scratchpad—: each
map's passability from its ChipSet's tables (`rm2k-rules`' rule, written
again in Python), a walk from every teleport into the map with and without
wrapping, the doors inside the map as passages and events left out of
the passability; and the routes of the pages and of `MoveEvent`.
Captures of map 70 in the emulator are in the captures folder of that day,
`2026-10-19-maps-that-wrap`, with their README. RPG_RT itself was not run.

The implementation, with the proposed scope: `maps-that-wrap-around`.
