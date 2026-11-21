---
name: "A transparent message under a moving camera keeps the layer above"
description: "A window without its background carries the map's layer above only with the camera still on the 8-pixel grid; one that opens while the camera moves takes the layer off its lines, and one under which it moves keeps a stale copy"
type: feature
status: wishlist
author: taro
---

Split from
[`a-transparent-message-keeps-the-layer-above`](a-transparent-message-keeps-the-layer-above.md)
by Aguará on 2026-11-14, as taro asked on 2026-10-19: the camera moving
while the text is up is out of the first phase.

**What is seen**: the console carries the layer above inside the
window's plane on the lines of a message without its background
—`runtime/message_layer.s` in the-advocate—, copying the layer's
tilemap entries and composing the cells with letters over the layer's
pixels. That needs the window's cells on the map's: the camera on the
8-pixel grid, which is where it always is at rest. So:

* **A window that opens with the camera between two cells** —a pan, a
  route walking the hero, the shake— keeps the old look: the layer goes
  off its lines across the screen.
* **A window under which the camera moves** keeps what it copied: the
  copy stays where it was on the screen while the map scrolls under it,
  for as long as the box is up.

taro remembers no such case in A Blurred Line, and the text would be hard
to read anyway.

**What it would take**: a camera off the grid is a text moved up to seven
pixels or a composer that draws it shifted, three cell rows a line —see
the parent task—; and a camera that moves under the box is the copy
read and composed again each time it crosses a cell, or the old look from
then on. Neither is measured. The parent task also asked the build to warn
on every map where the camera can move while a transparent message is
up, which needs the events' static analysis of
[`a-transparent-message-baked-only-where-it-can-be-shown`](a-transparent-message-baked-only-where-it-can-be-shown.md);
it is not there.
