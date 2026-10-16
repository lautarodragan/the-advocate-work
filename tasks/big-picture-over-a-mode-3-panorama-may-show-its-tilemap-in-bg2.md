---
name: "A big picture over a mode-3 panorama may show its own tilemap in BG2"
description: "In the 'panorama' VRAM layout BG2's base is $4000, where a big picture puts its tilemap; the emptied layer above points at BG2's tile 0, which would be that tilemap. Suspected by reading, not reproduced"
type: bug
status: draft
---

Seen by Hurón on 2026-10-12 reading the code while bringing the book's
`internals/vram.md` up to date ([`three-texts-that-went-stale`](three-texts-that-went-stale.md)),
at the-advocate `25d93f0a`. **Not run, not reproduced**: no game is known
to show a big picture on a map with that layout.

What the code says:

* `LAYOUT_PANORAMA_MODE3` ("panorama", `VENTANA_PANORAMA`) in
  `rm2k-snes/mapdata/src/vram.rs` puts BG2's base at `$4000`: the
  panorama's first stretch, with its tile 0 blank. It is the only layout
  whose BG2 base is below `$5000`.
* `runtime/big_picture.s` puts the picture's tilemap at `BIG_VRAM_MAP =
  $4000` in every layout, keeps BG2's base "where the map has them"
  (`M_BG12NBA_VALUE & $F0`), and empties the layer above's tilemap, so all
  of BG2 names tile 0 — "its tile 0 is blank in every map".
* In that layout BG2's tile 0 is then the first 16 words of the picture's
  tilemap, not a blank tile.

What would be seen: a pattern of one 8x8 tile repeated over the whole
picture, on a map whose panorama goes in mode 3 —and only in the first of
those layouts— when a `ShowPicture` big enough for BG1 is shown.

How to see it: a test page that shows a big picture on a map that
converts with the "panorama" layout (mode 3, background in 256 tiles).

The header of `big_picture.s` also says BG2's tiles are above `$5000` in
every layout, which this layout contradicts: see
[`stale-comments-on-the-vram-layouts`](stale-comments-on-the-vram-layouts.md).

**Checked on 2026-10-16** at the-advocate `759aa0ba`, by Cardón: the code
is as described and nothing has reproduced it. The last paragraph is
stale: `acf3153c` (2026-10-15) fixed the header of `big_picture.s`, which
now says BG2's base is at `$4000` in "panorama" and links this draft.
