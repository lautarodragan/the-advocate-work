---
name: "The missile hatches turn into soldiers"
description: "In the cutscene of the past, when the missiles fire, the events that act as hatches take on the graphic of a military person"
type: bug
status: done
agents: [Hurón, Tijereta]
assignee: taro
---

From taro, on 2026-10-05: "Another bug, similar to the tank one: in the
cutscene of the past, when the missiles fire, the events that act as hatches
turn into military-person graphics". It may be the same cause as
`el-tanque-de-dalia-se-vuelve-dalia.md`: a graphic that an event sets and
something else changes.

# What was measured (Tijereta, 2026-10-05)

Base: ABL `c988101`, tools `d0e2e16c`.

**It reproduces, and it isn't the battle animation**: the hatches are already
soldiers around tick 150, when event 4's `MoveEvent`s turn them
(`face_down`, `face_left`), well before the `ShowBattleAnimation`s.
The animation's 64-tile box lands on tile 128 and steps on no one.

**The cause.** The silos are `Missiles` index 1, with the `fixed_graphic`
animation (4) and column 0. In that sheet column 0 of each row is the
hatch —closed, ajar, open— and columns 1 and 2 are a soldier. RM2k never
changes a `fixed_graphic`'s column (`IsAnimated` in
`Game_Character::UpdateAnimation`): turning shows column 0 of the new row.
The ROM, when giving an event a route slot (`route_for_event`), always put
it in the middle column, and `animate_ev_route` left it there: the hatch
turned into the soldier.

It isn't a regression: it has been like this since the events a route moves
have had their twelve poses.

# The fix

In the tools, branch `worktree-agent-ac0c3db5dd60db962` (commit "Eventos
que una ruta mueve: la columna del gráfico fijo y el gráfico de la página"):
the page carries in its +15 whether its graphic is fixed and its column, and
the route slot —forced or its own— keeps it and doesn't animate it, like
RM2k. New RAM: `FOUND_SPEED`, $7E30CB. No opcode.

Compared with the original under Wine (a copy that starts in 92): the
hatches open —closed, ajar, red lights— without any soldier, and the ROM
now the same. Screenshots in
`/shared/capturas/2026-10-05-compuertas-y-wick/`.

It moved two goldens, on purpose: `tram-320` and `tram-620`, the Hover-Tram
of 9, also a fixed graphic in column 0, which loses the flame underneath.

The test is `rpgmaker/test_grafico_de_pagina.py`: the silhouette of each
hatch in VRAM against the sheet's cell. Red with main's tools, green with
the branch's.

**When merging**: install `cartridge`, `convert`, `mapdata` and `wally`.
