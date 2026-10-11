---
name: "Vampires Dawn now builds with its own System"
description: "The VD port uses ABL's System because with VDBlutsys the ROM didn't fit; since the poses dropped 1.65 MB, it builds with its own. It remains to look at it and decide whether the knob goes"
type: chore
status: draft
---

Tijereta, on 2026-10-11 (`la-ventana-en-el-banco-de-tiles.md`):
the five games went back to their System except Vampires Dawn, "its screens
fit, but the ROM goes over by one 64 KB piece". The
comment of `system = "ablskin.png"` in `vampires-dawn/rm2k-snes.toml` says so
(ports `a85b7e3`).

**It's no longer true.** That measurement is from before
`una-cuantizacion-por-personaje.md` (Mulita), which brought the poses down
from 4.93 to 3.28 MB. Checked today, the-advocate `fc6f7456` and ports
`a85b7e3`, in an own worktree: with the `system` line commented out,
`just cartuchos release` in `vampires-dawn/` builds (rc 0, 2 min 12 s):
12,352 pieces in the 127 banks and 1,297 in the `.msu`. The screens are
fused with WARNING, as in the other games: the frame of the message
window (28 tiles), the actor choice (158 of 64), items and equipment
(151 of 31), the shop (166 of 96) and End Game (20 colors).

**What wasn't done**: it wasn't started in an emulator nor were the
fused screens looked at, and the knob wasn't touched —it belongs to the port's toml—.

**What is seen when playing today**: Vampires Dawn's windows, menu and battle
come out with A Blurred Line's System, not the game's.

**How to see it**: comment out `system` in `[graphics]` of
`vampires-dawn/rm2k-snes.toml` and `just cartuchos release` in
`vampires-dawn/`.
