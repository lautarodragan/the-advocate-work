---
name: "Maps with more objects on a line than the PPU draws"
description: "Nothing tells today when a map puts more than 32 objects or 34 slivers on a line; a sweep in the harness over every map of every game, and the PPU's own flags counted in the debug screen"
type: feature
status: doing
assignee: Mulita
agents: [Mulita]
---

Opened by Hornero on 2026-11-17, at the-advocate `7dab7d82` and the ports
`e87e936`, from
[`abl-the-hover-tram-s-crowd-is-cut`](abl-the-hover-tram-s-crowd-is-cut.md):
map 13's crowd was found by taro playing. taro, translated:

> Question: does the build log today the cases where we have more objects
> on a line than the SNES allows?

It does not: the converter does not count objects per line, the runtime
does not read `$213E` (STAT77: range over, more than 32 objects on a
line; time over, more than 34 slivers of 8 px), and no test looks. Two
things, in this order (taro: "Dale!"):

1. **A sweep in the harness**: enter every map of every game, let it
   settle, and count objects and slivers per line from the OAM the way the
   PPU reads it (`sheet.drawn_silhouettes`). Out: a list of the maps that
   go over, with the line, the count and the events on it. No ROM cost.
   Whether it becomes a test (a ceiling per game) or a report recipe is
   part of the decision.
2. **The PPU's flags in the debug screen**: read `$213E` once per frame
   and count the frames with range over or time over, shown in the debug
   screen and readable by the harness, for what the sweep cannot see (a
   scene that adds people while it plays). Its per-frame cost, measured;
   gated like the rest of the debug screen.
