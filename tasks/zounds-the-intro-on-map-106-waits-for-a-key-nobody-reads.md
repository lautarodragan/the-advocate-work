---
name: "Zounds: the intro on map 106 waits for a key nobody reads"
description: "Map 106's autostart waits for variable 4 to be 5 or 6 (the action or cancel key); only common event 3 writes it, with KeyInputProc in its long form, and that event is left out by the long KeyInputProc and by ControlVars from an actor's stats"
type: bug
status: doing
assignee: Aguará
agents: [Aguará]
---

Found by Hornero on 2026-10-16, with the-advocate `af7c399d` and the ports
`f28916b`, asked by taro what keeps Zounds' boot on map 106.

Map 106 "Imágenes": event 1, page 0 (autostart) waits 50 and turns switch
192 on; page 1 (autostart, switch 192) asks variable 4: 5 → EraseScreen,
switch 193, Teleport to map 107 (10,7); 6 → the same to (9,7). No event of
the map reads a key. Common event 3, "Set Gloval Variables" (parallel, no
switch), does: `KeyInputProc` into variable 4 under a branch on switch 315.

`culprits` keeps common event 3 out for:

* `KeyInputProc` with 9 parameters, `[4, 1, 1, 1, 1, 1, 1, 1, 0]`: RM2k
  1.50's and 2003's long form, each direction on its own. The compiler
  requires the 5-parameter form (`compile.rs`, the `KEY_INPUT_PROC` arm,
  "the length is required instead of assumed"). With the four directions
  alike it is the short form.
* `ControlVars` from an actor (operand 5): `[0, 79, 79, 0, 5, 1, 1]`,
  `[0, 137, 137, 0, 5, 4, 0]` and others.

Common events 7 ("Saltar") and 40 ("Notes On Screen") are out for the same
long `KeyInputProc`.
