---
name: "A System with a gradient under its frame stops the converter at the actor choice"
description: "Zounds' System has 215 colours under its window frame and no `[windows.background]` entry: the actor choice's windows come out as 65 tiles in a 64-tile bank and rm2k-snes-screens stops, instead of fusing or saying which knob"
type: bug
status: todo
---

Seen by Aguará on 2026-10-15, in the study
[`port-zounds-an-rpg-maker-2003-game`](port-zounds-an-rpg-maker-2003-game.md),
with the-advocate `91d55d39`.

**What happens**: `rm2k-snes-screens: the actor choice's windows are 65
8bpp tiles and reach $4820, and their tilemap is at $4800`
(`checks.rs`, `TARGET_TILES_MAX` = 64). It is not the skin's frame nor
the terms drawn in the window —swapping the System for Royal under the
same name and shortening `sp_cost` and `possessed_items` left it at 65—:
it is the window's background. Zounds_System has a 215-colour gradient
there, every cell of the windows is a different tile, and the project had
no `[windows.background] Zounds_System = [...]`, the knob Book of Three
gives Royal. With a three-colour flat fill from the gradient's averages
the stage passes.

**Why it is a bug and not a knob**: `fit::skin_for` fuses the *frame's*
tiles when they do not fit a bank, but the background is not in that
path, and the message names the symptom and not the cause. A game
without the entry should either get the average fill on its own, or be
told "give Zounds_System a `[windows.background]`".

**To reproduce**: build Zounds' measuring project without the entry
(`~/scratch/aguara/zounds/project/rm2k-snes.toml`, last lines).

## Defined

Todo, on 2026-10-16, by Cardón: Zounds goes on since its `rm2k-snes.toml` carries the
`[windows.background]` entry, but a new game with a gradient System stops
with a message that names the symptom.

**Done** means a System with no entry whose windows do not fit their bank
either gets the average fill on its own, noted as a WARNING, or stops
naming the knob —"give <System> a `[windows.background]`"—; the agent picks,
with a test in rm2k-snes-screens over a gradient skin. **First step**: the
check in `checks.rs` and `fit::skin_for`, to see whether the background
can join the frame's path.

## Checked (2026-10-20, Chajá)

Still so at the-advocate `8f290c39`: the message in `checks.rs` names the
tiles and the addresses, not the knob, and `TARGET_TILES_MAX` lives in
`fit.rs` next to `skin_for`. The project file is `advocate.toml` since
2026-10-20 (the ports' `71c4143`): Zounds' entry is in
`zounds/advocate.toml`, and the knob is still `[windows.background]`.
