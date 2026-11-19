---
name: "Desert Nightmare: the towns run at half speed"
description: "Every map that draws more than ~50 events takes two frames or more per round of the main loop —2.65 on map 62—: the town's streets play at 30 frames a second or less. With no row drawn, map 2 is back at one"
type: bug
status: draft
game: desert-nightmare
agents: [Hurón]
---

Seen by Hurón on 2026-11-19, at the-advocate `62b6e5cb` and the ports
`1ea90bf`, for
[`desert-nightmare-what-it-takes-to-be-playable`](desert-nightmare-what-it-takes-to-be-playable.md).

**What is seen**: each map entered with a door's teleport and played 240
ticks (`~/scratch/huron/dn/sweep.py`), counting the frames between two
`ticks`: 2.0 frames a tick on maps 2, 3, 4, 6, 11 to 14, 43, 59 to 61,
67, 68 and 172; 2.55 on 5 and 2.65 on 62; between 1.2 and 1.8 on 10, 15,
17, 35, 63 to 66, 72 and 121; 1.0 on the interiors. The same played: 2.0
on map 2, 3 and 14. Every map at 2 draws more than ~50 events.

**On map 2 played, with every row's +14 zeroed** —nothing drawn, every
page still running— **1.0**; with the first 70 rows drawn, 1.0; with 80,
2.0. The frame's cost is drawing the events, not running them.

What those events are: the towns' buildings and props, cut in 24x32
pieces of CharSets and placed one per cell over the panorama —3,368 of
the game's 3,977 drawn events never change their look and nobody moves
them—. See the book's research
`ports/desert-nightmare/research/2026-11-19-what-it-takes-to-be-playable.md`.
