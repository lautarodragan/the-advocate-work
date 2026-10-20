---
name: "Zounds: two secret chests share a switch"
description: "The Chest 2 of MiniCave 177 turns on and reads switch 129, Secret- Cofre 1, which is MiniCave 89's chest's: opening either shows the other open without its items"
type: bug
status: doing
assignee: Calandria
agents: [Calandria]
---

taro, on 2026-10-20, in their words, translated:

> The Chest 2 event of the MiniCave map, which uses switch 129
> "Secret- Cofre 1", always shows open. What turns that switch on? Is it
> accidentally shared with another chest?

**Read in the dump** (Hornero, the ports' `zounds/data/` of the day):
the secret chests are each a `Chest 2` on a MiniCave —89 under "5 -
Rocks2" with switch 129 (Secret- Cofre 1, three Manzana Deshidratada),
91 under "1 - Main" with 127 (Secret- Cofre 2), 92 with 130 (Secret-
Cofre 3)—, and **177**, under "6 (Right to 5)", is a copy of 89's that
kept its switch: it turns on and reads 129 and gives Zapatos de Cuero,
three Poción Roja and three Poción Verde. Nothing else in the maps,
common events or troops reads or writes 129. Whichever is opened first
shows the other open, without its items.

taro approved the fix the same day: 177's chest gets a switch of its own,
named "Secret- Cofre 4", one with no name and no use (74 or 197 were free
that day), on both its pages —the one that turns it on and the one that
shows it open—, in the game's own data.
