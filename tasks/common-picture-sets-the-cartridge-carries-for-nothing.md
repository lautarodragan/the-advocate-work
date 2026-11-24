---
name: "Sets of common pictures the cartridge carries for nothing"
description: "The common events' small pictures go in the cartridge by sets since 2026-10-20: A Blurred Line carries one for a menu nothing opens, and Desert Nightmare the same 320 tiles twice, under two sets"
type: refactor
status: todo
agents: [cardon]
author: carpintero
links:
  found-in: [pictures-in-common-events-compiled-apart-are-not-shown]
---

Seen by Carpintero on 2026-10-20, with the-advocate's branch
`carpintero-ce-pictures` (`54cf582b`) and the ports' of the same name,
reading each game's `build/release/converter.log` after
[`pictures-in-common-events-compiled-apart-are-not-shown`](pictures-in-common-events-compiled-apart-are-not-shown.md).
Only cartridge is lost; nothing is seen wrong.

* **A Blurred Line, common event 11** (`CustomMenuHier1`, automatic on
  switch 335): its set, 192 tiles, fits on 190 of the 313 maps and is
  carried, but only item 150, `SCRATCHEDOUT`, turns 335 on, and nothing
  gives that item. `common_pages.rs` in the converter already asks "can
  something turn this switch on?" for the copies, without counting switch
  items; the sets do not ask at all. Chajá saw the same for the big
  pictures of common 16 on 2026-10-19.
* **Desert Nightmare, common events 2, 5, 7, 9, 11, 12, 13 and common 4**:
  two sets —an automatic one with what it calls, and a parallel one that
  pastes the same body— with the same two pictures, `TextboxInnen` and
  `TextboxRahmen`, so the same 320 tiles twice. Two sets with the same keys
  could be one: a parallel one's pasted pictures are compiled with its own
  set, but nothing stops that set from being another's.

How to see it: the lines "common events …: their small pictures …, go up
when shown" and "…fit on N of the M maps" in each game's converter log.

## Log

### 2026-11-24, Cardón: to todo

Only cartridge space, nothing seen: code debt with an obvious fix —a set
asks whether its switch can be turned on (switch items included, as
`common_pages.rs` should too), and two sets with the same pictures are
one—. No commit since `54cf582b` touches the sets' choice (log of
`rm2k-snes/convert/src/common_pages.rs` since 2026-10-20). The task starts
by confirming the two converter-log lines still say so.
