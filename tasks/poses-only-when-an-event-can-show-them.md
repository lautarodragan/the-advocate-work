---
name: "Poses only when an event can show them"
description: "Every character on a map carries its twelve poses in the cartridge and gets a VRAM slot sized for them, also the NPCs that never move: Dooms 2's map 1 has 16 still NPCs facing down and '31 with their twelve poses'"
type: feature
status: draft
---

Left by Calandria on 2026-10-16, from taro's plan for Dooms 2's map 1
(`dooms-2-slots-and-menu-dont-fit-in-their-bank.md`), tools `30ab0ca6`,
ports `f8aca68`: "a general optimization: poses loaded only when needed".

**What is seen**: in the converter's log of Dooms 2's release, map 1 says
"sprites: 31 characters, 29 slots, 500 tiles in VRAM, 8 palettes; 31 with
their twelve poses in the cartridge". Its 16 NPCs with a graphic are all
still —`move_type` 0, no route, every page facing down— and nobody turns
them: of the twelve poses of each, the map can show one. The same line in
the other maps of the game reads "N with their twelve poses" for every
character, still or not.

**What exists already**: in VRAM, most of it. Still characters share a
slot per (CharSet, index, facing) with only the tiles of that pose, the
distant ones take turns on one, the slots are a cache, and the walking
steps upload their pose in vblank —"Characters and sprites" under the
book's lossless optimizations, and `internals/vram.md`—. And
`poses-without-their-empty-tiles.md`, in testing, stores each pose without
its empty tiles and shares the NPCs' poses whole.

**What this would add**: in the **cartridge**, carrying for each
character only the poses some page of the map can show —one for a still
NPC nobody turns, the four facings for one that turns without walking,
the twelve for a walker—, with the converter deciding it from the pages
and routes as `possible_leaders` decides who can lead. What the log
counts as "with their twelve poses" says how much it would save per map;
it is not measured in bytes here. A page change that gives the event a
route it did not have —a switch— has to be seen by the same analysis, or
the pose is missing when it walks.

**How to see it**: `just cartridges release` in `dooms2/` and the
`sprites:` line of map 1 in `build/release/converter.log`.
