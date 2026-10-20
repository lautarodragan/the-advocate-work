---
name: "Zounds: the ship's transparent messages come out broken"
description: "On the ship (map 21), the boss's speech about Unamë's donation is shown in transparent boxes in the middle of the screen, and the text comes out torn in bands over the map; the choice after it too"
type: bug
status: doing
assignee: Chajá
agents: [Chajá]
---

taro, on 2026-10-20, in their words, translated, with three captures
(in `/shared/captures/2026-10-20-zounds-ship-messages/`):

> These texts come out quite broken. They are on the ship, before
> reaching the desert for the first time, when the boss tells the crew
> about Uname's "donation". I don't know if they have a ShowPicture and
> it ends up like that, or if it's the System, or because it tries to
> use a transparency, or what.
>
> I wouldn't complicate things much if VRAM is limited — I'd look for
> the cheap options.

**Read in the dump** (Hornero): map 21, event 9 "Kazar", page 1, sets
`MessageOptions` to a transparent window in the middle
(`10120 [1, 1, 0, 0]`) before Unamë's "Lo mato. Lo mato. ¿Lo mato?" and
its `ShowChoice`, and back to an opaque one at the bottom
(`[0, 2, 1, 0]`) after. No `ShowPicture` there. The converter says of
map 21: "the message arrow stays in the window's cells, and a window
without its background keeps the layer above off its bottom row: its 8
sprite palettes are taken", and it has five panoramas.

**Done**: the cause found; the cheapest fix that reads well —from
fixing the transparent window on this map, to, if that costs VRAM or
more than it is worth, a port patch of map 21 that makes these boxes
opaque—, with taro's preference for cheap noted. A golden of one of
these boxes red before.
