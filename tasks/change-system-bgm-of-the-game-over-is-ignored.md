---
name: "ChangeSystemBGM of the Game Over is ignored"
description: "Dooms 2 gives the Game Over screen another song once; the port keeps the database's"
type: bug
status: draft
---

Seen by Carpintero on 2026-10-19, counting `ChangeSystemBGM` over the nine
dumps, with the-advocate `carpintero-music` (from `9592b88b`) and the ports
`carpintero-music` (from `c420032`).

The battle's and the victory's slots are done since then; the others are
still `system-bgm-not-changed` in `degradations.json`. Of those, the only
one a port shows is **Dooms 2's Game Over** —slot 6, "Everlasting battle
with Jack", one command—: losing after it plays the database's Game Over
song. (Zounds changes a vehicle's once, and the port has no vehicles; no
game changes the inn's.)

**How to see it**: `degradations.json` of Dooms 2's `release`, kind
`system-bgm-not-changed`.
