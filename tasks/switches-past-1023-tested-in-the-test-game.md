---
name: "Switches past 1023, tested in the test game"
description: "The switches-past-1023 ROM test leaves ABL —its fork of map 348 goes— for a map of the test game"
type: chore
status: done
assignee: taro
agents: [Calandria]
---

taro, on 2026-10-15: Tijereta's `test_switches_past_1023` needed a fork of
ABL's map 348 —an invisible event whose only page asks for switch 1100—,
because ABL names no switch past 1008. That made ABL carry an engine test
inside the cartridge taro plays. taro: take it out now and move it to the
test game.

What it asks for:

* in the test game, the same check: a page conditioned on a switch past
  1023, a `ControlSwitches` past 1023 and a branch on one, seen running in
  the ROM;
* in the ports, `patches/manual/forks/Map0348.*` deleted, with the
  `switches-past-1023` case, `abl/tests/rpgmaker/test_switches_past_1023.py`
  and their lines in the tests README; map 348 back to the original;
* ABL's suite still green, and its switch table back to the size ABL's
  own switches ask for.

## Calandria, 2026-10-15

From the-advocate 6124b620 and the ports 115f240, branches
`calandria-switches-test` in both.

The plan: the meadow gets an invisible event whose only page, parallel,
asks for 1100 and turns on 1101 —no new map: below the hero and with no
graphic, it draws nothing, and with 1100 off it has no page—. The test
game gets its first real case, `switches-past-1023`, the same as ABL's
without the `Teleport`, and its harness the minimum to run one: choosing
the case by `CASE_SLOT` and reading a switch. Map 348 stays in ABL's
`[maps] test`: it was there since 2026-10-02, before the fork.

Found on the way: ABL's case `flee-short` turns on 1100 too —older than the
fork, and the switch is the test's own, nothing in ABL names it—, so with
the fork gone ABL's table would still be 138 bytes in every cartridge that
carries the cases. It moves to a switch the game does not name and that
fits under the harness's 1023.

**Done in the test game** (the-advocate `c7c73c40`): the meadow's event
at (1,1), the case `test-game/cases/switches-past-1023.json`,
`test-game/tests/test_switches_past_1023.py`, and in `tests/game.py` the
cases from the builder's listing, `Session(core, case=...)` and
`switch(n)`; the `core` fixture moved to a `conftest.py`. The case ends
around tick 60 counted from the boot (measured), so the test runs 120.
Seen red with two mutations of the event: without its condition, "ran
with 1100 off"; turning on 1099 instead, "did not run with it on". The
meadow's goldens did not move. The test game's table: 138 bytes (1103).

**Done in the ports** (`ee44d9b`, `a397616`): fork, case, test and README
lines gone; `flee-short` and its test on 1022. ABL's table measured on the
new builds: 127 bytes in the cartridges without cases (1008, the game's),
128 in those with them (1023, the harness's); it was 138 in both.

**The book** (`6ca47df`, branch `calandria-switches-test`): the test
game's progress page says the cases exist and what moved out of ABL.
`02cf3a2` in the ports fixes the harness comment that counted the free
switches under 1023 (comment only, after the suite).

**Verified**, with the installed tools (no Rust touched, nothing to
install): `just test-game` 4 passed —meadow and switches, snes9x and
bsnes—; `just test` in the-advocate 29 passed; ABL's `just tests` in the
ports worktree 1553 passed, 2 skipped, `tests/tooling/test_fork_maps.py`
included; `release`'s `abl.sfc` sha256 `681b75cd…f0ede`, `SWITCH_BYTES`
128.

**What the suite no longer covers**: a save carrying a switch table bigger
than 128 bytes. Tijereta's task counted on ABL's 138 for it; ABL is back
at 128, and the test game, at 138, has no save test yet. Also not covered,
as before: the switch skill and item past 1023, the custom menus' switch
conditions past 1023, the troop pages' switch triggers past 1023.

**To install when merging**: nothing; no Rust changed.
