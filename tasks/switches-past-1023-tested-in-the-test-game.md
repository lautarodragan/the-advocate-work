---
name: "Switches past 1023, tested in the test game"
description: "The switches-past-1023 ROM test leaves ABL —its fork of map 348 goes— for a map of the test game"
type: chore
status: doing
assignee: Calandria
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
