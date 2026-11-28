---
name: "The fade's last black tick uploads songs the map is not playing"
description: "Without MSU-1, a teleport's fade forces up on its last black tick every song of the destination's package, not only the one playing: 5 to 16 frames on Lashe City's doors"
type: optimization
status: todo
author: chaja
game: abl
agents: [cardon]
links:
  found-in: [lashe-city-transitions-lag]
  relates: [frozen-world-every-turn-re-uploads-the-battle-screens-audio]
---

Seen by Chajá on 2026-11-22, measuring
[`lashe-city-transitions-lag`](lashe-city-transitions-lag.md), with
the-advocate `ec672f4c`, ABL's `release` from the ports `cb9f4f5`, on
Mesen2's core, without the `.msu`.

**What was seen**: a map's audio package carries every song its pages can
start. Since
[`frozen-world-every-turn-re-uploads-the-battle-screens-audio`](frozen-world-every-turn-re-uploads-the-battle-screens-audio.md)
a teleport's effects may wait past the fade, but its music may not:
`package_settle` uploads at once, on the fade's last black tick, whatever
music the frozen ticks did not reach —the songs the map is not playing
included—. Entering Lashe City 33,36 (map 9) from 34,35 (8), with
hzstream playing, that tick uploads `cd4`'s and `C3classi`'s samples, 23
KB, **7.5 frames** of black; coming back to 9 from the Lazer Teeth HQ
(11), whose `rshinld` pushed hzstream's neighbours out, **15.4 frames**;
with switch 35 on (EV0054's `PlayBGM cd4` before its jump), 5.4.

With the `.msu` those songs are tracks and nothing goes up.

**What would remove it**: those songs wait like the effects, and a
`PlayBGM` that asks for one uploads it whole then (`song_now` already
finishes what waits before it starts a song), at about a frame per KB.
It trades the door's hitch for one on that `PlayBGM`.

**To reproduce**: `measure.py` in `~/scratch/chaja/lashe-lag/` (the task's
log says how it runs), or walk from 8's (73,56) right into 9 with
hzstream playing and count the frames of the fade's tick 43.

## Comments

### 2026-11-24, Cardón: a question for taro

Without the `.msu`, a door's black lasts
5 to 16 frames longer on Lashe City because songs the map is not playing go
up then (`package_settle`, `runtime/audio_package.s` 661, unchanged since).
Where the wait goes is a choice:

* **a)** leave it: the wait is in the black, where nothing is seen;
* **b)** those songs wait like the effects and go up in the free time of the
  vblanks after the fade; a `PlayBGM` that comes before they are up finishes
  them then, freezing at about a frame per KB;
* **c)** b without the trickle: only on the `PlayBGM`.

Recommendation: **b**: most of the time they are up before anyone asks, and
with the `.msu` none of it happens.

## Log

### 2026-11-24, Hornero: taro chose b

> About the-fades-last-black-tick-uploads-songs-the-map-is-not-playing:
> let's go with option B, the one Cardón suggested.

(taro, 2026-11-24)

To `todo`: the songs the map is not playing wait like the effects and go
up in the vblanks' free time after the fade; a `PlayBGM` that arrives
before they are up finishes them then. The door's black should drop by the
5 to 16 frames measured, without the `.msu`; measure it the same way, and
the `PlayBGM` that has to finish a song, how long it freezes.
