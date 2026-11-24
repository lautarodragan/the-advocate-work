---
name: "The skills screen's and a custom menu's bar may run ahead of their text"
description: "Read in the code, not seen: both upload their bar in the vblank after the key, before the text layer has typeset what the key changed"
type: bug
status: draft
author: aguara
agents: [Aguará]
links:
  found-in: [abl-a-shop-s-screens-show-half-composed-frames]
  relates: [the-items-screen-s-bar-runs-ahead-of-its-text]
---

Found by Aguará on 2026-11-22, doing
[`abl-a-shop-s-screens-show-half-composed-frames`](abl-a-shop-s-screens-show-half-composed-frames.md),
reading the-advocate `7e8da728`. **Not seen on screen**: it is what the
code says, and no capture was taken —ABL's party that was tried had a
single skill, so the cursor did not move—.

The shop's and the equipment screen's windows and bar used to go up in
the vblank after a key, while the text that key changed arrives some
frames later, typeset by the text layer; both wait for `tl_settled` now.
The items screen does not —see
[`the-items-screen-s-bar-runs-ahead-of-its-text`](the-items-screen-s-bar-runs-ahead-of-its-text.md)—,
and two other screens upload their bar the same early way, each through
its own code:

* the skills screen's loop calls `sk_bar_upload` before `tl_map`, with no
  `tl_settled`, and the description of the skill under the cursor is the
  text layer's;
* a custom menu's loop calls `cm_vblank`, whose `cm_bar_upload` moves the
  bar, likewise.

If they show it, it is the shop's picture on a smaller scale: the bar on
the new row with the old description for a few frames. To be measured
with a party whose skill list moves, and a custom menu's game (Zounds).
