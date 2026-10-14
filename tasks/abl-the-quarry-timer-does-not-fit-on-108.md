---
name: "ABL: the quarry's timer does not fit on 108"
description: "With the quarry (150) in the cartridge, the converter gives the timer digits to 108 by walking reach and stops there: its eight sprite palettes are full"
type: bug
status: testing
assignee: taro
agents: [Chajá]
---

Seen by Cardón on 2026-10-14, with the-advocate `a7f278e6` and the ports
`6a9d53c`, in ABL, building a cartridge with every map of the game: see
[`abl-release-stops-at-the-first-night`](abl-release-stops-at-the-first-night.md).

**What is seen**: the converter stops with "map 108: the timer doesn't
fit: the map already uses the 8 sprite palettes it gets and none has room
for its 2 colors". The defender's job at the quarry (150, event 4) starts a
five-minute timer, common event 36 stops it, and the converter gives the
digits to every map it reaches walking from there —see `timer_reach` in
`scan.rs` of `rm2k-snes-convert`—; 150's exits lead to 108. In RM2k the
job can be left, so the timer does run on 108.

With 108 added to `[graphics] timer_never_runs_in` the reach stops at the
town and the build goes on: the digits go to 63 maps, 150 and 151 among
them. What that loses is the timer on screen while Talan walks through 108
in the middle of the job.

**How to see it**: a cartridge with 150 and 108, and the converter's log.

## Log

**Chajá, 2026-10-14.** Tools `51b4b1b2`, ports `d91049e`; branches
`chaja-end-blockers` in the-advocate, the ports and the book.

**The original shows it.** Under Wine, a copy of the game edited with
Ditto to start on 150 with the job's tail (396 and 385 on, the timer at
five minutes shown, 450 and 449): Right from (17,3) into the exit at
(19,2), and 108 has the timer counting (04:53). The exit's page only asks
for 396 and 385, which the job keeps on; when the timer reaches zero
common event 36 brings Talan back to 150 from wherever he is. So Cardón's
line —108 in `timer_never_runs_in`— loses something that is seen.

**Why 108 does not fit.** With every leader of the game, three of its
eight palettes are the leaders' and the other five each lend themselves to
a character with no palette of its own (ten are lent). The split's way out
—bringing a character with a palette to itself down a colour— finds none
alone in its palette, so `timer_digits` stopped.

**What was done**, three commits in the-advocate and one in the ports:

* `wally: the timer is lent a palette when none has room`: the last way
  out is the characters' own. The timer goes to the palette whose nearest
  colours change it least (pixels times `luma_distance`) and each glyph
  colour is drawn with its nearest; a WARNING says it. On 108: palette 3,
  black as itself and (31,0,0) as (28,5,6). Nobody loses a colour. It only
  runs where the build used to stop. Test: `tests/timer_room.rs`, 108's
  shape made up, red before; and `extras`' test that asserted the stop
  became the lending, with the stop kept for all-leaders palettes.
* `convert: [graphics] timer_stays_in`: with 108 open the walk reached
  every cutscene that leaves the town, 283 maps instead of 64, seventeen
  characters losing a colour and Lashe City (13) not fitting at all. A map
  in the list is reached but its pages start with the timer stopped.
  Test in `scan.rs`.
* Ports: `timer_stays_in = [108]` in ABL's `rm2k-snes.toml`, with its why.
  What it loses: the timer in Paradise's houses during the job (the
  tunnel is closed from 396 on, so the town is not left).
* The book: ABL's decision "The quarry's timer stays in Paradise", and
  "The timer has no palette of its own" now says it is lent one.

Discarded on the way: counting the lent guests out of the split's
"single owner" check also fits 108, but it costs Chara1:2 a colour (21% of
its pixels) and a pose bank of its own, all game long, for a timer seen
five minutes; lending costs only the red's shade while it shows.

**Verified**: whole-game experiment (Cardón's diffs, the text pass and
far RAM patched aside, `--msu-everything`) builds past 108 —"map 108:
WARNING, the timer has no palette with room and is lent 3"— and to the
end; a throwaway harness test captured the timer on 150 and, written in
RAM and teleported, on 108. `release` with wally+convert and the toml:
byte for byte `be7d567e…a0e3`. With the whole branch (screens included):
`just tests` 1303 passed, `just boot` 9, `just test` 27; crates wally,
convert and screens green. Captures, original and port side by side:
`~/scratch/chaja/captures/2026-10-14-end-blockers/`.

**Not covered by the suite**: the lending (no map of `release` reaches
it) and `timer_stays_in` (`release` does not carry 150); only their unit
tests and the experiment.

To install when merging: `wally`, `convert` (and `screens`, from the slot
screen's task).
