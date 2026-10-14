---
name: "Unused items at the start of each game's database"
description: "Do the eight games leave RM2k's default items unused at the start of the item table? A measurement, for a quick fix to the 255-item limit"
type: research
status: doing
assignee: Mulita
agents: [Mulita]
---

taro, on 2026-10-14: "I think in ABL the first entries of each DB table
are the ones RPG Maker brings by default, and surely they are not used.
We could probably 'remove' the first 10–20 items as a quick fix. It is
costlier than ignoring the ones that don't fit, because it means moving
every reference, and the right fix is 2 bytes; but I'd like to know if the
other games also have N unused items, all together, at the start of the
table. Leaving the default entries and never using them was a common
practice."

Context: [`abl-release-stops-at-the-first-night`](abl-release-stops-at-the-first-night.md)
—ABL's whole `release` carries 264 items and the tables hold 255—.

## Log
