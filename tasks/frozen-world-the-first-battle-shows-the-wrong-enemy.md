---
name: "Frozen World: the first battle shows the wrong enemy"
description: "The game's first battle, started by a plant on the map, shows a dark hooded figure —the final enemy's or the intro's wizard's graphic— instead of the plant"
type: bug
status: testing
assignee: taro
agents: [Tijereta]
---

Seen by taro on 2026-10-19, playing Frozen World's delivery of that day
(the ports `acff443`, the-advocate `2c350d8f`), after Carpintero's fix of
the cursor's graphics.

**What is seen**: the first battle of the game is started by a plant's
sprite on the map, and on the battle map the enemy is a dark hooded
figure; a later battle shows the plant, as expected. taro thinks the
figure is the final enemy's, or at least the wizard of the intro: it makes
no sense so early. Captures in
`/shared/captures/2026-10-20-frozen-world-wrong-enemy/`: `1-first-battle.png`
(the figure), `2-plant.png` (a later battle with the plant).

**Probably related**: the battle is map 1, where the enemy is an event
whose graphic is set by the custom battle system; Carpintero's
[`frozen-world-the-cursor-keeps-the-wrong-graphic`](frozen-world-the-cursor-keeps-the-wrong-graphic.md)
changed how route graphics are numbered across jumps and in common
events, and
[`frozen-world-plates-in-the-battle-are-drawn-with-other-colours`](frozen-world-plates-in-the-battle-are-drawn-with-other-colours.md)
says map 1 has no palettes to spare.

## The cause (2026-10-19, Tijereta)

Reproduced with the-advocate `2c350d8f` and the ports `1182513`: from the
cell below the plant —event 2 of map 12, the cave next to the beach, at
(12,33)—, a step up starts the battle with the hooded figure.

**What RM2k shows**, read in the dump: the plant's page turns switch 218
on and teleports to map 1, whose `CombatController` (event 7, automatic)
calls common event 14, "Monster Party 2": switches 176 and 217. Monster A
(event 2 of map 1) has 29 pages, each asking for 176 and one more switch;
page 2, on 217, is the plant (`sforceW` 3). Page 28 asks for **1023** and
is `EEEEVIL` 5, the wizard; page 29 asks for 1059. Only common event 69,
"Monster Party 41", turns 1023 on, and common event 11,
"PostBattleCleanup", turns it off with the rest. A new game starts with
every switch off, so the first battle is the plant.

**Why ours differs**: switch 1023 is already on at the first game frame,
alone. It is the converter's `TEST_SWITCH` (`rm2k-snes/convert/src/compiler.rs`):
the test pages that every cartridge with cases carries —the release too,
with its empty case `nothing`— turn it on first so as not to repeat, and
the last page, which asks for it, ends them. It is a convention of ABL's
harness from the start ("the game checks switches up to 1003 and 1023 is
the test page's", `abl/tests/harness/events.py`), never checked against
the game's own switches. The first battle finds it on and Monster A picks
page 28; the cleanup after that battle turns it off, which is why the later
battles show the right enemy. Not new from Carpintero's route graphics: it
is as old as the port. Of the nine games only The Frozen World names 1023
(Monster A's page 28, and common events 11 and 69).

## The fix (2026-10-19, Tijereta)

The test pages' switch is now **one the game does not name**: the
converter asks the events' scan for 1023 (`test_switch` in the request),
and the scan answers it, or the first switch above it that nothing names
—`indices::test_switch` in `rm2k-snes-events`, over the same sweep as
`switch_top`; a `ControlSwitches` range now names all of it, not only its
ends—. The converter turns that one on in the test pages, asks for it in
their last page and puts it in the table, and the cartridge says it as the
symbol `TEST_SWITCH` (`mapdata.inc`), which the test game's harness reads
instead of its own 1023. The Frozen World's is **1078**, inside the table
it already had (`SWITCH_BYTES` 135); a game that does not name 1023 keeps
it: ABL, the test game and six of the seven ports keep 1023, and ABL's
release came out byte for byte the main checkout's. **Vampires Dawn moves
too**, to 1644: its map 69 turns off every switch from 1 to 1641 with a
range, which until today counted only its ends; its table does not grow
(`SWITCH_BYTES` 206 either way). ABL's harness still says 1023 in
`abl/tests/harness/events.py`, which is right for ABL.

The book's decision
[`the-test-page-switches-itself-off`](https://github.com/lautarodragan/the-advocate-docs/blob/main/src/decisions/the-test-page-switches-itself-off.md)
says it now.

**Test**: the ports' `tests/test_frozen_world_first_battle.py`, which plays
to the beach, walks into the cave's plant from below and looks at the
battle: switch 1023 still off, and Monster A's box against its golden,
`frozen-world-first-battle-plant` —the plant, `sforceW` 3—. Red with the
global tools of `2c350d8f` ("switch 1023 is on at the beach"), green with
this branch's. In the-advocate,
`the_test_switch_is_one_the_game_does_not_name` (indices) and
`the_scan_says_the_highest_switch` asks the scan for it.

**Verified**, with this branch's `events`, `mapdata` and `convert`
installed locally: the crate tests of the three; the-advocate's `just test`
(29 passed); `just test-game` with `SOUNDFONT=FluidR3_GM.sf2` (45 passed, 1
skipped), whose harness now reads `TEST_SWITCH`; the ports' `just boot`
(91 passed, Frozen World's cursor tests and the new one included); ABL's
suite, 1572 passed, 2 skipped and one red in `test_cores.py`,
`big-picture-return-240`, which passed twice alone right after on the same
build —the release it plays was byte for byte main's—: draft
[`abl-test-cores-big-picture-return-red-once-in-a-full-run`](abl-test-cores-big-picture-return-red-once-in-a-full-run.md).

**Branches**: `tijereta-fw-enemy` in the-advocate, the ports and the book.
**To install when merging**: `just install events mapdata convert`.

**For taro to play**: a new game to the cave next to the beach, and the
plant: the first battle shows the plant. Not compared with the original
under Wine
([`frozen-world-does-not-open-under-wine`](frozen-world-does-not-open-under-wine.md)):
what RM2k shows is read in the dump.
