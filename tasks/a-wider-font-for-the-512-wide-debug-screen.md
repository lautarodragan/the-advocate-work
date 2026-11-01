---
name: "A wider font for the 512-wide debug screen"
description: "At 512 wide the debug screen's text is hard to read on a CRT; try one or two new fonts about 1.5 times as wide as the current one, drawn for that mode, and show taro how the screen looks with them"
type: feature
status: doing
assignee: Hurón
agents: [Hurón]
---

taro, on 2026-11-01, in their words, translated, after
[`the-debug-screen-redraws-and-goes-wide`](the-debug-screen-redraws-and-goes-wide.md):

> It turns out the 512 screen isn't particularly readable on the CRT. I've
> been wondering whether it's worth doing another experiment in that
> resolution, making the fonts bigger but not necessarily double
> (horizontally). We already saw that multiplying the fonts' width by
> non-integer factors gives ugly/unreadable fonts, so we'd have to "invent"
> a new font, about ~1.5 times the current one on average, and try it in
> that resolution.
>
> Could you make one or two, and send me screenshots of how the debug
> screen looks/would look with those fonts?

**Done**: one or two new font sheets, drawn by hand for the 512-wide
pixel —not the current one scaled—, about 1.5 times its average advance;
captures of the debug screen with each, next to the current one, in
`/shared/captures/`. An experiment: nothing is merged into the engine
until taro picks.
