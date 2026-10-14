---
name: "ABL: release stops at the first night in Paradise"
description: "About 180 maps of the story, from the next day in Paradise to the teaser that closes the game, are not in release; carrying them stops at five limits of the build"
type: feature
status: draft
---

Seen by Cardón on 2026-10-14, with the-advocate `a7f278e6` and the ports
`6a9d53c`, in ABL: research
[`ports/abl/research/2026-10-14-what-still-blocks-the-end.md`](https://lautarodragan.github.io/the-advocate-docs/ports/abl/research/2026-10-14-what-still-blocks-the-end.html).

**What is seen**: `release` ends where Emily says good night after the
grove (108, event 47 of `patches/manual/forks/Map0108.json`, the end sign),
and `[maps] below = 129` carries nothing after. The story goes on for about
180 maps more —the next day (114, switch 396), the jobs, the bandits, the
agency, Surl, the refinery, Eisen's simulation— up to "To be concluded..."
on 241 and the teaser trailer (256, 268, 299–309), which returns to the
title.

**What stops carrying them**, each in its own draft, in the order the build
hits them:

* the quarry's timer on 108:
  [`abl-the-quarry-timer-does-not-fit-on-108`](abl-the-quarry-timer-does-not-fit-on-108.md);
* the text block's measuring pass:
  [`the-text-measuring-pass-stops-pages-past-256-kb`](the-text-measuring-pass-stops-pages-past-256-kb.md);
* the slot screen's names:
  [`abl-the-slot-screen-has-no-room-for-the-last-leaders-names`](abl-the-slot-screen-has-no-room-for-the-last-leaders-names.md);
* the materials' table in far RAM:
  [`the-materials-table-has-room-for-21-actors`](the-materials-table-has-room-for-21-actors.md);
* the space:
  [`abl-the-whole-game-does-not-fit-in-8-mb`](abl-the-whole-game-does-not-fit-in-8-mb.md).

And what the build of the whole game warns about on those maps, without
stopping —tiles fused on 148 and 250, pictures not drawn on 207 and 285,
more walkers than route slots on 207 and 285, WAV songs that only MSU-1
plays—, is section 3 of the research.

**How to see it**: a cartridge in `rm2k-snes.toml` with every map
reachable from 4 and the fork of 108 set aside; the research says how.
