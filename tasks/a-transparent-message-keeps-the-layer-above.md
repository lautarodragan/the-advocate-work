---
name: "A transparent message keeps the map's layer above"
description: "A message with a transparent background hides the roofs and treetops on its lines, because its text takes BG2 there; RM2k draws the text over them"
type: feature
status: todo
---

Asked by taro on 2026-10-19, after
[`show-window-a-window-command-of-our-own`](show-window-a-window-command-of-our-own.md)
made keeping the layer above beside a window a strict requirement.

**What is seen**: a message with a transparent background
(`ChangeMessageStyle`) shows its text over the map, but on its lines the
map's layer above —roofs, treetops— is gone: the message window's HDMA
points BG2, which is that layer, at the window's tilemap for the whole
line (`msg_hdma_build` in `runtime/message_place.s`). With a framed window
it is covered anyway; with a transparent one it shows.

**The idea** (Hornero, not measured): bake the layer above into the text's
own tiles when the message is composed. VRAM probably does not grow: the
text area is already 240 tiles, one per cell and not deduplicated
(`runtime/messages.s`), so each cell would start from the layer's pixels
instead of from transparent. What it costs:

* **CPU**: copying the layer's pixels into each cell before the letters
  are composed over them. The map's BG2 scrolls by the pixel and the text
  cells are aligned to the screen, so a cell straddles up to four of the
  map's tiles. Where the line has no tile of the layer above, nothing to
  copy.
* **Palettes, the hard part**: a BG tile has one 16-colour palette, so a
  cell with a roof under it needs the text's colours and its shadow in the
  roof's palette, or the closest ones —an Adeleine decision, made at
  build time per map—.
* **Where the layer's tiles are read from**: VRAM can only be read in
  vblank; the map's decompressed tiles in WRAM or ROM are cheaper.
* **The map moving while the text is up** (a parallel event, a pan):
  the baked cells would have to be baked again.

**First step**: how many transparent messages the ports show over tiles
of the layer above, and on which maps, before choosing.

## The palettes: the text's colours win (taro, 2026-10-19)

The text keeps its exact colours, and the background gives way: in each
palette of the layer above that a baked cell uses, the entry closest to
each of the text's colours —and its shadow's— becomes that colour. The
layer above changes colour slightly, maybe differently from tile to tile,
and that is less disruptive than text whose colour changes between cells,
however imperceptibly. taro's words: consistency in the text matters more
than in the background.

What that leaves to measure (Hornero): the change is to the palette, so
it is seen on every tile of the map that uses that entry, not only under
the text —done at build time it is permanent on that map; done in CGRAM
while the message is up, the rest of the layer would flicker—. And it
costs one entry per colour the text can take there: the colour codes
(`\c[n]`) a message uses are known when it is compiled, so the build can
say, per map, how many entries each palette gives up.
