---
name: "A small picture's fifteen colours lose a whole hue"
description: "A face shown as a picture keeps its fifteen most used colours: Unamë's green hair and eyes on Zounds' skill screen come out orange, the skin's"
type: bug
status: draft
---

Seen by Calandria on 2026-10-20, with the-advocate `3bc68ac4` plus the
branch `calandria-skill-screen`, on Zounds' map 190 —the golden
`zounds-skill-screen-down.png` in the ports' `tests/golden/`—, while
doing
[`small-pictures-under-a-big-one-are-hidden`](small-pictures-under-a-big-one-are-hidden.md).

**What it is**: `Zounds_Face_Unamë.png`, 48x48 with 123 colours, has green
hair and green eyes over brown skin. As a small picture it goes in one
sprite palette, and `convert_shown` in `rm2k-snes/images/src/show_picture.rs`
keeps the fifteen colours the picture uses most (`most_used`) and sends
every other to the nearest of them. The skin's shades are each used more
than any green, so the fifteen are all skin and the hair comes out orange:
a whole hue gone, not a gradient banded. `Zounds_Face_Kazar.png`, dark
hair over the same skin, comes out right.

The book already says pictures in sprites have "fifteen colours, counted
by use: gradients get banded" (`divergences/what-pictures-as-sprites-do-not-model.md`);
this is the case that rule does not describe. What would fix it is a
quantiser that keeps the hues —Adeleine's grouping, or a median cut— for
the pictures, as the big ones already have.

How to see it: Zounds' `release`, switch 294 on from anywhere (the skill
screen's common event), then Down: the face in the right panel.
