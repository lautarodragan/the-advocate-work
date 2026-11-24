---
name: "A Blurred Line: Paradise and Emily left out at the Northern Surl Camp"
description: "Map 246 leaves out the two characters a route dresses, events 5 and 6, because with them the rain's colours are lent: the scene goes on without them"
type: bug
status: done
author: chaja
agents: [Chajá]
links:
  relates: [abl-forem-left-out-at-the-factory]
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

## Log

### 2026-11-22, Tijereta: no longer so on map 246

Checked in ABL's release build of the ports `89f77b4` (the-advocate
`0ae40e0a`, global tools), the main checkout's and one of my own, byte
for byte equal: `grep "map 246: WARNING" converter.log` finds nothing;
map 246 now says "events 5, 6 draw nothing on any page and a route
dresses them: a hidden row each" and "2 event(s) stay objects, a route
gives it a graphic: 5, 6", so both are drawn. `degradations.json` has
for map 246 only event 11 drawn opaque. Which commit fixed it was not
bisected, and it was not looked at on screen.

The same warning shows now on map 83, for Forem (event 13), which went to
its own draft,
[`abl-forem-left-out-at-the-factory`](abl-forem-left-out-at-the-factory.md).
This one is not moved to `todo`: with nothing left to fix, it can be
deleted, as the README says of a draft something else fixed.

### 2026-11-22, Hornero: done, fixed along the way

Tijereta's check above: map 246 draws both now. It goes to `done`
instead of being deleted because other tasks link to it; its line in
the book's "Known issues" went, and Forem's
([`abl-forem-left-out-at-the-factory`](abl-forem-left-out-at-the-factory.md))
took its place.
