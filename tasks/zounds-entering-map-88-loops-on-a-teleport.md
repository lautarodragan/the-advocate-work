---
name: "Zounds: entering map 88 loops on a teleport"
description: "Entering 'Desierto de Urbaddun / Mountains / Oeste de la Grieta / Secreton / 4 - Desert' (map 88) leaves the hero unable to move or leave: Get Outta Map's autostart pages, conditioned on variables 7 and 8, seem to fire with both still at 0 and teleport in a loop"
type: bug
status: doing
assignee: Calandria
agents: [Calandria]
---

taro, on 2026-10-19, playing Zounds (delivery of that day, the-advocate
`54ec3daf`, the ports `c2912ad`), going north of the desert for the pyro
sword: on entering that map they loop and cannot move or leave. taro's
reading: the event `Get Outta Map` triggers one of its pages conditioned on
X or Y although those should not hold, and loops on a teleport; X and Y are
never loaded into the variables. "I suppose RPG Maker ran page zero first,
which is a Parallel Process, and always managed to set the variables.
Maybe in our case those variables are at 0, 0 by default and nothing sets
X, Y."

What Hornero saw in `zounds/data/maps/Map0088.json`: Get Outta Map has four
pages. Page 0, no condition, trigger parallel, 2 commands. Pages 1-3,
autostart, 7 commands each: variable 7 <= 1, variable 8 <= 1, variable 8
>= 38 (compare operators as liblcf numbers them; check). In RM2k the
active page is the highest one whose conditions hold, so with both
variables at 0 page 2 is active and page 0 would never run there either:
something else probably sets 7 and 8 before (a parallel common event, the
map the hero comes from, the teleport). To find out, against EasyRPG's
source and the original under Wine if needed.

## Log
