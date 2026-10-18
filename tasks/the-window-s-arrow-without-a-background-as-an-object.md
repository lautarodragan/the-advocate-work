---
name: "The backgroundless window's arrow as an object"
description: "A window without a background still takes the map's upper layer on its bottom frame row, eight lines across the screen, only to draw the arrow of a message waiting for a key; drawn as an object, that row could be given back too"
type: optimization
status: doing
assignee: Chajá
agents: [Chajá]
---

taro, on 2026-10-18, looking at the captures of
`a-window-without-background-hides-the-upper-layer-only-on-its-text-lines`
(`/shared/captures/2026-10-18-window-upper-layer/`): an improvement, but
the trees under the window, in Core and Manta's memory, still miss a row of
tiles. "Can't we get that one back too?"

What that row is: the window's bottom frame row, eight lines, which the
window keeps in BG2 when the page can show the arrow of a message waiting
for a key (`WINDOW_BAND_ARROW` in `runtime/message_place.s`). The trees'
tops fall on it. If the arrow were an object —it is a few tiles wide, and
the characters do not cover it in RM2k, where it goes over everything—,
that band would not need BG2 and could give the map back as well.

Done means: on a window without a background, the bottom row's lines show
the map's upper layer, with the arrow still blinking where RM2k puts it,
over the characters; measured in a ROM test, and Core and Manta's trees
whole under the window's empty lines.

## Log
