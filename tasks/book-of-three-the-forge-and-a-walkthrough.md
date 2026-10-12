---
name: "Book of Three: the forge, and a walkthrough test"
description: "At the forge's house the NPC asks to forge something, but the fire isn't interactive and the house can't be left; and up to there the game is right, so a played walkthrough test with goldens is worth having"
type: bug
status: doing
assignee: Calandria
agents: [Calandria]
---

taro, on 2026-10-12, playing `/shared/builds/otros-juegos/` (ports
`a8ee168`, the-advocate `25d93f0a`):

* **The forge**: "I get to the forge's house and the NPC wants me to forge
  something, but the fire isn't interactive. I can't leave the house." The
  game is stuck there.
* **Up to there, everything looks perfect** —behaviour, graphics, all—, so
  it is worth an automated test for this game: what works today shouldn't
  break without anyone noticing.

The plan: a walkthrough played from the start up to the forge, with goldens
at its milestones (as ABL's `test_recorrido_golden.py`), which goes red at
the forge today and green with the fix; and the cause of the fire found and
fixed.
