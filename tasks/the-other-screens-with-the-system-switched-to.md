---
name: "The other screens with the System a game switches to"
description: "ChangeSystemGraphics changes only the message window: the menu, the slot screen, the item, equipment and shop screens, End Game, the battle's windows and the title keep the starting System"
type: feature
status: draft
---

Found by Cardón on 2026-10-12, doing
[`changesystemgraphics`](changesystemgraphics.md) (the-advocate
`cardon-change-system`).

What is seen: Sunset Over Imdahl switches to `SaveMeny` in the opening
(map 11) and keeps it for the rest of the game; its dialogue now comes out
with `SaveMeny`'s white text, and its pause menu keeps `System`'s
windows. Vampires Dawn's menu keeps
`VDBlutsys` whatever style the player picks from the old man in map 27,
and Desert Nightmare's keeps `Systemset_Intro` after `Init`.

How to see it: build Sunset Over Imdahl's `release`, start a new game and
open the menu after the first lines of the opening.

What the converter knows about it: every screen but the message window is
drawn once by `rm2k-snes-screens convert` into its bank, with the starting
System; the divergence is
[What `ChangeSystemGraphics` does not model](https://lautarodragan.github.io/the-advocate-docs/divergences/what-changesystemgraphics-does-not-model.html).
