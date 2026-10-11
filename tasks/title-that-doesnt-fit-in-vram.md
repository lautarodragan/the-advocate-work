---
name: "The title that doesn't fit in VRAM"
description: "Desert Nightmare, The Frozen World and Vampires Dawn start without their title screen: the picture goes past the 544 tiles that title.s leaves it"
type: feature
status: draft
---

Carpintero declared it on 2026-10-06 as a degradation
(`degrade-instead-of-failing.md`, point 5): the converter checks the
title against the limits that `title.s` asserts —544 picture tiles, 704
for the menu— and, if it doesn't fit, the game starts without a title, with
a WARNING. No task follows it.

**Checked today** (the-advocate `fc6f7456`, ports `a85b7e3`, built in a
worktree of their own), from each release's `conversor.log`:

| game | picture | picture tiles |
|---|---|---|
| Desert Nightmare | `Titelbild` | 872 of 544 |
| The Frozen World | `FrozenWorldTitle` | 736 of 544 |
| Vampires Dawn | (its title) | 896 of 544 |

Book of Three (425), El Dorado (206) and Dooms 2 (282) fit. Sunset wasn't
built today.

**What you see while playing**: the game starts straight on its first map,
without the title screen or its New Game / Continue / Quit menu. How a saved
game is loaded in those cartridges wasn't looked at.

**How to see it**: `just cartuchos release` in the game's directory and
`grep "title screen" build/release/conversor.log`.
