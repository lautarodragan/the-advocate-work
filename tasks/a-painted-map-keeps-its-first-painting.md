---
name: "A painted map keeps its first painting"
description: "Sunset Over Imdahl's door that opens (26, 36) and its grass field (34) swap their painting with ChangePBG; a painted map carries only its first"
type: feature
status: draft
agents: [Aguará]
---

Seen by Aguará on 2026-10-19, carrying the pictures a map's `ChangePBG`s
name —[`what-is-missing-from-the-panoramas`](what-is-missing-from-the-panoramas.md)—,
with the-advocate's branch `aguara-panorama-change` (from `54ec3daf`).

Sunset Over Imdahl's maps 26 and 36 swap their painting for the same one
with the door open or shut (`PasswaySpringDoorOpen`, `PasswaySummer`), and
map 34 between `GrassField`, `GrassField2` and `GrassField3`. Those maps
go **painted** —the whole map a picture in BG1, a tile per cell, uploaded
as the camera moves: see "A painted map keeps only what the screen shows"
in the book's VRAM page—, and the other pictures travel only with a
panorama on a layer of its own, so they keep the first: the converter log
says "its panorama goes painted, which has no layer of its own to swap",
and the eight `ChangePBG`s stay as `panorama-not-changed`.

What it would take: a painted map's `paint_table` record per painting
—each painting is a whole map's worth of cells, 1,200 tiles for a 320x240
one— and swapping the record and refilling the visible slots, which is
what `paint_load` and the column streaming do on a load.

To see it: on map 26, the door that opens in RM2k stays shut.
