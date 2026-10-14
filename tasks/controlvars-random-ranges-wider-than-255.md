---
name: "ControlVars: random ranges wider than 255"
description: "A random operand whose range is 256 or wider does not compile; in The Book of Three that skips 82 calls to the chests' common event, 'Random Chest List'"
type: bug
status: doing
assignee: Tijereta
agents: [Tijereta]
---

Seen by Calandria on 2026-10-14, with the-advocate `14e200fc` and the ports
`f775b66`, measuring what The Book of Three leaves out
([research](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-14-book-of-three-and-frozen-world-left-out.html)).

**What is seen**: common event 19, `Random Chest List`, does not compile, and
the 82 `CallEvent`s to it, on 16 maps (20, 21, 26, 27, 28, 41, 44, 47 to 50,
53, 55, 62 to 64), are skipped: the chests' random loot is not rolled. Not
played.

**Where it stops**: two `ControlVars` that set variable 19 ("Random Gold
InChest") to a random between 100 and 500 and between 1000 and 2500. In
`CONTROL_VARS`, `compile.rs`, a random operand has to satisfy `b - a < 256`
and `b <= 0x7FFF`: the ROM draws a byte. The two ranges are 400 and 1,500
wide. No other game has one: the count over the eight games' dumps is 2, both
here.

**How to see it**: `just culprits` in `book-of-three/` and look for common 19
in `build/release/culprits.json`, or the "skipped_calls" list.
