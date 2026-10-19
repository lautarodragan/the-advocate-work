---
name: "Zounds: a message shows a face it should not"
description: "Sometimes a message or a choice shows the face of an earlier message, as if an erase-face that RM2k runs was skipped; it depends on the game's state, not on the command: the save point's choice shows Uname's face after a chest's message and not other times"
type: bug
status: doing
assignee: Carpintero
agents: [Carpintero]
---

taro, on 2026-10-19, playing Zounds (delivery of that day, the-advocate
`54ec3daf`, the ports `c2912ad`): "sometimes they show up when they should
not. It is not constant, so I think it depends on the game's state and not
on the command itself. Maybe there is a `hide face` we are not running,
sometimes, and the next message comes out wrong. It is not impossible that
it is a bug of the original game, but I suspect ours, from the patterns I
saw."

Four screenshots, in this order, in
`/shared/captures/2026-10-19-zounds-faces/` (and `~/scratch/hornero/faces/`):

* `18.png`: the save point's choice —Guardar / Salir del Juego / Ver
  Estados / Nada, from a common event— with the green-haired face.
* `19.png`: a chest's message, "Has encontrado: Poción Roja x2, Poción
  Verde x1", with the same face.
* `20.png`: the same choice, without a face (as it should be, presumably).
* `21.png`: the same choice with the face again; the hero is green there.

## Log
