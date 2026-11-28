---
name: "A door decompresses the whole bytecode of the map it leaves"
description: "When a page goes on after a Teleport —every door—, code_carry_after decompresses all of the left map's bytecode: Desert Nightmare's maps carry ~14 KB each, some two to five frames per door"
type: refactor
status: testing
assignee: taro
agents: [cardon]
author: cardon
links:
  found-in: [maps-load-faster-without-losing-anything]
  relates: [lashe-city-transitions-lag]
  found: [a-door-that-shows-the-screen-after-its-jump-still-carries-the-maps-bytecode]
---

Seen by Cardón on 2026-10-18, measuring
[`maps-load-faster-without-losing-anything`](maps-load-faster-without-losing-anything.md),
with the-advocate `b066b885`, in snes9x.

**What was seen**: a page that goes on after its `Teleport` keeps running
from the map it left, so `code_carry_after` (`runtime/decompress.s`)
decompresses that map's bytecode stream into `CODE_CARRY` at the end of
the load, all of it, though the page needs only its own stretch. Every door
of RM2k is such a page. The streams, from each game's `map_code` table:

    game                 maps   median     p90      largest
    Desert Nightmare      189   14151 B   14778 B   16076 B
    A Blurred Line        313     238 B     975 B   12175 B
    Zounds                188     120 B     526 B    4451 B

In Desert Nightmare, where the harness's jumps happened to find a page
running, that step was 4.8 frames of every load on average. In ABL it is
negligible except for its few big maps.

**To reproduce**: Desert Nightmare's `just cartridges`, and a door of any of
its maps; the time is the step from `code_carry_after` in
`enter_map_no_events`, with the probe described in that task's log.

## Comments

### 2026-11-24, Cardón: a question for taro

Still so at `8b069fc2`: `code_carry_after` (`runtime/decompress.s`)
decompresses the carried map's whole stream with one `lz2_decompress`
whenever `CARRY_MAP` is set, which `code_carry_before` does whenever a
foreground page is active. Measured: 4.8 frames a door in Desert
Nightmare, 0.6-1.6 in Lashe City.

**To decide**: whether it is worth it. (a) The cheap one: not carrying
when the page's next opcode is its end —probably every plain door; not
checked—. (b) A stream per page or per group of pages for big-bytecode
maps: ROM and converter complexity. (c) Leave it.

**Recommendation**: (a) as a todo, measured on Desert Nightmare; (b) only
if (a) leaves doors slow.

### 2026-11-28, taro: an answer: (a)

> (a)

### 2026-11-28, Hornero: to todo

taro chose (a): to `todo`. Not carrying when the page's next opcode is its end, measured on Desert Nightmare's doors before and after; (b) only if (a) leaves doors slow. Not started.

## Log

### 2026-10-20, Tijereta: checked

Still so at the-advocate `8f290c39`: `code_carry_after`
(`runtime/decompress.s`) decompresses the carried map's whole stream with
one `lz2_decompress`, and `maps-load-faster-without-losing-anything`
(`testing`) left it as it was. What to do is not decided: the stream is
LZ2 and cannot start at the page's stretch, so it is either a stream per
page or per group of pages for the maps whose bytecode is big, or not
carrying it when the page has nothing left after its `Teleport` —not
checked whether a door's page does, nor whether the runtime already skips
that case—.

### 2026-11-22, Chajá: in Lashe City

Measured in [`lashe-city-transitions-lag`](lashe-city-transitions-lag.md)
at the-advocate `ec672f4c`: `code_carry_after` is 0.6 frames on Lashe's
doors and 1.6 leaving the Lazer Teeth HQ (map 11, 7 KB of bytecode).
Still small next to the load's LZ2.

### 2026-11-28, Cardón: (a), and how many doors it reaches

Branches `cardon-doors` in the-advocate (from `b4654a3a`) and in the ports
(from `aaa51a7c`).

`git blame -C --diff-algorithm=histogram` on `code_carry_before`: the
foreground part is `14139ad9` (2026-10-01, the bytecode behind the grid,
carried), its call-stack frames `3ad8a901`, and `cf205c12`'s depth. It
carries every page halfway through on purpose, with no look at what is left
of it: nothing there says the plain door was considered.

**How many doors (a) reaches**, counted on each game's dump with a
throwaway script (`~/scratch/cardon/doors/py/doors.py`): for each
`Teleport` of a non-parallel page, what runs next, past the block ends and
the jumps an `else` or a choice's option leaves —what the compiler turns
into `OP_GOTO`—.

    game              foreground Teleports   page ends right after   goes on
    Desert Nightmare          663                    156               507
    A Blurred Line            941                    550               391
    Zounds                    718                     55               663

What goes on, most of it: in Desert Nightmare `ShowScreen` (452) —its
doors are `EraseScreen`, a sound, `Wait`, `Teleport`, `ShowScreen`—; in
Zounds `ShowScreen` too (568); in ABL `TintScreen` (124) and `PlayBGM`
(106). Counting only the plain doors —one page, no condition, a touch or
action trigger and a single `Teleport`, no branch before it—, Desert
Nightmare has 363, and **3** end right after the jump: 345 end with
`ShowScreen`. ABL has 318, and 218 end right after the jump.

So (a) is almost every door of ABL and almost none of Desert Nightmare's.

### 2026-11-28, Cardón: done, `7a4faa29`

`code_carry_before` asks `ends_after_jump` first (`runtime/decompress.s`):
if the foreground page's next opcode, through up to four `OP_GOTO`s —what
an `else` or a choice's option leaves behind a branch that jumps—, is an
`OP_DONE` with `call_depth` at zero, the page is pointed at an `OP_DONE` in
the cartridge (`ends_here`) and nothing is carried. It is not ended there:
it still ends on the frame after the load, as it did carried, so the new
map's automatic events start on the same frame. A page inside a call is
carried as before. ABL's bank 1 pays 55 bytes (`just cartridges release`:
1099 to 1044 B left in its tightest bank); Desert Nightmare's tightest bank
does not move.

**The test**: `test-game/tests/test_plain_door.py`, two cases in both
cores: the lookout's dispatcher (an automatic page whose only command is
the `Teleport`) and the guide's teleport (the last command of a
`ShowChoice`'s option: the `OP_GOTO` path). Each asks that `CARRY_MAP` is
`$FFFF` once the player has control on the new map. Seen red with the
runtime of `b4654a3a`: `CARRY_MAP` was map 10 and map 1. The carried path
stays covered by `test_panorama_swap.py`, which asks that a page that goes
on is carried.

#### Measured

A throwaway script (`~/scratch/cardon/doors/py/measure.py`) on the
generic harness, snes9x, two `release` builds that differ only in
`runtime/decompress.s`: the harness's jump next to a real door (not
measured), control, then the hero walks into it; hardware frames from the
first frame held to control on the new map.

ABL, Lashe City's doors (no `.msu`):

    door                 before   after
    8>10 EV0033            86       86
    8>10 EV0055            86       86
    9>11 EV0009            90       89
    11>9 EV0004           124      122
    8>9  EV0009           119      118
    9>8  EV0003            95       95

Zero to two frames a door, as Chajá's 0.6 and 1.6 said; the carry is gone
on all six: `CARRY_MAP` was the map left before, `$FFFF` after.

Desert Nightmare, nine of its `ShowScreen` doors picked at random (maps 4,
10, 5, 63, 22, 177, 61, 59 and 142): 85 to 99 frames each, **the same
frame count before and after on all nine**, and `CARRY_MAP` the map left
on both. Its three plain doors that end right after the jump (maps 178 and
184) the script could not walk into from any side, and were not measured.
So (a) leaves Desert Nightmare's doors as slow as they were —the 4.8
frames a load of 2026-10-18 stand—: the follow-up, and the question of
what to do about it, is the draft
[`a-door-that-shows-the-screen-after-its-jump-still-carries-the-maps-bytecode`](a-door-that-shows-the-screen-after-its-jump-still-carries-the-maps-bytecode.md).
(b) was not done.

#### Verified

With `just install-local .local-tools advocate` in the-advocate's
worktree and that `bin/` first in the PATH:

* the-advocate: `just lint` (FluidR3), `just test` 31, `env -u SOUNDFONT
  just rust-test` —three of fxpak's pty tests red with "another fxpak is
  using the port", other agents' runs at the same time; `just crate-test
  fxpak` alone, green—, `just test-game` 235 passed, 6 skipped;
* the ports: `just boot` at the root, 209 passed; ABL's `just tests`,
  1621 passed before merging main and 1623 passed, 2 skipped after;
  `just lint` and `just test-game` again after it, green
  (the-advocate `130dffd7`, the ports at `7ff51a0b`). **No golden moved.**

Not covered by any test: a page inside a call that teleports and whose
caller ends right after —it is carried as before, on purpose—, and a
chain of more than four `OP_GOTO`s, which carries as before too.

To install when merging: `advocate` (the runtime only; no crate changed).
