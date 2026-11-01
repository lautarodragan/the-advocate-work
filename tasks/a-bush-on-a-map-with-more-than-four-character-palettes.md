---
name: "A bush on a map with more than four character palettes"
description: "The hero's feet in a bush stay opaque on a map whose characters take sprite palettes 4 to 7: the color math would blend them too"
type: bug
status: draft
agents: [Aguará]
---

Found by Aguará on 2026-11-01, doing
[`terrains-encounter-rates-and-bushes`](terrains-encounter-rates-and-bushes.md),
with the-advocate `e1627246` and the ports `e0659e1`.

**What is seen**: on The Book of Three's map 56, *Tylwyth Teg*, the hero
walks into the water —terrain 11, "Water in Tylwyth", `bush_depth` 2— and
is drawn whole; in the original its lower half is half transparent. The
same on Vampires Dawn's maps 201, 236 and 240 with the Giftwasser (depth 1)
and on A Blurred Line's map 5, *Core Retrospective*, in the forest (depth
1). On The Book of Three's 84 and Vampires Dawn's 435 it is drawn.

**Why**: the console draws a bush with the color math, which blends every
object in sprite palettes 4 to 7, and on those maps the characters take
eight or seven palettes: blending would turn the ones in 4 to 7 half
transparent too while the hero stands in the bush, so `bush_oam` refuses.
See "What a bush does not model" in the book's divergences.

**What would do it**: limiting the math to the feet —a color window for
the columns and an HDMA channel for the lines—, which needs a channel free
while a message is up, or the leaders' palette in 4 to 7, which is where
the pictures and their color math are. Each has its own cost.

**How to see it**: the debug map to Book of Three's 56 and a step into the
water; or ABL's `tests/rpgmaker/test_bush.py`, which guards that the feet
stay whole there.
