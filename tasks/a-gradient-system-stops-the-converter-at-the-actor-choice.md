---
name: "A System with a gradient under its frame stops the converter at the actor choice"
description: "Zounds' System has 215 colours under its window frame and no `[windows.background]` entry: the actor choice's windows come out as 65 tiles in a 64-tile bank and rm2k-snes-screens stops, instead of fusing or saying which knob"
type: bug
status: draft
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
