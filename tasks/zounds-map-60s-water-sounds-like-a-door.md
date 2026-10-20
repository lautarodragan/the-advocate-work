---
name: "Zounds: map 60's water sounds like a door, because NAU_Splash is a stand-in"
description: "The Water event on map 60 plays NAU_Splash, which the repository never had; on the snes-port branch it is a copy of Close1, like the other NAU_ sounds"
type: bug
status: draft
---

Seen by taro on 2026-10-19 playing the port, and measured by Carpintero the
same day in
[`zounds-desert-flower-plays-in-the-cave`](zounds-desert-flower-plays-in-the-cave.md),
with the zounds clone at `3330c15` (branch `snes-port`) and the-advocate at
`2c350d8f`.

**What is seen**: on map 60 (Derecha (To-East)), in the cave under the
crack, the parallel `Water` event plays `NAU_Splash` twice and Kazar says
he heard water; the console plays a door closing instead of a splash.

**Why**: `Sound/NAU_Splash.wav` is one of the sounds the repository never
had, and on the port's branch it is a copy of `Close1`
(commit `42aa093` there, "A stand-in for each of the 197 assets the
repository lacks"): all 25 `NAU_` sounds are that same file. The ROM plays
what it was given: on map 60, entering it directly or from 59, with and
without the `.msu`, effect place 181 holds `NAU_Splash`'s own bytes —its
ROM sample, or its `.msu` version— and the `PlaySound` starts that row.

See
[`zounds-the-repository-lacks-197-assets`](zounds-the-repository-lacks-197-assets.md).
