---
name: "ABL: what still blocks playing it to the end"
description: "A fresh count of what stops A Blurred Line from being played from the start to the ending today: pages left out on the story's path, maps not carried, commands not done, and anything else"
type: research
status: done
assignee: taro
agents: [Cardón]
---

taro, on 2026-10-14:

> a new analysis of ABL, to list which blockers it has today that stop it
> from being played to the end? I suspect very little is missing.

## Log

2026-10-14, Cardón. Base: the-advocate `a7f278e6`, ports `6a9d53c`, book
`7b5c894`, this repo `62f51be`.

**Done**: the research, in the book:
[`ports/abl/research/2026-10-14-what-still-blocks-the-end.md`](https://lautarodragan.github.io/the-advocate-docs/ports/abl/research/2026-10-14-what-still-blocks-the-end.html)
(branch `cardon-the-end` of the book).

* **The ending** is 277 → 288 → 241 ("To be concluded...", the save for
  *Line's End*) → the teaser trailer (256, 268, 299–309) → the title.
* **`release` stops at the first night** (108's fork, `below = 129`):
  about 180 maps of the story are not carried.
* **Every page of the 307 reachable maps compiles** (`culprits` on the
  request of a cartridge with all of them). What stops is the build,
  five times, each one a draft:
  [`abl-the-quarry-timer-does-not-fit-on-108`](abl-the-quarry-timer-does-not-fit-on-108.md),
  [`the-text-measuring-pass-stops-pages-past-256-kb`](the-text-measuring-pass-stops-pages-past-256-kb.md),
  [`abl-the-slot-screen-has-no-room-for-the-last-leaders-names`](abl-the-slot-screen-has-no-room-for-the-last-leaders-names.md),
  [`the-materials-table-has-room-for-21-actors`](the-materials-table-has-room-for-21-actors.md),
  [`abl-the-whole-game-does-not-fit-in-8-mb`](abl-the-whole-game-does-not-fit-in-8-mb.md)
  (8.42 MB asked, 7.70 MB held); and the umbrella,
  [`abl-release-stops-at-the-first-night`](abl-release-stops-at-the-first-night.md).
* **Played**, on a throwaway cartridge built with patched tools and
  `--msu-everything`: the next day (108 → 114), the defender's quarry up
  to "one month later", and the ending from 277 to the title. Captures in
  `/shared/captures/2026-10-14-abl-what-blocks-the-end/` (not goldens).

**Not done**: no fix; nothing committed in the-advocate or the ports —the
experiment's worktrees were removed—. Not played: the other professions,
the second month, Surl, the refinery, Eisen's simulation and the minigame.

**When merging**: the book's branch; nothing to install.
