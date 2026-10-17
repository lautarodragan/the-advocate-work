---
name: "The raindrops cost a cache its slots"
description: "Rain is drawn whenever its greys fit a palette, before the cache counts its slots: Vampires Dawn's 51 gives up 21 animations for it and its 163 has events waiting"
type: bug
status: doing
assignee: Calandria
agents: [Calandria]
---

Seen by Calandria on 2026-10-16, with the-advocate `8c6a345b` and the
ports `059ddcd`, measuring
[`abl-the-sixty-one-torches-of-map-148-stand-still`](abl-the-sixty-one-torches-of-map-148-stand-still.md).
Read from `degradations.json` and `wally map`, not played.

**What it is**: the drops go at the next row of four blocks after the
sprite bank (`rain_drops` in wally's `sprites/extras.rs`), and the cache
gets the slots that are left after them. Rain is drawn whenever its three
greys fit a palette; nothing weighs it against the slots it takes. With
the fix for empty pages that turned, palettes freed up and fifteen
Vampires Dawn maps got their rain back, and two of them lost something
else for it:

* **51**: the cache goes from 30 slots to 26, animating would make four
  events wait, so its 21 still events that animate stand still.
* **163**: the cache goes from 14 slots to 11, and up to two events wait
  for one.

Sunset Over Imdahl rains on most of its maps and had this before the fix:
2, 3, 4, 12, 13, 14, 15, 56, 57 and 58 have events waiting, and 1, 2, 3,
12, 13, 14, 15 and 46 still events standing still, with the rain.

A proposal is on the-advocate's branch `calandria-rain-before-slots`
(`836861f0`, on top of the fix): a map that rains and loses either is
converted again without the rain, and that one goes if it loses less of
both and nothing else. Its commit has what it changes in both games:
Sunset loses the rain on twelve more maps. Which loss is worse is taro's.

**How to see it**: `just cartridges` in `vampires-dawn/` with the fix, and
maps 51 and 163 in `build/release/degradations.json`.

## taro's decision

taro, on 2026-10-17: the rain is not given up. If both do not fit, the
animations go —so `calandria-rain-before-slots` is not merged—, but first
look for ways to keep both, also when it rains.

## Log
