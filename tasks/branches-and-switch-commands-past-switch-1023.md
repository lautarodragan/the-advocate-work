---
name: "Branches and switch commands past switch 1023"
description: "ControlSwitches on a switch past the ROM's 1024 compiles and writes outside the switch table (Frozen World 78 commands, Vampires Dawn 1,014); the branch on one is refused and leaves pages out (63 and 39)"
type: bug
status: testing
assignee: taro
agents: [Tijereta]
---

Seen by Calandria on 2026-10-14, with the-advocate `14e200fc` and the ports
`f775b66`, measuring what The Frozen World leaves out
([research](https://lautarodragan.github.io/the-advocate-docs/progress/book-of-three-and-frozen-world.html)).
**Read in the compiler and in the compiled output; the ROM was not run.**

**What is seen**: the ROM keeps 1,024 switches (`SWITCH_BYTES` is 128, in
`low_ram.s`, a table in the low RAM). Two things touch a switch past 1,023
differently:

* **The branch** (`ConditionalBranch` on a switch) is refused: `branch_bytes`
  in `compile.rs` checks `0..SWITCH_MAX`. It leaves out Frozen World's map
  pages 1/7, 1/18, 1/25 (map 1 is not in the cartridge), 14/15, 153/6 (two
  pages) and common events 23, 24, 26, 27, 36 and 37.
* **`ControlSwitches` is not checked at all.** The arm of `CONTROL_SWITCHES`
  only limits a range to 64 and writes `OP_SWITCH` with the number as a word.
  `set_switch` (`runtime/variables.s`) takes `n / 8` as an index into
  `switches`, so a switch past 1,023 writes a bit past the table, into
  whatever the linker put after it. The Frozen World has 78 such commands
  (up to switch 1,077, seven bytes past the table): 28 map pages (maps 19,
  27, 31, 76 to 79, 86 to 89, 105 to 107, 111, 128, 131, 135, 138, 140, 143,
  147, 151, 154) and common events 11, 69 and 70 compile with one. Map 19,
  event 12, page 1 starts with `OP_SWITCH $041B, on`: switch 1,051. Vampires
  Dawn has 1,014, up to switch 1,643.

What a player sees from the stray write was not looked at: it depends on what
follows `switches`.

**Uses in the eight dumps**: `ControlSwitches` past 1,023, Frozen World 78,
Vampires Dawn 1,014; branches, Frozen World 63, Vampires Dawn 39; page
conditions, Frozen World 45, Vampires Dawn 735, which is the other draft:
[`page-conditions-on-switches-past-1023-read-other-ram`](page-conditions-on-switches-past-1023-read-other-ram.md).
That draft says the compiler refuses the commands that touch such a switch;
it refuses the branch only.

**How to see it**: `rm2k-snes-events compile` with `frozen-world/build/release/events-request.json`
and the game's `data/`; map 19's page code starts `011b0401`.


## The fix (Tijereta, 2026-10-15)

Taken together with
[`page-conditions-on-switches-past-1023-read-other-ram`](page-conditions-on-switches-past-1023-read-other-ram.md):
one table, one size, every reader. Branches `tijereta-switches` in
the-advocate, the ports and the book.

* **The table is the game's.** The event compiler's indices carry
  `switch_top`, the highest switch the game names anywhere —every page of
  every map, troop and common event, compiled or not: conditions, triggers,
  `ControlSwitches` single and range, branches; the database's switch items
  and skills; the test pages, the harness's `TEST_SWITCH` and the custom
  menus' conditions, which the converter sends as `extra_switches`—. The
  scan answers it, the converter passes it to `rm2k-snes-mapdata`, and
  `SWITCH_BYTES` is `switch_top / 8 + 1`. Measured: Vampires Dawn 206
  bytes (1643), The Frozen World 135 (1077), ABL 138 (1103: map 348's fork
  and the new case; without them 1023, the harness's, and 1008 the game's).
* **Every command, toggle, branch, troop trigger, common trigger and page
  condition is checked against it** (`Indices::holds_switch`):
  `ControlSwitches` was not checked at all. Since the table holds every
  switch named, the checks guard a mistake, not a game; a game that names
  2048 or more is refused by the converter.
* **The table moved to far RAM**: the bank 0 BSS had 20 bytes and `FARBSS`
  13, in ABL. It has its own area, `SWITCHRAM`, 256 bytes at `$7E7D00`,
  which the materials' table left free on 2026-10-14: segment `SWITCHES`,
  declared in `runtime/switches.s`, after `mapdata.inc`. Readers and
  writers take it with a long index —`set_switch`, `switch_on`, the common
  events' `switch_of` and `compar_one`, the battle's `ba_page_switch` and
  switch skills, the custom menus, boot's clear— and the save with
  `.loword`. ABL's bank 0 pays 9 bytes; its BSS gets 128 back. `just
  space` prints what the table leaves: VD 50, FW 121, ABL 118.
* **The save format changes** with the size: `SAVE_BYTES` and
  `GAME_SIGNATURE` see it. Saves from before do not load, in any game.

**Tests**: compiler tests in `compile.rs` (a switch past 1023 set, a range
and a toggle, the branch, and refused past the table), `indices.rs` (each
place that names a switch raises the table; past 2047 refused), mapdata's
`switch_bytes`, and `the_scan_says_the_highest_switch`. In ABL,
`tests/rpgmaker/test_switches_past_1023.py`, with the case
`switches-past-1023` and a fork of map 348 (a test map) that adds an
invisible event whose only page, parallel, asks for 1100 and turns on 1101:
the case waits, checks 1101 is off, turns on 1100 and branches on it. Red
with the global tools: the case's page does not compile, `release` does not
build. Green with these, and the whole suite green, no golden moved; `just
boot` green.

**`just culprits`**, global tools against these on the same request (before merging main):
Frozen World commons 94 → 99 compile, maps 3871 → 3876 (the branch as the
only culprit, 5 → 0); Vampires Dawn commons 26 → 29, maps 17611 → 17613.

VD's map 433, seen in the ROM and not played: switch 1521 reads off on
entering, and the table is 206 bytes at `$7E7D00`. Which page the figures
take was not looked at.

**What the suite does not cover**: the switch skill and the switch item
past 1023 (VD has one of each), the custom menus' switch conditions past
1023 (no game has one), the troop pages' switch triggers past 1023 (none
compile in VD or FW yet), and the save carrying a table bigger than 128
(the suite's save tests run with ABL's 138, which is bigger, so that one
is covered).

**To install when merging**: `events`, `mapdata`, `convert` and `cartridge`
—`cartridge` because the runtime's memory map gets the `SWITCHRAM` area—.
