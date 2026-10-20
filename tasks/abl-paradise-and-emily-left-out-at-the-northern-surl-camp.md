---
name: "A Blurred Line: Paradise and Emily left out at the Northern Surl Camp"
description: "Map 246 leaves out the two characters a route dresses, events 5 and 6, because with them the rain's colours are lent: the scene goes on without them"
type: bug
status: draft
agents: [Chajá]
---

Seen by Tijereta on 2026-10-20 in the release build of the ports `68bf55b`
(the-advocate `8f290c39`), and still so on the-advocate `3bc68ac4` and the
ports `b5cfc1e` (Chajá, 2026-10-20). It is the third map of
[`characters-a-route-dresses-left-out-where-they-cost-the-map`](characters-a-route-dresses-left-out-where-they-cost-the-map.md),
the only one that fix did not cover: there what the dressed rows cost was
a tile event lent a palette, and here it is the rain.

**What is seen**: on map 246, "Northern Surl Camp", events 5
(`ParadiseChar`) and 6 (`Emily`) draw nothing on any page and a route
dresses them; drawn, the map's rain loses its own colours, so they are not
drawn, and the scene that places them goes on with them missing. Not
looked at on screen, nor compared with the original.

**How to see it**: `just cartridges` in `abl/` and

    grep "map 246: WARNING" build/release/converter.log

says "with them the map loses rain-colors-lent".
