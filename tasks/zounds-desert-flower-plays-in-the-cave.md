---
name: "Zounds: Desert flower plays in the cave and elsewhere"
description: "Inside the crack's cave Zounds_Dungeon_1 starts right, but a screen or two to the right Desert flower plays instead; taro saw the same outside it, always Desert flower"
type: bug
status: doing
assignee: Carpintero
agents: [Carpintero]
---

Seen by taro on 2026-10-19, playing Zounds' delivery of that day (the ports `1182513`, the-advocate `2c350d8f`).

**What is seen**: entering the first dungeon (inside the crack) the right
song plays, `Zounds_Dungeon_1`; walking one or two screens to the right,
Desert Rose (`18 - Desert flower`) starts. taro finds no map of the
dungeon that sets it. They think the same happened on other maps outside
the crack, always with that song.

**A lead** (Hornero, read in the dump, not measured): the cave's maps
—58 Caída, 52 Cueva, 51 Entrada de la Cueva and their children, 60, 68,
69, 70, 78…— all say "same as the parent" (`music_type` 0), and going up
the tree the first that names a song is 33 Mountains, `18 - Desert
flower`. Whether RM2k resolves it the same way and the game plays the
dungeon's song with events, and what our runtime does differently, is the
question.

**Also, from the same session**: the `Water` event on map 60 (Derecha
(To-East)) plays `NAU_Splash` in a loop, and the ROM plays a different
sound. Is it one of the sounds left out?
