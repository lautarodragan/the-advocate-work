---
name: "A dead enemy does not fade out"
description: "RM2k fades a dead enemy away; the console erases it all at once, and no divergence page tells it"
type: docs
status: draft
---

Seen by Hurón on 2026-10-18, writing the book's "A dead enemy redraws
only its cells" (the book's `huron-optimizations-2`), at the-advocate
`df9a0f9c`.

In RM2k an enemy that dies disappears with a fade. On the console it goes
all at once, in the frames its cells take to upload: `scene_tick` in
`runtime/battle_scene.s` says so ("RM2k makes it disappear with a fade;
here it goes all at once"). It is like that since the scene began to be
composed on the console, in the-advocate `80dbea5f` (2026-09-21), and
that commit gives no reason for it, of cost or otherwise.

No page of the book's `divergences/` tells it: it is a divergence the
book does not have. Seen in any game with battles, on the frame an enemy
dies.
