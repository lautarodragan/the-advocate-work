---
name: "A map's own music ignores its volume and tempo"
description: "The song a map plays on its own, by its properties, is played as written: a map that asks for it at 50% or 70% plays it at full volume"
type: bug
status: doing
assignee: Carpintero
agents: [Carpintero]
---

Seen by Mulita on 2026-10-15, comparing The Book of Three with the
original's data, with the-advocate `fa9d1a14` and the ports `0ca371b`.

**What is heard**: a map whose properties set its music with a volume or
tempo other than 100 plays that song at full volume and normal tempo in the
port. In The Book of Three the South Mountains (map 25) and the northern
world map (82) ask for 70%, and the hills, the Eagle Mountains and the way
out of them (47, 53, 55, 62) for 50%; the port's `BGM_NOW` on map 25 reads
`80 80 00 01`, the level of a song as written. A `PlayBGM` with a volume
is honored: the same RAM reads `52 52` after one at 70% on map 21.

**Where**: `runtime/bgm_level.s` and `music.s` say it in their comments:
"the title, a loaded game, a map's own song plays the song as written". No
divergence page or `degradations.json` entry mentions it.

**How many**, maps with their own music at a volume or tempo other than
100: The Book of Three 6, ABL 18, Vampires Dawn 125, El Dorado 10, Sunset
Over Imdahl 6, The Frozen World 3, Dooms 2 2, Desert Nightmare 0.

**How to see it**: the ports' case `milestone-south-mountains` and
`Session.song_level()` on map 25.

## Defined

Todo, on 2026-10-16, by Cardón: heard in play, in every port —ABL 18 maps, Vampires Dawn
125—. At the-advocate `f4709d0b` `runtime/bgm_level.s` and `music.s` still
play a map's own song as written.

**Done** means a map's own song plays at its volume and tempo, as a
`PlayBGM` with them already does, with `Session.song_level()` on map 25 of
`milestone-south-mountains` reading the 70% —red before—. **First step**:
`git blame` the "as written" comments of `bgm_level.s`, to see whether it
was a decision or only what was there; if it was a decision, ask before.

## Doing (2026-10-19, Carpintero)

`git blame` of the "as written" comments: `d23d2628` (2026-10-01), whose
message says the title's and the maps' songs have a level of their own
"that is not used, noted in the task" —a debt, not a decision—.

**How**: the level a map plays its song at goes with it in a
`map_song_level` table, six bytes per map —gains, step and fade-in, the
units of `OP_BGM`—, which the music's stage writes from the map tree's
node (`Level`, now in rm2k-snes-bytecode's `level.rs`, shared by the event
compiler and the music). Entering a map starts its song at that level; a
map whose song is already playing only changes the level, as easyrpg's
`BgmPlay` does with the same name. And `BGM_NOW` travels in the save, so a
loaded game plays at the level it was saved at instead of as written.
