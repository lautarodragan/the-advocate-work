---
name: "ControlVars: random ranges wider than 255"
description: "A random operand whose range is 256 or wider does not compile; in The Book of Three that skips 82 calls to the chests' common event, 'Random Chest List'"
type: bug
status: testing
assignee: taro
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

## Done (Tijereta, 2026-10-14)

From the-advocate `14e200fc` and the ports `f775b66`, branch
`tijereta-bot-fixes` in both.

* **Compiler** (`CONTROL_VARS`, the `VAR_RANDOM` branch, in
  `rm2k-snes/events/src/compile.rs`): any range in the signed word, ends
  swapped if reversed —easyrpg's `ControlVariables::Random` takes the min
  and the max—. The operand's high byte of `b` is masked instead of checked,
  since a random's `b` can now be negative. Test
  `a_random_operand_takes_any_range_in_the_word`, red before.
* **Runtime** (`op_var`'s `var_random`, `runtime/interpreter_variables.s`):
  a range narrower than 256 still goes through the hardware's divider, so
  every number drawn before is the same; a wider one by a sixteen-bit
  shift-and-subtract, and the whole word (n wraps to 0) as the draw itself.
  Modulo bias as before.
* **ROM test**: `test_a_random_range_wider_than_a_byte` in ABL's
  `tests/rpgmaker/test_variables.py`, case `variables-random-wide`: five
  draws in a row (1000–2500, 500–100 reversed, -300 to -10, the whole word,
  0–100) against Python's xorshift.

**When merging**: reinstall `events`, `convert` and `cartridge` (the runtime changed). `op_var` grew in bank 0 by the long division; `just space` measured on the branch (see the report). The draws below 256 give the same numbers as before: no golden moved in ABL's suite.

**Not covered**: whether the chests' loot is right in play (not played); the test looks at the draw, the culprits at the common compiling.
