---
name: "Zounds: sleeping in Uname's bed leaves the screen black"
description: "Sleeping in the bed of Uname's room fades the screen out and it never fades back in; the next map's music plays"
type: bug
status: testing
assignee: taro
agents: [Aguará]
---

taro, on 2026-10-17, playing Zounds on Mednafen (delivery of that day,
the-advocate `69e3be10`, the ports `71a6afd`): in Uname's room, sleeping in
the bed fades the screen out and it never fades back in. The next map's
music plays fine, so the game goes on: taro suspects the tint/fade, or an
autostart event on the next map that does the fade-in and whose page does
not compile.

## Log

## Work (Aguará, 2026-10-17)

Worktrees in `~/scratch/aguara/bed/`, branches `aguara-zounds-bed` from
the-advocate `69e3be10` and the ports `71a6afd`.

**The chain**: map 17's bed is events 7 (16,4) and 8 (16,5), "Dormir",
action key; their page 2 (switch 40) is the scene: two boxes,
`EraseScreen` (random blocks, a fade here), the CharSet, `ShowScreen`, a
route, `EraseScreen -1`, `FadeOutBGM`, a wait of ten seconds,
`PlayBGM Zounds_Dream` —the music taro hears—, switch 45, the CharSet,
`ShowPicture fog2`, and `Teleport` to map 30 (45,35). Map 30, "Sueño 2
(Hover Tram)", is the dream: its autostart (event 1) shows the screen,
and its timer page (event 14) sets switch 47 and teleports back to 17.

**The cause**: map 30 is not in the cartridge. Zounds' `rm2k-snes.toml`
excludes it —200x200, its grid does not fit WRAM: the todo
[`a-200x200-map-does-not-fit-the-cell-stream`](a-200x200-map-does-not-fit-the-cell-stream.md)—,
so the converter compiles the `Teleport` as the box "Teleport to missing
map 30" and the page goes on on map 17 (`teleport-to-missing-map` in
`degradations.json`). But the screen is erased right then, and an erased
screen is black under the windows too —as in RPG_RT, where the
transition is drawn above them (easyrpg's `Priority_Transition`)—, so
the box that was meant to show the hole waits for A in the black, and
after it nothing shows the screen again. Nothing on map 30 is to blame:
it is never loaded.

**Reproduced** (snes9x, `release` built with the tools of `69e3be10`):
from control on map 7, a jump to map 17 at (15,5), switch 40 on by hand,
A on the bed. The second `EraseScreen` ends at tick 5113 with brightness
0, the dream's song starts at 5716, the box opens at 5725 with
`SCREEN_ERASED` at 1 and brightness 0, and at 5729 the player has
control on a black map 17.

**The fix** (the-advocate `aguara-zounds-bed`): the compiler's
`compile_missing_teleport` puts a `ShowScreen` with the cut before the
box, which does nothing unless an event erased the screen. With it the
box shows over the room, and after it the room is under the dream's
`fog2` picture —the page put it up before the jump; in the original it is
over map 30— with the dream's song.

**What it does not fix**: the story stops there. Only the dream (map 30's
event 14) turns on switch 47, which map 17's autostart page 3 waits for,
so the game goes on only with map 30 in the cartridge: that is
[`a-200x200-map-does-not-fit-the-cell-stream`](a-200x200-map-does-not-fit-the-cell-stream.md),
where I left what map 30 is made of.

### Delivered

* the-advocate `aguara-zounds-bed`: `a6a0f639`, the compiler, its unit
  test, `python.json` (the compilation's and the scan's `maps`, on
  purpose; python.rs's header says so), and the test game's case
  `missing-teleport` with `test_missing_teleport.py`, red before (both
  cores: the box up with `SCREEN_ERASED` at 1) and green after.
* the ports `aguara-zounds-bed`: `40b81a8`,
  `test_sleeping_in_unames_bed_the_screen_comes_back` in
  `tests/test_zounds.py`, red with the tools of `69e3be10` and green with
  the branch's.
* the docs `aguara-zounds-bed`: `a09e8d4`, the divergence "A teleport to a
  map not carried", the stale paragraph of `internals/events.md` (it still
  said such a page is not emitted), and Zounds' known issue of map 30,
  which now says where it shows.
* Captures in `/shared/captures/2026-10-17-zounds-bed/`, with a
  `README.txt` and `sheet.png`.

### What to install when merging

`events` (`just install events`).

### What was run, on the branches (main had not moved), with `events` installed locally

* `just crate-test events`: green.
* `just test` (29 passed), `just test-game` (40 passed, 1 skipped; the
  new case red with the global tools of `69e3be10`, both cores).
* ABL's `just tests`: 1565 passed, 2 skipped; no golden moved.
  `abl.sfc` `06fe346c94c5…` (sha1).
* `just boot` at the ports root: 62 passed, with the new Zounds test.

Not covered: a `RecallToLocation` whose map is not carried, not looked
at; and the rest of the game past the bed, which needs map 30.
