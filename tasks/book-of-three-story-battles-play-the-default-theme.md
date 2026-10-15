---
name: "The Book of Three: the story's battles play the default battle theme"
description: "Each scripted fight sets its own battle and victory music with ChangeSystemBGM, which the port does not do: they all play the database's battle theme"
type: bug
status: draft
---

Seen by Mulita on 2026-10-15, comparing the port with the original's event
data, with the-advocate `fa9d1a14` (and `362d3765` for
`degradations.json`) and the ports `0ca371b`, in The Book of Three.

**What is heard**: before almost every story fight the game changes the
system's battle music —and the battle-end music— with `ChangeSystemBGM`,
and sets it back after. In the port the battle always plays the
database's theme, "intothefireedit". Measured in the port's RAM on map 16:
the original asks for "talisn" there, the port plays "intothefireedit".

**Where**: 40 commands on maps 16, 21, 22, 26, 31, 32, 44, 46, 64, 78, 88
and 89, in `degradations.json` as `system-bgm-not-changed`.
`ChangeSystemBGM` is a declared debt since the survey —"the missing
commands" research, 2026-10-05—; there was no task for this game, where
every story fight relies on it.

**How to see it**: the ports' case `milestone-cauldron` and the song in
RAM (`games.Session.song`) during the first battle.
