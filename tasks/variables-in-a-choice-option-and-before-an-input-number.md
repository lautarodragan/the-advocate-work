---
name: "\\V[n] in a choice option and before an InputNumber"
description: "Only a plain ShowMessage turns \\V[n] into the variable's digits; a choice's options and the box in front of an InputNumber keep the escape and the page is refused. Frozen World: 3 merchants (6 pages) and the use-item menu (5 pages)"
type: feature
status: testing
assignee: taro
agents: [Mulita]
---

Seen by Calandria on 2026-10-14, with the-advocate `14e200fc` and the ports
`f775b66`, measuring what The Frozen World leaves out
([research](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-14-book-of-three-and-frozen-world-left-out.html)).
**Read in the data and the compiler, not played.**

**What is seen**:

* The merchants on map 50 (event 20, two pages), map 51 (event 29, page 4)
  and map 128 (events 7, 21 and 25) offer consumables or "plates", and the
  last option of each is "[Keep Lutine's \V[0126] gold]". The pages are left
  out: those three merchants sell nothing.
* Map 14, "Use Menu", events 3 to 7: "[1] Health Candy (have \V[0103])" in a
  box followed by an `InputNumber`. The same pages also need
  [`controlvars-from-an-item-count`](controlvars-from-an-item-count.md).
  Map 14 is part of the combat, which is not in the cartridge.

**Where it stops**: `with_variables` (which turns `\V[n]` into the variable's
mark) is applied in the `SHOW_MESSAGE` arm only. `choice_boxes` and
`compile_number` call `messages.add` with the text as it is, so `escape_tail`
finds the backslash and refuses it.

No other game has a `\V` in an option: 6 in the eight dumps, all here.

**Done** by Mulita on 2026-10-14 (the-advocate `84cc60e5`, same commit as [`a-literal-backslash-in-messages`](a-literal-backslash-in-messages.md)). `choice_boxes` and `compile_number` now run `with_names` and `with_variables` like the `ShowMessage` arm. In Frozen World `just culprits`, `ShowChoice` and `InputNumber` are no longer among the culprits: the three merchants and the use-item menu's boxes compile (the `InputNumber` pages did not need another fix; the item-count `ControlVars` was already done). Tests: compiler unit test (red before) and ABL `test_escapes_in_text.py` (option with `\V` against the same option with the number written). The merchants' Known issue is removed from the book.
