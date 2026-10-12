---
name: "The windows' background setting, and the text area from one cell"
description: "Steps 1 and 2 of cheaper-windows: [windows] background in the project, drawn by the converter over one CGRAM entry, and the message window's text area filled from one cell when the background is flat"
type: feature
status: done
agents: [Cardón]
assignee: taro
---

taro, on 2026-10-12: the first two steps of `cheaper-windows.md`, the ones
worth doing even if nothing else is. What each saves, per game, is in
[`research/2026-10-11-the-windows-made-cheaper.md`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-11-the-windows-made-cheaper.html) in the book.

## Worklog (Cardón)

Branches `cardon-window-background` in the-advocate (from `2c7b10ce`) and
the-advocate-ports (from `b3063e2`).

* taro changed the shape while this was being built (through Hornero, the
  same day): the setting is **keyed by the System's name**, not one value
  per game, so `ChangeSystemGraphics` can pick the one of the System that
  is current:

      [windows.background]
      ablskin = "#000000"
      Royal = ["#783f31", "#5a231f", "#421d2d"]

  A System without an entry keeps its own background.
* A gradient is drawn, until step 3, as **its average** —the mean of the
  line its stops draw, ends weighing half—, not its first stop: it is what
  the window looks like from afar.
* The screens stage takes the one colour as `--window-background`, and
  fills the System's 32x32 background square with it: every window drawn
  from the skin gets it, stretched or tiled.
* **Step 2 is one line, not one cell**: the emission writes the text
  area's background once when its four lines are the same
  (`WINDOW_BACKDROP_LINES = 1`), and `prime_line` copies it by DMA under
  every line. A cell filled by the CPU would save 1,888 more bytes and
  cost ~8,000 cycles a line inside `message_tick`.
* The ABL harness passes `--window-background` too
  (`screen_stage._window_background`), or the `_dibujo` tests compare a
  different window from the ROM's.

## Done

the-advocate, branch `cardon-window-background`:

* `a7de613c` the setting: `rm2k-snes-project` (`windows.rs`), the
  converter, `rm2k-snes-screens --window-background`;
* `d049dd4e` step 2: `prime_line` and the emission;
* `de9c8b3c` the tests with invented System names (`test_no_game_names`).

the-advocate-ports, branch `cardon-window-background`: one commit per game
with its `[windows.background]`, the harness and the window's colours test
(12 now), A Blurred Line's map patches (one more colour per background:
16 maps undo colour fusions), the goldens (150, only the (1,1,1) stroke in
the windows and the undone fusions in the maps), and Vampires Dawn back
to `VDBlutsys`.

the-advocate-docs, branch `cardon-window-background`: the decision page,
and the pages that change.

Verified: without the setting the eight games, and A Blurred Line's six
cartridges, byte for byte the same; with it the four already flat ones
too, before step 2. A Blurred Line's suite green with the goldens of step
1 and none moved by step 2; `just arrancan` green for the seven; `just
test` green. Not covered by any cartridge: the four-line path of
`prime_line`, now that every game has the setting.

What is left for `ChangeSystemGraphics` is written in its task.

## To install when merging

`project` changes, so everything that compiles it: `just install` of
`project screens convert cartridge mapdata` at least —`project` is in
every binary—, and the cartridges rebuild.
