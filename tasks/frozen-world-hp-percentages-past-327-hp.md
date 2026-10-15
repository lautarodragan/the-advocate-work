---
name: "The Frozen World's HP percentages come out low past 327 HP"
description: "CalculateHPPercents multiplies the HP by 100 and then divides by the maximum; the product passes the sixteen-bit variable and clamps at 32767"
type: bug
status: draft
---

Seen by Tijereta on 2026-10-14, with the-advocate `51f05d7c` plus the branch
`tijereta-controlvars` and the ports `5272c1e`, reading the data (not
played: it is the combat, which is not in the cartridge).

**What would be seen**: common event 38 of The Frozen World,
`CalculateHPPercents`, does `var = HP; var *= 100; var /= max HP` for three
combatants (variables 174 to 176). Its actors reach 473 to 944 HP. The
console's variables are sixteen bits, so from 328 HP on the product clamps
at 32767 and the percentage comes out lower than RM2k's: 944 HP of 944
gives 34 instead of 100.

**Why**: [Variables saturate at sixteen
bits](https://lautarodragan.github.io/the-advocate-docs/divergences/variables-saturate-at-16-bits.html).
Multiplying clamps since
[`controlvars-multiply-and-divide`](controlvars-multiply-and-divide.md);
before, the page did not compile.

**What it would take**: either 32-bit variables, or a compiler pass that
fuses a multiply followed by a divide on the same variable into one
operation with a 32-bit intermediate (nothing can read the variable between
two consecutive commands). It only matters once the combat (maps 1 and 2) is
in the cartridge.

### taro and Hornero, 2026-10-14: 32-bit arithmetic is not enough

taro asked about doing the arithmetic in 32 bits with 16-bit variables.
The 65816 does it in software (and `var_arith` already multiplies into a
32-bit product), but here the product is **stored** between commands —
`var = HP`, `var *= 100`, `var /= max HP`— so it saturates when stored,
whatever width each command computes in. What would fix it without
widening every variable: the compiler gives 4 bytes only to the variables
that are multiplied and then divided (or set to constants past the word),
and the runtime keeps those in 32 bits. Not a priority (taro).

### taro, 2026-10-14: how to approach it, in order

taro prefers **the hidden high half**: "a kind of carry register for RPG
Maker's variables". Even with parallel events, execution at run time is
sequential, so a single register can carry what overflowed the last
result into the next operation on that variable.

Better still: **detect the patterns at build time** and replace the
original commands with synthetic commands of The Advocate's own, designed
to do the arithmetic in 32 bits without more RAM —e.g. `var = HP; var *=
100; var /= max` compiled as one multiply-then-divide with a 32-bit
intermediate—.

And if something really needs to **store** a value that does not fit in 16
bits, 32-bit variables are unavoidable; then choosing each variable's
width at build time makes sense, but by the numbers it has to hold, not by
which operations touch it.

Priorities (taro):

1. A solution whose RAM is **constant**, independent of which operations
   exist at run time (the carry register).
2. Second, optimise at build time as much as possible (the synthetic
   commands; the width by the values a variable must hold).
