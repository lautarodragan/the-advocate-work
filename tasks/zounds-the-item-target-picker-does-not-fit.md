---
name: "Zounds: the item target picker does not fit"
description: "Using an item in Zounds, the item's name wraps and its windows run under the faces, and the party list's border is cut; taro proposes the item's line on top, in one row, and the party list full width"
type: bug
status: doing
assignee: Aguará
agents: [Aguará]
---

taro, on 2026-11-02, playing Zounds' build of the-advocate `23b413cd` and
the ports `3e4e95d` on the console, with a photo of the screen
(`/shared/captures/2026-11-02-zounds-item-target/taro-on-the-console.webp`),
in their words, translated:

> problems... I don't know how we can fix this screen (use item). Without
> the faces, it would be easy. With the faces... the only thing I can think
> of is moving what is on the left to the top (ideally in a single row), and
> the list of characters being full width

## What the photo shows

The Green Potion used from the item screen, two in the party:

* the item's name, "Poci?n Verde", wraps into two lines, and its `ó`
  comes out as `?` —the item list draws the same names without that—;
* the item's window and the "Tienes: 1" one run under the faces, which
  are drawn over their right border;
* the party window's own frame is cut where the left windows meet it, and
  the highlighted actor's cursor box covers the name and stats but not the
  face.

RM2k lays it out on 320 pixels: 136 for the item and the count, 184 for
the party with its faces. On 256 they do not fit side by side.

## Asked

taro's layout: the item's name and how many one has, on top, in a single
row, and the party list below, full width, faces included.

## Log
