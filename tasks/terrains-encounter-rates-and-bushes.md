---
name: "Terrains: encounter rates and bushes"
description: "The next two parts of terrains-do-what-rm2k-does: a terrain's encounter rate multiplies the steps to a battle, and its bush depth draws the lower part of a character half-transparent"
type: feature
status: doing
assignee: Aguará
agents: [Aguará]
---

The two parts left in [`terrains-do-what-rm2k-does`](terrains-do-what-rm2k-does.md)
—"What is left"— that need no vehicles nor 2003 sounds. That task stays
in `testing` with its first part, the damage; this one takes the next
two. taro, on 2026-11-01, in their words, translated, asked to launch
every pending one that could run in parallel:

> Go ahead! All the ones that can run in parallel without leading to
> conflicts that are too complicated to resolve.

**Done**:

* **Encounter rate**: a terrain's rate multiplies the steps to a battle
  as RM2k does it (easyrpg's `Game_Player` encounter steps), on every
  game; Vampires Dawn's sea, at rate 0, never has a battle; the model in
  `rm2k-snes/battle/src/encounters.rs` and the ROM agree, and ABL's
  `tests/tooling/test_encounters.py` says so.
* **Bush depth**: the lower part of a character on a bush terrain is
  drawn half-transparent, as RM2k does; Book of Three's "Water in
  Tylwyth" and Vampires Dawn's forests; captures looked at.

Each part its own commit, red before.
