---
name: "Four shortcuts for the other games"
description: "The direction condition, the missing route orders, PlayerVisibility and Comment in troop pages: the cheap stuff that unblocks the most pages in the seven games"
type: feature
status: done
agents: [Chajá]
assignee: taro
---

Measured by Hornero on 2026-10-06 with `rm2k-snes-events culprits --every-map`
over the seven games, after the merge of the colour codes. The
pages that **only** that command leaves out:

* `ConditionalBranch` type 6, by a character's direction: Sunset 111,
  Vampires Dawn 37, El Dorado 23, Desert 21. Already in
  `maps-loose-commands.md`, for ABL (31 pages).
* `MoveEvent` with orders the ROM doesn't understand: the random step (8) in
  Desert (39) and Vampires Dawn (16), move away from the hero (10) in Vampires Dawn
  (48) and El Dorado (9), and Sunset's routes with 36/37 (about 40; it remains to see which
  order is the one that blocks). `route-the-missing-moves.md` says
  they didn't pay off: in ABL it was true, in these games it isn't.
* `PlayerVisibility`: El Dorado 170.
* `Comment` in troop pages: The Book of Three 153. In maps
  it is already ignored.

taro, on 2026-10-06: "Go ahead!", with Sonnet.

## Chajá, 2026-10-06

Four commits in the tools, one per shortcut, plus one that came out of
measuring them, and four in ABL (branch `chaja-atajos` of its clone). Each command with
its test in the crate, shown red before the fix.

**The opcodes taken**: `OP_IF_FACING = 0x47` and `OP_HERO_VISIBLE =
0x48`. The next free one is 0x49.

**1. The direction condition** (`OP_IF_FACING`: character, direction,
destination). The character is the hero, "this event" or an event by its number,
with the same `target_of` as routes. The hero's direction is `hero_dir`;
an event's, from where `face_diagonal` reads it: its route's slot if it has already
turned it, and otherwise the row of the NPC table. **An event without a row answers
down**, which is RM2k's default value; it differs only for an
invisible event whose page faces elsewhere and which a condition asks about.

**2. Routes.** Orders 8 (random step), 10 (move away from the
hero) and 22 (face the other way) go in, **only on events** and not inside
a jump, like 9 and 21. Moving away is `toward_hero` turned half a circle,
identical in all cases including the tie; the random step takes two bits
from the map's xorshift, so it is random but it isn't RM2k's generator.

**What blocks Sunset's routes with 36/37 isn't 36/37**, which already
compiled: it is **the hero's diagonals** (4 to 7), which the compiler
rejects on purpose. It is what leaves the most pages now: about 51 in Sunset and 45
in Vampires Dawn, measured. **It wasn't done**, and why is in
`route-the-missing-moves.md`: it is a new hero step, not
four copied routines, and there is nothing to compare it with. The hero's relative turns (16
to 20) and move forward (11) weren't either: about 8 pages in Sunset.

**3. `PlayerVisibility`** (`OP_HERO_VISIBLE`, one byte). The hidden hero isn't
drawn and everything else stays the same. The state is the player's: it survives the
map, starts visible at boot and **travels in the saved game** —one line
of `save_table` and one byte of `SAVE_BYTES`—, so **games saved
with the previous ROM stop loading**.

**4. `Comment` in troop pages**: two lines in
`TROOP_COMMANDS`. It doesn't emit a byte, so there is no ROM path to execute.

**What came out of measuring: `SUB_MAX` from 8 to 16.** With all of the above El
Dorado stopped building: map 7 asks for nine substituted blocks and the table
carried eight; the ninth is brought by a page that didn't compile before. 32 bytes
of bank 0 BSS, which is left with 1,995 B free in `abl`. **Every time
pages get in it may happen again**; nobody measured how many the map
that asks for the most among the seven asks for.

### Pages that compile, before and after

`culprits --every-map`, with the same request per game and the binaries from
`main` against those from the worktree. Maps, except where stated.

| game | before | after | |
|---|---|---|---|
| The Book of Three | 206 of 746 (troops) | 359 of 746 (troops) | +153, the `Comment` ones; the maps don't change |
| Desert Nightmare | 7034 of 7340 | 7150 of 7340 | +116 |
| El Dorado | 710 of 972 | 963 of 972 | +253, and one more common event (9 to 10 of 10) |
| Sunset Over Imdahl | 1151 of 1369 | 1266 of 1369 | +115 |
| Vampires Dawn | 21214 of 22977 | 21272 of 22977 | +58 |
| ABL | 5560 of 5601 | 5592 of 5601 | +32: Eisen's 31 and one more |

Vampires Dawn **doesn't finish building** because of something else —map 1 and its
ending pictures, same as before this—, so its number comes from
`scan`, not from a cartridge. There they fall below what was expected because it has
more than one command blocking the same page; what it has left in `MoveEvent` is
the hero's diagonals.

The ROMs of the games that build —The Book of Three, Desert Nightmare, El
Dorado and Sunset— are in `/shared/builds/other-games/<juego>.sfc`.

### ABL

**The suite: 1147 green** with the worktree's tools (1136 from before
and the 11 new tests), and **no golden changed**. `abl.sfc` went from
`27e94e67039533a2…` to `602b60e0e0635bfb…`, and it is reproducible: the same with
`NO_CACHE=1`. It changes because of four things, all expected: the runtime carries
new routines and opcodes; the 32 pages that now compile; `hero_hidden`
in the saved game and `SUB_MAX`; and the seven new test cases, which
`release` carries all of. **Whether the 32 pages can be reached while
playing wasn't looked at**: they are Eisen's simulation, and no golden sees them change.

Branch `chaja-atajos` of the clone `/extras/scratch/chaja/abl-atajos`: three tests
(`test_conditional_by_direction.py`, `test_routes_moving_away.py`,
`test_hidden_hero.py`), their cases, and two fixes the suite asked for by itself:
the index in the tests' README, and the subtraction in `test_the_music_travels_in_the_save`,
which duplicates `save_table` and warns every time the save grows.

### What the suite doesn't cover

* **That `hero_hidden` travels in a save and is loaded.** It is only tested that
  the format adds up and that the state lives in RAM.
* **An event whose direction a route has already changed**, in the direction
  condition: the tests look at its page's, not the slot's. The same
  for an event without a row that faces elsewhere.
* **The tie when moving away from the hero**: it is covered only by reasoning —it is
  `toward_hero` turned around—, there is no case with the hero on an exact
  diagonal.
* **That the random step is random**: the test checks that it doesn't always go
  the same way in sixteen steps, with the boot seed.
* **The games themselves**: none of the new pages of the other games was
  played; what is checked is that they compile and that the cartridges build.

## When merging

Reinstall in the global `events cartridge convert`: the compiler, the runtime
and the bytecode, and the converter because of `SUB_MAX`. `bytecode` changed, and
`rm2k-snes-audio` compiles it in: if any music is built with that tool,
it too; the music stream didn't change.

ABL: `git pull` of the `chaja-atajos` branch of Chajá's clone.
