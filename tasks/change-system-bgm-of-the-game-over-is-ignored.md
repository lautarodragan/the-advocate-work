---
name: "ChangeSystemBGM of the Game Over is ignored"
description: "Dooms 2 gives the Game Over screen another song once; the port keeps the database's"
type: bug
status: todo
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

## Defined (2026-10-20, Tijereta)

Checked against the-advocate `8f290c39` and the release builds of the
ports `68bf55b`: still so. `CHANGE_SYSTEM_BGM` in
`rm2k-snes/events/src/compile.rs` carries slots 0 and 1 as
`OP_SYSTEM_BGM` and loses the others with a comment that names the Game
Over; Dooms 2's `degradations.json` has its one `system-bgm-not-changed`.
It is one command in one game, but the battle's two slots left the way
paved: the state that travels in the save (`runtime/bgm_level.s`) and the
song carried apart. **Done**: slot 6 is carried like 0 and 1, the Game
Over screen plays the song the last `ChangeSystemBGM` gave it, and Dooms
2's build no longer lists the loss; a compiler test for the slot, and the
line in "Known issues" of Dooms 2's page in the book removed. **First
step**: where the Game Over screen picks its song in the runtime, and
whether that song's samples can go up there as the battle's extra one
does.
