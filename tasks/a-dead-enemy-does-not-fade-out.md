---
name: "A dead enemy does not fade out"
description: "RM2k fades a dead enemy away; the console erases it all at once, and no divergence page tells it"
type: docs
status: todo
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

## Defined (2026-10-20, Tijereta)

Checked against the-advocate `8f290c39` and the book at `8c5c4c0`: the
comment is still in `scene_tick` (`runtime/battle_scene.s`) and no page
of `src/divergences/` tells it. **Done**: a divergence page in the book,
`src/divergences/<slug>.md` with `## What` and `## Why` —why it goes at
once: what a fade would cost, or that nobody tried it— and its line in
`src/SUMMARY.md`. Making the enemy fade, if that is worth it, is another
task. **First step**: `git log -S` on that comment for any reason given
at the time, and what easyrpg's `Sprite_Enemy` does (how many frames).
