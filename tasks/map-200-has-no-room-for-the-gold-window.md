---
name: "The inn of ABL's map 200 shows no gold window"
description: "The gold window goes in objects past the sprite bank and in a free sprite palette, and map 200 has its eight palettes taken"
type: bug
status: testing
assignee: taro
author: huron
agents: [Hurón, cardon]
links:
  found-in: [an-inn-has-no-gold-window]
---

Seen by Hurón on 2026-10-19, building the inn's gold window
—[`an-inn-has-no-gold-window`](an-inn-has-no-gold-window.md)—, with
the-advocate's branch `huron-inn-gold` (`d76bb565`, merged with
`tijereta-inns` at `dec72ff8`) and the ports' `huron-inn-gold`.

The gold window is 44 8x8 objects after the message arrow's two tiles
past the sprite bank, in the sprite palette nobody takes —`arrow_obj` in
rm2k-snes-mapdata—. Of ABL's six maps with a paid inn (20, 72, 78, 112,
200, 348), map 200 has its eight sprite palettes taken by the characters,
so its inns (events 16 and 17) greet without the gold window; "Yes" is
still greyed without the price. The build lists it as
`inn-no-gold-window` in `degradations.json`; the converter's log already
says the same map keeps its message arrow in the window's cells.

How to see it: talk to either inn of map 200 in the release ROM.

What it would take: a palette for the window on the maps that ask for
it —the layout choice in `vram.rs` reserving one when a map's pages open
a gold window, or the window borrowing a character palette on the lines
it covers—. Either changes how the map's characters are packed.

## Comments

### 2026-11-24, Cardón: a question for taro

Still so at the-advocate `8b069fc2`: the build still reports
`inn-no-gold-window` (`rm2k-snes/mapdata/src/main.rs:262`), and ABL's page
in the book lists it in "Known issues".

**What to decide**: what map 200 gives up for its inn's gold window, since
its eight sprite palettes are its characters'. Either way changes how the
map's characters are packed: what is lost for lack of room.

**Options**: (a) the layout in `vram.rs` reserves a palette on maps whose
pages open a gold window, and two characters on map 200 share one (some
colours lost); (b) the window borrows a character palette on the lines it
covers (HDMA; no colour lost, more runtime); (c) leave it: "Yes" is greyed
without the price on one map.

**Recommendation**: (a): the general rule is small and the colours a
shared palette loses are measurable in the build; if map 200's loss shows,
(c).

### 2026-11-28, taro: an answer: (a)

> (a)

### 2026-11-28, Hornero: (a), to todo

To `todo` with (a): the VRAM layout reserves a palette on maps whose
pages open a gold window, and two of map 200's characters share one,
the colours they lose measured in the build. If the loss shows on
screen, (c) is still open.

## Log

### 2026-11-28, Hurón: (a), the pair that loses least

From the-advocate `b4654a3a` and the ports `aaa51a7c`, on branches
`huron-gold-palette` in both.

The sprite palettes are not split in `vram.rs` but in Wally's
`sprites/split.rs`, so that is where the reservation goes. The converter
tells Wally that a map opens a gold window —`gold_window` in its request,
from the compiler's first call, walking each page for `OP_INN 3` as the
emission already did with the real compilation—, and after the split,
while the characters, the battle animation's box and the pictures leave
no palette above them, `join_two` makes two of them one: of every pair it
can join, the one that loses least, counted as `lend` counts a lent
palette (each shown pixel times how far its colour lands). The fifteen
colours are Adeleine's `merge_least_visible` over both, weighed by the
pixels the map shows. Not a leader's palette, nor one with a character
baked into the background (its tiles keep its colours), nor one cut for
the timer. The build says it as a new loss, `palette-shared`: who shares,
how many colours go and how many shown pixels change colour.

#### Map 200's eighth palette was the rain's, not a character's

The first build changed nothing: map 200's characters take seven
palettes, and the eighth is the raindrops' (`rain_drops` in `extras`
pushes one while there is room). So the extras yield first: on a map
with a gold window, the timer, the rain and the sand get one palette
fewer to reach and are lent the nearest colours of one there is, as they
already are when none is left —they are not on screen all the time, the
characters are—; `join_two` only runs if the characters alone still
take them all. On map 200 the raindrops are lent palette 1:
`[16,16,18]` as `[15,15,15]`, `[11,11,13]` as `[11,11,11]`, `[6,6,7]` as
`[6,6,6]` (a hint of blue, only if it rains on screen there).
`rain-colors-lent` goes from 30 to 31 maps, `inn-no-gold-window` from 1
to none. No character shares a palette on any ABL map: `join_two` is
covered only by its unit test, `two_palettes_join_where_they_lose_least`
in `split.rs`.

#### Measured against b4654a3a's own tools

ABL's release built with tools installed from `b4654a3a` and from the
branch, both over the ports' `aaa51a7c`: of the raw files only map 200's
sprite tiles differ, and of `mapdata.inc` only map 200's header
(`SPRITE_CGRAM`, `RAIN_PAL`), its arrow word and the banks' order. Maps
20, 72, 78, 112 and 348 come out byte for byte the same. The captures of
the inn and of the tavern before talking, before and after, are in
`/shared/captures/2026-11-28-map-200-gold-window/`: the tavern is the
same pixel for pixel, the greeting gains the window.

#### Verified, with main merged

the-advocate `huron-gold-palette` at its merge with main (`98da383c`
and the merge), the ports at `7ff51a0b` (no commit of mine: no golden
moved), the book's `huron-gold-palette` (`960916d` and its merge). With
the merge's `advocate` installed locally: `just lint` (SOUNDFONT
FluidR3_GM), `just test`, `env -u SOUNDFONT just rust-test` green; `just
test-game` 230 passed and `test_screen_letters.py::test_the_battle[bsnes]`
red once, "the battle did not reach its commands", green again alone with
`--lf` while the CPU was full; in the ports `just boot` 209 passed and
ABL's `just tests` 1623 passed, 2 skipped. No golden moved: no case looks
at map 200's inn, and the suite does not cover the gold window there nor
`join_two` on a real map.

When merging: `just install advocate` (Wally, the converter and the
emission changed; they are compiled into it).
