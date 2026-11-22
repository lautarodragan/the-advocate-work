---
name: "A painted map's columns may go up over a big picture's tiles"
description: "paint_flush uploads a painted map's new columns and rows in every vblank, also with a big picture up, whose tiles share VRAM with the painting's slots; the map's own strips are dropped then. Suspected by reading, not reproduced"
type: bug
status: draft
author: mulita
---

Seen by Mulita on 2026-11-22 reading the code while fixing
[`desert-nightmare-the-menu-s-face-is-lost-on-painted-maps`](desert-nightmare-the-menu-s-face-is-lost-on-painted-maps.md),
at the-advocate `0ae40e0a`. **Not reproduced**, so there is no capture:
in Desert Nightmare's menu the camera does not move, and a probe that
moved the hero 64 pixels with the face up on map 4 left the camera, VRAM
and the screen as they were.

What the code says:

* `runtime/big_picture.s` puts a big picture's tiles from VRAM word 0 to
  `$3FFF`, over the map's, and says the vblank does not upload "strips of
  the map" while it is up: `big_vblank` drops `col_addr` and `row_addr`.
* A painted map's slots are `$1000` to `$3000` (`LAYOUT_PAINTED` in
  `rm2k-snes/mapdata/src/vram.rs`), and their uploads are not those
  strips: `paint_tick` queues the columns and rows the camera uncovers, and
  `paint_flush` uploads them from `flush_video` (`runtime/vblank.s`)
  **before** the question of whether a big picture is up, without asking
  `BIG_FLAGS`.

What would be seen: on a painted map whose camera moves while a big
picture is up —a scene that pans with a picture over it—, the picture
with a column or a row of cells of the painting in it, until it is erased
(erasing reloads the map, and `paint_load` rebuilds every slot). The fix
that suggests itself: `paint_flush` drops its queue while `BIG_ON` is set;
`paint_load` on the way back starts over from the camera.
