---
name: "ABL: release stops at the first night in Paradise"
description: "About 180 maps of the story, from the next day in Paradise to the teaser that closes the game, are not in release; carrying them stops at five limits of the build"
type: feature
status: testing
assignee: taro
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

### Hornero, 2026-10-14: the whole game builds, on a branch

taro: go on without investing in the stops, with a temporary hard-code.
On the `whole-game` branch of the-advocate (`9c9b0f66`) and of the ports
(`74eb754`), not main: the items past 255 are left out (411, 413–416,
418–421) and an enemy dropping one drops nothing; and an MSU-1 effect
with no rate of its own in a package takes any version of the effect
(`rm2k-snes-audio/src/msu.rs`, which panicked "no entry found for key").
Both marked TEMPORARY in the code.

With that, `release` with the whole game **fits in 8 MB**: 121 of 127
banks, 6 halves of 32 KB free; far RAM 13 B, BSS 20 B, texts 51 KB left.
Delivered to taro as `2026-10-14-74eb754-9c9b0f66`. ABL's suite: 11 red of
1492, not looked at —the two of 108's fork, the farm (two), the mechanic
and tram talks, the tram scene, three of the music ceilings, and the
versioned patches—.

### Hornero, 2026-10-14: in main

The `whole-game` branches merged into main (the-advocate `0255f8f7`, ports
`a6823c8`): `release` is the whole game. ABL's suite 1514 green and 2
skipped, `just boot` 12, `just test` 27, `rust-test` green.

**ABL's pending list**, what was accepted to get here (taro: "degrading
where needed"; what is cheap was fixed, the rest is listed):

* **Items past 255 left out** (411, 413–416, 418–421; a drop of one
  drops nothing): TEMPORARY in `convert.rs` and `emit.rs`. The real fix is
  the item index in 16 bits. Dropping RM2k's 16 default items does not
  help: the cartridge already carries only the referenced ones (see
  [`unused-items-at-the-start-of-each-database`](unused-items-at-the-start-of-each-database.md)).
* **An MSU-1 effect with no rate of its own in a package takes any
  version of the effect**: TEMPORARY in `rm2k-snes-audio/src/msu.rs`, which
  panicked. Not looked at why the rate is missing.
* **Sprites drawn with another's palette** in the tram, the mechanic and,
  visibly, the farm's celebration (villagers with another hair colour),
  now that `release` carries every map: about twenty goldens approved.
* **108's still ones no longer take turns**, so the two tests of taking
  turns on 108 are skipped (`_NO_TURNS_ON_108` in `test_paradise.py`):
  to be pointed at a map that still does, or removed.
* The farm's playthrough ends the next morning (114) instead of the end
  sign, which is gone with the fork of 108.
