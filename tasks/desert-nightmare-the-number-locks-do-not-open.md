---
name: "Desert Nightmare: the number locks do not open"
description: "Four locks are left out: an InputNumber with no message of its own, which the ROM does not do, and two codes past sixteen bits —71456, the warehouse's safe that ends day 1, and 136264—"
type: bug
status: doing
assignee: Tijereta
game: desert-nightmare
agents: [Hurón]
---

Seen by Hurón on 2026-11-19, at the-advocate `62b6e5cb` and the ports
`1ea90bf`, for
[`desert-nightmare-what-it-takes-to-be-playable`](desert-nightmare-what-it-takes-to-be-playable.md).
Read from `just culprits` (`build/release/culprits.json`), not played.

The four map pages that do not compile are the game's number locks:

* map 28, event 12 page 3: the warehouse's safe, **71456** in five
  digits —its key is the way out of the warehouse, the end of day 1—;
* map 42, event 3 page 1: five digits into variable 210 (the chest of
  day 2, 26538 in the walkthrough);
* map 123, event 5 page 1: four digits, **1759**, the tailor's door of
  day 3;
* map 156, event 10 page 1: **136264** in six digits, the chest in the
  second vault of day 3.

All four put the `InputNumber` after the message is over —a
`ChangeFaceGraphic` or the box closed in between—, which in RPG_RT is a
window of its own with only the digits; the compiler takes an
`InputNumber` only inside the message before it (`number_inputs` in
`compile.rs` of the event compiler). And two compare against numbers a
variable of the ROM cannot hold: it keeps sixteen bits, saturating at
32767, and RPG_RT's go to 9,999,999 (`NUMBER_DIGITS_MAX` and
`runtime/number_input.s`).

## Taken (2026-11-20)

By Tijereta, from Hurón's ranking in `desert-nightmare-what-it-takes-to-be-playable`. taro: "dale!".
