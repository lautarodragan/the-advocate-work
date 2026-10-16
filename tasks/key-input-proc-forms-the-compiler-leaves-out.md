---
name: "KeyInputProc: the forms the compiler leaves out"
description: "Some directions and not others, the timed form of RPG Maker 2003 and the keys the pad does not have: no game of the nine asks for the first two, and the third is noted as a degradation"
type: feature
status: draft
---

Seen by Aguará on 2026-10-16, with the-advocate `af7c399d` and the ports
`f28916b`, while compiling the long forms of `KeyInputProc` for Zounds
([`zounds-the-intro-on-map-106-waits-for-a-key-nobody-reads`](zounds-the-intro-on-map-106-waits-for-a-key-nobody-reads.md)).

**What compiles**: the five-parameter form, and the long ones —RM2k 1.50's
ten, RPG Maker 2003's nine and fourteen— when they ask for the same keys as
the short one: the four directions alike, the action key, cancel. The
layout of each is read against easyrpg's `CommandKeyInputProc`; the `is_2003`
of the game decides which.

**What does not, and no game asks for** —measured over the nine dumps:
only Zounds writes a long form, seven times, all with the four directions—:

* **some directions and not others**: `KEY_DIRS` is one flag in `op_key`,
  and the four come from a table in `key_value`. Doing it would be an
  opcode with a pad mask, or four flag bits the byte does not have —it
  carries wait, dirs, decision, cancel, start and the refresh—.
* **the timed form** of 2003 (parameter 8): it also stores in the time
  variable (parameter 7) how long the player took, in tenths.

**What is noted and goes on**: shift, the number keys and the operators,
which the pad does not have. A page asking for them with the other keys
compiles, with a `key-not-on-the-pad` degradation per key, and those
keys never come —which is what RM2k does on a keyboard without them—.
Zounds' common events 3 and 7 ask for shift, numbers and operators along
with everything else, and common event 40 for shift. A page asking only
for them does not compile, since it would wait forever.

How to see it: `just culprits` in a game whose pages carry one of the two
forms; the compiler's unit test
`key_input_proc_long_forms_that_are_the_short_form_compile_as_it` has one
of each.
