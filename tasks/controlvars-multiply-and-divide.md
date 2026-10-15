---
name: "ControlVars: multiply and divide"
description: "The compiler does set, add and subtract; multiply, divide and modulo do not compile. Book of Three 53 uses (Cash Reward in 52 troops, the Glory Hound common event), Frozen World 6, Sunset 4, Vampires Dawn 7"
type: feature
status: testing
assignee: taro
agents: [Tijereta]
---

Seen by Calandria on 2026-10-14, with the-advocate `14e200fc` and the ports
`f775b66`, measuring what The Book of Three and The Frozen World leave out
([research](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-14-book-of-three-and-frozen-world-left-out.html)).

**What is seen** (not played):

* Book of Three: Taran's **Cash Reward** (steal silver) is a page in 52
  troops that does `ControlVars` 8 *= variable 9; the page does not compile,
  so the command does nothing. Common event 13, `Glory Hound` (parallel,
  switch 95), has a multiplication by a variable too.
* Frozen World: common event 38, `CalculateHPPercents`, called 11 times from
  the combat on maps 1 and 14 (not in the cartridge), multiplies by 100 and
  divides by a variable.

**Where it stops**: the `CONTROL_VARS` arm of `compile.rs` accepts
`VAR_SET | VAR_ADD | VAR_SUBTRACT` (0, 1, 2) and refuses the operation
otherwise: 3 multiply, 4 divide, 5 modulo.

**Uses in the eight dumps**: multiply, Book of Three 53, Frozen World 3,
Sunset 4, Vampires Dawn 1; divide, Frozen World 3, Vampires Dawn 6; modulo,
none.

**Note**: the variables are 16 bits signed (see the divergence
[Variables saturate at sixteen bits](https://lautarodragan.github.io/the-advocate-docs/divergences/variables-saturate-at-16-bits.html));
what a multiplication that overflows does is a question for whoever takes it.

## Done (Tijereta, 2026-10-14)

From the-advocate `51f05d7c` and the ports `5272c1e`, branches
`tijereta-controlvars` in both, and in the book.

* **The compiler** takes the six operations of RM2k (set, add, subtract,
  multiply, divide, modulo) with any operand class; the Maniacs' bitwise ones
  (6 and up) still do not compile. A constant outside the word does not
  compile for the three new ones, as for add and subtract.
* **The ROM**: `var_arith`, in the new `runtime/variable_arithmetic.s` (FAR,
  outside bank 0), as easyrpg's `VarMult`, `VarDiv` and `VarMod`: the product
  is taken whole in 32 bits and clamped to the word (-32768..32767);
  division truncates toward zero and the remainder takes the dividend's
  sign; by zero the division leaves the variable and the modulo gives 0;
  -32768 / -1 clamps to 32767. The division is `udiv16`, the sixteen-bit
  shift-and-subtract the random range used inline, now a routine both share
  (the random draws are the same: `test_a_random_range_wider_than_a_byte`
  stays green).
* **What 16 bits lose**: a product a later command brings back into range.
  Written in the book's divergence *Variables saturate at sixteen bits*; the
  case that would show it is The Frozen World's HP percentages, draft
  [`frozen-world-hp-percentages-past-327-hp`](frozen-world-hp-percentages-past-327-hp.md),
  behind its combat.

**Tests**: `multiply_divide_and_modulo_compile` in the event compiler (red
before); ABL's `test_multiply_divide_and_modulo_are_rm2ks`, case
`variables-arithmetic`: fifteen operations against Python (both edges of the
clamp with and without a high word, the signs of division and remainder,
both by zero, -32768 / -1, and by a variable). With the old tools the case
does not compile, so the release cartridge does not build.

**`just culprits`**, before and after (same request, the main checkout's):

* Book of Three: commons 22 → 24 of 25 (with the item count), maps 1275 →
  1276, troops 499 → 551 (Cash Reward's 52 pages); no ControlVars culprit
  left.
* Frozen World: commons 89 → 90; ControlVars gone from commons and maps.
* Sunset over Imdahl: maps 1338 → 1342; ControlVars culprits 5 → 1.
* Vampires Dawn: maps 17608 → 17609; ControlVars culprits 50 → 29 in
  commons and 1427 → 1396 in maps (what is left is other causes).

**Install when merging**: `events`, `convert`; the runtime changes too.
