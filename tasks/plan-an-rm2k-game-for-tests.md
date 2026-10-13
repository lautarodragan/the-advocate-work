---
name: "Plan: an RM2k game for tests"
description: "A synthetic game, with no copyrighted assets, so the tests of what RM2k does can live with the tools and the runtime and not with ABL"
type: research
status: done
assignee: taro
---

From taro, on 2026-10-02: "start the project of having an RPG Maker
2000 game for tests". Today the tests of "what RM2k does"
(`rom/pruebas/rpgmaker/`) live on ABL's side only because they need a
game. The crates already have small games in `tests/game/`. It's a plan, not
code: the tasks come out of it.

# taro's direction (2026-10-02)

"When these are finished, I'd like to go ahead with the test game, if
Leñatero finds it feasible":

1. **First, everything of ABL in a single place, outside this repo**: a repo
   of its own, with its history.
2. **Then, 100% original tests in this repo**, with no references to ABL
   nor copyrighted assets.
3. **The assets**: EasyRPG's RTP replacement
   (https://easyrpg.org/rtp-replacement/), other free assets —taro has
   sites saved—, or made up for now; sound effects that taro
   can make in FL Studio; and MIDIs of public domain works (Bach,
   Beethoven, Mozart), with the file's licence verified.

## While working (Leñatero, 2026-10-02)

* The base suite: `just tests --junitxml=…` gives 999 in 86.5 s, 643
  CPU-s. Without the engine's ones (`--ignore` of each M1 and M2 file), 394 in
  73 s and 351 CPU-s.
* The synthetic game was written as an exact Ditto dump (~8 KB of
  JSON and text, with a generator of about 120 lines) and built a cartridge that
  boots and walks, with EasyRPG's RTP and FluidR3. To get there six
  ABL assumptions in the tools had to be dodged: they go into the study.
* taro, through the coordinator, the same day: the first phase is moving ABL out to a
  repo of its own; then, 100% original tests. The study includes it.

## Result

The study is [`research/2026-10-02-the-test-game.md`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-02-the-test-game.html). The short version:

* Of the 999 cases, 605 in 80 files are the engine's and can be written
  against a synthetic game; 208 in 20 run on both games; 186 in 38
  are ABL's.
* The game is written as an exact Ditto dump, without an editor nor `.lmu`,
  with the assets of EasyRPG's RTP replacement (CC0 and CC-BY 4.0) and
  FluidR3 (MIT); the battle backgrounds and the enemies are made up.
* Five phases: ABL to its repo with `git filter-repo`; the minimal game with the
  seven ABL assumptions fixed and the harness split; the rest of M1; M2
  with assets; M3 on both. The tasks that come out are at the end of the
  study, not created: taro decides them.
* ABL goes down from 643 to 351 CPU-s, but from 86.5 to 73 s of wall clock.

**When merging there's nothing to install**: it's a document and this task.
`just tests` gave 999 green on this tree, and `just -f tools/justfile
test` 36.

# ABL's history: without filter-repo (taro, 2026-10-02)

"I'm not sure I'm that worried about git-filter-repo. For now, we still have
the git log here, and what will be left on ABL's side should be very little".
ABL's repo is born from scratch with today's files, and the history stays in
this repo.
