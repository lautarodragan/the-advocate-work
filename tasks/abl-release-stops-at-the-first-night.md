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

### Hornero, 2026-10-14: release with every map, the next stop

With the four small stops and the space fixed (Tijereta, Chajá,
Carpintero, Calandria), taro asked to carry the whole game in `release`.
Tried on the-advocate `0a7ee197`, ports `c35afbd`: `[maps] below = 352`,
`excluded` with the folders and backups plus the maps Cardón's walk does
not reach (161, 198, 202, 211, 274, 275, 280, 297, 320, 322, 341),
`added` empty, and the fork of 108 removed. The diff is kept in Hornero's
scratch, `whole-release.diff`; nothing was committed.

The converter stops before packing: **"264 items don't fit in one-byte
tables"** (`items_and_battle` in `rm2k-snes/mapdata/src/emit.rs`). The
database has 450; Cardón's whole cartridge passed this check, so what
pushes `release` past 255 is most likely what only `release` carries
—the suite's cases and test maps—, not the debug map (without it, still
264). Not measured further.

The way on: either the item index goes to 16 bits in the tables and the
runtime (the right fix: the game itself may need more than 255 one day),
or `release` counts only the items its pages, shops, troops and cases
really name, if that is below 255 —to measure first—. After that, the
space has to be measured on the real `release`, which carries the cases
too.
