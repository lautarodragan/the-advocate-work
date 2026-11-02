---
name: "An InputNumber after a label has no message to go into"
description: "Zounds' dice man (map 156, event 26) asks for the die's number with a ShowMessage, a Label and then the InputNumber: the label sits between them, so the number is a window of its own, which the ROM does not draw, and the page stays out"
type: bug
status: draft
---

Seen by Calandria on 2026-11-02, doing
[`zounds-mining-and-the-jail-do-not-compile`](zounds-mining-and-the-jail-do-not-compile.md),
with the-advocate `calandria-zounds-mining` (from `0ba09da4`), running
`just culprits` in `zounds/` of the ports.

**What was seen**: map 156's event 26, the "Hombre de los Dados", left
Zounds' culprits list for its `Loop` —one that breaks, which compiles
now— and stays out for the next culprit, the `InputNumber` of one digit
into variable 98 (command 41). Its message, "Ahora, elige un número del
dado.", is command 39, and command 40 is `Label 1`, which the "¡Ese no
sirve!" branches jump back to. `number_inputs` in
`rm2k-snes/events/src/compile.rs` pairs an `InputNumber` only with the
`ShowMessage` right before it, so here the number is a window with no
text, which the ROM does not do. In RPG_RT the label does nothing and
`CommandShowMessage` takes the `InputNumber` into the same box; after a
jump back to the label the number opens alone, with no text, which is
what the ROM would have to draw then.

**How to reproduce**: `just culprits` in `zounds/` with that compiler;
map 156, event 26, page 1.
