---
name: "ABL: it does not rain in Paradise"
description: "Map 108 sets rain for the crying girl's scene, and the converter leaves its drops out: its sprite palettes have no room for the three greys"
type: bug
status: testing
assignee: taro
agents: [Calandria]
---

Seen by Chajá on 2026-10-14, with the-advocate `51b4b1b2` and the ports
`d91049e`, in ABL's `release`, while measuring the quarry's timer on the
same map
([`abl-the-quarry-timer-does-not-fit-on-108`](abl-the-quarry-timer-does-not-fit-on-108.md)).

**What is seen**: event 34 of Paradise (108), the autostart that follows
the crying girl (switch 362), starts with `WeatherEffects` rain. In the
port it does not rain there: `converter.log` of `release` says "map 108:
WARNING, the raindrops don't fit in the sprite palettes and it doesn't
rain here". The drops need room for their three greys in a palette that
is neither a leader's nor the timer's, and 108's eight are full.

The same with every map of the game, with or without the timer on 108.

**How to see it**: `just cartridges release` in `abl/` and the line in
`build/release/converter.log`; in the game, 108 with switch 362 on.

## Defined

Todo, on 2026-10-16, by Cardón: a story scene of ABL's `release` without its rain, and the
WARNING is still in `rm2k-snes/wally/src/map.rs` at the-advocate
`f4709d0b`.

**Done** means it rains on 108 with switch 362 on, and the WARNING is gone
from `release`'s `converter.log`, with a golden of the scene. Two ways, the
agent picks and measures: make room for the three greys on 108 (fusing the
map's sprite palettes, as the ground already is), or draw the drops with
greys a palette already has (the nearest three of a leader's or the
timer's). **First step**: what the eight palettes of 108 hold, and how far
each of their greys is from the drops'.

## Log

**2026-10-17, Calandria**, done on the way of
[`rain-drops-cost-a-cache-its-slots`](rain-drops-cost-a-cache-its-slots.md),
on the-advocate's branch `calandria-rain-and-slots`: the second way. A map
whose palettes have no room for the three greys lends the drops one —never
a leader's nor the timer's—, the one whose nearest colours, in CIE Lab,
are closest after taking in the greys it has room for (`lend_to_rain` in
Wally's `sprites/extras.rs`). 108 is lent palette 5, whose only grey is
`[8, 8, 8]`: the three shades are that one. The WARNING is gone from
`release`'s `converter.log`, and it rains on the 32 maps of ABL that did
not draw it, 108 among them; it says `rain-colors-lent` instead.

Not done: the golden of the scene. The paradise-day playthrough photographs
the crying girl but does not bless its photos, and its photo is before the
rain starts. What was looked at is a capture of 108 with the rain turned on
in far RAM, in `/shared/captures/2026-10-17-rain-and-animations/`.
