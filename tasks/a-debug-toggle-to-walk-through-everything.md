---
name: "A debug toggle to walk through everything"
description: "In a debug build, Select turns on and off walking through walls, events and tiles, as RPG_RT's test play does holding Ctrl"
type: feature
status: doing
assignee: Carpintero
agents: [Carpintero]
---

taro, on 2026-11-02, in their words, translated:

> Another debug option: _phasing_ or whatever it's called, like the
> original RPG_RT.exe, which, in debug mode, let you hold Ctrl (if I
> remember right) to go through things.
>
> In our case, I think we have the Select button free. Maybe we could use
> it to toggle phasing on/off, no?

## What is asked

* Only in a build with debug on —whatever `[debug]` in a port's
  `advocate.toml` turns on today, as Zounds' debug room—; a release
  without debug behaves as before, byte for byte if it can.
* Select toggles it; RPG_RT holds Ctrl instead, and that difference is
  declared.
* What RPG_RT lets through while it is held is read from
  `~/ref/easyrpg-player` (`Game_Player`, `Game_Character::MakeWay` /
  `IsPassable`, the debug "through" check), not from memory.

## Log
