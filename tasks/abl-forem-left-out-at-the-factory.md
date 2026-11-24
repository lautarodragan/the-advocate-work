---
name: "ABL: Forem left out at the factory"
description: "Map 83 leaves out Forem, event 13, whom a route dresses, because with him the rain's colours are lent: the converter says so, as it said of Northern Surl Camp's Paradise and Emily"
type: bug
status: draft
author: tijereta
links:
  found-in: [abl-paradise-and-emily-left-out-at-the-northern-surl-camp]
  relates: [abl-the-factory-pump-s-light-is-grey, characters-a-route-dresses-left-out-where-they-cost-the-map]
---

Seen by Tijereta on 2026-11-22, grooming
[`abl-paradise-and-emily-left-out-at-the-northern-surl-camp`](abl-paradise-and-emily-left-out-at-the-northern-surl-camp.md),
in ABL's release build of the ports `89f77b4` with the-advocate
`0ae40e0a` and the global tools.

**What is seen**: on map 83, "Dalia at the Factory", event 13 (`Forem`)
draws nothing on any page and a route dresses him; the converter leaves
his row out because with it the map's rain loses its own colours, so the
scene goes on without him. It is the case that draft described for map
246, which no longer shows it, moved here. Forem was drawn from
2026-10-20 on
([`characters-a-route-dresses-left-out-where-they-cost-the-map`](characters-a-route-dresses-left-out-where-they-cost-the-map.md),
paying with the pump's red light,
[`abl-the-factory-pump-s-light-is-grey`](abl-the-factory-pump-s-light-is-grey.md));
when he went back out was not bisected. Not looked at on screen: no test
plays the scene that places him.

**How to see it**: `just cartridges release` in `abl/` and

    grep "map 83: WARNING" build/release/converter.log

says "events 13 draw nothing on any page and a route dresses them, and
they aren't drawn: with them the map loses rain-colors-lent".
