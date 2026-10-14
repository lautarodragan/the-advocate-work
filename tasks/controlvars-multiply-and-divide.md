---
name: "ControlVars: multiply and divide"
description: "The compiler does set, add and subtract; multiply, divide and modulo do not compile. Book of Three 53 uses (Cash Reward in 52 troops, the Glory Hound common event), Frozen World 6, Sunset 4, Vampires Dawn 7"
type: feature
status: draft
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
