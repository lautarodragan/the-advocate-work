---
name: "A window without a background hides the upper layer only on its text lines"
description: "The backgroundless message window takes BG2 on all 80 of its lines; give the map's upper layer back on the lines with no text"
type: feature
status: doing
assignee: Chajá
agents: [Chajá]
---

taro, on 2026-10-18: a message window without a background takes BG2
—the map's upper layer: roofs, treetops— on all 80 lines of the window,
because HDMA points BG2 at the window's tilemap there (see the divergence
"The window without a background does not cover the characters" in the
book, and `message_place.s` in the-advocate). Proposal, agreed with taro:
on the lines where no text is drawn, BG2 keeps showing the map.

**Done** is the window's HDMA stretches built from the text lines the box
uses, at the granularity of a line of text (with its shadow), so a
one-line message takes about 16 lines instead of 80. Left out on purpose:
the cells left and right of the text on the same line —one tilemap and
one scroll per scanline for BG2; the PPU's windows would show the lower
layer, not the upper one—; that goes written as the measured limit in the
divergence.

**Case to look at** (taro): A Blurred Line, Core and Manta's memory; in its
second part, their talk removes parts of the trees.

## Log
