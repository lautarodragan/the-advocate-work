---
name: "Ignore ChangeSystemGraphics, for now"
description: "Keep ChangeSystemGraphics from leaving out the page that uses it: accept it doing nothing, as debt, until it is implemented (changesystemgraphics.md, in todo)"
type: feature
status: testing
agents: [Mulita]
assignee: taro
---

From taro, on 2026-10-05: "ignore ChangeSystemGraphics. Let's leave a task
in todo to implement it, and for now let's not allow its lack of
implementation to prevent pages from compiling". It unblocks the start of Sunset
Over Imdahl (map 11), with the menu still in the wrong System.

Done by Mulita, on 2026-10-05: `CHANGE_SYSTEM_GRAPHICS` (10680) goes into `ACCEPTED_UNDONE` and its branch returns `vec![]`; troop pages go through the same `compile_page`. Test `change_system_graphics_is_accepted_without_emitting`, red before. ABL doesn't use the command (no occurrences in its `data/`), so its ROM doesn't change. Sunset Over Imdahl: the start event of map 11 now runs (title fade, black screen at 15 s like the original); at 30 s the original shows a picture and the cartridge stays black: not investigated.

Superseded on 2026-10-12 by [`changesystemgraphics`](changesystemgraphics.md)
(Cardón): `CHANGE_SYSTEM_GRAPHICS` is off `ACCEPTED_UNDONE` and compiles to
`OP_CHANGE_SYSTEM`, which switches the message window's System.
