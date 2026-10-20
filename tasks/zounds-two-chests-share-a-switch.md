---
name: "Zounds: two secret chests share a switch"
description: "The Chest 2 of MiniCave 177 turns on and reads switch 129, Secret- Cofre 1, which is MiniCave 89's chest's: opening either shows the other open without its items"
type: bug
status: testing
assignee: taro
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

## Done (Calandria, 2026-10-20)

**Switch 74.** It had no name, and nothing in the dump reads or writes it:
no `ControlSwitches` (one by one or by range), no page condition of maps,
common events or troops, no item's or skill's `switch_id`; and the game
has no `ControlSwitches` by variable that could reach it. 197 was just as
free; 74 is the lower.

* **The game** (branch `calandria-chest` of its repository): `Map0177.lmu`,
  event 2, `Chest 2` —page 1's `ControlSwitches` and page 2's condition—
  say 74 instead of 129, and `RPG_RT.ldb` names switch 74
  "Secret- Cofre 4". With `ditto read`/`write`, each file round-tripped byte
  for byte before editing and read back equal to the JSON written.
* **The ports**: the new dump of `zounds/data/` —three values— and
  `tests/test_zounds_secret_chests.py`, a data check that the four secret
  chests (maps 89, 91, 92 and 177, event 2) each turn on a switch of
  their own, read it on their open page, and that it is named
  Secret- Cofre 1 to 4. Red on the old dump —"the chests of maps 89 and
  177 share switch 129"—, green on the new. No ROM case: the console runs
  the two pages like any event's; what was wrong was the switch named.
* **The book**: a bullet in Zounds' "What is fixed in the game itself".

Seen on the way and not a finding: map 35, "BackUp", is a copy of map 34
whose two `Chest 2` share switch 37 (34 gave the second one switch 325),
but nothing teleports to map 35.

Nothing to install when merging: no tool was touched.

**Run**: `just boot -k zounds` in the ports, with `GAMES` pointing at the
game's branch, 30 passed. Not with the global install: the ports' main
(a75f83c) already asks for the battle term `dodge`, which came with the
tools' fd543e73 —on GitHub's main, not yet in the global install—, and
with it Zounds does not build; it ran with Hornero's integration tools
(5971f850). The suite does not play the chests: what holds the fix is the
data check.
