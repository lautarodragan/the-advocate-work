---
name: "Stale comments on the VRAM layouts"
description: "big_picture.s and vram.rs say things about the layouts that stopped being true when the panorama and painted ones came"
type: docs
status: testing
assignee: taro
agents: [Cardón]
---

Seen by Hurón on 2026-10-12 while bringing the book's `internals/vram.md`
up to date ([`three-texts-that-went-stale`](three-texts-that-went-stale.md)),
at the-advocate `25d93f0a`. Not fixed there: the task was the book's two
pages and one test header.

* **`runtime/big_picture.s`, its header**: "The window's tilemap is in that
  range in one layout" —it is in four: "window" at `$1C00` and three of
  the panorama ones at `$1800`—; "BG2's tiles and the window's are above
  $5000 in all of them" —BG2's base is `$4000` in "panorama"; see
  [`big-picture-over-a-mode-3-panorama-may-show-its-tilemap-in-bg2`](big-picture-over-a-mode-3-panorama-may-show-its-tilemap-in-bg2.md)—.
  It also sends to `tools/port/picture.py` and to `picture.py`'s
  `BIG_PALETTES` for which pictures go there and how: that Python left
  with the converter on 2026-10-02.
* **`rm2k-snes/mapdata/src/vram.rs`**: the doc of `LAYOUT_WINDOW_BOTH`
  says it is "the only one that moves the background's tilemap", and
  `LAYOUT_WINDOW_ABOVE`, the panorama ones and the painted one move it
  too; `Layout::pieces` says "by the names the converter's Python knew
  them by", a Python that left on 2026-10-02.

## Done (Cardón, 2026-10-15)

Fixed in the-advocate `acf3153c` (comments only), on branch
`cardon-vram-comments`: the header of `runtime/big_picture.s` (four
layouts, the BG2 base of "panorama", the `BIG_PALETTES` pointer),
`LAYOUT_WINDOW_BOTH` and `Layout::pieces`. Verified by ABL's release
`abl.sfc` coming out byte for byte the same with the global tools and
with this checkout's `cartridge`: sha256 `b5367669…`.

Left alone: `rm2k-snes/mapdata/src/emit.rs` (~line 1048) still says
`BIG_PALETTES` "in picture.py"; it lives in
`rm2k-snes/convert/src/pictures.rs` now.
